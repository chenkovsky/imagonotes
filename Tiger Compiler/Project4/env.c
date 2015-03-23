//#include "env.h"
#include "util.h"
#include "table.h"
#include "symbol.h"
#include "translate.h"
#include <stdlib.h>
S_table E_base_tenv(void){
  S_table tenv = (S_table)TAB_empty();
  S_enter(tenv, S_Symbol("string"), Ty_String());
  S_enter(tenv, S_Symbol("int"), Ty_Int());
  return tenv;
}
S_table E_base_venv(void){
  S_table venv = (S_table)TAB_empty();
  S_enter(venv, S_Symbol("print"), E_FunEntry(Tr_outermost(), Temp_namedlabel("print"), Ty_TyList(Ty_String(), NULL), Ty_Void()));
  S_enter(venv, S_Symbol("flush"), E_FunEntry(Tr_outermost(), Temp_namedlabel("flush"), NULL, Ty_Void()));
  S_enter(venv, S_Symbol("getchar"), E_FunEntry(Tr_outermost(), Temp_namedlabel("getchar"), NULL,Ty_String()));
  S_enter(venv, S_Symbol("ord"), E_FunEntry(Tr_outermost(), Temp_namedlabel("ord"), Ty_TyList(Ty_String(), NULL), Ty_Int()));
  S_enter(venv, S_Symbol("chr"), E_FunEntry(Tr_outermost(), Temp_namedlabel("chr"), Ty_TyList(Ty_Int(), NULL), Ty_String()));
  S_enter(venv, S_Symbol("size"), E_FunEntry(Tr_outermost(), Temp_namedlabel("size"), Ty_TyList(Ty_String(), NULL), Ty_Int()));
  S_enter(venv, S_Symbol("substring"), E_FunEntry(Tr_outermost(), Temp_namedlabel("substring"), Ty_TyList(Ty_String(), Ty_TyList(Ty_String(), NULL)), Ty_String()));
  S_enter(venv, S_Symbol("concat"), E_FunEntry(Tr_outermost(), Temp_namedlabel("concat"), Ty_TyList(Ty_String(), Ty_TyList(Ty_Int(), Ty_TyList(Ty_Int(), NULL))), Ty_String()));
  S_enter(venv, S_Symbol("not"), E_FunEntry(Tr_outermost(), Temp_namedlabel("not"), Ty_TyList(Ty_Int(), NULL), Ty_Int()));
  S_enter(venv, S_Symbol("exit"), E_FunEntry(Tr_outermost(), Temp_namedlabel("exit"), Ty_TyList(Ty_Int(), NULL), Ty_Void()));

  S_enter(venv, S_Symbol("initArray"), E_FunEntry(Tr_outermost(), Temp_namedlabel("initArray"), Ty_TyList(Ty_Int(), Ty_TyList(Ty_Int(), NULL)), Ty_Array(NULL)));

  S_enter(venv, S_Symbol("allocRecord"), E_FunEntry(Tr_outermost(), Temp_namedlabel("allocRecord"), Ty_TyList(Ty_Int(), NULL), Ty_Record(NULL)));

  S_enter(venv, S_Symbol("stringEqual"), E_FunEntry(Tr_outermost(), Temp_namedlabel("stringEqual"), Ty_TyList(Ty_String(), Ty_TyList(Ty_String(), NULL)), Ty_Int()));

  S_enter(venv, S_Symbol("printi"), E_FunEntry(Tr_outermost(), Temp_namedlabel("printi"), Ty_TyList(Ty_Int(), NULL), Ty_Void()));
  return venv;
}
