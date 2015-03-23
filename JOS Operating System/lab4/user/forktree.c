// Fork a binary tree of processes and display their structure.

#include <inc/lib.h>

#define DEPTH 3//i change it,don't forget to change it back

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
	char nxt[DEPTH+1];
    //cprintf("before set next\n");
	if (strlen(cur) >= DEPTH)
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
    cprintf("in forkchild the child branch %s\n",nxt);
	if (fork() == 0) {
        cprintf("forkchild nxt in the stack is %s\n",nxt);
		forktree(nxt);
		exit();
	}
}

void
forktree(const char *cur)
{
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
    cprintf("fork first child \n");
	forkchild(cur, '0');
    cprintf("fork second child \n");
	forkchild(cur, '1');
}

void
umain(void)
{	cprintf("running in %d\n",sys_getenvid());
	forktree("");
}

