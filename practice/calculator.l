%{
   #include "calculator.tab.h"  // Include the generated Bison header file
%}

%%
"+"    { return ADD; }
"-"    { return SUB; }
"*"    { return MUL; }
"/"    { return DIV; }
"|"    { return ABS; }
"("     { return OP; }
")"     { return CP; }
"//".*  /* ignore comments */
[0-9]+ { yylval.num = atoi(yytext); return NUMBER; }  // Use yylval.num to store integer value
\n     { return EOL; }
[ \t]  { /* ignore whitespace */ }
.      { printf("Mystery character %c\n", *yytext); }

%%

int yywrap(void) {
    return 1;  // Required to handle end-of-file in Flex
}
