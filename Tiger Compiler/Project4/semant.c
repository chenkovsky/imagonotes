#include <stdio.h>
#include <stdlib.h>
#include "util.h"
#include "errormsg.h"
#include "table.h"
#include "symbol.h" /* symbol table data structures */
#include "absyn.h"
//#include "types.h"
#include "temp.h"
//#include "tree.h"
//#include "frame.h"
#include "translate.h"
#include "semant.h"
#include "env.h"
struct expty expTy(Tr_exp exp, Ty_ty ty){
  struct expty e;
  e.exp = exp;
  e.ty = ty;
  return e;
};
struct expty transDec(A_dec dec, Tr_level level,S_table tenv, S_table venv);
struct expty transExp(A_exp exp, Tr_level level, S_table tenv,S_table venv);
struct expty transVar(A_var var, Tr_level level,S_table tenv, S_table venv);
Temp_labelList label_stack = NULL;
static void pushDoneLabel(Temp_label label){
  label_stack = Temp_LabelList(label, label_stack);
}
static void popDoneLabel(){
  label_stack = label_stack->tail;
}
static F_fragList list = NULL;

static void  insert_head(F_frag h){
  list = F_FragList(h, list);
}
static void insert_tail(F_frag t){
  F_fragList tmp = list;
  F_fragList pre = list;
  while(tmp){
    pre = tmp;
    tmp = tmp->tail;
  }
  if(pre){
    pre->tail = F_FragList(t,NULL);
  }else{
    list = F_FragList(t,NULL);
  }
}
//struct S_symbol_ loopsym = {"<loop>", 0};
//return function arguements list
U_boolList FunBoolList(A_fieldList l){
  U_boolList bl = U_BoolList(TRUE,NULL);
  U_boolList tmp = NULL;
  while(l){
    bl = U_BoolList(TRUE, bl);






    l = l->tail;
  }
  return bl;
}

struct expty transSimpleVar(A_var var, Tr_level level,S_table tenv, S_table venv){ 
  E_enventry x = S_look(venv,var->u.simple);
  if(x == NULL){
    return expTy(NULL,NULL);
  }
  return expTy(Tr_simpleVar(x->u.var.access, level), actual_ty(tenv,x->u.var.ty)); 
}
struct expty transFieldVar(A_var var, Tr_level level,S_table tenv, S_table venv){ 
  //you see, Mem(Mem(Mem(a)+off1)+off2):a.b.c
  struct expty e = transVar(var->u.field.var, level, tenv, venv);
  Ty_fieldList list;
  int offset = 0;
  for (list = e.ty->u.record; list; list = list->tail,offset+=4) {
    if (list->head->name == var->u.field.sym) {
      return expTy(Tr_Ex(T_Mem(T_Binop(T_plus, unEx(e.exp), T_Const(offset)))), actual_ty(tenv,list->head->ty));
    }
  }
  assert(0);
  return expTy(NULL, NULL);
}















struct expty transSubscriptVar(A_var var, Tr_level level,S_table tenv, S_table venv){ 
  //array
  struct expty e = transVar(var->u.subscript.var, level, tenv, venv);
  struct expty f = transExp(var->u.subscript.exp, level, tenv, venv);
  return expTy(Tr_Ex(T_Mem(T_Binop(T_plus, unEx(e.exp),T_Binop(T_mul, T_Const(4), unEx(f.exp))))), actual_ty(tenv, e.ty->u.array)); 
}

struct expty transVar(A_var var, Tr_level level,S_table tenv, S_table venv){ 
  switch(var->kind){
  case A_simpleVar:{
    return transSimpleVar(var, level, tenv, venv);
  }
  case A_fieldVar:{
    return transFieldVar( var, level, tenv, venv);
  }
  case A_subscriptVar:{
    return transSubscriptVar(var, level, tenv, venv);
  }
  }return expTy(NULL,NULL);
}

struct expty transFunctionDec(A_dec dec, Tr_level level,S_table tenv, S_table venv){
  A_fundecList fl = dec->u.function;
  A_fundec f;
  string name = "";
  Ty_tyList fTys;
  Ty_ty rTy;
  while(fl) {
    f = fl->head;
    //get the return type
    name = S_name(f->name);
    if(f->result != NULL && strcmp(S_name(f->result), "")){
      rTy = S_look(tenv,f->result);
    }else{
      rTy = Ty_Void();
    }
    fTys =  TyFormalList(tenv, f->params);
    Temp_label label = Temp_newlabel();//this can be replace by another method with name as arg. 
    S_enter(venv, f->name,E_FunEntry(level, label, fTys, rTy));fl = fl->tail;
  }
  fl = dec->u.function;
  while(fl) {f = fl->head;
    S_beginScope(venv);
    U_boolList formals = FunBoolList(f->params);
    E_enventry entry = S_look(venv, f->name);
    Tr_level nl = Tr_newLevel(level,entry->u.fun.label,formals);
    A_fieldList l = f->params;fTys =  TyFormalList(tenv, f->params);
    Ty_tyList t = fTys;
    F_accessList acc = nl->frame->formal_location->tail;
    
    for(;l;l = l->tail, t=t->tail){
      S_enter(venv, l->head->name,E_VarEntry(Tr_Access(nl, acc->head), t->head));
      acc =acc->tail;
    }
    struct expty body = transExp(f->body, nl, tenv, venv);
    F_frag frag = F_ProgFrag(T_Move(T_Temp(F_RV()), unEx(body.exp)), nl->frame);
    insert_tail(frag);
    S_endScope(venv);
    fl = fl->tail;
  }
  return expTy(NULL,NULL);
}

struct expty transVarDec(A_dec dec, Tr_level level,S_table tenv, S_table venv){
  Ty_ty ty = NULL;
  Tr_access local = Tr_allocLocal(level,TRUE);
  struct expty r = {NULL,NULL};
  if (dec->u.var.init == NULL) {
    ty = Ty_Void();
    //printf("NULL %x\n",(int)(ty));//debug
    S_enter(venv, dec->u.var.var, E_VarEntry(local, ty));
  } else {
    struct expty e = transExp(dec->u.var.init, level, tenv, venv);
    //printf("%s %x\n",e.ty->kind, (int)(e.ty));//debug
    if (dec->u.var.typ != NULL && dec->u.var.typ != S_Symbol("")) {
      ty = actual_ty(tenv, S_look(tenv, dec->u.var.typ));
    }
    if (ty) {
      S_enter(venv, dec->u.var.var, E_VarEntry(local, ty));
    } else {
      S_enter(venv, dec->u.var.var, E_VarEntry(local, e.ty));
    }
    r = expTy((Tr_Nx(T_Move(T_Mem(T_Binop(T_plus, T_Temp(F_FP()) ,T_Const(local->access->u.offset))),unEx(e.exp)))),ty); 
  }
  return r;
}

struct expty transTypeDec(A_dec dec, Tr_level level,S_table tenv, S_table venv){ 
  A_nametyList l = dec->u.type;
  //A_namety prev = NULL;
  while(l) {
    A_namety nty = l->head;
    S_enter(tenv, nty->name,Ty_Name(nty->name, NULL));
    l = l->tail;
  }
  l = dec->u.type;
  while(l) {
    Ty_ty tmp = transTy(tenv, l->head->ty);
    Ty_ty name = S_look(tenv, l->head->name);
    name->u.name.ty = tmp;
    l = l->tail;
  }
  return expTy(NULL, NULL);
}
struct expty transOpExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){ 
  A_oper oper = exp->u.op.oper;
  struct expty left = transExp(exp->u.op.left, level, tenv, venv);
  struct expty right = transExp(exp->u.op.right,level, tenv, venv);
  T_binOp top = -1;
  switch(oper){
  case A_plusOp:
    top = T_plus;
    break;
  case A_minusOp:
    top = T_minus;
    break;
  case A_timesOp:
    top = T_mul;
    break;
  case A_divideOp:
    top = T_div;
    break;
  }
  if(top != -1){
    return expTy(Tr_Ex(T_Binop(top,unEx(left.exp),unEx(right.exp))), Ty_Int());
  }
  T_relOp rop = -1;
  switch(oper){
  case A_ltOp:
    rop = T_lt;
    break;
  case A_geOp:
    rop = T_ge;
    break;
  case A_leOp:
    rop = T_le;
    break;
  case A_gtOp:
    rop = T_gt;
    break;
  case A_neqOp:
    rop = T_ne;
    break;
  case A_eqOp:
    rop = T_eq;
    break;
  }
  if(rop != -1){
    T_stm stm = T_Cjump(rop, unEx(left.exp), unEx(right.exp), NULL, NULL);
    return expTy(Tr_Cx(PatchList(&stm->u.CJUMP.true, NULL), PatchList(&stm->u.CJUMP.false, NULL),stm), Ty_Int()); 
  }
  return expTy(NULL,NULL);
}

struct expty transStringExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  Temp_label label = Temp_newlabel();
  F_frag flag = F_StringFrag(label, exp->u.stringg);
  insert_head(flag);
  return expTy(Tr_Ex(T_Name(label)) ,Ty_String());
}


struct expty transCallExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  E_enventry f = S_look(venv, exp->u.call.func);
  Ty_ty r = f->u.fun.result;
  //Ty_tyList fs = f->u.fun.formals;
  A_expList as = exp->u.call.args;
  A_exp p;
  int idx = 0;
  //struct expty ty = {NULL,r}
  //if(r == Ty_Void()){
  //}
  T_expList args = T_ExpList(T_Const((int)level),NULL);
  //T_expList tmp = args;
  for (; as; p = as->head, as = as->tail, idx++) {
    struct expty t = transExp(as->head, level, tenv, venv);
    //if(tmp){
    //tmp->tail = T_ExpList(unEx(t.exp),NULL);tmp = tmp->tail;
    args = T_ExpList(unEx(t.exp),args);
    //}else{
    //args = T_ExpList(unEx(t.exp),NULL);
    //tmp = args;
    //}
  }
  return expTy(Tr_Ex(T_Call(T_Name(f->u.fun.label), args )), actual_ty(tenv,r));
}

struct  expty transVarExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  //A_oper oper = a->u.op.oper;
  struct expty e = transVar(exp->u.var, level, tenv, venv);
  return e;
}

struct expty transRecordExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  Ty_ty ty = actual_ty(tenv,S_look(tenv, exp->u.record.typ));
  Ty_fieldList tf = ty->u.record;
  A_efieldList ef = exp->u.record.fields;
  int idx = 0;
  //E_enventry newf = S_look(tenv, S_Symbol("allocRecord"));
  //get the record address

  //check whether types of values  right
  T_stm init_stm = NULL;
  T_stm cur_stm = NULL;
  T_stm tmp_stm = NULL;
  for (; tf && ef; tf = tf->tail, ef = ef->tail, idx++) {
    struct expty e = transExp(ef->head->exp, level, tenv, venv);
    if(tf->tail){
      tmp_stm = T_Seq(T_Move(T_Mem(T_Binop(T_plus, T_Temp(F_ScratchTemp()), T_Const(idx*sizeof(int)))), unEx(e.exp)),NULL);
    }else{
      tmp_stm = T_Move(T_Mem(T_Binop(T_plus, T_Temp(F_ScratchTemp()), T_Const(idx*sizeof(int)))), unEx(e.exp));
    }
    if(init_stm == NULL){
      cur_stm = tmp_stm;
      init_stm = cur_stm;
    }else{
      cur_stm->u.SEQ.right = tmp_stm;
      cur_stm = tmp_stm;
    }
  }
  T_expList newarg = T_ExpList(T_Const(idx*sizeof(int)), NULL);
  //also we can T_Name(Temp_namedlabel(s)) to call function
  T_exp newstm = T_Call(T_Name(Temp_namedlabel("allocRecord")), newarg);
  T_stm set_alloc_addr = T_Move(T_Temp(F_ScratchTemp()), newstm);
	
  return expTy(Tr_Ex(T_Eseq(T_Seq(set_alloc_addr, init_stm),T_Temp(F_ScratchTemp()))), ty);
}

struct expty transSeqExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  //Tr_exp te;
  struct expty e;
  A_expList ae = exp->u.seq;
  T_exp init = NULL;
  T_exp tmp = NULL;
  T_exp cur = NULL;
  while (ae && ae->head) {
    e = transExp(ae->head, level, tenv, venv);
    if(ae->tail){
      if(ae->tail->head){
	tmp = T_Eseq(T_Exp(unEx(e.exp)), NULL);}else{tmp = unEx(e.exp);}
    }else{
      tmp = unEx(e.exp);
    }
    if(init){
      cur->u.ESEQ.exp = tmp;
      cur = tmp;
    }else{
      cur=tmp;
      init = tmp;
    }
    ae = ae->tail;
  }
  if (e.ty) {
    return expTy(Tr_Ex(init), e.ty);
  } else {
    return expTy(Tr_Ex(init), Ty_Void());
  }
}

struct expty transAssignExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  struct expty v = transVar(exp->u.assign.var, level, tenv, venv);
  struct expty e = transExp(exp->u.assign.exp, level, tenv, venv);
  //if ((a->u.assign.var->kind == A_simpleVar) && S_look(s_venv, a->u.assign.var->u.simple)) {
  //  EM_error(a->u.assign.exp->pos, "invalid assign to index");
  //}
  //if ((v.ty != NULL) && (v.ty != e.ty) && (e.ty->kind != Ty_nil)) {
  //  EM_error(a->pos, "type mismatch");
  //}
  return expTy(Tr_Nx(T_Move(unEx(v.exp), unEx(e.exp))), Ty_Void());
}
// if(){***
// jump done
//}{
//jump false ....
//jump done
//}
//done:
//construct from bottom to up
//
struct expty transIfExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  struct expty e = transExp(exp->u.iff.test, level, tenv, venv);
  struct expty tb = transExp(exp->u.iff.then, level, tenv, venv);
  struct expty eb = {NULL,NULL};
  if (exp->u.iff.elsee) {
    eb = transExp(exp->u.iff.elsee, level, tenv, venv);
  }
  Temp_label donel = Temp_newlabel();
  Temp_label truel = Temp_newlabel();
  Temp_label falsel = Temp_newlabel();
  T_exp re = T_Mem(T_Binop(T_plus, T_Temp(F_FP()), T_Const(F_allocLocal(level->frame, TRUE)->u.offset)));
  //
  //
  struct Cx cx = unCx(e.exp);
  doPatch(cx.trues, truel);
  doPatch(cx.falses, falsel);
  T_exp explist = T_Eseq(T_Label(donel), re);
  explist = T_Eseq(T_Jump(T_Name(donel), Temp_LabelList(donel, NULL)),explist);//the expression if the iff is done
  if(exp->u.iff.elsee) {
    T_exp elsee = T_Mem(T_Binop(T_plus, T_Temp(F_FP()), T_Const(F_allocLocal(level->frame, TRUE)->u.offset)));
    explist = T_Eseq(T_Move(re,elsee),explist);
    explist = T_Eseq(T_Move(elsee,unEx(eb.exp)), explist);
  }
  explist = T_Eseq(T_Label(falsel), explist);
  explist = T_Eseq(T_Jump(T_Name(donel), Temp_LabelList(donel, NULL)), explist);
  T_exp ife = T_Mem(T_Binop(T_plus, T_Temp(F_FP()), T_Const(F_allocLocal(level->frame, TRUE)->u.offset)));
  explist = T_Eseq(T_Move(re,ife),explist);
  explist = T_Eseq(T_Move(ife,unEx(tb.exp)),explist);
  
  explist = T_Eseq(T_Label(truel), explist);
  explist = T_Eseq(unNx(e.exp), explist);
  return expTy(Tr_Ex(explist),Ty_Void());
}

struct expty transWhileExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  Temp_label testl = Temp_newlabel();
  Temp_label truel = Temp_newlabel();
  Temp_label falsel = Temp_newlabel();
  Temp_label donel = Temp_newlabel();
  pushDoneLabel(donel);
  struct expty e = transExp(exp->u.iff.test, level, tenv, venv);
  struct expty b = transExp(exp->u.whilee.body, level, tenv, venv);
  struct Cx cx = unCx(e.exp);
  doPatch(cx.trues, truel);
  doPatch(cx.falses, falsel);
  T_stm stm = T_Label(donel);
  stm = T_Seq(T_Jump(T_Name(donel), Temp_LabelList(donel, NULL)), stm);
  stm = T_Seq(T_Label(falsel), stm);
  stm = T_Seq(T_Jump(T_Name(testl), Temp_LabelList(testl, NULL)), stm);
  stm = T_Seq(unNx(b.exp), stm);
  stm = T_Seq(T_Label(truel), stm);
  stm = T_Seq(unNx(e.exp), stm);
  stm = T_Seq(T_Label(testl), stm);
  popDoneLabel();
  return expTy(Tr_Nx(stm), Ty_Void());
}
struct expty transForExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){

  Temp_label testl = Temp_newlabel();
  Temp_label truel = Temp_newlabel();
  Temp_label falsel = Temp_newlabel();
  Temp_label donel = Temp_newlabel();
  pushDoneLabel(donel);
  struct expty l = transExp(exp->u.forr.lo, level, tenv, venv);
  struct expty u = transExp(exp->u.forr.hi, level, tenv, venv);
  S_beginScope(venv);
  S_beginScope(tenv);
  Tr_access acc = Tr_allocLocal(level, exp->u.forr.escape);//true
  assert(exp->u.forr.escape == 1);
  S_enter(venv, exp->u.forr.var, E_VarEntry(acc, Ty_Int()));
  struct expty b = transExp(exp->u.forr.body, level, tenv, venv);
  S_endScope(tenv);
  S_endScope(venv);

  T_exp vexp = T_Mem(T_Binop(T_plus, T_Temp(F_FP()), T_Const(acc->access->u.offset)));
  T_exp uexp = T_Mem(T_Binop(T_plus, T_Const(F_allocLocal(level->frame, TRUE)->u.offset), T_Temp(F_FP())));
  T_stm stm = T_Label(donel);
  stm = T_Seq(T_Jump(T_Name(donel), Temp_LabelList(donel, NULL)), stm);
  stm = T_Seq(T_Label(falsel), stm);
  stm = T_Seq(T_Jump(T_Name(testl), Temp_LabelList(testl, NULL)), stm);
  stm = T_Seq(T_Move(vexp, T_Binop(T_plus, vexp, T_Const(1))), stm);
  stm = T_Seq(unNx(b.exp), stm);
  stm = T_Seq(T_Label(truel), stm);
  stm = T_Seq(T_Cjump(T_le, vexp, uexp, truel, falsel), stm);
  stm = T_Seq(T_Label(testl), stm);
  stm = T_Seq(T_Move(uexp, unEx(u.exp)), stm);
  stm = T_Seq(T_Move(vexp, unEx(l.exp)), stm);
  popDoneLabel();
  return expTy(Tr_Nx(stm), Ty_Void());
}
struct expty transBreakExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  return expTy(Tr_Nx(T_Jump(T_Name(label_stack->head), Temp_LabelList(label_stack->head, NULL))),NULL);
}
struct expty transLetExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  struct expty ety;
  struct expty tmp;
  A_decList d;int var_amount = 0;
  S_beginScope(venv);
  S_beginScope(tenv);
  T_stm decexp = NULL;
  T_stm dectail= NULL;
  T_stm tmp_stm = NULL;
  for (d = exp->u.let.decs; d; d = d->tail) {if(d->head->kind == A_varDec) { if(d->head->u.var.init){var_amount++;}}}
  for (d = exp->u.let.decs; d; d = d->tail) {
    tmp = transDec(d->head, level, tenv, venv);
    if(d->tail && var_amount > 1){
      tmp_stm = T_Seq(unNx(tmp.exp),NULL);
    }else{
      tmp_stm = unNx(tmp.exp);
    }
    if(tmp.exp){
      if(decexp == NULL){
	decexp = tmp_stm;
	dectail = decexp;
      }else{
	dectail->u.SEQ.right = tmp_stm;
	dectail = dectail->u.SEQ.right;
      }
    }
  }
  ety = transExp(exp->u.let.body, level, tenv, venv);
  S_endScope(tenv);
  S_endScope(venv);
  if(decexp == NULL){
    return expTy(ety.exp, ety.ty);  
  }else{
    return expTy(Tr_Ex(T_Eseq(decexp, unEx(ety.exp))),ety.ty);
  }
}
struct expty transArrayExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  struct expty s = transExp(exp->u.array.size, level, tenv, venv);
  Ty_ty ty = actual_ty(tenv, S_look(tenv, exp->u.array.typ));
  struct expty v = transExp(exp->u.array.init, level, tenv, venv);
  //if (actual_ty(tenv, ty->u.array) != v.ty) {
  //EM_error(a->u.array.init->pos, "type mismatched");
  //}
  T_expList newarg = T_ExpList(unEx(v.exp),T_ExpList(unEx(s.exp), NULL));
  T_exp newstm = T_Call(T_Name(Temp_namedlabel("initArray")), newarg);
  return expTy(Tr_Ex(newstm), ty);
}



//i think it's ok
struct expty transDec(A_dec dec, Tr_level level,S_table tenv, S_table venv) {
  switch(dec->kind){
  case A_functionDec:{//i think it's ok
    return transFunctionDec(dec, level, tenv, venv);
  }
  case A_varDec:{
    return transVarDec(dec, level, tenv, venv);
  }
  case A_typeDec:{//I think it's OK
    return transTypeDec(dec, level,tenv, venv);
  }
  }return expTy(NULL,NULL);
}

struct expty transExp(A_exp exp, Tr_level level, S_table tenv,S_table venv){
  switch(exp->kind){
  case A_opExp:{
    return transOpExp(exp, level, tenv, venv);
  }
  case A_nilExp:{
    return expTy(Tr_Ex(T_Const(0)), Ty_Int());
  }
  case A_intExp:{
    return expTy(Tr_Ex(T_Const(exp->u.intt)),Ty_Int());
  }
  case A_stringExp:{
    return transStringExp(exp, level, tenv,venv);
  }
  case A_callExp:{
    return transCallExp(exp, level, tenv, venv);
  }
  case A_varExp:{
    return transVarExp(exp, level, tenv, venv);
  }
  case A_recordExp:{
    return transRecordExp(exp, level, tenv, venv);
  }
  case A_seqExp:{
    return transSeqExp(exp, level, tenv, venv);
  }
  case A_assignExp:{
    return transAssignExp(exp, level, tenv, venv);
  }
  case A_ifExp:{
    return transIfExp(exp, level, tenv, venv);
  }
  case A_whileExp:{
    return transWhileExp(exp, level, tenv, venv);
  }
  case A_forExp:{
    return transForExp(exp, level, tenv, venv);
  }
  case A_breakExp:{
    return transBreakExp(exp, level, tenv, venv);
  }
  case A_letExp:{
    return transLetExp(exp, level, tenv, venv);
  }
  case A_arrayExp:{
    return transArrayExp(exp, level, tenv, venv);
  }
  }return expTy(NULL,NULL);
}
    
    
F_fragList SEM_transProg(A_exp exp)
{
  S_table base_tenv = E_base_tenv();
  S_table base_venv = E_base_venv();
  Tr_level level = Tr_outermost();
  struct expty e = transExp(exp,level,base_tenv,base_venv);
  F_frag frag = F_ProgFrag(unNx(e.exp), level->frame);
  insert_tail(frag);
  return list;
}

