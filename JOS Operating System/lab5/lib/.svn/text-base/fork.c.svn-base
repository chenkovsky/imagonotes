// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
    void *addr = (void *) utf->utf_fault_va;
    uint32_t err = utf->utf_err;
    int r;

    // Check that the faulting access was (1) a write, and (2) to a
    // copy-on-write page.  If not, panic.
    // Hint:
    //   Use the read-only page table mappings at vpt
    //   (see <inc/memlayout.h>).

    // LAB 4: Your code here.

    // Allocate a new page, map it at a temporary location (PFTEMP),
    // copy the data from the old page to the new page, then move the new
    // page to the old page's address.
    // Hint:
    //   You should make three system calls.
    //   No need to explicitly delete the old page's mapping.

    // LAB 4: Your code here.
    //cprintf("in the pgfault handler in fork\n");
    /*if((uint32_t)ROUNDDOWN(addr,PGSIZE) == USTACKTOP-PGSIZE) {
        cprintf("user stack!!!!!!!!!!\n");
    }*/
    if (err & FEC_WR) {
        //cprintf("it's caused by fault write\n");
        if (vpt[PPN(addr)] & PTE_COW) {//first
            //ok it's caused by copy on write
            //cprintf("it's caused by copy on write\n");
            if ((r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W))) {//wrong not ROUNDDOWN(addr,PGSIZE)
                panic("pgfault->sys_page_alloc:%e",r);
            }
            //cprintf("before copy data from ROUNDDOWN(%x,PGSIZE) to PFTEMP\n",addr);
            memcpy(PFTEMP,ROUNDDOWN(addr,PGSIZE),PGSIZE);
            //cprintf("before map the PFTEMP to the ROUNDDOWN(%x,PGSIZE)\n",addr);
            if ((r= sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_P|PTE_U|PTE_W))) {/*seemly than PTE_USER is wrong*/
                panic("pgfault->sys_page_map:%e",r);
            }
            //cprintf("before unmap the PFTEMP\n");
            if ((r = sys_page_unmap(0,PFTEMP))) {
                panic("pgfault->sys_page_unmap:%e",r);
            }
            //cprintf("after unmap the PFTEMP\n");
        } else {
            panic("the fault write page is not copy on write\n");
        }
    } else {
        panic("the fault page isn't fault write,%eip is %x,va is %x,errcode is %d",utf->utf_eip,addr,err);
    }
    //it should be ok
    //panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why mark ours copy-on-write again
// if it was already copy-on-write?)//////why?
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
    int r;
    void *addr;
    pte_t pte;
    pte = vpt[pn];//current env's page table entry
    addr = (void *) (pn*PGSIZE);//virtual address
    uint32_t perm = pte & PTE_USER;
    /*if((uint32_t)addr == USTACKTOP-PGSIZE) {
        cprintf("duppage user stack!!!!!!!!!!\n");
    }*/
    if ((pte & PTE_COW)|(pte & PTE_W)) {
        /*the page need copy on write*/
        perm |= PTE_COW;
        perm &= ~PTE_W;
        if ((r = sys_page_map(0,addr,envid,addr,perm))) {
            return r;
        }
        return sys_page_map(0,addr,0,addr,perm);//also remap it
        /*now the page can't be writen*/
    }
    // LAB 4: Your code here.
    //panic("duppage not implemented");
    //may be wrong, it's not writable so just map it,although it may be no safe
    return sys_page_map(0, addr, envid, addr, perm);
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "env" and the user exception stack in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
    // LAB 4: Your code here.
    int pde_index;
    int pte_index;
    envid_t envid;
    unsigned pn = 0;
    int r;
    set_pgfault_handler(pgfault);/*set the pgfault handler for the father*/
    //cprintf("in fork before sys_exofork\n");
    envid = sys_exofork();//it use int to syscall
    //the child will come back use iret
    //cprintf("after fork->sys_exofork return:%d\n",envid);
    if (envid < 0) {
        /*err in the exofork*/
        return envid;
    }
    if (envid == 0) {
        /*if it's child,just return, the initial of it done by parent env*/
        //cprintf("i'm child,return\n");
        env = &envs[ENVX(sys_getenvid())];
        //cprintf("in fork child env's padding:%d",env->env_tf.tf_padding1);
        return 0;
    }
    /*it's parent*/
    //cprintf("before parent map for child\n");
    for (pde_index = 0;pde_index<VPD(UTOP);pde_index++) {
        /*upper than utop,such map has already done*/
        if (vpd[pde_index]) {
            for (pte_index = 0;pte_index < NPTENTRIES;pte_index++) {
                if (vpt[pn]&& (pn*PGSIZE) != (UXSTACKTOP - PGSIZE)) {
                    /*if the pte is not null and it's not pgfault stack*/
                    if ((r = duppage(envid,pn)))
                        panic("in duppage:%e",r);
                }
                pn++;
            }
        } else {
            pn += NPTENTRIES;/*skip 1024 virtual page*/
        }
    }
    //cprintf("after parent map for child\n");
    /*set the pgfault handler for child*/
    //cprintf("after set the pgfault handler\n");
    if ((r = sys_page_alloc(envid,(void *)(UXSTACKTOP - PGSIZE),PTE_P|PTE_U|PTE_W))) {
        panic("in fork->sys_page_alloc %e",r);
    }
    //cprintf("before set the pgfault up call for child\n");
    //cprintf("env->env_pgfault_upcall:%x\n",env->env_pgfault_upcall);
    sys_env_set_pgfault_upcall(envid,env->env_pgfault_upcall);
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE))) {
        panic("in fork->sys_env_status %e",r);
    }
    //cprintf("fork ok %d\n",sys_getenvid());
    return envid;
    //panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
    panic("sfork not implemented");
    return -E_INVAL;
}
