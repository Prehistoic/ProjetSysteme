%code requires {
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include "symbol_table.h"
}

%{

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdarg.h>
  #include "symbol_table.h"

  int yylex(void);
  int yydebug = 1;

  int cmpt_error = 0;
  void yyerror (char const *s) {
      extern int yylineno;
      fprintf (stderr, "ERROR (%d): %s\n", yylineno, s);
      cmpt_error++;
  }

  extern FILE *yyin;
  FILE *output_file = NULL;

  char last_var_read[256];

  void update_last_var(const char* new_var) {
      memset(last_var_read,'\0',256);
      strcpy(last_var_read, new_var);
  }

  int current_depth = 0;

  struct output_code {
      int last_line;
      char instructions[3000][32];
  };

  struct output_code output = {0};

  void add_to_output(char * format, ...) {
      char buffer[32];
      va_list aptr;
      va_start(aptr, format);
      vsprintf(buffer, format, aptr);
      va_end(aptr);
      strcpy(output.instructions[output.last_line], buffer);
      output.last_line++;
  }

  void display_output() {
      printf("main:\n");
      if (output_file != NULL) fprintf(output_file, "main:\n");
      for(int i=0; i<output.last_line; i++) {
          printf("%d\t%s\n",i,output.instructions[i]);
          if (output_file != NULL) fprintf(output_file, "\t%s\n", output.instructions[i]);
      }
  }

  void add_to_instruction(char *instruction, int line) {
    char buffer[32];
    sprintf(buffer, "%d", line);
    strcpy(instruction, strcat(instruction, buffer));
  }

  // Gestion des différentes opérations
  void exec_operation(const char* operator) {
      int adr_first_operand = get_last_symbol()-1;
      int adr_second_operand = get_last_symbol();
      add_to_output("%s %d %d %d",operator,adr_first_operand,adr_first_operand,adr_second_operand);
      pop_symbol();
  }

  void exec_affectation(const char* var) {
      int adr = find_symbol(var, current_depth);
      int last_adr = get_last_symbol();
      add_to_output("COP %d %d", adr, last_adr);
      set_initialized(var, current_depth);
  }

  void exec_condition(char * operation_code) {
      int adr_first_operand = get_last_symbol()-1;
      int adr_second_operand = get_last_symbol();
      int new_adr;
      if(strcmp(operation_code,"==")==0) {
        add_to_output("EQU %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
      }
      else if(strcmp(operation_code,"!=")==0) {
        new_adr = push_symbol("$", current_depth, 0);
        add_to_output("INF %d %d %d",new_adr,adr_first_operand,adr_second_operand);
        add_to_output("SUP %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
        add_to_output("ADD %d %d %d",adr_first_operand,adr_first_operand,new_adr);
        pop_symbol();
      }
      else if(strcmp(operation_code,"<")==0) {
        add_to_output("INF %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
      }
      else if(strcmp(operation_code,"<=")==0) {
        new_adr = push_symbol("$", current_depth, 0);
        add_to_output("INF %d %d %d",new_adr,adr_first_operand,adr_second_operand);
        add_to_output("EQU %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
        add_to_output("ADD %d %d %d",adr_first_operand,adr_first_operand,new_adr);
        pop_symbol();
      }
      else if(strcmp(operation_code,">")==0) {
        add_to_output("SUP %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
      }
      else if(strcmp(operation_code,">=")==0) {
        new_adr = push_symbol("$", current_depth, 0);
        add_to_output("SUP %d %d %d",new_adr,adr_first_operand,adr_second_operand);
        add_to_output("EQU %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
        add_to_output("ADD %d %d %d",adr_first_operand,adr_first_operand,new_adr);
        pop_symbol();
      }
      pop_symbol();
  }

%}

%union {
  int Integer;
  char Variable[256];
};

%token t_main t_printf
%token t_int t_const
%token t_add t_mul t_sou t_div t_eq
%token t_op t_cp t_oa t_ca
%token t_cr t_space t_tab t_comma t_sc
%token t_checkeq t_checkneq t_checkless t_checklteq t_checkgreat t_checkgrteq
%token t_if t_else t_while
%token <Integer> t_expnum
%token <Integer> t_num
%token <Variable> t_var

%type <Integer> save_line_number

%right t_eq
%left t_checkeq t_checkneq
%left t_checkless t_checklteq t_checkgreat t_checkgrteq
%left t_add t_sou
%left t_mul t_div

%start File

%%

File:
     /* Vide */
    | t_int t_main t_op t_cp t_oa { current_depth++; } Instructions t_ca { current_depth--; if (cmpt_error == 0) { display_table(); display_output(); fclose(output_file); } }
    ;

Instructions:
     /* Vide */
    | Declaration Instructions
    | Affectation Instructions
    | If_Statement Instructions
    | While_Loop Instructions
    | Print Instructions
    ;

If_Statement:
    t_if t_op Expression t_cp {
        int adr_condition_result = get_last_symbol();
        add_to_output("JMF %d ", adr_condition_result);
    }
    save_line_number t_oa { current_depth++; } Instructions {
        add_to_instruction(output.instructions[$6], output.last_line);
    }
    t_ca {
        current_depth--;
        add_to_output("JMP ");
    }
    save_line_number Else_Statement {
        add_to_instruction(output.instructions[$13], output.last_line);
    }

Else_Statement:
     /* Vide */
    | t_else t_oa { current_depth++; } Instructions t_ca { current_depth--; }
    | t_else If_Statement
    ;

While_Loop:
    t_while save_line_number t_op Expression t_cp {
        int adr_condition_result = get_last_symbol();
        add_to_output("JMF %d ", adr_condition_result);
    }
    save_line_number t_oa { current_depth++; } Instructions {
        add_to_instruction(output.instructions[$7], output.last_line+1);
        add_to_output("JMP %d", ($2)+1);
    }
    t_ca { current_depth--; }

save_line_number: { $$ = output.last_line-1; }

Declaration:
    t_int t_var {
        update_last_var($2);
        int adr = push_symbol($2, current_depth, 0);
    } Affectation_after_declaration MultipleDeclarations
    | t_const t_int t_var {
        update_last_var($3);
        int adr = push_symbol($3, current_depth, 1);
    } Affectation_after_declaration MultipleDeclarations
    ;

MultipleDeclarations:
    t_comma t_var {
        update_last_var($2);
        int adr = push_symbol($2, current_depth, 0);
    } Affectation_after_declaration MultipleDeclarations
    | t_const t_comma t_var {
        update_last_var($3);
        int adr = push_symbol($3, current_depth, 1);
    } Affectation_after_declaration MultipleDeclarations
    | t_sc
    ;

Affectation_after_declaration:
     /* Vide */
    | t_eq Expression { exec_affectation(last_var_read); }
    ;

Affectation:
    t_var t_eq Expression t_sc {
      int constant = get_const($1, current_depth);
      if(constant == 1) {
        yyerror("modification d'une constante");
      }
      else
        exec_affectation($1);
    }
    ;

Expression:
    t_num {
        int new_adr = push_symbol("$", current_depth, 0);
        add_to_output("AFC %d %d", new_adr, $1);
    }
    | t_expnum {
        int new_adr = push_symbol("$", current_depth, 0);
        add_to_output("AFC %d %d", new_adr, $1);
    }
    | t_var {
        int current_adr = find_symbol($1, current_depth);
        int new_adr = push_symbol("$",current_depth, 0);

        if(!get_initialized($1, current_depth)) {
            yyerror("variable non initialisée");
        }

        add_to_output("COP %d %d", new_adr, current_adr);
    }
    | Expression t_add Expression { exec_operation("ADD"); }
    | Expression t_sou Expression { exec_operation("SOU"); }
    | Expression t_mul Expression { exec_operation("MUL"); }
    | Expression t_div Expression { exec_operation("DIV"); }
    | Expression t_checkeq Expression { exec_condition("=="); }
    | Expression t_checkneq Expression { exec_condition("!="); }
    | Expression t_checkless Expression { exec_condition("<"); }
    | Expression t_checklteq Expression { exec_condition("<="); }
    | Expression t_checkgreat Expression { exec_condition(">"); }
    | Expression t_checkgrteq Expression { exec_condition(">="); }
    | t_op Expression t_cp
    ;

Print:
    t_printf t_op t_var t_cp t_sc {
        int adr = find_symbol($3, current_depth);
        add_to_output("PRI %d",adr);
    }
    ;

%%

int main(int argc, char *argv[]) {
  yyin = fopen(argv[1], "r");
  if (argc > 2) {
      output_file = fopen(argv[2], "w");
  }
  yyparse();
  return 0;
}
