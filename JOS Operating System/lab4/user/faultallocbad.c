// test user-level fault handler -- alloc pages to fix faults
// doesn't work because we sys_cputs instead of cprintf (exercise: why?)

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
	int r;
	void *addr = (void*)utf->utf_fault_va;

	cprintf("fault %x\n", addr);
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
    //cprintf("here handler of fault alloc bad\n");
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(void)
{    //int a = 3,b = 3,c = 3,d = 3,e = 3,f = 3,g = 3;
    //cprintf("a :%d,b :%d,c :%d,d :%d,e :%d,f :%d\n",a,b,c,d,e,f);
	set_pgfault_handler(handler);
    //cprintf("got here in faultallocbad\n");
	sys_cputs((char*)0xDEADBEEF, 4);
    //cprintf("a :%d,b :%d,c :%d,d :%d,e :%d,f :%d\n",a,b,c,d,e,f);

}
