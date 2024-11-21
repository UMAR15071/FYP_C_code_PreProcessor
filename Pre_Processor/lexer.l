%e	number of parsed tree nodes
%p	number of positions
%n	number of states
%k	number of packed character classes
%a	number of transitions
%o	size of output array

%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{
#include <stdio.h>
#include "parser.tab.h"

extern void yyerror(const char *);  /* prints grammar violation message */

extern int sym_type(const char *);  /* returns type from symbol table */

#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

static void comment(void);
static int check_type(void);
%}

%%
"/*"                                    { comment(); }
"//".*                                    { /* consume //-comment */ }

"auto"					{ return(AUTO); }
"break"					{ return(BREAK); }
"case"					{ return(CASE); }
"char"					{ return(CHAR); }
"const"					{ return(CONST); }
"continue"				{ return(CONTINUE); }
"default"				{ return(DEFAULT); }
"do"					{ return(DO); }
"double"				{ return(DOUBLE); }
"else"					{ return(ELSE); }
"enum"					{ return(ENUM); }
"extern"				{ return(EXTERN); }
"float"					{ return(FLOAT); }
"for"					{ return(FOR); }
"goto"					{ return(GOTO); }
"if"					{ return(IF); }
"inline"				{ return(INLINE); }
"int"					{ return(INT); }
"long"					{ return(LONG); }
"register"				{ return(REGISTER); }
"restrict"				{ return(RESTRICT); }
"return"				{ return(RETURN); }
"short"					{ return(SHORT); }
"signed"				{ return(SIGNED); }
"sizeof"				{ return(SIZEOF); }
"static"				{ return(STATIC); }
"struct"				{ return(STRUCT); }
"switch"				{ return(SWITCH); }
"typedef"				{ return(TYPEDEF); }
"union"					{ return(UNION); }
"unsigned"				{ return(UNSIGNED); }
"void"					{ return(VOID); }
"volatile"				{ return(VOLATILE); }
"while"					{ return(WHILE); }
"_Alignas"                              { return ALIGNAS; }
"_Alignof"                              { return ALIGNOF; }
"_Atomic"                               { return ATOMIC; }
"_Bool"                                 { return BOOL; }
"_Complex"                              { return COMPLEX; }
"_Generic"                              { return GENERIC; }
"_Imaginary"                            { return IMAGINARY; }
"_Noreturn"                             { return NORETURN; }
"_Static_assert"                        { return STATIC_ASSERT; }
"_Thread_local"                         { return THREAD_LOCAL; }
"__func__"                              { return FUNC_NAME; }

{L}{A}*					{ return check_type(); }


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

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ return STRING_LITERAL; }

"..."					{ return ELLIPSIS; }
">>="					{ return RIGHT_ASSIGN; }
"<<="					{ return LEFT_ASSIGN; }
"+="					{ return ADD_ASSIGN; }
"-="					{ return SUB_ASSIGN; }
"*="					{ return MUL_ASSIGN; }
"/="					{ return DIV_ASSIGN; }
"%="					{ return MOD_ASSIGN; }
"&="					{ return AND_ASSIGN; }
"^="					{ return XOR_ASSIGN; }
"|="					{ return OR_ASSIGN; }
">>"					{ return RIGHT_OP; }
"<<"					{ return LEFT_OP; }
"++"					{ return INC_OP; }
"--"					{ return DEC_OP; }
"->"					{ return PTR_OP; }
"&&"					{ return AND_OP; }
"||"					{ return OR_OP; }
"<="					{ return LE_OP; }
">="					{ return GE_OP; }
"=="					{ return EQ_OP; }
"!="					{ return NE_OP; }
";"					{ return ';'; }
("{"|"<%")				{ return '{'; }
("}"|"%>")				{ return '}'; }
","					{ return ','; }
":"					{ return ':'; }
"="					{ return '='; }
"("					{ return '('; }
")"					{ return ')'; }
("["|"<:")				{ return '['; }
("]"|":>")				{ return ']'; }
"."					{ return '.'; }
"&"					{ return '&'; }
"!"					{ return '!'; }
"~"					{ return '~'; }
"-"					{ return '-'; }
"+"					{ return '+'; }
"*"					{ return '*'; }
"/"					{ return '/'; }
"%"					{ return '%'; }
"<"					{ return '<'; }
">"					{ return '>'; }
"^"					{ return '^'; }
"|"					{ return '|'; }
"?"					{ return '?'; }

{WS}+					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

static void comment(void)
{
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
    yyerror("unterminated comment");
}

static int check_type(void)
{
    switch (sym_type(yytext))
    {
    case TYPEDEF_NAME:                /* previously defined */
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        /* previously defined */
        return ENUMERATION_CONSTANT;
    default:                          /* includes undefined */
        return IDENTIFIER;
    }
}

