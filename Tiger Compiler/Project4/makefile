#a.out: parsetest.o y.tab.o lex.yy.o errormsg.o util.o
#	cc -g parsetest.o y.tab.o lex.yy.o errormsg.o util.o

#parsetest.o: parsetest.c errormsg.h util.h
#	cc -g -c parsetest.c

a.out:  y.tab.o lex.yy.o errormsg.o absyn.o prabsyn.o symbol.o parse.o table.o util.o semant.o types.o temp.o frame.o translate.o tree.o printtree.o canon.o assem.o codegen.o env.o
	cc -g y.tab.o lex.yy.o errormsg.o absyn.o prabsyn.o symbol.o parse.o table.o util.o semant.o types.o temp.o frame.o translate.o tree.o printtree.o canon.o assem.o codegen.o env.o

codegen.o: codegen.c codegen.h
	cc -Wall -g -c codegen.c

env.o: env.c env.h
	cc -Wall -g -c env.c

assem.o: assem.c assem.h
	cc -Wall -g -c assem.c

canon.o:canon.c canon.h
	cc -Wall -g -c canon.c

tree.o : tree.c tree.h
	cc -Wall -g -c tree.c

printtree.o:printtree.c printtree.h
	cc -Wall -g -c printtree.c
	
frame.o:frame.c frame.h
	cc -Wall -g -c frame.c

translate.o:translate.c translate.h
	cc -Wall -g -c translate.c

temp.o:temp.c temp.h
	cc -Wall -g -c temp.c

semant.o:semant.c semant.h
	cc -Wall -g -c semant.c

types.o: types.c types.h
	cc -Wall -g -c types.c

absyn.o: absyn.c absyn.h util.h symbol.h
	cc -Wall -g -c absyn.c

prabsyn.o : prabsyn.c prabsyn.h absyn.h util.h symbol.h
	cc -Wall -g -c prabsyn.c 

symbol.o : symbol.c symbol.h util.h table.h
	cc -Wall -g -c symbol.c 

parse.o : parse.c parse.h util.h symbol.h errormsg.h absyn.h
	cc -Wall -g -c parse.c 

table.o : table.c table.h util.h
	cc -Wall -g -c table.c
 
y.tab.o: y.tab.c
	cc -Wall -g -c y.tab.c

y.tab.c: tiger.grm
	yacc -dv tiger.grm

y.tab.h: y.tab.c
	echo "y.tab.h was created at the same time as y.tab.c"

errormsg.o: errormsg.c errormsg.h util.h
	cc -g -c errormsg.c

lex.yy.o: lex.yy.c y.tab.h errormsg.h util.h
	cc -g -c lex.yy.c

#lex.yy.c: tiger.lex
#	lex tiger.lex

util.o: util.c util.h
	cc -Wall -g -c util.c

clean: 
#	rm -f a.out util.o parsetest.o lex.yy.o errormsg.o y.tab.c y.tab.h y.tab.o
	rm -f a.out  y.tab.o lex.yy.o errormsg.o absyn.o prabsyn.o symbol.o parse.o table.o util.o semant.o types.o y.tab.c y.tab.h temp.o frame.o translate.o  tree.o printtree.o canon.o assem.o codegen.o env.o
