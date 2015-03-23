#ifndef _ENV_H
#define _ENV_H
#include "types.h"

//E_enventry E_VarEntry(Ty_ty ty);
//E_enventry E_FunEntry(Ty_tyList formals, Ty_ty result);
S_table E_base_tenv(void);
S_table E_base_venv(void);

#endif /* _ENV_H_ */
