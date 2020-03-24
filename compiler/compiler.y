%code requires {
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "symbol_table.h"
}

%{

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "symbol_table.h"

  int yylex(void);
  void yyerror (char const *s) {
      fprintf (stderr, "%s\n", s);
  }

  extern FILE *yyin;

  char last_var_read[256];

  void update_last_var(const char* new_var) {
      memset(last_var_read,'\0',256);
      strcpy(last_var_read, new_var);
  }

  int current_depth = 0;

  // Gestion des différentes opérations
  void exec_operation(const char* operator) {
      int adr_first_operand = get_last_symbol()-1;
      int adr_second_operand = get_last_symbol();
      printf("\t%s %d %d %d\n",operator,adr_first_operand,adr_first_operand,adr_second_operand);
      pop_symbol();
  }

  void exec_affectation(const char* var) {
      int adr = find_symbol(var, current_depth);
      int last_adr = get_last_symbol();
      printf("\tCOP %d %d\n", adr, last_adr);
      set_initialized(var, current_depth);
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
%token <Integer> t_expnum
%token <Integer> t_num
%token <Variable> t_var

%right t_eq
%left t_add t_sou
%left t_mul t_div

%start File

%%

File:
     /* Vide */
    | t_int t_main t_op t_cp { printf("main:\n"); }
      t_oa { current_depth++; } Instructions t_ca { display_table(); }
    ;

Instructions:
     /* Vide */
    | Declaration Instructions
    | Affectation Instructions
    | Print Instructions
    ;

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
      int init = get_const($1, current_depth);
      if(init == 1) {
        printf("ERREUR TENTATIVE DE CHANGEMENT DE LA VALEUR DE LA CONSTANTE %s",$1);
        exit(-1);
      }
      else
        exec_affectation($1);
    }
    ;

Expression:
    t_num {
        int new_adr = push_symbol("$", current_depth, 0);
        printf("\tAFC %d %d\n", new_adr, $1);
    }
    | t_expnum {
        int new_adr = push_symbol("$", current_depth, 0);
        printf("\tAFC %d %d\n", new_adr, $1);
    }
    | t_var {
        int current_adr = find_symbol($1, current_depth);
        int new_adr = push_symbol("$",current_depth, 0);

        if(!get_initialized($1, current_depth)) {
          printf("ERREUR LA VARIABLE %s N'EST PAS INITIALISÉE !!!",$1);
          exit(-1);
        }

        printf("\tCOP %d %d\n", new_adr, current_adr);
    }
    | Expression t_add Expression { exec_operation("ADD"); }
    | Expression t_sou Expression { exec_operation("SOU"); }
    | Expression t_mul Expression { exec_operation("MUL"); }
    | Expression t_div Expression { exec_operation("DIV"); }
    | t_op Expression t_cp
    ;

Print:
    t_printf t_op t_var t_cp t_sc {
        int adr = find_symbol($3, current_depth);
        printf("\tPRI %d\n",adr);
    }
    ;

%%

int main(int argc, char *argv[]) {
  yyin = fopen(argv[1], "r");
  yyparse();
  return 0;
}
