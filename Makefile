build: test

test: test.yy.c test.tab.c
	g++ -o test test.yy.c test.tab.c
test.tab.c: test.y
	yacc -o test.tab.c -d test.y
test.yy.c: test.lex
	lex -o test.yy.c test.lex

clean:
	rm *.c *.h
rebuild: clean build

