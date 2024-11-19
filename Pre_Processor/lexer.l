%{

#ifdef _MSC_VER
    #define strdup_safe(char_ptr) _strdup(char_ptr)
#else
    #define strdup_safe(char_ptr) strdup(char_ptr)
#endif

#include <stdio.h>  
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <ctype.h>
#include "parser.tab.h"

extern long int TARGET_LONG_MAX;

char *yytext;

void read_comment();
int differentiate_identifiers(char *);
void wrap_integer_constants(char *, char *, char **);
void wrap_floating_point_constants(char *, char *, char **);
void add_missing_zero(char *, char **);
  

%}

O   [0-7]
D   [0-9]
NZ  [1-9]
H   [a-fA-F0-9]
HP  (0[xX])
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
CP  (u|U|L)
WS  [ \t\v\n\f]
E   ([Ee][+-]?{D}+)


%%

{HP}{H}+{IS}?				{printf("Processing1: %s\n", yytext);
                             wrap_integer_constants("16'", &yytext[2], &yylval.id);     //hexadecimal integer
                             return I_CONSTANT;
                            }
{NZ}{D}*{IS}?				{printf("Processing2: %s\n", yytext);
                             wrap_integer_constants("", yytext, &yylval.id);            //decimal integer
                             return I_CONSTANT;
                            }
                            
"0"{O}*{IS}?				{printf("Processing3: %s\n", yytext);
                             if (isdigit(yytext[1])) wrap_integer_constants("8'", &yytext[1], &yylval.id);  //octal integer 
                             else { //the second char after 0 is not a digit (it's /0, ofr an IS (u|U)(l|L|ll|LL) char), so it's just the constant 0, rather than a true octal 
                                yylval.id = (char*)malloc(7);
                                strcpy(yylval.id, "int(0)");    
                             }
                             return I_CONSTANT;
                            }
{CP}?"'"([^'\\\n]|{ES})+"'"	{
                             printf("Processing4: %s\n", yytext);
                             yylval.id = strdup_safe(yytext); return I_CONSTANT;}   //single characters

{D}+{E}{FS}?				{   printf("Processing1: %s\n", yytext);
                                wrap_floating_point_constants("", yytext, &yylval.id);     //Decimal floating-point constants with an exponent.
                                return F_CONSTANT;
                            }
{D}*"."{D}+{E}?{FS}?		{   printf("Processing2: %s\n", yytext);
                                wrap_floating_point_constants("", yytext, &yylval.id);     //Decimal floating-point constants with a fractional part.
                                return F_CONSTANT;
                            }                           
{D}+"."{E}?{FS}?			{   printf("Processing3: %s\n", yytext);
                                char* added_0;
                                add_missing_zero(yytext, &added_0);
                                wrap_floating_point_constants("", added_0, &yylval.id);         //Decimal floating-point constants with a fractional part.
                                return F_CONSTANT;
                            }
{HP}{H}+{P}{FS}?			{   printf("Processing4: %s\n", yytext);
                                wrap_floating_point_constants("hexadecimal", yytext, &yylval.id);  //Hexadecimal floating-point constants: will fail parser in ECLiPSe
                                return F_CONSTANT;
                            }
{HP}{H}*"."{H}+{P}{FS}?		{   printf("Processing5: %s\n", yytext);
                                wrap_floating_point_constants("hexadecimal", yytext, &yylval.id);    //Hexadecimal floating-point constants with a fractional part.: will fail parser in ECLiPSe
                                return F_CONSTANT;
                            }
{HP}{H}+"."{P}{FS}?			{   printf("Processing6: %s\n", yytext);
                                char* added_0;
                                add_missing_zero(yytext, &added_0);
                                wrap_floating_point_constants("hexadecimal", added_0, &yylval.id);   //Hexadecimal floating-point constants with digits before the decimal point, but none after. : will fail parser in ECLiPSe
                                return F_CONSTANT;
                            }
{WS}+				        { /* whitespaces (including new lines) separate tokens */ }

"-"					        { return '-'; }
.                           {  } 
%%



void read_comment() {
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
}

//add hexademical or octal wrapper and handle u|l|ll variations
void wrap_integer_constants(char *wrapper, char *input, char **output) {
    int current = strlen(input)-1;
    int has_u = 0, has_l = 0, has_ll = 0;
    int has_suffix = 1;

    while (has_suffix && current >= 0) {    //start from the end and move back until non u|U|l|L character is met
        switch (input[current]) {
            case 'u':
            case 'U':
                has_u = 1;
                break;
            case 'l':
            case 'L':
                if (current >0 && (input[current-1] == 'l' || input[current-1] == 'L')) {
                    has_ll = 1;
                    current--;  //skip the other 'l' or 'LL'
                }
                else has_l = 1;
                break;
            default:
                has_suffix = 0;  
        }
        if (has_suffix) current--;
    }
    int has_wrapper = strcmp(wrapper, "");
    //calculating the length of the result: length of the wrapper + length of the prefix, the suffix, the underscore, the parenthesis
    int size = strlen(wrapper) + current+1 + 1 + has_u*strlen("unsigned") + has_l*strlen("long") + has_ll*strlen("long_long") + has_u*has_l + has_u*has_ll + (has_u || has_l || has_ll ? 2 : 0);

    char format_string[100];
    strcpy(format_string, "");

    if (!has_u && !has_l && !has_ll) {              //has no suffix, type depends on value
        unsigned long constant = strtoul(input, NULL, 0);         //the 0 enables automatic detection of base: decimal, octal or hexadecimal
        if (constant <= INT_MAX) {
            strcat(format_string, "int(");
            size += strlen("int()");
        } else if (has_wrapper && constant <= UINT_MAX) {   //different rule for octals and hexademcimals
            strcat(format_string, "unsigned(");
            size += strlen("unsigned()");
        }
         else if (constant <= TARGET_LONG_MAX) {          //don't use LONG_MAX, values dependents on the target memory model size (32 vs 64 bits) of the program under test, not of the compiler used to generate the parser
            strcat(format_string, "long(");
            size += strlen("long()");
        } else {
            strcat(format_string, "unsigned_long(");   //todo check how long long constants without suffix are handled in gcc/ansi C currently set as unsigned long which is big enough
            size += strlen("unsigned_long()");
        }   
    }
    else if (has_u && !has_l && !has_ll) 
        strcat(format_string, "unsigned(");
    else if (has_u && has_l && !has_ll) 
        strcat(format_string, "unsigned_long(");
    else if (has_u && !has_l && has_ll) 
        strcat(format_string, "unsigned_long_long(");
    else if (!has_u && has_l && !has_ll) 
        strcat(format_string, "long(");
    else if (!has_u && !has_l && has_ll) 
        strcat(format_string, "long_long(");

    if (has_wrapper) strcat(format_string, "%s");
    
    strcat(format_string, "%.*s)");

    *output = (char *)malloc(size);
    if (has_wrapper) {
        snprintf(*output, size, format_string, wrapper, current + 1, input);
    } else {
        snprintf(*output, size, format_string, current + 1, input);
    }
}

//add hexademical wrapper if present and handle f|F|l|L variations
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