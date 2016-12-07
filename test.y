%{
    #include <iostream>
    #include <stdio.h>
    #include <string>
    #include <map>
    #include <unistd.h>
    std::map<std::string, int> _vars;

    void yyerror(const char* s);

    // extern from lex
    extern int yylex(void);
    extern "C" int yylineno;
    FILE* dict=NULL;//output rule-var table to this file  
%}

%union {
    struct {
        std::string* Value;
    } String;
    struct {
        int Value;
    } Number;
    struct {
        std::string* Name;
    } Variant;
    struct {
        std::string* Name;
    } Classname;
    struct {
        std::string* Typename;
    } Type;
}

%token <String>  STRING
%token <Number>  NUMBER
%token <Variant> VARIANT
%token <Classname> CLASSNAME
%token <Type> TYPE
%token KW_VAR
%token KW_NEW
%token KW_PRINT
%token KW_WHENEVER
%token KW_CLASS

%type  <Number>  expr
%type  <Myvar> dotvar

%right '=' OP_ADDEQ OP_SUBEQ OP_MULEQ OP_DIVEQ OP_MODEQ
%right '?' ':'
%left  OP_EQ OP_NEQ
%left  '>' '<' OP_GE OP_LE
%left  '+' '-'
%left  '*' '/' '%' 
%nonassoc OP_UMINUS
%right OP_ADDADD OP_SUBSUB
%nonassoc OP_SUF_ADDADD OP_SUF_SUBSUB

%start program

%%
program     : statement ';' program
            | classdef program
            | /* empty */
            ;

statement   : KW_VAR VARIANT '=' expr       { _vars[*$2.Name] = $4.Value; }
            | dotvar '=' KW_NEW TYPE '(' ')'
            | dotvar '=' dotvar
            | printcall
            | expr
            ;

dotvar      : VARIANT '.' dotvar
            | VARIANT
            ;


expr        : '-' expr                      %prec OP_UMINUS         { $$.Value = - $2.Value; }
            | VARIANT OP_ADDADD             %prec OP_SUF_ADDADD     { $$.Value = _vars[*$1.Name]++; }
            | VARIANT OP_SUBSUB             %prec OP_SUF_SUBSUB     { $$.Value = _vars[*$1.Name]--; }
            | OP_ADDADD VARIANT             { $$.Value = ++_vars[*$2.Name]; }
            | OP_SUBSUB VARIANT             { $$.Value = --_vars[*$2.Name]; }
            | expr '*' expr                 { $$.Value = $1.Value *  $3.Value; }
            | expr '/' expr                 { $$.Value = $1.Value /  $3.Value; }
            | expr '%' expr                 { $$.Value = $1.Value %  $3.Value; }
            | expr '+' expr                 { $$.Value = $1.Value +  $3.Value; }
            | expr '-' expr                 { $$.Value = $1.Value -  $3.Value; }
            | expr '>' expr                 { $$.Value = $1.Value >  $3.Value; }
            | expr '<' expr                 { $$.Value = $1.Value <  $3.Value; }
            | expr '?' expr ':' expr        { $$.Value = $1.Value ? $3.Value : $5.Value; }
            | expr OP_GE expr               { $$.Value = $1.Value >= $3.Value; }
            | expr OP_LE expr               { $$.Value = $1.Value <= $3.Value; }
            | expr OP_EQ expr               { $$.Value = $1.Value == $3.Value; }
            | expr OP_NEQ expr              { $$.Value = $1.Value != $3.Value; }
            | VARIANT '=' expr              { $$.Value = $3.Value; _vars[*$1.Name] = $3.Value; }
            | VARIANT OP_ADDEQ expr         { $$.Value = (_vars[*$1.Name] += $3.Value); }
            | VARIANT OP_SUBEQ expr         { $$.Value = (_vars[*$1.Name] -= $3.Value); }
            | VARIANT OP_MULEQ expr         { $$.Value = (_vars[*$1.Name] *= $3.Value); }
            | VARIANT OP_DIVEQ expr         { $$.Value = (_vars[*$1.Name] /= $3.Value); }
            | VARIANT OP_MODEQ expr         { $$.Value = (_vars[*$1.Name] %= $3.Value); }
            | '(' expr ')'                  { $$.Value = $2.Value; }
            | VARIANT                       { $$.Value = _vars[*$1.Name]; }
            | NUMBER                        { $$.Value = $1.Value; }
            ;

printcall   : KW_PRINT '(' printlist ')'    { std::cout << std::endl; }
            ;

printlist   : printarg
            | printarg ',' printlist
            | /* empty */
            ;

printarg    : expr                          { std::cout << $1.Value; }
            | STRING                        { std::cout << *$1.Value; }
            ;

%%
void yyerror(const char* s) 
{
    std::cerr << s << std::endl;
}

int main(int argc, char* argv[]) 
{ 
    int ch;
    opterr = 0;
    //while((ch = getopt(argc,argv,”o:d:”))!= -1)
    while((ch=getopt(argc,argv,"o:d:"))!=-1)
    switch(ch)
    {
        case 'o':
        freopen(optarg,"w",stdout);
        break;
        case 'd':
        dict=fopen(optarg,"wb");
        break;

    }
    yyparse(); 
    if(dict)fclose(dict);
    return 0; 
}
