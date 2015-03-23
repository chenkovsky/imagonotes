#include "escape.h"
#include "absyn.h"
static void traverseExp(S_table env, int depth, A_exp e);
static void traverseDec(S_table env, int depth, A_dec d);
static void traverseVar(S_table env, int depth, A_var v);
void Esc_findEscape(A_exp exp){
}
static void traverseExp(S_table env, int depth, A_exp e){
  depth++;
  switch(e->kind){
  case A_opExp:{
    traverseExp(env,depth,e->u.op.left);
    traverseExp(env,depth,e->u.op.right);
  }
    break;
  case A_recordExp:{
    A_efieldList ef;
    for (ef = e->u.record.fields; tf; ef = ef->tail){
      traverseExp(env,depth,ef->head->exp);	
    }
  }
    break;
  case A_letExp:{
    //S_beginScope(env);
    A_decList d;
    for(d = e->u.let.decs; d; d = d->tail){
      traverseDec(env,depth,d->head);
    }
    traverseExp(env, depth, e->u.let.body);
  }
    break;
  case A_seqExp:{
    A_expList ae = d->u.seq;
    while(ae && ae->head){
      traverseExp(env, depth, ae->head);
      ae = ae->tail;
    }
  }
    break;
  case A_varExp:{
    traverseVar(env, depth, e->u.var);
  }
    break;
  case A_callExp:{
    A_expList as;
    for(as = e->u.call.args; as; as = as->tail){
      traverseExp(env, depth, as->head);
    }
  }
    break;
  case A_assignExp:{
    traverseVar(env, depth, e->u.assign.var);
    traverseExp(env, depth, e->u.assign.exp);
  }
    break;
  case A_ifExp:{
    traverseExp(env, depth, e->u.iff.test);
    if(e->u.iff.elsee){
      traverseExp(env, depth, e->u.iff.elsee);
    }
  }
    break;
  case A_whileExp:{
    traverseExp(env, depth, e->u.whilee.test);
    //S_beginScope(env);
    //S_enter(env, &loopsym, NULL);
    traverseExp(env, depth, e->u.whilee.body);
    //S_endScope(env);
  }
    break;
  case A_forExp:{
    traverseExp(env, depth, e->u.forr.lo);
    traverseExp(env, depth, e->u.forr.hi);
    //S_beginScope(env);
    //S_enter(venv)
    //S_enter(env, e->u.forr.var,EscapeEntry(depth, &(e->escape)));
    traverseExp(env, depth, e->u.forr.body);
    //S_endScope(env);
  }
    break;
  case A_arrayExp:{
    traverseExp(env, depth, e->u.array.size);
    traverseExp(env, depth, e->u.array.init);
  }
    break;
  }
}
static void traverseDec(S_table env, int depth, A_dec d){
  depth++;
  switch(d->kind){
  case A_functionDec:{
    A_fundecList fl = d->u.function;
    A_fundec f;
    while(fl){
      f = fl->head;
      traverseExp(env, depth, f->body);
    }
  }
    break;
  case A_varDec:{
    if(d->u.var.escape){
      S_enter(env, d->u.var.var, EscapeEntry(depth,&(d->u.var.escape)));
    }
    if(d->u.var.init == NULL){
      traverseExp(env, depth, d->u.var.init);
    }
    S_enter(env, d->u.var.var,NULL);
  }
    break;
  case A_typeDec:{
  }
    break;
  }
}
static void traverseVar(S_table env, int depth, A_var v){
  depth++;
  switch(v->kind){
  case A_simpleVar:{
  }
    break;
  case A_fieldVar:{
    traverseVar(env, depth, v->u.field.var);
  }
    break;
  case A_subscriptVar:{
    traverseVar(env, depth, v->u.subscript.var);
  }
    break;
  }
}

