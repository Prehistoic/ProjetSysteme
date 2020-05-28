%code requires {
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include "symbol_table.h"
    #include "function_table.h"
}

%{

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdarg.h>
  #include "symbol_table.h"
  #include "function_table.h"

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
      memset(last_var_read, '\0', 256);
      strcpy(last_var_read, new_var);
  }

  int current_depth = 0;
  int current_func = -1;
  int const_status = 0;
  int pointer_status = 0;

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

  int current_args = 0;

  void compare_params(char * id, int nb_args) {
    int func_params = get_params_code(id);
    if(current_args != func_params) {
      if(nb_args != get_function_params(id)) {
        yyerror("Mauvais nombre de paramètres !");
      } else {
        yyerror("Mauvais type(s) de paramètres !");
      }
    }
    current_args = 0;
  }

  void update_current_args() {
    int addr = get_last_symbol();
    int new = is_pointer(addr) + 1;
    if(current_args == 0) {
      current_args = new;
    } else {
      current_args = current_args * 10 + new;
    }
  }

  // Gestion des différentes opérations
  void exec_operation(const char* operator) {
      int adr_first_operand = get_last_symbol()-1;
      int adr_second_operand = get_last_symbol();
      add_to_output("%s %d %d %d",operator,adr_first_operand,adr_first_operand,adr_second_operand);
      pop_symbol();
  }

  void exec_affectation(const char* var) {
      int adr = find_symbol(var, current_depth, current_func);
      int last_adr = get_last_symbol();
      add_to_output("COP %d %d", adr, last_adr);
      set_initialized(var, current_depth, current_func);
  }

  void exec_condition(char * operation_code) {
      int adr_first_operand = get_last_symbol()-1;
      int adr_second_operand = get_last_symbol();
      int new_adr;
      if(strcmp(operation_code,"==")==0) {
        add_to_output("EQU %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
      }
      else if(strcmp(operation_code,"!=")==0) {
        new_adr = push_symbol("$", current_depth, 0, 0, current_func);
        add_to_output("INF %d %d %d",new_adr,adr_first_operand,adr_second_operand);
        add_to_output("SUP %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
        add_to_output("ADD %d %d %d",adr_first_operand,adr_first_operand,new_adr);
        pop_symbol();
      }
      else if(strcmp(operation_code,"<")==0) {
        add_to_output("INF %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
      }
      else if(strcmp(operation_code,"<=")==0) {
        new_adr = push_symbol("$", current_depth, 0, 0, current_func);
        add_to_output("INF %d %d %d",new_adr,adr_first_operand,adr_second_operand);
        add_to_output("EQU %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
        add_to_output("ADD %d %d %d",adr_first_operand,adr_first_operand,new_adr);
        pop_symbol();
      }
      else if(strcmp(operation_code,">")==0) {
        add_to_output("SUP %d %d %d",adr_first_operand,adr_first_operand,adr_second_operand);
      }
      else if(strcmp(operation_code,">=")==0) {
        new_adr = push_symbol("$", current_depth, 0, 0, current_func);
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

%token t_main t_printf t_return
%token t_int t_const t_void t_amp
%token t_add t_mul t_sou t_div t_eq
%token t_op t_cp t_oa t_ca
%token t_cr t_space t_tab t_comma t_sc
%token t_checkeq t_checkneq t_checkless t_checklteq t_checkgreat t_checkgrteq
%token t_if t_else t_while
%token <Integer> t_expnum
%token <Integer> t_num
%token <Variable> t_var

%type <Variable> t_main
%type <Integer> Save_Line_Number
%type <Integer> Int_Function_Call
%type <Integer> Params
%type <Integer> Multiple_Params
%type <Integer> Args
%type <Integer> Multiple_Args

%right t_eq
%left t_checkeq t_checkneq
%left t_checkless t_checklteq t_checkgreat t_checkgrteq
%left t_add t_sou
%left t_mul t_div

%start File

%%

File:
    /* vide */
  | { add_to_output("JMP "); } Functions
  ;

Functions:
    Main
  | Function_Declaration Functions
  ;

Main:
    t_void t_main t_op t_cp Save_Line_Number t_oa {
      add_function("main");
      set_function_attributes("main", 0, -1, 0);
      current_func++;
      add_to_instruction(output.instructions[0], $5 + 1);
    } Instructions t_ca {
      if (cmpt_error == 0) {
        clear_current_func_symbols(current_func);
        display_table();
        display_functions();
        display_output();
        if(output_file != NULL) {
          fclose(output_file);
        }
      }
    }
    | t_int t_main t_op t_cp Save_Line_Number t_oa {
        add_function("main");
        set_function_attributes("main", 0, -1, 0);
        current_func++;
        add_to_instruction(output.instructions[0], $5 + 1);
      } Instructions t_return Expression t_sc t_ca {
        if (cmpt_error == 0) {
          clear_current_func_symbols(current_func);
          display_table();
          display_functions();
          display_output();
          if(output_file != NULL) {
            fclose(output_file);
          }
        }
      }
    ;

Function_Declaration:
    t_int t_var {
      current_func++;
      add_function($2);
    } t_op Params t_cp Save_Line_Number t_oa {
      set_function_attributes($2, $5, $7 +1, 0);
    } Instructions t_return Expression {
        if(is_pointer(get_last_symbol()) == 0) {
        add_to_output("COP 0 %d", get_last_symbol());
      } else {
        yyerror("Mauvais type de retour, entier attendu !");
      }
    }
    t_sc t_ca {
      add_to_output("RET");
      clear_current_func_symbols(current_func);
    }
    | t_int t_mul t_var {
      current_func++;
      add_function($3);
    } t_op Params t_cp Save_Line_Number t_oa {
      set_function_attributes($3, $6, $8 +1, 1);
    } Instructions t_return Expression {
        if(is_pointer(get_last_symbol()) == 1) {
        add_to_output("COP 0 %d", get_last_symbol());
      } else {
        yyerror("Mauvais type de retour, pointeur attendu !");
      }
    }
    t_sc t_ca {
      add_to_output("RET");
      clear_current_func_symbols(current_func);
    }
    | t_void t_var {
      current_func++;
      add_function($2);
    } t_op Params t_cp Save_Line_Number t_oa {
        set_function_attributes($2, $5, $7 +1, 0);
      } Instructions t_ca {
        add_to_output("RET");
        clear_current_func_symbols(current_func);
      }
  ;

Params:
      /* vide */ { $$ = 0; }
    | t_void { $$ = 0; }
    | t_int t_var {
        update_last_var($2);
        int adr = push_symbol($2, current_depth, 0, 0, current_func);
        set_initialized($2, current_depth, current_func);
        add_to_params_code(current_func, 1);
      } Multiple_Params { $$ = $4 + 1; }
    | t_int t_mul t_var {
        update_last_var($3);
        int adr = push_symbol($3, current_depth, 0, 1, current_func);
        set_initialized($3, current_depth, current_func);
        add_to_params_code(current_func, 2);
      } Multiple_Params { $$ = $5 + 1; }
    ;

Multiple_Params:
      /* Vide */ { $$ = 0; }
    | t_comma t_int t_var {
        update_last_var($3);
        int adr = push_symbol($3, current_depth, 0, 0, current_func);
        set_initialized($3, current_depth, current_func);
        add_to_params_code(current_func, 1);
      } Multiple_Params { $$ = $5 + 1; }
    | t_comma t_int t_mul t_var {
        update_last_var($4);
        int adr = push_symbol($4, current_depth, 0, 1, current_func);
        set_initialized($4, current_depth, current_func);
        add_to_params_code(current_func, 2);
      } Multiple_Params { $$ = $6 + 1; }
    ;

Instructions:
     /* Vide */
    | Instruction Instructions
    ;

Instruction:
      Declaration
    | Affectation
    | If_Statement
    | While_Loop
    | Print
    | Void_Function_Call
    ;

Print:
    t_printf t_op t_var t_cp t_sc {
        int adr = find_symbol($3, current_depth, current_func);
        add_to_output("PRI %d",adr);
    }
    ;

Void_Function_Call:
  t_var t_op Args t_cp t_sc {
    if(get_func_index($1) == -1) {
      yyerror("Fonction inconnue !");
    } else {
      compare_params($1,$3);
      add_to_output("PUSH %d %d", get_function_params($1), get_last_symbol());
      add_to_output("CALL %d %d", get_function_start($1), output.last_line+1);
      add_to_output("POP");
    }
  }
  ;

Int_Function_Call:
  t_var t_op Args t_cp {
    if(get_func_index($1) == -1) {
      yyerror("Fonction inconnue !");
    } else {
      compare_params($1,$3);
      add_to_output("PUSH %d %d", get_function_params($1), get_last_symbol());
      add_to_output("CALL %d %d", get_function_start($1), output.last_line+1);
      add_to_output("POP %d", get_last_symbol()+1);
      pointer_status = return_pointer($1);
    }
  }
  ;

Args:
      /* vide */ { $$ = 0; }
    | Expression Multiple_Args { $$ = $2 + 1; update_current_args(); }
    ;

Multiple_Args:
      /* Vide */ { $$ = 0; }
    | t_comma Expression Multiple_Args { $$ = $3 + 1; update_current_args(); }
    ;

If_Statement:
    t_if t_op Expression {
        int adr_condition_result = get_last_symbol();
        add_to_output("JMF %d ", adr_condition_result);
        pop_symbol();
    } t_cp Save_Line_Number t_oa { current_depth++; } Instructions {
        add_to_output("JMP ");
        add_to_instruction(output.instructions[$6], output.last_line);
    }
    t_ca { clear_current_depth_symbols(current_depth); current_depth--; } Save_Line_Number
    Else_Statement { add_to_instruction(output.instructions[$13], output.last_line); }
    ;

Else_Statement:
     /* Vide */
    | t_else t_oa { current_depth++; } Instructions t_ca { clear_current_depth_symbols(current_depth); current_depth--; }
    ;

While_Loop:
    t_while Save_Line_Number t_op Expression t_cp {
        int adr_condition_result = get_last_symbol();
        add_to_output("JMF %d ", adr_condition_result);
        pop_symbol();
    }
    Save_Line_Number t_oa { current_depth++; } Instructions {
        add_to_instruction(output.instructions[$7], output.last_line+1);
        add_to_output("JMP %d", $2+1);
    }
    t_ca { clear_current_depth_symbols(current_depth); current_depth--; }
    ;

Save_Line_Number:
    { $$ = output.last_line-1; }
    ;

Declaration:
    t_int t_var {
        update_last_var($2);
        int adr = push_symbol($2, current_depth, 0, 0, current_func);
    } Affectation_After_Declaration Multiple_Declarations
    | t_const t_int t_var {
        update_last_var($3);
        int adr = push_symbol($3, current_depth, 1, 0, current_func);
        const_status = 1;
    } Affectation_After_Declaration Multiple_Declarations
    | t_int t_mul t_var {
        update_last_var($3);
        int adr = push_symbol($3, current_depth, 0, 1, current_func);
    } Affectation_After_Declaration Multiple_Declarations
    | t_const t_int t_mul t_var {
        update_last_var($4);
        int adr = push_symbol($4, current_depth, 1, 1, current_func);
        const_status = 1;
    } Affectation_After_Declaration Multiple_Declarations
    ;

Multiple_Declarations:
    t_comma t_var {
        update_last_var($2);
        int adr = push_symbol($2, current_depth, const_status, pointer_status, current_func);
    } Affectation_After_Declaration Multiple_Declarations
    | t_sc { const_status = 0; pointer_status = 0; }
    ;

Affectation_After_Declaration:
     /* Vide */
    | t_eq Expression { exec_affectation(last_var_read); pop_symbol(); }
    ;

Affectation:
    t_var t_eq Expression t_sc {
      int constant = get_const($1, current_depth, current_func);
      if(constant == 1) {
        yyerror("Modification d'une constante");
      }
      else
        exec_affectation($1);
        pop_symbol();
    }
    ;

Expression:
    t_num {
        int new_adr = push_symbol("$", current_depth, 0, 0, current_func);
        add_to_output("AFC %d %d", new_adr, $1);
    }
    | t_expnum {
        int new_adr = push_symbol("$", current_depth, 0, 0, current_func);
        add_to_output("AFC %d %d", new_adr, $1);
    }
    | t_var {
        int current_adr = find_symbol($1, current_depth, current_func);
        int pointer = is_pointer(current_adr);
        int new_adr = push_symbol("$",current_depth, 0, pointer, current_func);

        if(!get_initialized($1, current_depth, current_func)) {
            yyerror("Variable non initialisée");
        }

        add_to_output("COP %d %d", new_adr, current_adr);
    }
    | t_amp t_var {
        int current_adr = find_symbol($2, current_depth, current_func);
        int new_adr = push_symbol("$",current_depth, 0, 1, current_func);

        if(!get_initialized($2, current_depth, current_func)) {
            yyerror("Variable non initialisée");
        }

        add_to_output("STR %d %d", new_adr, current_adr);
    }
    | t_mul t_var {
        int current_adr = find_symbol($2, current_depth, current_func);

        if(!is_pointer(current_adr)) {
            yyerror("Déférencement d'une variable non pointeur !");
        }

        int new_adr = push_symbol("$",current_depth, 0, 0, current_func);

        if(!get_initialized($2, current_depth, current_func)) {
            yyerror("Variable non initialisée");
        }

        add_to_output("LDR %d %d", new_adr, current_adr);
    }
    | Int_Function_Call {
        int new_adr = push_symbol("$", current_depth, 0, pointer_status, current_func);
        pointer_status = 0;
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

%%

int main(int argc, char *argv[]) {
  yyin = fopen(argv[1], "r");
  if (argc>2) {
    output_file = fopen(argv[2], "w");
  }
  yyparse();
  return 0;
}
