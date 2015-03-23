
obj/user/spin：     文件格式 elf32-i386

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

00800034 <umain>:
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	68 e0 13 80 00       	push   $0x8013e0
  800040:	e8 53 01 00 00       	call   800198 <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 9f 0e 00 00       	call   800ee9 <fork>
  80004a:	89 c3                	mov    %eax,%ebx
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 12                	jne    800065 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 58 14 80 00       	push   $0x801458
  80005b:	e8 38 01 00 00       	call   800198 <cprintf>
		while (1)
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	eb fe                	jmp    800063 <umain+0x2f>
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 08 14 80 00       	push   $0x801408
  80006d:	e8 26 01 00 00       	call   800198 <cprintf>
	sys_yield();
  800072:	e8 89 0a 00 00       	call   800b00 <sys_yield>
	sys_yield();
  800077:	e8 84 0a 00 00       	call   800b00 <sys_yield>
	sys_yield();
  80007c:	e8 7f 0a 00 00       	call   800b00 <sys_yield>
	sys_yield();
  800081:	e8 7a 0a 00 00       	call   800b00 <sys_yield>
	sys_yield();
  800086:	e8 75 0a 00 00       	call   800b00 <sys_yield>
	sys_yield();
  80008b:	e8 70 0a 00 00       	call   800b00 <sys_yield>
	sys_yield();
  800090:	e8 6b 0a 00 00       	call   800b00 <sys_yield>
	sys_yield();
  800095:	e8 66 0a 00 00       	call   800b00 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009a:	c7 04 24 30 14 80 00 	movl   $0x801430,(%esp)
  8000a1:	e8 f2 00 00 00       	call   800198 <cprintf>
	sys_env_destroy(env);
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 a3 09 00 00       	call   800a51 <sys_env_destroy>
}
  8000ae:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    
	...

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
  8000bf:	e8 de 09 00 00       	call   800aa2 <sys_getenvid>
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
  8000e6:	e8 49 ff ff ff       	call   800034 <umain>
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
  800100:	e8 4c 09 00 00       	call   800a51 <sys_env_destroy>
}
  800105:	c9                   	leave  
  800106:	c3                   	ret    
	...

00800108 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	53                   	push   %ebx
  80010c:	83 ec 04             	sub    $0x4,%esp
  80010f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800112:	8b 03                	mov    (%ebx),%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80011b:	40                   	inc    %eax
  80011c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800123:	75 1a                	jne    80013f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	68 ff 00 00 00       	push   $0xff
  80012d:	8d 43 08             	lea    0x8(%ebx),%eax
  800130:	50                   	push   %eax
  800131:	e8 be 08 00 00       	call   8009f4 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013f:	ff 43 04             	incl   0x4(%ebx)
}
  800142:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800150:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  800157:	00 00 00 
	b.cnt = 0;
  80015a:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800161:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800164:	ff 75 0c             	pushl  0xc(%ebp)
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800170:	50                   	push   %eax
  800171:	68 08 01 80 00       	push   $0x800108
  800176:	e8 83 01 00 00       	call   8002fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	83 c4 08             	add    $0x8,%esp
  80017e:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800184:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 64 08 00 00       	call   8009f4 <sys_cputs>

	return b.cnt;
  800190:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a1:	50                   	push   %eax
  8001a2:	ff 75 08             	pushl  0x8(%ebp)
  8001a5:	e8 9d ff ff ff       	call   800147 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 0c             	sub    $0xc,%esp
  8001b5:	8b 75 10             	mov    0x10(%ebp),%esi
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001be:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c6:	39 d7                	cmp    %edx,%edi
  8001c8:	72 39                	jb     800203 <printnum+0x57>
  8001ca:	77 04                	ja     8001d0 <printnum+0x24>
  8001cc:	39 c6                	cmp    %eax,%esi
  8001ce:	72 33                	jb     800203 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d0:	83 ec 04             	sub    $0x4,%esp
  8001d3:	ff 75 20             	pushl  0x20(%ebp)
  8001d6:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8001d9:	50                   	push   %eax
  8001da:	ff 75 18             	pushl  0x18(%ebp)
  8001dd:	8b 45 18             	mov    0x18(%ebp),%eax
  8001e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e5:	52                   	push   %edx
  8001e6:	50                   	push   %eax
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	e8 12 0f 00 00       	call   801100 <__udivdi3>
  8001ee:	83 c4 10             	add    $0x10,%esp
  8001f1:	52                   	push   %edx
  8001f2:	50                   	push   %eax
  8001f3:	ff 75 0c             	pushl  0xc(%ebp)
  8001f6:	ff 75 08             	pushl  0x8(%ebp)
  8001f9:	e8 ae ff ff ff       	call   8001ac <printnum>
  8001fe:	83 c4 20             	add    $0x20,%esp
  800201:	eb 19                	jmp    80021c <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800203:	4b                   	dec    %ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7e 14                	jle    80021c <printnum+0x70>
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 0c             	pushl  0xc(%ebp)
  80020e:	ff 75 20             	pushl  0x20(%ebp)
  800211:	ff 55 08             	call   *0x8(%ebp)
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	4b                   	dec    %ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f ec                	jg     800208 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	ff 75 0c             	pushl  0xc(%ebp)
  800222:	8b 45 18             	mov    0x18(%ebp),%eax
  800225:	ba 00 00 00 00       	mov    $0x0,%edx
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	52                   	push   %edx
  80022e:	50                   	push   %eax
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	e8 ea 0f 00 00       	call   801220 <__umoddi3>
  800236:	83 c4 14             	add    $0x14,%esp
  800239:	0f be 80 20 15 80 00 	movsbl 0x801520(%eax),%eax
  800240:	50                   	push   %eax
  800241:	ff 55 08             	call   *0x8(%ebp)
}
  800244:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 18             	sub    $0x18,%esp
  800254:	8b 75 08             	mov    0x8(%ebp),%esi
  800257:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025a:	8a 45 18             	mov    0x18(%ebp),%al
  80025d:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  800260:	53                   	push   %ebx
  800261:	6a 1b                	push   $0x1b
  800263:	ff d6                	call   *%esi
	putch('[', putdat);
  800265:	83 c4 08             	add    $0x8,%esp
  800268:	53                   	push   %ebx
  800269:	6a 5b                	push   $0x5b
  80026b:	ff d6                	call   *%esi
	putch('0', putdat);
  80026d:	83 c4 08             	add    $0x8,%esp
  800270:	53                   	push   %ebx
  800271:	6a 30                	push   $0x30
  800273:	ff d6                	call   *%esi
	putch(';', putdat);
  800275:	83 c4 08             	add    $0x8,%esp
  800278:	53                   	push   %ebx
  800279:	6a 3b                	push   $0x3b
  80027b:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  80027d:	83 c4 0c             	add    $0xc,%esp
  800280:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800284:	50                   	push   %eax
  800285:	ff 75 14             	pushl  0x14(%ebp)
  800288:	6a 0a                	push   $0xa
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
  80028d:	99                   	cltd   
  80028e:	52                   	push   %edx
  80028f:	50                   	push   %eax
  800290:	53                   	push   %ebx
  800291:	56                   	push   %esi
  800292:	e8 15 ff ff ff       	call   8001ac <printnum>
	putch('m', putdat);
  800297:	83 c4 18             	add    $0x18,%esp
  80029a:	53                   	push   %ebx
  80029b:	6a 6d                	push   $0x6d
  80029d:	ff d6                	call   *%esi

}
  80029f:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002af:	83 f8 01             	cmp    $0x1,%eax
  8002b2:	7e 0f                	jle    8002c3 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002b4:	8b 01                	mov    (%ecx),%eax
  8002b6:	83 c0 08             	add    $0x8,%eax
  8002b9:	89 01                	mov    %eax,(%ecx)
  8002bb:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002be:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002c1:	eb 0f                	jmp    8002d2 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8002c3:	8b 01                	mov    (%ecx),%eax
  8002c5:	83 c0 04             	add    $0x4,%eax
  8002c8:	89 01                	mov    %eax,(%ecx)
  8002ca:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002dd:	83 f8 01             	cmp    $0x1,%eax
  8002e0:	7e 0f                	jle    8002f1 <getint+0x1d>
		return va_arg(*ap, long long);
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	83 c0 08             	add    $0x8,%eax
  8002e7:	89 02                	mov    %eax,(%edx)
  8002e9:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002ec:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002ef:	eb 0b                	jmp    8002fc <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	83 c0 04             	add    $0x4,%eax
  8002f6:	89 02                	mov    %eax,(%edx)
  8002f8:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002fb:	99                   	cltd   
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	57                   	push   %edi
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	83 ec 1c             	sub    $0x1c,%esp
  800307:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030a:	0f b6 13             	movzbl (%ebx),%edx
  80030d:	43                   	inc    %ebx
  80030e:	83 fa 25             	cmp    $0x25,%edx
  800311:	74 1e                	je     800331 <vprintfmt+0x33>
			if (ch == '\0')
  800313:	85 d2                	test   %edx,%edx
  800315:	0f 84 dc 02 00 00    	je     8005f7 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  80031b:	83 ec 08             	sub    $0x8,%esp
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	52                   	push   %edx
  800322:	ff 55 08             	call   *0x8(%ebp)
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	0f b6 13             	movzbl (%ebx),%edx
  80032b:	43                   	inc    %ebx
  80032c:	83 fa 25             	cmp    $0x25,%edx
  80032f:	75 e2                	jne    800313 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800331:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  800335:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  80033c:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800341:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  800346:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  80034d:	0f b6 13             	movzbl (%ebx),%edx
  800350:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  800353:	43                   	inc    %ebx
  800354:	83 f8 55             	cmp    $0x55,%eax
  800357:	0f 87 75 02 00 00    	ja     8005d2 <vprintfmt+0x2d4>
  80035d:	ff 24 85 84 15 80 00 	jmp    *0x801584(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800364:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800368:	eb e3                	jmp    80034d <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036a:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  80036e:	eb dd                	jmp    80034d <vprintfmt+0x4f>

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
  800370:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800375:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800378:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  80037c:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80037f:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800382:	83 f8 09             	cmp    $0x9,%eax
  800385:	77 27                	ja     8003ae <vprintfmt+0xb0>
  800387:	43                   	inc    %ebx
  800388:	eb eb                	jmp    800375 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038a:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800394:	eb 18                	jmp    8003ae <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  800396:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80039a:	79 b1                	jns    80034d <vprintfmt+0x4f>
				width = 0;
  80039c:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  8003a3:	eb a8                	jmp    80034d <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8003a5:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  8003ac:	eb 9f                	jmp    80034d <vprintfmt+0x4f>

			process_precision: if (width < 0)
  8003ae:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003b2:	79 99                	jns    80034d <vprintfmt+0x4f>
				width = precision, precision = -1;
  8003b4:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8003b7:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003bc:	eb 8f                	jmp    80034d <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003be:	41                   	inc    %ecx
			goto reswitch;
  8003bf:	eb 8c                	jmp    80034d <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	ff 75 0c             	pushl  0xc(%ebp)
  8003c7:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	ff 70 fc             	pushl  0xfffffffc(%eax)
  8003d1:	e9 c4 01 00 00       	jmp    80059a <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	79 02                	jns    8003e6 <vprintfmt+0xe8>
				err = -err;
  8003e4:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 08             	cmp    $0x8,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0xf8>
  8003eb:	8b 3c 85 60 15 80 00 	mov    0x801560(,%eax,4),%edi
  8003f2:	85 ff                	test   %edi,%edi
  8003f4:	75 08                	jne    8003fe <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	50                   	push   %eax
  8003f7:	68 31 15 80 00       	push   $0x801531
  8003fc:	eb 06                	jmp    800404 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8003fe:	57                   	push   %edi
  8003ff:	68 3a 15 80 00       	push   $0x80153a
  800404:	ff 75 0c             	pushl  0xc(%ebp)
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 f0 01 00 00       	call   8005ff <printfmt>
  80040f:	e9 89 01 00 00       	jmp    80059d <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800414:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  80041e:	85 ff                	test   %edi,%edi
  800420:	75 05                	jne    800427 <vprintfmt+0x129>
				p = "(null)";
  800422:	bf 3d 15 80 00       	mov    $0x80153d,%edi
			if (width > 0 && padc != '-')
  800427:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80042b:	7e 3b                	jle    800468 <vprintfmt+0x16a>
  80042d:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  800431:	74 35                	je     800468 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	56                   	push   %esi
  800437:	57                   	push   %edi
  800438:	e8 74 02 00 00       	call   8006b1 <strnlen>
  80043d:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  800440:	83 c4 10             	add    $0x10,%esp
  800443:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800447:	7e 1f                	jle    800468 <vprintfmt+0x16a>
  800449:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80044d:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	ff 75 0c             	pushl  0xc(%ebp)
  800456:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  800459:	ff 55 08             	call   *0x8(%ebp)
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800462:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800466:	7f e8                	jg     800450 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800468:	0f be 17             	movsbl (%edi),%edx
  80046b:	47                   	inc    %edi
  80046c:	85 d2                	test   %edx,%edx
  80046e:	74 3e                	je     8004ae <vprintfmt+0x1b0>
  800470:	85 f6                	test   %esi,%esi
  800472:	78 03                	js     800477 <vprintfmt+0x179>
  800474:	4e                   	dec    %esi
  800475:	78 37                	js     8004ae <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  800477:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  80047b:	74 12                	je     80048f <vprintfmt+0x191>
  80047d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800480:	83 f8 5e             	cmp    $0x5e,%eax
  800483:	76 0a                	jbe    80048f <vprintfmt+0x191>
					putch('?', putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	6a 3f                	push   $0x3f
  80048d:	eb 07                	jmp    800496 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	52                   	push   %edx
  800496:	ff 55 08             	call   *0x8(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80049f:	0f be 17             	movsbl (%edi),%edx
  8004a2:	47                   	inc    %edi
  8004a3:	85 d2                	test   %edx,%edx
  8004a5:	74 07                	je     8004ae <vprintfmt+0x1b0>
  8004a7:	85 f6                	test   %esi,%esi
  8004a9:	78 cc                	js     800477 <vprintfmt+0x179>
  8004ab:	4e                   	dec    %esi
  8004ac:	79 c9                	jns    800477 <vprintfmt+0x179>
			for (; width > 0; width--)
  8004ae:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004b2:	0f 8e 52 fe ff ff    	jle    80030a <vprintfmt+0xc>
				putch(' ', putdat);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	ff 75 0c             	pushl  0xc(%ebp)
  8004be:	6a 20                	push   $0x20
  8004c0:	ff 55 08             	call   *0x8(%ebp)
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004c9:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004cd:	7f e9                	jg     8004b8 <vprintfmt+0x1ba>
			break;
  8004cf:	e9 36 fe ff ff       	jmp    80030a <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	51                   	push   %ecx
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004db:	50                   	push   %eax
  8004dc:	e8 f3 fd ff ff       	call   8002d4 <getint>
  8004e1:	89 c6                	mov    %eax,%esi
  8004e3:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	79 15                	jns    800501 <vprintfmt+0x203>
				putch('-', putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	ff 75 0c             	pushl  0xc(%ebp)
  8004f2:	6a 2d                	push   $0x2d
  8004f4:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004f7:	f7 de                	neg    %esi
  8004f9:	83 d7 00             	adc    $0x0,%edi
  8004fc:	f7 df                	neg    %edi
  8004fe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800501:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800506:	eb 70                	jmp    800578 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	51                   	push   %ecx
  80050c:	8d 45 14             	lea    0x14(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	e8 91 fd ff ff       	call   8002a6 <getuint>
  800515:	89 c6                	mov    %eax,%esi
  800517:	89 d7                	mov    %edx,%edi
			base = 10;
  800519:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80051e:	eb 55                	jmp    800575 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	51                   	push   %ecx
  800524:	8d 45 14             	lea    0x14(%ebp),%eax
  800527:	50                   	push   %eax
  800528:	e8 79 fd ff ff       	call   8002a6 <getuint>
  80052d:	89 c6                	mov    %eax,%esi
  80052f:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  800531:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800536:	eb 3d                	jmp    800575 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	6a 30                	push   $0x30
  800540:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800543:	83 c4 08             	add    $0x8,%esp
  800546:	ff 75 0c             	pushl  0xc(%ebp)
  800549:	6a 78                	push   $0x78
  80054b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80054e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800558:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  80055d:	eb 11                	jmp    800570 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	51                   	push   %ecx
  800563:	8d 45 14             	lea    0x14(%ebp),%eax
  800566:	50                   	push   %eax
  800567:	e8 3a fd ff ff       	call   8002a6 <getuint>
  80056c:	89 c6                	mov    %eax,%esi
  80056e:	89 d7                	mov    %edx,%edi
			base = 16;
  800570:	ba 10 00 00 00       	mov    $0x10,%edx
  800575:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800578:	83 ec 04             	sub    $0x4,%esp
  80057b:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80057f:	50                   	push   %eax
  800580:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800583:	52                   	push   %edx
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	ff 75 0c             	pushl  0xc(%ebp)
  800589:	ff 75 08             	pushl  0x8(%ebp)
  80058c:	e8 1b fc ff ff       	call   8001ac <printnum>
			break;
  800591:	eb 37                	jmp    8005ca <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	ff 75 0c             	pushl  0xc(%ebp)
  800599:	52                   	push   %edx
  80059a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	e9 65 fd ff ff       	jmp    80030a <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	51                   	push   %ecx
  8005a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ac:	50                   	push   %eax
  8005ad:	e8 f4 fc ff ff       	call   8002a6 <getuint>
  8005b2:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  8005b4:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8005be:	56                   	push   %esi
  8005bf:	ff 75 0c             	pushl  0xc(%ebp)
  8005c2:	ff 75 08             	pushl  0x8(%ebp)
  8005c5:	e8 82 fc ff ff       	call   80024c <printcolor>
			break;
  8005ca:	83 c4 20             	add    $0x20,%esp
  8005cd:	e9 38 fd ff ff       	jmp    80030a <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	ff 75 0c             	pushl  0xc(%ebp)
  8005d8:	6a 25                	push   $0x25
  8005da:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005dd:	4b                   	dec    %ebx
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005e5:	0f 84 1f fd ff ff    	je     80030a <vprintfmt+0xc>
  8005eb:	4b                   	dec    %ebx
  8005ec:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005f0:	75 f9                	jne    8005eb <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005f2:	e9 13 fd ff ff       	jmp    80030a <vprintfmt+0xc>
		}
	}
}
  8005f7:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	c9                   	leave  
  8005fe:	c3                   	ret    

008005ff <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800605:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800608:	50                   	push   %eax
  800609:	ff 75 10             	pushl  0x10(%ebp)
  80060c:	ff 75 0c             	pushl  0xc(%ebp)
  80060f:	ff 75 08             	pushl  0x8(%ebp)
  800612:	e8 e7 fc ff ff       	call   8002fe <vprintfmt>
	va_end(ap);
}
  800617:	c9                   	leave  
  800618:	c3                   	ret    

00800619 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  800619:	55                   	push   %ebp
  80061a:	89 e5                	mov    %esp,%ebp
  80061c:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80061f:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800622:	8b 0a                	mov    (%edx),%ecx
  800624:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800627:	73 07                	jae    800630 <sprintputch+0x17>
		*b->buf++ = ch;
  800629:	8b 45 08             	mov    0x8(%ebp),%eax
  80062c:	88 01                	mov    %al,(%ecx)
  80062e:	ff 02                	incl   (%edx)
}
  800630:	c9                   	leave  
  800631:	c3                   	ret    

00800632 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	83 ec 18             	sub    $0x18,%esp
  800638:	8b 55 08             	mov    0x8(%ebp),%edx
  80063b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80063e:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800641:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800645:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800648:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  80064f:	85 d2                	test   %edx,%edx
  800651:	74 04                	je     800657 <vsnprintf+0x25>
  800653:	85 c9                	test   %ecx,%ecx
  800655:	7f 07                	jg     80065e <vsnprintf+0x2c>
		return -E_INVAL;
  800657:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80065c:	eb 1d                	jmp    80067b <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  80065e:	ff 75 14             	pushl  0x14(%ebp)
  800661:	ff 75 10             	pushl  0x10(%ebp)
  800664:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800667:	50                   	push   %eax
  800668:	68 19 06 80 00       	push   $0x800619
  80066d:	e8 8c fc ff ff       	call   8002fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800672:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800675:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800678:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  80067b:	c9                   	leave  
  80067c:	c3                   	ret    

0080067d <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800686:	50                   	push   %eax
  800687:	ff 75 10             	pushl  0x10(%ebp)
  80068a:	ff 75 0c             	pushl  0xc(%ebp)
  80068d:	ff 75 08             	pushl  0x8(%ebp)
  800690:	e8 9d ff ff ff       	call   800632 <vsnprintf>
	va_end(ap);

	return rc;
}
  800695:	c9                   	leave  
  800696:	c3                   	ret    
	...

00800698 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069e:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a3:	80 3a 00             	cmpb   $0x0,(%edx)
  8006a6:	74 07                	je     8006af <strlen+0x17>
		n++;
  8006a8:	40                   	inc    %eax
  8006a9:	42                   	inc    %edx
  8006aa:	80 3a 00             	cmpb   $0x0,(%edx)
  8006ad:	75 f9                	jne    8006a8 <strlen+0x10>
	return n;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	74 0f                	je     8006d2 <strnlen+0x21>
  8006c3:	80 39 00             	cmpb   $0x0,(%ecx)
  8006c6:	74 0a                	je     8006d2 <strnlen+0x21>
		n++;
  8006c8:	40                   	inc    %eax
  8006c9:	41                   	inc    %ecx
  8006ca:	4a                   	dec    %edx
  8006cb:	74 05                	je     8006d2 <strnlen+0x21>
  8006cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d0:	75 f6                	jne    8006c8 <strnlen+0x17>
	return n;
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	53                   	push   %ebx
  8006d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006db:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006de:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006e0:	8a 02                	mov    (%edx),%al
  8006e2:	42                   	inc    %edx
  8006e3:	88 01                	mov    %al,(%ecx)
  8006e5:	41                   	inc    %ecx
  8006e6:	84 c0                	test   %al,%al
  8006e8:	75 f6                	jne    8006e0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ea:	89 d8                	mov    %ebx,%eax
  8006ec:	5b                   	pop    %ebx
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	57                   	push   %edi
  8006f3:	56                   	push   %esi
  8006f4:	53                   	push   %ebx
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fb:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006fe:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	39 f3                	cmp    %esi,%ebx
  800707:	73 10                	jae    800719 <strncpy+0x2a>
		*dst++ = *src;
  800709:	8a 02                	mov    (%edx),%al
  80070b:	88 01                	mov    %al,(%ecx)
  80070d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80070e:	80 3a 00             	cmpb   $0x0,(%edx)
  800711:	74 01                	je     800714 <strncpy+0x25>
			src++;
  800713:	42                   	inc    %edx
  800714:	43                   	inc    %ebx
  800715:	39 f3                	cmp    %esi,%ebx
  800717:	72 f0                	jb     800709 <strncpy+0x1a>
	}
	return ret;
}
  800719:	89 f8                	mov    %edi,%eax
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	56                   	push   %esi
  800724:	53                   	push   %ebx
  800725:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80072e:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800730:	85 d2                	test   %edx,%edx
  800732:	74 19                	je     80074d <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800734:	4a                   	dec    %edx
  800735:	74 13                	je     80074a <strlcpy+0x2a>
  800737:	80 39 00             	cmpb   $0x0,(%ecx)
  80073a:	74 0e                	je     80074a <strlcpy+0x2a>
			*dst++ = *src++;
  80073c:	8a 01                	mov    (%ecx),%al
  80073e:	41                   	inc    %ecx
  80073f:	88 03                	mov    %al,(%ebx)
  800741:	43                   	inc    %ebx
  800742:	4a                   	dec    %edx
  800743:	74 05                	je     80074a <strlcpy+0x2a>
  800745:	80 39 00             	cmpb   $0x0,(%ecx)
  800748:	75 f2                	jne    80073c <strlcpy+0x1c>
		*dst = '\0';
  80074a:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  80074d:	89 d8                	mov    %ebx,%eax
  80074f:	29 f0                	sub    %esi,%eax
}
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 55 08             	mov    0x8(%ebp),%edx
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80075e:	80 3a 00             	cmpb   $0x0,(%edx)
  800761:	74 13                	je     800776 <strcmp+0x21>
  800763:	8a 02                	mov    (%edx),%al
  800765:	3a 01                	cmp    (%ecx),%al
  800767:	75 0d                	jne    800776 <strcmp+0x21>
		p++, q++;
  800769:	42                   	inc    %edx
  80076a:	41                   	inc    %ecx
  80076b:	80 3a 00             	cmpb   $0x0,(%edx)
  80076e:	74 06                	je     800776 <strcmp+0x21>
  800770:	8a 02                	mov    (%edx),%al
  800772:	3a 01                	cmp    (%ecx),%al
  800774:	74 f3                	je     800769 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800776:	0f b6 02             	movzbl (%edx),%eax
  800779:	0f b6 11             	movzbl (%ecx),%edx
  80077c:	29 d0                	sub    %edx,%eax
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 55 08             	mov    0x8(%ebp),%edx
  800787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	74 1f                	je     8007b0 <strncmp+0x30>
  800791:	80 3a 00             	cmpb   $0x0,(%edx)
  800794:	74 16                	je     8007ac <strncmp+0x2c>
  800796:	8a 02                	mov    (%edx),%al
  800798:	3a 03                	cmp    (%ebx),%al
  80079a:	75 10                	jne    8007ac <strncmp+0x2c>
		n--, p++, q++;
  80079c:	42                   	inc    %edx
  80079d:	43                   	inc    %ebx
  80079e:	49                   	dec    %ecx
  80079f:	74 0f                	je     8007b0 <strncmp+0x30>
  8007a1:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a4:	74 06                	je     8007ac <strncmp+0x2c>
  8007a6:	8a 02                	mov    (%edx),%al
  8007a8:	3a 03                	cmp    (%ebx),%al
  8007aa:	74 f0                	je     80079c <strncmp+0x1c>
	if (n == 0)
  8007ac:	85 c9                	test   %ecx,%ecx
  8007ae:	75 07                	jne    8007b7 <strncmp+0x37>
		return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	eb 0a                	jmp    8007c1 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b7:	0f b6 12             	movzbl (%edx),%edx
  8007ba:	0f b6 03             	movzbl (%ebx),%eax
  8007bd:	29 c2                	sub    %eax,%edx
  8007bf:	89 d0                	mov    %edx,%eax
}
  8007c1:	8b 1c 24             	mov    (%esp),%ebx
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cc:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007cf:	80 38 00             	cmpb   $0x0,(%eax)
  8007d2:	74 0a                	je     8007de <strchr+0x18>
		if (*s == c)
  8007d4:	38 10                	cmp    %dl,(%eax)
  8007d6:	74 0b                	je     8007e3 <strchr+0x1d>
  8007d8:	40                   	inc    %eax
  8007d9:	80 38 00             	cmpb   $0x0,(%eax)
  8007dc:	75 f6                	jne    8007d4 <strchr+0xe>
			return (char *) s;
	return 0;
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007ee:	80 38 00             	cmpb   $0x0,(%eax)
  8007f1:	74 0a                	je     8007fd <strfind+0x18>
		if (*s == c)
  8007f3:	38 10                	cmp    %dl,(%eax)
  8007f5:	74 06                	je     8007fd <strfind+0x18>
  8007f7:	40                   	inc    %eax
  8007f8:	80 38 00             	cmpb   $0x0,(%eax)
  8007fb:	75 f6                	jne    8007f3 <strfind+0xe>
			break;
	return (char *) s;
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	57                   	push   %edi
  800803:	8b 7d 08             	mov    0x8(%ebp),%edi
  800806:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800809:	89 f8                	mov    %edi,%eax
  80080b:	85 c9                	test   %ecx,%ecx
  80080d:	74 40                	je     80084f <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80080f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800815:	75 30                	jne    800847 <memset+0x48>
  800817:	f6 c1 03             	test   $0x3,%cl
  80081a:	75 2b                	jne    800847 <memset+0x48>
		c &= 0xFF;
  80081c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800823:	8b 45 0c             	mov    0xc(%ebp),%eax
  800826:	c1 e0 18             	shl    $0x18,%eax
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082c:	c1 e2 10             	shl    $0x10,%edx
  80082f:	09 d0                	or     %edx,%eax
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
  800834:	c1 e2 08             	shl    $0x8,%edx
  800837:	09 d0                	or     %edx,%eax
  800839:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80083c:	c1 e9 02             	shr    $0x2,%ecx
  80083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800842:	fc                   	cld    
  800843:	f3 ab                	repz stos %eax,%es:(%edi)
  800845:	eb 06                	jmp    80084d <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	fc                   	cld    
  80084b:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  80084d:	89 f8                	mov    %edi,%eax
}
  80084f:	8b 3c 24             	mov    (%esp),%edi
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	57                   	push   %edi
  800858:	56                   	push   %esi
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80085f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800862:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800864:	39 c6                	cmp    %eax,%esi
  800866:	73 33                	jae    80089b <memmove+0x47>
  800868:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  80086b:	39 c2                	cmp    %eax,%edx
  80086d:	76 2c                	jbe    80089b <memmove+0x47>
		s += n;
  80086f:	89 d6                	mov    %edx,%esi
		d += n;
  800871:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800874:	f6 c2 03             	test   $0x3,%dl
  800877:	75 1b                	jne    800894 <memmove+0x40>
  800879:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087f:	75 13                	jne    800894 <memmove+0x40>
  800881:	f6 c1 03             	test   $0x3,%cl
  800884:	75 0e                	jne    800894 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800886:	83 ef 04             	sub    $0x4,%edi
  800889:	83 ee 04             	sub    $0x4,%esi
  80088c:	c1 e9 02             	shr    $0x2,%ecx
  80088f:	fd                   	std    
  800890:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800892:	eb 27                	jmp    8008bb <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800894:	4f                   	dec    %edi
  800895:	4e                   	dec    %esi
  800896:	fd                   	std    
  800897:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800899:	eb 20                	jmp    8008bb <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a1:	75 15                	jne    8008b8 <memmove+0x64>
  8008a3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a9:	75 0d                	jne    8008b8 <memmove+0x64>
  8008ab:	f6 c1 03             	test   $0x3,%cl
  8008ae:	75 08                	jne    8008b8 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  8008b0:	c1 e9 02             	shr    $0x2,%ecx
  8008b3:	fc                   	cld    
  8008b4:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  8008b6:	eb 03                	jmp    8008bb <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b8:	fc                   	cld    
  8008b9:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008bb:	5e                   	pop    %esi
  8008bc:	5f                   	pop    %edi
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <memcpy>:

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
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008c5:	ff 75 10             	pushl  0x10(%ebp)
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 81 ff ff ff       	call   800854 <memmove>
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008df:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  8008e2:	89 d0                	mov    %edx,%eax
  8008e4:	4a                   	dec    %edx
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	74 1b                	je     800904 <memcmp+0x2f>
		if (*s1 != *s2)
  8008e9:	8a 01                	mov    (%ecx),%al
  8008eb:	3a 03                	cmp    (%ebx),%al
  8008ed:	74 0c                	je     8008fb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008ef:	0f b6 d0             	movzbl %al,%edx
  8008f2:	0f b6 03             	movzbl (%ebx),%eax
  8008f5:	29 c2                	sub    %eax,%edx
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	eb 0e                	jmp    800909 <memcmp+0x34>
		s1++, s2++;
  8008fb:	41                   	inc    %ecx
  8008fc:	43                   	inc    %ebx
  8008fd:	89 d0                	mov    %edx,%eax
  8008ff:	4a                   	dec    %edx
  800900:	85 c0                	test   %eax,%eax
  800902:	75 e5                	jne    8008e9 <memcmp+0x14>
	}

	return 0;
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800909:	5b                   	pop    %ebx
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800915:	89 c2                	mov    %eax,%edx
  800917:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	73 09                	jae    800927 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80091e:	38 08                	cmp    %cl,(%eax)
  800920:	74 05                	je     800927 <memfind+0x1b>
  800922:	40                   	inc    %eax
  800923:	39 d0                	cmp    %edx,%eax
  800925:	72 f7                	jb     80091e <memfind+0x12>
			break;
	return (void *) s;
}
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 55 08             	mov    0x8(%ebp),%edx
  800932:	8b 75 0c             	mov    0xc(%ebp),%esi
  800935:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800938:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  80093d:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800942:	80 3a 20             	cmpb   $0x20,(%edx)
  800945:	74 05                	je     80094c <strtol+0x23>
  800947:	80 3a 09             	cmpb   $0x9,(%edx)
  80094a:	75 0b                	jne    800957 <strtol+0x2e>
		s++;
  80094c:	42                   	inc    %edx
  80094d:	80 3a 20             	cmpb   $0x20,(%edx)
  800950:	74 fa                	je     80094c <strtol+0x23>
  800952:	80 3a 09             	cmpb   $0x9,(%edx)
  800955:	74 f5                	je     80094c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800957:	80 3a 2b             	cmpb   $0x2b,(%edx)
  80095a:	75 03                	jne    80095f <strtol+0x36>
		s++;
  80095c:	42                   	inc    %edx
  80095d:	eb 0b                	jmp    80096a <strtol+0x41>
	else if (*s == '-')
  80095f:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800962:	75 06                	jne    80096a <strtol+0x41>
		s++, neg = 1;
  800964:	42                   	inc    %edx
  800965:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80096a:	85 c9                	test   %ecx,%ecx
  80096c:	74 05                	je     800973 <strtol+0x4a>
  80096e:	83 f9 10             	cmp    $0x10,%ecx
  800971:	75 15                	jne    800988 <strtol+0x5f>
  800973:	80 3a 30             	cmpb   $0x30,(%edx)
  800976:	75 10                	jne    800988 <strtol+0x5f>
  800978:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80097c:	75 0a                	jne    800988 <strtol+0x5f>
		s += 2, base = 16;
  80097e:	83 c2 02             	add    $0x2,%edx
  800981:	b9 10 00 00 00       	mov    $0x10,%ecx
  800986:	eb 1a                	jmp    8009a2 <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800988:	85 c9                	test   %ecx,%ecx
  80098a:	75 16                	jne    8009a2 <strtol+0x79>
  80098c:	80 3a 30             	cmpb   $0x30,(%edx)
  80098f:	75 08                	jne    800999 <strtol+0x70>
		s++, base = 8;
  800991:	42                   	inc    %edx
  800992:	b9 08 00 00 00       	mov    $0x8,%ecx
  800997:	eb 09                	jmp    8009a2 <strtol+0x79>
	else if (base == 0)
  800999:	85 c9                	test   %ecx,%ecx
  80099b:	75 05                	jne    8009a2 <strtol+0x79>
		base = 10;
  80099d:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a2:	8a 02                	mov    (%edx),%al
  8009a4:	83 e8 30             	sub    $0x30,%eax
  8009a7:	3c 09                	cmp    $0x9,%al
  8009a9:	77 08                	ja     8009b3 <strtol+0x8a>
			dig = *s - '0';
  8009ab:	0f be 02             	movsbl (%edx),%eax
  8009ae:	83 e8 30             	sub    $0x30,%eax
  8009b1:	eb 20                	jmp    8009d3 <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  8009b3:	8a 02                	mov    (%edx),%al
  8009b5:	83 e8 61             	sub    $0x61,%eax
  8009b8:	3c 19                	cmp    $0x19,%al
  8009ba:	77 08                	ja     8009c4 <strtol+0x9b>
			dig = *s - 'a' + 10;
  8009bc:	0f be 02             	movsbl (%edx),%eax
  8009bf:	83 e8 57             	sub    $0x57,%eax
  8009c2:	eb 0f                	jmp    8009d3 <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  8009c4:	8a 02                	mov    (%edx),%al
  8009c6:	83 e8 41             	sub    $0x41,%eax
  8009c9:	3c 19                	cmp    $0x19,%al
  8009cb:	77 12                	ja     8009df <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009cd:	0f be 02             	movsbl (%edx),%eax
  8009d0:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009d3:	39 c8                	cmp    %ecx,%eax
  8009d5:	7d 08                	jge    8009df <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009d7:	42                   	inc    %edx
  8009d8:	0f af d9             	imul   %ecx,%ebx
  8009db:	01 c3                	add    %eax,%ebx
  8009dd:	eb c3                	jmp    8009a2 <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009df:	85 f6                	test   %esi,%esi
  8009e1:	74 02                	je     8009e5 <strtol+0xbc>
		*endptr = (char *) s;
  8009e3:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009e5:	89 d8                	mov    %ebx,%eax
  8009e7:	85 ff                	test   %edi,%edi
  8009e9:	74 02                	je     8009ed <strtol+0xc4>
  8009eb:	f7 d8                	neg    %eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	c9                   	leave  
  8009f1:	c3                   	ret    
	...

008009f4 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
  800a05:	89 f8                	mov    %edi,%eax
  800a07:	89 fb                	mov    %edi,%ebx
  800a09:	89 fe                	mov    %edi,%esi
  800a0b:	55                   	push   %ebp
  800a0c:	9c                   	pushf  
  800a0d:	56                   	push   %esi
  800a0e:	54                   	push   %esp
  800a0f:	5d                   	pop    %ebp
  800a10:	8d 35 18 0a 80 00    	lea    0x800a18,%esi
  800a16:	0f 34                	sysenter 
  800a18:	83 c4 04             	add    $0x4,%esp
  800a1b:	9d                   	popf   
  800a1c:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	b8 01 00 00 00       	mov    $0x1,%eax
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a32:	89 fa                	mov    %edi,%edx
  800a34:	89 f9                	mov    %edi,%ecx
  800a36:	89 fb                	mov    %edi,%ebx
  800a38:	89 fe                	mov    %edi,%esi
  800a3a:	55                   	push   %ebp
  800a3b:	9c                   	pushf  
  800a3c:	56                   	push   %esi
  800a3d:	54                   	push   %esp
  800a3e:	5d                   	pop    %ebp
  800a3f:	8d 35 47 0a 80 00    	lea    0x800a47,%esi
  800a45:	0f 34                	sysenter 
  800a47:	83 c4 04             	add    $0x4,%esp
  800a4a:	9d                   	popf   
  800a4b:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	c9                   	leave  
  800a50:	c3                   	ret    

00800a51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	83 ec 0c             	sub    $0xc,%esp
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a62:	bf 00 00 00 00       	mov    $0x0,%edi
  800a67:	89 f9                	mov    %edi,%ecx
  800a69:	89 fb                	mov    %edi,%ebx
  800a6b:	89 fe                	mov    %edi,%esi
  800a6d:	55                   	push   %ebp
  800a6e:	9c                   	pushf  
  800a6f:	56                   	push   %esi
  800a70:	54                   	push   %esp
  800a71:	5d                   	pop    %ebp
  800a72:	8d 35 7a 0a 80 00    	lea    0x800a7a,%esi
  800a78:	0f 34                	sysenter 
  800a7a:	83 c4 04             	add    $0x4,%esp
  800a7d:	9d                   	popf   
  800a7e:	5d                   	pop    %ebp
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	7e 17                	jle    800a9a <sys_env_destroy+0x49>
  800a83:	83 ec 0c             	sub    $0xc,%esp
  800a86:	50                   	push   %eax
  800a87:	6a 03                	push   $0x3
  800a89:	68 dc 16 80 00       	push   $0x8016dc
  800a8e:	6a 4c                	push   $0x4c
  800a90:	68 f9 16 80 00       	push   $0x8016f9
  800a95:	e8 9a 05 00 00       	call   801034 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a9a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	b8 02 00 00 00       	mov    $0x2,%eax
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab2:	89 fa                	mov    %edi,%edx
  800ab4:	89 f9                	mov    %edi,%ecx
  800ab6:	89 fb                	mov    %edi,%ebx
  800ab8:	89 fe                	mov    %edi,%esi
  800aba:	55                   	push   %ebp
  800abb:	9c                   	pushf  
  800abc:	56                   	push   %esi
  800abd:	54                   	push   %esp
  800abe:	5d                   	pop    %ebp
  800abf:	8d 35 c7 0a 80 00    	lea    0x800ac7,%esi
  800ac5:	0f 34                	sysenter 
  800ac7:	83 c4 04             	add    $0x4,%esp
  800aca:	9d                   	popf   
  800acb:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    

00800ad1 <sys_dump_env>:

int
sys_dump_env(void)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	b8 04 00 00 00       	mov    $0x4,%eax
  800adc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae1:	89 fa                	mov    %edi,%edx
  800ae3:	89 f9                	mov    %edi,%ecx
  800ae5:	89 fb                	mov    %edi,%ebx
  800ae7:	89 fe                	mov    %edi,%esi
  800ae9:	55                   	push   %ebp
  800aea:	9c                   	pushf  
  800aeb:	56                   	push   %esi
  800aec:	54                   	push   %esp
  800aed:	5d                   	pop    %ebp
  800aee:	8d 35 f6 0a 80 00    	lea    0x800af6,%esi
  800af4:	0f 34                	sysenter 
  800af6:	83 c4 04             	add    $0x4,%esp
  800af9:	9d                   	popf   
  800afa:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	c9                   	leave  
  800aff:	c3                   	ret    

00800b00 <sys_yield>:

void
sys_yield(void)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b0b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b10:	89 fa                	mov    %edi,%edx
  800b12:	89 f9                	mov    %edi,%ecx
  800b14:	89 fb                	mov    %edi,%ebx
  800b16:	89 fe                	mov    %edi,%esi
  800b18:	55                   	push   %ebp
  800b19:	9c                   	pushf  
  800b1a:	56                   	push   %esi
  800b1b:	54                   	push   %esp
  800b1c:	5d                   	pop    %ebp
  800b1d:	8d 35 25 0b 80 00    	lea    0x800b25,%esi
  800b23:	0f 34                	sysenter 
  800b25:	83 c4 04             	add    $0x4,%esp
  800b28:	9d                   	popf   
  800b29:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b41:	b8 05 00 00 00       	mov    $0x5,%eax
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4b:	89 fe                	mov    %edi,%esi
  800b4d:	55                   	push   %ebp
  800b4e:	9c                   	pushf  
  800b4f:	56                   	push   %esi
  800b50:	54                   	push   %esp
  800b51:	5d                   	pop    %ebp
  800b52:	8d 35 5a 0b 80 00    	lea    0x800b5a,%esi
  800b58:	0f 34                	sysenter 
  800b5a:	83 c4 04             	add    $0x4,%esp
  800b5d:	9d                   	popf   
  800b5e:	5d                   	pop    %ebp
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 17                	jle    800b7a <sys_page_alloc+0x4b>
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	6a 05                	push   $0x5
  800b69:	68 dc 16 80 00       	push   $0x8016dc
  800b6e:	6a 4c                	push   $0x4c
  800b70:	68 f9 16 80 00       	push   $0x8016f9
  800b75:	e8 ba 04 00 00       	call   801034 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b97:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9f:	55                   	push   %ebp
  800ba0:	9c                   	pushf  
  800ba1:	56                   	push   %esi
  800ba2:	54                   	push   %esp
  800ba3:	5d                   	pop    %ebp
  800ba4:	8d 35 ac 0b 80 00    	lea    0x800bac,%esi
  800baa:	0f 34                	sysenter 
  800bac:	83 c4 04             	add    $0x4,%esp
  800baf:	9d                   	popf   
  800bb0:	5d                   	pop    %ebp
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 17                	jle    800bcc <sys_page_map+0x4a>
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 06                	push   $0x6
  800bbb:	68 dc 16 80 00       	push   $0x8016dc
  800bc0:	6a 4c                	push   $0x4c
  800bc2:	68 f9 16 80 00       	push   $0x8016f9
  800bc7:	e8 68 04 00 00       	call   801034 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800bcc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    

00800bd4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	b8 07 00 00 00       	mov    $0x7,%eax
  800be8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bed:	89 fb                	mov    %edi,%ebx
  800bef:	89 fe                	mov    %edi,%esi
  800bf1:	55                   	push   %ebp
  800bf2:	9c                   	pushf  
  800bf3:	56                   	push   %esi
  800bf4:	54                   	push   %esp
  800bf5:	5d                   	pop    %ebp
  800bf6:	8d 35 fe 0b 80 00    	lea    0x800bfe,%esi
  800bfc:	0f 34                	sysenter 
  800bfe:	83 c4 04             	add    $0x4,%esp
  800c01:	9d                   	popf   
  800c02:	5d                   	pop    %ebp
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_page_unmap+0x4a>
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 07                	push   $0x7
  800c0d:	68 dc 16 80 00       	push   $0x8016dc
  800c12:	6a 4c                	push   $0x4c
  800c14:	68 f9 16 80 00       	push   $0x8016f9
  800c19:	e8 16 04 00 00       	call   801034 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3f:	89 fb                	mov    %edi,%ebx
  800c41:	89 fe                	mov    %edi,%esi
  800c43:	55                   	push   %ebp
  800c44:	9c                   	pushf  
  800c45:	56                   	push   %esi
  800c46:	54                   	push   %esp
  800c47:	5d                   	pop    %ebp
  800c48:	8d 35 50 0c 80 00    	lea    0x800c50,%esi
  800c4e:	0f 34                	sysenter 
  800c50:	83 c4 04             	add    $0x4,%esp
  800c53:	9d                   	popf   
  800c54:	5d                   	pop    %ebp
  800c55:	85 c0                	test   %eax,%eax
  800c57:	7e 17                	jle    800c70 <sys_env_set_status+0x4a>
  800c59:	83 ec 0c             	sub    $0xc,%esp
  800c5c:	50                   	push   %eax
  800c5d:	6a 09                	push   $0x9
  800c5f:	68 dc 16 80 00       	push   $0x8016dc
  800c64:	6a 4c                	push   $0x4c
  800c66:	68 f9 16 80 00       	push   $0x8016f9
  800c6b:	e8 c4 03 00 00       	call   801034 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c70:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	c9                   	leave  
  800c77:	c3                   	ret    

00800c78 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c91:	89 fb                	mov    %edi,%ebx
  800c93:	89 fe                	mov    %edi,%esi
  800c95:	55                   	push   %ebp
  800c96:	9c                   	pushf  
  800c97:	56                   	push   %esi
  800c98:	54                   	push   %esp
  800c99:	5d                   	pop    %ebp
  800c9a:	8d 35 a2 0c 80 00    	lea    0x800ca2,%esi
  800ca0:	0f 34                	sysenter 
  800ca2:	83 c4 04             	add    $0x4,%esp
  800ca5:	9d                   	popf   
  800ca6:	5d                   	pop    %ebp
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_env_set_trapframe+0x4a>
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 0a                	push   $0xa
  800cb1:	68 dc 16 80 00       	push   $0x8016dc
  800cb6:	6a 4c                	push   $0x4c
  800cb8:	68 f9 16 80 00       	push   $0x8016f9
  800cbd:	e8 72 03 00 00       	call   801034 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    

00800cca <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cde:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce3:	89 fb                	mov    %edi,%ebx
  800ce5:	89 fe                	mov    %edi,%esi
  800ce7:	55                   	push   %ebp
  800ce8:	9c                   	pushf  
  800ce9:	56                   	push   %esi
  800cea:	54                   	push   %esp
  800ceb:	5d                   	pop    %ebp
  800cec:	8d 35 f4 0c 80 00    	lea    0x800cf4,%esi
  800cf2:	0f 34                	sysenter 
  800cf4:	83 c4 04             	add    $0x4,%esp
  800cf7:	9d                   	popf   
  800cf8:	5d                   	pop    %ebp
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_env_set_pgfault_upcall+0x4a>
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 0b                	push   $0xb
  800d03:	68 dc 16 80 00       	push   $0x8016dc
  800d08:	6a 4c                	push   $0x4c
  800d0a:	68 f9 16 80 00       	push   $0x8016f9
  800d0f:	e8 20 03 00 00       	call   801034 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d14:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	c9                   	leave  
  800d1b:	c3                   	ret    

00800d1c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d33:	be 00 00 00 00       	mov    $0x0,%esi
  800d38:	55                   	push   %ebp
  800d39:	9c                   	pushf  
  800d3a:	56                   	push   %esi
  800d3b:	54                   	push   %esp
  800d3c:	5d                   	pop    %ebp
  800d3d:	8d 35 45 0d 80 00    	lea    0x800d45,%esi
  800d43:	0f 34                	sysenter 
  800d45:	83 c4 04             	add    $0x4,%esp
  800d48:	9d                   	popf   
  800d49:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d60:	bf 00 00 00 00       	mov    $0x0,%edi
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	89 fb                	mov    %edi,%ebx
  800d69:	89 fe                	mov    %edi,%esi
  800d6b:	55                   	push   %ebp
  800d6c:	9c                   	pushf  
  800d6d:	56                   	push   %esi
  800d6e:	54                   	push   %esp
  800d6f:	5d                   	pop    %ebp
  800d70:	8d 35 78 0d 80 00    	lea    0x800d78,%esi
  800d76:	0f 34                	sysenter 
  800d78:	83 c4 04             	add    $0x4,%esp
  800d7b:	9d                   	popf   
  800d7c:	5d                   	pop    %ebp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_ipc_recv+0x49>
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 0e                	push   $0xe
  800d87:	68 dc 16 80 00       	push   $0x8016dc
  800d8c:	6a 4c                	push   $0x4c
  800d8e:	68 f9 16 80 00       	push   $0x8016f9
  800d93:	e8 9c 02 00 00       	call   801034 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	c9                   	leave  
  800d9f:	c3                   	ret    

00800da0 <pgfault>:
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	53                   	push   %ebx
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
    void *addr = (void *) utf->utf_fault_va;
  800daa:	8b 1a                	mov    (%edx),%ebx
    uint32_t err = utf->utf_err;
  800dac:	8b 42 04             	mov    0x4(%edx),%eax
    int r;

    // Check that the faulting access was (1) a write, and (2) to a
    // copy-on-write page.  If not, panic.
    // Hint:
    //   Use the read-only page table mappings at vpt
    //   (see <inc/memlayout.h>).

    // LAB 4: Your code here.

    // Allocate a new page, map it at a temporary location (PFTEMP),
    // copy the data from the old page to the new page, then move the new
    // page to the old page's address.
    // Hint:
    //   You should make three system calls.
    //   No need to explicitly delete the old page's mapping.

    // LAB 4: Your code here.
    //cprintf("in the pgfault handler in fork\n");
    /*if((uint32_t)ROUNDDOWN(addr,PGSIZE) == USTACKTOP-PGSIZE) {
        cprintf("user stack!!!!!!!!!!\n");
    }*/
    if (err & FEC_WR) {
  800daf:	a8 02                	test   $0x2,%al
  800db1:	0f 84 ae 00 00 00    	je     800e65 <pgfault+0xc5>
        //cprintf("it's caused by fault write\n");
        if (vpt[PPN(addr)] & PTE_COW) {//first
  800db7:	89 d8                	mov    %ebx,%eax
  800db9:	c1 e8 0c             	shr    $0xc,%eax
  800dbc:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  800dc3:	f6 c4 08             	test   $0x8,%ah
  800dc6:	0f 84 85 00 00 00    	je     800e51 <pgfault+0xb1>
            //ok it's caused by copy on write
            //cprintf("it's caused by copy on write\n");
            if ((r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W))) {//wrong not ROUNDDOWN(addr,PGSIZE)
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	6a 07                	push   $0x7
  800dd1:	68 00 f0 7f 00       	push   $0x7ff000
  800dd6:	6a 00                	push   $0x0
  800dd8:	e8 52 fd ff ff       	call   800b2f <sys_page_alloc>
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	74 0a                	je     800dee <pgfault+0x4e>
                panic("pgfault->sys_page_alloc:%e",r);
  800de4:	50                   	push   %eax
  800de5:	68 07 17 80 00       	push   $0x801707
  800dea:	6a 2f                	push   $0x2f
  800dec:	eb 6d                	jmp    800e5b <pgfault+0xbb>
            }
            //cprintf("before copy data from ROUNDDOWN(%x,PGSIZE) to PFTEMP\n",addr);
            memcpy(PFTEMP,ROUNDDOWN(addr,PGSIZE),PGSIZE);
  800dee:	89 d8                	mov    %ebx,%eax
  800df0:	25 ff 0f 00 00       	and    $0xfff,%eax
  800df5:	29 c3                	sub    %eax,%ebx
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	68 00 10 00 00       	push   $0x1000
  800dff:	53                   	push   %ebx
  800e00:	68 00 f0 7f 00       	push   $0x7ff000
  800e05:	e8 b5 fa ff ff       	call   8008bf <memcpy>
            //cprintf("before map the PFTEMP to the ROUNDDOWN(%x,PGSIZE)\n",addr);
            if ((r= sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_P|PTE_U|PTE_W))) {/*seemly than PTE_USER is wrong*/
  800e0a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e11:	53                   	push   %ebx
  800e12:	6a 00                	push   $0x0
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 62 fd ff ff       	call   800b82 <sys_page_map>
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	74 0a                	je     800e31 <pgfault+0x91>
                panic("pgfault->sys_page_map:%e",r);
  800e27:	50                   	push   %eax
  800e28:	68 22 17 80 00       	push   $0x801722
  800e2d:	6a 35                	push   $0x35
  800e2f:	eb 2a                	jmp    800e5b <pgfault+0xbb>
            }
            //cprintf("before unmap the PFTEMP\n");
            if ((r = sys_page_unmap(0,PFTEMP))) {
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	68 00 f0 7f 00       	push   $0x7ff000
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 94 fd ff ff       	call   800bd4 <sys_page_unmap>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	74 37                	je     800e7e <pgfault+0xde>
                panic("pgfault->sys_page_unmap:%e",r);
  800e47:	50                   	push   %eax
  800e48:	68 3b 17 80 00       	push   $0x80173b
  800e4d:	6a 39                	push   $0x39
  800e4f:	eb 0a                	jmp    800e5b <pgfault+0xbb>
            }
            //cprintf("after unmap the PFTEMP\n");
        } else {
            panic("the fault write page is not copy on write\n");
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	68 bc 17 80 00       	push   $0x8017bc
  800e59:	6a 3d                	push   $0x3d
  800e5b:	68 56 17 80 00       	push   $0x801756
  800e60:	e8 cf 01 00 00       	call   801034 <_panic>
        }
    } else {
        panic("the fault page isn't fault write,%eip is %x,va is %x,errcode is %d",utf->utf_eip,addr,err);
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	50                   	push   %eax
  800e69:	53                   	push   %ebx
  800e6a:	ff 72 28             	pushl  0x28(%edx)
  800e6d:	68 e8 17 80 00       	push   $0x8017e8
  800e72:	6a 40                	push   $0x40
  800e74:	68 56 17 80 00       	push   $0x801756
  800e79:	e8 b6 01 00 00       	call   801034 <_panic>
    }
    //it should be ok
    //panic("pgfault not implemented");
}
  800e7e:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <duppage>:

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why mark ours copy-on-write again
// if it was already copy-on-write?)//////why?
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
    int r;
    void *addr;
    pte_t pte;
    pte = vpt[pn];//current env's page table entry
  800e8e:	8b 14 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%edx
    addr = (void *) (pn*PGSIZE);//virtual address
  800e95:	89 c6                	mov    %eax,%esi
  800e97:	c1 e6 0c             	shl    $0xc,%esi
    uint32_t perm = pte & PTE_USER;
  800e9a:	89 d3                	mov    %edx,%ebx
  800e9c:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
    /*if((uint32_t)addr == USTACKTOP-PGSIZE) {
        cprintf("duppage user stack!!!!!!!!!!\n");
    }*/
    if ((pte & PTE_COW)|(pte & PTE_W)) {
  800ea2:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ea8:	74 26                	je     800ed0 <duppage+0x4d>
        /*the page need copy on write*/
        perm |= PTE_COW;
  800eaa:	80 cf 08             	or     $0x8,%bh
        perm &= ~PTE_W;
  800ead:	83 e3 fd             	and    $0xfffffffd,%ebx
        if ((r = sys_page_map(0,addr,envid,addr,perm))) {
  800eb0:	83 ec 0c             	sub    $0xc,%esp
  800eb3:	53                   	push   %ebx
  800eb4:	56                   	push   %esi
  800eb5:	51                   	push   %ecx
  800eb6:	56                   	push   %esi
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 c4 fc ff ff       	call   800b82 <sys_page_map>
  800ebe:	83 c4 20             	add    $0x20,%esp
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	75 19                	jne    800ee0 <duppage+0x5d>
            return r;
        }
        return sys_page_map(0,addr,0,addr,perm);//also remap it
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	53                   	push   %ebx
  800ecb:	56                   	push   %esi
  800ecc:	6a 00                	push   $0x0
  800ece:	eb 06                	jmp    800ed6 <duppage+0x53>
        /*now the page can't be writen*/
    }
    // LAB 4: Your code here.
    //panic("duppage not implemented");
    //may be wrong, it's not writable so just map it,although it may be no safe
    return sys_page_map(0, addr, envid, addr, perm);
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	53                   	push   %ebx
  800ed4:	56                   	push   %esi
  800ed5:	51                   	push   %ecx
  800ed6:	56                   	push   %esi
  800ed7:	6a 00                	push   $0x0
  800ed9:	e8 a4 fc ff ff       	call   800b82 <sys_page_map>
  800ede:	89 c2                	mov    %eax,%edx
}
  800ee0:	89 d0                	mov    %edx,%eax
  800ee2:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <fork>:

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "env" and the user exception stack in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 18             	sub    $0x18,%esp
    // LAB 4: Your code here.
    int pde_index;
    int pte_index;
    envid_t envid;
    unsigned pn = 0;
  800ef2:	be 00 00 00 00       	mov    $0x0,%esi
    int r;
    set_pgfault_handler(pgfault);/*set the pgfault handler for the father*/
  800ef7:	68 a0 0d 80 00       	push   $0x800da0
  800efc:	e8 93 01 00 00       	call   801094 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
  800f01:	83 c4 10             	add    $0x10,%esp
	envid_t ret;
    
	// Provide assembly code to call the system call(sys_exofork)
	// You can choose "int"  
	// "int" instruction is easier than sysenter here
    // If you use int instruction you may code like this :-)
    // envid_t ret;
	// __asm __volatile("int %2"
	// 	 : "=a" (return value)
	//	 : "a"  (syscall number),
	//	   "i"  (T_SYSCALL) //T_SYSCALL the syscall trap number, in jos is 48
	//  );
	
	
	// LAB 4: Your code here.
	//panic("sys_exofork(lib.h/inc) not implemented");
    asm volatile("int %2\n\t"
  800f04:	ba 08 00 00 00       	mov    $0x8,%edx
  800f09:	89 d0                	mov    %edx,%eax
  800f0b:	cd 30                	int    $0x30
  800f0d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
    //cprintf("in fork before sys_exofork\n");
    envid = sys_exofork();//it use int to syscall
    //the child will come back use iret
    //cprintf("after fork->sys_exofork return:%d\n",envid);
    if (envid < 0) {
  800f10:	89 c2                	mov    %eax,%edx
  800f12:	85 c0                	test   %eax,%eax
  800f14:	0f 88 f4 00 00 00    	js     80100e <fork+0x125>
        /*err in the exofork*/
        return envid;
    }
    if (envid == 0) {
        /*if it's child,just return, the initial of it done by parent env*/
        //cprintf("i'm child,return\n");
        env = &envs[ENVX(sys_getenvid())];
        //cprintf("in fork child env's padding:%d",env->env_tf.tf_padding1);
        return 0;
    }
    /*it's parent*/
    //cprintf("before parent map for child\n");
    for (pde_index = 0;pde_index<VPD(UTOP);pde_index++) {
  800f1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f1f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800f23:	75 21                	jne    800f46 <fork+0x5d>
  800f25:	e8 78 fb ff ff       	call   800aa2 <sys_getenvid>
  800f2a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f2f:	c1 e0 07             	shl    $0x7,%eax
  800f32:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f37:	a3 04 20 80 00       	mov    %eax,0x802004
  800f3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f41:	e9 c8 00 00 00       	jmp    80100e <fork+0x125>
        /*upper than utop,such map has already done*/
        if (vpd[pde_index]) {
  800f46:	8b 04 bd 00 d0 7b ef 	mov    0xef7bd000(,%edi,4),%eax
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	74 48                	je     800f99 <fork+0xb0>
            for (pte_index = 0;pte_index < NPTENTRIES;pte_index++) {
  800f51:	bb 00 00 00 00       	mov    $0x0,%ebx
                if (vpt[pn]&& (pn*PGSIZE) != (UXSTACKTOP - PGSIZE)) {
  800f56:	8b 04 b5 00 00 40 ef 	mov    0xef400000(,%esi,4),%eax
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	74 2c                	je     800f8d <fork+0xa4>
  800f61:	89 f0                	mov    %esi,%eax
  800f63:	c1 e0 0c             	shl    $0xc,%eax
  800f66:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  800f6b:	74 20                	je     800f8d <fork+0xa4>
                    /*if the pte is not null and it's not pgfault stack*/
                    if ((r = duppage(envid,pn)))
  800f6d:	83 ec 08             	sub    $0x8,%esp
  800f70:	56                   	push   %esi
  800f71:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800f74:	e8 0a ff ff ff       	call   800e83 <duppage>
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	74 0d                	je     800f8d <fork+0xa4>
                        panic("in duppage:%e",r);
  800f80:	50                   	push   %eax
  800f81:	68 61 17 80 00       	push   $0x801761
  800f86:	68 9e 00 00 00       	push   $0x9e
  800f8b:	eb 77                	jmp    801004 <fork+0x11b>
                }
                pn++;
  800f8d:	46                   	inc    %esi
  800f8e:	43                   	inc    %ebx
  800f8f:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  800f95:	7e bf                	jle    800f56 <fork+0x6d>
  800f97:	eb 06                	jmp    800f9f <fork+0xb6>
            }
        } else {
            pn += NPTENTRIES;/*skip 1024 virtual page*/
  800f99:	81 c6 00 04 00 00    	add    $0x400,%esi
  800f9f:	47                   	inc    %edi
  800fa0:	81 ff ba 03 00 00    	cmp    $0x3ba,%edi
  800fa6:	76 9e                	jbe    800f46 <fork+0x5d>
        }
    }
    //cprintf("after parent map for child\n");
    /*set the pgfault handler for child*/
    //cprintf("after set the pgfault handler\n");
    if ((r = sys_page_alloc(envid,(void *)(UXSTACKTOP - PGSIZE),PTE_P|PTE_U|PTE_W))) {
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	6a 07                	push   $0x7
  800fad:	68 00 f0 bf ee       	push   $0xeebff000
  800fb2:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800fb5:	e8 75 fb ff ff       	call   800b2f <sys_page_alloc>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	74 0d                	je     800fce <fork+0xe5>
        panic("in fork->sys_page_alloc %e",r);
  800fc1:	50                   	push   %eax
  800fc2:	68 6f 17 80 00       	push   $0x80176f
  800fc7:	68 aa 00 00 00       	push   $0xaa
  800fcc:	eb 36                	jmp    801004 <fork+0x11b>
    }
    //cprintf("before set the pgfault up call for child\n");
    //cprintf("env->env_pgfault_upcall:%x\n",env->env_pgfault_upcall);
    sys_env_set_pgfault_upcall(envid,env->env_pgfault_upcall);
  800fce:	83 ec 08             	sub    $0x8,%esp
  800fd1:	a1 04 20 80 00       	mov    0x802004,%eax
  800fd6:	8b 40 68             	mov    0x68(%eax),%eax
  800fd9:	50                   	push   %eax
  800fda:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800fdd:	e8 e8 fc ff ff       	call   800cca <sys_env_set_pgfault_upcall>
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE))) {
  800fe2:	83 c4 08             	add    $0x8,%esp
  800fe5:	6a 01                	push   $0x1
  800fe7:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800fea:	e8 37 fc ff ff       	call   800c26 <sys_env_set_status>
  800fef:	83 c4 10             	add    $0x10,%esp
        panic("in fork->sys_env_status %e",r);
    }
    //cprintf("fork ok %d\n",sys_getenvid());
    return envid;
  800ff2:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	74 15                	je     80100e <fork+0x125>
  800ff9:	50                   	push   %eax
  800ffa:	68 8a 17 80 00       	push   $0x80178a
  800fff:	68 b0 00 00 00       	push   $0xb0
  801004:	68 56 17 80 00       	push   $0x801756
  801009:	e8 26 00 00 00       	call   801034 <_panic>
    //panic("fork not implemented");
}
  80100e:	89 d0                	mov    %edx,%eax
  801010:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	c9                   	leave  
  801017:	c3                   	ret    

00801018 <sfork>:

// Challenge!
int
sfork(void)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 0c             	sub    $0xc,%esp
    panic("sfork not implemented");
  80101e:	68 a5 17 80 00       	push   $0x8017a5
  801023:	68 bb 00 00 00       	push   $0xbb
  801028:	68 56 17 80 00       	push   $0x801756
  80102d:	e8 02 00 00 00       	call   801034 <_panic>
	...

00801034 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	53                   	push   %ebx
  801038:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  80103b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80103e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801045:	74 16                	je     80105d <_panic+0x29>
		cprintf("%s: ", argv0);
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	ff 35 08 20 80 00    	pushl  0x802008
  801050:	68 2b 18 80 00       	push   $0x80182b
  801055:	e8 3e f1 ff ff       	call   800198 <cprintf>
  80105a:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80105d:	ff 75 0c             	pushl  0xc(%ebp)
  801060:	ff 75 08             	pushl  0x8(%ebp)
  801063:	ff 35 00 20 80 00    	pushl  0x802000
  801069:	68 30 18 80 00       	push   $0x801830
  80106e:	e8 25 f1 ff ff       	call   800198 <cprintf>
	vcprintf(fmt, ap);
  801073:	83 c4 08             	add    $0x8,%esp
  801076:	53                   	push   %ebx
  801077:	ff 75 10             	pushl  0x10(%ebp)
  80107a:	e8 c8 f0 ff ff       	call   800147 <vcprintf>
	cprintf("\n");
  80107f:	c7 04 24 74 14 80 00 	movl   $0x801474,(%esp)
  801086:	e8 0d f1 ff ff       	call   800198 <cprintf>

	// Cause a breakpoint exception
	while (1)
  80108b:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80108e:	cc                   	int3   
  80108f:	eb fd                	jmp    80108e <_panic+0x5a>
}
  801091:	00 00                	add    %al,(%eax)
	...

00801094 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == NULL) {
  80109a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8010a1:	75 2a                	jne    8010cd <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
        //cprintf("i'm in set pgfault_handler,before alloc\n");
        if(sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W)) {//maybe not PTE_USER
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	6a 07                	push   $0x7
  8010a8:	68 00 f0 bf ee       	push   $0xeebff000
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 7b fa ff ff       	call   800b2f <sys_page_alloc>
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	75 1a                	jne    8010d5 <set_pgfault_handler+0x41>
            return;
        }
        //cprintf("i'm in set pgfault_handler,after alloc\n");
        sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	68 d8 10 80 00       	push   $0x8010d8
  8010c3:	6a 00                	push   $0x0
  8010c5:	e8 00 fc ff ff       	call   800cca <sys_env_set_pgfault_upcall>
  8010ca:	83 c4 10             	add    $0x10,%esp
        //cprintf("here in set pgfault handler\n");
		//panic("set_pgfault_handler not implemented");
	}
	// Save handler pointer for assembly to call.
    //cprintf("handler %x;pgfault_handler address %x,upcall address %x,upcall points %x\n",handler,&_pgfault_handler,&_pgfault_upcall,_pgfault_upcall);
	_pgfault_handler = handler;
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	a3 0c 20 80 00       	mov    %eax,0x80200c
    //cprintf("here\n");
    //it should be ok
}
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    
	...

008010d8 <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010d9:	a1 0c 20 80 00       	mov    0x80200c,%eax
    //xchg %bx, %bx
	call *%eax
  8010de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010e0:	83 c4 04             	add    $0x4,%esp
	
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
  8010e3:	83 c4 08             	add    $0x8,%esp
/*    //it's wrong
    movl %esp,%eax//old esp is stored in the upper 40byte of the current esp
    addl $40,%eax //eax point to the old esp
    //xchg %bx, %bx
    movl %eax,%edx
    addl $4,%edx //then edx points to the retaddr
    movl %edx,(%eax)//set the esp in the stack to the 
*/   
    movl 32(%esp),%edx //edx is the old eip 
  8010e6:	8b 54 24 20          	mov    0x20(%esp),%edx
    movl 40(%esp),%eax //eax is the old esp
  8010ea:	8b 44 24 28          	mov    0x28(%esp),%eax
    subl $4, %eax // then eax point to the place where the return address will be store
  8010ee:	83 e8 04             	sub    $0x4,%eax
    movl %edx,(%eax)//the old eip is stored in the return address place.maybe this will cause recursive copyonwrite pagefault
  8010f1:	89 10                	mov    %edx,(%eax)
    movl %eax,40(%esp)//then the value of the esp place in the utf points to the old eip
  8010f3:	89 44 24 28          	mov    %eax,0x28(%esp)
    //because the register will be restored, so don't care the eax and edx
	// Restore the trap-time registers.
	// LAB 4: Your code here.
    popal
  8010f7:	61                   	popa   
	// Restore eflags from the stack.
	// LAB 4: Your code here.
    addl $4,%esp
  8010f8:	83 c4 04             	add    $0x4,%esp
    popfl
  8010fb:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    //xchg %bx,%bx
    popl %esp//then esp points to the retaddr
  8010fc:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    //xchg %bx, %bx
    ret
  8010fd:	c3                   	ret    
	...

00801100 <__udivdi3>:
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	56                   	push   %esi
  801105:	83 ec 20             	sub    $0x20,%esp
  801108:	8b 55 14             	mov    0x14(%ebp),%edx
  80110b:	8b 75 08             	mov    0x8(%ebp),%esi
  80110e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801111:	8b 45 10             	mov    0x10(%ebp),%eax
  801114:	85 d2                	test   %edx,%edx
  801116:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  801119:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  801120:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  801127:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80112a:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  80112d:	89 fe                	mov    %edi,%esi
  80112f:	75 5b                	jne    80118c <__udivdi3+0x8c>
  801131:	39 f8                	cmp    %edi,%eax
  801133:	76 2b                	jbe    801160 <__udivdi3+0x60>
  801135:	89 fa                	mov    %edi,%edx
  801137:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80113a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80113d:	89 c7                	mov    %eax,%edi
  80113f:	90                   	nop    
  801140:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  801147:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80114a:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  80114d:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  801150:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801153:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801156:	83 c4 20             	add    $0x20,%esp
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	c9                   	leave  
  80115c:	c3                   	ret    
  80115d:	8d 76 00             	lea    0x0(%esi),%esi
  801160:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  801163:	85 c0                	test   %eax,%eax
  801165:	75 0e                	jne    801175 <__udivdi3+0x75>
  801167:	b8 01 00 00 00       	mov    $0x1,%eax
  80116c:	31 c9                	xor    %ecx,%ecx
  80116e:	31 d2                	xor    %edx,%edx
  801170:	f7 f1                	div    %ecx
  801172:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  801175:	89 f0                	mov    %esi,%eax
  801177:	31 d2                	xor    %edx,%edx
  801179:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80117c:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  80117f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  801182:	f7 75 dc             	divl   0xffffffdc(%ebp)
  801185:	89 c7                	mov    %eax,%edi
  801187:	eb be                	jmp    801147 <__udivdi3+0x47>
  801189:	8d 76 00             	lea    0x0(%esi),%esi
  80118c:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  80118f:	76 07                	jbe    801198 <__udivdi3+0x98>
  801191:	31 ff                	xor    %edi,%edi
  801193:	eb ab                	jmp    801140 <__udivdi3+0x40>
  801195:	8d 76 00             	lea    0x0(%esi),%esi
  801198:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  80119c:	89 c7                	mov    %eax,%edi
  80119e:	83 f7 1f             	xor    $0x1f,%edi
  8011a1:	75 19                	jne    8011bc <__udivdi3+0xbc>
  8011a3:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  8011a6:	77 0a                	ja     8011b2 <__udivdi3+0xb2>
  8011a8:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8011ab:	31 ff                	xor    %edi,%edi
  8011ad:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  8011b0:	72 8e                	jb     801140 <__udivdi3+0x40>
  8011b2:	bf 01 00 00 00       	mov    $0x1,%edi
  8011b7:	eb 87                	jmp    801140 <__udivdi3+0x40>
  8011b9:	8d 76 00             	lea    0x0(%esi),%esi
  8011bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8011c1:	29 f8                	sub    %edi,%eax
  8011c3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8011c6:	89 f9                	mov    %edi,%ecx
  8011c8:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8011cb:	d3 e2                	shl    %cl,%edx
  8011cd:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  8011d0:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  8011d3:	d3 e8                	shr    %cl,%eax
  8011d5:	09 c2                	or     %eax,%edx
  8011d7:	89 f9                	mov    %edi,%ecx
  8011d9:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  8011dc:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  8011df:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  8011e2:	89 f2                	mov    %esi,%edx
  8011e4:	d3 ea                	shr    %cl,%edx
  8011e6:	89 f9                	mov    %edi,%ecx
  8011e8:	d3 e6                	shl    %cl,%esi
  8011ea:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8011ed:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  8011f0:	d3 e8                	shr    %cl,%eax
  8011f2:	09 c6                	or     %eax,%esi
  8011f4:	89 f9                	mov    %edi,%ecx
  8011f6:	89 f0                	mov    %esi,%eax
  8011f8:	f7 75 ec             	divl   0xffffffec(%ebp)
  8011fb:	89 d6                	mov    %edx,%esi
  8011fd:	89 c7                	mov    %eax,%edi
  8011ff:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  801202:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  801205:	f7 e7                	mul    %edi
  801207:	39 f2                	cmp    %esi,%edx
  801209:	77 0f                	ja     80121a <__udivdi3+0x11a>
  80120b:	0f 85 2f ff ff ff    	jne    801140 <__udivdi3+0x40>
  801211:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  801214:	0f 86 26 ff ff ff    	jbe    801140 <__udivdi3+0x40>
  80121a:	4f                   	dec    %edi
  80121b:	e9 20 ff ff ff       	jmp    801140 <__udivdi3+0x40>

00801220 <__umoddi3>:
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	83 ec 30             	sub    $0x30,%esp
  801228:	8b 55 14             	mov    0x14(%ebp),%edx
  80122b:	8b 75 08             	mov    0x8(%ebp),%esi
  80122e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801231:	8b 45 10             	mov    0x10(%ebp),%eax
  801234:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  801237:	85 d2                	test   %edx,%edx
  801239:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  801240:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  801247:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  80124a:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80124d:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801250:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  801253:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801256:	75 68                	jne    8012c0 <__umoddi3+0xa0>
  801258:	39 f8                	cmp    %edi,%eax
  80125a:	76 3c                	jbe    801298 <__umoddi3+0x78>
  80125c:	89 f0                	mov    %esi,%eax
  80125e:	89 fa                	mov    %edi,%edx
  801260:	f7 75 cc             	divl   0xffffffcc(%ebp)
  801263:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  801266:	85 c9                	test   %ecx,%ecx
  801268:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  80126b:	74 1b                	je     801288 <__umoddi3+0x68>
  80126d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801270:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801273:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  80127a:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80127d:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  801280:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  801283:	89 10                	mov    %edx,(%eax)
  801285:	89 48 04             	mov    %ecx,0x4(%eax)
  801288:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80128b:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80128e:	83 c4 30             	add    $0x30,%esp
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	c9                   	leave  
  801294:	c3                   	ret    
  801295:	8d 76 00             	lea    0x0(%esi),%esi
  801298:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  80129b:	85 f6                	test   %esi,%esi
  80129d:	75 0d                	jne    8012ac <__umoddi3+0x8c>
  80129f:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a4:	31 d2                	xor    %edx,%edx
  8012a6:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8012a9:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8012ac:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8012af:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8012b2:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8012b5:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8012b8:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8012bb:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8012be:	eb a3                	jmp    801263 <__umoddi3+0x43>
  8012c0:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8012c3:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  8012c6:	76 14                	jbe    8012dc <__umoddi3+0xbc>
  8012c8:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  8012cb:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8012ce:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8012d1:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  8012d4:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8012d7:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8012da:	eb ac                	jmp    801288 <__umoddi3+0x68>
  8012dc:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  8012e0:	89 c6                	mov    %eax,%esi
  8012e2:	83 f6 1f             	xor    $0x1f,%esi
  8012e5:	75 4d                	jne    801334 <__umoddi3+0x114>
  8012e7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8012ea:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  8012ed:	77 08                	ja     8012f7 <__umoddi3+0xd7>
  8012ef:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8012f2:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  8012f5:	72 12                	jb     801309 <__umoddi3+0xe9>
  8012f7:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8012fa:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8012fd:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  801300:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  801303:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801306:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801309:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80130c:	85 d2                	test   %edx,%edx
  80130e:	0f 84 74 ff ff ff    	je     801288 <__umoddi3+0x68>
  801314:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801317:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80131a:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  80131d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  801320:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  801323:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801326:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801329:	89 01                	mov    %eax,(%ecx)
  80132b:	89 51 04             	mov    %edx,0x4(%ecx)
  80132e:	e9 55 ff ff ff       	jmp    801288 <__umoddi3+0x68>
  801333:	90                   	nop    
  801334:	b8 20 00 00 00       	mov    $0x20,%eax
  801339:	29 f0                	sub    %esi,%eax
  80133b:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80133e:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801341:	89 f1                	mov    %esi,%ecx
  801343:	d3 e2                	shl    %cl,%edx
  801345:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  801348:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80134b:	d3 e8                	shr    %cl,%eax
  80134d:	09 c2                	or     %eax,%edx
  80134f:	89 f1                	mov    %esi,%ecx
  801351:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801354:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801357:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80135a:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80135d:	d3 ea                	shr    %cl,%edx
  80135f:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  801362:	89 f1                	mov    %esi,%ecx
  801364:	d3 e7                	shl    %cl,%edi
  801366:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801369:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80136c:	d3 e8                	shr    %cl,%eax
  80136e:	09 c7                	or     %eax,%edi
  801370:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801373:	89 f8                	mov    %edi,%eax
  801375:	89 f1                	mov    %esi,%ecx
  801377:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80137a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  80137d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801380:	f7 65 cc             	mull   0xffffffcc(%ebp)
  801383:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801386:	89 c7                	mov    %eax,%edi
  801388:	77 3f                	ja     8013c9 <__umoddi3+0x1a9>
  80138a:	74 38                	je     8013c4 <__umoddi3+0x1a4>
  80138c:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80138f:	85 c0                	test   %eax,%eax
  801391:	0f 84 f1 fe ff ff    	je     801288 <__umoddi3+0x68>
  801397:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  80139a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80139d:	29 f8                	sub    %edi,%eax
  80139f:	19 d1                	sbb    %edx,%ecx
  8013a1:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8013a4:	89 ca                	mov    %ecx,%edx
  8013a6:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8013a9:	d3 e2                	shl    %cl,%edx
  8013ab:	89 f1                	mov    %esi,%ecx
  8013ad:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8013b0:	d3 e8                	shr    %cl,%eax
  8013b2:	09 c2                	or     %eax,%edx
  8013b4:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8013b7:	d3 e8                	shr    %cl,%eax
  8013b9:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8013bc:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8013bf:	e9 b6 fe ff ff       	jmp    80127a <__umoddi3+0x5a>
  8013c4:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  8013c7:	76 c3                	jbe    80138c <__umoddi3+0x16c>
  8013c9:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  8013cc:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  8013cf:	eb bb                	jmp    80138c <__umoddi3+0x16c>
  8013d1:	90                   	nop    
  8013d2:	90                   	nop    
  8013d3:	90                   	nop    
