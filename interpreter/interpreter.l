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
"JMP" return t_jmp;
"JMF" return t_jmf;
"INF" return t_inf;
"SUP" return t_sup;
"EQU" return t_equ;
"CALL" return t_call;
"PUSH" return t_push;
"POP" return t_pop;
"RET" return t_ret;
"STR" return t_str;
"LDR" return t_ldr;
[0-9]+ {
  yylval.Valeur=atoi(yytext);
  return t_val;
}

%%
