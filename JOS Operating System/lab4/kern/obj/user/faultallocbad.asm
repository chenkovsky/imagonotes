
obj/user/faultallocbad：     文件格式 elf32-i386

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
  80002c:	e8 83 00 00 00       	call   8000b4 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:
#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	53                   	push   %ebx
  800041:	68 40 11 80 00       	push   $0x801140
  800046:	e8 ad 01 00 00       	call   8001f8 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	89 d8                	mov    %ebx,%eax
  800050:	25 ff 0f 00 00       	and    $0xfff,%eax
  800055:	89 da                	mov    %ebx,%edx
  800057:	29 c2                	sub    %eax,%edx
  800059:	6a 07                	push   $0x7
  80005b:	52                   	push   %edx
  80005c:	6a 00                	push   $0x0
  80005e:	e8 2c 0b 00 00       	call   800b8f <sys_page_alloc>
  800063:	83 c4 10             	add    $0x10,%esp
  800066:	85 c0                	test   %eax,%eax
  800068:	79 16                	jns    800080 <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80006a:	83 ec 0c             	sub    $0xc,%esp
  80006d:	50                   	push   %eax
  80006e:	53                   	push   %ebx
  80006f:	68 60 11 80 00       	push   $0x801160
  800074:	6a 0f                	push   $0xf
  800076:	68 4a 11 80 00       	push   $0x80114a
  80007b:	e8 88 00 00 00       	call   800108 <_panic>
    //cprintf("here handler of fault alloc bad\n");
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800080:	53                   	push   %ebx
  800081:	68 8c 11 80 00       	push   $0x80118c
  800086:	6a 64                	push   $0x64
  800088:	53                   	push   %ebx
  800089:	e8 4f 06 00 00       	call   8006dd <snprintf>
}
  80008e:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <umain>:

void
umain(void)
{    //int a = 3,b = 3,c = 3,d = 3,e = 3,f = 3,g = 3;
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 14             	sub    $0x14,%esp
    //cprintf("a :%d,b :%d,c :%d,d :%d,e :%d,f :%d\n",a,b,c,d,e,f);
	set_pgfault_handler(handler);
  800099:	68 34 00 80 00       	push   $0x800034
  80009e:	e8 5d 0d 00 00       	call   800e00 <set_pgfault_handler>
    //cprintf("got here in faultallocbad\n");
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a3:	83 c4 08             	add    $0x8,%esp
  8000a6:	6a 04                	push   $0x4
  8000a8:	68 ef be ad de       	push   $0xdeadbeef
  8000ad:	e8 a2 09 00 00       	call   800a54 <sys_cputs>
    //cprintf("a :%d,b :%d,c :%d,d :%d,e :%d,f :%d\n",a,b,c,d,e,f);

}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
  8000b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  8000bf:	e8 3e 0a 00 00       	call   800b02 <sys_getenvid>
  8000c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c9:	c1 e0 07             	shl    $0x7,%eax
  8000cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d1:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d6:	85 f6                	test   %esi,%esi
  8000d8:	7e 07                	jle    8000e1 <libmain+0x2d>
		binaryname = argv[0];
  8000da:	8b 03                	mov    (%ebx),%eax
  8000dc:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e1:	83 ec 08             	sub    $0x8,%esp
  8000e4:	53                   	push   %ebx
  8000e5:	56                   	push   %esi
  8000e6:	e8 a8 ff ff ff       	call   800093 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  8000eb:	e8 08 00 00 00       	call   8000f8 <exit>
}
  8000f0:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    
	...

008000f8 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  8000fe:	6a 00                	push   $0x0
  800100:	e8 ac 09 00 00       	call   800ab1 <sys_env_destroy>
}
  800105:	c9                   	leave  
  800106:	c3                   	ret    
	...

00800108 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	53                   	push   %ebx
  80010c:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  80010f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800112:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800119:	74 16                	je     800131 <_panic+0x29>
		cprintf("%s: ", argv0);
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	ff 35 08 20 80 00    	pushl  0x802008
  800124:	68 c4 11 80 00       	push   $0x8011c4
  800129:	e8 ca 00 00 00       	call   8001f8 <cprintf>
  80012e:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800131:	ff 75 0c             	pushl  0xc(%ebp)
  800134:	ff 75 08             	pushl  0x8(%ebp)
  800137:	ff 35 00 20 80 00    	pushl  0x802000
  80013d:	68 c9 11 80 00       	push   $0x8011c9
  800142:	e8 b1 00 00 00       	call   8001f8 <cprintf>
	vcprintf(fmt, ap);
  800147:	83 c4 08             	add    $0x8,%esp
  80014a:	53                   	push   %ebx
  80014b:	ff 75 10             	pushl  0x10(%ebp)
  80014e:	e8 54 00 00 00       	call   8001a7 <vcprintf>
	cprintf("\n");
  800153:	c7 04 24 48 11 80 00 	movl   $0x801148,(%esp)
  80015a:	e8 99 00 00 00       	call   8001f8 <cprintf>

	// Cause a breakpoint exception
	while (1)
  80015f:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800162:	cc                   	int3   
  800163:	eb fd                	jmp    800162 <_panic+0x5a>
}
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	40                   	inc    %eax
  80017c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 1a                	jne    80019f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800185:	83 ec 08             	sub    $0x8,%esp
  800188:	68 ff 00 00 00       	push   $0xff
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 be 08 00 00       	call   800a54 <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019f:	ff 43 04             	incl   0x4(%ebx)
}
  8001a2:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 68 01 80 00       	push   $0x800168
  8001d6:	e8 83 01 00 00       	call   80035e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  8001e4:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 64 08 00 00       	call   800a54 <sys_cputs>

	return b.cnt;
  8001f0:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	8b 75 10             	mov    0x10(%ebp),%esi
  800218:	8b 7d 14             	mov    0x14(%ebp),%edi
  80021b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 45 18             	mov    0x18(%ebp),%eax
  800221:	ba 00 00 00 00       	mov    $0x0,%edx
  800226:	39 d7                	cmp    %edx,%edi
  800228:	72 39                	jb     800263 <printnum+0x57>
  80022a:	77 04                	ja     800230 <printnum+0x24>
  80022c:	39 c6                	cmp    %eax,%esi
  80022e:	72 33                	jb     800263 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800230:	83 ec 04             	sub    $0x4,%esp
  800233:	ff 75 20             	pushl  0x20(%ebp)
  800236:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800239:	50                   	push   %eax
  80023a:	ff 75 18             	pushl  0x18(%ebp)
  80023d:	8b 45 18             	mov    0x18(%ebp),%eax
  800240:	ba 00 00 00 00       	mov    $0x0,%edx
  800245:	52                   	push   %edx
  800246:	50                   	push   %eax
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	e8 1e 0c 00 00       	call   800e6c <__udivdi3>
  80024e:	83 c4 10             	add    $0x10,%esp
  800251:	52                   	push   %edx
  800252:	50                   	push   %eax
  800253:	ff 75 0c             	pushl  0xc(%ebp)
  800256:	ff 75 08             	pushl  0x8(%ebp)
  800259:	e8 ae ff ff ff       	call   80020c <printnum>
  80025e:	83 c4 20             	add    $0x20,%esp
  800261:	eb 19                	jmp    80027c <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800263:	4b                   	dec    %ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7e 14                	jle    80027c <printnum+0x70>
			putch(padc, putdat);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	ff 75 20             	pushl  0x20(%ebp)
  800271:	ff 55 08             	call   *0x8(%ebp)
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	4b                   	dec    %ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f ec                	jg     800268 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	ff 75 0c             	pushl  0xc(%ebp)
  800282:	8b 45 18             	mov    0x18(%ebp),%eax
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
  80028a:	83 ec 04             	sub    $0x4,%esp
  80028d:	52                   	push   %edx
  80028e:	50                   	push   %eax
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	e8 f6 0c 00 00       	call   800f8c <__umoddi3>
  800296:	83 c4 14             	add    $0x14,%esp
  800299:	0f be 80 78 12 80 00 	movsbl 0x801278(%eax),%eax
  8002a0:	50                   	push   %eax
  8002a1:	ff 55 08             	call   *0x8(%ebp)
}
  8002a4:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 18             	sub    $0x18,%esp
  8002b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ba:	8a 45 18             	mov    0x18(%ebp),%al
  8002bd:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  8002c0:	53                   	push   %ebx
  8002c1:	6a 1b                	push   $0x1b
  8002c3:	ff d6                	call   *%esi
	putch('[', putdat);
  8002c5:	83 c4 08             	add    $0x8,%esp
  8002c8:	53                   	push   %ebx
  8002c9:	6a 5b                	push   $0x5b
  8002cb:	ff d6                	call   *%esi
	putch('0', putdat);
  8002cd:	83 c4 08             	add    $0x8,%esp
  8002d0:	53                   	push   %ebx
  8002d1:	6a 30                	push   $0x30
  8002d3:	ff d6                	call   *%esi
	putch(';', putdat);
  8002d5:	83 c4 08             	add    $0x8,%esp
  8002d8:	53                   	push   %ebx
  8002d9:	6a 3b                	push   $0x3b
  8002db:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  8002dd:	83 c4 0c             	add    $0xc,%esp
  8002e0:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  8002e4:	50                   	push   %eax
  8002e5:	ff 75 14             	pushl  0x14(%ebp)
  8002e8:	6a 0a                	push   $0xa
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	99                   	cltd   
  8002ee:	52                   	push   %edx
  8002ef:	50                   	push   %eax
  8002f0:	53                   	push   %ebx
  8002f1:	56                   	push   %esi
  8002f2:	e8 15 ff ff ff       	call   80020c <printnum>
	putch('m', putdat);
  8002f7:	83 c4 18             	add    $0x18,%esp
  8002fa:	53                   	push   %ebx
  8002fb:	6a 6d                	push   $0x6d
  8002fd:	ff d6                	call   *%esi

}
  8002ff:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80030f:	83 f8 01             	cmp    $0x1,%eax
  800312:	7e 0f                	jle    800323 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800314:	8b 01                	mov    (%ecx),%eax
  800316:	83 c0 08             	add    $0x8,%eax
  800319:	89 01                	mov    %eax,(%ecx)
  80031b:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80031e:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800321:	eb 0f                	jmp    800332 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800323:	8b 01                	mov    (%ecx),%eax
  800325:	83 c0 04             	add    $0x4,%eax
  800328:	89 01                	mov    %eax,(%ecx)
  80032a:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  80032d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80033d:	83 f8 01             	cmp    $0x1,%eax
  800340:	7e 0f                	jle    800351 <getint+0x1d>
		return va_arg(*ap, long long);
  800342:	8b 02                	mov    (%edx),%eax
  800344:	83 c0 08             	add    $0x8,%eax
  800347:	89 02                	mov    %eax,(%edx)
  800349:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80034c:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80034f:	eb 0b                	jmp    80035c <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800351:	8b 02                	mov    (%edx),%eax
  800353:	83 c0 04             	add    $0x4,%eax
  800356:	89 02                	mov    %eax,(%edx)
  800358:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  80035b:	99                   	cltd   
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 1c             	sub    $0x1c,%esp
  800367:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036a:	0f b6 13             	movzbl (%ebx),%edx
  80036d:	43                   	inc    %ebx
  80036e:	83 fa 25             	cmp    $0x25,%edx
  800371:	74 1e                	je     800391 <vprintfmt+0x33>
			if (ch == '\0')
  800373:	85 d2                	test   %edx,%edx
  800375:	0f 84 dc 02 00 00    	je     800657 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  80037b:	83 ec 08             	sub    $0x8,%esp
  80037e:	ff 75 0c             	pushl  0xc(%ebp)
  800381:	52                   	push   %edx
  800382:	ff 55 08             	call   *0x8(%ebp)
  800385:	83 c4 10             	add    $0x10,%esp
  800388:	0f b6 13             	movzbl (%ebx),%edx
  80038b:	43                   	inc    %ebx
  80038c:	83 fa 25             	cmp    $0x25,%edx
  80038f:	75 e2                	jne    800373 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800391:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  800395:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  80039c:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8003a1:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8003a6:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  8003ad:	0f b6 13             	movzbl (%ebx),%edx
  8003b0:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8003b3:	43                   	inc    %ebx
  8003b4:	83 f8 55             	cmp    $0x55,%eax
  8003b7:	0f 87 75 02 00 00    	ja     800632 <vprintfmt+0x2d4>
  8003bd:	ff 24 85 c4 12 80 00 	jmp    *0x8012c4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c4:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  8003c8:	eb e3                	jmp    8003ad <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ca:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  8003ce:	eb dd                	jmp    8003ad <vprintfmt+0x4f>

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
  8003d0:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8003d5:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8003d8:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  8003dc:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8003df:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8003e2:	83 f8 09             	cmp    $0x9,%eax
  8003e5:	77 27                	ja     80040e <vprintfmt+0xb0>
  8003e7:	43                   	inc    %ebx
  8003e8:	eb eb                	jmp    8003d5 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ea:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  8003f4:	eb 18                	jmp    80040e <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  8003f6:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003fa:	79 b1                	jns    8003ad <vprintfmt+0x4f>
				width = 0;
  8003fc:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  800403:	eb a8                	jmp    8003ad <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800405:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  80040c:	eb 9f                	jmp    8003ad <vprintfmt+0x4f>

			process_precision: if (width < 0)
  80040e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800412:	79 99                	jns    8003ad <vprintfmt+0x4f>
				width = precision, precision = -1;
  800414:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800417:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80041c:	eb 8f                	jmp    8003ad <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041e:	41                   	inc    %ecx
			goto reswitch;
  80041f:	eb 8c                	jmp    8003ad <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	ff 75 0c             	pushl  0xc(%ebp)
  800427:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	ff 70 fc             	pushl  0xfffffffc(%eax)
  800431:	e9 c4 01 00 00       	jmp    8005fa <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  800436:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  800440:	85 c0                	test   %eax,%eax
  800442:	79 02                	jns    800446 <vprintfmt+0xe8>
				err = -err;
  800444:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800446:	83 f8 08             	cmp    $0x8,%eax
  800449:	7f 0b                	jg     800456 <vprintfmt+0xf8>
  80044b:	8b 3c 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edi
  800452:	85 ff                	test   %edi,%edi
  800454:	75 08                	jne    80045e <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  800456:	50                   	push   %eax
  800457:	68 89 12 80 00       	push   $0x801289
  80045c:	eb 06                	jmp    800464 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  80045e:	57                   	push   %edi
  80045f:	68 92 12 80 00       	push   $0x801292
  800464:	ff 75 0c             	pushl  0xc(%ebp)
  800467:	ff 75 08             	pushl  0x8(%ebp)
  80046a:	e8 f0 01 00 00       	call   80065f <printfmt>
  80046f:	e9 89 01 00 00       	jmp    8005fd <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800474:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  80047e:	85 ff                	test   %edi,%edi
  800480:	75 05                	jne    800487 <vprintfmt+0x129>
				p = "(null)";
  800482:	bf 95 12 80 00       	mov    $0x801295,%edi
			if (width > 0 && padc != '-')
  800487:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80048b:	7e 3b                	jle    8004c8 <vprintfmt+0x16a>
  80048d:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  800491:	74 35                	je     8004c8 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	56                   	push   %esi
  800497:	57                   	push   %edi
  800498:	e8 74 02 00 00       	call   800711 <strnlen>
  80049d:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004a7:	7e 1f                	jle    8004c8 <vprintfmt+0x16a>
  8004a9:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8004ad:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004c2:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004c6:	7f e8                	jg     8004b0 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	0f be 17             	movsbl (%edi),%edx
  8004cb:	47                   	inc    %edi
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	74 3e                	je     80050e <vprintfmt+0x1b0>
  8004d0:	85 f6                	test   %esi,%esi
  8004d2:	78 03                	js     8004d7 <vprintfmt+0x179>
  8004d4:	4e                   	dec    %esi
  8004d5:	78 37                	js     80050e <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d7:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8004db:	74 12                	je     8004ef <vprintfmt+0x191>
  8004dd:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8004e0:	83 f8 5e             	cmp    $0x5e,%eax
  8004e3:	76 0a                	jbe    8004ef <vprintfmt+0x191>
					putch('?', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	6a 3f                	push   $0x3f
  8004ed:	eb 07                	jmp    8004f6 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	ff 75 0c             	pushl  0xc(%ebp)
  8004f5:	52                   	push   %edx
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004ff:	0f be 17             	movsbl (%edi),%edx
  800502:	47                   	inc    %edi
  800503:	85 d2                	test   %edx,%edx
  800505:	74 07                	je     80050e <vprintfmt+0x1b0>
  800507:	85 f6                	test   %esi,%esi
  800509:	78 cc                	js     8004d7 <vprintfmt+0x179>
  80050b:	4e                   	dec    %esi
  80050c:	79 c9                	jns    8004d7 <vprintfmt+0x179>
			for (; width > 0; width--)
  80050e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800512:	0f 8e 52 fe ff ff    	jle    80036a <vprintfmt+0xc>
				putch(' ', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	6a 20                	push   $0x20
  800520:	ff 55 08             	call   *0x8(%ebp)
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800529:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80052d:	7f e9                	jg     800518 <vprintfmt+0x1ba>
			break;
  80052f:	e9 36 fe ff ff       	jmp    80036a <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	51                   	push   %ecx
  800538:	8d 45 14             	lea    0x14(%ebp),%eax
  80053b:	50                   	push   %eax
  80053c:	e8 f3 fd ff ff       	call   800334 <getint>
  800541:	89 c6                	mov    %eax,%esi
  800543:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	85 d2                	test   %edx,%edx
  80054a:	79 15                	jns    800561 <vprintfmt+0x203>
				putch('-', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	ff 75 0c             	pushl  0xc(%ebp)
  800552:	6a 2d                	push   $0x2d
  800554:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800557:	f7 de                	neg    %esi
  800559:	83 d7 00             	adc    $0x0,%edi
  80055c:	f7 df                	neg    %edi
  80055e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800561:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800566:	eb 70                	jmp    8005d8 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	51                   	push   %ecx
  80056c:	8d 45 14             	lea    0x14(%ebp),%eax
  80056f:	50                   	push   %eax
  800570:	e8 91 fd ff ff       	call   800306 <getuint>
  800575:	89 c6                	mov    %eax,%esi
  800577:	89 d7                	mov    %edx,%edi
			base = 10;
  800579:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80057e:	eb 55                	jmp    8005d5 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	51                   	push   %ecx
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	50                   	push   %eax
  800588:	e8 79 fd ff ff       	call   800306 <getuint>
  80058d:	89 c6                	mov    %eax,%esi
  80058f:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  800591:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800596:	eb 3d                	jmp    8005d5 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	6a 30                	push   $0x30
  8005a0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a3:	83 c4 08             	add    $0x8,%esp
  8005a6:	ff 75 0c             	pushl  0xc(%ebp)
  8005a9:	6a 78                	push   $0x78
  8005ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005ae:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8005b8:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  8005bd:	eb 11                	jmp    8005d0 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	51                   	push   %ecx
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c6:	50                   	push   %eax
  8005c7:	e8 3a fd ff ff       	call   800306 <getuint>
  8005cc:	89 c6                	mov    %eax,%esi
  8005ce:	89 d7                	mov    %edx,%edi
			base = 16;
  8005d0:	ba 10 00 00 00       	mov    $0x10,%edx
  8005d5:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  8005d8:	83 ec 04             	sub    $0x4,%esp
  8005db:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8005df:	50                   	push   %eax
  8005e0:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8005e3:	52                   	push   %edx
  8005e4:	57                   	push   %edi
  8005e5:	56                   	push   %esi
  8005e6:	ff 75 0c             	pushl  0xc(%ebp)
  8005e9:	ff 75 08             	pushl  0x8(%ebp)
  8005ec:	e8 1b fc ff ff       	call   80020c <printnum>
			break;
  8005f1:	eb 37                	jmp    80062a <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	ff 75 0c             	pushl  0xc(%ebp)
  8005f9:	52                   	push   %edx
  8005fa:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	e9 65 fd ff ff       	jmp    80036a <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	51                   	push   %ecx
  800609:	8d 45 14             	lea    0x14(%ebp),%eax
  80060c:	50                   	push   %eax
  80060d:	e8 f4 fc ff ff       	call   800306 <getuint>
  800612:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800614:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80061e:	56                   	push   %esi
  80061f:	ff 75 0c             	pushl  0xc(%ebp)
  800622:	ff 75 08             	pushl  0x8(%ebp)
  800625:	e8 82 fc ff ff       	call   8002ac <printcolor>
			break;
  80062a:	83 c4 20             	add    $0x20,%esp
  80062d:	e9 38 fd ff ff       	jmp    80036a <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	ff 75 0c             	pushl  0xc(%ebp)
  800638:	6a 25                	push   $0x25
  80063a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063d:	4b                   	dec    %ebx
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800645:	0f 84 1f fd ff ff    	je     80036a <vprintfmt+0xc>
  80064b:	4b                   	dec    %ebx
  80064c:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800650:	75 f9                	jne    80064b <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800652:	e9 13 fd ff ff       	jmp    80036a <vprintfmt+0xc>
		}
	}
}
  800657:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80065a:	5b                   	pop    %ebx
  80065b:	5e                   	pop    %esi
  80065c:	5f                   	pop    %edi
  80065d:	c9                   	leave  
  80065e:	c3                   	ret    

0080065f <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80065f:	55                   	push   %ebp
  800660:	89 e5                	mov    %esp,%ebp
  800662:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800668:	50                   	push   %eax
  800669:	ff 75 10             	pushl  0x10(%ebp)
  80066c:	ff 75 0c             	pushl  0xc(%ebp)
  80066f:	ff 75 08             	pushl  0x8(%ebp)
  800672:	e8 e7 fc ff ff       	call   80035e <vprintfmt>
	va_end(ap);
}
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80067f:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800682:	8b 0a                	mov    (%edx),%ecx
  800684:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800687:	73 07                	jae    800690 <sprintputch+0x17>
		*b->buf++ = ch;
  800689:	8b 45 08             	mov    0x8(%ebp),%eax
  80068c:	88 01                	mov    %al,(%ecx)
  80068e:	ff 02                	incl   (%edx)
}
  800690:	c9                   	leave  
  800691:	c3                   	ret    

00800692 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	83 ec 18             	sub    $0x18,%esp
  800698:	8b 55 08             	mov    0x8(%ebp),%edx
  80069b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80069e:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8006a1:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8006a5:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8006a8:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8006af:	85 d2                	test   %edx,%edx
  8006b1:	74 04                	je     8006b7 <vsnprintf+0x25>
  8006b3:	85 c9                	test   %ecx,%ecx
  8006b5:	7f 07                	jg     8006be <vsnprintf+0x2c>
		return -E_INVAL;
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bc:	eb 1d                	jmp    8006db <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  8006be:	ff 75 14             	pushl  0x14(%ebp)
  8006c1:	ff 75 10             	pushl  0x10(%ebp)
  8006c4:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8006c7:	50                   	push   %eax
  8006c8:	68 79 06 80 00       	push   $0x800679
  8006cd:	e8 8c fc ff ff       	call   80035e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d2:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8006d5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e6:	50                   	push   %eax
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	ff 75 08             	pushl  0x8(%ebp)
  8006f0:	e8 9d ff ff ff       	call   800692 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    
	...

008006f8 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	80 3a 00             	cmpb   $0x0,(%edx)
  800706:	74 07                	je     80070f <strlen+0x17>
		n++;
  800708:	40                   	inc    %eax
  800709:	42                   	inc    %edx
  80070a:	80 3a 00             	cmpb   $0x0,(%edx)
  80070d:	75 f9                	jne    800708 <strlen+0x10>
	return n;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    

00800711 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	85 d2                	test   %edx,%edx
  800721:	74 0f                	je     800732 <strnlen+0x21>
  800723:	80 39 00             	cmpb   $0x0,(%ecx)
  800726:	74 0a                	je     800732 <strnlen+0x21>
		n++;
  800728:	40                   	inc    %eax
  800729:	41                   	inc    %ecx
  80072a:	4a                   	dec    %edx
  80072b:	74 05                	je     800732 <strnlen+0x21>
  80072d:	80 39 00             	cmpb   $0x0,(%ecx)
  800730:	75 f6                	jne    800728 <strnlen+0x17>
	return n;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	53                   	push   %ebx
  800738:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80073e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800740:	8a 02                	mov    (%edx),%al
  800742:	42                   	inc    %edx
  800743:	88 01                	mov    %al,(%ecx)
  800745:	41                   	inc    %ecx
  800746:	84 c0                	test   %al,%al
  800748:	75 f6                	jne    800740 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074a:	89 d8                	mov    %ebx,%eax
  80074c:	5b                   	pop    %ebx
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	57                   	push   %edi
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075b:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80075e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800760:	bb 00 00 00 00       	mov    $0x0,%ebx
  800765:	39 f3                	cmp    %esi,%ebx
  800767:	73 10                	jae    800779 <strncpy+0x2a>
		*dst++ = *src;
  800769:	8a 02                	mov    (%edx),%al
  80076b:	88 01                	mov    %al,(%ecx)
  80076d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80076e:	80 3a 00             	cmpb   $0x0,(%edx)
  800771:	74 01                	je     800774 <strncpy+0x25>
			src++;
  800773:	42                   	inc    %edx
  800774:	43                   	inc    %ebx
  800775:	39 f3                	cmp    %esi,%ebx
  800777:	72 f0                	jb     800769 <strncpy+0x1a>
	}
	return ret;
}
  800779:	89 f8                	mov    %edi,%eax
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80078e:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800790:	85 d2                	test   %edx,%edx
  800792:	74 19                	je     8007ad <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800794:	4a                   	dec    %edx
  800795:	74 13                	je     8007aa <strlcpy+0x2a>
  800797:	80 39 00             	cmpb   $0x0,(%ecx)
  80079a:	74 0e                	je     8007aa <strlcpy+0x2a>
			*dst++ = *src++;
  80079c:	8a 01                	mov    (%ecx),%al
  80079e:	41                   	inc    %ecx
  80079f:	88 03                	mov    %al,(%ebx)
  8007a1:	43                   	inc    %ebx
  8007a2:	4a                   	dec    %edx
  8007a3:	74 05                	je     8007aa <strlcpy+0x2a>
  8007a5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a8:	75 f2                	jne    80079c <strlcpy+0x1c>
		*dst = '\0';
  8007aa:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8007ad:	89 d8                	mov    %ebx,%eax
  8007af:	29 f0                	sub    %esi,%eax
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8007be:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c1:	74 13                	je     8007d6 <strcmp+0x21>
  8007c3:	8a 02                	mov    (%edx),%al
  8007c5:	3a 01                	cmp    (%ecx),%al
  8007c7:	75 0d                	jne    8007d6 <strcmp+0x21>
		p++, q++;
  8007c9:	42                   	inc    %edx
  8007ca:	41                   	inc    %ecx
  8007cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ce:	74 06                	je     8007d6 <strcmp+0x21>
  8007d0:	8a 02                	mov    (%edx),%al
  8007d2:	3a 01                	cmp    (%ecx),%al
  8007d4:	74 f3                	je     8007c9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d6:	0f b6 02             	movzbl (%edx),%eax
  8007d9:	0f b6 11             	movzbl (%ecx),%edx
  8007dc:	29 d0                	sub    %edx,%eax
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  8007ed:	85 c9                	test   %ecx,%ecx
  8007ef:	74 1f                	je     800810 <strncmp+0x30>
  8007f1:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f4:	74 16                	je     80080c <strncmp+0x2c>
  8007f6:	8a 02                	mov    (%edx),%al
  8007f8:	3a 03                	cmp    (%ebx),%al
  8007fa:	75 10                	jne    80080c <strncmp+0x2c>
		n--, p++, q++;
  8007fc:	42                   	inc    %edx
  8007fd:	43                   	inc    %ebx
  8007fe:	49                   	dec    %ecx
  8007ff:	74 0f                	je     800810 <strncmp+0x30>
  800801:	80 3a 00             	cmpb   $0x0,(%edx)
  800804:	74 06                	je     80080c <strncmp+0x2c>
  800806:	8a 02                	mov    (%edx),%al
  800808:	3a 03                	cmp    (%ebx),%al
  80080a:	74 f0                	je     8007fc <strncmp+0x1c>
	if (n == 0)
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	75 07                	jne    800817 <strncmp+0x37>
		return 0;
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 0a                	jmp    800821 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800817:	0f b6 12             	movzbl (%edx),%edx
  80081a:	0f b6 03             	movzbl (%ebx),%eax
  80081d:	29 c2                	sub    %eax,%edx
  80081f:	89 d0                	mov    %edx,%eax
}
  800821:	8b 1c 24             	mov    (%esp),%ebx
  800824:	c9                   	leave  
  800825:	c3                   	ret    

00800826 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80082f:	80 38 00             	cmpb   $0x0,(%eax)
  800832:	74 0a                	je     80083e <strchr+0x18>
		if (*s == c)
  800834:	38 10                	cmp    %dl,(%eax)
  800836:	74 0b                	je     800843 <strchr+0x1d>
  800838:	40                   	inc    %eax
  800839:	80 38 00             	cmpb   $0x0,(%eax)
  80083c:	75 f6                	jne    800834 <strchr+0xe>
			return (char *) s;
	return 0;
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80084e:	80 38 00             	cmpb   $0x0,(%eax)
  800851:	74 0a                	je     80085d <strfind+0x18>
		if (*s == c)
  800853:	38 10                	cmp    %dl,(%eax)
  800855:	74 06                	je     80085d <strfind+0x18>
  800857:	40                   	inc    %eax
  800858:	80 38 00             	cmpb   $0x0,(%eax)
  80085b:	75 f6                	jne    800853 <strfind+0xe>
			break;
	return (char *) s;
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	57                   	push   %edi
  800863:	8b 7d 08             	mov    0x8(%ebp),%edi
  800866:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800869:	89 f8                	mov    %edi,%eax
  80086b:	85 c9                	test   %ecx,%ecx
  80086d:	74 40                	je     8008af <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800875:	75 30                	jne    8008a7 <memset+0x48>
  800877:	f6 c1 03             	test   $0x3,%cl
  80087a:	75 2b                	jne    8008a7 <memset+0x48>
		c &= 0xFF;
  80087c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800883:	8b 45 0c             	mov    0xc(%ebp),%eax
  800886:	c1 e0 18             	shl    $0x18,%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	c1 e2 10             	shl    $0x10,%edx
  80088f:	09 d0                	or     %edx,%eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
  800894:	c1 e2 08             	shl    $0x8,%edx
  800897:	09 d0                	or     %edx,%eax
  800899:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80089c:	c1 e9 02             	shr    $0x2,%ecx
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	fc                   	cld    
  8008a3:	f3 ab                	repz stos %eax,%es:(%edi)
  8008a5:	eb 06                	jmp    8008ad <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008aa:	fc                   	cld    
  8008ab:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8008ad:	89 f8                	mov    %edi,%eax
}
  8008af:	8b 3c 24             	mov    (%esp),%edi
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8008bf:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008c2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008c4:	39 c6                	cmp    %eax,%esi
  8008c6:	73 33                	jae    8008fb <memmove+0x47>
  8008c8:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  8008cb:	39 c2                	cmp    %eax,%edx
  8008cd:	76 2c                	jbe    8008fb <memmove+0x47>
		s += n;
  8008cf:	89 d6                	mov    %edx,%esi
		d += n;
  8008d1:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d4:	f6 c2 03             	test   $0x3,%dl
  8008d7:	75 1b                	jne    8008f4 <memmove+0x40>
  8008d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008df:	75 13                	jne    8008f4 <memmove+0x40>
  8008e1:	f6 c1 03             	test   $0x3,%cl
  8008e4:	75 0e                	jne    8008f4 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8008e6:	83 ef 04             	sub    $0x4,%edi
  8008e9:	83 ee 04             	sub    $0x4,%esi
  8008ec:	c1 e9 02             	shr    $0x2,%ecx
  8008ef:	fd                   	std    
  8008f0:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  8008f2:	eb 27                	jmp    80091b <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f4:	4f                   	dec    %edi
  8008f5:	4e                   	dec    %esi
  8008f6:	fd                   	std    
  8008f7:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  8008f9:	eb 20                	jmp    80091b <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800901:	75 15                	jne    800918 <memmove+0x64>
  800903:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800909:	75 0d                	jne    800918 <memmove+0x64>
  80090b:	f6 c1 03             	test   $0x3,%cl
  80090e:	75 08                	jne    800918 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800910:	c1 e9 02             	shr    $0x2,%ecx
  800913:	fc                   	cld    
  800914:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800916:	eb 03                	jmp    80091b <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800918:	fc                   	cld    
  800919:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcpy>:

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
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800925:	ff 75 10             	pushl  0x10(%ebp)
  800928:	ff 75 0c             	pushl  0xc(%ebp)
  80092b:	ff 75 08             	pushl  0x8(%ebp)
  80092e:	e8 81 ff ff ff       	call   8008b4 <memmove>
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  80093c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  80093f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  800942:	89 d0                	mov    %edx,%eax
  800944:	4a                   	dec    %edx
  800945:	85 c0                	test   %eax,%eax
  800947:	74 1b                	je     800964 <memcmp+0x2f>
		if (*s1 != *s2)
  800949:	8a 01                	mov    (%ecx),%al
  80094b:	3a 03                	cmp    (%ebx),%al
  80094d:	74 0c                	je     80095b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80094f:	0f b6 d0             	movzbl %al,%edx
  800952:	0f b6 03             	movzbl (%ebx),%eax
  800955:	29 c2                	sub    %eax,%edx
  800957:	89 d0                	mov    %edx,%eax
  800959:	eb 0e                	jmp    800969 <memcmp+0x34>
		s1++, s2++;
  80095b:	41                   	inc    %ecx
  80095c:	43                   	inc    %ebx
  80095d:	89 d0                	mov    %edx,%eax
  80095f:	4a                   	dec    %edx
  800960:	85 c0                	test   %eax,%eax
  800962:	75 e5                	jne    800949 <memcmp+0x14>
	}

	return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	5b                   	pop    %ebx
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800975:	89 c2                	mov    %eax,%edx
  800977:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097a:	39 d0                	cmp    %edx,%eax
  80097c:	73 09                	jae    800987 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097e:	38 08                	cmp    %cl,(%eax)
  800980:	74 05                	je     800987 <memfind+0x1b>
  800982:	40                   	inc    %eax
  800983:	39 d0                	cmp    %edx,%eax
  800985:	72 f7                	jb     80097e <memfind+0x12>
			break;
	return (void *) s;
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	57                   	push   %edi
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 55 08             	mov    0x8(%ebp),%edx
  800992:	8b 75 0c             	mov    0xc(%ebp),%esi
  800995:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800998:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  80099d:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a2:	80 3a 20             	cmpb   $0x20,(%edx)
  8009a5:	74 05                	je     8009ac <strtol+0x23>
  8009a7:	80 3a 09             	cmpb   $0x9,(%edx)
  8009aa:	75 0b                	jne    8009b7 <strtol+0x2e>
		s++;
  8009ac:	42                   	inc    %edx
  8009ad:	80 3a 20             	cmpb   $0x20,(%edx)
  8009b0:	74 fa                	je     8009ac <strtol+0x23>
  8009b2:	80 3a 09             	cmpb   $0x9,(%edx)
  8009b5:	74 f5                	je     8009ac <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8009b7:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8009ba:	75 03                	jne    8009bf <strtol+0x36>
		s++;
  8009bc:	42                   	inc    %edx
  8009bd:	eb 0b                	jmp    8009ca <strtol+0x41>
	else if (*s == '-')
  8009bf:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8009c2:	75 06                	jne    8009ca <strtol+0x41>
		s++, neg = 1;
  8009c4:	42                   	inc    %edx
  8009c5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ca:	85 c9                	test   %ecx,%ecx
  8009cc:	74 05                	je     8009d3 <strtol+0x4a>
  8009ce:	83 f9 10             	cmp    $0x10,%ecx
  8009d1:	75 15                	jne    8009e8 <strtol+0x5f>
  8009d3:	80 3a 30             	cmpb   $0x30,(%edx)
  8009d6:	75 10                	jne    8009e8 <strtol+0x5f>
  8009d8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009dc:	75 0a                	jne    8009e8 <strtol+0x5f>
		s += 2, base = 16;
  8009de:	83 c2 02             	add    $0x2,%edx
  8009e1:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009e6:	eb 1a                	jmp    800a02 <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  8009e8:	85 c9                	test   %ecx,%ecx
  8009ea:	75 16                	jne    800a02 <strtol+0x79>
  8009ec:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ef:	75 08                	jne    8009f9 <strtol+0x70>
		s++, base = 8;
  8009f1:	42                   	inc    %edx
  8009f2:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009f7:	eb 09                	jmp    800a02 <strtol+0x79>
	else if (base == 0)
  8009f9:	85 c9                	test   %ecx,%ecx
  8009fb:	75 05                	jne    800a02 <strtol+0x79>
		base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a02:	8a 02                	mov    (%edx),%al
  800a04:	83 e8 30             	sub    $0x30,%eax
  800a07:	3c 09                	cmp    $0x9,%al
  800a09:	77 08                	ja     800a13 <strtol+0x8a>
			dig = *s - '0';
  800a0b:	0f be 02             	movsbl (%edx),%eax
  800a0e:	83 e8 30             	sub    $0x30,%eax
  800a11:	eb 20                	jmp    800a33 <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800a13:	8a 02                	mov    (%edx),%al
  800a15:	83 e8 61             	sub    $0x61,%eax
  800a18:	3c 19                	cmp    $0x19,%al
  800a1a:	77 08                	ja     800a24 <strtol+0x9b>
			dig = *s - 'a' + 10;
  800a1c:	0f be 02             	movsbl (%edx),%eax
  800a1f:	83 e8 57             	sub    $0x57,%eax
  800a22:	eb 0f                	jmp    800a33 <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800a24:	8a 02                	mov    (%edx),%al
  800a26:	83 e8 41             	sub    $0x41,%eax
  800a29:	3c 19                	cmp    $0x19,%al
  800a2b:	77 12                	ja     800a3f <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a2d:	0f be 02             	movsbl (%edx),%eax
  800a30:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a33:	39 c8                	cmp    %ecx,%eax
  800a35:	7d 08                	jge    800a3f <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a37:	42                   	inc    %edx
  800a38:	0f af d9             	imul   %ecx,%ebx
  800a3b:	01 c3                	add    %eax,%ebx
  800a3d:	eb c3                	jmp    800a02 <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a3f:	85 f6                	test   %esi,%esi
  800a41:	74 02                	je     800a45 <strtol+0xbc>
		*endptr = (char *) s;
  800a43:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a45:	89 d8                	mov    %ebx,%eax
  800a47:	85 ff                	test   %edi,%edi
  800a49:	74 02                	je     800a4d <strtol+0xc4>
  800a4b:	f7 d8                	neg    %eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    
	...

00800a54 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
  800a65:	89 f8                	mov    %edi,%eax
  800a67:	89 fb                	mov    %edi,%ebx
  800a69:	89 fe                	mov    %edi,%esi
  800a6b:	55                   	push   %ebp
  800a6c:	9c                   	pushf  
  800a6d:	56                   	push   %esi
  800a6e:	54                   	push   %esp
  800a6f:	5d                   	pop    %ebp
  800a70:	8d 35 78 0a 80 00    	lea    0x800a78,%esi
  800a76:	0f 34                	sysenter 
  800a78:	83 c4 04             	add    $0x4,%esp
  800a7b:	9d                   	popf   
  800a7c:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a92:	89 fa                	mov    %edi,%edx
  800a94:	89 f9                	mov    %edi,%ecx
  800a96:	89 fb                	mov    %edi,%ebx
  800a98:	89 fe                	mov    %edi,%esi
  800a9a:	55                   	push   %ebp
  800a9b:	9c                   	pushf  
  800a9c:	56                   	push   %esi
  800a9d:	54                   	push   %esp
  800a9e:	5d                   	pop    %ebp
  800a9f:	8d 35 a7 0a 80 00    	lea    0x800aa7,%esi
  800aa5:	0f 34                	sysenter 
  800aa7:	83 c4 04             	add    $0x4,%esp
  800aaa:	9d                   	popf   
  800aab:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 0c             	sub    $0xc,%esp
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac7:	89 f9                	mov    %edi,%ecx
  800ac9:	89 fb                	mov    %edi,%ebx
  800acb:	89 fe                	mov    %edi,%esi
  800acd:	55                   	push   %ebp
  800ace:	9c                   	pushf  
  800acf:	56                   	push   %esi
  800ad0:	54                   	push   %esp
  800ad1:	5d                   	pop    %ebp
  800ad2:	8d 35 da 0a 80 00    	lea    0x800ada,%esi
  800ad8:	0f 34                	sysenter 
  800ada:	83 c4 04             	add    $0x4,%esp
  800add:	9d                   	popf   
  800ade:	5d                   	pop    %ebp
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	7e 17                	jle    800afa <sys_env_destroy+0x49>
  800ae3:	83 ec 0c             	sub    $0xc,%esp
  800ae6:	50                   	push   %eax
  800ae7:	6a 03                	push   $0x3
  800ae9:	68 1c 14 80 00       	push   $0x80141c
  800aee:	6a 4c                	push   $0x4c
  800af0:	68 39 14 80 00       	push   $0x801439
  800af5:	e8 0e f6 ff ff       	call   800108 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afa:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b12:	89 fa                	mov    %edi,%edx
  800b14:	89 f9                	mov    %edi,%ecx
  800b16:	89 fb                	mov    %edi,%ebx
  800b18:	89 fe                	mov    %edi,%esi
  800b1a:	55                   	push   %ebp
  800b1b:	9c                   	pushf  
  800b1c:	56                   	push   %esi
  800b1d:	54                   	push   %esp
  800b1e:	5d                   	pop    %ebp
  800b1f:	8d 35 27 0b 80 00    	lea    0x800b27,%esi
  800b25:	0f 34                	sysenter 
  800b27:	83 c4 04             	add    $0x4,%esp
  800b2a:	9d                   	popf   
  800b2b:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    

00800b31 <sys_dump_env>:

int
sys_dump_env(void)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b41:	89 fa                	mov    %edi,%edx
  800b43:	89 f9                	mov    %edi,%ecx
  800b45:	89 fb                	mov    %edi,%ebx
  800b47:	89 fe                	mov    %edi,%esi
  800b49:	55                   	push   %ebp
  800b4a:	9c                   	pushf  
  800b4b:	56                   	push   %esi
  800b4c:	54                   	push   %esp
  800b4d:	5d                   	pop    %ebp
  800b4e:	8d 35 56 0b 80 00    	lea    0x800b56,%esi
  800b54:	0f 34                	sysenter 
  800b56:	83 c4 04             	add    $0x4,%esp
  800b59:	9d                   	popf   
  800b5a:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <sys_yield>:

void
sys_yield(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b70:	89 fa                	mov    %edi,%edx
  800b72:	89 f9                	mov    %edi,%ecx
  800b74:	89 fb                	mov    %edi,%ebx
  800b76:	89 fe                	mov    %edi,%esi
  800b78:	55                   	push   %ebp
  800b79:	9c                   	pushf  
  800b7a:	56                   	push   %esi
  800b7b:	54                   	push   %esp
  800b7c:	5d                   	pop    %ebp
  800b7d:	8d 35 85 0b 80 00    	lea    0x800b85,%esi
  800b83:	0f 34                	sysenter 
  800b85:	83 c4 04             	add    $0x4,%esp
  800b88:	9d                   	popf   
  800b89:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	83 ec 0c             	sub    $0xc,%esp
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba1:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bab:	89 fe                	mov    %edi,%esi
  800bad:	55                   	push   %ebp
  800bae:	9c                   	pushf  
  800baf:	56                   	push   %esi
  800bb0:	54                   	push   %esp
  800bb1:	5d                   	pop    %ebp
  800bb2:	8d 35 ba 0b 80 00    	lea    0x800bba,%esi
  800bb8:	0f 34                	sysenter 
  800bba:	83 c4 04             	add    $0x4,%esp
  800bbd:	9d                   	popf   
  800bbe:	5d                   	pop    %ebp
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_page_alloc+0x4b>
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 05                	push   $0x5
  800bc9:	68 1c 14 80 00       	push   $0x80141c
  800bce:	6a 4c                	push   $0x4c
  800bd0:	68 39 14 80 00       	push   $0x801439
  800bd5:	e8 2e f5 ff ff       	call   800108 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bda:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfa:	b8 06 00 00 00       	mov    $0x6,%eax
  800bff:	55                   	push   %ebp
  800c00:	9c                   	pushf  
  800c01:	56                   	push   %esi
  800c02:	54                   	push   %esp
  800c03:	5d                   	pop    %ebp
  800c04:	8d 35 0c 0c 80 00    	lea    0x800c0c,%esi
  800c0a:	0f 34                	sysenter 
  800c0c:	83 c4 04             	add    $0x4,%esp
  800c0f:	9d                   	popf   
  800c10:	5d                   	pop    %ebp
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 17                	jle    800c2c <sys_page_map+0x4a>
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 06                	push   $0x6
  800c1b:	68 1c 14 80 00       	push   $0x80141c
  800c20:	6a 4c                	push   $0x4c
  800c22:	68 39 14 80 00       	push   $0x801439
  800c27:	e8 dc f4 ff ff       	call   800108 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800c2c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	b8 07 00 00 00       	mov    $0x7,%eax
  800c48:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4d:	89 fb                	mov    %edi,%ebx
  800c4f:	89 fe                	mov    %edi,%esi
  800c51:	55                   	push   %ebp
  800c52:	9c                   	pushf  
  800c53:	56                   	push   %esi
  800c54:	54                   	push   %esp
  800c55:	5d                   	pop    %ebp
  800c56:	8d 35 5e 0c 80 00    	lea    0x800c5e,%esi
  800c5c:	0f 34                	sysenter 
  800c5e:	83 c4 04             	add    $0x4,%esp
  800c61:	9d                   	popf   
  800c62:	5d                   	pop    %ebp
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_page_unmap+0x4a>
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 07                	push   $0x7
  800c6d:	68 1c 14 80 00       	push   $0x80141c
  800c72:	6a 4c                	push   $0x4c
  800c74:	68 39 14 80 00       	push   $0x801439
  800c79:	e8 8a f4 ff ff       	call   800108 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9f:	89 fb                	mov    %edi,%ebx
  800ca1:	89 fe                	mov    %edi,%esi
  800ca3:	55                   	push   %ebp
  800ca4:	9c                   	pushf  
  800ca5:	56                   	push   %esi
  800ca6:	54                   	push   %esp
  800ca7:	5d                   	pop    %ebp
  800ca8:	8d 35 b0 0c 80 00    	lea    0x800cb0,%esi
  800cae:	0f 34                	sysenter 
  800cb0:	83 c4 04             	add    $0x4,%esp
  800cb3:	9d                   	popf   
  800cb4:	5d                   	pop    %ebp
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7e 17                	jle    800cd0 <sys_env_set_status+0x4a>
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 09                	push   $0x9
  800cbf:	68 1c 14 80 00       	push   $0x80141c
  800cc4:	6a 4c                	push   $0x4c
  800cc6:	68 39 14 80 00       	push   $0x801439
  800ccb:	e8 38 f4 ff ff       	call   800108 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	c9                   	leave  
  800cd7:	c3                   	ret    

00800cd8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cec:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf1:	89 fb                	mov    %edi,%ebx
  800cf3:	89 fe                	mov    %edi,%esi
  800cf5:	55                   	push   %ebp
  800cf6:	9c                   	pushf  
  800cf7:	56                   	push   %esi
  800cf8:	54                   	push   %esp
  800cf9:	5d                   	pop    %ebp
  800cfa:	8d 35 02 0d 80 00    	lea    0x800d02,%esi
  800d00:	0f 34                	sysenter 
  800d02:	83 c4 04             	add    $0x4,%esp
  800d05:	9d                   	popf   
  800d06:	5d                   	pop    %ebp
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_env_set_trapframe+0x4a>
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0a                	push   $0xa
  800d11:	68 1c 14 80 00       	push   $0x80141c
  800d16:	6a 4c                	push   $0x4c
  800d18:	68 39 14 80 00       	push   $0x801439
  800d1d:	e8 e6 f3 ff ff       	call   800108 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	c9                   	leave  
  800d29:	c3                   	ret    

00800d2a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d43:	89 fb                	mov    %edi,%ebx
  800d45:	89 fe                	mov    %edi,%esi
  800d47:	55                   	push   %ebp
  800d48:	9c                   	pushf  
  800d49:	56                   	push   %esi
  800d4a:	54                   	push   %esp
  800d4b:	5d                   	pop    %ebp
  800d4c:	8d 35 54 0d 80 00    	lea    0x800d54,%esi
  800d52:	0f 34                	sysenter 
  800d54:	83 c4 04             	add    $0x4,%esp
  800d57:	9d                   	popf   
  800d58:	5d                   	pop    %ebp
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_env_set_pgfault_upcall+0x4a>
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 0b                	push   $0xb
  800d63:	68 1c 14 80 00       	push   $0x80141c
  800d68:	6a 4c                	push   $0x4c
  800d6a:	68 39 14 80 00       	push   $0x801439
  800d6f:	e8 94 f3 ff ff       	call   800108 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d93:	be 00 00 00 00       	mov    $0x0,%esi
  800d98:	55                   	push   %ebp
  800d99:	9c                   	pushf  
  800d9a:	56                   	push   %esi
  800d9b:	54                   	push   %esp
  800d9c:	5d                   	pop    %ebp
  800d9d:	8d 35 a5 0d 80 00    	lea    0x800da5,%esi
  800da3:	0f 34                	sysenter 
  800da5:	83 c4 04             	add    $0x4,%esp
  800da8:	9d                   	popf   
  800da9:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    

00800daf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	89 fb                	mov    %edi,%ebx
  800dc9:	89 fe                	mov    %edi,%esi
  800dcb:	55                   	push   %ebp
  800dcc:	9c                   	pushf  
  800dcd:	56                   	push   %esi
  800dce:	54                   	push   %esp
  800dcf:	5d                   	pop    %ebp
  800dd0:	8d 35 d8 0d 80 00    	lea    0x800dd8,%esi
  800dd6:	0f 34                	sysenter 
  800dd8:	83 c4 04             	add    $0x4,%esp
  800ddb:	9d                   	popf   
  800ddc:	5d                   	pop    %ebp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_ipc_recv+0x49>
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 0e                	push   $0xe
  800de7:	68 1c 14 80 00       	push   $0x80141c
  800dec:	6a 4c                	push   $0x4c
  800dee:	68 39 14 80 00       	push   $0x801439
  800df3:	e8 10 f3 ff ff       	call   800108 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == NULL) {
  800e06:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800e0d:	75 2a                	jne    800e39 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
        //cprintf("i'm in set pgfault_handler,before alloc\n");
        if(sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W)) {//maybe not PTE_USER
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	6a 07                	push   $0x7
  800e14:	68 00 f0 bf ee       	push   $0xeebff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 6f fd ff ff       	call   800b8f <sys_page_alloc>
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	75 1a                	jne    800e41 <set_pgfault_handler+0x41>
            return;
        }
        //cprintf("i'm in set pgfault_handler,after alloc\n");
        sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	68 44 0e 80 00       	push   $0x800e44
  800e2f:	6a 00                	push   $0x0
  800e31:	e8 f4 fe ff ff       	call   800d2a <sys_env_set_pgfault_upcall>
  800e36:	83 c4 10             	add    $0x10,%esp
        //cprintf("here in set pgfault handler\n");
		//panic("set_pgfault_handler not implemented");
	}
	// Save handler pointer for assembly to call.
    //cprintf("handler %x;pgfault_handler address %x,upcall address %x,upcall points %x\n",handler,&_pgfault_handler,&_pgfault_upcall,_pgfault_upcall);
	_pgfault_handler = handler;
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	a3 0c 20 80 00       	mov    %eax,0x80200c
    //cprintf("here\n");
    //it should be ok
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    
	...

00800e44 <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e44:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e45:	a1 0c 20 80 00       	mov    0x80200c,%eax
    //xchg %bx, %bx
	call *%eax
  800e4a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e4c:	83 c4 04             	add    $0x4,%esp
	
	// Now the C page fault handler has returned and you must return
	// to the trap time state.
	// Push trap-time %eip onto the trap-time stack.
	//
	// Explanation:
	//   We must prepare the trap-time stack for our eventual return to
	//   re-execute the instruction that faulted.
	//   Unfortunately, we can't return directly from the exception stack:why?security?
	//   We can't call 'jmp', since that requires that we load the address
	//   into a register, and all registers must have their trap-time
	//   values after the return.
	//   We can't call 'ret' from the exception stack either, since if we
	//   did, %esp would have the wrong value.
	//   So instead, we push the trap-time %eip onto the *trap-time* stack!
	//   Below we'll switch to that stack and call 'ret', which will
	//   restore %eip to its pre-fault value.
	//
	//   In the case of a recursive fault on the exception stack,
	//   note that the word we're pushing now will fit in the
	//   blank word that the kernel reserved for us.
	//
	// Hints:
	//   What registers are available for intermediate calculations?
	//
	// LAB 4: Your code here.
    //skip faultva and errcode
    // esp point to the place where %edi stores
    //xchg %bx, %bx
    addl $8, %esp//point to the head of the frame
  800e4f:	83 c4 08             	add    $0x8,%esp
/*    //it's wrong
    movl %esp,%eax//old esp is stored in the upper 40byte of the current esp
    addl $40,%eax //eax point to the old esp
    //xchg %bx, %bx
    movl %eax,%edx
    addl $4,%edx //then edx points to the retaddr
    movl %edx,(%eax)//set the esp in the stack to the 
*/   
    movl 32(%esp),%edx //edx is the old eip 
  800e52:	8b 54 24 20          	mov    0x20(%esp),%edx
    movl 40(%esp),%eax //eax is the old esp
  800e56:	8b 44 24 28          	mov    0x28(%esp),%eax
    subl $4, %eax // then eax point to the place where the return address will be store
  800e5a:	83 e8 04             	sub    $0x4,%eax
    movl %edx,(%eax)//the old eip is stored in the return address place.maybe this will cause recursive copyonwrite pagefault
  800e5d:	89 10                	mov    %edx,(%eax)
    movl %eax,40(%esp)//then the value of the esp place in the utf points to the old eip
  800e5f:	89 44 24 28          	mov    %eax,0x28(%esp)
    //because the register will be restored, so don't care the eax and edx
	// Restore the trap-time registers.
	// LAB 4: Your code here.
    popal
  800e63:	61                   	popa   
	// Restore eflags from the stack.
	// LAB 4: Your code here.
    addl $4,%esp
  800e64:	83 c4 04             	add    $0x4,%esp
    popfl
  800e67:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    //xchg %bx,%bx
    popl %esp//then esp points to the retaddr
  800e68:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    //xchg %bx, %bx
    ret
  800e69:	c3                   	ret    
	...

00800e6c <__udivdi3>:
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	83 ec 20             	sub    $0x20,%esp
  800e74:	8b 55 14             	mov    0x14(%ebp),%edx
  800e77:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e80:	85 d2                	test   %edx,%edx
  800e82:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800e85:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800e8c:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800e93:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e96:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e99:	89 fe                	mov    %edi,%esi
  800e9b:	75 5b                	jne    800ef8 <__udivdi3+0x8c>
  800e9d:	39 f8                	cmp    %edi,%eax
  800e9f:	76 2b                	jbe    800ecc <__udivdi3+0x60>
  800ea1:	89 fa                	mov    %edi,%edx
  800ea3:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800ea6:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800ea9:	89 c7                	mov    %eax,%edi
  800eab:	90                   	nop    
  800eac:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800eb3:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800eb6:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800eb9:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800ebc:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800ebf:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800ec2:	83 c4 20             	add    $0x20,%esp
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    
  800ec9:	8d 76 00             	lea    0x0(%esi),%esi
  800ecc:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	75 0e                	jne    800ee1 <__udivdi3+0x75>
  800ed3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed8:	31 c9                	xor    %ecx,%ecx
  800eda:	31 d2                	xor    %edx,%edx
  800edc:	f7 f1                	div    %ecx
  800ede:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800ee8:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800eeb:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800eee:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800ef1:	89 c7                	mov    %eax,%edi
  800ef3:	eb be                	jmp    800eb3 <__udivdi3+0x47>
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800efb:	76 07                	jbe    800f04 <__udivdi3+0x98>
  800efd:	31 ff                	xor    %edi,%edi
  800eff:	eb ab                	jmp    800eac <__udivdi3+0x40>
  800f01:	8d 76 00             	lea    0x0(%esi),%esi
  800f04:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800f08:	89 c7                	mov    %eax,%edi
  800f0a:	83 f7 1f             	xor    $0x1f,%edi
  800f0d:	75 19                	jne    800f28 <__udivdi3+0xbc>
  800f0f:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800f12:	77 0a                	ja     800f1e <__udivdi3+0xb2>
  800f14:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f17:	31 ff                	xor    %edi,%edi
  800f19:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800f1c:	72 8e                	jb     800eac <__udivdi3+0x40>
  800f1e:	bf 01 00 00 00       	mov    $0x1,%edi
  800f23:	eb 87                	jmp    800eac <__udivdi3+0x40>
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	b8 20 00 00 00       	mov    $0x20,%eax
  800f2d:	29 f8                	sub    %edi,%eax
  800f2f:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800f32:	89 f9                	mov    %edi,%ecx
  800f34:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800f37:	d3 e2                	shl    %cl,%edx
  800f39:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800f3c:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800f3f:	d3 e8                	shr    %cl,%eax
  800f41:	09 c2                	or     %eax,%edx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800f48:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800f4b:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800f4e:	89 f2                	mov    %esi,%edx
  800f50:	d3 ea                	shr    %cl,%edx
  800f52:	89 f9                	mov    %edi,%ecx
  800f54:	d3 e6                	shl    %cl,%esi
  800f56:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800f59:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800f5c:	d3 e8                	shr    %cl,%eax
  800f5e:	09 c6                	or     %eax,%esi
  800f60:	89 f9                	mov    %edi,%ecx
  800f62:	89 f0                	mov    %esi,%eax
  800f64:	f7 75 ec             	divl   0xffffffec(%ebp)
  800f67:	89 d6                	mov    %edx,%esi
  800f69:	89 c7                	mov    %eax,%edi
  800f6b:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800f6e:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800f71:	f7 e7                	mul    %edi
  800f73:	39 f2                	cmp    %esi,%edx
  800f75:	77 0f                	ja     800f86 <__udivdi3+0x11a>
  800f77:	0f 85 2f ff ff ff    	jne    800eac <__udivdi3+0x40>
  800f7d:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800f80:	0f 86 26 ff ff ff    	jbe    800eac <__udivdi3+0x40>
  800f86:	4f                   	dec    %edi
  800f87:	e9 20 ff ff ff       	jmp    800eac <__udivdi3+0x40>

00800f8c <__umoddi3>:
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	83 ec 30             	sub    $0x30,%esp
  800f94:	8b 55 14             	mov    0x14(%ebp),%edx
  800f97:	8b 75 08             	mov    0x8(%ebp),%esi
  800f9a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f9d:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa0:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800fa3:	85 d2                	test   %edx,%edx
  800fa5:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800fac:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800fb3:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800fb6:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800fb9:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800fbc:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800fbf:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800fc2:	75 68                	jne    80102c <__umoddi3+0xa0>
  800fc4:	39 f8                	cmp    %edi,%eax
  800fc6:	76 3c                	jbe    801004 <__umoddi3+0x78>
  800fc8:	89 f0                	mov    %esi,%eax
  800fca:	89 fa                	mov    %edi,%edx
  800fcc:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800fcf:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800fd2:	85 c9                	test   %ecx,%ecx
  800fd4:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800fd7:	74 1b                	je     800ff4 <__umoddi3+0x68>
  800fd9:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fdc:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800fdf:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800fe6:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800fe9:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800fec:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800fef:	89 10                	mov    %edx,(%eax)
  800ff1:	89 48 04             	mov    %ecx,0x4(%eax)
  800ff4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800ff7:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800ffa:	83 c4 30             	add    $0x30,%esp
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	c9                   	leave  
  801000:	c3                   	ret    
  801001:	8d 76 00             	lea    0x0(%esi),%esi
  801004:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  801007:	85 f6                	test   %esi,%esi
  801009:	75 0d                	jne    801018 <__umoddi3+0x8c>
  80100b:	b8 01 00 00 00       	mov    $0x1,%eax
  801010:	31 d2                	xor    %edx,%edx
  801012:	f7 75 cc             	divl   0xffffffcc(%ebp)
  801015:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  801018:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  80101b:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80101e:	f7 75 cc             	divl   0xffffffcc(%ebp)
  801021:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801024:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801027:	f7 75 cc             	divl   0xffffffcc(%ebp)
  80102a:	eb a3                	jmp    800fcf <__umoddi3+0x43>
  80102c:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80102f:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  801032:	76 14                	jbe    801048 <__umoddi3+0xbc>
  801034:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  801037:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80103a:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80103d:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801040:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  801043:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  801046:	eb ac                	jmp    800ff4 <__umoddi3+0x68>
  801048:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  80104c:	89 c6                	mov    %eax,%esi
  80104e:	83 f6 1f             	xor    $0x1f,%esi
  801051:	75 4d                	jne    8010a0 <__umoddi3+0x114>
  801053:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801056:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  801059:	77 08                	ja     801063 <__umoddi3+0xd7>
  80105b:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  80105e:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  801061:	72 12                	jb     801075 <__umoddi3+0xe9>
  801063:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801066:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801069:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  80106c:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80106f:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801072:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801075:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801078:	85 d2                	test   %edx,%edx
  80107a:	0f 84 74 ff ff ff    	je     800ff4 <__umoddi3+0x68>
  801080:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801083:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801086:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801089:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80108c:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  80108f:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801092:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801095:	89 01                	mov    %eax,(%ecx)
  801097:	89 51 04             	mov    %edx,0x4(%ecx)
  80109a:	e9 55 ff ff ff       	jmp    800ff4 <__umoddi3+0x68>
  80109f:	90                   	nop    
  8010a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8010a5:	29 f0                	sub    %esi,%eax
  8010a7:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8010aa:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8010ad:	89 f1                	mov    %esi,%ecx
  8010af:	d3 e2                	shl    %cl,%edx
  8010b1:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8010b4:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8010b7:	d3 e8                	shr    %cl,%eax
  8010b9:	09 c2                	or     %eax,%edx
  8010bb:	89 f1                	mov    %esi,%ecx
  8010bd:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  8010c0:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8010c3:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8010c6:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8010c9:	d3 ea                	shr    %cl,%edx
  8010cb:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  8010ce:	89 f1                	mov    %esi,%ecx
  8010d0:	d3 e7                	shl    %cl,%edi
  8010d2:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8010d5:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8010d8:	d3 e8                	shr    %cl,%eax
  8010da:	09 c7                	or     %eax,%edi
  8010dc:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  8010df:	89 f8                	mov    %edi,%eax
  8010e1:	89 f1                	mov    %esi,%ecx
  8010e3:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8010e6:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8010e9:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  8010ec:	f7 65 cc             	mull   0xffffffcc(%ebp)
  8010ef:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  8010f2:	89 c7                	mov    %eax,%edi
  8010f4:	77 3f                	ja     801135 <__umoddi3+0x1a9>
  8010f6:	74 38                	je     801130 <__umoddi3+0x1a4>
  8010f8:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	0f 84 f1 fe ff ff    	je     800ff4 <__umoddi3+0x68>
  801103:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  801106:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801109:	29 f8                	sub    %edi,%eax
  80110b:	19 d1                	sbb    %edx,%ecx
  80110d:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  801110:	89 ca                	mov    %ecx,%edx
  801112:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801115:	d3 e2                	shl    %cl,%edx
  801117:	89 f1                	mov    %esi,%ecx
  801119:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  80111c:	d3 e8                	shr    %cl,%eax
  80111e:	09 c2                	or     %eax,%edx
  801120:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  801123:	d3 e8                	shr    %cl,%eax
  801125:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  801128:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80112b:	e9 b6 fe ff ff       	jmp    800fe6 <__umoddi3+0x5a>
  801130:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  801133:	76 c3                	jbe    8010f8 <__umoddi3+0x16c>
  801135:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  801138:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80113b:	eb bb                	jmp    8010f8 <__umoddi3+0x16c>
  80113d:	90                   	nop    
  80113e:	90                   	nop    
  80113f:	90                   	nop    
