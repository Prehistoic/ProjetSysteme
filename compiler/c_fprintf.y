%{
    
#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;
extern FILE *yyout;
int yydebug = 1;

%}

%union {int Integer;
        char * Variable;}

%token t_main t_printf t_return
%token t_int t_const
%token t_add t_mul t_sou t_div t_eq
%token t_op t_cp t_oa t_ca
%token t_cr t_space t_tab t_comma t_sc
%token <Integer> t_expnum 
%token <Integer> t_num 
%token <Variable> t_var

%left t_add t_sou
%left t_mul t_div
%left t_neg

%start File

%%

File:
     /* Vide */
    | t_int t_main t_op { fprintf(yyout, "int main("); } Params t_cp t_oa { fprintf(yyout, ") {\n"); } Body t_return t_num t_sc t_ca { fprintf(yyout, "return 0;\n}"); }
    ;

Body:
     /* Vide */
    | Line t_sc { fprintf(yyout, ";\n"); } Body
    ;

Params:
     /* Vide */
    | NonEmptyParams
    ;

SingleParam:
    t_var { fprintf(yyout, "%s", $1); }
    ;

NonEmptyParams:
    SingleParam
    | SingleParam t_comma { fprintf(yyout, ","); } NonEmptyParams  
    ;

Line:
    Definition
    | Affectation
    | Print
    ;

Number:
    t_num { fprintf(yyout,"%d", $1); }
    | t_expnum { fprintf(yyout,"%d", $1); }
    ;

Expression:
    Number 
    | t_var { fprintf(yyout, "%s", $1); }
    | Expression t_add { fprintf(yyout, "+"); } Expression 
    | Expression t_sou { fprintf(yyout, "-"); } Expression 
    | Expression t_mul { fprintf(yyout, "*"); } Expression 
    | Expression t_div { fprintf(yyout, "/"); } Expression
    | t_sou { fprintf(yyout, "-"); } Expression %prec t_neg 
    | t_op { fprintf(yyout, "("); } Expression t_cp { fprintf(yyout, ")"); }
    ;

SingleDefinition:
    t_var { fprintf(yyout, "%s", $1); }
    ;

Definitions:
    SingleDefinition
    | SingleDefinition t_comma { fprintf(yyout, ", "); } Definitions  
    ;

Definition:
    t_const t_int { fprintf(yyout, "const int "); } Definitions
    | t_int { fprintf(yyout, "int "); } Definitions 
    ;

Affectation:
    Definition t_eq { fprintf(yyout, "="); } Expression 
    | t_var t_eq { fprintf(yyout, "%s=", $1); } Expression 
    ;

Print:
    t_printf t_op { fprintf(yyout, "printf("); } NonEmptyParams t_cp { fprintf(yyout, ")"); }
    ;

%%

int yyerror(char *s) {
  printf("%s\n",s);
  exit(2);
  return 1;
}


int main(int argc, char *argv[]) {
  if (argc == 3) {

   yyout = fopen(argv[2],"w");
   yyin = fopen(argv[1], "r");
   yyparse();
   fclose(yyout);
  }
  else {
    printf("Wrong usage !\n");
  }

  return 0;
}
