/* See COPYRIGHT for copyright information. */

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/monitor.h>
#include <kern/console.h>
#include <kern/pmap.h>
#include <kern/kclock.h>
#include <kern/env.h>
#include <kern/trap.h>
void
i386_init(void)
{
	extern char edata[], end[];
extern uint32_t sysenterhandler;
//extern struct Taskstate ts;
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();

	cprintf("6828 decimal is %o octal!\n", 6828);

	// Lab 2 memory management initialization functions
	i386_detect_memory();
	i386_vm_init();

	// Lab 3 user environment initialization functions
	env_init();
	idt_init();


    /*set up MSR*/
    wrmsr(IA32_SYSENTER_CS,GD_KT,0);//set the segment
    wrmsr(IA32_SYSENTER_EIP,&sysenterhandler,0);//set the handler
    wrmsr(IA32_SYSENTER_ESP,KSTACKTOP,0);//set the stack
	// Temporary test code specific to LAB 3
#if defined(TEST)
	// Don't touch -- used by grading script!
//    cprintf("here1\n");
	ENV_CREATE2(TEST, TESTSIZE);
#else
	// Touch all you want.
//    cprintf("here2\n");
	ENV_CREATE(user_hello);
#endif // TEST*

//cprintf("i386_init: PassedTest\n");
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);


}


/*
 * Variable panicstr contains argument to first call to panic; used as flag
 * to indicate that the kernel has already called panic.
 */
static const char *panicstr;

/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
	va_list ap;

	if (panicstr)
		goto dead;
	panicstr = fmt;

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
	vcprintf(fmt, ap);
	cprintf("\n");
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
	vcprintf(fmt, ap);
	cprintf("\n");
	va_end(ap);
}
