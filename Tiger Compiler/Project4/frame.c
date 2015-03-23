#include <stdio.h>
#include <string.h>
#include "util.h"
#include "symbol.h"
#include "temp.h"
#include "tree.h"
#include "frame.h"

Temp_label F_name(F_frame f)
{
  assert(f);
  return f->label;
}

unsigned int SavedRegNum = 5;

Temp_temp  fp = NULL;

Temp_temp F_FP(void)
{
  //implement here
  if(fp == NULL){
    fp = Temp_newtemp();
  }
  return fp;
}


/******************************************
return frame pointer
******************************************/
Temp_temp SP = NULL;
Temp_temp F_SP(void)
{
  //implement here
  if(SP == NULL){
    SP = Temp_newtemp();
  }
  return SP;
}

/******************************************
return the temp holding return value
******************************************/
Temp_temp RV = NULL;
Temp_temp F_RV(void)
{
  //implement here;
  if(RV == NULL){
    RV = Temp_newtemp();
  }
  return RV;
}


/******************************************
Support code
******************************************/
Temp_temp ScratchTemp = NULL;
Temp_temp F_ScratchTemp(void)
{
  if(!ScratchTemp)
    ScratchTemp = Temp_newtemp();
  return ScratchTemp;
}

Temp_temp AssemScratchTemp1 = NULL;
Temp_temp AssemScratchTemp2 = NULL;
Temp_temp F_AssemScratchTemp(int i)
{
  if(i == 0){
    if(!AssemScratchTemp1)
      AssemScratchTemp1 = Temp_newtemp();
    return AssemScratchTemp1;
  }
  else if(i == 1){
    if(!AssemScratchTemp2)
      AssemScratchTemp2 = Temp_newtemp();
    return AssemScratchTemp2;
  }
  else{
    assert(0);
  }
}

F_frame globalCurrentFrame = NULL;

int F_newSpillLocation()
{
  (globalCurrentFrame->locals)++;
  return -((globalCurrentFrame->locals)* 4);// + SavedRegNum
}
F_accessList F_AccessList(F_access access){
  F_accessList list = checked_malloc(sizeof(struct F_accessList_));
  list->head = access;
  return list;
}
F_access InFrame(int offset){
  F_access access = checked_malloc(sizeof(struct F_access_));
  access->kind = inFrame;
  access->u.offset = offset;
  return access;
}
F_access InReg(Temp_temp reg){
  F_access access = checked_malloc(sizeof(struct F_access_));
  access->kind = inReg;
  access->u.reg = reg;
  return access;
}
//my codestatic int cur_local = 0;
//hasn't alloc static link
F_frame F_newFrame(Temp_label name, U_boolList formals){
  F_frame frame = (F_frame)checked_malloc(sizeof(struct F_frame_));
  frame->locals = 5;
  frame->label = name;
  F_accessList list = frame->formal_location;
  int cur_offset = 4;
  while(formals){
    F_access access = NULL;
    if(formals->head){
      access = InFrame((cur_offset+=4));
    }else{
      access = InReg(F_ScratchTemp());
    }
    if(list){
      list->tail = F_AccessList(access);
      list = list->tail;
    }else{
      frame->formal_location = F_AccessList(access);
      list = frame->formal_location;
    }
    formals = formals->tail;
  }
  return frame;
}
F_accessList F_formals(F_frame f){
  return f->formal_location;
}
//Also haven't compute the location of variables
F_access F_allocLocal(F_frame f, bool escape){
  F_access access = NULL;
  if(escape){
    access = InFrame(-((f->locals+=1)*4));
  }else{
    access = InReg(F_ScratchTemp());
  }
  F_accessList l = f->formal_location;
  F_accessList tail = l;
  //list->head = access;
  while(l){
    tail = l;
    l = l->tail;
  }
  if(tail){
    tail->tail = F_AccessList(access);
  }else{
    f->formal_location = F_AccessList(access);
  }
  return access;
}


F_fragList F_FragList(F_frag head, F_fragList tail){
  F_fragList fl = checked_malloc(sizeof(struct F_fragList_));
  fl->head = head;
  fl->tail = tail;
  return fl;
}
F_frag F_StringFrag(Temp_label label, string str){
  F_frag f = checked_malloc(sizeof(struct F_frag_));
  f->kind = F_stringFrag;
  f->u.stringg.str = str;
  f->u.stringg.label = label;
  return f;
}
F_frag F_ProgFrag(T_stm body, F_frame frame){
  F_frag f = checked_malloc(sizeof(struct F_frag_));
  f->kind = F_progFrag;
  f->u.proc.body = body;
  f->u.proc.frame = frame;
  return f;
}
