all:	compiler

compiler:	compiler.y compiler.l ast.c ast.h symtable.c symtable.h emit.c emit.h
			lex compiler.l
			yacc -d compiler.y
			gcc -o compiler lex.yy.c y.tab.c ast.c symtable.c emit.c

clean:
		rm -f compiler
		rm y.*
		rm lex.yy.c
