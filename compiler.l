/* 
Vincent Sanchez
August 27,2025
Lab 22
Added the parenthesis to the list of expressions
This file is used to capture all of the values to send to yacc as well as act as the debugger
*/

/*                 Small LEX routine which returns two formal tokens (INTEGER and VARIABLE)
                   along with single string elements like '+'.
 
                    This LEX definition is the companion to the docalc.y YACC routine which
                   is a simple calculator

                    Shaun Cooper
                    January 2015
*/
%{

int mydebug=0;
int linecount = 1;
#include "y.tab.h"
%}


%%

int     { return (T_INT);}
\".*\"  { yylval.string = strdup(yytext); return (T_STRING);}
begin   { return (T_BEGIN);}
end     { return (T_END);}
void    { return (T_VOID);}
boolean { return (T_BOOLEAN);}
return  { return (T_RETURN);}
read    { return (T_READ);}
write   { return (T_WRITE);}
not     { return (T_NOT);}
true    { return (T_TRUE);}
false   { return (T_FALSE);}
and     { return (T_AND);}
or      { return (T_OR);}
if      { return (T_IF);}
then    { return (T_THEN);}
else    { return (T_ELSE);}
endif   { return (T_ENDIF);}
while   { return (T_WHILE);}
do      { return (T_DO);}
"<="    { return (T_LE);}
">="    { return (T_GE);}
"!="    { return (T_NE);}
"=="    { return (T_EQ);}
"<"     { return (T_LT);}
">"     { return (T_GT);}
"+"     { return (T_PLUS);}
"-"     { return (T_MINUS);}
"*"     { return (T_MULT);}
"/"     { return (T_DIVIDE);}
"//".*    {linecount++; /* Ignoring comment lines */}


[a-zA-Z][a-zA-Z0-9_]*           {if (mydebug) fprintf(stderr,"Letter found\n");
                       yylval.string=strdup(yytext); return(T_ID);}
[0-9][0-9]*     {if (mydebug) fprintf(stderr,"Digit found\n");
                       yylval.value=atoi((const char *)yytext); return(T_NUM);}
[ \t]           {if (mydebug) fprintf(stderr,"Whitespace found\n");}
[=%();,\[\]]    { if (mydebug) fprintf(stderr,"return a token %c\n",*yytext);
                       return (*yytext);}
\n              { if (mydebug) fprintf(stderr,"cariage return %c\n",*yytext);
                       linecount++;
  }

%%

int yywrap(void)
{ return 1;}

