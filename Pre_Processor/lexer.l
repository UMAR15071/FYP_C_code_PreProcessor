%{
#include <stdio.h>  
#include <stdlib.h>
#include "parser.tab.h"
extern int yyerror(const char *s);  // Declare yyerror()

%}

%%

[a-z]           { return CHARACTER; }      // Return CHARACTER for lowercase letters
[0-9]+          { return NUMBER; }         // Return NUMBER for sequences of digits
[ \t\n]+        { /* Ignore whitespace */ } // Ignore whitespace, tabs, and newlines
.               { yyerror("Unknown token!"); } // Call yyerror for unknown tokens

%%

