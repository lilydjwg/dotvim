
LEX = flex -I
#cc = gcc -DYYDEBUG=1
CC = gcc -DYYDEBUG=1

dll	:
	#flex tipswnd.lex
	$(CC) -o ../plugin/vjde/tipswnd.dll -shared lex.yy.c -DDLL -lcomctl32 -lgdi32 -mwindows
	$(CC) -o ../plugin/vjde/readtags -DREADTAGS_MAIN readtags.c -mwindows
	g++ -o ../plugin/vjde/wspawn wspawn.cpp -mwindows

tipswnd	:build/lex.yy.o
	$(CC)   -o tipswnd build/lex.yy.o -luser32 -lcomctl32 -lgdi32 -mwindows


build/%.o	:%.c
	$(CC) -c -o build/$(*F).o $<

lex.yy.c	:tipswnd.lex
	flex tipswnd.lex

clean	:
	rm -rf build/*.o
	rm lex.yy.c

