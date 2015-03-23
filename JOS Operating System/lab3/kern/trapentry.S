/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



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

//TRAPHANDLER_NOEC(handler48 ,T_SYSCALL);
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
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

    iret

//define the function to handle syscall
.globl sysenterhandler;
.type sysenterhandler, @function;
sysenterhandler:
        pushl    $0
	pushl    %edi
	pushl    %ebx
	pushl    %ecx
	pushl    %edx
	pushl    %eax
    //xchg %bx %bx
	call     syscall	
	movl %ebp, %ecx
        movl %esi, %edx
  	sysexit
