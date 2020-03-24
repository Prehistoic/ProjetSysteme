all: compiler

compiler: y.tab.o lex.yy.o symbol_table.o
	gcc -Wall y.tab.o lex.yy.o symbol_table.o -o compiler

symbol_table.o: symbol_table.c
	gcc -c symbol_table.c

y.tab.c: compiler.y
	yacc -d -v compiler.yacc

lex.yy.c: compiler.l
	lex compiler.l

clean:
	rm -rf compiler lex.yy.* y.tab.* *.o *.output
