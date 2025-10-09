%{

        /* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "ast.h"

extern int yylex();
extern int linecount;

void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s on line number %d\n", s, linecount);
}

int yylex();

%}
/*  defines the start symbol, what values come back from LEX and how the operators are associated  */

%start Program

%union
{
int value;
char* string;
ASTnode * node;
enum DataTypes datatype;
enum OPERATORS operator;
}

%token <value> T_NUM
%token <string> T_ID T_STRING
%token T_INT T_VOID T_BOOLEAN T_RETURN T_READ T_WRITE T_WHILE T_PLUS
%token T_MINUS T_OR T_AND T_FALSE T_TRUE T_IF T_THEN T_ELSE T_ENDIF 
%token T_DO T_MULT T_DIVIDE T_BEGIN T_END T_NOT T_LE T_LT T_GT T_GE T_EQ T_NE

%type <node> Declaration Declaration_List Var_List Var_Declaration Fun_Declaration 
%type <node> Compound_Stmt Local_Declarations Statement Statement_List Write_Stmt
%type <node> Factor Term Additive_Expression Simple_Expression Expression Selection_Stmt
%type <node> Param Params Param_List Assignment_Stmt Var  Expression_Stmt Iteration_Stmt
%type <node> Return_Stmt Read_Stmt Call Args Arg_List
%type <datatype> Type_Specifier
%type <operator> Add_Op Mult_Op Rel_Op


%left T_OR 
%left T_AND
%left T_EQ T_NE T_LT T_LE T_GT T_GE
%left T_PLUS T_MINUS
%left T_MULT T_DIVIDE '%'
%left UMINUS

%%      /* end specs, begin rules */

Program : Declaration_List
                { program = $1; }
        ;       /* end Program */

Declaration_List  	: Declaration
                        { 
							$$ = ASTCreateNode(A_DEC_LIST); 
                            $$->s1 = $1;
                        }
                    | Declaration Declaration_List
                        { 
                            $$ = ASTCreateNode(A_DEC_LIST); 
								$$->s1 = $1;
								$$->s2 = $2 ;
                        }
                    ;   /* end Declaration_List */

Declaration     : Var_Declaration { $$ = $1; }
                | Fun_Declaration { $$ = $1; }
                ;       /* end Declaration */

Var_Declaration : Type_Specifier Var_List ';' 
					{ 
						$$ = $2; 
						ASTnode* p;
						p = $2;
						while (p != NULL) {
							p->datatype = $1;
							p = p->s1;
						} // end of while
					}
                ;       /* end Var_Declaration */

Var_List	: T_ID 
				{ 
					$$ = ASTCreateNode(A_VARDEC);
					$$->name = $1;
				}
			| T_ID '[' T_NUM ']' 
				{
					$$ = ASTCreateNode(A_VARDEC);
					$$->name = $1;
					$$->value = $3;
				}
			| T_ID ',' Var_List 
				{
					$$ = ASTCreateNode(A_VARDEC);
					$$->name = $1;
					$$->s1 = $3; //sets next travel path to the Var_List
				}
			| T_ID '[' T_NUM ']' ',' Var_List
				{
					$$ = ASTCreateNode(A_VARDEC);
					$$->name = $1;
					$$->s1 = $6; //sets next travel path to the Var_List
					$$->value = $3;
				}
			;       /* end Var_List */

Type_Specifier  : T_INT { $$ = A_INTTYPE; }
                | T_VOID { $$ = A_VOIDTYPE; }
                | T_BOOLEAN {$$ = A_BOOLEANTYPE; }
                ;       /* end Type_Specifier */

Fun_Declaration : Type_Specifier T_ID '(' Params ')' Compound_Stmt
                    { 
                        $$ = ASTCreateNode(A_FUNDEC); 
                        $$->name = $2;
                        $$->datatype = $1;
                        $$->s1 = $4;
                        $$->s2 = $6;
                    }
                ;       /* end Fun_Declaration */

Params  : T_VOID 
			{ 
				$$ = ASTCreateNode(A_PARAM);
				$$->datatype = A_VOIDTYPE;
			}
        | Param_List 
			{ 
				$$ = $1;
			}
        ;       /* end Params */

Param_List  : Param 
				{	
					$$ = ASTCreateNode(A_PARAM_LIST);
					$$->s1 = $1;
				}
            | Param ',' Param_List 
				{ 
					$$ = ASTCreateNode(A_PARAM_LIST);
					$$->s1 = $1;
					$$->s2 = $3; 
				}
            ;   /* end Param_List */

Param   : Type_Specifier T_ID 
            { 
				$$ = ASTCreateNode(A_PARAM);
				$$->datatype = $1;
				$$->name = $2;
			}
        | Type_Specifier T_ID '[' ']'
            { 
				$$ = ASTCreateNode(A_PARAM);
				$$->datatype = $1;
				$$->name = $2;
				$$->s1 = $$;
			}
        ;       /* end Param */

Compound_Stmt   : T_BEGIN Local_Declarations Statement_List T_END
					{ 
						$$ = ASTCreateNode(A_COMPOUND); 
						$$->s1 = $2;
						$$->s2 = $3;
					}
                ;       /* end Compound_Stmt */

Local_Declarations      : Var_Declaration Local_Declarations
							{
								$$ = $1;
								$$->s2 = $2;
							}
                        | /*empty*/
                            { $$ = NULL; }
                        ;       /* end Local_Declarations */

Statement_List  : Statement Statement_List
					{
						$$ = ASTCreateNode(A_STMT_LIST);
						$$->s1 = $1;
						$$->s2 = $2;
					}
                | /*empty*/
					{
						$$ = NULL;
					}
                ;       /* end Statement_List */

Statement       : Expression_Stmt { $$ = $1; }
                | Compound_Stmt { $$ = $1; }
                | Selection_Stmt { $$ = $1; } 
                | Iteration_Stmt { $$ = $1; }
                | Assignment_Stmt { $$ = $1; }
                | Return_Stmt { $$ = $1; }
                | Read_Stmt { $$ = $1; } 
                | Write_Stmt { $$ = $1; }
                ;       /* end Statement */

Expression_Stmt : Expression ';'
					{
						$$ = $1;
					}
                | ';' { $$ = NULL; }
                ;       /* end Expression_Stmt */

Selection_Stmt  : T_IF Expression T_THEN Statement T_ELSE Statement T_ENDIF 
					{
						$$ = ASTCreateNode(A_IFSTMT);
						$$->s1 = $2;
						$$->s2 = ASTCreateNode(A_IF_BODY);
						$$->s2->s1 = $4;
						$$->s2->s2 = $6;
					}
                | T_IF Expression T_THEN Statement T_ENDIF
					{
						$$ = ASTCreateNode(A_IFSTMT);
						$$->s1 = $2;
						$$->s2 = ASTCreateNode(A_IF_BODY);
						$$->s2->s1 = $4;
					}
                ;       /* end Selection_Stmt */

Iteration_Stmt  : T_WHILE Expression T_DO Statement
					{
						$$ = ASTCreateNode(A_ITERATION);
						$$->s1 = $2;
						$$->s2 = $4;
					}
                ;       /* end Iteration_Stmt */

Return_Stmt : T_RETURN Expression ';'
				{
					$$ = ASTCreateNode(A_RETURN);
					$$->s1 = $2;
				}
            | T_RETURN ';'
				{
					$$ = ASTCreateNode(A_RETURN);
				}
            ;   /* end Return_Stmt */

Read_Stmt   : T_READ Var ';'
				{
					$$ = ASTCreateNode(A_READ);
					$$->s1 = $2;
				}
            ;   /* end Read_Stmt */

Write_Stmt  : T_WRITE Expression ';'
				{
					$$ = ASTCreateNode(A_WRITE);
                    $$->s1 = $2;
				}
            | T_WRITE T_STRING ';'
                {
                    $$ = ASTCreateNode(A_WRITE);
                    $$->name = $2;
                }
            ;   /* end Write_Stmt */

Assignment_Stmt : Var '=' Simple_Expression ';'
					{
						$$ = ASTCreateNode(A_ASSIGN);
						$$->s1 = $1;
						$$->s2 = $3;
					}
                ;       /* end Assignment_Stmt */

Expression  : Simple_Expression { $$ = $1; }
            ;   /* end Expression */

Var : T_ID  
        { 
			$$ = ASTCreateNode(A_VAR);
			$$->name = $1; 
		}
    | T_ID '[' Expression ']'
        { 
			$$ = ASTCreateNode(A_VAR);
			$$->name = $1;
			$$->s1 = $3;
		}
    ;   /* end Var */

Simple_Expression   : Simple_Expression Rel_Op Additive_Expression
						{
							$$ = ASTCreateNode(A_EXPR);
							$$->s1 = $1;
							$$->s2 = $3;
							$$->operator = $2;
						}
                    | Additive_Expression { $$ = $1; }
                    ;   /* end Simple_Expression */

Rel_Op	: T_LE { $$ = A_LE; }
    	| T_LT { $$ = A_LT; }
        | T_GT { $$ = A_GT; }
        | T_GE { $$ = A_GE; }
        | T_EQ { $$ = A_EQ; }
        | T_NE { $$ = A_NE; }
        ;       /* end Rel_Op */

Additive_Expression : Additive_Expression Add_Op Term
						{
							$$ = ASTCreateNode(A_EXPR);
							$$->s1 = $1;
							$$->s2 = $3;
							$$->operator = $2;
						}
                    | Term { $$ = $1; }
                    ;   /* end Additive_Expression */

Add_Op  : T_PLUS { $$ = A_PLUS; }
        | T_MINUS { $$ = A_MINUS; }
        ;       /* end Add_Op */

Term    : Term Mult_Op Factor
			{
				$$ = ASTCreateNode(A_EXPR);
				$$->s1 = $1;
				$$->s2 = $3;
				$$->operator = $2;
			}
        | Factor { $$ = $1; }
        ;       /* end Term */

Mult_Op : T_MULT { $$ = A_TIMES; }
        | T_DIVIDE { $$ = A_DIVIDE; }
        | T_AND { $$ = A_AND; }
        | T_OR { $$ = A_OR; }
        ;       /* end Mult_Op */

Factor  : '(' Expression ')'
			{ $$ = $2; }
        | T_NUM
			{
				$$ = ASTCreateNode(A_NUM);
				$$->value = $1;
			}
        | Var 
			{
				$$ = $1;
			}
        | Call
			{
				$$ = $1;
			}
        | T_TRUE
			{
				$$ = ASTCreateNode(A_TRUE);
			}
        | T_FALSE
			{
				$$ = ASTCreateNode(A_FALSE);
			}
        | T_NOT Factor
			{
				$$ = ASTCreateNode(A_NOT);
				$$->s1 = $2;
			}
        ;      /* end Factor */ 

Call    : T_ID '(' Args ')'
            { 
				$$ = ASTCreateNode(A_CALL);
				$$->name = $1;
				$$->s1 = $3;
			}
        ;       /* end Call */

Args    : Arg_List 
			{
				$$ = $1;
			}
        | /* empty */ 
			{ $$ = NULL; }
        ;       /* end Args */

Arg_List    : Expression 
				{ 
					$$ = ASTCreateNode(A_ARGS);
					$$->s1 = $1;
				}
            | Expression ',' Arg_List
				{ 
					$$ = ASTCreateNode(A_ARGS);
					$$->s1 = $1;
					$$->s2 = $3; 
				}
            ;   /* end Arg_List */

%%      /* end of rules, start of program */

int main()
{ yyparse();
        ASTprint(0, program);
}
                                                   