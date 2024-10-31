/* fb2-3 skeleton for include files */
%option noyywrap yylineno
%x IFILE

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct bufstack {
    struct bufstack *prev;      /* previous entry */
    YY_BUFFER_STATE bs;         /* saved buffer */
    int lineno;                 /* saved line number */
    char *filename;             /* name of this file */
    FILE *f;                    /* current file */
} *curbs = 0;

char *curfilename;              /* name of current input file */

int newfile(char *fn);
int popfile(void);
%}

%%
   /* Match #include statement up through the quote or < */
^"#"[ \t]*include[ \t]*[\"<]  { BEGIN IFILE; }

   /* Handle filename up to the closing quote, >, or end of line */
<IFILE>[^ \t\n\">]+            { 
                                 int c;
                                 while((c = input()) && c != '\n');
                                 yylineno++;
                                 if(!newfile(yytext)) {
                                   yyterminate(); /* no such file */
                                 }
                                 BEGIN INITIAL;
                               }

   /* Handle bad input in IFILE state */
<IFILE>.|\n                    { 
                                 fprintf(stderr, "%4d: bad include line\n", yylineno);
                                 yyterminate();
                               }

   /* Pop the file stack at end of file, terminate if it's the outermost file */
<<EOF>>                        { if(!popfile()) yyterminate(); }

   /* Print the line number at the beginning of each line */
^.                              { fprintf(yyout, "%4d %s", yylineno, yytext); }
^\n                             { fprintf(yyout, "%4d\n", yylineno++); }
\n                              { ECHO; yylineno++; }
.                               { ECHO; }

%%

int main(int argc, char **argv)
{
    if(argc < 2) {
        fprintf(stderr, "Need filename\n");
        return 1;
    }
    if(newfile(argv[1])) {
        yylex();
    }
    return 0;
}

int newfile(char *fn)
{
    FILE *f = fopen(fn, "r");
    struct bufstack *bs = malloc(sizeof(struct bufstack));

    /* Die if no file or no room */
    if(!f) {
        perror(fn);
        return 0;
    }
    if(!bs) {
        perror("malloc");
        exit(1);
    }

    /* Remember state */
    if(curbs) curbs->lineno = yylineno;
    bs->prev = curbs;

    /* Set up current entry */
    bs->bs = yy_create_buffer(f, YY_BUF_SIZE);
    bs->f = f;
    bs->filename = strdup(fn);
    yy_switch_to_buffer(bs->bs);
    curbs = bs;
    yylineno = 1;
    curfilename = bs->filename;
    return 1;
}

int popfile(void)
{
    struct bufstack *bs = curbs;
    struct bufstack *prevbs;

    if(!bs) return 0;

    /* Get rid of current entry */
    fclose(bs->f);
    free(bs->filename);
    yy_delete_buffer(bs->bs);

    /* Switch back to previous */
    prevbs = bs->prev;
    free(bs);

    if(!prevbs) return 0;

    yy_switch_to_buffer(prevbs->bs);
    curbs = prevbs;
    yylineno = curbs->lineno;
    curfilename = curbs->filename;
    return 1;
}
