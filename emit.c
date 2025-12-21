#include <string.h>
#include "emit.h"

// In file prototypes defined in this file and not used otherwise
void emit_ast(ASTnode *p, FILE *fp);
void emit_fundec(ASTnode *p, FILE *fp);
void emit_write(ASTnode *p, FILE *fp);
void emit_expr(ASTnode *p, FILE *fp);
void emit_var(ASTnode *p, FILE *fp);
void emit_call(ASTnode *p, FILE *fp);
void emit_params(ASTnode *p, FILE *fp);
void emit_read(ASTnode *p, FILE *fp);
void emit_assign(ASTnode *p, FILE *fp);
void emit_if(ASTnode *p, FILE *fp);
void emit_while(ASTnode *p, FILE *fp);
void emit_args(ASTnode *p, FILE *fp);

// PRE: PTR to first ASTdode in our tree
// POST: MIPS code directly and through helper functions 
//       prints into the file via fp
void EMIT(ASTnode *p, FILE *fp) {
    emit_header(p, fp);
    emit_ast(p, fp);
} //end of EMIT

// PRE: ASTnode tree
// POST: The header function for our mips with strings and global vars
void emit_header(ASTnode *p, FILE *fp){
    fprintf(fp, "# Compilers MIPS code Fall 2025\n\n\n");

    fprintf(fp, ".data \n\n");
    emit_strings(p, fp);
    fprintf(fp, "\n");

    fprintf(fp, ".align 2 \n\n");
    emit_globals(p, fp);
    fprintf(fp, "\n");

    fprintf(fp, ".text \n\n");
    fprintf(fp, ".globl main \n\n");
} //end of emit_header

// PRE: ASTnode tree
// POST: MIPS code for all global variables
void emit_globals(ASTnode *p, FILE *fp){
    if (p == NULL) return;

    if ((p->nodetype == A_VARDEC) && (p->symbol->level == 0)){
        fprintf(fp, "%s:\t.space\t%d\n", p->name, p->symbol->mysize * WSIZE);
    } //end if 

    emit_globals(p->s1, fp);
    emit_globals(p->s2, fp);
} //end of emit_globals

// PRE: ASTnode subtree
// POST: MIPS code for global variable allocation of strings
void emit_strings(ASTnode *p, FILE *fp){
    if (p == NULL) return;

    if ((p->nodetype == A_WRITE) && (p->name != NULL)){
        p->label = CreateLabel();
        fprintf(fp, "%s:\t.asciiz\t%s\n", p->label, p->name);
    } //end if 

    emit_strings(p->s1, fp);
    emit_strings(p->s2, fp);
} //end of emit_strings

// PRE: Possible label, command, and comment
// POST: formatted output to the file
void emit (FILE *fp, char *label, char *command, char *comment){
    if (strcmp("", comment) == 0)
        if (strcmp("", label) == 0)
            fprintf(fp, "\t%s\t\t\n", command);
        else
            fprintf(fp, "%s:\t%s\t\t\n", label, command);
    else
        if (strcmp("", label) == 0)
            fprintf(fp, "\t%s\t\t# %s\n", command, comment);
        else
            fprintf(fp, "%s:\t%s\t\t# %s\n", label, command, comment);
} //end of emit

// PRE: PTR to ASTnode
// POST: Main way we walk the AST and generate MIPS code
void emit_ast(ASTnode *p, FILE *fp){
    if (p == NULL) return;

    switch (p->nodetype) {
        case A_DEC_LIST:
            emit_ast(p->s1, fp);
            emit_ast(p->s2, fp);
            break;

        case A_VARDEC:
            emit_ast(p->s1, fp);
            emit_ast(p->s2, fp);
            break;    

        case A_FUNDEC:
            emit_fundec(p, fp);
            break; 

        case A_COMPOUND:
            emit_ast(p->s2, fp);
            break;

        case A_STMT_LIST:
            emit_ast(p->s1, fp);
            emit_ast(p->s2, fp);
            break;

        case A_WRITE:
            emit_write(p, fp);
            break;

        case A_READ:
            emit_read(p, fp);
            break;

        case A_VAR:
            emit_var(p, fp);
            break;

        case A_ASSIGN:
            emit_assign(p, fp);
            break;

        case A_IFSTMT:
            emit_if(p, fp);
            break;
        
        case A_ITERATION:
            emit_while(p, fp);
            break;

        case A_EXPR:
            emit_expr(p, fp);
            break;

        case A_NUM:
            emit_expr(p, fp);
            break;

        case A_PARAM:
            emit_params(p, fp);
            break;

        case A_PARAM_LIST:
            emit_ast(p->s1, fp);
            emit_ast(p->s2, fp);
            break;

        case A_CALL:
            emit_call(p, fp);
            break;

        case A_RETURN:
            if(p->s1 != NULL){ //returning an expression;
                emit_expr(p->s1, fp);
            } //end of if

            else{
                emit(fp, "", "li $a0, 0", "return has no specified value set to 0");
            } //end of else

            emit(fp, "", "lw $ra 4($sp)", "restore ra");
            emit(fp, "", "lw $sp ($sp)", "restore sp");
            emit(fp, "", "jr $ra", "return to the caller");
            fprintf(fp, "\n");
            break;

        case A_NOT:
            emit_expr(p, fp);
            break;

        default:
            printf("emit_ast unknown nodetype: %d\n", p->nodetype);
            printf("Exiting\n");
            exit(1);
            break;

    } //end of switch (p->nodetype)
} //end of emit_ast

// PRE: PTE to A_FUNDEC node
// POST: MIPS code for the function using emit_ast as helper
void emit_fundec(ASTnode *p, FILE *fp){
    char s[100];

    emit(fp, p->name, "", "Start of Function");
    sprintf(s, "subu $a0, $sp, %d", p->symbol->offset * WSIZE);
    emit(fp, "", s, "adjust the stack for function");

    emit(fp, "", "sw $sp, ($a0)", "remember old stack pointer");
    emit(fp, "", "sw $ra, 4($a0)", "remember current Return address");
    emit(fp, "", "move $sp, $a0", "adjust the stack pointer");
    fprintf(fp, "\n");

    emit_ast(p->s1, fp);
    emit_ast(p->s2, fp); // calls for Compound Statement

    emit(fp, "", "li $a0, 0", "return has no specified value, set to 0");
    emit(fp, "", "lw $ra, 4($sp)", "restore ra");
    emit(fp, "", "lw $sp, ($sp)", "restore sp");
    fprintf(fp, "\n");
    if (strcmp(p->name, "main") == 0){//in main
        emit(fp, "", "li $v0, 10", "leave main program");
        emit(fp, "", "syscall", "leave everything");
    } //end of if
    else{
        emit(fp, "", "jr $ra", "return to the caller");
    } //end of else
} //end of emit_fundec

// PRE: PTR to a write node
// POST: MIPS code to perform write
void emit_write(ASTnode *p, FILE *fp){
    char s[100];

    if (p->name != NULL){ //it is a string
         emit(fp, "", "li $v0, 4", "print a string");
         sprintf(s, "la $a0, %s", p->label);
         emit(fp, "", s, "print fetch string location");
         emit(fp, "", "syscall", "perform a write string");
         fprintf(fp, "\n");
    } //end of if

    else{ //it is an expression
        emit_expr(p->s1, fp);
        emit(fp, "", "li $v0, 1", "print the number");
        emit(fp, "", "syscall", "system call for print number");
        fprintf(fp, "\n");
    } //end of if
} //end of emit_write

// PRE: pointer to expression tree component
// POST: MIPS code so that $a0 has the value of the expression
void emit_expr(ASTnode *p, FILE *fp){
    char s[100];

    if (p==NULL) return;

    switch (p->nodetype)
    {
    case A_NUM:
        sprintf(s, "li $a0, %d", p->value);
        emit(fp, "", s, "expression is constant");
        return;
        break;
    
    case A_TRUE:
        emit(fp, "", "li $a0, 1", "expr true");
        return;
        break;

    case A_FALSE:
        emit(fp, "", "li $a0, 0", "expr true");
        return;
        break;
    
    case A_VAR:
        emit_var(p, fp);
        emit(fp, "", "lw $a0 ($a0)", "expression is a var, get value");
        return;
        break;

    case A_CALL:
        emit_call(p, fp);
        return;
        break;

    case A_NOT:
        emit_expr(p->s1, fp);
        emit(fp, "", "xori $a0, $a0, 1", "flips bit for not");
        return;
        break;

    case A_EXPR:
        break;

    default:
        printf("emit_expr unknown nodetype: %d\n", p->nodetype);
        printf("Exiting\n");
        exit(1);
        break;
    } //end of switch (p->nodetype)

    emit_expr(p->s1, fp);
    sprintf(s, "sw $a0, %d($sp)", p->symbol->offset * WSIZE);
    emit(fp, "", s, "expression store LHS temporarily");
    emit_expr(p->s2, fp);
    emit(fp, "", "move $a1, $a0", "RHS needs to be a1");

    sprintf(s, "lw $a0, %d($sp)", p->symbol->offset * WSIZE);
    emit(fp, "", s, "expression restore LHS from memory");

    switch(p->operator)
    {
        case A_PLUS:
            emit(fp, "", "add $a0, $a0, $a1", "expr add");
            break;

        case A_MINUS:
            emit(fp, "", "sub $a0, $a0, $a1", "expr minus");
            break;

        case A_TIMES:
            emit(fp, "", "mult $a0, $a1", "expr mult");
            emit(fp, "", "mflo $a0", "expr mult");
            break;

        case A_DIVIDE:
            emit(fp, "", "div $a0, $a1", "expr divide");
            emit(fp, "", "mflo $a0", "expr divide");
            break;

        case A_LT:
            emit (fp, "", "slt $a0, $a0, $a1", "expr less than");
            break;

        case A_LE:
            emit (fp, "", "add $a1, $a1, 1", "expr LE add one to compare");
            emit (fp, "", "slt $a0, $a0, $a1", "expr less than or equal");
            break;
        
        case A_GT:
            emit (fp, "", "slt $a0, $a1, $a0", "expr greater than");
            break;

        case A_GE:
            emit (fp, "", "add $a0, $a0, 1", "expr GE add one to compare");
            emit (fp, "", "slt $a0, $a1, $a0", "expr greater than or equal");
            break;

        case A_EQ:
            emit (fp, "", "slt $t2, $a0, $a1", "expr equal");
            emit (fp, "", "slt $t3, $a1, $a0", "expr equal");
            emit (fp, "", "nor $a0, $t2, $t3", "expr equal");
            emit (fp, "", "andi $a0, 1", "expr equal");
            break;

        case A_NE:
            emit (fp, "", "slt $t2, $a0, $a1", "expr not equal");
            emit (fp, "", "slt $t3, $a1, $a0", "expr not equal");
            emit (fp, "", "or $a0, $t2, $t3", "expr not equal");
            break;

        case A_AND:
            emit(fp, "", "and $a0, $a0, $a1", "expr and");
            break;

        case A_OR:
            emit(fp, "", "or $a0, $a0, $a1", "expr or");
            break;
            
        default:
            printf("emit_expr operator not known: %d\n", p->operator);
            exit(1);
    } //end of switch(p->operator)
} //end of emit_expr

// PRE: PTR to VAR node
// POST: The location of VAR in $a0, either array or not
void emit_var(ASTnode *p, FILE *fp){
    char s[100];

    if (p->s1 != NULL){//an array
        emit_expr(p->s1, fp);
        emit(fp, "", "move $a1, $a0", "var copy index array in a1");
        emit(fp, "", "sll $a1 $a1 2", "multply the index by wordsize via SLL");
    } //end of if

    if (p->symbol->level == 0){//global variable
        sprintf(s, "la $a0, %s", p->name);
        emit(fp, "", s, "emit var global variable");
    } //end of if
    else{//local variable
        emit(fp, "", "move $a0, $sp", "VAR local make a copy of stackpointer");
        sprintf(s, "addi $a0, $a0, %d", p->symbol->offset * WSIZE);
        emit(fp, "", s, "VAR local stack pointer plus offset");
    } //end of else

    if (p->s1 != NULL){//an array
        emit(fp, "", "add $a0 $a0 $a1", "var array add internal offset");
    } //end of if
} //end of emit_var

// PRE: PTR to a read var
// POST: MIPS code to generate location of VAR and read it in 
void emit_read(ASTnode *p, FILE *fp){
    emit_var(p->s1, fp); //a0 is the memory location
    emit(fp, "", "li $v0, 5", "read a number from input");
    emit(fp, "", "syscall", "reading a number");
    emit(fp, "", "sw $v0, ($a0)", "store the read into a memory location");
    fprintf(fp, "\n");
} //end of emit_read

// PRE: PTR TO a call node
// POST: $a0 will have the value
void emit_call(ASTnode *p, FILE *fp){
    char s[100];
    char temp[3];
    int tempVal = 0;

    emit(fp, "", "", "setting up function call");
    emit(fp, "", "", "evaluate funtion parameters");
   
    ASTnode *cursor = p->s1; 
    while (cursor != NULL){
        emit_args(cursor, fp);

        cursor = cursor->s2;   // move to next argument
    } //end of while

    emit(fp, "", "", "place parameters into T registers");
    cursor = p->s1; 
    while (cursor != NULL && tempVal < 8){
        sprintf(temp, "t%d", tempVal);

        sprintf(s, "lw $a0, %d($sp)", cursor->symbol->offset * WSIZE);
        emit(fp, "", s, "pull out stored arg");

        sprintf(s, "move $%s, $a0", temp);
        emit(fp, "", s, "move arg into temp");
        
        cursor = cursor->s2;
        tempVal++;
    } //end of while

    if (cursor != NULL){
        printf("Too many args in emit_call\n");
        printf("Exiting\n");
        exit(1);
    } //end of if

    fprintf(fp, "\n");

    sprintf(s, "jal %s", p->name);
    emit(fp, "", s, "call the function");
    fprintf(fp, "\n");
} //end of emit_call

//PRE: PTR to an arg for a function call
//POST: evaluates the expression and stores the value on the stack
void emit_args(ASTnode *p, FILE *fp){
        char s[100];

        emit_expr(p->s1, fp);
        sprintf(s, "sw $a0, %d($sp)", p->symbol->offset * WSIZE);
        emit(fp, "", s, "store call arg temporarily");
        fprintf(fp, "\n");
} //end of emit_args

//PRE: PTR to param_list node
//POST: assigned temp vals to params
void emit_params(ASTnode *p, FILE *fp){
    char s[100];
    char temp[3];
    static int tempVal = 0;

    while (p != NULL){ //cycle through parameters
        if (p -> symbol == NULL) //end of the list
            return;

        sprintf(temp, "t%d", tempVal);

        sprintf(s, "sw $%s, %d($sp)", temp, p->symbol->offset * WSIZE);
        emit(fp, "", s, "load temp variable into formal parameter");
        p = p->s2;
        tempVal++;
    } //end of while
} //end of emit_params

// PRE: PTR to assignment statement node
// POST: stores RHS of assign into memory 
void emit_assign(ASTnode *p, FILE *fp){
    char s[100];

    emit_expr(p->s2, fp);
    sprintf(s, "sw $a0, %d($sp)", p->symbol->offset * WSIZE);
    emit(fp, "", s, "store RHS temporarily");

    emit_var(p->s1, fp);
    sprintf(s, "lw $a1, %d($sp)", p->symbol->offset * WSIZE);
    emit(fp, "", s, "load RHS from stack");

    emit(fp, "", "sw $a1, ($a0)", "store RHS into memory");
    fprintf(fp, "\n");
} //end of emit_assign

// PRE: PTR to if
// POST: MIPS code for if and else statement
void emit_if(ASTnode *p, FILE *fp){
    char s[100];

    char *else_label = CreateLabel();
    char *if_label = CreateLabel();

    emit_expr(p->s1, fp);

    sprintf(s, "beq $a0, $0, %s", else_label);
    emit(fp, "", s, "IF branch to else part");
    fprintf(fp, "\n");

    emit(fp, "", "", "the positive portion of IF");
    emit_ast(p->s2->s1, fp);

    sprintf(s, "j %s", if_label);
    emit(fp, "", s, "if STMT1 end");

    emit(fp, else_label, "", "ELSE target");
    emit(fp, "", "", "the negative portion of IF, if there is an else");
    emit_ast(p->s2->s2, fp);

    emit(fp, if_label, "", "End of IF");
} //end of emit_if


// PRE: PTR to while
// POST: MIPS code for while statement
void emit_while(ASTnode *p, FILE *fp){
    char s[100];

    char *l1 = CreateLabel();
    char *l2 = CreateLabel();

    emit(fp, l1, "", "WHILE top target");
    emit_expr(p->s1, fp);
    
    sprintf(s, "beq $a0, $0, %s", l2);
    emit(fp, "", s, "WHILE branch out");
    emit_ast(p->s2, fp);

    sprintf(s, "j %s", l1);
    emit(fp, "", s, "WHILE jump back");
    emit(fp, l2, "", "End of WHILE");
} //end of emit_while