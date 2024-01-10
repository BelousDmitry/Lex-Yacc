%{
#include "chaffee.tab.h"
#include <stdlib.h>
#include <string.h>

%}

%%
[ \t\n\r]       {}
[0-9]+          yylval = atoi( yytext ); return NUM;
print           return PRINT;
input           return INPUT;
func            return FUNC;
end_func        return END_FUNC;
call            return CALL;
if              return IF;
else            return ELSE;
while           return WHILE;
end_while       return END_WHILE;
end_if          return END_IF;
[a-z]           yylval = (int) yytext[0]; return VAR;
"("[a-zA-Z]*")"       yylval = removeQuotes(yytext); return TITLE;
"\"".*"\""      yylval = removeQuotes(yytext); return STRING;
.               return (int) yytext[0];
%%

int yywrap(void)
{
  return 1;
}


int removeQuotes(char* str) {
  char *result = str+1; // removes first character
  result[strlen(result)-1] = '\0'; // removes last character
  return (int)result;
}