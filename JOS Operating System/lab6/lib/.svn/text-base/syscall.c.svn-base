// System call stubs.

#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;

	// Generic system call: pass system call number in AX,
	// up to five parameters in DX, CX, BX, DI, SI.
	// Interrupt kernel with T_SYSCALL.
	//
	// The "volatile" tells the assembler not to optimize
	// this instruction away just because we don't use the
	// return value.
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	/*asm volatile("int %1\n"
		: "=a" (ret)
		: "i" (T_SYSCALL),
		  "a" (num),
		  "d" (a1),
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");*/
    // maybe it's wrong, because of the eflags
	__asm__ volatile(
                /*"pushl %%ecx\n\t"
                "pushl %%edx\n\t"
                "pushl %%ebx\n\t"
                "pushl %%esi\n\t"
                "pushl %%edi\n\t"*/
                "pushl %%ebp\n\t"
                "pushfl\n\t"
                "pushl %6\n\t"//pushl the fifth arguements to the user stack
                                //we must pushl it before ebpchanges
                "pushl %%esp\n\t"
                "popl %%ebp\n\t"//esp will be changed so store it in ebp
                 //"xchg %%bx, %%bx\n\t"
                 "leal 1f,%%esi\n\t"
                 //"xchg %%bx,%%bx\n\t"
                 "sysenter\n\t"
                 "1:\n\t"
                 //"xchg %%bx,%%bx\n\t"
                 "addl $4,%%esp\n\t"
                 //"xchg %%bx, %%bx\n\t"
                 "popfl\n\t"
                 //"xchg %%bx, %%bx\n\t"
                 "popl %%ebp\n\t"
                 /*"popl %%edi\n\t"
                 "popl %%esi\n\t"
                 "popl %%ebx\n\t"
                 "popl %%edx\n\t"
                 "popl %%ecx"*/
                 : "=a" (ret)
                 : "a" (num),
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4),
                   "S" (a5)
                   :"cc","memory");
	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned
sys_time_msec()
{
	return (unsigned) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_ide_read(uint32_t secno, const void *dst, size_t nsecs)
{
    int r;
    //cprintf("sys_ide-read dst:%x\n",dst);
	if((r = syscall(SYS_ide_read, 1, secno, (uint32_t)dst, nsecs, 0, 0))){
        return r;
    }
    //cprintf("after sysenter,we wait the ide_read finish\n");
    while(env->env_tf.tf_padding2) {
        //cprintf("yield!!!!!!!!!!!!\n");
        sys_yield();
    }
    return r;
}

int
sys_ide_write(uint32_t secno, const void *src, size_t nsecs)
{
    int r;
	if((r = syscall(SYS_ide_write, 1, secno, (uint32_t)src, nsecs, 0, 0))){
        return r;
    }
    //cprintf("after sysenter,we wait the ide_write finish\n");
    while(env->env_tf.tf_padding2) {
	sys_yield();
    }
    return r;
}

int sys_send_packet(void *addr,int size){
    return syscall(SYS_send_packet,0,(uint32_t)addr,size,0,0,0);
}
int sys_recv_packet(void *addr,int *size){
    return syscall(SYS_recv_packet,0,(uint32_t)addr,(uint32_t)size,0,0,0);
}

