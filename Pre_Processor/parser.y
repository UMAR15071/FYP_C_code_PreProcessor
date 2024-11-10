%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex();  // Declare yylex()
int yyerror(char *s);
%}

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

constant
	: I_CONSTANT		/* includes character_constant */
	| F_CONSTANT	    {printf("Floating successfully parsed");}
	| ENUMERATION_CONSTANT	
	;
%%

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}
