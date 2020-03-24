%{
  #include "y.tab.h"
  #include "asm.h"
%}

%option noyywrap

spaces [ \t\n]+

%%

{spaces} ;
"main:" return t_main;
"COP" return t_cop;
"AFC" return t_afc;
"PRI" return t_pri;
"ADD" return t_add;
"SOU" return t_sou;
"MUL" return t_mul;
"DIV" return t_div;
[0-9]+ {
  yylval.Valeur=atoi(yytext);
  return t_val;
}

%%
