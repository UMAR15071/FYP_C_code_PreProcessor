%{

#include "handle_typedefs.c"
void yyerror(const char*);
    
%}

%token <id> IDENTIFIER TYPEDEF_NAME I_CONSTANT F_CONSTANT ENUMERATION_CONSTANT STRING_LITERAL

%%
primary_expression
	: IDENTIFIER
		{$$ = to_prolog_var($1);
		 free($1);
		}
%%