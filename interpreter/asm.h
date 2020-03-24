#ifndef ASM_H
#define ASM_H

#define NB_REGISTRES 32
#define MAX_INSTRUCTIONS 1000

#define COP 1
#define AFC 2
#define PRI 3
#define ADD 4
#define SOU 5
#define MUL 6
#define DIV 7

struct instruction
{
  int type;
  int val1;
  int val2;
  int val3;
};

void execute();

void add_instruction(int type, int val1, int val2, int val3);

void execute_instruction(int index);

void print_registers();

void print_instructions(int line);

void print_instruction(struct instruction inst);

void print_program();

void print_printbuffer();

int print_input_mode(int line);

void add_breakpoint();

int check_breakpoints(int line);

#endif