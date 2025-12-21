#ifndef EMIT_H
#define EMIT_H
#include "ast.h"
#include "symtable.h"

#define WSIZE 4
#define LOG_WSIZE 2

void EMIT(ASTnode *p, FILE *fp);
void emit_header(ASTnode *p, FILE *fp);
void emit_globals(ASTnode *p, FILE *fp);
void emit_strings(ASTnode *p, FILE *fp);
void emit (FILE *fp, char *label, char *command, char *comment);

#endif