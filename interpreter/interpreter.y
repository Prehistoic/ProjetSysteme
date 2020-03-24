%code requires {
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "asm.h"
}

%{

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "asm.h"

  int yylex(void);
  void yyerror (char const *s) {
      fprintf (stderr, "%s\n", s);
  }

  extern FILE *yyin;

%}

%union {
  int Valeur;
};

%token t_main
%token t_cop t_afc t_pri t_add t_sou t_mul t_div
%token <Valeur> t_val

%start File

%%

File:
    /* Vide */
  | t_main Instructions { execute(); }
  ;

Instructions:
    /* Vide */
  | Instruction Instructions
  ;

Instruction:
    t_cop t_val t_val { add_instruction(COP, $2, $3, -1); }
  | t_afc t_val t_val { add_instruction(AFC, $2, $3, -1); }
  | t_pri t_val { add_instruction(PRI, $2, -1, -1); }
  | t_add t_val t_val t_val { add_instruction(ADD, $2, $3, $4); }
  | t_sou t_val t_val t_val { add_instruction(SOU, $2, $3, $4); }
  | t_mul t_val t_val t_val { add_instruction(MUL, $2, $3, $4); }
  | t_div t_val t_val t_val { add_instruction(DIV, $2, $3, $4); }
  ;

%%

int main(int argc, char *argv[]) {
  yyin = fopen(argv[1], "r");
  yyparse();
  return 0;
}
