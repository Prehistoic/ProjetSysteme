BISON := $(shell command -v bison 2> /dev/null)

all: compiler

compiler: y.tab.o lex.yy.o symbol_table.o function_table.o
	gcc -Wall y.tab.o lex.yy.o symbol_table.o function_table.o -o compiler

symbol_table.o: symbol_table.c
	gcc -c symbol_table.c

function_table.o: function_table.c
	gcc -c function_table.c

y.tab.c: compiler.y
ifdef BISON
	bison -d -v -y compiler.y
endif
ifndef BISON
	yacc -d -v compiler.yacc
endif

lex.yy.c: compiler.l
	lex compiler.l

clean:
	rm -rf compiler lex.yy.* y.tab.* *.o *.output *.asm
