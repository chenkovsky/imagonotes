/*
translate.h
*/
#ifndef _TRANSLATE_H_
#define _TRANSLATE_H_
#include "util.h"
#include "types.h"
#include "temp.h"
#include "frame.h"
#include "tree.h"
typedef struct Tr_access_ *Tr_access;
typedef struct Tr_accessList_ *Tr_accessList;
typedef struct Tr_level_ *Tr_level;

struct Tr_level_  {F_frame frame;Tr_level parent;};
struct Tr_access_ {Tr_level level;F_access access;};
struct Tr_accessList_ {Tr_access head;Tr_accessList tail;};
typedef struct E_enventry_ *E_enventry;
struct E_enventry_ {
  enum {E_varEntry, E_funEntry}kind;
  union {
    struct {
      Tr_access access;
      Ty_ty ty;
    }var;
    struct {
      Tr_level level;
      Temp_label label;
      Ty_tyList formals;
      Ty_ty result;
    }fun;
  }u;
};
Tr_access Tr_Access(Tr_level level, F_access access);
typedef struct patchList_ *patchList;
struct patchList_ {
  Temp_label *head;
  patchList tail;
};
static patchList PatchList(Temp_label *head, patchList tail){
  patchList p = checked_malloc(sizeof(struct patchList_));
  p->head = head;
  p->tail = tail;
  return p;
}

typedef struct Tr_exp_ *Tr_exp;
struct Cx {
  patchList trues; 
  patchList falses; 
  T_stm stm;
};
struct Tr_exp_ {
  enum{
    Tr_ex, Tr_nx, Tr_cx
  }kind;
  union{
    T_exp ex;
    T_stm nx;
    struct Cx cx;
  } u;
};

Tr_exp Tr_Ex(T_exp ex);
Tr_exp Tr_Nx(T_stm nx);
Tr_exp Tr_Cx(patchList trues, patchList falses, T_stm stm);

void doPatch(patchList tList, Temp_label label);
patchList joinPatch(patchList first, patchList second);
T_exp unEx(Tr_exp e);
T_stm unNx(Tr_exp e);
struct Cx unCx(Tr_exp e);

E_enventry E_VarEntry(Tr_access access, Ty_ty ty);
E_enventry E_FunEntry(Tr_level level, Temp_label label, Ty_tyList formals, Ty_ty result); 
Tr_level Tr_outermost();
int Tr_level_distance(Tr_level cur);
Tr_accessList Tr_AccessList(Tr_access head, Tr_accessList tail);
Tr_level Tr_newLevel(Tr_level parent, Temp_label name, U_boolList formals);
Tr_accessList Tr_formals(Tr_level level);
Tr_access Tr_allocLocal(Tr_level level, bool escape);
Tr_exp Tr_simpleVar(Tr_access acc, Tr_level level);
Tr_exp Tr_fieldVar(Tr_access acc, Tr_level level, int idx);
#endif /* _TRANSLATE_H_ */
