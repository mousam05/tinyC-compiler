a.out: lex.yy.c y.tab.c y.tab.h ass6_14CS30019_translator.h ass6_14CS30019_translator.cxx ass6_14CS30019_target_translator.cxx libmyl.a
	g++ -std=c++11 lex.yy.c y.tab.c ass6_14CS30019_translator.cxx ass6_14CS30019_target_translator.cxx -lfl
	#"make t<number>" will compile and run individual test files

t1: a.out ass6_14CS30019_test1.c
	./a.out < ass6_14CS30019_test1.c  1
	gcc -c ass6_14CS30019_1.s
	gcc  ass6_14CS30019_1.o -L. -g -lmyl -o test1.out
	./test1.out

t2: a.out ass6_14CS30019_test2.c
	./a.out < ass6_14CS30019_test2.c 2
	gcc -c ass6_14CS30019_2.s
	gcc  ass6_14CS30019_2.o -L. -g -lmyl -o test2.out
	./test2.out

t3: a.out ass6_14CS30019_test3.c
	./a.out < ass6_14CS30019_test3.c 3
	gcc -c ass6_14CS30019_3.s
	gcc  ass6_14CS30019_3.o -L. -g -lmyl -o test3.out
	./test3.out

t4: a.out ass6_14CS30019_test4.c
	./a.out < ass6_14CS30019_test4.c 4
	gcc -c ass6_14CS30019_4.s
	gcc  ass6_14CS30019_4.o -L. -g -lmyl -o test4.out
	./test4.out


t5: a.out ass6_14CS30019_test5.c
	./a.out < ass6_14CS30019_test5.c 5
	gcc -c ass6_14CS30019_5.s
	gcc  ass6_14CS30019_5.o -L. -g -lmyl -o test5.out
	./test5.out
	
libmyl.a: myl.o
	ar -rcs libmyl.a myl.o

myl.o: myl.c myl.h
	gcc -Wall -c myl.c

y.tab.h: ass6_14CS30019.y
	yacc -dtv ass6_14CS30019.y

y.tab.c: ass6_14CS30019.y
	yacc -dtv ass6_14CS30019.y 

lex.yy.c: ass6_14CS30019.l y.tab.h
	flex ass6_14CS30019.l

clean: 
	rm *.s *.a *.out *.o y.tab.h y.tab.c lex.yy.c y.output



