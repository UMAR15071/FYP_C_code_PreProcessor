%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void yyerror(const char* msg); // Function prototype for error handling
%}

%token<identifier> IDENTIFIER

%%

// Define a simple rule for starting with IDENTIFIER
start:
    IDENTIFIER {
        printf("Identifier parsed: %s\n", $1); // Output the parsed identifier
    }
    ;

%%

// Prototypes for the lexer function
int yylex(void); // Declare the lexer function

int main(int argc, char *argv[]) {
    yyparse(); // Start parsing
    return 0;
}

void yyerror(const char* msg) {
    fprintf(stderr, "Error: %s\n", msg);
}
