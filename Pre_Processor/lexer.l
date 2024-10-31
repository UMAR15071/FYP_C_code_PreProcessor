%{
#include <stdio.h>
#define YY_BUFFER_SIZE 32768
%}

%%
.*\n       { printf("%s", yytext); }  // Print each line from each file
%%

int main(int argc, char *argv[]) {
    if (argc < 2) {
       printf("Usage: %s <filename1> <filename2> .... \n", argv[0]);
       return 1;
    }
    for(int i = 1; i < argc; i++){
         yyin = fopen(argv[i], "r");  // Set `yyin` to the input file
        if (!yyin) {
            perror("Failed to open file");
            return 1;
        }
        printf("Reading file: %s\n", argv[i]);
        yylex();  // Start scanning with Flex
        fclose(yyin);  // Close the file after scanning
        
    }

   return 0;
}
