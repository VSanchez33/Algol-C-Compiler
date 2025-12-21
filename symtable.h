/*  Completely new symtable structure
    From Dr. Shaun Cooper
    
    Symbol Table --linked list headers
    Used for Compilers class

Modified Spring 2015 to allow for name to pointed to by symtable, instead of
copied, since the name is copied
into the heap

Modified to have levels. A level 0 means global variable, other levels means
in range of the function. 

We start out our offsets at 0 (from stack pointer) for level 1,,,when we enter a
functional declaration.

We increment offset each time we insert a new variable. A variable is
considered to be valid if it is found in the symbol table at our level or 
lesser level. If at 0, then it is global.

We return a pointer to the symbol table when a variable matches our creteria.

We add a routine to remove variables at our level and above.
*/

#ifndef _SYMTAB
#define _SYMTAB
#include "ast.h"

enum SYMBOL_SUBTYPE
{
    SYM_SCALAR,
    SYM_FUNCTION,
    SYM_FUNCTION_PROTO,
    SYM_FUNCTION_PRE,
    SYM_ARRAY
    // missing for array as parameter
};

void Display();
int Delete(int level);
struct SymbTab
{
    char *name;
    int offset;                   /* from activation record boundary */
    int mysize;                   /* number of words this item is 1 or more */
    int level;                    /* the level where we found the variable */
    enum DataTypes Declared_Type; /* the type of the symbol */
    enum SYMBOL_SUBTYPE SubType;  /* the subtype of the symbol */
    ASTnode *fparms;              /* pointer to parameters of the function in the AST */
    struct SymbTab *next;
};

struct SymbTab *Insert(char *name, enum DataTypes my_assigned_type, enum SYMBOL_SUBTYPE sub_type, int level, int mysize, int offset);
struct SymbTab *Search(char name[], int level, int recur);
static struct SymbTab *first = NULL; /* global pointers into the symbol table */
char *CreateTemp();
char *CreateLabel();
int Has_Proto();

#endif