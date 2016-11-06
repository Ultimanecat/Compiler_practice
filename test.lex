%{
    #include <stdio.h>
    #include <string>
    int rulecnt = 0;
    #include "test.tab.hpp"
%}
%option yylineno
%option noyywrap

%x  COMMENT
%x  RULEARG
%x  RULECODE

Letter      [A-Za-z]
Digit       [0-9]

Word        {Letter}+
Number      {Digit}+
Variant         {Letter}({Letter}|{Digit}|_)*
Space       [ \r\n\t]
WHENEVER    "whenever"

%%
{WHENEVER}"("     {
                    BEGIN RULEARG;
                    rulecnt++;
                    //todo:return rulecnt?
                }

"//"            {
                    //printf("Comment|\n");
                    BEGIN COMMENT;
                }

.               {
                    // Unknown token
                    //printf("Unknown| %s\n", yytext);
                    return yytext[0];
                }
                
<COMMENT>\\\n   {   /* comment continues */ }
<COMMENT>.      {   /* just ignore in comment */ }
<COMMENT>\n     {
                    BEGIN INITIAL; 
                }

<RULEARG>{Variant}       {
                    yylval.Variant.Name = new std::string(yytext);
                    //printf("VARIANT | %s\n", yytext);
                    return VARIANT;
                }
<RULEARG>,      {/*ignore*/}

<RULEARG>")"{Space}*"{"     {BEGIN RULECODE;}
<RULECODE>"}"   {BEGIN INITIAL;}
<RULECODE>.     {return yytext[0];}

%%


/*int main() 
{
    printf("======== Start ========\n");

    yylex();

    printf("======== Done ========\n");
    return 0;
}

int yywrap() 
{
    return 1;
}*/
