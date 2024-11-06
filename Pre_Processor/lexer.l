%{
#include <stdio.h>    
#include "parser.tab.h"   
%}

L   [a-zA-Z_]
A   [a-zA-Z_0-9]

%%

{L}{A}*     { yylval.id = strdup(yytext); return IDENTIFIER; }

%%

// Include the implementation for yylex
int yylex(void);
