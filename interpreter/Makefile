BISON := $(shell command -v bison 2> /dev/null)

all: interpreter

interpreter: y.tab.o lex.yy.o asm.o
	gcc -Wall y.tab.o lex.yy.o asm.o -o interpreter

asm.o: asm.c
	gcc -c asm.c

y.tab.c: interpreter.y
ifdef BISON
	bison -d -v -y interpreter.y
endif
ifndef BISON
	yacc -d -v interpreter.yacc
endif

lex.yy.c: interpreter.l
	lex interpreter.l

clean:
	rm -rf interpreter lex.yy.* y.tab.* *.o *.output