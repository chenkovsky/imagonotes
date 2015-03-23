/*
 * parse.c - Parse source file.
 */

#include <stdio.h>
#include <stdlib.h>
#include "util.h"
#include "symbol.h"
#include "absyn.h"
#include "errormsg.h"
#include "parse.h"
#include "prabsyn.h"
#include "types.h"
#include "temp.h"
#include "tree.h"
#include "frame.h"
#include "canon.h"
#include "assem.h"
#include "codegen.h"
#include "translate.h"
#include "semant.h"

extern int yyparse(void);
extern A_exp absyn_root;
extern F_frame globalCurrentFrame;

/* parse source file fname; 
   return abstract syntax data structure */
A_exp parse(string fname) 
{
	EM_reset(fname);
	if (yyparse() == 0) /* parsing worked */
		return absyn_root;
	else return NULL;
}

int main(int argc, char **argv) {
	if (argc < 2) 
	{
		fprintf(stderr,"usage: a.out filename\n"); 
		exit(1);
	}
	char* filename = "output.s";
	if(argc == 3){
	  filename = argv[2];
	}
	F_fragList fgl = SEM_transProg(parse(argv[1]));
	string funcName;
	FILE * outfile = fopen("output","w");
	FILE * outfile1 = fopen(filename,"w");
	fprintf(outfile1, "\t.file \"%s\"\n", argv[1]);
	fprintf(outfile1, "\t.text");

	for(;fgl;fgl=fgl->tail)
	{
		if(fgl->head->kind == F_progFrag)
		{
			globalCurrentFrame = fgl->head->u.proc.frame;
			T_stmList stmlist = C_linearize(fgl->head->u.proc.body);
			stmlist = C_traceSchedule(C_basicBlocks(stmlist));
			printStmList(outfile,stmlist);
			AS_instrList iList = F_codegen(fgl->head->u.proc.frame, stmlist);
			if(globalCurrentFrame == Tr_outermost()->frame){
   	   			funcName = "tigermain";
			}
			else{
				 funcName = Temp_labelstring(F_name(globalCurrentFrame));
			}
			fprintf(outfile1, "\n.globl\t%s", funcName);
			fprintf(outfile1, "\n%s:\n", funcName);
			//fprintf(outfile1,"\tpushl\t%%ebp\n");
			//fprintf(outfile1,"\tmovl\t%%esp\t%%ebp\n");

			//fprintf(outfile1,"\tpushl\t%%ebx\n");
			//fprintf(outfile1,"\tpushl\t%%ecx\n");
			//fprintf(outfile1,"\tpushl\t%%edx\n");
			//fprintf(outfile1,"\tpushl\t%%esi\n");
			//fprintf(outfile1,"\tpushl\t%%edi\n\n");
			AS_printInstrList(outfile1,  iList);
			//fprintf(outfile1,"\tpopl\t%%edi\n");
			//fprintf(outfile1,"\tpopl\t%%esi\n");
			//fprintf(outfile1,"\tpopl\t%%edx\n");
			//fprintf(outfile1,"\tpopl\t%%ecx\n");
			//fprintf(outfile1,"\tpopl\t%%ebx\n\n");
			//fprintf(outfile1,"\tleave\n");
			//fprintf(outfile1,"\tret\n\n");
		}
		else if(fgl->head->kind == F_stringFrag)
		{
			fprintf(outfile,"%s\n",fgl->head->u.stringg.str);
			fprintf(outfile1, "\n%s:\n\t.string \"%s\\0\"\n", Temp_labelstring(fgl->head->u.stringg.label), fgl->head->u.stringg.str);
		}
	}
	fclose(outfile);
	fclose(outfile1);
	return 0;
}


