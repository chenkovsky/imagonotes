
obj/user/yield：     文件格式 elf32-i386

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
  80002c:	e8 67 00 00 00       	call   800098 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", env->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 4c             	mov    0x4c(%eax),%eax
  800043:	50                   	push   %eax
  800044:	68 c0 10 80 00       	push   $0x8010c0
  800049:	e8 2e 01 00 00       	call   80017c <cprintf>
	for (i = 0; i < 5; i++) {
  80004e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800053:	83 c4 10             	add    $0x10,%esp
		sys_yield();
  800056:	e8 89 0a 00 00       	call   800ae4 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	53                   	push   %ebx
  80005f:	a1 04 20 80 00       	mov    0x802004,%eax
  800064:	8b 40 4c             	mov    0x4c(%eax),%eax
  800067:	50                   	push   %eax
  800068:	68 e0 10 80 00       	push   $0x8010e0
  80006d:	e8 0a 01 00 00       	call   80017c <cprintf>
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	43                   	inc    %ebx
  800076:	83 fb 04             	cmp    $0x4,%ebx
  800079:	7e db                	jle    800056 <umain+0x22>
			env->env_id, i);
	}
	cprintf("All done in environment %08x.\n", env->env_id);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	a1 04 20 80 00       	mov    0x802004,%eax
  800083:	8b 40 4c             	mov    0x4c(%eax),%eax
  800086:	50                   	push   %eax
  800087:	68 0c 11 80 00       	push   $0x80110c
  80008c:	e8 eb 00 00 00       	call   80017c <cprintf>
}
  800091:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	56                   	push   %esi
  80009c:	53                   	push   %ebx
  80009d:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  8000a3:	e8 de 09 00 00       	call   800a86 <sys_getenvid>
  8000a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ad:	c1 e0 07             	shl    $0x7,%eax
  8000b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b5:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ba:	85 f6                	test   %esi,%esi
  8000bc:	7e 07                	jle    8000c5 <libmain+0x2d>
		binaryname = argv[0];
  8000be:	8b 03                	mov    (%ebx),%eax
  8000c0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	53                   	push   %ebx
  8000c9:	56                   	push   %esi
  8000ca:	e8 65 ff ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  8000cf:	e8 08 00 00 00       	call   8000dc <exit>
}
  8000d4:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    
	...

008000dc <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  8000e2:	6a 00                	push   $0x0
  8000e4:	e8 4c 09 00 00       	call   800a35 <sys_env_destroy>
}
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    
	...

008000ec <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000ff:	40                   	inc    %eax
  800100:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800102:	3d ff 00 00 00       	cmp    $0xff,%eax
  800107:	75 1a                	jne    800123 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	68 ff 00 00 00       	push   $0xff
  800111:	8d 43 08             	lea    0x8(%ebx),%eax
  800114:	50                   	push   %eax
  800115:	e8 be 08 00 00       	call   8009d8 <sys_cputs>
		b->idx = 0;
  80011a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800120:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800123:	ff 43 04             	incl   0x4(%ebx)
}
  800126:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800129:	c9                   	leave  
  80012a:	c3                   	ret    

0080012b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800134:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  80013b:	00 00 00 
	b.cnt = 0;
  80013e:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800145:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800148:	ff 75 0c             	pushl  0xc(%ebp)
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800154:	50                   	push   %eax
  800155:	68 ec 00 80 00       	push   $0x8000ec
  80015a:	e8 83 01 00 00       	call   8002e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015f:	83 c4 08             	add    $0x8,%esp
  800162:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800168:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	e8 64 08 00 00       	call   8009d8 <sys_cputs>

	return b.cnt;
  800174:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800182:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800185:	50                   	push   %eax
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	e8 9d ff ff ff       	call   80012b <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	8b 75 10             	mov    0x10(%ebp),%esi
  80019c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80019f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	8b 45 18             	mov    0x18(%ebp),%eax
  8001a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001aa:	39 d7                	cmp    %edx,%edi
  8001ac:	72 39                	jb     8001e7 <printnum+0x57>
  8001ae:	77 04                	ja     8001b4 <printnum+0x24>
  8001b0:	39 c6                	cmp    %eax,%esi
  8001b2:	72 33                	jb     8001e7 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b4:	83 ec 04             	sub    $0x4,%esp
  8001b7:	ff 75 20             	pushl  0x20(%ebp)
  8001ba:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	ff 75 18             	pushl  0x18(%ebp)
  8001c1:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c9:	52                   	push   %edx
  8001ca:	50                   	push   %eax
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	e8 12 0c 00 00       	call   800de4 <__udivdi3>
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	52                   	push   %edx
  8001d6:	50                   	push   %eax
  8001d7:	ff 75 0c             	pushl  0xc(%ebp)
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	e8 ae ff ff ff       	call   800190 <printnum>
  8001e2:	83 c4 20             	add    $0x20,%esp
  8001e5:	eb 19                	jmp    800200 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e7:	4b                   	dec    %ebx
  8001e8:	85 db                	test   %ebx,%ebx
  8001ea:	7e 14                	jle    800200 <printnum+0x70>
			putch(padc, putdat);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	ff 75 20             	pushl  0x20(%ebp)
  8001f5:	ff 55 08             	call   *0x8(%ebp)
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	4b                   	dec    %ebx
  8001fc:	85 db                	test   %ebx,%ebx
  8001fe:	7f ec                	jg     8001ec <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 0c             	pushl  0xc(%ebp)
  800206:	8b 45 18             	mov    0x18(%ebp),%eax
  800209:	ba 00 00 00 00       	mov    $0x0,%edx
  80020e:	83 ec 04             	sub    $0x4,%esp
  800211:	52                   	push   %edx
  800212:	50                   	push   %eax
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	e8 ea 0c 00 00       	call   800f04 <__umoddi3>
  80021a:	83 c4 14             	add    $0x14,%esp
  80021d:	0f be 80 d5 11 80 00 	movsbl 0x8011d5(%eax),%eax
  800224:	50                   	push   %eax
  800225:	ff 55 08             	call   *0x8(%ebp)
}
  800228:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 18             	sub    $0x18,%esp
  800238:	8b 75 08             	mov    0x8(%ebp),%esi
  80023b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80023e:	8a 45 18             	mov    0x18(%ebp),%al
  800241:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  800244:	53                   	push   %ebx
  800245:	6a 1b                	push   $0x1b
  800247:	ff d6                	call   *%esi
	putch('[', putdat);
  800249:	83 c4 08             	add    $0x8,%esp
  80024c:	53                   	push   %ebx
  80024d:	6a 5b                	push   $0x5b
  80024f:	ff d6                	call   *%esi
	putch('0', putdat);
  800251:	83 c4 08             	add    $0x8,%esp
  800254:	53                   	push   %ebx
  800255:	6a 30                	push   $0x30
  800257:	ff d6                	call   *%esi
	putch(';', putdat);
  800259:	83 c4 08             	add    $0x8,%esp
  80025c:	53                   	push   %ebx
  80025d:	6a 3b                	push   $0x3b
  80025f:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800261:	83 c4 0c             	add    $0xc,%esp
  800264:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800268:	50                   	push   %eax
  800269:	ff 75 14             	pushl  0x14(%ebp)
  80026c:	6a 0a                	push   $0xa
  80026e:	8b 45 10             	mov    0x10(%ebp),%eax
  800271:	99                   	cltd   
  800272:	52                   	push   %edx
  800273:	50                   	push   %eax
  800274:	53                   	push   %ebx
  800275:	56                   	push   %esi
  800276:	e8 15 ff ff ff       	call   800190 <printnum>
	putch('m', putdat);
  80027b:	83 c4 18             	add    $0x18,%esp
  80027e:	53                   	push   %ebx
  80027f:	6a 6d                	push   $0x6d
  800281:	ff d6                	call   *%esi

}
  800283:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800293:	83 f8 01             	cmp    $0x1,%eax
  800296:	7e 0f                	jle    8002a7 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800298:	8b 01                	mov    (%ecx),%eax
  80029a:	83 c0 08             	add    $0x8,%eax
  80029d:	89 01                	mov    %eax,(%ecx)
  80029f:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002a2:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002a5:	eb 0f                	jmp    8002b6 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8002a7:	8b 01                	mov    (%ecx),%eax
  8002a9:	83 c0 04             	add    $0x4,%eax
  8002ac:	89 01                	mov    %eax,(%ecx)
  8002ae:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002c1:	83 f8 01             	cmp    $0x1,%eax
  8002c4:	7e 0f                	jle    8002d5 <getint+0x1d>
		return va_arg(*ap, long long);
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	83 c0 08             	add    $0x8,%eax
  8002cb:	89 02                	mov    %eax,(%edx)
  8002cd:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002d0:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002d3:	eb 0b                	jmp    8002e0 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	83 c0 04             	add    $0x4,%eax
  8002da:	89 02                	mov    %eax,(%edx)
  8002dc:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002df:	99                   	cltd   
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 1c             	sub    $0x1c,%esp
  8002eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ee:	0f b6 13             	movzbl (%ebx),%edx
  8002f1:	43                   	inc    %ebx
  8002f2:	83 fa 25             	cmp    $0x25,%edx
  8002f5:	74 1e                	je     800315 <vprintfmt+0x33>
			if (ch == '\0')
  8002f7:	85 d2                	test   %edx,%edx
  8002f9:	0f 84 dc 02 00 00    	je     8005db <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	ff 75 0c             	pushl  0xc(%ebp)
  800305:	52                   	push   %edx
  800306:	ff 55 08             	call   *0x8(%ebp)
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	0f b6 13             	movzbl (%ebx),%edx
  80030f:	43                   	inc    %ebx
  800310:	83 fa 25             	cmp    $0x25,%edx
  800313:	75 e2                	jne    8002f7 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800315:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  800319:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  800320:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800325:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  80032a:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  800331:	0f b6 13             	movzbl (%ebx),%edx
  800334:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  800337:	43                   	inc    %ebx
  800338:	83 f8 55             	cmp    $0x55,%eax
  80033b:	0f 87 75 02 00 00    	ja     8005b6 <vprintfmt+0x2d4>
  800341:	ff 24 85 24 12 80 00 	jmp    *0x801224(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800348:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  80034c:	eb e3                	jmp    800331 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800352:	eb dd                	jmp    800331 <vprintfmt+0x4f>

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
  800354:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800359:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80035c:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800360:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800363:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800366:	83 f8 09             	cmp    $0x9,%eax
  800369:	77 27                	ja     800392 <vprintfmt+0xb0>
  80036b:	43                   	inc    %ebx
  80036c:	eb eb                	jmp    800359 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80036e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800378:	eb 18                	jmp    800392 <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  80037a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80037e:	79 b1                	jns    800331 <vprintfmt+0x4f>
				width = 0;
  800380:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  800387:	eb a8                	jmp    800331 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800389:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800390:	eb 9f                	jmp    800331 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  800392:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800396:	79 99                	jns    800331 <vprintfmt+0x4f>
				width = precision, precision = -1;
  800398:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80039b:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003a0:	eb 8f                	jmp    800331 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a2:	41                   	inc    %ecx
			goto reswitch;
  8003a3:	eb 8c                	jmp    800331 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	ff 75 0c             	pushl  0xc(%ebp)
  8003ab:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	ff 70 fc             	pushl  0xfffffffc(%eax)
  8003b5:	e9 c4 01 00 00       	jmp    80057e <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  8003ba:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  8003c4:	85 c0                	test   %eax,%eax
  8003c6:	79 02                	jns    8003ca <vprintfmt+0xe8>
				err = -err;
  8003c8:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8003ca:	83 f8 08             	cmp    $0x8,%eax
  8003cd:	7f 0b                	jg     8003da <vprintfmt+0xf8>
  8003cf:	8b 3c 85 00 12 80 00 	mov    0x801200(,%eax,4),%edi
  8003d6:	85 ff                	test   %edi,%edi
  8003d8:	75 08                	jne    8003e2 <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  8003da:	50                   	push   %eax
  8003db:	68 e6 11 80 00       	push   $0x8011e6
  8003e0:	eb 06                	jmp    8003e8 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8003e2:	57                   	push   %edi
  8003e3:	68 ef 11 80 00       	push   $0x8011ef
  8003e8:	ff 75 0c             	pushl  0xc(%ebp)
  8003eb:	ff 75 08             	pushl  0x8(%ebp)
  8003ee:	e8 f0 01 00 00       	call   8005e3 <printfmt>
  8003f3:	e9 89 01 00 00       	jmp    800581 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f8:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  800402:	85 ff                	test   %edi,%edi
  800404:	75 05                	jne    80040b <vprintfmt+0x129>
				p = "(null)";
  800406:	bf f2 11 80 00       	mov    $0x8011f2,%edi
			if (width > 0 && padc != '-')
  80040b:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80040f:	7e 3b                	jle    80044c <vprintfmt+0x16a>
  800411:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  800415:	74 35                	je     80044c <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	56                   	push   %esi
  80041b:	57                   	push   %edi
  80041c:	e8 74 02 00 00       	call   800695 <strnlen>
  800421:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80042b:	7e 1f                	jle    80044c <vprintfmt+0x16a>
  80042d:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800431:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	ff 75 0c             	pushl  0xc(%ebp)
  80043a:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  80043d:	ff 55 08             	call   *0x8(%ebp)
  800440:	83 c4 10             	add    $0x10,%esp
  800443:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800446:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80044a:	7f e8                	jg     800434 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044c:	0f be 17             	movsbl (%edi),%edx
  80044f:	47                   	inc    %edi
  800450:	85 d2                	test   %edx,%edx
  800452:	74 3e                	je     800492 <vprintfmt+0x1b0>
  800454:	85 f6                	test   %esi,%esi
  800456:	78 03                	js     80045b <vprintfmt+0x179>
  800458:	4e                   	dec    %esi
  800459:	78 37                	js     800492 <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  80045b:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  80045f:	74 12                	je     800473 <vprintfmt+0x191>
  800461:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800464:	83 f8 5e             	cmp    $0x5e,%eax
  800467:	76 0a                	jbe    800473 <vprintfmt+0x191>
					putch('?', putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	ff 75 0c             	pushl  0xc(%ebp)
  80046f:	6a 3f                	push   $0x3f
  800471:	eb 07                	jmp    80047a <vprintfmt+0x198>
				else
					putch(ch, putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 0c             	pushl  0xc(%ebp)
  800479:	52                   	push   %edx
  80047a:	ff 55 08             	call   *0x8(%ebp)
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800483:	0f be 17             	movsbl (%edi),%edx
  800486:	47                   	inc    %edi
  800487:	85 d2                	test   %edx,%edx
  800489:	74 07                	je     800492 <vprintfmt+0x1b0>
  80048b:	85 f6                	test   %esi,%esi
  80048d:	78 cc                	js     80045b <vprintfmt+0x179>
  80048f:	4e                   	dec    %esi
  800490:	79 c9                	jns    80045b <vprintfmt+0x179>
			for (; width > 0; width--)
  800492:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800496:	0f 8e 52 fe ff ff    	jle    8002ee <vprintfmt+0xc>
				putch(' ', putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	6a 20                	push   $0x20
  8004a4:	ff 55 08             	call   *0x8(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004ad:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004b1:	7f e9                	jg     80049c <vprintfmt+0x1ba>
			break;
  8004b3:	e9 36 fe ff ff       	jmp    8002ee <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	51                   	push   %ecx
  8004bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 f3 fd ff ff       	call   8002b8 <getint>
  8004c5:	89 c6                	mov    %eax,%esi
  8004c7:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	79 15                	jns    8004e5 <vprintfmt+0x203>
				putch('-', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	6a 2d                	push   $0x2d
  8004d8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004db:	f7 de                	neg    %esi
  8004dd:	83 d7 00             	adc    $0x0,%edi
  8004e0:	f7 df                	neg    %edi
  8004e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004e5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004ea:	eb 70                	jmp    80055c <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	51                   	push   %ecx
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f3:	50                   	push   %eax
  8004f4:	e8 91 fd ff ff       	call   80028a <getuint>
  8004f9:	89 c6                	mov    %eax,%esi
  8004fb:	89 d7                	mov    %edx,%edi
			base = 10;
  8004fd:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800502:	eb 55                	jmp    800559 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	51                   	push   %ecx
  800508:	8d 45 14             	lea    0x14(%ebp),%eax
  80050b:	50                   	push   %eax
  80050c:	e8 79 fd ff ff       	call   80028a <getuint>
  800511:	89 c6                	mov    %eax,%esi
  800513:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  800515:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  80051a:	eb 3d                	jmp    800559 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 0c             	pushl  0xc(%ebp)
  800522:	6a 30                	push   $0x30
  800524:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800527:	83 c4 08             	add    $0x8,%esp
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	6a 78                	push   $0x78
  80052f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800532:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  80053c:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  800541:	eb 11                	jmp    800554 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	51                   	push   %ecx
  800547:	8d 45 14             	lea    0x14(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	e8 3a fd ff ff       	call   80028a <getuint>
  800550:	89 c6                	mov    %eax,%esi
  800552:	89 d7                	mov    %edx,%edi
			base = 16;
  800554:	ba 10 00 00 00       	mov    $0x10,%edx
  800559:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  80055c:	83 ec 04             	sub    $0x4,%esp
  80055f:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800563:	50                   	push   %eax
  800564:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800567:	52                   	push   %edx
  800568:	57                   	push   %edi
  800569:	56                   	push   %esi
  80056a:	ff 75 0c             	pushl  0xc(%ebp)
  80056d:	ff 75 08             	pushl  0x8(%ebp)
  800570:	e8 1b fc ff ff       	call   800190 <printnum>
			break;
  800575:	eb 37                	jmp    8005ae <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	ff 75 0c             	pushl  0xc(%ebp)
  80057d:	52                   	push   %edx
  80057e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	e9 65 fd ff ff       	jmp    8002ee <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	51                   	push   %ecx
  80058d:	8d 45 14             	lea    0x14(%ebp),%eax
  800590:	50                   	push   %eax
  800591:	e8 f4 fc ff ff       	call   80028a <getuint>
  800596:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800598:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8005a2:	56                   	push   %esi
  8005a3:	ff 75 0c             	pushl  0xc(%ebp)
  8005a6:	ff 75 08             	pushl  0x8(%ebp)
  8005a9:	e8 82 fc ff ff       	call   800230 <printcolor>
			break;
  8005ae:	83 c4 20             	add    $0x20,%esp
  8005b1:	e9 38 fd ff ff       	jmp    8002ee <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	ff 75 0c             	pushl  0xc(%ebp)
  8005bc:	6a 25                	push   $0x25
  8005be:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005c1:	4b                   	dec    %ebx
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005c9:	0f 84 1f fd ff ff    	je     8002ee <vprintfmt+0xc>
  8005cf:	4b                   	dec    %ebx
  8005d0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005d4:	75 f9                	jne    8005cf <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005d6:	e9 13 fd ff ff       	jmp    8002ee <vprintfmt+0xc>
		}
	}
}
  8005db:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8005de:	5b                   	pop    %ebx
  8005df:	5e                   	pop    %esi
  8005e0:	5f                   	pop    %edi
  8005e1:	c9                   	leave  
  8005e2:	c3                   	ret    

008005e3 <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005e3:	55                   	push   %ebp
  8005e4:	89 e5                	mov    %esp,%ebp
  8005e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005ec:	50                   	push   %eax
  8005ed:	ff 75 10             	pushl  0x10(%ebp)
  8005f0:	ff 75 0c             	pushl  0xc(%ebp)
  8005f3:	ff 75 08             	pushl  0x8(%ebp)
  8005f6:	e8 e7 fc ff ff       	call   8002e2 <vprintfmt>
	va_end(ap);
}
  8005fb:	c9                   	leave  
  8005fc:	c3                   	ret    

008005fd <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8005fd:	55                   	push   %ebp
  8005fe:	89 e5                	mov    %esp,%ebp
  800600:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800603:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800606:	8b 0a                	mov    (%edx),%ecx
  800608:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80060b:	73 07                	jae    800614 <sprintputch+0x17>
		*b->buf++ = ch;
  80060d:	8b 45 08             	mov    0x8(%ebp),%eax
  800610:	88 01                	mov    %al,(%ecx)
  800612:	ff 02                	incl   (%edx)
}
  800614:	c9                   	leave  
  800615:	c3                   	ret    

00800616 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800616:	55                   	push   %ebp
  800617:	89 e5                	mov    %esp,%ebp
  800619:	83 ec 18             	sub    $0x18,%esp
  80061c:	8b 55 08             	mov    0x8(%ebp),%edx
  80061f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800622:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800625:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800629:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80062c:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  800633:	85 d2                	test   %edx,%edx
  800635:	74 04                	je     80063b <vsnprintf+0x25>
  800637:	85 c9                	test   %ecx,%ecx
  800639:	7f 07                	jg     800642 <vsnprintf+0x2c>
		return -E_INVAL;
  80063b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800640:	eb 1d                	jmp    80065f <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  800642:	ff 75 14             	pushl  0x14(%ebp)
  800645:	ff 75 10             	pushl  0x10(%ebp)
  800648:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  80064b:	50                   	push   %eax
  80064c:	68 fd 05 80 00       	push   $0x8005fd
  800651:	e8 8c fc ff ff       	call   8002e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800656:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800659:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80065c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  80065f:	c9                   	leave  
  800660:	c3                   	ret    

00800661 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80066a:	50                   	push   %eax
  80066b:	ff 75 10             	pushl  0x10(%ebp)
  80066e:	ff 75 0c             	pushl  0xc(%ebp)
  800671:	ff 75 08             	pushl  0x8(%ebp)
  800674:	e8 9d ff ff ff       	call   800616 <vsnprintf>
	va_end(ap);

	return rc;
}
  800679:	c9                   	leave  
  80067a:	c3                   	ret    
	...

0080067c <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800682:	b8 00 00 00 00       	mov    $0x0,%eax
  800687:	80 3a 00             	cmpb   $0x0,(%edx)
  80068a:	74 07                	je     800693 <strlen+0x17>
		n++;
  80068c:	40                   	inc    %eax
  80068d:	42                   	inc    %edx
  80068e:	80 3a 00             	cmpb   $0x0,(%edx)
  800691:	75 f9                	jne    80068c <strlen+0x10>
	return n;
}
  800693:	c9                   	leave  
  800694:	c3                   	ret    

00800695 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80069e:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	74 0f                	je     8006b6 <strnlen+0x21>
  8006a7:	80 39 00             	cmpb   $0x0,(%ecx)
  8006aa:	74 0a                	je     8006b6 <strnlen+0x21>
		n++;
  8006ac:	40                   	inc    %eax
  8006ad:	41                   	inc    %ecx
  8006ae:	4a                   	dec    %edx
  8006af:	74 05                	je     8006b6 <strnlen+0x21>
  8006b1:	80 39 00             	cmpb   $0x0,(%ecx)
  8006b4:	75 f6                	jne    8006ac <strnlen+0x17>
	return n;
}
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	53                   	push   %ebx
  8006bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006c2:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006c4:	8a 02                	mov    (%edx),%al
  8006c6:	42                   	inc    %edx
  8006c7:	88 01                	mov    %al,(%ecx)
  8006c9:	41                   	inc    %ecx
  8006ca:	84 c0                	test   %al,%al
  8006cc:	75 f6                	jne    8006c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ce:	89 d8                	mov    %ebx,%eax
  8006d0:	5b                   	pop    %ebx
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	57                   	push   %edi
  8006d7:	56                   	push   %esi
  8006d8:	53                   	push   %ebx
  8006d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006df:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006e2:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8006e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e9:	39 f3                	cmp    %esi,%ebx
  8006eb:	73 10                	jae    8006fd <strncpy+0x2a>
		*dst++ = *src;
  8006ed:	8a 02                	mov    (%edx),%al
  8006ef:	88 01                	mov    %al,(%ecx)
  8006f1:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8006f2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f5:	74 01                	je     8006f8 <strncpy+0x25>
			src++;
  8006f7:	42                   	inc    %edx
  8006f8:	43                   	inc    %ebx
  8006f9:	39 f3                	cmp    %esi,%ebx
  8006fb:	72 f0                	jb     8006ed <strncpy+0x1a>
	}
	return ret;
}
  8006fd:	89 f8                	mov    %edi,%eax
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	56                   	push   %esi
  800708:	53                   	push   %ebx
  800709:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80070c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800712:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800714:	85 d2                	test   %edx,%edx
  800716:	74 19                	je     800731 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800718:	4a                   	dec    %edx
  800719:	74 13                	je     80072e <strlcpy+0x2a>
  80071b:	80 39 00             	cmpb   $0x0,(%ecx)
  80071e:	74 0e                	je     80072e <strlcpy+0x2a>
			*dst++ = *src++;
  800720:	8a 01                	mov    (%ecx),%al
  800722:	41                   	inc    %ecx
  800723:	88 03                	mov    %al,(%ebx)
  800725:	43                   	inc    %ebx
  800726:	4a                   	dec    %edx
  800727:	74 05                	je     80072e <strlcpy+0x2a>
  800729:	80 39 00             	cmpb   $0x0,(%ecx)
  80072c:	75 f2                	jne    800720 <strlcpy+0x1c>
		*dst = '\0';
  80072e:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800731:	89 d8                	mov    %ebx,%eax
  800733:	29 f0                	sub    %esi,%eax
}
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	8b 55 08             	mov    0x8(%ebp),%edx
  80073f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800742:	80 3a 00             	cmpb   $0x0,(%edx)
  800745:	74 13                	je     80075a <strcmp+0x21>
  800747:	8a 02                	mov    (%edx),%al
  800749:	3a 01                	cmp    (%ecx),%al
  80074b:	75 0d                	jne    80075a <strcmp+0x21>
		p++, q++;
  80074d:	42                   	inc    %edx
  80074e:	41                   	inc    %ecx
  80074f:	80 3a 00             	cmpb   $0x0,(%edx)
  800752:	74 06                	je     80075a <strcmp+0x21>
  800754:	8a 02                	mov    (%edx),%al
  800756:	3a 01                	cmp    (%ecx),%al
  800758:	74 f3                	je     80074d <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80075a:	0f b6 02             	movzbl (%edx),%eax
  80075d:	0f b6 11             	movzbl (%ecx),%edx
  800760:	29 d0                	sub    %edx,%eax
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	53                   	push   %ebx
  800768:	8b 55 08             	mov    0x8(%ebp),%edx
  80076b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800771:	85 c9                	test   %ecx,%ecx
  800773:	74 1f                	je     800794 <strncmp+0x30>
  800775:	80 3a 00             	cmpb   $0x0,(%edx)
  800778:	74 16                	je     800790 <strncmp+0x2c>
  80077a:	8a 02                	mov    (%edx),%al
  80077c:	3a 03                	cmp    (%ebx),%al
  80077e:	75 10                	jne    800790 <strncmp+0x2c>
		n--, p++, q++;
  800780:	42                   	inc    %edx
  800781:	43                   	inc    %ebx
  800782:	49                   	dec    %ecx
  800783:	74 0f                	je     800794 <strncmp+0x30>
  800785:	80 3a 00             	cmpb   $0x0,(%edx)
  800788:	74 06                	je     800790 <strncmp+0x2c>
  80078a:	8a 02                	mov    (%edx),%al
  80078c:	3a 03                	cmp    (%ebx),%al
  80078e:	74 f0                	je     800780 <strncmp+0x1c>
	if (n == 0)
  800790:	85 c9                	test   %ecx,%ecx
  800792:	75 07                	jne    80079b <strncmp+0x37>
		return 0;
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
  800799:	eb 0a                	jmp    8007a5 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80079b:	0f b6 12             	movzbl (%edx),%edx
  80079e:	0f b6 03             	movzbl (%ebx),%eax
  8007a1:	29 c2                	sub    %eax,%edx
  8007a3:	89 d0                	mov    %edx,%eax
}
  8007a5:	8b 1c 24             	mov    (%esp),%ebx
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b0:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007b3:	80 38 00             	cmpb   $0x0,(%eax)
  8007b6:	74 0a                	je     8007c2 <strchr+0x18>
		if (*s == c)
  8007b8:	38 10                	cmp    %dl,(%eax)
  8007ba:	74 0b                	je     8007c7 <strchr+0x1d>
  8007bc:	40                   	inc    %eax
  8007bd:	80 38 00             	cmpb   $0x0,(%eax)
  8007c0:	75 f6                	jne    8007b8 <strchr+0xe>
			return (char *) s;
	return 0;
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007d2:	80 38 00             	cmpb   $0x0,(%eax)
  8007d5:	74 0a                	je     8007e1 <strfind+0x18>
		if (*s == c)
  8007d7:	38 10                	cmp    %dl,(%eax)
  8007d9:	74 06                	je     8007e1 <strfind+0x18>
  8007db:	40                   	inc    %eax
  8007dc:	80 38 00             	cmpb   $0x0,(%eax)
  8007df:	75 f6                	jne    8007d7 <strfind+0xe>
			break;
	return (char *) s;
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	57                   	push   %edi
  8007e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8007ed:	89 f8                	mov    %edi,%eax
  8007ef:	85 c9                	test   %ecx,%ecx
  8007f1:	74 40                	je     800833 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007f3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007f9:	75 30                	jne    80082b <memset+0x48>
  8007fb:	f6 c1 03             	test   $0x3,%cl
  8007fe:	75 2b                	jne    80082b <memset+0x48>
		c &= 0xFF;
  800800:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080a:	c1 e0 18             	shl    $0x18,%eax
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800810:	c1 e2 10             	shl    $0x10,%edx
  800813:	09 d0                	or     %edx,%eax
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
  800818:	c1 e2 08             	shl    $0x8,%edx
  80081b:	09 d0                	or     %edx,%eax
  80081d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800820:	c1 e9 02             	shr    $0x2,%ecx
  800823:	8b 45 0c             	mov    0xc(%ebp),%eax
  800826:	fc                   	cld    
  800827:	f3 ab                	repz stos %eax,%es:(%edi)
  800829:	eb 06                	jmp    800831 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80082b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082e:	fc                   	cld    
  80082f:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800831:	89 f8                	mov    %edi,%eax
}
  800833:	8b 3c 24             	mov    (%esp),%edi
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	57                   	push   %edi
  80083c:	56                   	push   %esi
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800843:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800846:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800848:	39 c6                	cmp    %eax,%esi
  80084a:	73 33                	jae    80087f <memmove+0x47>
  80084c:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  80084f:	39 c2                	cmp    %eax,%edx
  800851:	76 2c                	jbe    80087f <memmove+0x47>
		s += n;
  800853:	89 d6                	mov    %edx,%esi
		d += n;
  800855:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800858:	f6 c2 03             	test   $0x3,%dl
  80085b:	75 1b                	jne    800878 <memmove+0x40>
  80085d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800863:	75 13                	jne    800878 <memmove+0x40>
  800865:	f6 c1 03             	test   $0x3,%cl
  800868:	75 0e                	jne    800878 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80086a:	83 ef 04             	sub    $0x4,%edi
  80086d:	83 ee 04             	sub    $0x4,%esi
  800870:	c1 e9 02             	shr    $0x2,%ecx
  800873:	fd                   	std    
  800874:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800876:	eb 27                	jmp    80089f <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800878:	4f                   	dec    %edi
  800879:	4e                   	dec    %esi
  80087a:	fd                   	std    
  80087b:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  80087d:	eb 20                	jmp    80089f <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80087f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800885:	75 15                	jne    80089c <memmove+0x64>
  800887:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088d:	75 0d                	jne    80089c <memmove+0x64>
  80088f:	f6 c1 03             	test   $0x3,%cl
  800892:	75 08                	jne    80089c <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800894:	c1 e9 02             	shr    $0x2,%ecx
  800897:	fc                   	cld    
  800898:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80089a:	eb 03                	jmp    80089f <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80089c:	fc                   	cld    
  80089d:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <memcpy>:

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
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008a9:	ff 75 10             	pushl  0x10(%ebp)
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	ff 75 08             	pushl  0x8(%ebp)
  8008b2:	e8 81 ff ff ff       	call   800838 <memmove>
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	4a                   	dec    %edx
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	74 1b                	je     8008e8 <memcmp+0x2f>
		if (*s1 != *s2)
  8008cd:	8a 01                	mov    (%ecx),%al
  8008cf:	3a 03                	cmp    (%ebx),%al
  8008d1:	74 0c                	je     8008df <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008d3:	0f b6 d0             	movzbl %al,%edx
  8008d6:	0f b6 03             	movzbl (%ebx),%eax
  8008d9:	29 c2                	sub    %eax,%edx
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	eb 0e                	jmp    8008ed <memcmp+0x34>
		s1++, s2++;
  8008df:	41                   	inc    %ecx
  8008e0:	43                   	inc    %ebx
  8008e1:	89 d0                	mov    %edx,%eax
  8008e3:	4a                   	dec    %edx
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	75 e5                	jne    8008cd <memcmp+0x14>
	}

	return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008f9:	89 c2                	mov    %eax,%edx
  8008fb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008fe:	39 d0                	cmp    %edx,%eax
  800900:	73 09                	jae    80090b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800902:	38 08                	cmp    %cl,(%eax)
  800904:	74 05                	je     80090b <memfind+0x1b>
  800906:	40                   	inc    %eax
  800907:	39 d0                	cmp    %edx,%eax
  800909:	72 f7                	jb     800902 <memfind+0x12>
			break;
	return (void *) s;
}
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    

0080090d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
  800916:	8b 75 0c             	mov    0xc(%ebp),%esi
  800919:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  80091c:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800921:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800926:	80 3a 20             	cmpb   $0x20,(%edx)
  800929:	74 05                	je     800930 <strtol+0x23>
  80092b:	80 3a 09             	cmpb   $0x9,(%edx)
  80092e:	75 0b                	jne    80093b <strtol+0x2e>
		s++;
  800930:	42                   	inc    %edx
  800931:	80 3a 20             	cmpb   $0x20,(%edx)
  800934:	74 fa                	je     800930 <strtol+0x23>
  800936:	80 3a 09             	cmpb   $0x9,(%edx)
  800939:	74 f5                	je     800930 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80093b:	80 3a 2b             	cmpb   $0x2b,(%edx)
  80093e:	75 03                	jne    800943 <strtol+0x36>
		s++;
  800940:	42                   	inc    %edx
  800941:	eb 0b                	jmp    80094e <strtol+0x41>
	else if (*s == '-')
  800943:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800946:	75 06                	jne    80094e <strtol+0x41>
		s++, neg = 1;
  800948:	42                   	inc    %edx
  800949:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80094e:	85 c9                	test   %ecx,%ecx
  800950:	74 05                	je     800957 <strtol+0x4a>
  800952:	83 f9 10             	cmp    $0x10,%ecx
  800955:	75 15                	jne    80096c <strtol+0x5f>
  800957:	80 3a 30             	cmpb   $0x30,(%edx)
  80095a:	75 10                	jne    80096c <strtol+0x5f>
  80095c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800960:	75 0a                	jne    80096c <strtol+0x5f>
		s += 2, base = 16;
  800962:	83 c2 02             	add    $0x2,%edx
  800965:	b9 10 00 00 00       	mov    $0x10,%ecx
  80096a:	eb 1a                	jmp    800986 <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  80096c:	85 c9                	test   %ecx,%ecx
  80096e:	75 16                	jne    800986 <strtol+0x79>
  800970:	80 3a 30             	cmpb   $0x30,(%edx)
  800973:	75 08                	jne    80097d <strtol+0x70>
		s++, base = 8;
  800975:	42                   	inc    %edx
  800976:	b9 08 00 00 00       	mov    $0x8,%ecx
  80097b:	eb 09                	jmp    800986 <strtol+0x79>
	else if (base == 0)
  80097d:	85 c9                	test   %ecx,%ecx
  80097f:	75 05                	jne    800986 <strtol+0x79>
		base = 10;
  800981:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800986:	8a 02                	mov    (%edx),%al
  800988:	83 e8 30             	sub    $0x30,%eax
  80098b:	3c 09                	cmp    $0x9,%al
  80098d:	77 08                	ja     800997 <strtol+0x8a>
			dig = *s - '0';
  80098f:	0f be 02             	movsbl (%edx),%eax
  800992:	83 e8 30             	sub    $0x30,%eax
  800995:	eb 20                	jmp    8009b7 <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800997:	8a 02                	mov    (%edx),%al
  800999:	83 e8 61             	sub    $0x61,%eax
  80099c:	3c 19                	cmp    $0x19,%al
  80099e:	77 08                	ja     8009a8 <strtol+0x9b>
			dig = *s - 'a' + 10;
  8009a0:	0f be 02             	movsbl (%edx),%eax
  8009a3:	83 e8 57             	sub    $0x57,%eax
  8009a6:	eb 0f                	jmp    8009b7 <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  8009a8:	8a 02                	mov    (%edx),%al
  8009aa:	83 e8 41             	sub    $0x41,%eax
  8009ad:	3c 19                	cmp    $0x19,%al
  8009af:	77 12                	ja     8009c3 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009b1:	0f be 02             	movsbl (%edx),%eax
  8009b4:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009b7:	39 c8                	cmp    %ecx,%eax
  8009b9:	7d 08                	jge    8009c3 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009bb:	42                   	inc    %edx
  8009bc:	0f af d9             	imul   %ecx,%ebx
  8009bf:	01 c3                	add    %eax,%ebx
  8009c1:	eb c3                	jmp    800986 <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009c3:	85 f6                	test   %esi,%esi
  8009c5:	74 02                	je     8009c9 <strtol+0xbc>
		*endptr = (char *) s;
  8009c7:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009c9:	89 d8                	mov    %ebx,%eax
  8009cb:	85 ff                	test   %edi,%edi
  8009cd:	74 02                	je     8009d1 <strtol+0xc4>
  8009cf:	f7 d8                	neg    %eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    
	...

008009d8 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e9:	89 f8                	mov    %edi,%eax
  8009eb:	89 fb                	mov    %edi,%ebx
  8009ed:	89 fe                	mov    %edi,%esi
  8009ef:	55                   	push   %ebp
  8009f0:	9c                   	pushf  
  8009f1:	56                   	push   %esi
  8009f2:	54                   	push   %esp
  8009f3:	5d                   	pop    %ebp
  8009f4:	8d 35 fc 09 80 00    	lea    0x8009fc,%esi
  8009fa:	0f 34                	sysenter 
  8009fc:	83 c4 04             	add    $0x4,%esp
  8009ff:	9d                   	popf   
  800a00:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5f                   	pop    %edi
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a11:	bf 00 00 00 00       	mov    $0x0,%edi
  800a16:	89 fa                	mov    %edi,%edx
  800a18:	89 f9                	mov    %edi,%ecx
  800a1a:	89 fb                	mov    %edi,%ebx
  800a1c:	89 fe                	mov    %edi,%esi
  800a1e:	55                   	push   %ebp
  800a1f:	9c                   	pushf  
  800a20:	56                   	push   %esi
  800a21:	54                   	push   %esp
  800a22:	5d                   	pop    %ebp
  800a23:	8d 35 2b 0a 80 00    	lea    0x800a2b,%esi
  800a29:	0f 34                	sysenter 
  800a2b:	83 c4 04             	add    $0x4,%esp
  800a2e:	9d                   	popf   
  800a2f:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	83 ec 0c             	sub    $0xc,%esp
  800a3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a41:	b8 03 00 00 00       	mov    $0x3,%eax
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4b:	89 f9                	mov    %edi,%ecx
  800a4d:	89 fb                	mov    %edi,%ebx
  800a4f:	89 fe                	mov    %edi,%esi
  800a51:	55                   	push   %ebp
  800a52:	9c                   	pushf  
  800a53:	56                   	push   %esi
  800a54:	54                   	push   %esp
  800a55:	5d                   	pop    %ebp
  800a56:	8d 35 5e 0a 80 00    	lea    0x800a5e,%esi
  800a5c:	0f 34                	sysenter 
  800a5e:	83 c4 04             	add    $0x4,%esp
  800a61:	9d                   	popf   
  800a62:	5d                   	pop    %ebp
  800a63:	85 c0                	test   %eax,%eax
  800a65:	7e 17                	jle    800a7e <sys_env_destroy+0x49>
  800a67:	83 ec 0c             	sub    $0xc,%esp
  800a6a:	50                   	push   %eax
  800a6b:	6a 03                	push   $0x3
  800a6d:	68 7c 13 80 00       	push   $0x80137c
  800a72:	6a 4c                	push   $0x4c
  800a74:	68 99 13 80 00       	push   $0x801399
  800a79:	e8 06 03 00 00       	call   800d84 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a7e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	c9                   	leave  
  800a85:	c3                   	ret    

00800a86 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	b8 02 00 00 00       	mov    $0x2,%eax
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
  800a96:	89 fa                	mov    %edi,%edx
  800a98:	89 f9                	mov    %edi,%ecx
  800a9a:	89 fb                	mov    %edi,%ebx
  800a9c:	89 fe                	mov    %edi,%esi
  800a9e:	55                   	push   %ebp
  800a9f:	9c                   	pushf  
  800aa0:	56                   	push   %esi
  800aa1:	54                   	push   %esp
  800aa2:	5d                   	pop    %ebp
  800aa3:	8d 35 ab 0a 80 00    	lea    0x800aab,%esi
  800aa9:	0f 34                	sysenter 
  800aab:	83 c4 04             	add    $0x4,%esp
  800aae:	9d                   	popf   
  800aaf:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	c9                   	leave  
  800ab4:	c3                   	ret    

00800ab5 <sys_dump_env>:

int
sys_dump_env(void)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	b8 04 00 00 00       	mov    $0x4,%eax
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	89 fa                	mov    %edi,%edx
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
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	c9                   	leave  
  800ae3:	c3                   	ret    

00800ae4 <sys_yield>:

void
sys_yield(void)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
  800aea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
  800af4:	89 fa                	mov    %edi,%edx
  800af6:	89 f9                	mov    %edi,%ecx
  800af8:	89 fb                	mov    %edi,%ebx
  800afa:	89 fe                	mov    %edi,%esi
  800afc:	55                   	push   %ebp
  800afd:	9c                   	pushf  
  800afe:	56                   	push   %esi
  800aff:	54                   	push   %esp
  800b00:	5d                   	pop    %ebp
  800b01:	8d 35 09 0b 80 00    	lea    0x800b09,%esi
  800b07:	0f 34                	sysenter 
  800b09:	83 c4 04             	add    $0x4,%esp
  800b0c:	9d                   	popf   
  800b0d:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b25:	b8 05 00 00 00       	mov    $0x5,%eax
  800b2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2f:	89 fe                	mov    %edi,%esi
  800b31:	55                   	push   %ebp
  800b32:	9c                   	pushf  
  800b33:	56                   	push   %esi
  800b34:	54                   	push   %esp
  800b35:	5d                   	pop    %ebp
  800b36:	8d 35 3e 0b 80 00    	lea    0x800b3e,%esi
  800b3c:	0f 34                	sysenter 
  800b3e:	83 c4 04             	add    $0x4,%esp
  800b41:	9d                   	popf   
  800b42:	5d                   	pop    %ebp
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7e 17                	jle    800b5e <sys_page_alloc+0x4b>
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	50                   	push   %eax
  800b4b:	6a 05                	push   $0x5
  800b4d:	68 7c 13 80 00       	push   $0x80137c
  800b52:	6a 4c                	push   $0x4c
  800b54:	68 99 13 80 00       	push   $0x801399
  800b59:	e8 26 02 00 00       	call   800d84 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b83:	55                   	push   %ebp
  800b84:	9c                   	pushf  
  800b85:	56                   	push   %esi
  800b86:	54                   	push   %esp
  800b87:	5d                   	pop    %ebp
  800b88:	8d 35 90 0b 80 00    	lea    0x800b90,%esi
  800b8e:	0f 34                	sysenter 
  800b90:	83 c4 04             	add    $0x4,%esp
  800b93:	9d                   	popf   
  800b94:	5d                   	pop    %ebp
  800b95:	85 c0                	test   %eax,%eax
  800b97:	7e 17                	jle    800bb0 <sys_page_map+0x4a>
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	50                   	push   %eax
  800b9d:	6a 06                	push   $0x6
  800b9f:	68 7c 13 80 00       	push   $0x80137c
  800ba4:	6a 4c                	push   $0x4c
  800ba6:	68 99 13 80 00       	push   $0x801399
  800bab:	e8 d4 01 00 00       	call   800d84 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800bb0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc7:	b8 07 00 00 00       	mov    $0x7,%eax
  800bcc:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd1:	89 fb                	mov    %edi,%ebx
  800bd3:	89 fe                	mov    %edi,%esi
  800bd5:	55                   	push   %ebp
  800bd6:	9c                   	pushf  
  800bd7:	56                   	push   %esi
  800bd8:	54                   	push   %esp
  800bd9:	5d                   	pop    %ebp
  800bda:	8d 35 e2 0b 80 00    	lea    0x800be2,%esi
  800be0:	0f 34                	sysenter 
  800be2:	83 c4 04             	add    $0x4,%esp
  800be5:	9d                   	popf   
  800be6:	5d                   	pop    %ebp
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 17                	jle    800c02 <sys_page_unmap+0x4a>
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 07                	push   $0x7
  800bf1:	68 7c 13 80 00       	push   $0x80137c
  800bf6:	6a 4c                	push   $0x4c
  800bf8:	68 99 13 80 00       	push   $0x801399
  800bfd:	e8 82 01 00 00       	call   800d84 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c02:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	b8 09 00 00 00       	mov    $0x9,%eax
  800c1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c23:	89 fb                	mov    %edi,%ebx
  800c25:	89 fe                	mov    %edi,%esi
  800c27:	55                   	push   %ebp
  800c28:	9c                   	pushf  
  800c29:	56                   	push   %esi
  800c2a:	54                   	push   %esp
  800c2b:	5d                   	pop    %ebp
  800c2c:	8d 35 34 0c 80 00    	lea    0x800c34,%esi
  800c32:	0f 34                	sysenter 
  800c34:	83 c4 04             	add    $0x4,%esp
  800c37:	9d                   	popf   
  800c38:	5d                   	pop    %ebp
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_env_set_status+0x4a>
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 09                	push   $0x9
  800c43:	68 7c 13 80 00       	push   $0x80137c
  800c48:	6a 4c                	push   $0x4c
  800c4a:	68 99 13 80 00       	push   $0x801399
  800c4f:	e8 30 01 00 00       	call   800d84 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c54:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c70:	bf 00 00 00 00       	mov    $0x0,%edi
  800c75:	89 fb                	mov    %edi,%ebx
  800c77:	89 fe                	mov    %edi,%esi
  800c79:	55                   	push   %ebp
  800c7a:	9c                   	pushf  
  800c7b:	56                   	push   %esi
  800c7c:	54                   	push   %esp
  800c7d:	5d                   	pop    %ebp
  800c7e:	8d 35 86 0c 80 00    	lea    0x800c86,%esi
  800c84:	0f 34                	sysenter 
  800c86:	83 c4 04             	add    $0x4,%esp
  800c89:	9d                   	popf   
  800c8a:	5d                   	pop    %ebp
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 17                	jle    800ca6 <sys_env_set_trapframe+0x4a>
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 0a                	push   $0xa
  800c95:	68 7c 13 80 00       	push   $0x80137c
  800c9a:	6a 4c                	push   $0x4c
  800c9c:	68 99 13 80 00       	push   $0x801399
  800ca1:	e8 de 00 00 00       	call   800d84 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc7:	89 fb                	mov    %edi,%ebx
  800cc9:	89 fe                	mov    %edi,%esi
  800ccb:	55                   	push   %ebp
  800ccc:	9c                   	pushf  
  800ccd:	56                   	push   %esi
  800cce:	54                   	push   %esp
  800ccf:	5d                   	pop    %ebp
  800cd0:	8d 35 d8 0c 80 00    	lea    0x800cd8,%esi
  800cd6:	0f 34                	sysenter 
  800cd8:	83 c4 04             	add    $0x4,%esp
  800cdb:	9d                   	popf   
  800cdc:	5d                   	pop    %ebp
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_env_set_pgfault_upcall+0x4a>
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 0b                	push   $0xb
  800ce7:	68 7c 13 80 00       	push   $0x80137c
  800cec:	6a 4c                	push   $0x4c
  800cee:	68 99 13 80 00       	push   $0x801399
  800cf3:	e8 8c 00 00 00       	call   800d84 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    

00800d00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d12:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d17:	be 00 00 00 00       	mov    $0x0,%esi
  800d1c:	55                   	push   %ebp
  800d1d:	9c                   	pushf  
  800d1e:	56                   	push   %esi
  800d1f:	54                   	push   %esp
  800d20:	5d                   	pop    %ebp
  800d21:	8d 35 29 0d 80 00    	lea    0x800d29,%esi
  800d27:	0f 34                	sysenter 
  800d29:	83 c4 04             	add    $0x4,%esp
  800d2c:	9d                   	popf   
  800d2d:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d44:	bf 00 00 00 00       	mov    $0x0,%edi
  800d49:	89 f9                	mov    %edi,%ecx
  800d4b:	89 fb                	mov    %edi,%ebx
  800d4d:	89 fe                	mov    %edi,%esi
  800d4f:	55                   	push   %ebp
  800d50:	9c                   	pushf  
  800d51:	56                   	push   %esi
  800d52:	54                   	push   %esp
  800d53:	5d                   	pop    %ebp
  800d54:	8d 35 5c 0d 80 00    	lea    0x800d5c,%esi
  800d5a:	0f 34                	sysenter 
  800d5c:	83 c4 04             	add    $0x4,%esp
  800d5f:	9d                   	popf   
  800d60:	5d                   	pop    %ebp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_ipc_recv+0x49>
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 0e                	push   $0xe
  800d6b:	68 7c 13 80 00       	push   $0x80137c
  800d70:	6a 4c                	push   $0x4c
  800d72:	68 99 13 80 00       	push   $0x801399
  800d77:	e8 08 00 00 00       	call   800d84 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	53                   	push   %ebx
  800d88:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  800d8b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800d8e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d95:	74 16                	je     800dad <_panic+0x29>
		cprintf("%s: ", argv0);
  800d97:	83 ec 08             	sub    $0x8,%esp
  800d9a:	ff 35 08 20 80 00    	pushl  0x802008
  800da0:	68 a7 13 80 00       	push   $0x8013a7
  800da5:	e8 d2 f3 ff ff       	call   80017c <cprintf>
  800daa:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800dad:	ff 75 0c             	pushl  0xc(%ebp)
  800db0:	ff 75 08             	pushl  0x8(%ebp)
  800db3:	ff 35 00 20 80 00    	pushl  0x802000
  800db9:	68 ac 13 80 00       	push   $0x8013ac
  800dbe:	e8 b9 f3 ff ff       	call   80017c <cprintf>
	vcprintf(fmt, ap);
  800dc3:	83 c4 08             	add    $0x8,%esp
  800dc6:	53                   	push   %ebx
  800dc7:	ff 75 10             	pushl  0x10(%ebp)
  800dca:	e8 5c f3 ff ff       	call   80012b <vcprintf>
	cprintf("\n");
  800dcf:	c7 04 24 c8 13 80 00 	movl   $0x8013c8,(%esp)
  800dd6:	e8 a1 f3 ff ff       	call   80017c <cprintf>

	// Cause a breakpoint exception
	while (1)
  800ddb:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800dde:	cc                   	int3   
  800ddf:	eb fd                	jmp    800dde <_panic+0x5a>
}
  800de1:	00 00                	add    %al,(%eax)
	...

00800de4 <__udivdi3>:
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	83 ec 20             	sub    $0x20,%esp
  800dec:	8b 55 14             	mov    0x14(%ebp),%edx
  800def:	8b 75 08             	mov    0x8(%ebp),%esi
  800df2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800df5:	8b 45 10             	mov    0x10(%ebp),%eax
  800df8:	85 d2                	test   %edx,%edx
  800dfa:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800dfd:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800e04:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800e0b:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e0e:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e11:	89 fe                	mov    %edi,%esi
  800e13:	75 5b                	jne    800e70 <__udivdi3+0x8c>
  800e15:	39 f8                	cmp    %edi,%eax
  800e17:	76 2b                	jbe    800e44 <__udivdi3+0x60>
  800e19:	89 fa                	mov    %edi,%edx
  800e1b:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e1e:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e21:	89 c7                	mov    %eax,%edi
  800e23:	90                   	nop    
  800e24:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800e2b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800e2e:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800e31:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e34:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e37:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e3a:	83 c4 20             	add    $0x20,%esp
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    
  800e41:	8d 76 00             	lea    0x0(%esi),%esi
  800e44:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e47:	85 c0                	test   %eax,%eax
  800e49:	75 0e                	jne    800e59 <__udivdi3+0x75>
  800e4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800e50:	31 c9                	xor    %ecx,%ecx
  800e52:	31 d2                	xor    %edx,%edx
  800e54:	f7 f1                	div    %ecx
  800e56:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e59:	89 f0                	mov    %esi,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e60:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e63:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e66:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e69:	89 c7                	mov    %eax,%edi
  800e6b:	eb be                	jmp    800e2b <__udivdi3+0x47>
  800e6d:	8d 76 00             	lea    0x0(%esi),%esi
  800e70:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800e73:	76 07                	jbe    800e7c <__udivdi3+0x98>
  800e75:	31 ff                	xor    %edi,%edi
  800e77:	eb ab                	jmp    800e24 <__udivdi3+0x40>
  800e79:	8d 76 00             	lea    0x0(%esi),%esi
  800e7c:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800e80:	89 c7                	mov    %eax,%edi
  800e82:	83 f7 1f             	xor    $0x1f,%edi
  800e85:	75 19                	jne    800ea0 <__udivdi3+0xbc>
  800e87:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800e8a:	77 0a                	ja     800e96 <__udivdi3+0xb2>
  800e8c:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e8f:	31 ff                	xor    %edi,%edi
  800e91:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800e94:	72 8e                	jb     800e24 <__udivdi3+0x40>
  800e96:	bf 01 00 00 00       	mov    $0x1,%edi
  800e9b:	eb 87                	jmp    800e24 <__udivdi3+0x40>
  800e9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ea0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea5:	29 f8                	sub    %edi,%eax
  800ea7:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800eaa:	89 f9                	mov    %edi,%ecx
  800eac:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800eaf:	d3 e2                	shl    %cl,%edx
  800eb1:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800eb4:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800eb7:	d3 e8                	shr    %cl,%eax
  800eb9:	09 c2                	or     %eax,%edx
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800ec0:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800ec3:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800ec6:	89 f2                	mov    %esi,%edx
  800ec8:	d3 ea                	shr    %cl,%edx
  800eca:	89 f9                	mov    %edi,%ecx
  800ecc:	d3 e6                	shl    %cl,%esi
  800ece:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800ed1:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800ed4:	d3 e8                	shr    %cl,%eax
  800ed6:	09 c6                	or     %eax,%esi
  800ed8:	89 f9                	mov    %edi,%ecx
  800eda:	89 f0                	mov    %esi,%eax
  800edc:	f7 75 ec             	divl   0xffffffec(%ebp)
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	89 c7                	mov    %eax,%edi
  800ee3:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800ee6:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800ee9:	f7 e7                	mul    %edi
  800eeb:	39 f2                	cmp    %esi,%edx
  800eed:	77 0f                	ja     800efe <__udivdi3+0x11a>
  800eef:	0f 85 2f ff ff ff    	jne    800e24 <__udivdi3+0x40>
  800ef5:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800ef8:	0f 86 26 ff ff ff    	jbe    800e24 <__udivdi3+0x40>
  800efe:	4f                   	dec    %edi
  800eff:	e9 20 ff ff ff       	jmp    800e24 <__udivdi3+0x40>

00800f04 <__umoddi3>:
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	83 ec 30             	sub    $0x30,%esp
  800f0c:	8b 55 14             	mov    0x14(%ebp),%edx
  800f0f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f12:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f15:	8b 45 10             	mov    0x10(%ebp),%eax
  800f18:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800f1b:	85 d2                	test   %edx,%edx
  800f1d:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800f24:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f2b:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800f2e:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f31:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800f34:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800f37:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800f3a:	75 68                	jne    800fa4 <__umoddi3+0xa0>
  800f3c:	39 f8                	cmp    %edi,%eax
  800f3e:	76 3c                	jbe    800f7c <__umoddi3+0x78>
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	89 fa                	mov    %edi,%edx
  800f44:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f47:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800f4a:	85 c9                	test   %ecx,%ecx
  800f4c:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800f4f:	74 1b                	je     800f6c <__umoddi3+0x68>
  800f51:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f54:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800f57:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f5e:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f61:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800f64:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800f67:	89 10                	mov    %edx,(%eax)
  800f69:	89 48 04             	mov    %ecx,0x4(%eax)
  800f6c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f6f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f72:	83 c4 30             	add    $0x30,%esp
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    
  800f79:	8d 76 00             	lea    0x0(%esi),%esi
  800f7c:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  800f7f:	85 f6                	test   %esi,%esi
  800f81:	75 0d                	jne    800f90 <__umoddi3+0x8c>
  800f83:	b8 01 00 00 00       	mov    $0x1,%eax
  800f88:	31 d2                	xor    %edx,%edx
  800f8a:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f8d:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f90:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800f93:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f96:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f99:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f9c:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f9f:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800fa2:	eb a3                	jmp    800f47 <__umoddi3+0x43>
  800fa4:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fa7:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800faa:	76 14                	jbe    800fc0 <__umoddi3+0xbc>
  800fac:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800faf:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800fb2:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800fb5:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800fb8:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800fbb:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800fbe:	eb ac                	jmp    800f6c <__umoddi3+0x68>
  800fc0:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800fc4:	89 c6                	mov    %eax,%esi
  800fc6:	83 f6 1f             	xor    $0x1f,%esi
  800fc9:	75 4d                	jne    801018 <__umoddi3+0x114>
  800fcb:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800fce:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800fd1:	77 08                	ja     800fdb <__umoddi3+0xd7>
  800fd3:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  800fd6:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800fd9:	72 12                	jb     800fed <__umoddi3+0xe9>
  800fdb:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fde:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fe1:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  800fe4:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800fe7:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800fea:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800fed:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800ff0:	85 d2                	test   %edx,%edx
  800ff2:	0f 84 74 ff ff ff    	je     800f6c <__umoddi3+0x68>
  800ff8:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800ffb:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800ffe:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801001:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  801004:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  801007:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80100a:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  80100d:	89 01                	mov    %eax,(%ecx)
  80100f:	89 51 04             	mov    %edx,0x4(%ecx)
  801012:	e9 55 ff ff ff       	jmp    800f6c <__umoddi3+0x68>
  801017:	90                   	nop    
  801018:	b8 20 00 00 00       	mov    $0x20,%eax
  80101d:	29 f0                	sub    %esi,%eax
  80101f:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  801022:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801025:	89 f1                	mov    %esi,%ecx
  801027:	d3 e2                	shl    %cl,%edx
  801029:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  80102c:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80102f:	d3 e8                	shr    %cl,%eax
  801031:	09 c2                	or     %eax,%edx
  801033:	89 f1                	mov    %esi,%ecx
  801035:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801038:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80103b:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80103e:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801041:	d3 ea                	shr    %cl,%edx
  801043:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  801046:	89 f1                	mov    %esi,%ecx
  801048:	d3 e7                	shl    %cl,%edi
  80104a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80104d:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801050:	d3 e8                	shr    %cl,%eax
  801052:	09 c7                	or     %eax,%edi
  801054:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801057:	89 f8                	mov    %edi,%eax
  801059:	89 f1                	mov    %esi,%ecx
  80105b:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80105e:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801061:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801064:	f7 65 cc             	mull   0xffffffcc(%ebp)
  801067:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  80106a:	89 c7                	mov    %eax,%edi
  80106c:	77 3f                	ja     8010ad <__umoddi3+0x1a9>
  80106e:	74 38                	je     8010a8 <__umoddi3+0x1a4>
  801070:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  801073:	85 c0                	test   %eax,%eax
  801075:	0f 84 f1 fe ff ff    	je     800f6c <__umoddi3+0x68>
  80107b:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  80107e:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801081:	29 f8                	sub    %edi,%eax
  801083:	19 d1                	sbb    %edx,%ecx
  801085:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  801088:	89 ca                	mov    %ecx,%edx
  80108a:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80108d:	d3 e2                	shl    %cl,%edx
  80108f:	89 f1                	mov    %esi,%ecx
  801091:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801094:	d3 e8                	shr    %cl,%eax
  801096:	09 c2                	or     %eax,%edx
  801098:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  80109b:	d3 e8                	shr    %cl,%eax
  80109d:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8010a0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8010a3:	e9 b6 fe ff ff       	jmp    800f5e <__umoddi3+0x5a>
  8010a8:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  8010ab:	76 c3                	jbe    801070 <__umoddi3+0x16c>
  8010ad:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  8010b0:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  8010b3:	eb bb                	jmp    801070 <__umoddi3+0x16c>
  8010b5:	90                   	nop    
  8010b6:	90                   	nop    
  8010b7:	90                   	nop    
