#ifndef CODEGEN_H
#define CODEGEN_H

static int munchArgs(T_expList expList);
static Temp_temp munchExp(T_exp e, int i);
static void munchStm(T_stm s);

static void emit(AS_instr inst);
AS_instrList F_codegen(F_frame f, T_stmList stmList);


#endif
