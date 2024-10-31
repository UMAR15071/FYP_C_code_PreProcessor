%option noyywrap

%{
#include <stdio.h>
#include <string.h>

int chars = 0;
int words = 0;
int lines = 0;

int totchars = 0;
int totwords = 0;
int totlines = 0;
%}

%%

[a-zA-Z]+  { words++; chars += strlen(yytext); }  // Count words and characters in each word
\n         { chars++; lines++; }                 // Count newlines and characters
.          { chars++; }                          // Count each character not matched by other patterns

%%

int main(int argc, char **argv) {
    int i;

    if (argc < 2) {  // If no arguments, read from standard input (stdin)
        yylex();
        printf("%8d%8d%8d\n", lines, words, chars);
        return 0;
    }

    for (i = 1; i < argc; i++) {
        FILE *f = fopen(argv[i], "r");

        if (!f) {
            perror(argv[i]);
            return 1;
        }

        yyrestart(f);  // Set the lexer to read from the current file
        yylex();       // Run the lexer on the file
        fclose(f);

        printf("%8d%8d%8d %s\n", lines, words, chars, argv[i]);

        // Update totals
        totchars += chars;
        totwords += words;
        totlines += lines;

        // Reset counters for the next file
        chars = words = lines = 0;
    }

    if (argc > 2)  // If multiple files, print total counts
        printf("%8d%8d%8d total\n", totlines, totwords, totchars);

    return 0;
}
