all:	compiler

compiler:	compiler.y compiler.l
		lex compiler.l
		yacc -d compiler.y
		gcc -o compiler lex.yy.c y.tab.c

clean:
		rm -f compiler
		rm y.*
		rm lex.yy.c
