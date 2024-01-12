# Creating an interpreted language using Lex & Yacc



## if
```
D:\chaffee-language>chaffee.exe
i = 10;
j = 20;
if i < j { print "i is less"; end_if;}
i is less

```
## while

```
D:\chaffee-language>chaffee.exe
i = 0;
j = 10;
while i < j { i = i + 2; print i; end_while;}
2
4
6
8
10

```

## Functions
Functions use “global” variables and do not have parameters. You must initialize/change the variable before calling the function to see the necessary result.
```
D:\chaffee-language>chaffee.exe
func (double) { i = i * 2; end_func; }
i = 10;
call (double);
print i;
20
call (double);
print i;       
40

```
