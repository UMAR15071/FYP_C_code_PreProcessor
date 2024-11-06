#include <stdio.h>
#include <stdlib.h>

extern FILE* yyin; // Declare yyin to be used for file input
extern int yyparse(); // Declare the yyparse function from the parser
extern void yyerror(const char* msg); // Error handling function

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r"); // Open the input file specified as the first argument
        if (!yyin) {
            perror("Failed to open file");
            return 1; // Return an error code if the file can't be opened
        }
    } else {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]); // Usage message if no file is provided
        return 1;
    }

    yyparse(); // Start parsing
    fclose(yyin); // Close the input file
    return 0; // Return success
}
