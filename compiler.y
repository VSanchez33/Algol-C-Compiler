%{

        /* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "ast.h"
#include "symtable.h"

extern int yylex();
extern int linecount;

int level = 0; // how many compound statements deep we are
int offset = 0; // how many words have we seen at global or inside func 
int gOffset; // holder for global offset when we enter and exit func definition 
int maxOffset; // total number of words a function needs


void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s on line number %d\n", s, linecount);
}

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
							//p->datatype = $1;
							p->symbol->Declared_Type = $1;
							p = p->s1;
						} // end of while
					}
                ;       /* end Var_Declaration */

Var_List	: T_ID 
				{ 
					if (Search($1, level, 0) == NULL) { //symbol not there
						$$ = ASTCreateNode(A_VARDEC);
						$$->name = $1;
						$$->symbol = Insert($1, A_UNKNOWN, SYM_SCALAR, level, 1, offset);
						offset += 1;
					} // end if 
					else {
						yyerror($1);
						yyerror("already defined");
						exit(1);
					} // end else
				}
			| T_ID '[' T_NUM ']' 
				{
					if (Search($1, level, 0) == NULL) { //symbol not there
						$$ = ASTCreateNode(A_VARDEC);
						$$->name = $1;
						$$->value = $3;
						$$->symbol = Insert($1, A_UNKNOWN, SYM_ARRAY, level, $3, offset);
						offset += $3;
					} // end if 
					else {
						yyerror($1);
						yyerror("already defined");
						exit(1);
					} // end else
				}
			| T_ID ',' Var_List 
				{
					if (Search($1, level, 0) == NULL) { //symbol not there
						$$ = ASTCreateNode(A_VARDEC);
						$$->name = $1;
						$$->symbol = Insert($1, A_UNKNOWN, SYM_SCALAR, level, 1, offset);
						offset += 1;
						$$->s1 = $3; //sets next travel path to the Var_List
					} // end if
					else {
						yyerror($1);
						yyerror("already defined");
						exit(1);
					} // end else
				}
			| T_ID '[' T_NUM ']' ',' Var_List
				{
					if (Search($1, level, 0) == NULL) { //symbol not there
						$$ = ASTCreateNode(A_VARDEC);
						$$->name = $1;
						$$->value = $3;
						$$->symbol = Insert($1, A_UNKNOWN, SYM_ARRAY, level, $3, offset);
						offset += $3;
						$$->s1 = $6;
					} // end if 
					else {
						yyerror($1);
						yyerror("already defined");
						exit(1);
					} // end else
				}
			;       /* end Var_List */

Type_Specifier  : T_INT { $$ = A_INTTYPE; }
                | T_VOID { $$ = A_VOIDTYPE; }
                | T_BOOLEAN {$$ = A_BOOLEANTYPE; }
                ;       /* end Type_Specifier */

Fun_Declaration : Type_Specifier T_ID '(' 
					{ //checks if function name is know, if it is BARF. if not put it in symbol table
						if (Search($2, level, 0) == NULL) {
							Insert($2, $1, SYM_FUNCTION, level, 0, 0);
							gOffset = offset;
							offset = 2; // we need two for SP and RA 
							maxOffset = offset;
						} // end if
						else {
							yyerror($2);
							yyerror("Cannot creat function, name is in use");
							exit(1);
						} // end else
					}
				Params ')' 
					{ //update symtable with parameters
						Search($2, level, 0)->fparms = $5;
					}
				Compound_Stmt
                    { 
                        $$ = ASTCreateNode(A_FUNDEC); 
                        $$->name = $2;
                        $$->datatype = $1;
                        $$->s1 = $5;
                        $$->s2 = $8;
						$$->symbol = Search($2, level, 0);
						$$->symbol->offset = maxOffset;
						offset = gOffset;
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

				if (Search($2, 1, 0) == NULL) { // need to insert into symbol table
					$$->symbol = Insert($2, $1, SYM_SCALAR, level+1, 1, offset);
					offset += 1;
					$$->datatype = $$->symbol->Declared_Type;
				}
				else {
					yyerror($2);
					yyerror("Parameter name already used");
					exit(1);
				}
			}
        | Type_Specifier T_ID '[' ']'
            { 
				$$ = ASTCreateNode(A_PARAM);
				$$->datatype = $1;
				$$->name = $2;
				$$->value = -1;

				if (Search($2, 1, 0) == NULL) { // need to insert into symbol table
					$$->symbol = Insert($2, $1, SYM_ARRAY, level+1, 1, offset);
					offset += 1;
					$$->datatype = $$->symbol->Declared_Type;
				}
				else {
					yyerror($2);
					yyerror("Parameter name already used");
					exit(1);
				}
			}
        ;       /* end Param */

Compound_Stmt   : T_BEGIN 
					{
						level++;		
					}
				Local_Declarations Statement_List T_END
					{ 
						$$ = ASTCreateNode(A_COMPOUND); 
						$$->s1 = $3;
						$$->s2 = $4;
						if (offset > maxOffset)
							maxOffset = offset;
						Display();
						offset = offset - Delete(level);
						level--;
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
						if ($1->datatype != $3->datatype){
							yyerror("Type mismatch on expression");
							exit(1);
						} // end if
						$$ = ASTCreateNode(A_ASSIGN);
						$$->s1 = $1;
						$$->s2 = $3;
						$$->datatype = $1->datatype;
						$$->name = CreateTemp();
						$$->symbol = Insert($$->name, $1->datatype, SYM_SCALAR, level, 1, offset);
						offset += 1;

					}
                ;       /* end Assignment_Stmt */

Expression  : Simple_Expression { $$ = $1; }
            ;   /* end Expression */

Var : T_ID  
        { 
			struct SymbTab *p;
			p = Search($1, level, 1);

			if (p == NULL){
				yyerror($1);
				yyerror("Variable used but not defined");
				exit(1);
			} // end if

			if (p->SubType != SYM_SCALAR) {
				yyerror($1);
				yyerror("Variable is wrong subtype");
				exit(1);
			}

			$$ = ASTCreateNode(A_VAR);
			$$->name = $1; 
			$$->symbol = p;
			$$->datatype = p->Declared_Type;
		}
    | T_ID '[' Expression ']'
        { 
			struct SymbTab *p;
			p = Search($1, level, 1);

			if (p == NULL){
				yyerror($1);
				yyerror("Variable used but not defined");
				exit(1);
			} // end if

			if (p->SubType != SYM_ARRAY) {
				yyerror($1);
				yyerror("Variable is wrong subtype");
				exit(1);
			}

			if ($3->datatype != A_INTTYPE){
				yyerror("Array index must be int");
				exit(1);
			}

			$$ = ASTCreateNode(A_VAR);
			$$->name = $1; 
			$$->s1 = $3;
			$$->symbol = p;
			$$->datatype = p->Declared_Type;
		}
    ;   /* end Var */

Simple_Expression   : Simple_Expression Rel_Op Additive_Expression
						{
							if($1->datatype != $3->datatype){
								yyerror("Type mismatch on expression");
								exit(1);
							} // end if
							$$ = ASTCreateNode(A_EXPR);
							$$->s1 = $1;
							$$->s2 = $3;
							$$->operator = $2;
							$$->datatype = A_BOOLEANTYPE;
							$$->name = CreateTemp();
							$$->symbol = Insert($$->name, $1->datatype, SYM_SCALAR, level, 1, offset);
							offset += 1;
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
							if($1->datatype != $3->datatype){
								yyerror("Type mismatch on expression");
								exit(1);
							} // end if
							$$ = ASTCreateNode(A_EXPR);
							$$->s1 = $1;
							$$->s2 = $3;
							$$->operator = $2;
							$$->datatype = $1->datatype;
							$$->name = CreateTemp();
							$$->symbol = Insert($$->name, $1->datatype, SYM_SCALAR, level, 1, offset);
							offset += 1;
						}
                    | Term { $$ = $1; }
                    ;   /* end Additive_Expression */

Add_Op  : T_PLUS { $$ = A_PLUS; }
        | T_MINUS { $$ = A_MINUS; }
        ;       /* end Add_Op */

Term    : Term Mult_Op Factor
			{
				if($1->datatype != $3->datatype){
					yyerror("Type mismatch on expression");
					exit(1);
				}
				$$ = ASTCreateNode(A_EXPR);
				$$->s1 = $1;
				$$->s2 = $3;
				$$->operator = $2;
				$$->datatype = $1->datatype;
				$$->name = CreateTemp();
				$$->symbol = Insert($$->name, $1->datatype, SYM_SCALAR, level, 1, offset);
				offset += 1;
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
				$$->datatype = A_INTTYPE;
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
				$$->datatype = A_BOOLEANTYPE;
			}
        | T_FALSE
			{
				$$ = ASTCreateNode(A_FALSE);
				$$->datatype = A_BOOLEANTYPE;
			}
        | T_NOT Factor
			{
				if ($2->datatype != A_BOOLEANTYPE){
					yyerror("Not operator expects boolean");
					exit(1);
				}
				$$ = ASTCreateNode(A_NOT);
				$$->s1 = $2;
				$$->datatype = A_BOOLEANTYPE;
			}
        ;      /* end Factor */ 

Call    : T_ID '(' Args ')'
            { // check if it is in symtable
				struct SymbTab *p;
				p = Search($1, 0, 0);

				if (p == NULL){
					yyerror($1);
					yyerror("Function name not defined");
					exit(1);
				} // end if

				if (p->SubType != SYM_FUNCTION){
					yyerror($1);
					yyerror("Function name is not defined as function");
					exit(1);
				} // end if
				
				if (check_params($3, p->fparms) == 0){
					// they do not match
					yyerror($1);
					yyerror("paramater usage is incorrect");
					exit(1);
				} // end if
				
				$$ = ASTCreateNode(A_CALL);
				$$->name = $1;
				$$->s1 = $3;
				$$->symbol = p;
				$$->datatype = $$->symbol->Declared_Type;
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
					$$->datatype = $1->datatype;
					$$->name = CreateTemp();
					$$->symbol = Insert($$->name, $$->datatype, SYM_SCALAR, level, 1, offset);
					offset++;
				}
            | Expression ',' Arg_List
				{ 
					$$ = ASTCreateNode(A_ARGS);
					$$->s1 = $1;
					$$->s2 = $3; 
					$$->datatype = $1->datatype;
					$$->name = CreateTemp();
					$$->symbol = Insert($$->name, $$->datatype, SYM_SCALAR, level, 1, offset);
					offset++;
				}
            ;   /* end Arg_List */

%%      /* end of rules, start of program */

int main()
{ 
	yyparse();
	Display();	
    ASTprint(0, program);
}
                                                   