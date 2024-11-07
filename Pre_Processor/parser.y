%{
#include <stdio.h>
#include <stdlib.h>
extern int yylex();  // Declare yylex()
int yyerror(char *s);
%}

%token CHARACTER NUMBER

%%

program : num 
        | letter
        ;

num : NUMBER {
    printf("This is a number\n");
}

letter : CHARACTER {
    printf("This is a character\n");
}

%%

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}


