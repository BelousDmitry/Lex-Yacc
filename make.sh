clear
rm -i *.c *.h *.o
flex -o chaffee.yy.c chaffee.l
bison -d chaffee.y
gcc chaffee.tab.c chaffee.yy.c -lm -o chaffee.exe

