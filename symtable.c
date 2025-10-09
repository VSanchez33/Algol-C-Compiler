#include "symtable.h"
#include <stdio.h>
/* #include<conio.h> */
//#include <malloc.h>
#include <string.h>
#include <stdlib.h>

int size = 0; // global variable used to keep track of the size of the list 

//void main() 
//{
//} /* end of main */

int FetchAddress (char * symbol)
{
    struct SymbTab * p;
    p = Search(symbol);
    if (p != NULL)
    {
        return p->addr;
    }
    else
    {
        //BARF
    }
}

void Insert(char* sym, int address) // recieves symbol name and address and adds it to the table
{
    struct SymbTab *p; //creates a new node to be added to the list
    p = malloc(sizeof(struct SymbTab));
    //adds the data to the new node 
    p->symbol = strdup(sym);
    p->addr = address;
    p->next = NULL;
    if (size == 0) // if the list is empty, makes the new node the first and last of the list
    {
        first = p;
        last = p;
    }
    else // adds the new node to the end of the list 
    {
        last->next = p;
        last = p;
    }
    Display();
    size++; // increases the size counter for the list 
    printf("\n\tLabel inserted\n");
} // end of insert

void Display() //displays all the sybols in the table 
{
    int i;
    struct SymbTab *p;
    p = first;
    printf("\n\tSYMBOL\t\tADDRESS\n");
    for (i = 0; i < size; i++) // iterates through the list and prints the symbol name and address of each symbol
    {
        printf("\t%s\t\t%d\n", p->symbol, p->addr);
        p = p->next;
    }
} // end of display

struct SymbTab * Search(char *s) // searches the list to find a given symbol in the list
{
    int i, flag = 0;
    struct SymbTab *p;
    p = first;
    for (i = 0; i < size; i++) // iterates through the list to look for the symbol
    {
        if (strcmp(p->symbol, s) == 0)
        {
            flag = 1;
            return p; // returns the symbol pointer now 
        }
        p = p->next;
    }
    return 0; // returns NULL now if not in list
} // end of search

void Delete(char *s) //deletes a given symbol from the table 
{
    struct SymbTab *p, *q;
    p = first;
    if (strcmp(first->symbol, s) == 0) // checks if the current node is the correct one and moves on to the next one if not
        first = first->next;
    else if (strcmp(last->symbol, s) == 0)
    {
        q = p->next;
        while (strcmp(q->symbol, s) != 0)
        {
            p = p->next;
            q = q->next;
        }
        p->next = NULL;
        last = p;
    }
    else // removes the node from the list if it is the correct symbol
    {
        q = p->next;
        while (strcmp(q->symbol, s) != 0)
        {
            p = p->next;
            q = q->next;
        }
        p->next = q->next;
    }
    size--; //decreases the size counter of the list 
    printf("\n\tAfter Deletion:\n");
    Display();
} // end of delete
