#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>

extern double yylval;  // Ensure yylval is declared

int yylex(void)
{
    int c = getchar();
    
    while(c == ' ' || c == '\t')
        c = getchar();

    if(c == '.' || isdigit(c)){
        ungetc(c, stdin);
        if(scanf ("%lf", &yylval) != 1)
            abort(); 
        return NUM;  
    }
    else if (c == EOF) 
        return YYEOF;
    else
        return c;  // Return the character itself for single-character tokens
}

// Error reporting function used by the parser
void yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}

// Main function calling the parser
int main(void)
{
    return yyparse();  
}
