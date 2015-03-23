#ifndef _ESCAPE_H_
#define _ESCAPE_H_
#include "absyn.h"
#include "util.h"
void Esc_findEscape(A_exp exp);
typedef struct Escape_entry_ *Escape_entry;
struct Escape_entry_{
  int depth;
  void* esc;
};
Escape_entry EscapeEntry(int depth, void* esc){
  Escape_entry e = checked_malloc(sizeof(struct Escape_entry_));
  e->depth = depth;
  e->esc = esc;
  return e;
}
#endif /* _ESCAPE_H_ */
