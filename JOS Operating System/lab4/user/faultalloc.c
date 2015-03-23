// test user-level fault handler -- alloc pages to fix faults

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
	int r;
	void *addr = (void*)utf->utf_fault_va;

	cprintf("fault %x\n", addr);
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
				PTE_P|PTE_U|PTE_W)) < 0){
		panic("allocating at %x in page fault handler: %e", addr, r);
    }
    //cprintf("ok we have alloc page for the wrong address\n");
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
    //cprintf("ok we have move the string to the addr\n");
}

void
umain(void)
{   //int a = 3,b = 4,c = 3,d = 3,e = 3,f = 3,g = 3;
    //cprintf("a :%d,b :%d,c :%d,d :%d,e :%d,f :%d\n",a,b,c,d,e,f);
	set_pgfault_handler(handler);
	cprintf("%s\n", (char*)0xDeadBeef);
	cprintf("%s\n", (char*)0xCafeBffe);
    //cprintf("a :%d,b :%d,c :%d,d :%d,e :%d,f :%d\n",a,b,c,d,e,f);
}
