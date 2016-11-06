%{
    #include <iostream>
    #include <string>
    #include <map>
    std::map<std::string, int> _vars;

    void yyerror(const char* s);

    // extern from lex
    extern int yylex(void);
    extern "C" int yylineno;
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
}

%token <String>  STRING
%token <Number>  NUMBER
%token <Variant> VARIANT
%token KW_VAR
%token KW_PRINT

%type  <Number>  expr

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
            | /* empty */
            ;

statement   : KW_VAR VARIANT '=' expr       { _vars[*$2.Name] = $4.Value; }
            | printcall
            | expr
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

int main() 
{ 
    yyparse(); 
    return 0; 
}
