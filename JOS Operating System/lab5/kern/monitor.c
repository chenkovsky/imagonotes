// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
    const char *name;
    const char *desc;
    // return -1 to force monitor to exit
    int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
    { "help", "Display this list of commands", mon_help},
    { "kerninfo", "Display information about the kernel", mon_kerninfo},
    { "backtrace", "back trace the stack", mon_backtrace}
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

void print_fun_name(const struct Eipdebuginfo *info) {
    int i;

    for (i = 0; i < info->eip_fn_namelen; i++)
        cputchar(info->eip_fn_name[i]);
}
/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
    int i;

    for (i = 0; i < NCOMMANDS; i++)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
    extern char _start[], etext[], edata[], end[];

    cprintf("Special kernel symbols:\n");
    cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
    cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
    cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
    cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end-_start+1023)/1024);
    return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
    // Your code here.
   void *ebp;
    void *eip;
    struct Eipdebuginfo info;
    cprintf("Stack backtrace:\n");
    eip = (void*) read_eip();
    ebp = (void*) read_ebp();
    /*trace the stack until the ebp is zero*/
    do {
        debuginfo_eip((uintptr_t) eip, &info);

        cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
                (uintptr_t) ebp, (uintptr_t) eip, *((uintptr_t *) ebp + 2),
                *((uintptr_t *) ebp + 3), *((uintptr_t *) ebp + 4),
                *((uintptr_t *) ebp + 5), *((uintptr_t *) ebp + 6));
        cprintf("%s:%d: ", info.eip_file, info.eip_line);
        print_fun_name(&info);
        cprintf("+%x\n", eip - info.eip_fn_addr);
        eip = *((void**) ebp + 1);
        ebp = *(void**) ebp;
    } while (ebp);
    return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
    int argc;
    char *argv[MAXARGS];
    int i;

    // Parse the command buffer into whitespace-separated arguments
    argc = 0;
    argv[argc] = 0;
    while (1) {
        // gobble whitespace
        while (*buf && strchr(WHITESPACE, *buf))
            *buf++ = 0;
        if (*buf == 0)
            break;

        // save and scan past next arg
        if (argc == MAXARGS-1) {
            cprintf("Too many arguments (max %d)\n", MAXARGS);
            return 0;
        }
        argv[argc++] = buf;
        while (*buf && !strchr(WHITESPACE, *buf))
            buf++;
    }
    argv[argc] = 0;

    // Lookup and invoke the command
    if (argc == 0)
        return 0;
    for (i = 0; i < NCOMMANDS; i++) {
        if (strcmp(argv[0], commands[i].name) == 0)
            return commands[i].func(argc, argv, tf);
    }
    cprintf("Unknown command '%s'\n", argv[0]);
    return 0;
}

void
monitor(struct Trapframe *tf)
{
    char *buf;

    cprintf("Welcome to the JOS kernel monitor!\n");
    cprintf("Type 'help' for a list of commands.\n");

    if (tf != NULL)
        print_trapframe(tf);

    while (1) {
        buf = readline("K> ");
        if (buf != NULL)
            if (runcmd(buf, tf) < 0)
                break;
    }
}

// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
    uint32_t callerpc;
    __asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
    return callerpc;
}
