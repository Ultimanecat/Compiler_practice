%{
    #include <stdio.h>
    #include <string>
    #include "test.tab.hpp"
    int rulebracket=0;
    int classbracket=0;
    bool inclass=false;
%}
%option yylineno
%option noyywrap

%x  COMMENT
%x  MULTICOMMENT
%x  RULEARG
%x  RULECODE
%x  CLASSDEF
%x  CLASSCODE

Letter      [A-Za-z]
Digit       [0-9]

Word        {Letter}+
Number      {Digit}+
Variant         {Letter}({Letter}|{Digit}|_)*
Space       [ \r\n\t]
WHENEVER    "whenever"

%%
{WHENEVER}      {
                    BEGIN RULEARG;
                    return KW_WHENEVER;
                }
"class"{Space}* {
                    BEGIN CLASSDEF;
                    return KW_CLASS;
                }
<CLASSDEF>{Variant} {
                    yylval.Variant.Name = new std::string(yytext);
                    //printf("VARIANT | %s\n", yytext);
                    return VARIANT;
                    }

<CLASSDEF>"{" {
    classbracket=1;
    BEGIN CLASSCODE;
    inclass=true;
    return yytext[0];
}
<CLASSDEF>. {return yytext[0];}    
<CLASSCODE>"{"  {
    classbracket++;
    return yytext[0];
}      
<CLASSCODE>"}"  {
    classbracket--;
    if(classbracket==0)
        BEGIN INITIAL;
    return yytext[0];
}
<CLASSCODE>{WHENEVER}
{
    BEGIN RULEARG;
    return KW_WHENEVER;
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
                    if(!inclass)
                            BEGIN INITIAL;
                        else
                            BEGIN CLASSCODE;
                }
"/*"            {
                    BEGIN MULTICOMMENT;
                }
<MULTICOMMENT>. {   /* just ignore in comment */ }
<MULTICOMMENT>"*/" {
                        if(!inclass)
                            BEGIN INITIAL;
                        else
                            BEGIN CLASSCODE;
                    }               

<RULEARG>{Variant}       {
                    yylval.Variant.Name = new std::string(yytext);
                    //printf("VARIANT | %s\n", yytext);
                    return VARIANT;
                }


<RULEARG>"{"     {
    BEGIN RULECODE;
    rulebracket=1;
    return yytext[0];
}
<RULEARG>.      {return yytext[0];}
<RULECODE>"{" {
    rulebracket++;
    return yytext[0];
}
<RULECODE>"}"       {
                    rulebracket--;
                    if(rulebracket==0){
                        if(!inclass)
                            BEGIN INITIAL;
                        else
                            BEGIN CLASSCODE;
                    }
                    return yytext[0];
                }
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
