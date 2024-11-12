#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;
int yyparse();

int main(int argc, char *argv[]) {
    // Check if a filename is provided as an argument
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Open the file passed as an argument in read mode
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error: Could not open file %s\n", argv[1]);
        return EXIT_FAILURE;  // Return failure status if the file can't be opened
    }

    printf("Parsing started...\n");

    // Start parsing
    if (yyparse() != 0) {
        fprintf(stderr, "Error: Parsing failed\n");
    }

    printf("Parsing completed successfully.\n");

    // Close the file after parsing
    fclose(yyin);

    return 0;
}
