#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>
#include <inc/string.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>

static struct Taskstate ts;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = { { 0}};
struct Pseudodesc idt_pd = {
    sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
    static const char * const excnames[] = {
        "Divide error",
        "Debug",
        "Non-Maskable Interrupt",
        "Breakpoint",
        "Overflow",
        "BOUND Range Exceeded",
        "Invalid Opcode",
        "Device Not Available",
        "Double Fault",
        "Coprocessor Segment Overrun",
        "Invalid TSS",
        "Segment Not Present",
        "Stack Fault",
        "General Protection",
        "Page Fault",
        "(unknown trap)",
        "x87 FPU Floating-Point Error",
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(excnames[0]))
        return excnames[trapno];
    if (trapno == T_SYSCALL)
        return "System call";
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
        return "Hardware Interrupt";
    return "(unknown trap)";
}


void
idt_init(void)
{
    extern struct Segdesc gdt[];

    // LAB 3: Your code here.
    extern uint32_t handler0;
    extern uint32_t handler1;
    extern uint32_t handler2;
    extern uint32_t handler3;
    extern uint32_t handler4;
    extern uint32_t handler5;
    extern uint32_t handler6;
    extern uint32_t handler7;
    extern uint32_t handler8;
    extern uint32_t handler9;
    extern uint32_t handler10;
    extern uint32_t handler11;
    extern uint32_t handler12;
    extern uint32_t handler13;
    extern uint32_t handler14;
    extern uint32_t handler15;
    extern uint32_t handler16;
    extern uint32_t handler17;
    extern uint32_t handler18;
    extern uint32_t handler19;
    extern uint32_t handler48;

    extern uint32_t inthandler0;
    extern uint32_t inthandler1;
    extern uint32_t inthandler2;
    extern uint32_t inthandler3;
    extern uint32_t inthandler4;
    extern uint32_t inthandler5;
    extern uint32_t inthandler6;
    extern uint32_t inthandler7;
    extern uint32_t inthandler8;
    extern uint32_t inthandler9;
    extern uint32_t inthandler10;
    extern uint32_t inthandler11;
    extern uint32_t inthandler12;
    extern uint32_t inthandler13;
    extern uint32_t inthandler14;
    extern uint32_t inthandler15;
    //extern uint32_t sysenterhandler;
    SETGATE(idt[T_DIVIDE], 0, GD_KT, &handler0, 0);
    SETGATE(idt[T_DEBUG], 0, GD_KT, &handler1, 0);
    SETGATE(idt[T_NMI], 0, GD_KT, &handler2, 0);
    SETGATE(idt[T_BRKPT], 0, GD_KT, &handler3, 3);/*low Privilege*/
    SETGATE(idt[T_OFLOW], 0, GD_KT, &handler4, 0);
    SETGATE(idt[T_BOUND], 0, GD_KT, &handler5, 0);
    SETGATE(idt[T_ILLOP], 0, GD_KT, &handler6, 0);
    SETGATE(idt[T_DEVICE], 0, GD_KT, &handler7, 0);
    SETGATE(idt[T_DBLFLT], 0, GD_KT, &handler8, 0);

    SETGATE(idt[T_TSS], 0, GD_KT, &handler10, 0);
    SETGATE(idt[T_SEGNP], 0, GD_KT, &handler11, 0);
    SETGATE(idt[T_STACK], 0, GD_KT, &handler12, 0);
    SETGATE(idt[T_GPFLT], 0, GD_KT, &handler13, 0);
    SETGATE(idt[T_PGFLT], 0, GD_KT, &handler14, 0);

    SETGATE(idt[T_FPERR], 0, GD_KT, &handler16, 0);
    SETGATE(idt[T_ALIGN], 0, GD_KT, &handler17, 0);
    SETGATE(idt[T_MCHK], 0, GD_KT, &handler18, 0);
    SETGATE(idt[T_SIMDERR], 0, GD_KT, &handler19, 0);
    SETGATE(idt[T_SYSCALL],0,GD_KT,&handler48,3);
    SETGATE(idt[IRQ_OFFSET],0,GD_KT,&inthandler0,0);
    SETGATE(idt[IRQ_OFFSET+1],0,GD_KT,&inthandler1,0);
    SETGATE(idt[IRQ_OFFSET+2],0,GD_KT,&inthandler2,0);
    SETGATE(idt[IRQ_OFFSET+3],0,GD_KT,&inthandler3,0);
    SETGATE(idt[IRQ_OFFSET+4],0,GD_KT,&inthandler4,0);
    SETGATE(idt[IRQ_OFFSET+5],0,GD_KT,&inthandler5,0);
    SETGATE(idt[IRQ_OFFSET+6],0,GD_KT,&inthandler6,0);
    SETGATE(idt[IRQ_OFFSET+7],0,GD_KT,&inthandler7,0);
    SETGATE(idt[IRQ_OFFSET+8],0,GD_KT,&inthandler8,0);
    SETGATE(idt[IRQ_OFFSET+9],0,GD_KT,&inthandler9,0);
    SETGATE(idt[IRQ_OFFSET+10],0,GD_KT,&inthandler10,0);
    SETGATE(idt[IRQ_OFFSET+11],0,GD_KT,&inthandler11,0);
    SETGATE(idt[IRQ_OFFSET+12],0,GD_KT,&inthandler12,0);
    SETGATE(idt[IRQ_OFFSET+13],0,GD_KT,&inthandler13,0);
    SETGATE(idt[IRQ_OFFSET+14],0,GD_KT,&inthandler14,0);
    SETGATE(idt[IRQ_OFFSET+15],0,GD_KT,&inthandler15,0);
    // Setup a TSS so that we get the right stack
    // when we trap to the kernel.


    ts.ts_esp0 = KSTACKTOP;
    ts.ts_ss0 = GD_KD;

    // Initialize the TSS field of the gdt.
    gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
                             sizeof(struct Taskstate), 0);
    gdt[GD_TSS >> 3].sd_s = 0;

    // Load the TSS
    ltr(GD_TSS);

    // Load the IDT
    asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
    cprintf("TRAP frame at %p\n", tf);
    print_regs(&tf->tf_regs);
    cprintf("  es   0x----%04x\n", tf->tf_es);
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
    cprintf("  err  0x%08x\n", tf->tf_err);
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x\n", tf->tf_eflags);
    cprintf("  esp  0x%08x\n", tf->tf_esp);
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
    cprintf("  edi  0x%08x\n", regs->reg_edi);
    cprintf("  esi  0x%08x\n", regs->reg_esi);
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
    cprintf("  edx  0x%08x\n", regs->reg_edx);
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
    cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static void
trap_dispatch(struct Trapframe *tf)
{
    // Handle processor exceptions.
    // LAB 3: Your code here.
    /*if(tf->tf_trapno != 0x20) {
        print_trapframe(tf);
    }*/
    switch (tf->tf_trapno) {
    case T_PGFLT:
        page_fault_handler(tf);
        return;
    case T_BRKPT:
    case T_DEBUG:
        //cprintf("BRKPT here\n");
        monitor(tf);
        return;
    case T_SYSCALL:
        tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
                                      tf->tf_regs.reg_edx,
                                      tf->tf_regs.reg_ecx,
                                      tf->tf_regs.reg_ebx,
                                      tf->tf_regs.reg_edi,
                                      tf->tf_regs.reg_esi);
        return;
    default:
        break;
    }
    // Handle clock interrupts.
    // LAB 4: Your code here.
    if(tf->tf_trapno == IRQ_OFFSET) {
        sched_yield();
    }
    // Handle spurious interupts
    // The hardware sometimes raises these because of noise on the
    // IRQ line or other reasons. We don't care.
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
        cprintf("Spurious interrupt on irq 7\n");
        print_trapframe(tf);
        return;
    }


    // Unexpected trap: The user process or the kernel has a bug.
    print_trapframe(tf);
    if (tf->tf_cs == GD_KT)
        panic("unhandled trap in kernel");
    else {
        env_destroy(curenv);
        return;
    }
}

void
trap(struct Trapframe *tf)
{
    if ((tf->tf_cs & 3) == 3) {
        // Trapped from user mode.
        // Copy trap frame (which is currently on the stack)
        // into 'curenv->env_tf', so that running the environment
        // will restart at the trap point.
        assert(curenv);
        curenv->env_tf = *tf;
        // The trapframe on the stack should be ignored from here on.
        tf = &curenv->env_tf;
    }

    // Dispatch based on what type of trap occurred
    //cprintf("in trap_dispatch:callno:%d,trapno:%d\n",tf->tf_regs.reg_eax,tf->tf_trapno);
    trap_dispatch(tf);
    
    // If we made it to this point, then no other environment was
    // scheduled, so we should return to the current environment
    // if doing so makes sense.
    if (curenv && curenv->env_status == ENV_RUNNABLE)
        env_run(curenv);
    else
        sched_yield();
}


void
page_fault_handler(struct Trapframe *tf)
{
    uint32_t fault_va;

    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();

    // Handle kernel-mode page faults.

    // LAB 3: Your code here.
    if ((tf->tf_cs & 3)!= 3) {//means that the cs is GD_KT
        panic("err of page_fault_handler: page fault in the kernel mode.\n the vitual address is %x,eip is %x\n",fault_va,tf->tf_eip);
    }
    // We've already handled kernel-mode exceptions, so if we get here,
    // the page fault happened in user mode.

    // Call the environment's page fault upcall, if one exists.  Set up a
    // page fault stack frame on the user exception stack (below
    // UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
    //
    // The page fault upcall might cause another page fault, in which case
    // we branch to the page fault upcall recursively, pushing another
    // page fault stack frame on top of the user exception stack.
    //
    // The trap handler needs one word of scratch space at the top of the
    // trap-time stack in order to return.  In the non-recursive case, we
    // don't have to worry about this because the top of the regular user
    // stack is free.  In the recursive case, this means we have to leave
    // an extra word between the current top of the exception stack and
    // the new stack frame because the exception stack _is_ the trap-time
    // stack.
    //
    // If there's no page fault upcall, the environment didn't allocate a
    // page for its exception stack, or the exception stack overflows,
    // then destroy the environment that caused the fault.
    //
    // Hints:
    //   user_mem_assert() and env_run() are useful here.
    //   To change what the user environment runs, modify 'curenv->env_tf'
    //   (the 'tf' variable points at 'curenv->env_tf').

    // LAB 4: Your code here.
    struct UTrapframe uf;
    uint32_t utfa;
    uint32_t retespaddr;
    //cprintf("start page_fault_handler fault va:%x\n",fault_va);
    if (curenv->env_pgfault_upcall) {
        //cprintf("before check upcall,upcall:%x\n",curenv->env_pgfault_upcall);
        user_mem_assert(curenv,(void*)curenv->env_pgfault_upcall,sizeof(int),PTE_P|PTE_U);
        //cprintf("before check stack %d\n",(void *)UXSTACKTOP-PGSIZE);
        user_mem_assert(curenv,(void *)UXSTACKTOP-PGSIZE,PGSIZE,PTE_P|PTE_U|PTE_W);
        //cprintf("after check stack\n");
        memset(&uf,0,sizeof(struct UTrapframe));
        /*set the values in the utrapframe*/
        uf.utf_fault_va = fault_va;
        //cprintf("trap.c the fault va is %x\n",fault_va);
        uf.utf_err = tf->tf_err;//PGFUALT
        //cprintf("trap.c the fault err is %d\n",T_PGFLT & 7);
        uf.utf_eip = tf->tf_eip;
        uf.utf_regs = tf->tf_regs;
        uf.utf_eflags = tf->tf_eflags;
        uf.utf_esp = tf->tf_esp;
        //cprintf("after set the registers in trap.c/page_fault_handler\n");
        /*set the values in the utrapframe*/
        if (uf.utf_esp < UXSTACKTOP && uf.utf_esp >= UXSTACKTOP-PGSIZE) {
            //cprintf("it's caused recursively \n");
            /*if the esp is in the uxstack*/
            retespaddr = tf->tf_esp - 4;
            utfa = retespaddr - sizeof(struct UTrapframe);//uf.utf_esp
        } else {
            /*if the page fault is caused in user state*/
            /*alloc stack*/
            //cprintf("it's caused first times\n");
            //syscall(SYS_page_alloc,curenv->env_id,(UXSTACKTOP-PGSIZE),PTE_USER,0,0);
            //cprintf("after alloc the page for the stack\n");
            /*clear it*/
            //memset((void*)(UXSTACKTOP-PGSIZE),0,PGSIZE);//may be needn't
            //cprintf("after clean the stack\n");
            retespaddr = UXSTACKTOP - 4;
            utfa = retespaddr -sizeof(struct UTrapframe);//uf.utf_esp
        }
        //cprintf("before check utf\n");
        user_mem_assert(curenv,(void*)utfa,sizeof(struct UTrapframe),PTE_P|PTE_U|PTE_W);
       // cprintf("after mem assert\n");
        /*set the return eip*/
        //*(uint32_t *)retespaddr = tf->tf_eip;
        memcpy((void *)utfa,&uf,sizeof(struct UTrapframe));
        curenv->env_tf.tf_esp = utfa;
        curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
        /*after set the values, return to the curenv*/
        //cprintf("return to the curenv\n");
        /*may be wrong,depend on how does the pgfault_upcall deal pgfault*/
        env_run(curenv);

    }
    //cprintf("the curenv doesn't have env_pgfault_upcall\n");
    // Destroy the environment that caused the fault.
    cprintf("[%08x] user fault va %08x ip %08x\n",
            curenv->env_id, fault_va, tf->tf_eip);
    print_trapframe(tf);
    env_destroy(curenv);
}

