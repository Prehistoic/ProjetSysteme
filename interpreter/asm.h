#ifndef ASM_H
#define ASM_H

#define NB_REGISTRES 16
#define MAX_INSTRUCTIONS 1000
#define MAX_LR_STACK 50
#define MAX_RI_STACK 50

#define COP 1
#define AFC 2
#define PRI 3
#define ADD 4
#define SOU 5
#define MUL 6
#define DIV 7
#define JMP 8
#define JMF 9
#define INF 10
#define SUP 11
#define EQU 12
#define CALL 13
#define PUSH 14
#define POP 15
#define RET 16
#define STR 17
#define LDR 18

struct instruction
{
  int type;
  int val1;
  int val2;
  int val3;
};

void push_to_stack(int nb_params, int last_param);

void pop_from_stack(int return_index);

void execute();

void add_instruction(int type, int val1, int val2, int val3);

int execute_instruction(int index);

void print_registers();

void print_instructions(int line);

void print_instruction(struct instruction inst);

void print_program();

void print_printbuffer();

int print_input_mode(int line);

void add_breakpoint();

int check_breakpoints(int line);

void clear_console();

#endif
