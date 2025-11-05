/* 
Abstract syntax tree code
This code is used to define an AST node,
routine for printing out the AST
defining an enumerated nodetype so we can figure out what we need to
do with this. The ENUM is basically going to be every non-terminal
and terminal in our language
*/

#include <stdio.h>
//#include <malloc.h>
#include <stdlib.h>
#include "ast.h"
#include "symtable.h"

/* uses malloc to create an ASTnode and passes back the heap address of the newley
created node */
// PRE: handed a node type
// POST: if you have a debug it will print it, otherwise mallocs and updates the node type 
ASTnode *ASTCreateNode(enum ASTtype mytype)
{
    ASTnode *p;
    if (mydebug)
        fprintf(stderr, "Creating AST Node \n");
    p = (ASTnode *)malloc(sizeof(ASTnode));
    p->nodetype = mytype;
    p->s1 = NULL;
    p->s2 = NULL;
    p->value = 0;
    return (p);
}

/* Helper function to print tabbing */
// PRE: Given a positive number
// POST: print the given number of spaces
void PT(int howmany)
{
    // MISSING
    while (howmany != 0){
        printf(" ");
        howmany--;
    }
}

// PRE: a Data Type
// POST: a character string for that type to print nicely -- caller does final output 
char *DataTypeToString(enum DataTypes mydatatype)
{
    switch (mydatatype)
    {
    case A_VOIDTYPE:
        return ("void");
        break;

    case A_INTTYPE:
        return ("int");
        break;

    case A_BOOLEANTYPE:
        return ("boolean");
        break;

    default:
        printf("Unknown type in DataTypeToString\n");
        exit(1);
    } // of switch
} // of DataTypeToString()

// PRE: ???
// POST: ??
/* Print out the abstract syntax tree */
void ASTprint(int level, ASTnode *p)
{
    int i;
    if (p == NULL)
        return;
    // when here p is not NULL
    switch (p->nodetype)
    {
    case A_VARDEC:
        PT(level);
        printf("Variable: ");
        printf("%s ", DataTypeToString(p->datatype));
        printf("%s", p->name);
        if (p->value > 0)
            printf("[%d]", p->value);
        printf(" with offset %d on level %d \n", p->symbol->offset, p->symbol->level);
        if (p->s1 != NULL)
            ASTprint(level, p->s1);
        break;

    case A_FUNDEC:
        PT(level);
        printf("Function: %s %s", DataTypeToString(p->datatype), p->name);
        printf(" with size %d\n", p->symbol->offset);
        PT(level+1);
        printf("(\n");
        ASTprint(level+2, p->s1); //parameters
        printf("\n");
        PT(level+1);
        printf(")\n");
        ASTprint(level+1, p->s2); //compound statement
        break;

    case A_DEC_LIST: 
        ASTprint(level, p->s1); //declaration
        ASTprint(level, p->s2); //dec list
        break;

    case A_STMT_LIST: 
        ASTprint(level, p->s1); //statement
        ASTprint(level, p->s2); //statement list
        break;

    case A_COMPOUND:
        PT(level);
        printf("BEGIN\n");
        ASTprint(level+1, p->s1); //local variables
        ASTprint(level+1, p->s2); //statement list 
        PT(level);
        printf("END\n");
        break;

    case A_WRITE:
        PT(level);
        printf("Write:\n");
        if (p->name != NULL){ //it is a string
            PT(level+1);
            printf("String: %s \n", p->name);
        }
        else
        {
            ASTprint(level+1, p->s1); //it is not a string
        }
        break;

    case A_EXPR:
        PT(level);
        printf("Expression: ");
        switch (p->operator) 
        {
        case A_PLUS:
            printf("+\n");
            break;

        case A_MINUS:
            printf("-\n");
            break;

        case A_TIMES:
            printf("*\n");
            break;

        case A_DIVIDE:
            printf("/\n");
            break;

        case A_AND:
            printf("and\n");
            break;

        case A_OR:
            printf("or\n");
            break;

        case A_LE:
            printf("<=\n");
            break;

        case A_LT:
            printf("<\n");
            break;

        case A_GT:
            printf(">\n");
            break;

        case A_GE:
            printf(">=\n");
            break;

        case A_EQ:
            printf("==\n");
            break;

        case A_NE:
            printf("!=\n");
            break;

        default:
            printf("Unknown operator in A_EXPR ASTprint\n");
            printf("Exiting expression in ASTprint immediately\n");
            exit(1);
        } //end switch (p->operator)
        ASTprint(level+1, p->s1);
        ASTprint(level+1, p->s2);
        break;

    case A_NUM: // is a leaf
        PT(level);
        printf("Num value: %d\n", p->value);
        break;

    case A_PARAM_LIST:
        ASTprint(level+1, p->s1);
        if(p->s2 != NULL)
            printf("\n");
        ASTprint(level, p->s2);
        break;

    case A_PARAM:
        PT(level);
        printf("Parameter:\n");
        PT(level+1);
        if (p->datatype == A_VOIDTYPE)
            printf("void");
        else {
            if(p->value != -1)
                printf("%s %s", DataTypeToString(p->datatype), p->name);
            else
                printf("%s %s[]", DataTypeToString(p->datatype), p->name);
        }
        if (p->symbol != NULL)
            printf(" with offset %d on level %d", p->symbol->offset, p->symbol->level);
        break;

    case A_ASSIGN:
        PT(level);
        printf("Assignment:\n");
        PT(level+1);
        printf("Left hand side:\n");
        ASTprint(level+2, p->s1);
        PT(level+1);
        printf("Right hand side:\n");
        ASTprint(level+2, p->s2);
        break;

    case A_VAR:
        PT(level);
        printf("Var name: %s\n", p->name);
        if (p->s1 != NULL) {
            PT(level+1);
            printf("[\n");
            ASTprint(level+2, p->s1);
            PT(level+1);
            printf("]\n");
        }
        break;

    case A_IFSTMT:
        PT(level);
        printf("If Statement:\n");
        PT(level+1);
        printf("If Condition:\n");
        ASTprint(level+2, p->s1);
        PT(level+1);
        printf("If Body:\n");
        ASTprint(level+2, p->s2->s1);
        if (p->s2->s2 != NULL){
            PT(level+1);
            printf("Else:\n");
            ASTprint(level+2, p->s2->s2);
        }
        PT(level);
        printf("END IF\n");
        break;

    case A_ITERATION:
        PT(level);
        printf("While:\n");
        PT(level+1);
        printf("Condition: \n");
        ASTprint(level+2, p->s1);
        PT(level+1);
        printf("While body:\n");
        ASTprint(level+2, p->s2);
        break;

    case A_RETURN:
        PT(level);
        printf("Return\n");
        if (p->s1 != NULL)
            ASTprint(level+1, p->s1);
        break;

    case A_READ:
        PT(level);
        printf("Read\n");
        ASTprint(level+1, p->s1);
        break;

    case A_CALL:
        PT(level);
        printf("Call: %s\n", p->name);
        if (p->s1 != NULL){
            PT(level+1);
            printf("(\n");
            ASTprint(level+2, p->s1);
            PT(level+1);
            printf(")\n");
        }
        else{
            PT(level+1);
            printf("(\n");
            PT(level+1);
            printf(")\n");
        }
        break;

    case A_ARGS:
        PT(level);
        printf("Call Argument:\n");
        ASTprint(level+1, p->s1);
        ASTprint(level, p->s2);
        break;

    case A_TRUE:
        PT(level+1);
        printf("Boolean with value: 1\n");
        break;

    case A_FALSE:
        PT(level+1);
        printf("Boolean with value: 0\n");
        break;

    case A_NOT:
        PT(level);
        printf("Not:\n");//add rest of operators
        ASTprint(level+1, p->s1);
        break;

    default:
        printf("unknown type in ASTprint\n");
        printf("Exiting ASTprint immediately\n");
        exit(1);
    } // of switch
} // of ASTprint

/* Checks parameters of definition and call to make sure they match */
// PRE: handed two lists that represent formals and actauls
// POST: returns 1 if they are the same length and each element is type consistent
//       returns 0 otherwise
int check_params(ASTnode *actuals, ASTnode *formals){
    if (actuals == NULL && formals == NULL) return 1;
    if (actuals == NULL || formals == NULL) return 0;
    if (actuals->datatype != formals->datatype) return 0;
    if ((actuals->s1->nodetype == A_VAR) && (actuals->s1->symbol->SubType == SYM_ARRAY) && (actuals->s1->s1 == NULL))
        return 0;
    return (check_params(actuals->s2, formals->s2));
}

/* dummy main program so I can compile for syntax error independently
main()
{
}
*/