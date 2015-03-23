/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
    // Check that the user has permission to read memory [s, s+len).
    // Destroy the environment if not.

    // LAB 3: Your code here.
    user_mem_assert(curenv,s,len,PTE_P);
    // Print the string supplied by the user.
    cprintf("%.*s", len, s);
}

// Read a character from the system console.
// Returns the character.
static int
sys_cgetc(void)
{
    int c;

    // The cons_getc() primitive doesn't wait for a character,
    // but the sys_cgetc() system call does.
    while ((c = cons_getc()) == 0)
        /* do nothing */;

    return c;
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
    return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
    int r;
    struct Env *e;

    if ((r = envid2env(envid, &e, 1)) < 0)
        return r;
    if (e == curenv)
        cprintf("[%08x] exiting gracefully\n", curenv->env_id);
    else
        cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
    env_destroy(e);
    return 0;
}

static int sys_dump_env(void){
    cprintf("env_id = %08x\n",curenv->env_id);
    cprintf("env_parent_id = %08x\n",curenv->env_parent_id);
    cprintf("env_runs = %d\n",curenv->env_runs);
    cprintf("env_pgdir = %08x\n",curenv->env_pgdir);
    cprintf("env_cr3 = %08x\n",curenv->env_cr3);
    cprintf("env_syscalls = %d\n",curenv->env_syscalls);
    return 0;
}
// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
    sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
static envid_t
sys_exofork(void)
{
    // Create the new environment with env_alloc(), from kern/env.c.
    // It should be left as env_alloc created it, except that
    // status is set to ENV_NOT_RUNNABLE, and the register set is copied
    // from the current environment -- but tweaked so sys_exofork
    // will appear to return 0.

    // LAB 4: Your code here.
    //panic("sys_exofork not implemented");
    struct Env *new_env;
    //cprintf("sys_exofork here\n");
    if (env_alloc(&new_env,curenv->env_id)) {
        //cprintf("env alloc fails\n");
        return -E_NO_FREE_ENV;
    }
    new_env->env_status = ENV_NOT_RUNNABLE;
    new_env->env_tf = curenv->env_tf;
    new_env->env_pgfault_upcall = curenv->env_pgfault_upcall;
    //new_env->env_tf.tf_regs.reg_eax = new_env->env_id;
    new_env->env_tf.tf_regs.reg_eax = 0;
    //cprintf("in sys_exofork,the new_env's id is %d\n",new_env->env_id);
    return new_env->env_id;
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
    // Hint: Use the 'envid2env' function from kern/env.c to translate an
    // envid to a struct Env.
    // You should set envid2env's third argument to 1, which will
    // check whether the current environment has permission to set
    // envid's status.

    // LAB 4: Your code here.
    struct Env *env;
    if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
        return -E_INVAL;
    }
    if (envid2env(envid,&env,1)) {
        return -E_BAD_ENV;
    }
    env->env_status = status;
    return 0;
    panic("sys_env_set_status not implemented");
}

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3) with interrupts enabled.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
    // LAB 4: Your code here.
    // Remember to check whether the user has supplied us with a good
    // address!
    struct Env *env;
    int r;//may be this method is wrong,because i use the padding in the tf to know how it syscall
    cprintf("sys set trapframe:envid:%d,tf:%x\n",envid,tf);
    if (( r = envid2env(envid,&env,1))) {
        return r;
    }
    env->env_tf = *tf;
    return 0;
    panic("sys_set_trapframe not implemented");
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
    // LAB 4: Your code here.
    struct Env *env;
    if (envid2env(envid,&env,1)) {
        return -E_BAD_ENV;
    }
    env->env_pgfault_upcall = func;
    return 0;
    panic("sys_env_set_pgfault_upcall not implemented");
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
    // Hint: This function is a wrapper around page_alloc() and
    //   page_insert() from kern/pmap.c.
    //   Most of the new code you write should be to check the
    //   parameters for correctness.
    //   If page_insert() fails, remember to free the page you
    //   allocated!

    // LAB 4: Your code here.
    struct Env *env;
    struct Page *page;
    //cprintf("parameter envid = %d,va = %x,perm = %x\n",envid,va,perm);
    if (((uint32_t)va >= UTOP) || (((uint32_t)va) % PGSIZE)) {
        cprintf("va is invalid\n");
        return -E_INVAL;
    }
    if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~(PTE_U|PTE_W|PTE_P|PTE_AVAIL))) {
        cprintf("perm is invalid\n");
        return -E_INVAL;
    }
    if (envid2env(envid,&env,1)) {
        cprintf("env is not ok\n");
        return -E_BAD_ENV;
    }
    if (page_alloc(&page)) {
        cprintf("page_alloc is not ok\n");
        return -E_NO_MEM;
    }
    if (page_insert(env->env_pgdir,page,va,perm)) {
        cprintf("page insert is not ok\n");
        page_free(page);
        return -E_NO_MEM;
    }
    memset(page2kva(page),0,PGSIZE);
    lcr3(curenv->env_cr3);
    //cprintf("the alloc is ok\n");
    return 0;
    panic("sys_page_alloc not implemented");
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
             envid_t dstenvid, void *dstva, int perm)
{
    // Hint: This function is a wrapper around page_lookup() and
    //   page_insert() from kern/pmap.c.
    //   Again, most of the new code you write should be to check the
    //   parameters for correctness.
    //   Use the third argument to page_lookup() to
    //   check the current permissions on the page.

    // LAB 4: Your code here.
    struct Env *src_env;
    struct Env *dst_env;

    struct Page *page;
    pte_t *pte_store;
    /*if ((uint32_t)srcva == USTACKTOP-PGSIZE||(uint32_t)dstva == USTACKTOP-PGSIZE) {
        cprintf("the stack arguement in KERN pgmap srcenv:%d,srcva:%x,dstenv:%d,dstva:%x,perm:%x\n",srcenvid,srcva,dstenvid,dstva,perm);
    }*/
    if (envid2env(srcenvid,&src_env,1)|| envid2env(dstenvid,&dst_env,1)) {
        return -E_BAD_ENV;
    }
    page = page_lookup(src_env->env_pgdir,srcva,&pte_store);
    //cprintf("in map parameter perm = %x\n",perm);
    if (page == NULL) {
        cprintf("page fails\n");
        return -E_INVAL;
    }
    if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~(PTE_U|PTE_W|PTE_P|PTE_AVAIL)) || (!(*pte_store & PTE_W) && (perm & PTE_W))) {
        cprintf("perm invalid\n");
        return -E_INVAL;
    }
    if ((((uint32_t)srcva) >= UTOP) || (((uint32_t)dstva) >= UTOP) || (((uint32_t)srcva) % PGSIZE) || (((uint32_t)dstva) % PGSIZE)) {
        cprintf("address invalid\n");
        return -E_INVAL;
    }
    if (page_insert(dst_env->env_pgdir,page,dstva,perm)) {
        cprintf("insert invalid\n");
        return -E_NO_MEM;
    }
    /*page = page_lookup(dst_env->env_pgdir,dstva,&pte_store);
    if ((uint32_t)dstva == USTACKTOP-PGSIZE) {
        cprintf("now the page is COW?%x\n",*pte_store&0x807);
    }*/
    lcr3(curenv->env_cr3);
    return 0;
    panic("sys_page_map not implemented");
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
    // Hint: This function is a wrapper around page_remove().

    // LAB 4: Your code here.
    struct Env *env;
    //cprintf("after envid2env in sys_page_unmap\n");
    if (envid2env(envid,&env,1)) {
        return -E_BAD_ENV;
    }
    if ((((uint32_t)va) >= UTOP) || (((uint32_t)va) %PGSIZE)) {
        return -E_INVAL;
    }
    //cprintf("page remove in sys_page_unmap va:%x\n",va);
    page_remove(env->env_pgdir,va);
    //cprintf("page removed in the sys_page_unmap\n");
    lcr3(curenv->env_cr3);
    return 0;
    panic("sys_page_unmap not implemented");
}

// Try to send 'value' to the target env 'envid'.
// If va != 0, then also send page currently mapped at 'va',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target has not requested IPC with sys_ipc_recv.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused ipc_recv system call.
//
// If the sender sends a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc doesn't happen unless no errors occur.
//
// Returns 0 on success where no page mapping occurs,
// 1 on success where a page mapping occurs, and < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
    // LAB 4: Your code here.
    int r;
    int ret = 0;
    struct Env *dstenv;
    if ((r = envid2env(envid,&dstenv,0))) {//needn't check
        cprintf("invalid env\n");
        return r;
    }
    if (!dstenv->env_ipc_recving) {
        /*not recieving*/
        //cprintf("the dstenv:%d is not recieving\n",dstenv->env_id);
        return -E_IPC_NOT_RECV;
    }
    if ((uint32_t)srcva < UTOP) {
        /*send a page then check parameter*/
        if ((uint32_t)srcva % PGSIZE) {
            cprintf("invalid srcva\n");
            return -E_INVAL;
        }
        if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~(PTE_U|PTE_W|PTE_P|PTE_AVAIL))) {// || (!(*pte_store & PTE_W) && (perm & PTE_W))
            cprintf("invalid perm\n");
            return -E_INVAL;
        }
    }
    dstenv->env_ipc_recving = 0;//reset it
    dstenv->env_ipc_perm = 0;//initial with low perm
    if((uint32_t)srcva < UTOP && (uint32_t)dstenv->env_ipc_dstva < UTOP) {
        cprintf("syscall send page\n");
        if((r = sys_page_map(0,srcva,envid,(void*)dstenv->env_ipc_dstva,perm))) {
            cprintf("the page map is not ok\n");
            return r;
        }
        cprintf("syscall send page ok\n");
        dstenv->env_ipc_perm = perm;
        ret = 1;
    }
    dstenv->env_ipc_value = value;
    dstenv->env_ipc_from = curenv->env_id;
    //cprintf("set dstenv->env_ipc_from:%d\n",dstenv->env_ipc_from);
    dstenv->env_status = ENV_RUNNABLE;
    return ret;
    //panic("sys_ipc_try_send not implemented");
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
    // LAB 4: Your code here.
    int r;
    if((uint32_t)dstva < UTOP) {
        /*recv page*/
        if((uint32_t)dstva % PGSIZE) {
            return -E_INVAL;
        }else{
            cprintf("want get map page\n");
            curenv->env_ipc_dstva = dstva;
        }
    }else{
        /*if not recieve page set the dstva as UTOP*/
        curenv->env_ipc_dstva = (void *) UTOP;
    }
    curenv->env_ipc_recving = 1;
    curenv->env_status = ENV_NOT_RUNNABLE;
    curenv->env_ipc_perm = 0;
    curenv->env_ipc_value = 0;
    curenv->env_ipc_from = 0;
    //cprintf("curenv:%d recv set ok\n",curenv->env_id);
    curenv->env_tf.tf_regs.reg_eax = 0;
    sched_yield();
    return 0;//never return
    panic("sys_ipc_recv not implemented");
    return 0;
}


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
    // Call the function corresponding to the 'syscallno' parameter.
    // Return any appropriate return value.
    // LAB 3: Your code here.
    //cprintf("kern syscall\n");
    int r = 0;
    switch (syscallno) {
    case SYS_cputs:
        //cprintf("cputs\n");
        sys_cputs((char*)a1,(size_t)a2);
        break;
    case SYS_cgetc:
        //cprintf("sys_cgetc\n");
        r = (int32_t)sys_cgetc();
        break;
    case SYS_getenvid:
        //cprintf("sys_getenvid\n");
        r = (int32_t)sys_getenvid();
        break;
    case SYS_env_destroy:
        //cprintf("sys_env_destroy\n");
        r = (int32_t)sys_env_destroy((envid_t)a1);
        break;
    case SYS_dump_env:
        //cprintf("sys_dump_env\n");
        r = sys_dump_env();
        break;
    case SYS_page_alloc:
        r = sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
        break;
    case SYS_page_map:
        r = sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
        break;
    case SYS_page_unmap:
        r = sys_page_unmap((envid_t)a1,(void*)a2);
        break;
    case SYS_exofork:
        r = sys_exofork();
        break;
    case SYS_env_set_status:
        r = sys_env_set_status((envid_t)a1,(int)a2);
        break;
    case SYS_env_set_trapframe:
        r = sys_env_set_trapframe((envid_t)a1,(struct Trapframe *)a2);
        break;
    case SYS_env_set_pgfault_upcall:
        r = sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
        break;
    case SYS_yield:
        sys_yield();
        break;
    case SYS_ipc_try_send:
        r = sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned) a4);
        break;
    case SYS_ipc_recv:
        r = sys_ipc_recv((void*)a1);
        break;
    default:
        return -E_INVAL;
    }
    curenv->env_syscalls++;
    return r;
    //panic("syscall not implemented");
}

void syscallwrap(struct SysFrame *sf){
    //save some register
    curenv->env_tf.tf_regs = sf->tf_regs;
    curenv->env_tf.tf_ds = sf->sf_ds;
    curenv->env_tf.tf_es = sf->sf_es;
    curenv->env_tf.tf_esp = sf->sf_esp;//the return esp of the user stack
    curenv->env_tf.tf_eip = sf->sf_eip;//the return address in the lib/syscall which on user stack
    curenv->env_tf.tf_regs.reg_esi = sf->sf_eip;//the restore the return address to the esi
    curenv->env_tf.tf_eflags = sf->sf_eflags;
    //cprintf("is the eflags of %d :%d interruptable in syscallwrap? %d\n",curenv->env_id,sf->sf_eflags,(sf->sf_eflags&FL_IF));
    //curenv->env_tf.tf_regs.reg_ecx = sf->sf_esp;
    //curenv->env_tf.tf_regs.reg_edx = sf->sf_eip;
    /*cprintf("the tf's esp is--%x\n",sf->sf_esp);
    cprintf("the tf's eip is--%x\n",sf->sf_eip);
    cprintf("reg_eax = %x\n",sf->tf_regs.reg_eax);
    //curenv->env_tf.tf_esp = tf->tf_regs.reg_ebp;
    //curenv->env_tf.tf_eip = tf->tf_regs.reg_esi; */  
    /*if(sf->tf_regs.reg_eax == SYS_page_map){
    cprintf("reg_edx = %x\n",sf->tf_regs.reg_edx);
    cprintf("reg_ecx = %x\n",sf->tf_regs.reg_ecx); 
    cprintf("reg_ebx = %x\n",sf->tf_regs.reg_ebx);
    cprintf("reg_edi = %x\n",sf->tf_regs.reg_edi);
    cprintf("reg_esi = %x\n",sf->tf_regs.reg_esi); 
    }*/
    //cprintf("eflags store %x\n",curenv->env_tf.tf_eflags);
    curenv->env_tf.tf_padding1 = 1;//use to check whether this use sysenter
    sf->tf_regs.reg_eax = syscall(sf->tf_regs.reg_eax,
                                  sf->tf_regs.reg_edx,
                                  sf->tf_regs.reg_ecx,
                                  sf->tf_regs.reg_ebx,
                                  sf->tf_regs.reg_edi,
                                  sf->tf_regs.reg_esi);
    curenv->env_tf.tf_padding1 = 0;
    //curenv->env_tf.tf_regs.reg_eax = sf->tf_regs.reg_eax;
    sf->tf_regs.reg_esi = sf->sf_eip;
    //cprintf("got here in syscallwrap\n");
    return;
}



