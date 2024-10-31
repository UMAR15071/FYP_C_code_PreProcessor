%{
    #include <stdio.h>
    #include <stdlib.h>

    int yylex(void);                  // Declaration for yylex
    void yyerror(const char *s);      // Declaration for yyerror
%}

%union {
    int num;
}

%token <num> NUMBER
%token ADD SUB MUL DIV ABS
%token EOL
%token OP CP

%type <num> exp factor term

%%

calclist:
    /* nothing */
    | calclist exp EOL { printf(" = %d\n", $2); }
    ;

exp:
    factor
    | exp ADD factor { $$ = $1 + $3; }
    | exp SUB factor { $$ = $1 - $3; }
    ;

factor:
    term
    | factor MUL term { $$ = $1 * $3; }
    | factor DIV term { if ($3 != 0) $$ = $1 / $3; else { yyerror("division by zero"); $$ = 0; } }
    ;

term:
    NUMBER
    | OP exp CP {$$ = $2;}
    | ABS term { $$ = $2 >= 0 ? $2 : -$2; }
    ;

%%

int main(int argc, char **argv) {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "error: %s\n", s);  // Correctly outputs to stderr
}
