#ifndef SEMANT_H
#define SEMANT_H

#include "absyn.h"
#include "types.h"
F_fragList SEM_transProg(A_exp exp);
struct expty{
  Tr_exp exp;
  Ty_ty ty;
};

#endif
