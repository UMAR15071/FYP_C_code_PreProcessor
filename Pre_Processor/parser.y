%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();  // Declare yylex()
int yyerror(const char* s);
extern char *yytext;
extern FILE *yyin;

long int TARGET_LONG_MAX = 2147483647L; 
%}

%define parse.error detailed

%union {
    char* id;
    struct for_stmt {
        char *init;
        char *cond;
        char *update;
    } for_stmt_type;
}

%token <id> I_CONSTANT F_CONSTANT ENUMERATION_CONSTANT

%%
input
    : /* empty */                     // Allow empty input
    | input line                      // Process each line
    ;

line
    : constant '\n'                   // Constant followed by newline
    | constant                        // Constant without newline (end-of-file case)
    ;

constant
    : '-' constant          { printf("Parsed negative constant: -%s\n", yytext); }
    | I_CONSTANT		    {       printf("Parsed I_CONSTANT: %s\n", yytext);
                            }
    | F_CONSTANT	        {   printf("Parsed F_CONSTANT: %s\n", yytext);
                            }
    | ENUMERATION_CONSTANT	{   printf("Parsed ENUMERATION_CONSTANT: %s\n", yytext);
                            }
    ;

%%


int yyerror(const char* s) {
    fprintf(stderr, "Error: %s at %s\n", s, yytext);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }
    yyparse();
    return 0;
}
