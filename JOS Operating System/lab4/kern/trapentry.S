/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* The TRAPHANDLER macro defines a globally-visible function for handling
 * a trap.  It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 */ 
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0 ,T_DIVIDE);
TRAPHANDLER_NOEC(handler1 ,T_DEBUG);
TRAPHANDLER_NOEC(handler2 ,T_NMI);
TRAPHANDLER_NOEC(handler3 ,T_BRKPT);
TRAPHANDLER_NOEC(handler4 ,T_OFLOW);
TRAPHANDLER_NOEC(handler5 ,T_BOUND);
TRAPHANDLER_NOEC(handler6 ,T_ILLOP);
TRAPHANDLER_NOEC(handler7 ,T_DEVICE);
TRAPHANDLER(handler8,T_DBLFLT);	
TRAPHANDLER_NOEC(handler9 ,9);//maybe this won't be used
TRAPHANDLER(handler10 ,T_TSS);
TRAPHANDLER(handler11 ,T_SEGNP);
TRAPHANDLER(handler12 ,T_STACK);
TRAPHANDLER(handler13 ,T_GPFLT);
TRAPHANDLER(handler14 ,T_PGFLT);
TRAPHANDLER(handler15, 15);
TRAPHANDLER_NOEC(handler16 ,T_FPERR);
TRAPHANDLER_NOEC(handler17 ,T_ALIGN);
TRAPHANDLER_NOEC(handler18 ,T_MCHK);
TRAPHANDLER_NOEC(handler19 ,T_SIMDERR);

TRAPHANDLER_NOEC(handler48 ,T_SYSCALL);

TRAPHANDLER_NOEC(inthandler0, IRQ_OFFSET)
TRAPHANDLER_NOEC(inthandler1, IRQ_OFFSET+1)
TRAPHANDLER_NOEC(inthandler2, IRQ_OFFSET+2)
TRAPHANDLER_NOEC(inthandler3, IRQ_OFFSET+3)
TRAPHANDLER_NOEC(inthandler4, IRQ_OFFSET+4)
TRAPHANDLER_NOEC(inthandler5, IRQ_OFFSET+5)
TRAPHANDLER_NOEC(inthandler6, IRQ_OFFSET+6)
TRAPHANDLER_NOEC(inthandler7, IRQ_OFFSET+7)
TRAPHANDLER_NOEC(inthandler8, IRQ_OFFSET+8)
TRAPHANDLER_NOEC(inthandler9, IRQ_OFFSET+9)
TRAPHANDLER_NOEC(inthandler10, IRQ_OFFSET+10)
TRAPHANDLER_NOEC(inthandler11, IRQ_OFFSET+11)
TRAPHANDLER_NOEC(inthandler12, IRQ_OFFSET+12)
TRAPHANDLER_NOEC(inthandler13, IRQ_OFFSET+13)
TRAPHANDLER_NOEC(inthandler14, IRQ_OFFSET+14)
TRAPHANDLER_NOEC(inthandler15, IRQ_OFFSET+15)

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    cli
    pushl %ds
    pushl %es
    pushal  //push all register

    movl $GD_KD, %eax
    movw %ax, %es
    movw %ax, %ds

    pushl %esp

    call trap
    popl %esp
    popal
    pop %es
    pop %ds
    addl $8, %esp
//xchg %bx, %bx
    iret

//define the function to handle syscall
.globl sysenterhandler;
.type sysenterhandler, @function;
sysenterhandler:
/*it uses kernel stack*/
    cli
    pushl %ebp//the return esp
    pushl %esi//the return eip
    movl 4(%ebp),%esi
    pushl %esi
    movl (%ebp),%esi
    pushl %ds
    pushl %es
    pushal  //push all register
    movl $GD_KD, %eax
    movw %ax, %es
    movw %ax, %ds
    pushl %esp
	call syscallwrap
    popl %esp
    popal
    popl  %es
    popl  %ds
    //xchg %bx, %bx
    //popfl
    //xchg %bx, %bx
    popl %edx
    popl %edx
    popl %ecx
    sti
  	sysexit

