
obj/user/fairness：     文件格式 elf32-i386

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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 4d 0a 00 00       	call   800a8e <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (env == &envs[1]) {
  800043:	81 3d 04 20 80 00 80 	cmpl   $0xeec00080,0x802004
  80004a:	00 c0 ee 
  80004d:	75 26                	jne    800075 <umain+0x41>
		while (1) {
  80004f:	8d 75 f4             	lea    0xfffffff4(%ebp),%esi
			ipc_recv(&who, 0, 0);
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	6a 00                	push   $0x0
  800057:	6a 00                	push   $0x0
  800059:	56                   	push   %esi
  80005a:	e8 2d 0d 00 00       	call   800d8c <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005f:	83 c4 0c             	add    $0xc,%esp
  800062:	ff 75 f4             	pushl  0xfffffff4(%ebp)
  800065:	53                   	push   %ebx
  800066:	68 c0 11 80 00       	push   $0x8011c0
  80006b:	e8 14 01 00 00       	call   800184 <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	eb dd                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	a1 cc 00 c0 ee       	mov    0xeec000cc,%eax
  80007d:	50                   	push   %eax
  80007e:	53                   	push   %ebx
  80007f:	68 d1 11 80 00       	push   $0x8011d1
  800084:	e8 fb 00 00 00       	call   800184 <cprintf>
		while (1)
  800089:	83 c4 10             	add    $0x10,%esp
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	a1 cc 00 c0 ee       	mov    0xeec000cc,%eax
  800097:	50                   	push   %eax
  800098:	e8 73 0d 00 00       	call   800e10 <ipc_send>
  80009d:	eb ea                	jmp    800089 <umain+0x55>
	...

008000a0 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
  8000a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  8000ab:	e8 de 09 00 00       	call   800a8e <sys_getenvid>
  8000b0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b5:	c1 e0 07             	shl    $0x7,%eax
  8000b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000bd:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c2:	85 f6                	test   %esi,%esi
  8000c4:	7e 07                	jle    8000cd <libmain+0x2d>
		binaryname = argv[0];
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	53                   	push   %ebx
  8000d1:	56                   	push   %esi
  8000d2:	e8 5d ff ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  8000d7:	e8 08 00 00 00       	call   8000e4 <exit>
}
  8000dc:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  8000ea:	6a 00                	push   $0x0
  8000ec:	e8 4c 09 00 00       	call   800a3d <sys_env_destroy>
}
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    
	...

008000f4 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 04             	sub    $0x4,%esp
  8000fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fe:	8b 03                	mov    (%ebx),%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800107:	40                   	inc    %eax
  800108:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 1a                	jne    80012b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 be 08 00 00       	call   8009e0 <sys_cputs>
		b->idx = 0;
  800122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800128:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012b:	ff 43 04             	incl   0x4(%ebx)
}
  80012e:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013c:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  800143:	00 00 00 
	b.cnt = 0;
  800146:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  80014d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800150:	ff 75 0c             	pushl  0xc(%ebp)
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  80015c:	50                   	push   %eax
  80015d:	68 f4 00 80 00       	push   $0x8000f4
  800162:	e8 83 01 00 00       	call   8002ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800167:	83 c4 08             	add    $0x8,%esp
  80016a:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800170:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800176:	50                   	push   %eax
  800177:	e8 64 08 00 00       	call   8009e0 <sys_cputs>

	return b.cnt;
  80017c:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018d:	50                   	push   %eax
  80018e:	ff 75 08             	pushl  0x8(%ebp)
  800191:	e8 9d ff ff ff       	call   800133 <vcprintf>
	va_end(ap);

	return cnt;
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	8b 75 10             	mov    0x10(%ebp),%esi
  8001a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a7:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001aa:	8b 45 18             	mov    0x18(%ebp),%eax
  8001ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b2:	39 d7                	cmp    %edx,%edi
  8001b4:	72 39                	jb     8001ef <printnum+0x57>
  8001b6:	77 04                	ja     8001bc <printnum+0x24>
  8001b8:	39 c6                	cmp    %eax,%esi
  8001ba:	72 33                	jb     8001ef <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	83 ec 04             	sub    $0x4,%esp
  8001bf:	ff 75 20             	pushl  0x20(%ebp)
  8001c2:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8001c5:	50                   	push   %eax
  8001c6:	ff 75 18             	pushl  0x18(%ebp)
  8001c9:	8b 45 18             	mov    0x18(%ebp),%eax
  8001cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d1:	52                   	push   %edx
  8001d2:	50                   	push   %eax
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	e8 02 0d 00 00       	call   800edc <__udivdi3>
  8001da:	83 c4 10             	add    $0x10,%esp
  8001dd:	52                   	push   %edx
  8001de:	50                   	push   %eax
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	e8 ae ff ff ff       	call   800198 <printnum>
  8001ea:	83 c4 20             	add    $0x20,%esp
  8001ed:	eb 19                	jmp    800208 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ef:	4b                   	dec    %ebx
  8001f0:	85 db                	test   %ebx,%ebx
  8001f2:	7e 14                	jle    800208 <printnum+0x70>
			putch(padc, putdat);
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	ff 75 0c             	pushl  0xc(%ebp)
  8001fa:	ff 75 20             	pushl  0x20(%ebp)
  8001fd:	ff 55 08             	call   *0x8(%ebp)
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	4b                   	dec    %ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f ec                	jg     8001f4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 0c             	pushl  0xc(%ebp)
  80020e:	8b 45 18             	mov    0x18(%ebp),%eax
  800211:	ba 00 00 00 00       	mov    $0x0,%edx
  800216:	83 ec 04             	sub    $0x4,%esp
  800219:	52                   	push   %edx
  80021a:	50                   	push   %eax
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	e8 da 0d 00 00       	call   800ffc <__umoddi3>
  800222:	83 c4 14             	add    $0x14,%esp
  800225:	0f be 80 92 12 80 00 	movsbl 0x801292(%eax),%eax
  80022c:	50                   	push   %eax
  80022d:	ff 55 08             	call   *0x8(%ebp)
}
  800230:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 18             	sub    $0x18,%esp
  800240:	8b 75 08             	mov    0x8(%ebp),%esi
  800243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800246:	8a 45 18             	mov    0x18(%ebp),%al
  800249:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  80024c:	53                   	push   %ebx
  80024d:	6a 1b                	push   $0x1b
  80024f:	ff d6                	call   *%esi
	putch('[', putdat);
  800251:	83 c4 08             	add    $0x8,%esp
  800254:	53                   	push   %ebx
  800255:	6a 5b                	push   $0x5b
  800257:	ff d6                	call   *%esi
	putch('0', putdat);
  800259:	83 c4 08             	add    $0x8,%esp
  80025c:	53                   	push   %ebx
  80025d:	6a 30                	push   $0x30
  80025f:	ff d6                	call   *%esi
	putch(';', putdat);
  800261:	83 c4 08             	add    $0x8,%esp
  800264:	53                   	push   %ebx
  800265:	6a 3b                	push   $0x3b
  800267:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800269:	83 c4 0c             	add    $0xc,%esp
  80026c:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	ff 75 14             	pushl  0x14(%ebp)
  800274:	6a 0a                	push   $0xa
  800276:	8b 45 10             	mov    0x10(%ebp),%eax
  800279:	99                   	cltd   
  80027a:	52                   	push   %edx
  80027b:	50                   	push   %eax
  80027c:	53                   	push   %ebx
  80027d:	56                   	push   %esi
  80027e:	e8 15 ff ff ff       	call   800198 <printnum>
	putch('m', putdat);
  800283:	83 c4 18             	add    $0x18,%esp
  800286:	53                   	push   %ebx
  800287:	6a 6d                	push   $0x6d
  800289:	ff d6                	call   *%esi

}
  80028b:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80029b:	83 f8 01             	cmp    $0x1,%eax
  80029e:	7e 0f                	jle    8002af <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002a0:	8b 01                	mov    (%ecx),%eax
  8002a2:	83 c0 08             	add    $0x8,%eax
  8002a5:	89 01                	mov    %eax,(%ecx)
  8002a7:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002aa:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002ad:	eb 0f                	jmp    8002be <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8002af:	8b 01                	mov    (%ecx),%eax
  8002b1:	83 c0 04             	add    $0x4,%eax
  8002b4:	89 01                	mov    %eax,(%ecx)
  8002b6:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002c9:	83 f8 01             	cmp    $0x1,%eax
  8002cc:	7e 0f                	jle    8002dd <getint+0x1d>
		return va_arg(*ap, long long);
  8002ce:	8b 02                	mov    (%edx),%eax
  8002d0:	83 c0 08             	add    $0x8,%eax
  8002d3:	89 02                	mov    %eax,(%edx)
  8002d5:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002d8:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002db:	eb 0b                	jmp    8002e8 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	83 c0 04             	add    $0x4,%eax
  8002e2:	89 02                	mov    %eax,(%edx)
  8002e4:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002e7:	99                   	cltd   
}
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 1c             	sub    $0x1c,%esp
  8002f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f6:	0f b6 13             	movzbl (%ebx),%edx
  8002f9:	43                   	inc    %ebx
  8002fa:	83 fa 25             	cmp    $0x25,%edx
  8002fd:	74 1e                	je     80031d <vprintfmt+0x33>
			if (ch == '\0')
  8002ff:	85 d2                	test   %edx,%edx
  800301:	0f 84 dc 02 00 00    	je     8005e3 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	ff 75 0c             	pushl  0xc(%ebp)
  80030d:	52                   	push   %edx
  80030e:	ff 55 08             	call   *0x8(%ebp)
  800311:	83 c4 10             	add    $0x10,%esp
  800314:	0f b6 13             	movzbl (%ebx),%edx
  800317:	43                   	inc    %ebx
  800318:	83 fa 25             	cmp    $0x25,%edx
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80031d:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  800321:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  800328:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  800332:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  800339:	0f b6 13             	movzbl (%ebx),%edx
  80033c:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  80033f:	43                   	inc    %ebx
  800340:	83 f8 55             	cmp    $0x55,%eax
  800343:	0f 87 75 02 00 00    	ja     8005be <vprintfmt+0x2d4>
  800349:	ff 24 85 e4 12 80 00 	jmp    *0x8012e4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800350:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800354:	eb e3                	jmp    800339 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800356:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  80035a:	eb dd                	jmp    800339 <vprintfmt+0x4f>

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
  80035c:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800361:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800364:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800368:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80036b:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80036e:	83 f8 09             	cmp    $0x9,%eax
  800371:	77 27                	ja     80039a <vprintfmt+0xb0>
  800373:	43                   	inc    %ebx
  800374:	eb eb                	jmp    800361 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800376:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800380:	eb 18                	jmp    80039a <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  800382:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800386:	79 b1                	jns    800339 <vprintfmt+0x4f>
				width = 0;
  800388:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80038f:	eb a8                	jmp    800339 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800391:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800398:	eb 9f                	jmp    800339 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  80039a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80039e:	79 99                	jns    800339 <vprintfmt+0x4f>
				width = precision, precision = -1;
  8003a0:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8003a3:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003a8:	eb 8f                	jmp    800339 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003aa:	41                   	inc    %ecx
			goto reswitch;
  8003ab:	eb 8c                	jmp    800339 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	ff 75 0c             	pushl  0xc(%ebp)
  8003b3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	ff 70 fc             	pushl  0xfffffffc(%eax)
  8003bd:	e9 c4 01 00 00       	jmp    800586 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  8003c2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	79 02                	jns    8003d2 <vprintfmt+0xe8>
				err = -err;
  8003d0:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8003d2:	83 f8 08             	cmp    $0x8,%eax
  8003d5:	7f 0b                	jg     8003e2 <vprintfmt+0xf8>
  8003d7:	8b 3c 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edi
  8003de:	85 ff                	test   %edi,%edi
  8003e0:	75 08                	jne    8003ea <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  8003e2:	50                   	push   %eax
  8003e3:	68 a3 12 80 00       	push   $0x8012a3
  8003e8:	eb 06                	jmp    8003f0 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8003ea:	57                   	push   %edi
  8003eb:	68 ac 12 80 00       	push   $0x8012ac
  8003f0:	ff 75 0c             	pushl  0xc(%ebp)
  8003f3:	ff 75 08             	pushl  0x8(%ebp)
  8003f6:	e8 f0 01 00 00       	call   8005eb <printfmt>
  8003fb:	e9 89 01 00 00       	jmp    800589 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800400:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  80040a:	85 ff                	test   %edi,%edi
  80040c:	75 05                	jne    800413 <vprintfmt+0x129>
				p = "(null)";
  80040e:	bf af 12 80 00       	mov    $0x8012af,%edi
			if (width > 0 && padc != '-')
  800413:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800417:	7e 3b                	jle    800454 <vprintfmt+0x16a>
  800419:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  80041d:	74 35                	je     800454 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	56                   	push   %esi
  800423:	57                   	push   %edi
  800424:	e8 74 02 00 00       	call   80069d <strnlen>
  800429:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800433:	7e 1f                	jle    800454 <vprintfmt+0x16a>
  800435:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800439:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 0c             	pushl  0xc(%ebp)
  800442:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  800445:	ff 55 08             	call   *0x8(%ebp)
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80044e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800452:	7f e8                	jg     80043c <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800454:	0f be 17             	movsbl (%edi),%edx
  800457:	47                   	inc    %edi
  800458:	85 d2                	test   %edx,%edx
  80045a:	74 3e                	je     80049a <vprintfmt+0x1b0>
  80045c:	85 f6                	test   %esi,%esi
  80045e:	78 03                	js     800463 <vprintfmt+0x179>
  800460:	4e                   	dec    %esi
  800461:	78 37                	js     80049a <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  800463:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800467:	74 12                	je     80047b <vprintfmt+0x191>
  800469:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  80046c:	83 f8 5e             	cmp    $0x5e,%eax
  80046f:	76 0a                	jbe    80047b <vprintfmt+0x191>
					putch('?', putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 0c             	pushl  0xc(%ebp)
  800477:	6a 3f                	push   $0x3f
  800479:	eb 07                	jmp    800482 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 0c             	pushl  0xc(%ebp)
  800481:	52                   	push   %edx
  800482:	ff 55 08             	call   *0x8(%ebp)
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80048b:	0f be 17             	movsbl (%edi),%edx
  80048e:	47                   	inc    %edi
  80048f:	85 d2                	test   %edx,%edx
  800491:	74 07                	je     80049a <vprintfmt+0x1b0>
  800493:	85 f6                	test   %esi,%esi
  800495:	78 cc                	js     800463 <vprintfmt+0x179>
  800497:	4e                   	dec    %esi
  800498:	79 c9                	jns    800463 <vprintfmt+0x179>
			for (; width > 0; width--)
  80049a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80049e:	0f 8e 52 fe ff ff    	jle    8002f6 <vprintfmt+0xc>
				putch(' ', putdat);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	ff 75 0c             	pushl  0xc(%ebp)
  8004aa:	6a 20                	push   $0x20
  8004ac:	ff 55 08             	call   *0x8(%ebp)
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004b5:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004b9:	7f e9                	jg     8004a4 <vprintfmt+0x1ba>
			break;
  8004bb:	e9 36 fe ff ff       	jmp    8002f6 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	51                   	push   %ecx
  8004c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8004c7:	50                   	push   %eax
  8004c8:	e8 f3 fd ff ff       	call   8002c0 <getint>
  8004cd:	89 c6                	mov    %eax,%esi
  8004cf:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	79 15                	jns    8004ed <vprintfmt+0x203>
				putch('-', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	ff 75 0c             	pushl  0xc(%ebp)
  8004de:	6a 2d                	push   $0x2d
  8004e0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004e3:	f7 de                	neg    %esi
  8004e5:	83 d7 00             	adc    $0x0,%edi
  8004e8:	f7 df                	neg    %edi
  8004ea:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004ed:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004f2:	eb 70                	jmp    800564 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	51                   	push   %ecx
  8004f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004fb:	50                   	push   %eax
  8004fc:	e8 91 fd ff ff       	call   800292 <getuint>
  800501:	89 c6                	mov    %eax,%esi
  800503:	89 d7                	mov    %edx,%edi
			base = 10;
  800505:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80050a:	eb 55                	jmp    800561 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	51                   	push   %ecx
  800510:	8d 45 14             	lea    0x14(%ebp),%eax
  800513:	50                   	push   %eax
  800514:	e8 79 fd ff ff       	call   800292 <getuint>
  800519:	89 c6                	mov    %eax,%esi
  80051b:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  80051d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800522:	eb 3d                	jmp    800561 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	6a 30                	push   $0x30
  80052c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80052f:	83 c4 08             	add    $0x8,%esp
  800532:	ff 75 0c             	pushl  0xc(%ebp)
  800535:	6a 78                	push   $0x78
  800537:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80053a:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800544:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  800549:	eb 11                	jmp    80055c <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	51                   	push   %ecx
  80054f:	8d 45 14             	lea    0x14(%ebp),%eax
  800552:	50                   	push   %eax
  800553:	e8 3a fd ff ff       	call   800292 <getuint>
  800558:	89 c6                	mov    %eax,%esi
  80055a:	89 d7                	mov    %edx,%edi
			base = 16;
  80055c:	ba 10 00 00 00       	mov    $0x10,%edx
  800561:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800564:	83 ec 04             	sub    $0x4,%esp
  800567:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80056b:	50                   	push   %eax
  80056c:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80056f:	52                   	push   %edx
  800570:	57                   	push   %edi
  800571:	56                   	push   %esi
  800572:	ff 75 0c             	pushl  0xc(%ebp)
  800575:	ff 75 08             	pushl  0x8(%ebp)
  800578:	e8 1b fc ff ff       	call   800198 <printnum>
			break;
  80057d:	eb 37                	jmp    8005b6 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	ff 75 0c             	pushl  0xc(%ebp)
  800585:	52                   	push   %edx
  800586:	ff 55 08             	call   *0x8(%ebp)
			break;
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	e9 65 fd ff ff       	jmp    8002f6 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	51                   	push   %ecx
  800595:	8d 45 14             	lea    0x14(%ebp),%eax
  800598:	50                   	push   %eax
  800599:	e8 f4 fc ff ff       	call   800292 <getuint>
  80059e:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  8005a0:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8005aa:	56                   	push   %esi
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	ff 75 08             	pushl  0x8(%ebp)
  8005b1:	e8 82 fc ff ff       	call   800238 <printcolor>
			break;
  8005b6:	83 c4 20             	add    $0x20,%esp
  8005b9:	e9 38 fd ff ff       	jmp    8002f6 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	ff 75 0c             	pushl  0xc(%ebp)
  8005c4:	6a 25                	push   $0x25
  8005c6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005c9:	4b                   	dec    %ebx
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005d1:	0f 84 1f fd ff ff    	je     8002f6 <vprintfmt+0xc>
  8005d7:	4b                   	dec    %ebx
  8005d8:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005dc:	75 f9                	jne    8005d7 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005de:	e9 13 fd ff ff       	jmp    8002f6 <vprintfmt+0xc>
		}
	}
}
  8005e3:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8005e6:	5b                   	pop    %ebx
  8005e7:	5e                   	pop    %esi
  8005e8:	5f                   	pop    %edi
  8005e9:	c9                   	leave  
  8005ea:	c3                   	ret    

008005eb <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005eb:	55                   	push   %ebp
  8005ec:	89 e5                	mov    %esp,%ebp
  8005ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005f4:	50                   	push   %eax
  8005f5:	ff 75 10             	pushl  0x10(%ebp)
  8005f8:	ff 75 0c             	pushl  0xc(%ebp)
  8005fb:	ff 75 08             	pushl  0x8(%ebp)
  8005fe:	e8 e7 fc ff ff       	call   8002ea <vprintfmt>
	va_end(ap);
}
  800603:	c9                   	leave  
  800604:	c3                   	ret    

00800605 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80060b:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80060e:	8b 0a                	mov    (%edx),%ecx
  800610:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800613:	73 07                	jae    80061c <sprintputch+0x17>
		*b->buf++ = ch;
  800615:	8b 45 08             	mov    0x8(%ebp),%eax
  800618:	88 01                	mov    %al,(%ecx)
  80061a:	ff 02                	incl   (%edx)
}
  80061c:	c9                   	leave  
  80061d:	c3                   	ret    

0080061e <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  80061e:	55                   	push   %ebp
  80061f:	89 e5                	mov    %esp,%ebp
  800621:	83 ec 18             	sub    $0x18,%esp
  800624:	8b 55 08             	mov    0x8(%ebp),%edx
  800627:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80062a:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80062d:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800631:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800634:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  80063b:	85 d2                	test   %edx,%edx
  80063d:	74 04                	je     800643 <vsnprintf+0x25>
  80063f:	85 c9                	test   %ecx,%ecx
  800641:	7f 07                	jg     80064a <vsnprintf+0x2c>
		return -E_INVAL;
  800643:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800648:	eb 1d                	jmp    800667 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  80064a:	ff 75 14             	pushl  0x14(%ebp)
  80064d:	ff 75 10             	pushl  0x10(%ebp)
  800650:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	68 05 06 80 00       	push   $0x800605
  800659:	e8 8c fc ff ff       	call   8002ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065e:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800661:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800664:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800667:	c9                   	leave  
  800668:	c3                   	ret    

00800669 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800669:	55                   	push   %ebp
  80066a:	89 e5                	mov    %esp,%ebp
  80066c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800672:	50                   	push   %eax
  800673:	ff 75 10             	pushl  0x10(%ebp)
  800676:	ff 75 0c             	pushl  0xc(%ebp)
  800679:	ff 75 08             	pushl  0x8(%ebp)
  80067c:	e8 9d ff ff ff       	call   80061e <vsnprintf>
	va_end(ap);

	return rc;
}
  800681:	c9                   	leave  
  800682:	c3                   	ret    
	...

00800684 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80068a:	b8 00 00 00 00       	mov    $0x0,%eax
  80068f:	80 3a 00             	cmpb   $0x0,(%edx)
  800692:	74 07                	je     80069b <strlen+0x17>
		n++;
  800694:	40                   	inc    %eax
  800695:	42                   	inc    %edx
  800696:	80 3a 00             	cmpb   $0x0,(%edx)
  800699:	75 f9                	jne    800694 <strlen+0x10>
	return n;
}
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    

0080069d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	74 0f                	je     8006be <strnlen+0x21>
  8006af:	80 39 00             	cmpb   $0x0,(%ecx)
  8006b2:	74 0a                	je     8006be <strnlen+0x21>
		n++;
  8006b4:	40                   	inc    %eax
  8006b5:	41                   	inc    %ecx
  8006b6:	4a                   	dec    %edx
  8006b7:	74 05                	je     8006be <strnlen+0x21>
  8006b9:	80 39 00             	cmpb   $0x0,(%ecx)
  8006bc:	75 f6                	jne    8006b4 <strnlen+0x17>
	return n;
}
  8006be:	c9                   	leave  
  8006bf:	c3                   	ret    

008006c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	53                   	push   %ebx
  8006c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006ca:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006cc:	8a 02                	mov    (%edx),%al
  8006ce:	42                   	inc    %edx
  8006cf:	88 01                	mov    %al,(%ecx)
  8006d1:	41                   	inc    %ecx
  8006d2:	84 c0                	test   %al,%al
  8006d4:	75 f6                	jne    8006cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	5b                   	pop    %ebx
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	57                   	push   %edi
  8006df:	56                   	push   %esi
  8006e0:	53                   	push   %ebx
  8006e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e7:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006ea:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8006ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f1:	39 f3                	cmp    %esi,%ebx
  8006f3:	73 10                	jae    800705 <strncpy+0x2a>
		*dst++ = *src;
  8006f5:	8a 02                	mov    (%edx),%al
  8006f7:	88 01                	mov    %al,(%ecx)
  8006f9:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8006fa:	80 3a 00             	cmpb   $0x0,(%edx)
  8006fd:	74 01                	je     800700 <strncpy+0x25>
			src++;
  8006ff:	42                   	inc    %edx
  800700:	43                   	inc    %ebx
  800701:	39 f3                	cmp    %esi,%ebx
  800703:	72 f0                	jb     8006f5 <strncpy+0x1a>
	}
	return ret;
}
  800705:	89 f8                	mov    %edi,%eax
  800707:	5b                   	pop    %ebx
  800708:	5e                   	pop    %esi
  800709:	5f                   	pop    %edi
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	56                   	push   %esi
  800710:	53                   	push   %ebx
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800714:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800717:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80071a:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80071c:	85 d2                	test   %edx,%edx
  80071e:	74 19                	je     800739 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800720:	4a                   	dec    %edx
  800721:	74 13                	je     800736 <strlcpy+0x2a>
  800723:	80 39 00             	cmpb   $0x0,(%ecx)
  800726:	74 0e                	je     800736 <strlcpy+0x2a>
			*dst++ = *src++;
  800728:	8a 01                	mov    (%ecx),%al
  80072a:	41                   	inc    %ecx
  80072b:	88 03                	mov    %al,(%ebx)
  80072d:	43                   	inc    %ebx
  80072e:	4a                   	dec    %edx
  80072f:	74 05                	je     800736 <strlcpy+0x2a>
  800731:	80 39 00             	cmpb   $0x0,(%ecx)
  800734:	75 f2                	jne    800728 <strlcpy+0x1c>
		*dst = '\0';
  800736:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800739:	89 d8                	mov    %ebx,%eax
  80073b:	29 f0                	sub    %esi,%eax
}
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80074a:	80 3a 00             	cmpb   $0x0,(%edx)
  80074d:	74 13                	je     800762 <strcmp+0x21>
  80074f:	8a 02                	mov    (%edx),%al
  800751:	3a 01                	cmp    (%ecx),%al
  800753:	75 0d                	jne    800762 <strcmp+0x21>
		p++, q++;
  800755:	42                   	inc    %edx
  800756:	41                   	inc    %ecx
  800757:	80 3a 00             	cmpb   $0x0,(%edx)
  80075a:	74 06                	je     800762 <strcmp+0x21>
  80075c:	8a 02                	mov    (%edx),%al
  80075e:	3a 01                	cmp    (%ecx),%al
  800760:	74 f3                	je     800755 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800762:	0f b6 02             	movzbl (%edx),%eax
  800765:	0f b6 11             	movzbl (%ecx),%edx
  800768:	29 d0                	sub    %edx,%eax
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	53                   	push   %ebx
  800770:	8b 55 08             	mov    0x8(%ebp),%edx
  800773:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800776:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800779:	85 c9                	test   %ecx,%ecx
  80077b:	74 1f                	je     80079c <strncmp+0x30>
  80077d:	80 3a 00             	cmpb   $0x0,(%edx)
  800780:	74 16                	je     800798 <strncmp+0x2c>
  800782:	8a 02                	mov    (%edx),%al
  800784:	3a 03                	cmp    (%ebx),%al
  800786:	75 10                	jne    800798 <strncmp+0x2c>
		n--, p++, q++;
  800788:	42                   	inc    %edx
  800789:	43                   	inc    %ebx
  80078a:	49                   	dec    %ecx
  80078b:	74 0f                	je     80079c <strncmp+0x30>
  80078d:	80 3a 00             	cmpb   $0x0,(%edx)
  800790:	74 06                	je     800798 <strncmp+0x2c>
  800792:	8a 02                	mov    (%edx),%al
  800794:	3a 03                	cmp    (%ebx),%al
  800796:	74 f0                	je     800788 <strncmp+0x1c>
	if (n == 0)
  800798:	85 c9                	test   %ecx,%ecx
  80079a:	75 07                	jne    8007a3 <strncmp+0x37>
		return 0;
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	eb 0a                	jmp    8007ad <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a3:	0f b6 12             	movzbl (%edx),%edx
  8007a6:	0f b6 03             	movzbl (%ebx),%eax
  8007a9:	29 c2                	sub    %eax,%edx
  8007ab:	89 d0                	mov    %edx,%eax
}
  8007ad:	8b 1c 24             	mov    (%esp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b8:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007bb:	80 38 00             	cmpb   $0x0,(%eax)
  8007be:	74 0a                	je     8007ca <strchr+0x18>
		if (*s == c)
  8007c0:	38 10                	cmp    %dl,(%eax)
  8007c2:	74 0b                	je     8007cf <strchr+0x1d>
  8007c4:	40                   	inc    %eax
  8007c5:	80 38 00             	cmpb   $0x0,(%eax)
  8007c8:	75 f6                	jne    8007c0 <strchr+0xe>
			return (char *) s;
	return 0;
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007da:	80 38 00             	cmpb   $0x0,(%eax)
  8007dd:	74 0a                	je     8007e9 <strfind+0x18>
		if (*s == c)
  8007df:	38 10                	cmp    %dl,(%eax)
  8007e1:	74 06                	je     8007e9 <strfind+0x18>
  8007e3:	40                   	inc    %eax
  8007e4:	80 38 00             	cmpb   $0x0,(%eax)
  8007e7:	75 f6                	jne    8007df <strfind+0xe>
			break;
	return (char *) s;
}
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    

008007eb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	57                   	push   %edi
  8007ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8007f5:	89 f8                	mov    %edi,%eax
  8007f7:	85 c9                	test   %ecx,%ecx
  8007f9:	74 40                	je     80083b <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007fb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800801:	75 30                	jne    800833 <memset+0x48>
  800803:	f6 c1 03             	test   $0x3,%cl
  800806:	75 2b                	jne    800833 <memset+0x48>
		c &= 0xFF;
  800808:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80080f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800812:	c1 e0 18             	shl    $0x18,%eax
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
  800818:	c1 e2 10             	shl    $0x10,%edx
  80081b:	09 d0                	or     %edx,%eax
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800820:	c1 e2 08             	shl    $0x8,%edx
  800823:	09 d0                	or     %edx,%eax
  800825:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800828:	c1 e9 02             	shr    $0x2,%ecx
  80082b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082e:	fc                   	cld    
  80082f:	f3 ab                	repz stos %eax,%es:(%edi)
  800831:	eb 06                	jmp    800839 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800833:	8b 45 0c             	mov    0xc(%ebp),%eax
  800836:	fc                   	cld    
  800837:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800839:	89 f8                	mov    %edi,%eax
}
  80083b:	8b 3c 24             	mov    (%esp),%edi
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	57                   	push   %edi
  800844:	56                   	push   %esi
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80084b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80084e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800850:	39 c6                	cmp    %eax,%esi
  800852:	73 33                	jae    800887 <memmove+0x47>
  800854:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800857:	39 c2                	cmp    %eax,%edx
  800859:	76 2c                	jbe    800887 <memmove+0x47>
		s += n;
  80085b:	89 d6                	mov    %edx,%esi
		d += n;
  80085d:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800860:	f6 c2 03             	test   $0x3,%dl
  800863:	75 1b                	jne    800880 <memmove+0x40>
  800865:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086b:	75 13                	jne    800880 <memmove+0x40>
  80086d:	f6 c1 03             	test   $0x3,%cl
  800870:	75 0e                	jne    800880 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800872:	83 ef 04             	sub    $0x4,%edi
  800875:	83 ee 04             	sub    $0x4,%esi
  800878:	c1 e9 02             	shr    $0x2,%ecx
  80087b:	fd                   	std    
  80087c:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80087e:	eb 27                	jmp    8008a7 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800880:	4f                   	dec    %edi
  800881:	4e                   	dec    %esi
  800882:	fd                   	std    
  800883:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800885:	eb 20                	jmp    8008a7 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800887:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088d:	75 15                	jne    8008a4 <memmove+0x64>
  80088f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800895:	75 0d                	jne    8008a4 <memmove+0x64>
  800897:	f6 c1 03             	test   $0x3,%cl
  80089a:	75 08                	jne    8008a4 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  80089c:	c1 e9 02             	shr    $0x2,%ecx
  80089f:	fc                   	cld    
  8008a0:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  8008a2:	eb 03                	jmp    8008a7 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008a4:	fc                   	cld    
  8008a5:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <memcpy>:

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
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008b1:	ff 75 10             	pushl  0x10(%ebp)
  8008b4:	ff 75 0c             	pushl  0xc(%ebp)
  8008b7:	ff 75 08             	pushl  0x8(%ebp)
  8008ba:	e8 81 ff ff ff       	call   800840 <memmove>
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  8008ce:	89 d0                	mov    %edx,%eax
  8008d0:	4a                   	dec    %edx
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	74 1b                	je     8008f0 <memcmp+0x2f>
		if (*s1 != *s2)
  8008d5:	8a 01                	mov    (%ecx),%al
  8008d7:	3a 03                	cmp    (%ebx),%al
  8008d9:	74 0c                	je     8008e7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008db:	0f b6 d0             	movzbl %al,%edx
  8008de:	0f b6 03             	movzbl (%ebx),%eax
  8008e1:	29 c2                	sub    %eax,%edx
  8008e3:	89 d0                	mov    %edx,%eax
  8008e5:	eb 0e                	jmp    8008f5 <memcmp+0x34>
		s1++, s2++;
  8008e7:	41                   	inc    %ecx
  8008e8:	43                   	inc    %ebx
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	4a                   	dec    %edx
  8008ec:	85 c0                	test   %eax,%eax
  8008ee:	75 e5                	jne    8008d5 <memcmp+0x14>
	}

	return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800901:	89 c2                	mov    %eax,%edx
  800903:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800906:	39 d0                	cmp    %edx,%eax
  800908:	73 09                	jae    800913 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80090a:	38 08                	cmp    %cl,(%eax)
  80090c:	74 05                	je     800913 <memfind+0x1b>
  80090e:	40                   	inc    %eax
  80090f:	39 d0                	cmp    %edx,%eax
  800911:	72 f7                	jb     80090a <memfind+0x12>
			break;
	return (void *) s;
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 55 08             	mov    0x8(%ebp),%edx
  80091e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800924:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800929:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80092e:	80 3a 20             	cmpb   $0x20,(%edx)
  800931:	74 05                	je     800938 <strtol+0x23>
  800933:	80 3a 09             	cmpb   $0x9,(%edx)
  800936:	75 0b                	jne    800943 <strtol+0x2e>
		s++;
  800938:	42                   	inc    %edx
  800939:	80 3a 20             	cmpb   $0x20,(%edx)
  80093c:	74 fa                	je     800938 <strtol+0x23>
  80093e:	80 3a 09             	cmpb   $0x9,(%edx)
  800941:	74 f5                	je     800938 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800943:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800946:	75 03                	jne    80094b <strtol+0x36>
		s++;
  800948:	42                   	inc    %edx
  800949:	eb 0b                	jmp    800956 <strtol+0x41>
	else if (*s == '-')
  80094b:	80 3a 2d             	cmpb   $0x2d,(%edx)
  80094e:	75 06                	jne    800956 <strtol+0x41>
		s++, neg = 1;
  800950:	42                   	inc    %edx
  800951:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800956:	85 c9                	test   %ecx,%ecx
  800958:	74 05                	je     80095f <strtol+0x4a>
  80095a:	83 f9 10             	cmp    $0x10,%ecx
  80095d:	75 15                	jne    800974 <strtol+0x5f>
  80095f:	80 3a 30             	cmpb   $0x30,(%edx)
  800962:	75 10                	jne    800974 <strtol+0x5f>
  800964:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800968:	75 0a                	jne    800974 <strtol+0x5f>
		s += 2, base = 16;
  80096a:	83 c2 02             	add    $0x2,%edx
  80096d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800972:	eb 1a                	jmp    80098e <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800974:	85 c9                	test   %ecx,%ecx
  800976:	75 16                	jne    80098e <strtol+0x79>
  800978:	80 3a 30             	cmpb   $0x30,(%edx)
  80097b:	75 08                	jne    800985 <strtol+0x70>
		s++, base = 8;
  80097d:	42                   	inc    %edx
  80097e:	b9 08 00 00 00       	mov    $0x8,%ecx
  800983:	eb 09                	jmp    80098e <strtol+0x79>
	else if (base == 0)
  800985:	85 c9                	test   %ecx,%ecx
  800987:	75 05                	jne    80098e <strtol+0x79>
		base = 10;
  800989:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80098e:	8a 02                	mov    (%edx),%al
  800990:	83 e8 30             	sub    $0x30,%eax
  800993:	3c 09                	cmp    $0x9,%al
  800995:	77 08                	ja     80099f <strtol+0x8a>
			dig = *s - '0';
  800997:	0f be 02             	movsbl (%edx),%eax
  80099a:	83 e8 30             	sub    $0x30,%eax
  80099d:	eb 20                	jmp    8009bf <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  80099f:	8a 02                	mov    (%edx),%al
  8009a1:	83 e8 61             	sub    $0x61,%eax
  8009a4:	3c 19                	cmp    $0x19,%al
  8009a6:	77 08                	ja     8009b0 <strtol+0x9b>
			dig = *s - 'a' + 10;
  8009a8:	0f be 02             	movsbl (%edx),%eax
  8009ab:	83 e8 57             	sub    $0x57,%eax
  8009ae:	eb 0f                	jmp    8009bf <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  8009b0:	8a 02                	mov    (%edx),%al
  8009b2:	83 e8 41             	sub    $0x41,%eax
  8009b5:	3c 19                	cmp    $0x19,%al
  8009b7:	77 12                	ja     8009cb <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009b9:	0f be 02             	movsbl (%edx),%eax
  8009bc:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009bf:	39 c8                	cmp    %ecx,%eax
  8009c1:	7d 08                	jge    8009cb <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009c3:	42                   	inc    %edx
  8009c4:	0f af d9             	imul   %ecx,%ebx
  8009c7:	01 c3                	add    %eax,%ebx
  8009c9:	eb c3                	jmp    80098e <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009cb:	85 f6                	test   %esi,%esi
  8009cd:	74 02                	je     8009d1 <strtol+0xbc>
		*endptr = (char *) s;
  8009cf:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009d1:	89 d8                	mov    %ebx,%eax
  8009d3:	85 ff                	test   %edi,%edi
  8009d5:	74 02                	je     8009d9 <strtol+0xc4>
  8009d7:	f7 d8                	neg    %eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    
	...

008009e0 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f1:	89 f8                	mov    %edi,%eax
  8009f3:	89 fb                	mov    %edi,%ebx
  8009f5:	89 fe                	mov    %edi,%esi
  8009f7:	55                   	push   %ebp
  8009f8:	9c                   	pushf  
  8009f9:	56                   	push   %esi
  8009fa:	54                   	push   %esp
  8009fb:	5d                   	pop    %ebp
  8009fc:	8d 35 04 0a 80 00    	lea    0x800a04,%esi
  800a02:	0f 34                	sysenter 
  800a04:	83 c4 04             	add    $0x4,%esp
  800a07:	9d                   	popf   
  800a08:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	b8 01 00 00 00       	mov    $0x1,%eax
  800a19:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1e:	89 fa                	mov    %edi,%edx
  800a20:	89 f9                	mov    %edi,%ecx
  800a22:	89 fb                	mov    %edi,%ebx
  800a24:	89 fe                	mov    %edi,%esi
  800a26:	55                   	push   %ebp
  800a27:	9c                   	pushf  
  800a28:	56                   	push   %esi
  800a29:	54                   	push   %esp
  800a2a:	5d                   	pop    %ebp
  800a2b:	8d 35 33 0a 80 00    	lea    0x800a33,%esi
  800a31:	0f 34                	sysenter 
  800a33:	83 c4 04             	add    $0x4,%esp
  800a36:	9d                   	popf   
  800a37:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	83 ec 0c             	sub    $0xc,%esp
  800a46:	8b 55 08             	mov    0x8(%ebp),%edx
  800a49:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a53:	89 f9                	mov    %edi,%ecx
  800a55:	89 fb                	mov    %edi,%ebx
  800a57:	89 fe                	mov    %edi,%esi
  800a59:	55                   	push   %ebp
  800a5a:	9c                   	pushf  
  800a5b:	56                   	push   %esi
  800a5c:	54                   	push   %esp
  800a5d:	5d                   	pop    %ebp
  800a5e:	8d 35 66 0a 80 00    	lea    0x800a66,%esi
  800a64:	0f 34                	sysenter 
  800a66:	83 c4 04             	add    $0x4,%esp
  800a69:	9d                   	popf   
  800a6a:	5d                   	pop    %ebp
  800a6b:	85 c0                	test   %eax,%eax
  800a6d:	7e 17                	jle    800a86 <sys_env_destroy+0x49>
  800a6f:	83 ec 0c             	sub    $0xc,%esp
  800a72:	50                   	push   %eax
  800a73:	6a 03                	push   $0x3
  800a75:	68 3c 14 80 00       	push   $0x80143c
  800a7a:	6a 4c                	push   $0x4c
  800a7c:	68 59 14 80 00       	push   $0x801459
  800a81:	e8 f6 03 00 00       	call   800e7c <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a86:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	b8 02 00 00 00       	mov    $0x2,%eax
  800a99:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9e:	89 fa                	mov    %edi,%edx
  800aa0:	89 f9                	mov    %edi,%ecx
  800aa2:	89 fb                	mov    %edi,%ebx
  800aa4:	89 fe                	mov    %edi,%esi
  800aa6:	55                   	push   %ebp
  800aa7:	9c                   	pushf  
  800aa8:	56                   	push   %esi
  800aa9:	54                   	push   %esp
  800aaa:	5d                   	pop    %ebp
  800aab:	8d 35 b3 0a 80 00    	lea    0x800ab3,%esi
  800ab1:	0f 34                	sysenter 
  800ab3:	83 c4 04             	add    $0x4,%esp
  800ab6:	9d                   	popf   
  800ab7:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <sys_dump_env>:

int
sys_dump_env(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ac8:	bf 00 00 00 00       	mov    $0x0,%edi
  800acd:	89 fa                	mov    %edi,%edx
  800acf:	89 f9                	mov    %edi,%ecx
  800ad1:	89 fb                	mov    %edi,%ebx
  800ad3:	89 fe                	mov    %edi,%esi
  800ad5:	55                   	push   %ebp
  800ad6:	9c                   	pushf  
  800ad7:	56                   	push   %esi
  800ad8:	54                   	push   %esp
  800ad9:	5d                   	pop    %ebp
  800ada:	8d 35 e2 0a 80 00    	lea    0x800ae2,%esi
  800ae0:	0f 34                	sysenter 
  800ae2:	83 c4 04             	add    $0x4,%esp
  800ae5:	9d                   	popf   
  800ae6:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <sys_yield>:

void
sys_yield(void)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800af7:	bf 00 00 00 00       	mov    $0x0,%edi
  800afc:	89 fa                	mov    %edi,%edx
  800afe:	89 f9                	mov    %edi,%ecx
  800b00:	89 fb                	mov    %edi,%ebx
  800b02:	89 fe                	mov    %edi,%esi
  800b04:	55                   	push   %ebp
  800b05:	9c                   	pushf  
  800b06:	56                   	push   %esi
  800b07:	54                   	push   %esp
  800b08:	5d                   	pop    %ebp
  800b09:	8d 35 11 0b 80 00    	lea    0x800b11,%esi
  800b0f:	0f 34                	sysenter 
  800b11:	83 c4 04             	add    $0x4,%esp
  800b14:	9d                   	popf   
  800b15:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
  800b37:	89 fe                	mov    %edi,%esi
  800b39:	55                   	push   %ebp
  800b3a:	9c                   	pushf  
  800b3b:	56                   	push   %esi
  800b3c:	54                   	push   %esp
  800b3d:	5d                   	pop    %ebp
  800b3e:	8d 35 46 0b 80 00    	lea    0x800b46,%esi
  800b44:	0f 34                	sysenter 
  800b46:	83 c4 04             	add    $0x4,%esp
  800b49:	9d                   	popf   
  800b4a:	5d                   	pop    %ebp
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	7e 17                	jle    800b66 <sys_page_alloc+0x4b>
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	50                   	push   %eax
  800b53:	6a 05                	push   $0x5
  800b55:	68 3c 14 80 00       	push   $0x80143c
  800b5a:	6a 4c                	push   $0x4c
  800b5c:	68 59 14 80 00       	push   $0x801459
  800b61:	e8 16 03 00 00       	call   800e7c <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b66:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b83:	8b 75 18             	mov    0x18(%ebp),%esi
  800b86:	b8 06 00 00 00       	mov    $0x6,%eax
  800b8b:	55                   	push   %ebp
  800b8c:	9c                   	pushf  
  800b8d:	56                   	push   %esi
  800b8e:	54                   	push   %esp
  800b8f:	5d                   	pop    %ebp
  800b90:	8d 35 98 0b 80 00    	lea    0x800b98,%esi
  800b96:	0f 34                	sysenter 
  800b98:	83 c4 04             	add    $0x4,%esp
  800b9b:	9d                   	popf   
  800b9c:	5d                   	pop    %ebp
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 17                	jle    800bb8 <sys_page_map+0x4a>
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 06                	push   $0x6
  800ba7:	68 3c 14 80 00       	push   $0x80143c
  800bac:	6a 4c                	push   $0x4c
  800bae:	68 59 14 80 00       	push   $0x801459
  800bb3:	e8 c4 02 00 00       	call   800e7c <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800bb8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	b8 07 00 00 00       	mov    $0x7,%eax
  800bd4:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd9:	89 fb                	mov    %edi,%ebx
  800bdb:	89 fe                	mov    %edi,%esi
  800bdd:	55                   	push   %ebp
  800bde:	9c                   	pushf  
  800bdf:	56                   	push   %esi
  800be0:	54                   	push   %esp
  800be1:	5d                   	pop    %ebp
  800be2:	8d 35 ea 0b 80 00    	lea    0x800bea,%esi
  800be8:	0f 34                	sysenter 
  800bea:	83 c4 04             	add    $0x4,%esp
  800bed:	9d                   	popf   
  800bee:	5d                   	pop    %ebp
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 17                	jle    800c0a <sys_page_unmap+0x4a>
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	50                   	push   %eax
  800bf7:	6a 07                	push   $0x7
  800bf9:	68 3c 14 80 00       	push   $0x80143c
  800bfe:	6a 4c                	push   $0x4c
  800c00:	68 59 14 80 00       	push   $0x801459
  800c05:	e8 72 02 00 00       	call   800e7c <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	b8 09 00 00 00       	mov    $0x9,%eax
  800c26:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2b:	89 fb                	mov    %edi,%ebx
  800c2d:	89 fe                	mov    %edi,%esi
  800c2f:	55                   	push   %ebp
  800c30:	9c                   	pushf  
  800c31:	56                   	push   %esi
  800c32:	54                   	push   %esp
  800c33:	5d                   	pop    %ebp
  800c34:	8d 35 3c 0c 80 00    	lea    0x800c3c,%esi
  800c3a:	0f 34                	sysenter 
  800c3c:	83 c4 04             	add    $0x4,%esp
  800c3f:	9d                   	popf   
  800c40:	5d                   	pop    %ebp
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_env_set_status+0x4a>
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 09                	push   $0x9
  800c4b:	68 3c 14 80 00       	push   $0x80143c
  800c50:	6a 4c                	push   $0x4c
  800c52:	68 59 14 80 00       	push   $0x801459
  800c57:	e8 20 02 00 00       	call   800e7c <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c78:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7d:	89 fb                	mov    %edi,%ebx
  800c7f:	89 fe                	mov    %edi,%esi
  800c81:	55                   	push   %ebp
  800c82:	9c                   	pushf  
  800c83:	56                   	push   %esi
  800c84:	54                   	push   %esp
  800c85:	5d                   	pop    %ebp
  800c86:	8d 35 8e 0c 80 00    	lea    0x800c8e,%esi
  800c8c:	0f 34                	sysenter 
  800c8e:	83 c4 04             	add    $0x4,%esp
  800c91:	9d                   	popf   
  800c92:	5d                   	pop    %ebp
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 17                	jle    800cae <sys_env_set_trapframe+0x4a>
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 0a                	push   $0xa
  800c9d:	68 3c 14 80 00       	push   $0x80143c
  800ca2:	6a 4c                	push   $0x4c
  800ca4:	68 59 14 80 00       	push   $0x801459
  800ca9:	e8 ce 01 00 00       	call   800e7c <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cae:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    

00800cb6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cca:	bf 00 00 00 00       	mov    $0x0,%edi
  800ccf:	89 fb                	mov    %edi,%ebx
  800cd1:	89 fe                	mov    %edi,%esi
  800cd3:	55                   	push   %ebp
  800cd4:	9c                   	pushf  
  800cd5:	56                   	push   %esi
  800cd6:	54                   	push   %esp
  800cd7:	5d                   	pop    %ebp
  800cd8:	8d 35 e0 0c 80 00    	lea    0x800ce0,%esi
  800cde:	0f 34                	sysenter 
  800ce0:	83 c4 04             	add    $0x4,%esp
  800ce3:	9d                   	popf   
  800ce4:	5d                   	pop    %ebp
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_env_set_pgfault_upcall+0x4a>
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 0b                	push   $0xb
  800cef:	68 3c 14 80 00       	push   $0x80143c
  800cf4:	6a 4c                	push   $0x4c
  800cf6:	68 59 14 80 00       	push   $0x801459
  800cfb:	e8 7c 01 00 00       	call   800e7c <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	c9                   	leave  
  800d07:	c3                   	ret    

00800d08 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	55                   	push   %ebp
  800d25:	9c                   	pushf  
  800d26:	56                   	push   %esi
  800d27:	54                   	push   %esp
  800d28:	5d                   	pop    %ebp
  800d29:	8d 35 31 0d 80 00    	lea    0x800d31,%esi
  800d2f:	0f 34                	sysenter 
  800d31:	83 c4 04             	add    $0x4,%esp
  800d34:	9d                   	popf   
  800d35:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	89 fb                	mov    %edi,%ebx
  800d55:	89 fe                	mov    %edi,%esi
  800d57:	55                   	push   %ebp
  800d58:	9c                   	pushf  
  800d59:	56                   	push   %esi
  800d5a:	54                   	push   %esp
  800d5b:	5d                   	pop    %ebp
  800d5c:	8d 35 64 0d 80 00    	lea    0x800d64,%esi
  800d62:	0f 34                	sysenter 
  800d64:	83 c4 04             	add    $0x4,%esp
  800d67:	9d                   	popf   
  800d68:	5d                   	pop    %ebp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_ipc_recv+0x49>
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 0e                	push   $0xe
  800d73:	68 3c 14 80 00       	push   $0x80143c
  800d78:	6a 4c                	push   $0x4c
  800d7a:	68 59 14 80 00       	push   $0x801459
  800d7f:	e8 f8 00 00 00       	call   800e7c <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d97:	8b 75 10             	mov    0x10(%ebp),%esi
    // LAB 4: Your code here.
    //cprintf("env:%d is recieving\n",env->env_id);
    int r;
    if (!pg) {
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	75 05                	jne    800da3 <ipc_recv+0x17>
        /*the reciever need an integer not a page*/
        pg = (void*)UTOP;
  800d9e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
    }
    if ((r = sys_ipc_recv(pg))) {
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	50                   	push   %eax
  800da7:	e8 8f ff ff ff       	call   800d3b <sys_ipc_recv>
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	85 c0                	test   %eax,%eax
  800db1:	74 16                	je     800dc9 <ipc_recv+0x3d>
        if (from_env_store) {
  800db3:	85 db                	test   %ebx,%ebx
  800db5:	74 06                	je     800dbd <ipc_recv+0x31>
            *from_env_store = 0;
  800db7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        }
        if (perm_store) {
  800dbd:	85 f6                	test   %esi,%esi
  800dbf:	74 48                	je     800e09 <ipc_recv+0x7d>
            *perm_store = 0;
  800dc1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        return r;
  800dc7:	eb 40                	jmp    800e09 <ipc_recv+0x7d>
    }
    if (from_env_store) {
  800dc9:	85 db                	test   %ebx,%ebx
  800dcb:	74 0a                	je     800dd7 <ipc_recv+0x4b>
        *from_env_store = env->env_ipc_from;
  800dcd:	a1 04 20 80 00       	mov    0x802004,%eax
  800dd2:	8b 40 78             	mov    0x78(%eax),%eax
  800dd5:	89 03                	mov    %eax,(%ebx)
    }
    if (perm_store) {
  800dd7:	85 f6                	test   %esi,%esi
  800dd9:	74 0a                	je     800de5 <ipc_recv+0x59>
        *perm_store = env->env_ipc_perm;
  800ddb:	a1 04 20 80 00       	mov    0x802004,%eax
  800de0:	8b 40 7c             	mov    0x7c(%eax),%eax
  800de3:	89 06                	mov    %eax,(%esi)
    }
    cprintf("from env %d to env %d,recieve ok,value:%d\n",env->env_ipc_from,env->env_id,env->env_ipc_value);
  800de5:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800deb:	8b 42 74             	mov    0x74(%edx),%eax
  800dee:	50                   	push   %eax
  800def:	8b 42 4c             	mov    0x4c(%edx),%eax
  800df2:	50                   	push   %eax
  800df3:	8b 42 78             	mov    0x78(%edx),%eax
  800df6:	50                   	push   %eax
  800df7:	68 68 14 80 00       	push   $0x801468
  800dfc:	e8 83 f3 ff ff       	call   800184 <cprintf>
    return env->env_ipc_value;
  800e01:	a1 04 20 80 00       	mov    0x802004,%eax
  800e06:	8b 40 74             	mov    0x74(%eax),%eax
    panic("ipc_recv not implemented");
    return 0;
}
  800e09:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    

00800e10 <ipc_send>:

// Send 'val' (and 'pg' with 'perm', assuming 'pg' is nonnull) to 'toenv'.
// This function keeps trying until it succeeds.
// It should panic() on any error other than -E_IPC_NOT_RECV.
//
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 75 14             	mov    0x14(%ebp),%esi
    // LAB 4: Your code here.
    int r;
    while (1) {
        if(!pg) {
  800e22:	85 db                	test   %ebx,%ebx
  800e24:	75 05                	jne    800e2b <ipc_send+0x1b>
            pg = (void*)UTOP;
  800e26:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
        }
        r = sys_ipc_try_send(to_env,val,pg,perm);
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	57                   	push   %edi
  800e2e:	ff 75 08             	pushl  0x8(%ebp)
  800e31:	e8 d2 fe ff ff       	call   800d08 <sys_ipc_try_send>
        if (r == 0 || r == 1) {
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	83 f8 01             	cmp    $0x1,%eax
  800e3c:	76 1e                	jbe    800e5c <ipc_send+0x4c>
            break;
        } else if (r != -E_IPC_NOT_RECV) {
  800e3e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e41:	74 12                	je     800e55 <ipc_send+0x45>
            /*unknown err*/
            panic("ipc_send not ok: %e\n",r);
  800e43:	50                   	push   %eax
  800e44:	68 b7 14 80 00       	push   $0x8014b7
  800e49:	6a 46                	push   $0x46
  800e4b:	68 cc 14 80 00       	push   $0x8014cc
  800e50:	e8 27 00 00 00       	call   800e7c <_panic>
        }
        sys_yield();
  800e55:	e8 92 fc ff ff       	call   800aec <sys_yield>
  800e5a:	eb c6                	jmp    800e22 <ipc_send+0x12>
    }
    cprintf("env %d to env %d send ok,value:%d\n",env->env_id,to_env,val);
  800e5c:	57                   	push   %edi
  800e5d:	ff 75 08             	pushl  0x8(%ebp)
  800e60:	a1 04 20 80 00       	mov    0x802004,%eax
  800e65:	8b 40 4c             	mov    0x4c(%eax),%eax
  800e68:	50                   	push   %eax
  800e69:	68 94 14 80 00       	push   $0x801494
  800e6e:	e8 11 f3 ff ff       	call   800184 <cprintf>
}
  800e73:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5f                   	pop    %edi
  800e79:	c9                   	leave  
  800e7a:	c3                   	ret    
	...

00800e7c <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  800e83:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800e86:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e8d:	74 16                	je     800ea5 <_panic+0x29>
		cprintf("%s: ", argv0);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	ff 35 08 20 80 00    	pushl  0x802008
  800e98:	68 d6 14 80 00       	push   $0x8014d6
  800e9d:	e8 e2 f2 ff ff       	call   800184 <cprintf>
  800ea2:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800ea5:	ff 75 0c             	pushl  0xc(%ebp)
  800ea8:	ff 75 08             	pushl  0x8(%ebp)
  800eab:	ff 35 00 20 80 00    	pushl  0x802000
  800eb1:	68 db 14 80 00       	push   $0x8014db
  800eb6:	e8 c9 f2 ff ff       	call   800184 <cprintf>
	vcprintf(fmt, ap);
  800ebb:	83 c4 08             	add    $0x8,%esp
  800ebe:	53                   	push   %ebx
  800ebf:	ff 75 10             	pushl  0x10(%ebp)
  800ec2:	e8 6c f2 ff ff       	call   800133 <vcprintf>
	cprintf("\n");
  800ec7:	c7 04 24 ca 14 80 00 	movl   $0x8014ca,(%esp)
  800ece:	e8 b1 f2 ff ff       	call   800184 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800ed3:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800ed6:	cc                   	int3   
  800ed7:	eb fd                	jmp    800ed6 <_panic+0x5a>
}
  800ed9:	00 00                	add    %al,(%eax)
	...

00800edc <__udivdi3>:
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	83 ec 20             	sub    $0x20,%esp
  800ee4:	8b 55 14             	mov    0x14(%ebp),%edx
  800ee7:	8b 75 08             	mov    0x8(%ebp),%esi
  800eea:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800eed:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef0:	85 d2                	test   %edx,%edx
  800ef2:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800ef5:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800efc:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800f03:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800f06:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800f09:	89 fe                	mov    %edi,%esi
  800f0b:	75 5b                	jne    800f68 <__udivdi3+0x8c>
  800f0d:	39 f8                	cmp    %edi,%eax
  800f0f:	76 2b                	jbe    800f3c <__udivdi3+0x60>
  800f11:	89 fa                	mov    %edi,%edx
  800f13:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800f16:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f19:	89 c7                	mov    %eax,%edi
  800f1b:	90                   	nop    
  800f1c:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800f23:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800f26:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800f29:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800f2c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f2f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f32:	83 c4 20             	add    $0x20,%esp
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    
  800f39:	8d 76 00             	lea    0x0(%esi),%esi
  800f3c:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	75 0e                	jne    800f51 <__udivdi3+0x75>
  800f43:	b8 01 00 00 00       	mov    $0x1,%eax
  800f48:	31 c9                	xor    %ecx,%ecx
  800f4a:	31 d2                	xor    %edx,%edx
  800f4c:	f7 f1                	div    %ecx
  800f4e:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f58:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800f5b:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800f5e:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f61:	89 c7                	mov    %eax,%edi
  800f63:	eb be                	jmp    800f23 <__udivdi3+0x47>
  800f65:	8d 76 00             	lea    0x0(%esi),%esi
  800f68:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800f6b:	76 07                	jbe    800f74 <__udivdi3+0x98>
  800f6d:	31 ff                	xor    %edi,%edi
  800f6f:	eb ab                	jmp    800f1c <__udivdi3+0x40>
  800f71:	8d 76 00             	lea    0x0(%esi),%esi
  800f74:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800f78:	89 c7                	mov    %eax,%edi
  800f7a:	83 f7 1f             	xor    $0x1f,%edi
  800f7d:	75 19                	jne    800f98 <__udivdi3+0xbc>
  800f7f:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800f82:	77 0a                	ja     800f8e <__udivdi3+0xb2>
  800f84:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f87:	31 ff                	xor    %edi,%edi
  800f89:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800f8c:	72 8e                	jb     800f1c <__udivdi3+0x40>
  800f8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800f93:	eb 87                	jmp    800f1c <__udivdi3+0x40>
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
  800f98:	b8 20 00 00 00       	mov    $0x20,%eax
  800f9d:	29 f8                	sub    %edi,%eax
  800f9f:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800fa2:	89 f9                	mov    %edi,%ecx
  800fa4:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800fa7:	d3 e2                	shl    %cl,%edx
  800fa9:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800fac:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800faf:	d3 e8                	shr    %cl,%eax
  800fb1:	09 c2                	or     %eax,%edx
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800fb8:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800fbb:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800fbe:	89 f2                	mov    %esi,%edx
  800fc0:	d3 ea                	shr    %cl,%edx
  800fc2:	89 f9                	mov    %edi,%ecx
  800fc4:	d3 e6                	shl    %cl,%esi
  800fc6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800fc9:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800fcc:	d3 e8                	shr    %cl,%eax
  800fce:	09 c6                	or     %eax,%esi
  800fd0:	89 f9                	mov    %edi,%ecx
  800fd2:	89 f0                	mov    %esi,%eax
  800fd4:	f7 75 ec             	divl   0xffffffec(%ebp)
  800fd7:	89 d6                	mov    %edx,%esi
  800fd9:	89 c7                	mov    %eax,%edi
  800fdb:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800fde:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800fe1:	f7 e7                	mul    %edi
  800fe3:	39 f2                	cmp    %esi,%edx
  800fe5:	77 0f                	ja     800ff6 <__udivdi3+0x11a>
  800fe7:	0f 85 2f ff ff ff    	jne    800f1c <__udivdi3+0x40>
  800fed:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800ff0:	0f 86 26 ff ff ff    	jbe    800f1c <__udivdi3+0x40>
  800ff6:	4f                   	dec    %edi
  800ff7:	e9 20 ff ff ff       	jmp    800f1c <__udivdi3+0x40>

00800ffc <__umoddi3>:
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	83 ec 30             	sub    $0x30,%esp
  801004:	8b 55 14             	mov    0x14(%ebp),%edx
  801007:	8b 75 08             	mov    0x8(%ebp),%esi
  80100a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80100d:	8b 45 10             	mov    0x10(%ebp),%eax
  801010:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  801013:	85 d2                	test   %edx,%edx
  801015:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  80101c:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  801023:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  801026:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  801029:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80102c:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  80102f:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801032:	75 68                	jne    80109c <__umoddi3+0xa0>
  801034:	39 f8                	cmp    %edi,%eax
  801036:	76 3c                	jbe    801074 <__umoddi3+0x78>
  801038:	89 f0                	mov    %esi,%eax
  80103a:	89 fa                	mov    %edi,%edx
  80103c:	f7 75 cc             	divl   0xffffffcc(%ebp)
  80103f:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  801042:	85 c9                	test   %ecx,%ecx
  801044:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  801047:	74 1b                	je     801064 <__umoddi3+0x68>
  801049:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80104c:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  80104f:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  801056:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  801059:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  80105c:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  80105f:	89 10                	mov    %edx,(%eax)
  801061:	89 48 04             	mov    %ecx,0x4(%eax)
  801064:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801067:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80106a:	83 c4 30             	add    $0x30,%esp
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	c9                   	leave  
  801070:	c3                   	ret    
  801071:	8d 76 00             	lea    0x0(%esi),%esi
  801074:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  801077:	85 f6                	test   %esi,%esi
  801079:	75 0d                	jne    801088 <__umoddi3+0x8c>
  80107b:	b8 01 00 00 00       	mov    $0x1,%eax
  801080:	31 d2                	xor    %edx,%edx
  801082:	f7 75 cc             	divl   0xffffffcc(%ebp)
  801085:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  801088:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  80108b:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80108e:	f7 75 cc             	divl   0xffffffcc(%ebp)
  801091:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801094:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801097:	f7 75 cc             	divl   0xffffffcc(%ebp)
  80109a:	eb a3                	jmp    80103f <__umoddi3+0x43>
  80109c:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80109f:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  8010a2:	76 14                	jbe    8010b8 <__umoddi3+0xbc>
  8010a4:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  8010a7:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8010aa:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8010ad:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  8010b0:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8010b3:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8010b6:	eb ac                	jmp    801064 <__umoddi3+0x68>
  8010b8:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  8010bc:	89 c6                	mov    %eax,%esi
  8010be:	83 f6 1f             	xor    $0x1f,%esi
  8010c1:	75 4d                	jne    801110 <__umoddi3+0x114>
  8010c3:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8010c6:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  8010c9:	77 08                	ja     8010d3 <__umoddi3+0xd7>
  8010cb:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8010ce:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  8010d1:	72 12                	jb     8010e5 <__umoddi3+0xe9>
  8010d3:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8010d6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8010d9:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  8010dc:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  8010df:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8010e2:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8010e5:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8010e8:	85 d2                	test   %edx,%edx
  8010ea:	0f 84 74 ff ff ff    	je     801064 <__umoddi3+0x68>
  8010f0:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8010f3:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8010f6:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  8010f9:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8010fc:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  8010ff:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801102:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801105:	89 01                	mov    %eax,(%ecx)
  801107:	89 51 04             	mov    %edx,0x4(%ecx)
  80110a:	e9 55 ff ff ff       	jmp    801064 <__umoddi3+0x68>
  80110f:	90                   	nop    
  801110:	b8 20 00 00 00       	mov    $0x20,%eax
  801115:	29 f0                	sub    %esi,%eax
  801117:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80111a:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80111d:	89 f1                	mov    %esi,%ecx
  80111f:	d3 e2                	shl    %cl,%edx
  801121:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  801124:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801127:	d3 e8                	shr    %cl,%eax
  801129:	09 c2                	or     %eax,%edx
  80112b:	89 f1                	mov    %esi,%ecx
  80112d:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801130:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801133:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801136:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801139:	d3 ea                	shr    %cl,%edx
  80113b:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  80113e:	89 f1                	mov    %esi,%ecx
  801140:	d3 e7                	shl    %cl,%edi
  801142:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801145:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801148:	d3 e8                	shr    %cl,%eax
  80114a:	09 c7                	or     %eax,%edi
  80114c:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80114f:	89 f8                	mov    %edi,%eax
  801151:	89 f1                	mov    %esi,%ecx
  801153:	f7 75 dc             	divl   0xffffffdc(%ebp)
  801156:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801159:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  80115c:	f7 65 cc             	mull   0xffffffcc(%ebp)
  80115f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801162:	89 c7                	mov    %eax,%edi
  801164:	77 3f                	ja     8011a5 <__umoddi3+0x1a9>
  801166:	74 38                	je     8011a0 <__umoddi3+0x1a4>
  801168:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80116b:	85 c0                	test   %eax,%eax
  80116d:	0f 84 f1 fe ff ff    	je     801064 <__umoddi3+0x68>
  801173:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  801176:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801179:	29 f8                	sub    %edi,%eax
  80117b:	19 d1                	sbb    %edx,%ecx
  80117d:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  801180:	89 ca                	mov    %ecx,%edx
  801182:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801185:	d3 e2                	shl    %cl,%edx
  801187:	89 f1                	mov    %esi,%ecx
  801189:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  80118c:	d3 e8                	shr    %cl,%eax
  80118e:	09 c2                	or     %eax,%edx
  801190:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  801193:	d3 e8                	shr    %cl,%eax
  801195:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  801198:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80119b:	e9 b6 fe ff ff       	jmp    801056 <__umoddi3+0x5a>
  8011a0:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  8011a3:	76 c3                	jbe    801168 <__umoddi3+0x16c>
  8011a5:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  8011a8:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  8011ab:	eb bb                	jmp    801168 <__umoddi3+0x16c>
  8011ad:	90                   	nop    
  8011ae:	90                   	nop    
  8011af:	90                   	nop    
