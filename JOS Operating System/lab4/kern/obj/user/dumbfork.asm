
obj/user/dumbfork：     文件格式 elf32-i386

反汇编 .text 节：

00800020 <_start>:
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 8f 01 00 00       	call   8001c0 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
envid_t dumbfork(void);

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800039:	e8 d2 00 00 00       	call   800110 <dumbfork>
  80003e:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800040:	bb 00 00 00 00       	mov    $0x0,%ebx
  800045:	eb 26                	jmp    80006d <umain+0x39>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800047:	83 ec 04             	sub    $0x4,%esp
  80004a:	b8 e0 11 80 00       	mov    $0x8011e0,%eax
  80004f:	85 f6                	test   %esi,%esi
  800051:	75 05                	jne    800058 <umain+0x24>
  800053:	b8 e7 11 80 00       	mov    $0x8011e7,%eax
  800058:	50                   	push   %eax
  800059:	53                   	push   %ebx
  80005a:	68 ed 11 80 00       	push   $0x8011ed
  80005f:	e8 a0 02 00 00       	call   800304 <cprintf>
		sys_yield();
  800064:	e8 03 0c 00 00       	call   800c6c <sys_yield>
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	43                   	inc    %ebx
  80006d:	85 f6                	test   %esi,%esi
  80006f:	74 05                	je     800076 <umain+0x42>
  800071:	83 fb 09             	cmp    $0x9,%ebx
  800074:	eb 03                	jmp    800079 <umain+0x45>
  800076:	83 fb 13             	cmp    $0x13,%ebx
  800079:	7e cc                	jle    800047 <umain+0x13>
	}
}
  80007b:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	c9                   	leave  
  800081:	c3                   	ret    

00800082 <duppage>:

void
duppage(envid_t dstenv, void *addr)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	56                   	push   %esi
  800086:	53                   	push   %ebx
  800087:	8b 75 08             	mov    0x8(%ebp),%esi
  80008a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80008d:	83 ec 04             	sub    $0x4,%esp
  800090:	6a 07                	push   $0x7
  800092:	53                   	push   %ebx
  800093:	56                   	push   %esi
  800094:	e8 02 0c 00 00       	call   800c9b <sys_page_alloc>
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	85 c0                	test   %eax,%eax
  80009e:	79 0a                	jns    8000aa <duppage+0x28>
		panic("sys_page_alloc: %e", r);
  8000a0:	50                   	push   %eax
  8000a1:	68 ff 11 80 00       	push   $0x8011ff
  8000a6:	6a 20                	push   $0x20
  8000a8:	eb 55                	jmp    8000ff <duppage+0x7d>
	//cprintf("call map\n");
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	6a 07                	push   $0x7
  8000af:	68 00 00 40 00       	push   $0x400000
  8000b4:	6a 00                	push   $0x0
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 31 0c 00 00       	call   800cee <sys_page_map>
  8000bd:	83 c4 20             	add    $0x20,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	79 0a                	jns    8000ce <duppage+0x4c>
		panic("sys_page_map: %e", r);
  8000c4:	50                   	push   %eax
  8000c5:	68 12 12 80 00       	push   $0x801212
  8000ca:	6a 23                	push   $0x23
  8000cc:	eb 31                	jmp    8000ff <duppage+0x7d>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	68 00 10 00 00       	push   $0x1000
  8000d6:	53                   	push   %ebx
  8000d7:	68 00 00 40 00       	push   $0x400000
  8000dc:	e8 df 08 00 00       	call   8009c0 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e1:	83 c4 08             	add    $0x8,%esp
  8000e4:	68 00 00 40 00       	push   $0x400000
  8000e9:	6a 00                	push   $0x0
  8000eb:	e8 50 0c 00 00       	call   800d40 <sys_page_unmap>
  8000f0:	83 c4 10             	add    $0x10,%esp
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	79 12                	jns    800109 <duppage+0x87>
		panic("sys_page_unmap: %e", r);
  8000f7:	50                   	push   %eax
  8000f8:	68 23 12 80 00       	push   $0x801223
  8000fd:	6a 26                	push   $0x26
  8000ff:	68 36 12 80 00       	push   $0x801236
  800104:	e8 0b 01 00 00       	call   800214 <_panic>
}
  800109:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	c9                   	leave  
  80010f:	c3                   	ret    

00800110 <dumbfork>:

envid_t
dumbfork(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	53                   	push   %ebx
  800114:	83 ec 04             	sub    $0x4,%esp
	
	
	// LAB 4: Your code here.
	//panic("sys_exofork(lib.h/inc) not implemented");
    asm volatile("int %2\n\t"
  800117:	ba 08 00 00 00       	mov    $0x8,%edx
  80011c:	89 d0                	mov    %edx,%eax
  80011e:	cd 30                	int    $0x30
  800120:	89 c3                	mov    %eax,%ebx
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];

	// Allocate a new child environment.
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800122:	85 c0                	test   %eax,%eax
  800124:	79 0a                	jns    800130 <dumbfork+0x20>
		panic("sys_exofork: %e", envid);
  800126:	50                   	push   %eax
  800127:	68 46 12 80 00       	push   $0x801246
  80012c:	6a 38                	push   $0x38
  80012e:	eb 7f                	jmp    8001af <dumbfork+0x9f>
	if (envid == 0) {
  800130:	85 c0                	test   %eax,%eax
  800132:	75 1e                	jne    800152 <dumbfork+0x42>
		// We're the child.
		// The copied value of the global variable 'env'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		env = &envs[ENVX(sys_getenvid())];
  800134:	e8 d5 0a 00 00       	call   800c0e <sys_getenvid>
  800139:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013e:	c1 e0 07             	shl    $0x7,%eax
  800141:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800146:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80014b:	ba 00 00 00 00       	mov    $0x0,%edx
  800150:	eb 67                	jmp    8001b9 <dumbfork+0xa9>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800152:	c7 45 f8 00 00 80 00 	movl   $0x800000,0xfffffff8(%ebp)
  800159:	81 7d f8 0c 20 80 00 	cmpl   $0x80200c,0xfffffff8(%ebp)
  800160:	73 1f                	jae    800181 <dumbfork+0x71>
		duppage(envid, addr);
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	ff 75 f8             	pushl  0xfffffff8(%ebp)
  800168:	53                   	push   %ebx
  800169:	e8 14 ff ff ff       	call   800082 <duppage>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	81 45 f8 00 10 00 00 	addl   $0x1000,0xfffffff8(%ebp)
  800178:	81 7d f8 0c 20 80 00 	cmpl   $0x80200c,0xfffffff8(%ebp)
  80017f:	72 e1                	jb     800162 <dumbfork+0x52>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800181:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  800184:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800189:	83 ec 08             	sub    $0x8,%esp
  80018c:	50                   	push   %eax
  80018d:	53                   	push   %ebx
  80018e:	e8 ef fe ff ff       	call   800082 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800193:	83 c4 08             	add    $0x8,%esp
  800196:	6a 01                	push   $0x1
  800198:	53                   	push   %ebx
  800199:	e8 f4 0b 00 00       	call   800d92 <sys_env_set_status>
  80019e:	83 c4 10             	add    $0x10,%esp
		panic("sys_env_set_status: %e", r);

	return envid;
  8001a1:	89 da                	mov    %ebx,%edx
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	79 12                	jns    8001b9 <dumbfork+0xa9>
  8001a7:	50                   	push   %eax
  8001a8:	68 56 12 80 00       	push   $0x801256
  8001ad:	6a 4d                	push   $0x4d
  8001af:	68 36 12 80 00       	push   $0x801236
  8001b4:	e8 5b 00 00 00       	call   800214 <_panic>
}
  8001b9:	89 d0                	mov    %edx,%eax
  8001bb:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  8001cb:	e8 3e 0a 00 00       	call   800c0e <sys_getenvid>
  8001d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d5:	c1 e0 07             	shl    $0x7,%eax
  8001d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001dd:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e2:	85 f6                	test   %esi,%esi
  8001e4:	7e 07                	jle    8001ed <libmain+0x2d>
		binaryname = argv[0];
  8001e6:	8b 03                	mov    (%ebx),%eax
  8001e8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	53                   	push   %ebx
  8001f1:	56                   	push   %esi
  8001f2:	e8 3d fe ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  8001f7:	e8 08 00 00 00       	call   800204 <exit>
}
  8001fc:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	c9                   	leave  
  800202:	c3                   	ret    
	...

00800204 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  80020a:	6a 00                	push   $0x0
  80020c:	e8 ac 09 00 00       	call   800bbd <sys_env_destroy>
}
  800211:	c9                   	leave  
  800212:	c3                   	ret    
	...

00800214 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	53                   	push   %ebx
  800218:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  80021b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80021e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800225:	74 16                	je     80023d <_panic+0x29>
		cprintf("%s: ", argv0);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	ff 35 08 20 80 00    	pushl  0x802008
  800230:	68 84 12 80 00       	push   $0x801284
  800235:	e8 ca 00 00 00       	call   800304 <cprintf>
  80023a:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80023d:	ff 75 0c             	pushl  0xc(%ebp)
  800240:	ff 75 08             	pushl  0x8(%ebp)
  800243:	ff 35 00 20 80 00    	pushl  0x802000
  800249:	68 89 12 80 00       	push   $0x801289
  80024e:	e8 b1 00 00 00       	call   800304 <cprintf>
	vcprintf(fmt, ap);
  800253:	83 c4 08             	add    $0x8,%esp
  800256:	53                   	push   %ebx
  800257:	ff 75 10             	pushl  0x10(%ebp)
  80025a:	e8 54 00 00 00       	call   8002b3 <vcprintf>
	cprintf("\n");
  80025f:	c7 04 24 fd 11 80 00 	movl   $0x8011fd,(%esp)
  800266:	e8 99 00 00 00       	call   800304 <cprintf>

	// Cause a breakpoint exception
	while (1)
  80026b:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80026e:	cc                   	int3   
  80026f:	eb fd                	jmp    80026e <_panic+0x5a>
}
  800271:	00 00                	add    %al,(%eax)
	...

00800274 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	53                   	push   %ebx
  800278:	83 ec 04             	sub    $0x4,%esp
  80027b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027e:	8b 03                	mov    (%ebx),%eax
  800280:	8b 55 08             	mov    0x8(%ebp),%edx
  800283:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800287:	40                   	inc    %eax
  800288:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80028a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028f:	75 1a                	jne    8002ab <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	68 ff 00 00 00       	push   $0xff
  800299:	8d 43 08             	lea    0x8(%ebx),%eax
  80029c:	50                   	push   %eax
  80029d:	e8 be 08 00 00       	call   800b60 <sys_cputs>
		b->idx = 0;
  8002a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ab:	ff 43 04             	incl   0x4(%ebx)
}
  8002ae:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bc:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8002c3:	00 00 00 
	b.cnt = 0;
  8002c6:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8002cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d0:	ff 75 0c             	pushl  0xc(%ebp)
  8002d3:	ff 75 08             	pushl  0x8(%ebp)
  8002d6:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  8002dc:	50                   	push   %eax
  8002dd:	68 74 02 80 00       	push   $0x800274
  8002e2:	e8 83 01 00 00       	call   80046a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e7:	83 c4 08             	add    $0x8,%esp
  8002ea:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  8002f0:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  8002f6:	50                   	push   %eax
  8002f7:	e8 64 08 00 00       	call   800b60 <sys_cputs>

	return b.cnt;
  8002fc:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030d:	50                   	push   %eax
  80030e:	ff 75 08             	pushl  0x8(%ebp)
  800311:	e8 9d ff ff ff       	call   8002b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 0c             	sub    $0xc,%esp
  800321:	8b 75 10             	mov    0x10(%ebp),%esi
  800324:	8b 7d 14             	mov    0x14(%ebp),%edi
  800327:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80032a:	8b 45 18             	mov    0x18(%ebp),%eax
  80032d:	ba 00 00 00 00       	mov    $0x0,%edx
  800332:	39 d7                	cmp    %edx,%edi
  800334:	72 39                	jb     80036f <printnum+0x57>
  800336:	77 04                	ja     80033c <printnum+0x24>
  800338:	39 c6                	cmp    %eax,%esi
  80033a:	72 33                	jb     80036f <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033c:	83 ec 04             	sub    $0x4,%esp
  80033f:	ff 75 20             	pushl  0x20(%ebp)
  800342:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800345:	50                   	push   %eax
  800346:	ff 75 18             	pushl  0x18(%ebp)
  800349:	8b 45 18             	mov    0x18(%ebp),%eax
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	52                   	push   %edx
  800352:	50                   	push   %eax
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	e8 b2 0b 00 00       	call   800f0c <__udivdi3>
  80035a:	83 c4 10             	add    $0x10,%esp
  80035d:	52                   	push   %edx
  80035e:	50                   	push   %eax
  80035f:	ff 75 0c             	pushl  0xc(%ebp)
  800362:	ff 75 08             	pushl  0x8(%ebp)
  800365:	e8 ae ff ff ff       	call   800318 <printnum>
  80036a:	83 c4 20             	add    $0x20,%esp
  80036d:	eb 19                	jmp    800388 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036f:	4b                   	dec    %ebx
  800370:	85 db                	test   %ebx,%ebx
  800372:	7e 14                	jle    800388 <printnum+0x70>
			putch(padc, putdat);
  800374:	83 ec 08             	sub    $0x8,%esp
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 20             	pushl  0x20(%ebp)
  80037d:	ff 55 08             	call   *0x8(%ebp)
  800380:	83 c4 10             	add    $0x10,%esp
  800383:	4b                   	dec    %ebx
  800384:	85 db                	test   %ebx,%ebx
  800386:	7f ec                	jg     800374 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800388:	83 ec 08             	sub    $0x8,%esp
  80038b:	ff 75 0c             	pushl  0xc(%ebp)
  80038e:	8b 45 18             	mov    0x18(%ebp),%eax
  800391:	ba 00 00 00 00       	mov    $0x0,%edx
  800396:	83 ec 04             	sub    $0x4,%esp
  800399:	52                   	push   %edx
  80039a:	50                   	push   %eax
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	e8 8a 0c 00 00       	call   80102c <__umoddi3>
  8003a2:	83 c4 14             	add    $0x14,%esp
  8003a5:	0f be 80 38 13 80 00 	movsbl 0x801338(%eax),%eax
  8003ac:	50                   	push   %eax
  8003ad:	ff 55 08             	call   *0x8(%ebp)
}
  8003b0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	c9                   	leave  
  8003b7:	c3                   	ret    

008003b8 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	56                   	push   %esi
  8003bc:	53                   	push   %ebx
  8003bd:	83 ec 18             	sub    $0x18,%esp
  8003c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c6:	8a 45 18             	mov    0x18(%ebp),%al
  8003c9:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  8003cc:	53                   	push   %ebx
  8003cd:	6a 1b                	push   $0x1b
  8003cf:	ff d6                	call   *%esi
	putch('[', putdat);
  8003d1:	83 c4 08             	add    $0x8,%esp
  8003d4:	53                   	push   %ebx
  8003d5:	6a 5b                	push   $0x5b
  8003d7:	ff d6                	call   *%esi
	putch('0', putdat);
  8003d9:	83 c4 08             	add    $0x8,%esp
  8003dc:	53                   	push   %ebx
  8003dd:	6a 30                	push   $0x30
  8003df:	ff d6                	call   *%esi
	putch(';', putdat);
  8003e1:	83 c4 08             	add    $0x8,%esp
  8003e4:	53                   	push   %ebx
  8003e5:	6a 3b                	push   $0x3b
  8003e7:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  8003e9:	83 c4 0c             	add    $0xc,%esp
  8003ec:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  8003f0:	50                   	push   %eax
  8003f1:	ff 75 14             	pushl  0x14(%ebp)
  8003f4:	6a 0a                	push   $0xa
  8003f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f9:	99                   	cltd   
  8003fa:	52                   	push   %edx
  8003fb:	50                   	push   %eax
  8003fc:	53                   	push   %ebx
  8003fd:	56                   	push   %esi
  8003fe:	e8 15 ff ff ff       	call   800318 <printnum>
	putch('m', putdat);
  800403:	83 c4 18             	add    $0x18,%esp
  800406:	53                   	push   %ebx
  800407:	6a 6d                	push   $0x6d
  800409:	ff d6                	call   *%esi

}
  80040b:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80040e:	5b                   	pop    %ebx
  80040f:	5e                   	pop    %esi
  800410:	c9                   	leave  
  800411:	c3                   	ret    

00800412 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800418:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80041b:	83 f8 01             	cmp    $0x1,%eax
  80041e:	7e 0f                	jle    80042f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800420:	8b 01                	mov    (%ecx),%eax
  800422:	83 c0 08             	add    $0x8,%eax
  800425:	89 01                	mov    %eax,(%ecx)
  800427:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80042a:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80042d:	eb 0f                	jmp    80043e <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80042f:	8b 01                	mov    (%ecx),%eax
  800431:	83 c0 04             	add    $0x4,%eax
  800434:	89 01                	mov    %eax,(%ecx)
  800436:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800439:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80043e:	c9                   	leave  
  80043f:	c3                   	ret    

00800440 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	8b 55 08             	mov    0x8(%ebp),%edx
  800446:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800449:	83 f8 01             	cmp    $0x1,%eax
  80044c:	7e 0f                	jle    80045d <getint+0x1d>
		return va_arg(*ap, long long);
  80044e:	8b 02                	mov    (%edx),%eax
  800450:	83 c0 08             	add    $0x8,%eax
  800453:	89 02                	mov    %eax,(%edx)
  800455:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800458:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80045b:	eb 0b                	jmp    800468 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	83 c0 04             	add    $0x4,%eax
  800462:	89 02                	mov    %eax,(%edx)
  800464:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800467:	99                   	cltd   
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	57                   	push   %edi
  80046e:	56                   	push   %esi
  80046f:	53                   	push   %ebx
  800470:	83 ec 1c             	sub    $0x1c,%esp
  800473:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800476:	0f b6 13             	movzbl (%ebx),%edx
  800479:	43                   	inc    %ebx
  80047a:	83 fa 25             	cmp    $0x25,%edx
  80047d:	74 1e                	je     80049d <vprintfmt+0x33>
			if (ch == '\0')
  80047f:	85 d2                	test   %edx,%edx
  800481:	0f 84 dc 02 00 00    	je     800763 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 0c             	pushl  0xc(%ebp)
  80048d:	52                   	push   %edx
  80048e:	ff 55 08             	call   *0x8(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	0f b6 13             	movzbl (%ebx),%edx
  800497:	43                   	inc    %ebx
  800498:	83 fa 25             	cmp    $0x25,%edx
  80049b:	75 e2                	jne    80047f <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80049d:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8004a1:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8004a8:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8004ad:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8004b2:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  8004b9:	0f b6 13             	movzbl (%ebx),%edx
  8004bc:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8004bf:	43                   	inc    %ebx
  8004c0:	83 f8 55             	cmp    $0x55,%eax
  8004c3:	0f 87 75 02 00 00    	ja     80073e <vprintfmt+0x2d4>
  8004c9:	ff 24 85 84 13 80 00 	jmp    *0x801384(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d0:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  8004d4:	eb e3                	jmp    8004b9 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d6:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  8004da:	eb dd                	jmp    8004b9 <vprintfmt+0x4f>

			// width field
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0;; ++fmt) {
  8004dc:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8004e1:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8004e4:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  8004e8:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8004eb:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8004ee:	83 f8 09             	cmp    $0x9,%eax
  8004f1:	77 27                	ja     80051a <vprintfmt+0xb0>
  8004f3:	43                   	inc    %ebx
  8004f4:	eb eb                	jmp    8004e1 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800500:	eb 18                	jmp    80051a <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  800502:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800506:	79 b1                	jns    8004b9 <vprintfmt+0x4f>
				width = 0;
  800508:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80050f:	eb a8                	jmp    8004b9 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800511:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800518:	eb 9f                	jmp    8004b9 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  80051a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80051e:	79 99                	jns    8004b9 <vprintfmt+0x4f>
				width = precision, precision = -1;
  800520:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800523:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800528:	eb 8f                	jmp    8004b9 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052a:	41                   	inc    %ecx
			goto reswitch;
  80052b:	eb 8c                	jmp    8004b9 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	ff 75 0c             	pushl  0xc(%ebp)
  800533:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80053d:	e9 c4 01 00 00       	jmp    800706 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  800542:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80054c:	85 c0                	test   %eax,%eax
  80054e:	79 02                	jns    800552 <vprintfmt+0xe8>
				err = -err;
  800550:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800552:	83 f8 08             	cmp    $0x8,%eax
  800555:	7f 0b                	jg     800562 <vprintfmt+0xf8>
  800557:	8b 3c 85 60 13 80 00 	mov    0x801360(,%eax,4),%edi
  80055e:	85 ff                	test   %edi,%edi
  800560:	75 08                	jne    80056a <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  800562:	50                   	push   %eax
  800563:	68 49 13 80 00       	push   $0x801349
  800568:	eb 06                	jmp    800570 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  80056a:	57                   	push   %edi
  80056b:	68 52 13 80 00       	push   $0x801352
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	ff 75 08             	pushl  0x8(%ebp)
  800576:	e8 f0 01 00 00       	call   80076b <printfmt>
  80057b:	e9 89 01 00 00       	jmp    800709 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800580:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  80058a:	85 ff                	test   %edi,%edi
  80058c:	75 05                	jne    800593 <vprintfmt+0x129>
				p = "(null)";
  80058e:	bf 55 13 80 00       	mov    $0x801355,%edi
			if (width > 0 && padc != '-')
  800593:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800597:	7e 3b                	jle    8005d4 <vprintfmt+0x16a>
  800599:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  80059d:	74 35                	je     8005d4 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	56                   	push   %esi
  8005a3:	57                   	push   %edi
  8005a4:	e8 74 02 00 00       	call   80081d <strnlen>
  8005a9:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8005b3:	7e 1f                	jle    8005d4 <vprintfmt+0x16a>
  8005b5:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8005b9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	ff 75 0c             	pushl  0xc(%ebp)
  8005c2:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8005ce:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8005d2:	7f e8                	jg     8005bc <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d4:	0f be 17             	movsbl (%edi),%edx
  8005d7:	47                   	inc    %edi
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	74 3e                	je     80061a <vprintfmt+0x1b0>
  8005dc:	85 f6                	test   %esi,%esi
  8005de:	78 03                	js     8005e3 <vprintfmt+0x179>
  8005e0:	4e                   	dec    %esi
  8005e1:	78 37                	js     80061a <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e3:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8005e7:	74 12                	je     8005fb <vprintfmt+0x191>
  8005e9:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8005ec:	83 f8 5e             	cmp    $0x5e,%eax
  8005ef:	76 0a                	jbe    8005fb <vprintfmt+0x191>
					putch('?', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	ff 75 0c             	pushl  0xc(%ebp)
  8005f7:	6a 3f                	push   $0x3f
  8005f9:	eb 07                	jmp    800602 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	52                   	push   %edx
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80060b:	0f be 17             	movsbl (%edi),%edx
  80060e:	47                   	inc    %edi
  80060f:	85 d2                	test   %edx,%edx
  800611:	74 07                	je     80061a <vprintfmt+0x1b0>
  800613:	85 f6                	test   %esi,%esi
  800615:	78 cc                	js     8005e3 <vprintfmt+0x179>
  800617:	4e                   	dec    %esi
  800618:	79 c9                	jns    8005e3 <vprintfmt+0x179>
			for (; width > 0; width--)
  80061a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80061e:	0f 8e 52 fe ff ff    	jle    800476 <vprintfmt+0xc>
				putch(' ', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	ff 75 0c             	pushl  0xc(%ebp)
  80062a:	6a 20                	push   $0x20
  80062c:	ff 55 08             	call   *0x8(%ebp)
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800635:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800639:	7f e9                	jg     800624 <vprintfmt+0x1ba>
			break;
  80063b:	e9 36 fe ff ff       	jmp    800476 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	51                   	push   %ecx
  800644:	8d 45 14             	lea    0x14(%ebp),%eax
  800647:	50                   	push   %eax
  800648:	e8 f3 fd ff ff       	call   800440 <getint>
  80064d:	89 c6                	mov    %eax,%esi
  80064f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 d2                	test   %edx,%edx
  800656:	79 15                	jns    80066d <vprintfmt+0x203>
				putch('-', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	ff 75 0c             	pushl  0xc(%ebp)
  80065e:	6a 2d                	push   $0x2d
  800660:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800663:	f7 de                	neg    %esi
  800665:	83 d7 00             	adc    $0x0,%edi
  800668:	f7 df                	neg    %edi
  80066a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800672:	eb 70                	jmp    8006e4 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	51                   	push   %ecx
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	50                   	push   %eax
  80067c:	e8 91 fd ff ff       	call   800412 <getuint>
  800681:	89 c6                	mov    %eax,%esi
  800683:	89 d7                	mov    %edx,%edi
			base = 10;
  800685:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80068a:	eb 55                	jmp    8006e1 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	51                   	push   %ecx
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
  800693:	50                   	push   %eax
  800694:	e8 79 fd ff ff       	call   800412 <getuint>
  800699:	89 c6                	mov    %eax,%esi
  80069b:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  80069d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8006a2:	eb 3d                	jmp    8006e1 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	6a 30                	push   $0x30
  8006ac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	6a 78                	push   $0x78
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8006ba:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8006c4:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  8006c9:	eb 11                	jmp    8006dc <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	51                   	push   %ecx
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	e8 3a fd ff ff       	call   800412 <getuint>
  8006d8:	89 c6                	mov    %eax,%esi
  8006da:	89 d7                	mov    %edx,%edi
			base = 16;
  8006dc:	ba 10 00 00 00       	mov    $0x10,%edx
  8006e1:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  8006e4:	83 ec 04             	sub    $0x4,%esp
  8006e7:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8006ef:	52                   	push   %edx
  8006f0:	57                   	push   %edi
  8006f1:	56                   	push   %esi
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	ff 75 08             	pushl  0x8(%ebp)
  8006f8:	e8 1b fc ff ff       	call   800318 <printnum>
			break;
  8006fd:	eb 37                	jmp    800736 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	ff 75 0c             	pushl  0xc(%ebp)
  800705:	52                   	push   %edx
  800706:	ff 55 08             	call   *0x8(%ebp)
			break;
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	e9 65 fd ff ff       	jmp    800476 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	51                   	push   %ecx
  800715:	8d 45 14             	lea    0x14(%ebp),%eax
  800718:	50                   	push   %eax
  800719:	e8 f4 fc ff ff       	call   800412 <getuint>
  80071e:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800720:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80072a:	56                   	push   %esi
  80072b:	ff 75 0c             	pushl  0xc(%ebp)
  80072e:	ff 75 08             	pushl  0x8(%ebp)
  800731:	e8 82 fc ff ff       	call   8003b8 <printcolor>
			break;
  800736:	83 c4 20             	add    $0x20,%esp
  800739:	e9 38 fd ff ff       	jmp    800476 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	6a 25                	push   $0x25
  800746:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800749:	4b                   	dec    %ebx
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800751:	0f 84 1f fd ff ff    	je     800476 <vprintfmt+0xc>
  800757:	4b                   	dec    %ebx
  800758:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80075c:	75 f9                	jne    800757 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80075e:	e9 13 fd ff ff       	jmp    800476 <vprintfmt+0xc>
		}
	}
}
  800763:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800774:	50                   	push   %eax
  800775:	ff 75 10             	pushl  0x10(%ebp)
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	ff 75 08             	pushl  0x8(%ebp)
  80077e:	e8 e7 fc ff ff       	call   80046a <vprintfmt>
	va_end(ap);
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80078b:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80078e:	8b 0a                	mov    (%edx),%ecx
  800790:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800793:	73 07                	jae    80079c <sprintputch+0x17>
		*b->buf++ = ch;
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	88 01                	mov    %al,(%ecx)
  80079a:	ff 02                	incl   (%edx)
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 18             	sub    $0x18,%esp
  8007a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8007aa:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8007ad:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8007b1:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8007b4:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	74 04                	je     8007c3 <vsnprintf+0x25>
  8007bf:	85 c9                	test   %ecx,%ecx
  8007c1:	7f 07                	jg     8007ca <vsnprintf+0x2c>
		return -E_INVAL;
  8007c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c8:	eb 1d                	jmp    8007e7 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  8007ca:	ff 75 14             	pushl  0x14(%ebp)
  8007cd:	ff 75 10             	pushl  0x10(%ebp)
  8007d0:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	68 85 07 80 00       	push   $0x800785
  8007d9:	e8 8c fc ff ff       	call   80046a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007de:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8007e1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f2:	50                   	push   %eax
  8007f3:	ff 75 10             	pushl  0x10(%ebp)
  8007f6:	ff 75 0c             	pushl  0xc(%ebp)
  8007f9:	ff 75 08             	pushl  0x8(%ebp)
  8007fc:	e8 9d ff ff ff       	call   80079e <vsnprintf>
	va_end(ap);

	return rc;
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    
	...

00800804 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080a:	b8 00 00 00 00       	mov    $0x0,%eax
  80080f:	80 3a 00             	cmpb   $0x0,(%edx)
  800812:	74 07                	je     80081b <strlen+0x17>
		n++;
  800814:	40                   	inc    %eax
  800815:	42                   	inc    %edx
  800816:	80 3a 00             	cmpb   $0x0,(%edx)
  800819:	75 f9                	jne    800814 <strlen+0x10>
	return n;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 0f                	je     80083e <strnlen+0x21>
  80082f:	80 39 00             	cmpb   $0x0,(%ecx)
  800832:	74 0a                	je     80083e <strnlen+0x21>
		n++;
  800834:	40                   	inc    %eax
  800835:	41                   	inc    %ecx
  800836:	4a                   	dec    %edx
  800837:	74 05                	je     80083e <strnlen+0x21>
  800839:	80 39 00             	cmpb   $0x0,(%ecx)
  80083c:	75 f6                	jne    800834 <strnlen+0x17>
	return n;
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80084a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80084c:	8a 02                	mov    (%edx),%al
  80084e:	42                   	inc    %edx
  80084f:	88 01                	mov    %al,(%ecx)
  800851:	41                   	inc    %ecx
  800852:	84 c0                	test   %al,%al
  800854:	75 f6                	jne    80084c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800856:	89 d8                	mov    %ebx,%eax
  800858:	5b                   	pop    %ebx
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	57                   	push   %edi
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
  800867:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80086a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80086c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800871:	39 f3                	cmp    %esi,%ebx
  800873:	73 10                	jae    800885 <strncpy+0x2a>
		*dst++ = *src;
  800875:	8a 02                	mov    (%edx),%al
  800877:	88 01                	mov    %al,(%ecx)
  800879:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80087a:	80 3a 00             	cmpb   $0x0,(%edx)
  80087d:	74 01                	je     800880 <strncpy+0x25>
			src++;
  80087f:	42                   	inc    %edx
  800880:	43                   	inc    %ebx
  800881:	39 f3                	cmp    %esi,%ebx
  800883:	72 f0                	jb     800875 <strncpy+0x1a>
	}
	return ret;
}
  800885:	89 f8                	mov    %edi,%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5f                   	pop    %edi
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80089a:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80089c:	85 d2                	test   %edx,%edx
  80089e:	74 19                	je     8008b9 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8008a0:	4a                   	dec    %edx
  8008a1:	74 13                	je     8008b6 <strlcpy+0x2a>
  8008a3:	80 39 00             	cmpb   $0x0,(%ecx)
  8008a6:	74 0e                	je     8008b6 <strlcpy+0x2a>
			*dst++ = *src++;
  8008a8:	8a 01                	mov    (%ecx),%al
  8008aa:	41                   	inc    %ecx
  8008ab:	88 03                	mov    %al,(%ebx)
  8008ad:	43                   	inc    %ebx
  8008ae:	4a                   	dec    %edx
  8008af:	74 05                	je     8008b6 <strlcpy+0x2a>
  8008b1:	80 39 00             	cmpb   $0x0,(%ecx)
  8008b4:	75 f2                	jne    8008a8 <strlcpy+0x1c>
		*dst = '\0';
  8008b6:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8008b9:	89 d8                	mov    %ebx,%eax
  8008bb:	29 f0                	sub    %esi,%eax
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8008ca:	80 3a 00             	cmpb   $0x0,(%edx)
  8008cd:	74 13                	je     8008e2 <strcmp+0x21>
  8008cf:	8a 02                	mov    (%edx),%al
  8008d1:	3a 01                	cmp    (%ecx),%al
  8008d3:	75 0d                	jne    8008e2 <strcmp+0x21>
		p++, q++;
  8008d5:	42                   	inc    %edx
  8008d6:	41                   	inc    %ecx
  8008d7:	80 3a 00             	cmpb   $0x0,(%edx)
  8008da:	74 06                	je     8008e2 <strcmp+0x21>
  8008dc:	8a 02                	mov    (%edx),%al
  8008de:	3a 01                	cmp    (%ecx),%al
  8008e0:	74 f3                	je     8008d5 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e2:	0f b6 02             	movzbl (%edx),%eax
  8008e5:	0f b6 11             	movzbl (%ecx),%edx
  8008e8:	29 d0                	sub    %edx,%eax
}
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  8008f9:	85 c9                	test   %ecx,%ecx
  8008fb:	74 1f                	je     80091c <strncmp+0x30>
  8008fd:	80 3a 00             	cmpb   $0x0,(%edx)
  800900:	74 16                	je     800918 <strncmp+0x2c>
  800902:	8a 02                	mov    (%edx),%al
  800904:	3a 03                	cmp    (%ebx),%al
  800906:	75 10                	jne    800918 <strncmp+0x2c>
		n--, p++, q++;
  800908:	42                   	inc    %edx
  800909:	43                   	inc    %ebx
  80090a:	49                   	dec    %ecx
  80090b:	74 0f                	je     80091c <strncmp+0x30>
  80090d:	80 3a 00             	cmpb   $0x0,(%edx)
  800910:	74 06                	je     800918 <strncmp+0x2c>
  800912:	8a 02                	mov    (%edx),%al
  800914:	3a 03                	cmp    (%ebx),%al
  800916:	74 f0                	je     800908 <strncmp+0x1c>
	if (n == 0)
  800918:	85 c9                	test   %ecx,%ecx
  80091a:	75 07                	jne    800923 <strncmp+0x37>
		return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
  800921:	eb 0a                	jmp    80092d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	0f b6 03             	movzbl (%ebx),%eax
  800929:	29 c2                	sub    %eax,%edx
  80092b:	89 d0                	mov    %edx,%eax
}
  80092d:	8b 1c 24             	mov    (%esp),%ebx
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80093b:	80 38 00             	cmpb   $0x0,(%eax)
  80093e:	74 0a                	je     80094a <strchr+0x18>
		if (*s == c)
  800940:	38 10                	cmp    %dl,(%eax)
  800942:	74 0b                	je     80094f <strchr+0x1d>
  800944:	40                   	inc    %eax
  800945:	80 38 00             	cmpb   $0x0,(%eax)
  800948:	75 f6                	jne    800940 <strchr+0xe>
			return (char *) s;
	return 0;
  80094a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094f:	c9                   	leave  
  800950:	c3                   	ret    

00800951 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80095a:	80 38 00             	cmpb   $0x0,(%eax)
  80095d:	74 0a                	je     800969 <strfind+0x18>
		if (*s == c)
  80095f:	38 10                	cmp    %dl,(%eax)
  800961:	74 06                	je     800969 <strfind+0x18>
  800963:	40                   	inc    %eax
  800964:	80 38 00             	cmpb   $0x0,(%eax)
  800967:	75 f6                	jne    80095f <strfind+0xe>
			break;
	return (char *) s;
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	57                   	push   %edi
  80096f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800972:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800975:	89 f8                	mov    %edi,%eax
  800977:	85 c9                	test   %ecx,%ecx
  800979:	74 40                	je     8009bb <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800981:	75 30                	jne    8009b3 <memset+0x48>
  800983:	f6 c1 03             	test   $0x3,%cl
  800986:	75 2b                	jne    8009b3 <memset+0x48>
		c &= 0xFF;
  800988:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800992:	c1 e0 18             	shl    $0x18,%eax
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
  800998:	c1 e2 10             	shl    $0x10,%edx
  80099b:	09 d0                	or     %edx,%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	c1 e2 08             	shl    $0x8,%edx
  8009a3:	09 d0                	or     %edx,%eax
  8009a5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	fc                   	cld    
  8009af:	f3 ab                	repz stos %eax,%es:(%edi)
  8009b1:	eb 06                	jmp    8009b9 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b6:	fc                   	cld    
  8009b7:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8009b9:	89 f8                	mov    %edi,%eax
}
  8009bb:	8b 3c 24             	mov    (%esp),%edi
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009cb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009ce:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009d0:	39 c6                	cmp    %eax,%esi
  8009d2:	73 33                	jae    800a07 <memmove+0x47>
  8009d4:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  8009d7:	39 c2                	cmp    %eax,%edx
  8009d9:	76 2c                	jbe    800a07 <memmove+0x47>
		s += n;
  8009db:	89 d6                	mov    %edx,%esi
		d += n;
  8009dd:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	f6 c2 03             	test   $0x3,%dl
  8009e3:	75 1b                	jne    800a00 <memmove+0x40>
  8009e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009eb:	75 13                	jne    800a00 <memmove+0x40>
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 0e                	jne    800a00 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8009f2:	83 ef 04             	sub    $0x4,%edi
  8009f5:	83 ee 04             	sub    $0x4,%esi
  8009f8:	c1 e9 02             	shr    $0x2,%ecx
  8009fb:	fd                   	std    
  8009fc:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  8009fe:	eb 27                	jmp    800a27 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a00:	4f                   	dec    %edi
  800a01:	4e                   	dec    %esi
  800a02:	fd                   	std    
  800a03:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800a05:	eb 20                	jmp    800a27 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a07:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0d:	75 15                	jne    800a24 <memmove+0x64>
  800a0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a15:	75 0d                	jne    800a24 <memmove+0x64>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 08                	jne    800a24 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
  800a1f:	fc                   	cld    
  800a20:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800a22:	eb 03                	jmp    800a27 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a24:	fc                   	cld    
  800a25:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <memcpy>:

#else

void *
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;

	return v;
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;

	return dst;
}
#endif

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a31:	ff 75 10             	pushl  0x10(%ebp)
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	ff 75 08             	pushl  0x8(%ebp)
  800a3a:	e8 81 ff ff ff       	call   8009c0 <memmove>
}
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  800a4e:	89 d0                	mov    %edx,%eax
  800a50:	4a                   	dec    %edx
  800a51:	85 c0                	test   %eax,%eax
  800a53:	74 1b                	je     800a70 <memcmp+0x2f>
		if (*s1 != *s2)
  800a55:	8a 01                	mov    (%ecx),%al
  800a57:	3a 03                	cmp    (%ebx),%al
  800a59:	74 0c                	je     800a67 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5b:	0f b6 d0             	movzbl %al,%edx
  800a5e:	0f b6 03             	movzbl (%ebx),%eax
  800a61:	29 c2                	sub    %eax,%edx
  800a63:	89 d0                	mov    %edx,%eax
  800a65:	eb 0e                	jmp    800a75 <memcmp+0x34>
		s1++, s2++;
  800a67:	41                   	inc    %ecx
  800a68:	43                   	inc    %ebx
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	4a                   	dec    %edx
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	75 e5                	jne    800a55 <memcmp+0x14>
	}

	return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a75:	5b                   	pop    %ebx
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a81:	89 c2                	mov    %eax,%edx
  800a83:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a86:	39 d0                	cmp    %edx,%eax
  800a88:	73 09                	jae    800a93 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8a:	38 08                	cmp    %cl,(%eax)
  800a8c:	74 05                	je     800a93 <memfind+0x1b>
  800a8e:	40                   	inc    %eax
  800a8f:	39 d0                	cmp    %edx,%eax
  800a91:	72 f7                	jb     800a8a <memfind+0x12>
			break;
	return (void *) s;
}
  800a93:	c9                   	leave  
  800a94:	c3                   	ret    

00800a95 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800aa9:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	80 3a 20             	cmpb   $0x20,(%edx)
  800ab1:	74 05                	je     800ab8 <strtol+0x23>
  800ab3:	80 3a 09             	cmpb   $0x9,(%edx)
  800ab6:	75 0b                	jne    800ac3 <strtol+0x2e>
		s++;
  800ab8:	42                   	inc    %edx
  800ab9:	80 3a 20             	cmpb   $0x20,(%edx)
  800abc:	74 fa                	je     800ab8 <strtol+0x23>
  800abe:	80 3a 09             	cmpb   $0x9,(%edx)
  800ac1:	74 f5                	je     800ab8 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800ac3:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800ac6:	75 03                	jne    800acb <strtol+0x36>
		s++;
  800ac8:	42                   	inc    %edx
  800ac9:	eb 0b                	jmp    800ad6 <strtol+0x41>
	else if (*s == '-')
  800acb:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800ace:	75 06                	jne    800ad6 <strtol+0x41>
		s++, neg = 1;
  800ad0:	42                   	inc    %edx
  800ad1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad6:	85 c9                	test   %ecx,%ecx
  800ad8:	74 05                	je     800adf <strtol+0x4a>
  800ada:	83 f9 10             	cmp    $0x10,%ecx
  800add:	75 15                	jne    800af4 <strtol+0x5f>
  800adf:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae2:	75 10                	jne    800af4 <strtol+0x5f>
  800ae4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae8:	75 0a                	jne    800af4 <strtol+0x5f>
		s += 2, base = 16;
  800aea:	83 c2 02             	add    $0x2,%edx
  800aed:	b9 10 00 00 00       	mov    $0x10,%ecx
  800af2:	eb 1a                	jmp    800b0e <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800af4:	85 c9                	test   %ecx,%ecx
  800af6:	75 16                	jne    800b0e <strtol+0x79>
  800af8:	80 3a 30             	cmpb   $0x30,(%edx)
  800afb:	75 08                	jne    800b05 <strtol+0x70>
		s++, base = 8;
  800afd:	42                   	inc    %edx
  800afe:	b9 08 00 00 00       	mov    $0x8,%ecx
  800b03:	eb 09                	jmp    800b0e <strtol+0x79>
	else if (base == 0)
  800b05:	85 c9                	test   %ecx,%ecx
  800b07:	75 05                	jne    800b0e <strtol+0x79>
		base = 10;
  800b09:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0e:	8a 02                	mov    (%edx),%al
  800b10:	83 e8 30             	sub    $0x30,%eax
  800b13:	3c 09                	cmp    $0x9,%al
  800b15:	77 08                	ja     800b1f <strtol+0x8a>
			dig = *s - '0';
  800b17:	0f be 02             	movsbl (%edx),%eax
  800b1a:	83 e8 30             	sub    $0x30,%eax
  800b1d:	eb 20                	jmp    800b3f <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800b1f:	8a 02                	mov    (%edx),%al
  800b21:	83 e8 61             	sub    $0x61,%eax
  800b24:	3c 19                	cmp    $0x19,%al
  800b26:	77 08                	ja     800b30 <strtol+0x9b>
			dig = *s - 'a' + 10;
  800b28:	0f be 02             	movsbl (%edx),%eax
  800b2b:	83 e8 57             	sub    $0x57,%eax
  800b2e:	eb 0f                	jmp    800b3f <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800b30:	8a 02                	mov    (%edx),%al
  800b32:	83 e8 41             	sub    $0x41,%eax
  800b35:	3c 19                	cmp    $0x19,%al
  800b37:	77 12                	ja     800b4b <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b39:	0f be 02             	movsbl (%edx),%eax
  800b3c:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800b3f:	39 c8                	cmp    %ecx,%eax
  800b41:	7d 08                	jge    800b4b <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800b43:	42                   	inc    %edx
  800b44:	0f af d9             	imul   %ecx,%ebx
  800b47:	01 c3                	add    %eax,%ebx
  800b49:	eb c3                	jmp    800b0e <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b4b:	85 f6                	test   %esi,%esi
  800b4d:	74 02                	je     800b51 <strtol+0xbc>
		*endptr = (char *) s;
  800b4f:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b51:	89 d8                	mov    %ebx,%eax
  800b53:	85 ff                	test   %edi,%edi
  800b55:	74 02                	je     800b59 <strtol+0xc4>
  800b57:	f7 d8                	neg    %eax
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    
	...

00800b60 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b71:	89 f8                	mov    %edi,%eax
  800b73:	89 fb                	mov    %edi,%ebx
  800b75:	89 fe                	mov    %edi,%esi
  800b77:	55                   	push   %ebp
  800b78:	9c                   	pushf  
  800b79:	56                   	push   %esi
  800b7a:	54                   	push   %esp
  800b7b:	5d                   	pop    %ebp
  800b7c:	8d 35 84 0b 80 00    	lea    0x800b84,%esi
  800b82:	0f 34                	sysenter 
  800b84:	83 c4 04             	add    $0x4,%esp
  800b87:	9d                   	popf   
  800b88:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	b8 01 00 00 00       	mov    $0x1,%eax
  800b99:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9e:	89 fa                	mov    %edi,%edx
  800ba0:	89 f9                	mov    %edi,%ecx
  800ba2:	89 fb                	mov    %edi,%ebx
  800ba4:	89 fe                	mov    %edi,%esi
  800ba6:	55                   	push   %ebp
  800ba7:	9c                   	pushf  
  800ba8:	56                   	push   %esi
  800ba9:	54                   	push   %esp
  800baa:	5d                   	pop    %ebp
  800bab:	8d 35 b3 0b 80 00    	lea    0x800bb3,%esi
  800bb1:	0f 34                	sysenter 
  800bb3:	83 c4 04             	add    $0x4,%esp
  800bb6:	9d                   	popf   
  800bb7:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bce:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd3:	89 f9                	mov    %edi,%ecx
  800bd5:	89 fb                	mov    %edi,%ebx
  800bd7:	89 fe                	mov    %edi,%esi
  800bd9:	55                   	push   %ebp
  800bda:	9c                   	pushf  
  800bdb:	56                   	push   %esi
  800bdc:	54                   	push   %esp
  800bdd:	5d                   	pop    %ebp
  800bde:	8d 35 e6 0b 80 00    	lea    0x800be6,%esi
  800be4:	0f 34                	sysenter 
  800be6:	83 c4 04             	add    $0x4,%esp
  800be9:	9d                   	popf   
  800bea:	5d                   	pop    %ebp
  800beb:	85 c0                	test   %eax,%eax
  800bed:	7e 17                	jle    800c06 <sys_env_destroy+0x49>
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	50                   	push   %eax
  800bf3:	6a 03                	push   $0x3
  800bf5:	68 dc 14 80 00       	push   $0x8014dc
  800bfa:	6a 4c                	push   $0x4c
  800bfc:	68 f9 14 80 00       	push   $0x8014f9
  800c01:	e8 0e f6 ff ff       	call   800214 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c06:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	b8 02 00 00 00       	mov    $0x2,%eax
  800c19:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1e:	89 fa                	mov    %edi,%edx
  800c20:	89 f9                	mov    %edi,%ecx
  800c22:	89 fb                	mov    %edi,%ebx
  800c24:	89 fe                	mov    %edi,%esi
  800c26:	55                   	push   %ebp
  800c27:	9c                   	pushf  
  800c28:	56                   	push   %esi
  800c29:	54                   	push   %esp
  800c2a:	5d                   	pop    %ebp
  800c2b:	8d 35 33 0c 80 00    	lea    0x800c33,%esi
  800c31:	0f 34                	sysenter 
  800c33:	83 c4 04             	add    $0x4,%esp
  800c36:	9d                   	popf   
  800c37:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <sys_dump_env>:

int
sys_dump_env(void)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	b8 04 00 00 00       	mov    $0x4,%eax
  800c48:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4d:	89 fa                	mov    %edi,%edx
  800c4f:	89 f9                	mov    %edi,%ecx
  800c51:	89 fb                	mov    %edi,%ebx
  800c53:	89 fe                	mov    %edi,%esi
  800c55:	55                   	push   %ebp
  800c56:	9c                   	pushf  
  800c57:	56                   	push   %esi
  800c58:	54                   	push   %esp
  800c59:	5d                   	pop    %ebp
  800c5a:	8d 35 62 0c 80 00    	lea    0x800c62,%esi
  800c60:	0f 34                	sysenter 
  800c62:	83 c4 04             	add    $0x4,%esp
  800c65:	9d                   	popf   
  800c66:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <sys_yield>:

void
sys_yield(void)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c77:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7c:	89 fa                	mov    %edi,%edx
  800c7e:	89 f9                	mov    %edi,%ecx
  800c80:	89 fb                	mov    %edi,%ebx
  800c82:	89 fe                	mov    %edi,%esi
  800c84:	55                   	push   %ebp
  800c85:	9c                   	pushf  
  800c86:	56                   	push   %esi
  800c87:	54                   	push   %esp
  800c88:	5d                   	pop    %ebp
  800c89:	8d 35 91 0c 80 00    	lea    0x800c91,%esi
  800c8f:	0f 34                	sysenter 
  800c91:	83 c4 04             	add    $0x4,%esp
  800c94:	9d                   	popf   
  800c95:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cad:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb7:	89 fe                	mov    %edi,%esi
  800cb9:	55                   	push   %ebp
  800cba:	9c                   	pushf  
  800cbb:	56                   	push   %esi
  800cbc:	54                   	push   %esp
  800cbd:	5d                   	pop    %ebp
  800cbe:	8d 35 c6 0c 80 00    	lea    0x800cc6,%esi
  800cc4:	0f 34                	sysenter 
  800cc6:	83 c4 04             	add    $0x4,%esp
  800cc9:	9d                   	popf   
  800cca:	5d                   	pop    %ebp
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_page_alloc+0x4b>
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 05                	push   $0x5
  800cd5:	68 dc 14 80 00       	push   $0x8014dc
  800cda:	6a 4c                	push   $0x4c
  800cdc:	68 f9 14 80 00       	push   $0x8014f9
  800ce1:	e8 2e f5 ff ff       	call   800214 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d03:	8b 75 18             	mov    0x18(%ebp),%esi
  800d06:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0b:	55                   	push   %ebp
  800d0c:	9c                   	pushf  
  800d0d:	56                   	push   %esi
  800d0e:	54                   	push   %esp
  800d0f:	5d                   	pop    %ebp
  800d10:	8d 35 18 0d 80 00    	lea    0x800d18,%esi
  800d16:	0f 34                	sysenter 
  800d18:	83 c4 04             	add    $0x4,%esp
  800d1b:	9d                   	popf   
  800d1c:	5d                   	pop    %ebp
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_page_map+0x4a>
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 06                	push   $0x6
  800d27:	68 dc 14 80 00       	push   $0x8014dc
  800d2c:	6a 4c                	push   $0x4c
  800d2e:	68 f9 14 80 00       	push   $0x8014f9
  800d33:	e8 dc f4 ff ff       	call   800214 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800d38:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 07 00 00 00       	mov    $0x7,%eax
  800d54:	bf 00 00 00 00       	mov    $0x0,%edi
  800d59:	89 fb                	mov    %edi,%ebx
  800d5b:	89 fe                	mov    %edi,%esi
  800d5d:	55                   	push   %ebp
  800d5e:	9c                   	pushf  
  800d5f:	56                   	push   %esi
  800d60:	54                   	push   %esp
  800d61:	5d                   	pop    %ebp
  800d62:	8d 35 6a 0d 80 00    	lea    0x800d6a,%esi
  800d68:	0f 34                	sysenter 
  800d6a:	83 c4 04             	add    $0x4,%esp
  800d6d:	9d                   	popf   
  800d6e:	5d                   	pop    %ebp
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 17                	jle    800d8a <sys_page_unmap+0x4a>
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	50                   	push   %eax
  800d77:	6a 07                	push   $0x7
  800d79:	68 dc 14 80 00       	push   $0x8014dc
  800d7e:	6a 4c                	push   $0x4c
  800d80:	68 f9 14 80 00       	push   $0x8014f9
  800d85:	e8 8a f4 ff ff       	call   800214 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	b8 09 00 00 00       	mov    $0x9,%eax
  800da6:	bf 00 00 00 00       	mov    $0x0,%edi
  800dab:	89 fb                	mov    %edi,%ebx
  800dad:	89 fe                	mov    %edi,%esi
  800daf:	55                   	push   %ebp
  800db0:	9c                   	pushf  
  800db1:	56                   	push   %esi
  800db2:	54                   	push   %esp
  800db3:	5d                   	pop    %ebp
  800db4:	8d 35 bc 0d 80 00    	lea    0x800dbc,%esi
  800dba:	0f 34                	sysenter 
  800dbc:	83 c4 04             	add    $0x4,%esp
  800dbf:	9d                   	popf   
  800dc0:	5d                   	pop    %ebp
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 17                	jle    800ddc <sys_env_set_status+0x4a>
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	50                   	push   %eax
  800dc9:	6a 09                	push   $0x9
  800dcb:	68 dc 14 80 00       	push   $0x8014dc
  800dd0:	6a 4c                	push   $0x4c
  800dd2:	68 f9 14 80 00       	push   $0x8014f9
  800dd7:	e8 38 f4 ff ff       	call   800214 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ddc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	c9                   	leave  
  800de3:	c3                   	ret    

00800de4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df8:	bf 00 00 00 00       	mov    $0x0,%edi
  800dfd:	89 fb                	mov    %edi,%ebx
  800dff:	89 fe                	mov    %edi,%esi
  800e01:	55                   	push   %ebp
  800e02:	9c                   	pushf  
  800e03:	56                   	push   %esi
  800e04:	54                   	push   %esp
  800e05:	5d                   	pop    %ebp
  800e06:	8d 35 0e 0e 80 00    	lea    0x800e0e,%esi
  800e0c:	0f 34                	sysenter 
  800e0e:	83 c4 04             	add    $0x4,%esp
  800e11:	9d                   	popf   
  800e12:	5d                   	pop    %ebp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7e 17                	jle    800e2e <sys_env_set_trapframe+0x4a>
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	50                   	push   %eax
  800e1b:	6a 0a                	push   $0xa
  800e1d:	68 dc 14 80 00       	push   $0x8014dc
  800e22:	6a 4c                	push   $0x4c
  800e24:	68 f9 14 80 00       	push   $0x8014f9
  800e29:	e8 e6 f3 ff ff       	call   800214 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e2e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    

00800e36 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4f:	89 fb                	mov    %edi,%ebx
  800e51:	89 fe                	mov    %edi,%esi
  800e53:	55                   	push   %ebp
  800e54:	9c                   	pushf  
  800e55:	56                   	push   %esi
  800e56:	54                   	push   %esp
  800e57:	5d                   	pop    %ebp
  800e58:	8d 35 60 0e 80 00    	lea    0x800e60,%esi
  800e5e:	0f 34                	sysenter 
  800e60:	83 c4 04             	add    $0x4,%esp
  800e63:	9d                   	popf   
  800e64:	5d                   	pop    %ebp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_env_set_pgfault_upcall+0x4a>
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 0b                	push   $0xb
  800e6f:	68 dc 14 80 00       	push   $0x8014dc
  800e74:	6a 4c                	push   $0x4c
  800e76:	68 f9 14 80 00       	push   $0x8014f9
  800e7b:	e8 94 f3 ff ff       	call   800214 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ea4:	55                   	push   %ebp
  800ea5:	9c                   	pushf  
  800ea6:	56                   	push   %esi
  800ea7:	54                   	push   %esp
  800ea8:	5d                   	pop    %ebp
  800ea9:	8d 35 b1 0e 80 00    	lea    0x800eb1,%esi
  800eaf:	0f 34                	sysenter 
  800eb1:	83 c4 04             	add    $0x4,%esp
  800eb4:	9d                   	popf   
  800eb5:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ecc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	89 fb                	mov    %edi,%ebx
  800ed5:	89 fe                	mov    %edi,%esi
  800ed7:	55                   	push   %ebp
  800ed8:	9c                   	pushf  
  800ed9:	56                   	push   %esi
  800eda:	54                   	push   %esp
  800edb:	5d                   	pop    %ebp
  800edc:	8d 35 e4 0e 80 00    	lea    0x800ee4,%esi
  800ee2:	0f 34                	sysenter 
  800ee4:	83 c4 04             	add    $0x4,%esp
  800ee7:	9d                   	popf   
  800ee8:	5d                   	pop    %ebp
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 17                	jle    800f04 <sys_ipc_recv+0x49>
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	50                   	push   %eax
  800ef1:	6a 0e                	push   $0xe
  800ef3:	68 dc 14 80 00       	push   $0x8014dc
  800ef8:	6a 4c                	push   $0x4c
  800efa:	68 f9 14 80 00       	push   $0x8014f9
  800eff:	e8 10 f3 ff ff       	call   800214 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f04:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <__udivdi3>:
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	83 ec 20             	sub    $0x20,%esp
  800f14:	8b 55 14             	mov    0x14(%ebp),%edx
  800f17:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f20:	85 d2                	test   %edx,%edx
  800f22:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800f25:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800f2c:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800f33:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800f36:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800f39:	89 fe                	mov    %edi,%esi
  800f3b:	75 5b                	jne    800f98 <__udivdi3+0x8c>
  800f3d:	39 f8                	cmp    %edi,%eax
  800f3f:	76 2b                	jbe    800f6c <__udivdi3+0x60>
  800f41:	89 fa                	mov    %edi,%edx
  800f43:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800f46:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f49:	89 c7                	mov    %eax,%edi
  800f4b:	90                   	nop    
  800f4c:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800f53:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800f56:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800f59:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800f5c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f5f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f62:	83 c4 20             	add    $0x20,%esp
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    
  800f69:	8d 76 00             	lea    0x0(%esi),%esi
  800f6c:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	75 0e                	jne    800f81 <__udivdi3+0x75>
  800f73:	b8 01 00 00 00       	mov    $0x1,%eax
  800f78:	31 c9                	xor    %ecx,%ecx
  800f7a:	31 d2                	xor    %edx,%edx
  800f7c:	f7 f1                	div    %ecx
  800f7e:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f88:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800f8b:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800f8e:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f91:	89 c7                	mov    %eax,%edi
  800f93:	eb be                	jmp    800f53 <__udivdi3+0x47>
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
  800f98:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800f9b:	76 07                	jbe    800fa4 <__udivdi3+0x98>
  800f9d:	31 ff                	xor    %edi,%edi
  800f9f:	eb ab                	jmp    800f4c <__udivdi3+0x40>
  800fa1:	8d 76 00             	lea    0x0(%esi),%esi
  800fa4:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800fa8:	89 c7                	mov    %eax,%edi
  800faa:	83 f7 1f             	xor    $0x1f,%edi
  800fad:	75 19                	jne    800fc8 <__udivdi3+0xbc>
  800faf:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800fb2:	77 0a                	ja     800fbe <__udivdi3+0xb2>
  800fb4:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800fb7:	31 ff                	xor    %edi,%edi
  800fb9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800fbc:	72 8e                	jb     800f4c <__udivdi3+0x40>
  800fbe:	bf 01 00 00 00       	mov    $0x1,%edi
  800fc3:	eb 87                	jmp    800f4c <__udivdi3+0x40>
  800fc5:	8d 76 00             	lea    0x0(%esi),%esi
  800fc8:	b8 20 00 00 00       	mov    $0x20,%eax
  800fcd:	29 f8                	sub    %edi,%eax
  800fcf:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800fd2:	89 f9                	mov    %edi,%ecx
  800fd4:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800fd7:	d3 e2                	shl    %cl,%edx
  800fd9:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800fdc:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800fdf:	d3 e8                	shr    %cl,%eax
  800fe1:	09 c2                	or     %eax,%edx
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800fe8:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800feb:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800fee:	89 f2                	mov    %esi,%edx
  800ff0:	d3 ea                	shr    %cl,%edx
  800ff2:	89 f9                	mov    %edi,%ecx
  800ff4:	d3 e6                	shl    %cl,%esi
  800ff6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800ff9:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800ffc:	d3 e8                	shr    %cl,%eax
  800ffe:	09 c6                	or     %eax,%esi
  801000:	89 f9                	mov    %edi,%ecx
  801002:	89 f0                	mov    %esi,%eax
  801004:	f7 75 ec             	divl   0xffffffec(%ebp)
  801007:	89 d6                	mov    %edx,%esi
  801009:	89 c7                	mov    %eax,%edi
  80100b:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  80100e:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  801011:	f7 e7                	mul    %edi
  801013:	39 f2                	cmp    %esi,%edx
  801015:	77 0f                	ja     801026 <__udivdi3+0x11a>
  801017:	0f 85 2f ff ff ff    	jne    800f4c <__udivdi3+0x40>
  80101d:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  801020:	0f 86 26 ff ff ff    	jbe    800f4c <__udivdi3+0x40>
  801026:	4f                   	dec    %edi
  801027:	e9 20 ff ff ff       	jmp    800f4c <__udivdi3+0x40>

0080102c <__umoddi3>:
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	83 ec 30             	sub    $0x30,%esp
  801034:	8b 55 14             	mov    0x14(%ebp),%edx
  801037:	8b 75 08             	mov    0x8(%ebp),%esi
  80103a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80103d:	8b 45 10             	mov    0x10(%ebp),%eax
  801040:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  801043:	85 d2                	test   %edx,%edx
  801045:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  80104c:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  801053:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  801056:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  801059:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80105c:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  80105f:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801062:	75 68                	jne    8010cc <__umoddi3+0xa0>
  801064:	39 f8                	cmp    %edi,%eax
  801066:	76 3c                	jbe    8010a4 <__umoddi3+0x78>
  801068:	89 f0                	mov    %esi,%eax
  80106a:	89 fa                	mov    %edi,%edx
  80106c:	f7 75 cc             	divl   0xffffffcc(%ebp)
  80106f:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  801072:	85 c9                	test   %ecx,%ecx
  801074:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  801077:	74 1b                	je     801094 <__umoddi3+0x68>
  801079:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80107c:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  80107f:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  801086:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  801089:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  80108c:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  80108f:	89 10                	mov    %edx,(%eax)
  801091:	89 48 04             	mov    %ecx,0x4(%eax)
  801094:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801097:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80109a:	83 c4 30             	add    $0x30,%esp
  80109d:	5e                   	pop    %esi
  80109e:	5f                   	pop    %edi
  80109f:	c9                   	leave  
  8010a0:	c3                   	ret    
  8010a1:	8d 76 00             	lea    0x0(%esi),%esi
  8010a4:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  8010a7:	85 f6                	test   %esi,%esi
  8010a9:	75 0d                	jne    8010b8 <__umoddi3+0x8c>
  8010ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b0:	31 d2                	xor    %edx,%edx
  8010b2:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8010b5:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8010b8:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8010bb:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8010be:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8010c1:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8010c4:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8010c7:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8010ca:	eb a3                	jmp    80106f <__umoddi3+0x43>
  8010cc:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8010cf:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  8010d2:	76 14                	jbe    8010e8 <__umoddi3+0xbc>
  8010d4:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  8010d7:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8010da:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8010dd:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  8010e0:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8010e3:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8010e6:	eb ac                	jmp    801094 <__umoddi3+0x68>
  8010e8:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  8010ec:	89 c6                	mov    %eax,%esi
  8010ee:	83 f6 1f             	xor    $0x1f,%esi
  8010f1:	75 4d                	jne    801140 <__umoddi3+0x114>
  8010f3:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8010f6:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  8010f9:	77 08                	ja     801103 <__umoddi3+0xd7>
  8010fb:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8010fe:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  801101:	72 12                	jb     801115 <__umoddi3+0xe9>
  801103:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801106:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801109:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  80110c:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80110f:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801112:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801115:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801118:	85 d2                	test   %edx,%edx
  80111a:	0f 84 74 ff ff ff    	je     801094 <__umoddi3+0x68>
  801120:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801123:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801126:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801129:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80112c:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  80112f:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801132:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801135:	89 01                	mov    %eax,(%ecx)
  801137:	89 51 04             	mov    %edx,0x4(%ecx)
  80113a:	e9 55 ff ff ff       	jmp    801094 <__umoddi3+0x68>
  80113f:	90                   	nop    
  801140:	b8 20 00 00 00       	mov    $0x20,%eax
  801145:	29 f0                	sub    %esi,%eax
  801147:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80114a:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80114d:	89 f1                	mov    %esi,%ecx
  80114f:	d3 e2                	shl    %cl,%edx
  801151:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  801154:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801157:	d3 e8                	shr    %cl,%eax
  801159:	09 c2                	or     %eax,%edx
  80115b:	89 f1                	mov    %esi,%ecx
  80115d:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801160:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801163:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801166:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801169:	d3 ea                	shr    %cl,%edx
  80116b:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  80116e:	89 f1                	mov    %esi,%ecx
  801170:	d3 e7                	shl    %cl,%edi
  801172:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801175:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801178:	d3 e8                	shr    %cl,%eax
  80117a:	09 c7                	or     %eax,%edi
  80117c:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80117f:	89 f8                	mov    %edi,%eax
  801181:	89 f1                	mov    %esi,%ecx
  801183:	f7 75 dc             	divl   0xffffffdc(%ebp)
  801186:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801189:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  80118c:	f7 65 cc             	mull   0xffffffcc(%ebp)
  80118f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801192:	89 c7                	mov    %eax,%edi
  801194:	77 3f                	ja     8011d5 <__umoddi3+0x1a9>
  801196:	74 38                	je     8011d0 <__umoddi3+0x1a4>
  801198:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80119b:	85 c0                	test   %eax,%eax
  80119d:	0f 84 f1 fe ff ff    	je     801094 <__umoddi3+0x68>
  8011a3:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  8011a6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8011a9:	29 f8                	sub    %edi,%eax
  8011ab:	19 d1                	sbb    %edx,%ecx
  8011ad:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8011b0:	89 ca                	mov    %ecx,%edx
  8011b2:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8011b5:	d3 e2                	shl    %cl,%edx
  8011b7:	89 f1                	mov    %esi,%ecx
  8011b9:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8011bc:	d3 e8                	shr    %cl,%eax
  8011be:	09 c2                	or     %eax,%edx
  8011c0:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8011c3:	d3 e8                	shr    %cl,%eax
  8011c5:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8011c8:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8011cb:	e9 b6 fe ff ff       	jmp    801086 <__umoddi3+0x5a>
  8011d0:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  8011d3:	76 c3                	jbe    801198 <__umoddi3+0x16c>
  8011d5:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  8011d8:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  8011db:	eb bb                	jmp    801198 <__umoddi3+0x16c>
  8011dd:	90                   	nop    
  8011de:	90                   	nop    
  8011df:	90                   	nop    
