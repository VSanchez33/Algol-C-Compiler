%{

/* 
Vincent Sanchez
August 27,2025
Lab 22
Added a multiplication function to expr
fixed the unary minus to not include first expr
Inputs are the expressions given by the user and the outputs are the solution to the answer
This file is what calculates the expression given from the user
*/

/*
 *                      **** CALC ****
 *
 * This routine will function like a desk calculator
 * There are 26 integer registers, named 'a' thru 'z'
 *
 */

/* This calculator depends on a LEX description which outputs either VARIABLE or INTEGER.
The return type via yylval is integer 

   When we need to make yylval more complicated, we need to define a pointer type for yylval 
   and to instruct YACC to use a new type so that we can pass back better values
 
   The registers are based on 0, so we substract 'a' from each single letter we get.

   based on context, we have YACC do the correct memmory look up or the storage depending
   on position

   Shaun Cooper
    January 2015

   problems  fix unary minus, fix parenthesis, add multiplication
   problems  make it so that verbose is on and off with an input argument instead of compiled in
*/


        /* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "symtable.h"

extern int yylex();
extern int linecount;

int regs[26];
int base, debugsw;

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
}

%token <value> T_NUM
%token <string> T_ID T_STRING
%token T_INT T_VOID T_BOOLEAN T_RETURN T_READ T_WRITE T_WHILE T_PLUS
%token T_MINUS T_OR T_AND T_FALSE T_TRUE T_IF T_THEN T_ELSE T_ENDIF 
%token T_DO T_MULT T_DIVIDE T_BEGIN T_END T_NOT T_LE T_LT T_GT T_GE T_EQ T_NE


%left T_OR 
%left T_AND
%left T_EQ T_NE T_LT T_LE T_GT T_GE
%left T_PLUS T_MINUS
%left T_MULT T_DIVIDE '%'
%left UMINUS

%%      /* end specs, begin rules */

Program : Declaration_List
        ;

Declaration_List    : Declaration
                    | Declaration Declaration_List
                    ;

Declaration     : Var_Declaration 
                | Fun_Declaration
                ;

Var_Declaration : Type_Specifier Var_List ';'
                ;

Var_List        : T_ID 
                    { printf("found ID in VAR_LIST -> T_ID %s on line %d\n", $1, linecount);}
                | T_ID '[' T_NUM ']' 
                    { printf("found ID in VAR_LIST -> T_ID %s on line %d\n", $1, linecount);}
                | T_ID ',' Var_List 
                    { printf("found ID in VAR_LIST -> T_ID %s on line %d\n", $1, linecount);}
                | T_ID '[' T_NUM ']' ',' Var_List
                    { printf("found ID in VAR_LIST -> T_ID %s on line %d\n", $1, linecount);}
                ;

Type_Specifier  : T_INT 
                | T_VOID
                | T_BOOLEAN
                ;

Fun_Declaration : Type_Specifier T_ID '(' Params ')' Compound_Stmt
                    { printf("found ID in FUN_DECLARATION -> T_ID %s on line %d\n", $2, linecount);}
                ;

Params  : T_VOID 
        | Param_List
        ;

Param_List  : Param
            | Param ',' Param_List
            ;

Param   : Type_Specifier T_ID 
            { printf("found ID in PARAM -> T_ID %s on line %d\n", $2, linecount);}
        | Type_Specifier T_ID '[' ']'
            { printf("found ID in PARAM -> T_ID %s on line %d\n", $2, linecount);}
        ;

Compound_Stmt   : T_BEGIN Local_Declarations Statement_List T_END
                ;

Local_Declarations      : Var_Declaration Local_Declarations
                        | /*empty*/
                        ;

Statement_List  : Statement Statement_List
                | /*empty*/
                ;

Statement       : Expression_Stmt
                | Compound_Stmt
                | Selection_Stmt
                | Iteration_Stmt
                | Assignment_Stmt
                | Return_Stmt
                | Read_Stmt
                | Write_Stmt
                ;

Expression_Stmt : Expression ';'
                | ';'
                ;

Selection_Stmt  : T_IF Expression T_THEN Statement T_ELSE Statement T_ENDIF
                | T_IF Expression T_THEN Statement T_ENDIF
                ;

Iteration_Stmt  : T_WHILE Expression T_DO Statement
                ;

Return_Stmt : T_RETURN Expression ';'
            | T_RETURN ';'
            ;

Read_Stmt   : T_READ Var ';'
            ;

Write_Stmt  : T_WRITE Expression ';'
            | T_WRITE T_STRING ';'
                    {printf("found a string in WRITE with value %s on line %d\n", $2, linecount);}
            ;

Assignment_Stmt : Var '=' Simple_Expression ';'
                ;

Expression  : Simple_Expression
            ;

Var : T_ID  
        { printf("found ID in VAR -> T_ID %s on line %d\n", $1, linecount);}
    | T_ID '[' Expression ']'
        { printf("found ID in VAR -> T_ID %s on line %d\n", $1, linecount);}
    ;

Simple_Expression   : Simple_Expression Relop Additive_Expression
                    | Additive_Expression
                    ;

Relop   : T_LE 
        | T_LT
        | T_GT 
        | T_GE 
        | T_EQ
        | T_NE 
        ;

Additive_Expression : Additive_Expression Add_Op Term
                    | Term
                    ;

Add_Op  : T_PLUS
        | T_MINUS
        ;

Term    : Term Mult_Op Factor
        | Factor
        ;

Mult_Op : T_MULT
        | T_DIVIDE
        | T_AND
        | T_OR
        ;

Factor  : '(' Expression ')'
        | T_NUM
        | Var 
        | Call
        | T_TRUE
        | T_FALSE
        | T_NOT Factor
        ;

Call    : T_ID '(' Args ')'
            { printf("found ID in CALL -> T_ID %s on line %d\n", $1, linecount);}
        ;

Args    : Arg_List
        | /* empty */
        ;

Arg_List    : Expression
            | Expression ',' Arg_List
            ;

%%      /* end of rules, start of program */

int main()
{ yyparse();
}
                                                   