/*
frame.h
*/
#ifndef _FRAME_H_
#define _FRAME_H_
#include "tree.h"


typedef struct F_frame_ *F_frame;
typedef struct F_access_ *F_access;

typedef struct F_accessList_ *F_accessList;
struct F_accessList_ {F_access head;F_accessList tail;};

//Temp_label F_name(F_frame f);

struct F_access_
	{
	  enum{inFrame,inReg} kind;
	  union{
	  	int offset;
		Temp_temp reg;
	  	}u;
	};

struct F_frame_ 
	{
	     F_accessList formal_location;
	     void * ins;
	     unsigned int locals;
	     Temp_label label;
	};

extern Temp_temp F_FP(void);
extern Temp_temp F_SP(void);
extern Temp_temp F_RV(void);
extern Temp_temp F_ScratchTemp(void);

extern Temp_temp F_AssemScratchTemp(int i);

typedef struct F_frag_ *F_frag;
struct F_frag_ {
	enum{F_stringFrag,F_progFrag}kind;
	union{
		struct {Temp_label label;string str;}stringg;
		struct {T_stm body;F_frame frame;} proc;
		}u;
	};

typedef struct F_fragList_ *F_fragList;
struct F_fragList_ {F_frag head;F_fragList tail;};
//my code
extern F_frame F_newFrame(Temp_label name, U_boolList formals);
extern Temp_label F_name(F_frame f);
extern F_accessList F_formals(F_frame f);
extern F_access F_allocLocal(F_frame f, bool escape);

//extern const int F_wordSize;

extern F_fragList F_FragList(F_frag head, F_fragList tail);
extern F_frag F_StringFrag(Temp_label label, string str);
extern F_frag F_ProgFrag(T_stm body, F_frame frame);
#endif /* _FRAME_H_ */
