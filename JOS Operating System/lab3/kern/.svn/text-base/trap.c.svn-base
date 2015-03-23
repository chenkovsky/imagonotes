#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>

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
    extern uint32_t sysenterhandler;
    SETGATE(idt[T_DIVIDE], 1, GD_KT, &handler0, 0);
    SETGATE(idt[T_DEBUG], 1, GD_KT, &handler1, 0);
    SETGATE(idt[T_NMI], 1, GD_KT, &handler2, 0);
    SETGATE(idt[T_BRKPT], 1, GD_KT, &handler3, 3);/*low Privilege*/
    SETGATE(idt[T_OFLOW], 1, GD_KT, &handler4, 0);
    SETGATE(idt[T_BOUND], 1, GD_KT, &handler5, 0);
    SETGATE(idt[T_ILLOP], 1, GD_KT, &handler6, 0);
    SETGATE(idt[T_DEVICE], 1, GD_KT, &handler7, 0);
    SETGATE(idt[T_DBLFLT], 1, GD_KT, &handler8, 0);

    SETGATE(idt[T_TSS], 1, GD_KT, &handler10, 0);
    SETGATE(idt[T_SEGNP], 1, GD_KT, &handler11, 0);
    SETGATE(idt[T_STACK], 1, GD_KT, &handler12, 0);
    SETGATE(idt[T_GPFLT], 1, GD_KT, &handler13, 0);
    SETGATE(idt[T_PGFLT], 1, GD_KT, &handler14, 0);

    SETGATE(idt[T_FPERR], 1, GD_KT, &handler16, 0);
    SETGATE(idt[T_ALIGN], 1, GD_KT, &handler17, 0);
    SETGATE(idt[T_MCHK], 1, GD_KT, &handler18, 0);
    SETGATE(idt[T_SIMDERR], 1, GD_KT, &handler19, 0);
    SETGATE(idt[T_SYSCALL],0,GD_KT,&sysenterhandler,3);
    //SETGATE(idt[T_SYSCALL], 0, GD_KT, &handler48, 3);//system call
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
    switch (tf->tf_trapno) {
    case T_PGFLT:
        page_fault_handler(tf);
        return;
    case T_BRKPT:
    case T_DEBUG:
        //cprintf("BRKPT here\n");
        monitor(tf);
        return;
    default:
        break;
    }

    // Unexpected trap: The user process or the kernel has a bug.
    print_trapframe(tf);
    if (tf->tf_cs == GD_KT)
        panic("unhandled trap in kernel\n");
    else {
        env_destroy(curenv);
        return;
    }
}

void
trap(struct Trapframe *tf)
{
    cprintf("Incoming TRAP frame at %p\n", tf);

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
    trap_dispatch(tf);

    // Return to the current environment, which should be runnable.
    assert(curenv && curenv->env_status == ENV_RUNNABLE);
    env_run(curenv);
}


void
page_fault_handler(struct Trapframe *tf)
{
    uint32_t fault_va;

    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();

    // Handle kernel-mode page faults.

    // LAB 3: Your code here.
if((tf->tf_cs & 3)!= 3) {
    panic("err of page_fault_handler: page fault in the kernel mode.\n the vitual address is %x,eip is %x\n",fault_va,tf->tf_eip);
}
    // We've already handled kernel-mode exceptions, so if we get here,
    // the page fault happened in user mode.

    // Destroy the environment that caused the fault.
    cprintf("[%08x] user fault va %08x ip %08x\n",
            curenv->env_id, fault_va, tf->tf_eip);
    print_trapframe(tf);
    env_destroy(curenv);
}

