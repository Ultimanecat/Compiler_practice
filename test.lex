%{
    #include <stdio.h>
    #include <string>
    #include "test.tab.h"
%}
%option yylineno

%x  COMMENT
%x  MULTICOMMENT
%x  CLASSDEF

Letter      [A-Za-z]
Digit       [0-9]

Word        {Letter}+
Number      {Digit}+
Variant         {Letter}({Letter}|{Digit}|_)*
Space       [ \r\n\t]
WHENEVER    whenever

%%
\"[^"]*\"       {
                    std::string tmp = yytext;
                    yylval.String.Value = new std::string(tmp.substr(1, yyleng - 2));
                    printf(" STRING | %s\n", yytext);
                    return STRING;
                }
"int"|"char"|"float"|"double"|"long"    {
                    yylval.Type.Typename = new std::string(yytext);
                    printf("Type | %s\n", yytext);
                    return TYPE;
}

{Number}        {
                    yylval.Number.Value = atoi(yytext);
                    printf(" NUMBER | %s\n", yytext);
                    return NUMBER;
                }
{WHENEVER}      {
                    printf(" WHENEVER | %s\n", yytext);
                    return KW_WHENEVER;
                }
{Variant}       {
                    yylval.Variant.Name = new std::string(yytext);
                    printf("VARIANT | %s\n", yytext);
                    return VARIANT;
                }

"class"{Space}* {
                    BEGIN CLASSDEF;
                    return KW_CLASS;
                }
<CLASSDEF>{Variant} {
                    yylval.Classname.Name = new std::string(yytext);
                    printf("CLASSNAME | %s\n", yytext);
                    BEGIN INITIAL;
                    return CLASSNAME;
                    }

<CLASSDEF>. {return yytext[0];}    

"//"            {
                    //printf("Comment|\n");
                    BEGIN COMMENT;
                }
               
<COMMENT>\\\n   {   /* comment continues */ }
<COMMENT>.      {   /* just ignore in comment */ }
<COMMENT>\n     {
                    BEGIN INITIAL;
                }
"/*"            {
                    BEGIN MULTICOMMENT;
                }
<MULTICOMMENT>. {   /* just ignore in comment */ }
<MULTICOMMENT>"*/"  {
                        BEGIN INITIAL;
                    }
{Space}*        {/*ignore*/}       
.               {
                    // Unknown token
                    //printf("Unknown| %s\n", yytext);
                    ECHO;
                    return yytext[0];
                }
%%


/*int main() 
{
    printf("======== Start ========\n");
    yylex();

    printf("======== Done ========\n");
    return 0;
}*/

int yywrap() 
{
    return 1;
}