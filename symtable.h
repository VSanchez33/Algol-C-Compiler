#ifndef SYMTABLE_H
#define SYMTABLE_H

int size; // global variable used to keep track of the size of the list

int FetchAddress (char * symbol);
void Insert(char* sym, int address); //recieves a symbol and address and inserts it in the symbol table
void Display(); // displays each symbol in the table
void Delete(char *s); //removes a given symbol if in the list
struct SymbTab * Search(char *s); //searches for a symbol, if in table displays 1, otherwise displays 0

struct SymbTab //the actual nodes in the linked list that include the symbol name and address
{
    char * symbol;
    int addr;
    struct SymbTab *next;
};
struct SymbTab *first, *last; // the first and last node in the list

#endif //end of symtable.h