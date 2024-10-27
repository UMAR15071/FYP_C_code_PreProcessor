%{

#include <stdio.h>
#include <stdlib.h>
int yylex();    
    
%}

%token CHARACTER   NUMBER

%%

programe: max | min;

max:    CHARACTER {

        printf("this is character \n");
        exit(0);

        };

min:    NUMBER{

        printf("this is number \n");
        exit(0);
        }
%%