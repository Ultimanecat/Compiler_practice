build: test

test: test.yy.cpp test.tab.cpp
	g++ -o test test.yy.cpp test.tab.cpp
test.tab.cpp: test.y
	yacc -o test.tab.cpp -d test.y
test.yy.cpp: test.lex
	lex -o test.yy.cpp test.lex

clean:
	rm *.cpp *.hpp
rebuild: clean build

