%{
#include <stdio.h>
extern int is_typedef_name(char*);
%}
%option noyywrap
%x ATTRIBUTE

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))

%%
{L}{A}*                     {yylval.id = strdup_safe(yytext);
                             if (is_typedef_name(yylval.id)) {
                                //if (debugMode) printf("Debug: returning the typedef %s from lexer\n", yytext);
                                return TYPEDEF_NAME;
                             }
                             return IDENTIFIER;
                            }
%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Failed to open file");
            return 1;
        }
    } else {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    yylex();
    fclose(yyin);
    return 0;
}

void wrap_integer_constants(char *wrapper, char *input, char **output) {
    // This function is now left as a placeholder.
}
