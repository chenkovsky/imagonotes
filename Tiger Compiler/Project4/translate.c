#include <stdio.h>
#include <string.h>
#include "util.h"
#include "symbol.h"
#include "temp.h"
#include "tree.h"
#include "frame.h"
#include "translate.h"
#include "absyn.h"

//outerMostLevel
Tr_level outerMostLevel = NULL;

/********************************************************
Return the outerMostLevel, it is created when first called
********************************************************/
Tr_level Tr_outermost(void)
{
    //implement here
  if(outerMostLevel == NULL){
    outerMostLevel = Tr_newLevel(NULL,Temp_namedlabel("tigermain"),NULL);
  }
  return outerMostLevel;
}

E_enventry E_VarEntry(Tr_access access, Ty_ty ty){
  E_enventry entry = (E_enventry)checked_malloc(sizeof(struct E_enventry_));
  entry->kind = E_varEntry;
  entry->u.var.access = access;
  entry->u.var.ty = ty;
  return entry;
}
E_enventry E_FunEntry(Tr_level level, Temp_label label, Ty_tyList formals, Ty_ty result){
  E_enventry entry = (E_enventry)checked_malloc(sizeof(struct E_enventry_));
  entry->kind = E_funEntry;
  entry->u.fun.level = level;
  entry->u.fun.label = label;
  entry->u.fun.formals = formals;
  entry->u.fun.result = result;
  return entry;
}

Tr_accessList Tr_AccessList(Tr_access head, Tr_accessList tail){
  Tr_accessList list = (Tr_accessList)checked_malloc(sizeof(struct Tr_accessList_));
  list->head = head;
  list->tail = tail;
  return list;
}
Tr_level Tr_newLevel(Tr_level parent, Temp_label name, U_boolList formals){
  Tr_level level = (Tr_level)checked_malloc(sizeof(struct Tr_level_));
  level->frame = F_newFrame(name,formals);
  level->parent = parent;
  return level;
}
//here is something wrong
Tr_accessList Tr_formals(Tr_level level){
  Tr_accessList list = (Tr_accessList)checked_malloc(sizeof(struct Tr_accessList_));
  Tr_access access = (Tr_access)checked_malloc(sizeof(struct Tr_access_));
  list->head = access;
  access->level = level;
  //access->access = 
  return list;
}
Tr_access Tr_allocLocal(Tr_level level, bool escape){
  Tr_access access = (Tr_access)checked_malloc(sizeof(struct Tr_access_));
  access->level = level;
  //level->frame->locals++;
  access->access = F_allocLocal(level->frame,escape);
  return access;
}
int Tr_level_distance(Tr_level cur){
  int level_count = 0;
  while(cur != Tr_outermost()){
    level_count++;
    cur = cur->parent;
  }
  return level_count;
}
void doPatch(patchList tList, Temp_label label){
  for(;tList;tList = tList->tail){
    *(tList->head) = label;
  }
}
patchList joinPatch(patchList first, patchList second){
  if(!first){
    return second;
  }
  for (;first->tail;first=first->tail);//go to end of list
  first->tail = second;
  return first;
}
T_exp unEx(Tr_exp e){
  switch (e->kind) {
  case Tr_ex:{
    assert(e->u.ex != NULL);
    return e->u.ex;
  }
  case Tr_cx:{
    Temp_temp r = F_ScratchTemp();//Temp_newtemp();
    Temp_label t = Temp_newlabel();
    Temp_label f = Temp_newlabel();
    doPatch(e->u.cx.trues, t);
    doPatch(e->u.cx.falses, f);
    assert(e->u.cx.stm != NULL);
    return T_Eseq(T_Move(T_Temp(r), T_Const(1)), 
		  T_Eseq(e->u.cx.stm,
			 T_Eseq(T_Label(f), 
			       T_Eseq(T_Move(T_Temp(r), T_Const(0)),
				      T_Eseq(T_Label(t),T_Temp(r))))));
  }
  case Tr_nx:{
    assert(e->u.nx != NULL);
    return T_Eseq(e->u.nx, T_Const(0));
  }
  default:
    assert(0);
  }
}
T_stm unNx(Tr_exp e){
  if(!e){
    return NULL;
  }
  switch(e->kind){
  case Tr_ex:{
    return T_Exp(e->u.ex); 
  }
  case Tr_cx:{
    return e->u.cx.stm;
  }
  case Tr_nx:{
    return e->u.nx;
  }
  default:
    assert(0);
  }
}
struct Cx unCx(Tr_exp e){
  switch(e->kind){
  case Tr_ex:{
    struct Cx cx;
    cx.stm = T_Cjump(T_ne, e->u.ex, T_Const(0),NULL,NULL);
    cx.trues = PatchList(&cx.stm->u.CJUMP.true,NULL);
    cx.falses = PatchList(&cx.stm->u.CJUMP.false, NULL);
    return cx;
  }
  case Tr_cx:{
    return e->u.cx;
  }
  case Tr_nx:{
    assert(0);
  }
  default:
    assert(0);
  }
  assert(0);
}


//the exp that get var from another level
//acc is the Tr_access of var's
//level is current frame's level
Tr_exp Tr_simpleVar(Tr_access acc, Tr_level level){
  T_exp exp = T_Temp(F_FP());
  Tr_level curlevel = acc->level;
  if(level != curlevel){
    //trace the static Link
    int aimlevel = (int)(acc->level);
    exp = T_Call(T_Name(S_Symbol("get_staticlink")),T_ExpList(T_Const(aimlevel),NULL));
  }
  exp = T_Mem(T_Binop(T_plus, T_Const(acc->access->u.offset), exp));
  return Tr_Ex(exp);
}

Tr_exp Tr_fieldVar(Tr_access acc, Tr_level level, int idx){
  Tr_exp fexp = Tr_simpleVar(acc, level);
  return Tr_Ex(T_Mem(T_Binop(T_plus, unEx(fexp) , T_Const(idx))));
}

Tr_exp Tr_Ex(T_exp ex){
  Tr_exp exp = checked_malloc(sizeof(struct Tr_exp_));
  exp->kind = Tr_ex;
  exp->u.ex = ex;
  return exp;
}
Tr_exp Tr_Nx(T_stm nx){
  Tr_exp exp = checked_malloc(sizeof(struct Tr_exp_));
  exp->kind = Tr_nx;
  exp->u.nx = nx;
  return exp;
}
Tr_exp Tr_Cx(patchList trues, patchList falses, T_stm stm){
  Tr_exp exp = checked_malloc(sizeof(struct Tr_exp_));
  exp->kind = Tr_cx;
  exp->u.cx.stm = stm;
  exp->u.cx.trues = trues;
  exp->u.cx.falses = falses;
  return exp;
}
Tr_access Tr_Access(Tr_level level, F_access access){
  Tr_access a = checked_malloc(sizeof(struct Tr_access_));
  a->level = level;
  a->access = access;
  return a;
}
