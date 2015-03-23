// User-level IPC library routines

#include <inc/lib.h>
// Receive a value via IPC and return it.
// If 'pg' is nonnull, then any page sent by the sender will be mapped at
//	that address.
// If 'fromenv' is nonnull, then store the IPC sender's envid in *fromenv.
// If 'perm' is nonnull, then store the IPC sender's page permission in *perm
//	(this is nonzero iff a page was successfully transferred to 'pg').
// If the system call fails, then store 0 in *fromenv and *perm (if
//	they're nonnull) and return the error.
//
// Hint:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
    // LAB 4: Your code here.
    //cprintf("env:%d is recieving\n",env->env_id);
    int r;
    if (!pg) {
        /*the reciever need an integer not a page*/
        pg = (void*)UTOP;
    }
    if ((r = sys_ipc_recv(pg))) {
        if (from_env_store) {
            *from_env_store = 0;
        }
        if (perm_store) {
            *perm_store = 0;
        }
        return r;
    }
    if (from_env_store) {
        *from_env_store = env->env_ipc_from;
    }
    if (perm_store) {
        *perm_store = env->env_ipc_perm;
    }
    cprintf("from env %d to env %d,recieve ok,value:%d\n",env->env_ipc_from,env->env_id,env->env_ipc_value);
    return env->env_ipc_value;
    panic("ipc_recv not implemented");
    return 0;
}

// Send 'val' (and 'pg' with 'perm', assuming 'pg' is nonnull) to 'toenv'.
// This function keeps trying until it succeeds.
// It should panic() on any error other than -E_IPC_NOT_RECV.
//
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
    // LAB 4: Your code here.
    int r;
    while (1) {
        if(!pg) {
            pg = (void*)UTOP;
        }
        r = sys_ipc_try_send(to_env,val,pg,perm);
        if (r == 0 || r == 1) {
            break;
        } else if (r != -E_IPC_NOT_RECV) {
            /*unknown err*/
            panic("ipc_send not ok: %e\n",r);
        }
        sys_yield();
    }
    cprintf("env %d to env %d send ok,value:%d\n",env->env_id,to_env,val);
}

