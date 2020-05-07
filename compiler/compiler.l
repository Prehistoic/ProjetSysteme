%{
  #include "y.tab.h"
  #include "symbol_table.h"
  #include "function_table.h"
%}

%option noyywrap
%option yylineno

spaces [ \t\n]+

%%

{spaces} ;

"main" return t_main;
"return" return t_return;
"void" return t_void;
"(" return t_op;
")" return t_cp;
"{" return t_oa;
"}" return t_ca;
"const" return t_const;
"int" return t_int;
"&" return t_amp;
"+" return t_add;
"-" return t_sou;
"*" return t_mul;
"/" return t_div;
"=" return t_eq;
"," return t_comma;
";" return t_sc;
"if" return t_if;
"else" return t_else;
"while" return t_while;
"==" return t_checkeq;
"!=" return t_checkneq;
"<" return t_checkless;
"<=" return t_checklteq;
">" return t_checkgreat;
">=" return t_checkgrteq;
"printf" return t_printf;
[0-9]+[eE][+]?[0-9]+ {
    yylval.Integer=(int)atof(yytext);
    return t_expnum;
}
[0-9]+ {
    yylval.Integer=atoi(yytext);
    return t_num;
}
[a-zA-Z][a-zA-Z0-9_]* {
    strcpy(yylval.Variable, yytext);
    return t_var;
};

%%
