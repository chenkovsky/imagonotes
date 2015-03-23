#include <stdio.h>
#include <string.h>
#include "util.h"
#include "symbol.h"
#include "temp.h"
#include "tree.h"
#include "frame.h"
#include "assem.h"
#include "codegen.h"

static char * itoa(int i)
{
    char * str = checked_malloc(10);

    sprintf(str, "%d", i);
    return str;
}

static char * getAssemOp(T_binOp binOp)
{
    switch(binOp){
    	   case T_plus:
    	   	   return "addl\t";
    	   case T_minus:
    	   	   return "subl\t";
    	   case T_mul:
    	   	   return "imull\t";
    	   case T_div:
    	   	   return "idivl\t";
	       case T_and:
	       case T_or:
	       case T_lshift:
	       case T_rshift:
	       case T_arshift:
	       case T_xor:
	       	   assert(0);
    }
}

/*****************************************************************
Get the jcc operation based on relational operator
*****************************************************************/
static char * getAssemJccOp(T_relOp relOp)
{
    switch(relOp){
    	   case T_eq:
    	   	   return "je\t";
    	   case T_ne:
    	   	   return "jne\t";
    	   case T_lt:
    	   	   return "jl\t";
    	   case T_gt:
    	   	   return "jg\t";
    	   case T_le:
    	   	   return "jle\t";
    	   case T_ge:
    	   	   return "jge\t";
    	   case T_ult:
    	   case T_ule:
    	   case T_ugt:
    	   case T_uge:
    	   	   assert(0);
    }
}

Temp_tempList L(Temp_temp h, Temp_tempList t) { return Temp_TempList(h, t);}

static int munchArgs(T_expList expList)
{
//    T_expList revExpList = NULL;
    int argNums = 0;

    //reverse the explist so that we can always push
    //the last argument onto the stack first
 /*   for(; expList != NULL; expList = expList->tail){
    	   revExpList = T_ExpList(expList->head, revExpList);
    }*/
    
    for(; expList != NULL; expList = expList->tail){
    	   Temp_temp r = munchExp(expList->head, 0);
    	   char * assem = "pushl\t `s0";

    	   emit(AS_Oper(assem, NULL, L(r, NULL), NULL));
    	   argNums ++;
    }
    return argNums;
}

static Temp_temp munchExp(T_exp e, int i)
{
  //fprintf(stderr, "\nbegin munch exp %d", e->kind);
	   switch(e->kind){
	   	   case T_BINOP:{
	   	   	   T_exp left = e->u.BINOP.left, right = e->u.BINOP.right;
			   if(e->u.BINOP.op == T_div){
	   	   	   	   char * assem1 = "movl\t`s0, `d0";
	   	   	   	   char * assem2 = getAssemOp(e->u.BINOP.op);
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);

                //because in x86, idivl divide EAX with the operand and result is stored in EAX, here it is just Temp_RV()
	   	   	   	   emit(AS_Oper(assem1, L(F_RV(), NULL), L(munchExp(left, i), NULL), NULL));
	   	   	   	   emit(AS_Oper(assem1, L(r, NULL), L(munchExp(right, i), NULL), NULL));

               		   emit(AS_Oper("cltd", NULL, NULL, NULL));
	   	   	   	   assem2 = sappend(assem2, "`s0");
	   	   	   	   emit(AS_Oper(assem2, NULL, L(r, NULL), NULL));
	   	   	   	   return F_RV();
	   	   	   }
	   	   	   //BINOP(binOp, TEMP(i), CONST(i))
	   	   	  else if(left->kind == T_TEMP
	   	   	   	   && right->kind == T_CONST){
	   	   	   	   char * assem1 = "movl\t`s0, `d0";
	   	   	   	   char * assem2 = getAssemOp(e->u.BINOP.op);
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);

                		   emit(AS_Oper(assem1, L(r, NULL), L(left->u.TEMP, NULL), NULL));
	   	   	   	   assem2 = sappend(assem2, "$");
	   	   	   	   assem2 = sappend(assem2, itoa(right->u.CONST));
	   	   	   	   assem2 = sappend(assem2, ", `d0");
	   	   	   	   emit(AS_Oper(assem2, L(r, NULL), NULL, NULL));
	   	   	   	   return r;
	   	   	   }
	   	   	   //BINOP(binOp, CONST(i), TEMP(i))
	   	   	   else if(left->kind == T_CONST
	   	   	   	   && right->kind == T_TEMP){
	   	   	   	   char * assem1 = "movl\t`s0, `d0";
	   	   	   	   char * assem2 = getAssemOp(e->u.BINOP.op);
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);

	   	   	   	   emit(AS_Oper(assem1, L(r, NULL), L(right->u.TEMP, NULL), NULL));
	   	   	   	   assem2 = sappend(assem2, "$");
	   	   	   	   assem2 = sappend(assem2, itoa(left->u.CONST));
	   	   	   	   assem2 = sappend(assem2, ", `d0");
	   	   	   	   emit(AS_Oper(assem2, L(r, NULL), NULL, NULL));
	   	   	   	   return r;
	   	   	   }
	   	   	   //BINOP(binOp, MEM(e1), CONST(i))
	   	   	   else if(left->kind == T_MEM
	   	   	   	   && right->kind == T_CONST){
	   	   	   	   char * assem1 = "movl\t(`s0), `d0";
	   	   	   	   char * assem2 = getAssemOp(e->u.BINOP.op);
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);

	   	   	   	   emit(AS_Oper(assem1, L(r, NULL), L(munchExp(left->u.MEM, i), NULL), NULL));
	   	   	   	   assem2 = sappend(assem2, "$");
	   	   	   	   assem2 = sappend(assem2, itoa(right->u.CONST));
	   	   	   	   assem2 = sappend(assem2, ", `d0");
	   	   	   	   emit(AS_Oper(assem2, L(r, NULL), NULL, NULL));
	   	   	   	   return r;
	   	   	   }
	   	   	   //BINOP(binOp, CONST(i), MEM(e1))
	   	   	   else if(left->kind == T_CONST
	   	   	   	   && right->kind == T_MEM){
	   	   	   	   char * assem1 = "movl\t(`s0), `d0";
	   	   	   	   char * assem2 = getAssemOp(e->u.BINOP.op);
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);

	   	   	   	   emit(AS_Oper(assem1, L(r, NULL), L(munchExp(right->u.MEM, i), NULL), NULL));
	   	   	   	   assem2 = sappend(assem2, "$");
	   	   	   	   assem2 = sappend(assem2, itoa(left->u.CONST));
	   	   	   	   assem2 = sappend(assem2, ", `d0");
	   	   	   	   emit(AS_Oper(assem2, L(r, NULL), NULL, NULL));
	   	   	   	   return r;
	   	   	   }
			   //BINOP(binOp, e1, e2)
	   	   	   else{
                      /* 	    char * assem1 = "movl\t `s0, `d0";
	   	   	   	   char * assem2 = getAssemOp(e->u.BINOP.op);
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);

	   	   	   	   emit(AS_Oper(assem1, L(r, NULL), L(munchExp(left, 0), NULL), NULL));
	   	   	   	   assem2 = sappend(assem2, " `s0, `d0");
	   	   	   	   emit(AS_Oper(assem2, L(r, NULL), L(munchExp(right,0), NULL), NULL));
	   	   	   	   return r;*/

				   //we must have a left recursive tree , or we can not do like this.
	   	   	          char * assem1 = "movl\t `s0, `d0";
			          Temp_temp r = F_AssemScratchTemp(i);
			          emit(AS_Oper(assem1, L(r, NULL), L(munchExp(left, i), NULL), NULL));
				   char * assem2 = "movl\t `s0, %esi";
				   emit(AS_Oper(assem2,NULL,L(r,NULL),NULL));
				   char * push ="pushl\t%esi";
				   emit(AS_Oper(push,NULL,NULL,NULL));
			          emit(AS_Oper(assem1,L(r, NULL),L(munchExp(right,i),NULL),NULL));
				   char * pop ="popl\t%esi";
				   emit(AS_Oper(pop,NULL,NULL,NULL));
				   char * assem3 = getAssemOp(e->u.BINOP.op);
				   assem3 = sappend(assem3," `s0, %esi");
				   emit(AS_Oper(assem3, NULL, L(r, NULL), NULL));
				   char * assem4 = "movl\t %esi, `d0";
				   emit(AS_Oper(assem4,L(r,NULL),NULL,NULL));
				   return r;
	   	   	   }
	   	   }
	   	   case T_MEM:{
	   	   	   T_exp me = e->u.MEM;
	   	   	   //MEM(BINOP(PLUS, e1, CONST(i)))
	   	   	   if(me->kind == T_BINOP
	   	   	   	   && me->u.BINOP.op == T_plus
	   	   	   	   && me->u.BINOP.right->kind == T_CONST){
	   	   	   	   T_exp e1 = me->u.BINOP.left;
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);
	   	   	   	   char * assem = "movl\t";

	   	   	   	   assem = sappend(assem, itoa(me->u.BINOP.right->u.CONST));
	   	   	   	   assem = sappend(assem, "(`s0), ");
	   	   	   	   assem = sappend(assem, "`d0");
	   	   	   	   emit(AS_Oper(assem, L(r, NULL), L(munchExp(e1, i), NULL), NULL));
	   	   	   	   return r;
	   	   	   }
	   	   	   //MEM(BINOP(PLUS, CONST(i), e1))
	   	   	   else if(me->kind == T_BINOP
	   	   	   	   && me->u.BINOP.op == T_plus
	   	   	   	   && me->u.BINOP.left->kind == T_CONST){
	   	   	   	   T_exp e1 = me->u.BINOP.right;
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);
	   	   	   	   char * assem = "movl\t";

	   	   	   	   assem = sappend(assem, itoa(me->u.BINOP.left->u.CONST));
	   	   	   	   assem = sappend(assem, "(`s0), ");
	   	   	   	   assem = sappend(assem, "`d0");
	   	   	   	   emit(AS_Oper(assem, L(r, NULL), L(munchExp(e1, i), NULL), NULL));
	   	   	   	   return r;
	   	   	   }
	   	   	   //MEM(CONST(i))
	   	   	   else if(me->kind == T_CONST){
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);
	   	   	   	   char * assem = "movl\t$";

	   	   	   	   assem = sappend(assem, itoa(me->u.CONST));
	   	   	   	   assem = sappend(assem, "`d0");
	   	   	   	   emit(AS_Oper(assem, L(r, NULL), NULL, NULL));
				   char * assem1 =  "movl\t(`s0), `d0";
				   emit(AS_Oper(assem1,L(r,NULL),L(r,NULL),NULL));
	   	   	   	   return r;
	   	   	   }
	   	   	   //MEM(e1)
	   	   	   else{
	   	   	   	   T_exp e1 = me;
	   	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   	   Temp_temp r = F_AssemScratchTemp(i);
	   	   	   	   char * assem = "movl\t(`s0), `d0";

	   	   	   	   emit(AS_Oper(assem, L(r, NULL), L(munchExp(me, i), NULL), NULL));
	   	   	   	   return r;
	   	   	   }
	   	   }
	   	   case T_TEMP:{
	   	   	   return e->u.TEMP;
	   	   }
	   	   case T_NAME:{
	   	   	   //NAME(LABEL)
	   	   	   //Temp_temp r = Temp_newtemp();
	   	   	   Temp_temp r = F_AssemScratchTemp(i);
	   	   	   char * assem = "movl\t$";

	   	   	   assem = sappend(assem, S_name(e->u.NAME));
	   	   	   assem = sappend(assem, ", `d0");
	   	   	   emit(AS_Oper(assem, L(r, NULL), NULL, NULL));
	   	   	   return r;
	   	   }
		      case T_CONST:{
		      	   //CONST(i)
		      	   //Temp_temp r = Temp_newtemp();
		      	   Temp_temp r = F_AssemScratchTemp(i);
		      	   char * assem = "movl\t$";

		      	   assem = sappend(assem, itoa(e->u.CONST));
		      	   assem = sappend(assem, ", `d0");
		      	   
		      	   emit(AS_Oper(assem, L(r, NULL), NULL, NULL));
		      	   return r;
		      }
		      case T_CALL:{
		      	   char * assem = "call\t";
		      	   int argNums = 0;
			   emit(AS_Oper("pushl\t%ecx", NULL, NULL, NULL));
			   emit(AS_Oper("pushl\t%edx", NULL, NULL, NULL));
            		   argNums = munchArgs(e->u.CALL.args);
		      	   assert(e->u.CALL.fun->kind == T_NAME);
		      	   assem = sappend(assem, S_name(e->u.CALL.fun->u.NAME));
		      	   emit(AS_Oper(assem, NULL, NULL, AS_Targets(Temp_LabelList(e->u.CALL.fun->u.NAME, NULL))));
            //clean up the stack of pushed arguments
		      	   if(argNums != 0){
		      	   	   assem = "addl\t$";
		      	   	   assem = sappend(assem, itoa(argNums * 4));
		      	   	   assem = sappend(assem, ", `d0");
		      	   	   emit(AS_Oper(assem, L(F_SP(), NULL), NULL, NULL));
		      	   }
			   emit(AS_Oper("popl\t%edx", NULL, NULL, NULL));
			   emit(AS_Oper("popl\t%ecx", NULL, NULL, NULL));
		      	   return F_RV();
		      }
		      case T_ESEQ:
	   	   	   assert(0);
	   }
}

static void munchStm(T_stm s)
{
  //fprintf(stderr, "\nbegin munch stm %d", s->kind);
	   switch(s->kind){
	   	   case T_MOVE: {
	   	   	   T_exp dst = s->u.MOVE.dst, src = s->u.MOVE.src;
	   	   	   //fprintf(stderr, "\nbegin munch T_MOVE stm");
	   	   	   if(dst->kind == T_MEM){
	   	   	   	   //MOVE(MEM(BINOP(PLUS, e1, CONST(i))), e2)
	   	   	   	   if(dst->u.MEM->kind == T_BINOP
	   	   	   	   	   && dst->u.MEM->u.BINOP.op == T_plus
	   	   	   	   	   && dst->u.MEM->u.BINOP.right->kind == T_CONST){
	   	   	   	   	   T_exp e1 = dst->u.MEM->u.BINOP.left, e2 = src;
	   	   	   	   	   char * assem = "movl\t`s1, ";

	   	   	   	   	   assem = sappend(assem, itoa(dst->u.MEM->u.BINOP.right->u.CONST));
	   	   	   	   	   assem = sappend(assem, "(`s0)");
	   	   	   	   	   
	   	   	   	   	   emit(AS_Oper(assem,
	   	   	   	   	   	   NULL, L(munchExp(e1, 0), L(munchExp(e2, 1), NULL)), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(MEM(BINOP(PLUS, CONST(i), e1)), e2)
	   	   	   	   else if(dst->u.MEM->kind == T_BINOP
	   	   	   	   	   && dst->u.MEM->u.BINOP.op == T_plus
	   	   	   	   	   && dst->u.MEM->u.BINOP.left->kind == T_CONST){
	   	   	   	   	   T_exp e1 = dst->u.MEM->u.BINOP.right, e2 = src;
	   	   	   	   	   char * assem = "movl\t`s1, ";

	   	   	   	   	   assem = sappend(assem, itoa(dst->u.MEM->u.BINOP.left->u.CONST));
	   	   	   	   	   assem = sappend(assem, "(`s0)");
	   	   	   	   	   
	   	   	   	   	   emit(AS_Oper(assem,
	   	   	   	   	   	   NULL, L(munchExp(e1, 0), L(munchExp(e2, 1), NULL)), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(MEM(CONST(i)), e2)
	   	   	   	   else if(dst->u.MEM->kind == T_CONST){
	   	   	   	   	   T_exp e2 = src;
	   	   	   	   	   char * assem = "movl\t`s0, (";

	   	   	   	   	   assem = sappend(assem, itoa(dst->u.MEM->u.CONST));
	   	   	   	   	   assem = sappend(assem, ")");
	   	   	   	   	   
	   	   	   	   	   emit(AS_Oper(assem,
	   	   	   	   	   	   NULL, L(munchExp(e2, 0), NULL), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(MEM(TEMP(i)), e2)
	   	   	   	   else if(dst->u.MEM->kind == T_TEMP){
	   	   	   	   	   T_exp e1 = dst->u.MEM, e2 = src;

	   	   	   	   	   emit(AS_Oper("movl\t`s1, (`s0)",
	   	   	   	   	   	   NULL, L(munchExp(e1, 0), L(munchExp(e2, 1), NULL)), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(MEM(e1), e2)
	   	   	   	   else{
	   	   	   	   	   T_exp e1 = dst->u.MEM, e2 = src;

	   	   	   	   	   emit(AS_Oper("movl\t`s1, (`s0)",
	   	   	   	   	   	   NULL, L(munchExp(e1, 0), L(munchExp(e2, 1), NULL)), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   }
	   	   	   else if(dst->kind == T_TEMP){
	   	   	   	   //MOVE(TEMP(i), MEM(BINOP(PLUS, e1, CONST(i))))
	   	   	   	   if(src->kind == T_MEM
	   	   	   	   	   && src->u.MEM->kind == T_BINOP
	   	   	   	   	   && src->u.MEM->u.BINOP.op == T_plus
	   	   	   	   	   && src->u.MEM->u.BINOP.right->kind == T_CONST){
	   	   	   	   	   T_exp e1 = dst, e2 = src->u.MEM->u.BINOP.left;
	   	   	   	   	   char * assem = "movl\t";

	   	   	   	   	   assem = sappend(assem, itoa(src->u.MEM->u.BINOP.right->u.CONST));
	   	   	   	   	   assem = sappend(assem, "(`s0), ");
	   	   	   	   	   assem = sappend(assem, "`d0");

	   	   	   	   	   emit(AS_Oper(assem, L(munchExp(e1, 0), NULL), L(munchExp(e2, 0), NULL), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(TEMP(i), MEM(BINOP(PLUS, CONST(i), e1)))
	   	   	   	   else if(src->kind == T_MEM
	   	   	   	   	   && src->u.MEM->kind == T_BINOP
	   	   	   	   	   && src->u.MEM->u.BINOP.op == T_plus
	   	   	   	   	   && src->u.MEM->u.BINOP.left->kind == T_CONST){
	   	   	   	   	   T_exp e1 = dst, e2 = src->u.MEM->u.BINOP.right;
	   	   	   	   	   char * assem = "movl\t";

	   	   	   	   	   assem = sappend(assem, itoa(src->u.MEM->u.BINOP.left->u.CONST));
	   	   	   	   	   assem = sappend(assem, "(`s0), ");
	   	   	   	   	   assem = sappend(assem, "`d0");
	   	   	   	   	   emit(AS_Oper(assem, L(munchExp(e1, 0), NULL), L(munchExp(e2, 0), NULL), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(TEMP(i), MEM(e2))
	   	   	   	   else if(src->kind == T_MEM){
	   	   	   	       T_exp e2 = src;
	   	   	   	       
	   	   	   	       emit(AS_Oper("movl\t(`s0), `d0",
	   	   	   	   	       L(munchExp(dst, 0), NULL), L(munchExp(e2, 0), NULL), NULL));
	   	   	   	       return;
	   	   	   	   }
	   	   	   	   //MOVE(TEMP(i), BINOP(binOp, e1, CONST(i)))
	   	   	   	   else if(src->kind == T_BINOP
	   	   	   	   	   && src->u.BINOP.right->kind == T_CONST){
	   	   	   	   	   T_exp e1 = src->u.BINOP.left;
	   	   	   	   	   char * assem1 = "movl\t`s0, `d0";
	   	   	   	   	   char * assem2 = getAssemOp(src->u.BINOP.op);

	   	   	   	   	   emit(AS_Oper(assem1, L(munchExp(dst, 0), NULL), L(munchExp(e1, 0), NULL), NULL));
	   	   	   	   	   assem2 = sappend(assem2, "$");
	   	   	   	   	   assem2 = sappend(assem2, itoa(src->u.BINOP.right->u.CONST));
	   	   	   	   	   assem2 = sappend(assem2,	", `d0");
	   	   	   	   	   emit(AS_Oper(assem2, L(munchExp(dst, 0), NULL), NULL, NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(TEMP(i), BINOP(binOp, CONST(i), e1))
	   	   	   	   else if(src->kind == T_BINOP
	   	   	   	   	   && src->u.BINOP.left->kind == T_CONST){
	   	   	   	   	   T_exp e1 = src->u.BINOP.right;
	   	   	   	   	   char * assem1 = "movl\t`s0, `d0";
	   	   	   	   	   char * assem2 = getAssemOp(src->u.BINOP.op);

	   	   	   	   	   emit(AS_Oper(assem1, L(munchExp(dst, 0), NULL), L(munchExp(e1, 0), NULL), NULL));
	   	   	   	   	   assem2 = sappend(assem2, "$");
	   	   	   	   	   assem2 = sappend(assem2, itoa(src->u.BINOP.left->u.CONST));
	   	   	   	   	   assem2 = sappend(assem2,	", `d0");
	   	   	   	   	   emit(AS_Oper(assem2, L(munchExp(dst, 0), NULL), NULL, NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(TEMP(i), CONST(0))
	   	   	   	   else if(src->kind == T_CONST
	   	   	   	   	   && src->u.CONST == 0){
	   	   	   	   	   char * assem = "xorl\t`s0, `d0";

	   	   	   	   	   emit(AS_Oper(assem, L(munchExp(dst, 0), NULL), L(munchExp(dst, 0), NULL), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(TEMP(i), CONST(i))
	   	   	   	   else if(src->kind == T_CONST){
	   	   	   	   	   char * assem = "movl\t$";

	   	   	   	   	   assem = sappend(assem, itoa(src->u.CONST));
	   	   	   	   	   assem = sappend(assem, ", `d0");

	   	   	   	   	   emit(AS_Oper(assem, L(munchExp(dst, 0), NULL), NULL, NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   	   //MOVE(TEMP(i), e2)
	   	   	   	   else{
	   	   	   	   	   T_exp e2 = src;
	   	   	   	   	   
	   	   	   	   	   emit(AS_Oper("movl\t`s0, `d0",
	   	   	   	   	       L(munchExp(dst, 0), NULL), L(munchExp(e2, 0), NULL), NULL));
	   	   	   	   	   return;
	   	   	   	   }
	   	   	   }
	   	   	   else{
	   	   	   	   assert(0);
	   	   	   }
	   	   }
	   	   case T_LABEL:{
	   	   	   char* label = sappend(S_name(s->u.LABEL), ":");
	   	   	   
	   	   	   //fprintf(stderr, "\nbegin munch T_LABEL stm");
	   	   	   emit(AS_Label(label, s->u.LABEL));
	   	   	   return;
	   	   }
	   	   case T_JUMP:{
	   	   	   //unconditional jump
	   	   	   T_exp e = s->u.JUMP.exp;
	   	   	   char * assem = "jmp\t";

            		   assert(s->u.JUMP.jumps->head != NULL);
          		   assem = sappend(assem, S_name(s->u.JUMP.jumps->head));
	   	   	   emit(AS_Oper(assem, NULL, NULL, AS_Targets(Temp_LabelList(s->u.JUMP.jumps->head, NULL))));
	   	   	   return;
	   	   }
	   	   case T_CJUMP:{
	   	   	   //conditional jump
	   	   	   T_exp e1 = s->u.CJUMP.left, e2 = s->u.CJUMP.right;
	   	   	   Temp_label tLabel = s->u.CJUMP.true, fLabel = s->u.CJUMP.false;
	   	   	   char * assem = getAssemJccOp(s->u.CJUMP.op);

            		   assem = sappend(assem, S_name(tLabel));
            		   emit(AS_Oper("cmpl\t`s0, `s1", NULL, L(munchExp(e2, 0), L(munchExp(e1, 1), NULL)), NULL));
	   	   	   emit(AS_Oper(assem, NULL, NULL, AS_Targets(Temp_LabelList(tLabel, NULL))));
	   	   	   return;
	   	   }
	   	   case T_EXP:{
	   	   	   munchExp(s->u.EXP, 0);
	   	   	   return;
	   	   }
	   	   case T_SEQ:
	   	   	   assert(0);
	   	   default:
	   	   	   assert(0);
	   }
}

AS_instrList globalInstrList = NULL;
AS_instrList lastGlobalInstrList = NULL;
//store the instruction to the inst list
static void emit(AS_instr inst)
{
    AS_instrList newInstrList = NULL;

    assert(inst);
    newInstrList = AS_InstrList(inst, NULL);

    if(globalInstrList == NULL){
        globalInstrList = lastGlobalInstrList = newInstrList;
    }
    else{
    	   lastGlobalInstrList->tail = newInstrList;
    	   lastGlobalInstrList = newInstrList;
    }
}

/*****************************************************************
Emit assemble instruction into the head of globalInstrList
*****************************************************************/
static void emitbefore(AS_instr instr)
{
    AS_instrList newInstrList = NULL;

    assert(instr != NULL);
    newInstrList = AS_InstrList(instr, NULL);

    if(globalInstrList == NULL){
        globalInstrList = lastGlobalInstrList = newInstrList;
    }
    else{
    	   newInstrList->tail = globalInstrList;
    	   globalInstrList = newInstrList;
    }
}

//generate code for one frame,
//Frame f records the local parameters info
//T_stmList stmList is the list of statement
AS_instrList F_codegen(F_frame f, T_stmList stmList)
{
    AS_instrList instrList = NULL;
    //string assem = NULL;

    //emit assembly code of the proc body
    for(; stmList != NULL; stmList = stmList->tail){
    	   munchStm(stmList->head);
    }

    //add prolog instrlist
    string assem;
    assem = "subl\t$";
    assem = sappend(assem, itoa(f->locals* 4));
    assem = sappend(assem, ", `d0");
    emitbefore(AS_Oper(assem, L(F_SP(), NULL), NULL, NULL));
    emitbefore(AS_Oper("pushl\t%esi", NULL, NULL, NULL));
    emitbefore(AS_Oper("pushl\t%edi", NULL, NULL, NULL));
    emitbefore(AS_Oper("pushl\t%edx", NULL, NULL, NULL));
    emitbefore(AS_Oper("pushl\t%ecx", NULL, NULL, NULL));
    emitbefore(AS_Oper("pushl\t%ebx", NULL, NULL, NULL));
    emitbefore(AS_Oper("movl\t`s0, `d0", L(F_FP(), NULL), L(F_SP(), NULL), NULL));
    emitbefore(AS_Oper("pushl\t`s0", NULL, L(F_FP(), NULL), NULL));

    //add epilog instrlist
    assem = "addl\t$";
    assem = sappend(assem, itoa(f->locals* 4));
    assem = sappend(assem, ", `d0");
    emit(AS_Oper(assem, L(F_SP(), NULL), NULL, NULL));
    emit(AS_Oper("popl\t%esi", NULL, NULL, NULL));
    emit(AS_Oper("popl\t%edi", NULL, NULL, NULL));
    emit(AS_Oper("popl\t%edx", NULL, NULL, NULL));
    emit(AS_Oper("popl\t%ecx", NULL, NULL, NULL));
    emit(AS_Oper("popl\t%ebx", NULL, NULL, NULL));
  /*  emit(AS_Oper("movl\t`s0, `d0", L(F_SP(), NULL), L(F_FP(), NULL), NULL));
    emit(AS_Oper("popl\t`s0", NULL, L(F_FP(), NULL), NULL));*/
    emit(AS_Oper("leave",NULL,NULL,NULL));
    emit(AS_Oper("ret", NULL, NULL, NULL));
	
    instrList = globalInstrList;
    globalInstrList = lastGlobalInstrList = NULL;
    return instrList;
}


