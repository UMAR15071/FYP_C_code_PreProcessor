// Reverse Polish notation calculator.

%{
    
#include <stdio.h>
#include <math.h>
int yylex(void);
void yyerror (char const*);

%}

%define api.value.type {double}
%token NUM

%%
input:
    %empty
|   input line
;


line:
    '\n'
|   exp '\n'    {printf("%.10g\n", $1);}
;

exp:
    NUM
|   exp exp '+' {$$ = $1 + $2;          }
|   exp exp '-' {$$ = $1 - $2;          }
|   exp exp '*' {$$ = $1 * $2;          }
|   exp exp '/' {$$ = $1 / $2;          }
|   exp exp '^' {$$ = pow($1, $2);      }
|   exp 'n'     {$$ = -$1;              }
;

%%