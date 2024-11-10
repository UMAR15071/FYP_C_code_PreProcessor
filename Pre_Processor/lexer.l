%{
#include <stdio.h>  
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
extern int yyerror(const char *s);  // Declare yyerror()
void wrap_floating_point_constants(char *, char *, char **);
void add_missing_zero(char *, char **);

%}

D   [0-9]
H   [a-fA-F0-9]
HP  (0[xX])
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)

%%

{HP}{H}+{P}{FS}?			{wrap_floating_point_constants("hexadecimal", yytext, &yylval.id);  //Hexadecimal floating-point constants: will fail parser in ECLiPSe
                             return F_CONSTANT;
                            }
{HP}{H}*"."{H}+{P}{FS}?		{wrap_floating_point_constants("hexadecimal", yytext, &yylval.id);    //Hexadecimal floating-point constants with a fractional part.: will fail parser in ECLiPSe
                             return F_CONSTANT;
                            }
{HP}{H}+"."{P}{FS}?			{char* added_0;
                             add_missing_zero(yytext, &added_0);
                             wrap_floating_point_constants("hexadecimal", added_0, &yylval.id);   //Hexadecimal floating-point constants with digits before the decimal point, but none after. : will fail parser in ECLiPSe
                             return F_CONSTANT;
                            }
[ \t\n]+        { /* Ignore whitespace */ } // Ignore whitespace, tabs, and newlines
.               { yyerror("Unknown token!"); } // Call yyerror for unknown tokens

%%

void wrap_floating_point_constants(char * wrapper, char * input, char ** output) {
    int current = strlen(input)-1;
    int has_f = 0, has_l = 0, is_d = 0;
    int has_suffix = 1;
    switch (input[current]) {
        case 'f':
        case 'F':
            has_f = 1;
            break;
        case 'l':
        case 'L':
            has_l = 1;
            break;
        default:
            is_d = 1;
            has_suffix = 0;
    }
    if (has_suffix) current--;
    int has_wrapper = strcmp(wrapper, "");
    //calculating the length of the result: length of the wrapper + 2 parentheses + length of the prefix, the suffix, the parenthesis
    int size = (has_wrapper ? strlen(wrapper) + 2 : 0) + current+1 + 1 + is_d*strlen("double") + has_f*strlen("float") + has_l*strlen("long_double") + (has_f || has_l || is_d ? 2 : 0);
    *output = (char *)malloc(size);
    char format_string[100];
    if (has_wrapper) strcpy(format_string, "%s("); //starts with the floating point kind wrapper
    else strcpy(format_string, "");
    if (is_d)
        strcat(format_string, "double(%.*s)");      //double is the default type for floating points literals
    else if (has_f) 
        strcat(format_string, "float(%.*s)");
    else if (has_l) 
        strcat(format_string, "long_double(%.*s)");
    if (has_wrapper) {
        strcat(format_string, ")"); //adds the wrapper end parenthesis
        snprintf(*output, size, format_string, wrapper, current + 1, input);
    } else {
        snprintf(*output, size, format_string, current + 1, input);
    }
}

//float has no digit after decimal point: need to add 0
void add_missing_zero(char * input, char ** output) {
    size_t len = strlen(input);
    *output = (char*)malloc(len + 1 + 1); // +1 for extra '0'
    strcpy(*output, input);
    char* decimal_point = strchr(*output, '.');
    char* suffix = strpbrk(decimal_point, "eElL"); //returns pointer to first occurrence of character
    if (suffix == NULL) {// No suffix, so it's the end of the string
        suffix = *output + strlen(*output);
    }
    size_t decimal_pos = decimal_point - *output;
    memmove(decimal_point + 2, decimal_point + 1, len - decimal_pos); //copy everything after the decimal point to +1 location
    (*output)[decimal_pos + 1] = '0';    //add the 'missing' 0
}