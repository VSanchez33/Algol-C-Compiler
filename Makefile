all:	compiler

compiler:	compiler.y compiler.l ast.c ast.h
		lex compiler.l
		yacc -d compiler.y
		gcc -o compiler lex.yy.c y.tab.c ast.c

clean:
		rm -f compiler
		rm y.*
		rm lex.yy.c
