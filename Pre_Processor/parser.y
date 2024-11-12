%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex();  // Declare yylex()
int yyerror(char *s);
extern char *yytext;

long int TARGET_LONG_MAX = 2147483647L; 
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
    : I_CONSTANT		    {       printf("Parsed I_CONSTANT: %s\n", yytext);
                                    return I_CONSTANT;
                            }
	| F_CONSTANT	        {   printf("Parsed F_CONSTANT: %s\n", yytext);
                                return F_CONSTANT;
                            }
	| ENUMERATION_CONSTANT	{   printf("Parsed ENUMERATION_CONSTANT: %s\n", yytext);
                                return ENUMERATION_CONSTANT;
                            }
	;
%%

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}
