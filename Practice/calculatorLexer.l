%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "calculatorParser.tab.h"  // Include parser header for token definitions
%}

%%

 // Regular expressions to match tokens
[0-9]+      { yylval = atof(yytext); return NUMBER; } 
[+]        { return PLUS; }
[-]        { return MINUS; }
[*]        { return MULTIPLY; }
[/]        { return DIVIDE; }
[(]        { return LPAREN; }
[)]        { return RPAREN; }
[ \t\n]+   { /* Ignore whitespace */ }

%%

// No main function here since it is part of the parser
