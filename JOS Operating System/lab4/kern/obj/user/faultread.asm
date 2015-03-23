
obj/user/faultread：     文件格式 elf32-i386

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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	ff 35 00 00 00 00    	pushl  0x0
  800040:	68 80 10 80 00       	push   $0x801080
  800045:	e8 e6 00 00 00       	call   800130 <cprintf>
}
  80004a:	c9                   	leave  
  80004b:	c3                   	ret    

0080004c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	8b 75 08             	mov    0x8(%ebp),%esi
  800054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  800057:	e8 de 09 00 00       	call   800a3a <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	c1 e0 07             	shl    $0x7,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 07                	jle    800079 <libmain+0x2d>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	53                   	push   %ebx
  80007d:	56                   	push   %esi
  80007e:	e8 b1 ff ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  800083:	e8 08 00 00 00       	call   800090 <exit>
}
  800088:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    
	...

00800090 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 4c 09 00 00       	call   8009e9 <sys_env_destroy>
}
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    
	...

008000a0 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 04             	sub    $0x4,%esp
  8000a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000b3:	40                   	inc    %eax
  8000b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000bb:	75 1a                	jne    8000d7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	68 ff 00 00 00       	push   $0xff
  8000c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c8:	50                   	push   %eax
  8000c9:	e8 be 08 00 00       	call   80098c <sys_cputs>
		b->idx = 0;
  8000ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000d7:	ff 43 04             	incl   0x4(%ebx)
}
  8000da:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8000dd:	c9                   	leave  
  8000de:	c3                   	ret    

008000df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000e8:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8000ef:	00 00 00 
	b.cnt = 0;
  8000f2:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8000f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000fc:	ff 75 0c             	pushl  0xc(%ebp)
  8000ff:	ff 75 08             	pushl  0x8(%ebp)
  800102:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	68 a0 00 80 00       	push   $0x8000a0
  80010e:	e8 83 01 00 00       	call   800296 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800113:	83 c4 08             	add    $0x8,%esp
  800116:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  80011c:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800122:	50                   	push   %eax
  800123:	e8 64 08 00 00       	call   80098c <sys_cputs>

	return b.cnt;
  800128:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800136:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800139:	50                   	push   %eax
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	e8 9d ff ff ff       	call   8000df <vcprintf>
	va_end(ap);

	return cnt;
}
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	8b 75 10             	mov    0x10(%ebp),%esi
  800150:	8b 7d 14             	mov    0x14(%ebp),%edi
  800153:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800156:	8b 45 18             	mov    0x18(%ebp),%eax
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	39 d7                	cmp    %edx,%edi
  800160:	72 39                	jb     80019b <printnum+0x57>
  800162:	77 04                	ja     800168 <printnum+0x24>
  800164:	39 c6                	cmp    %eax,%esi
  800166:	72 33                	jb     80019b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	ff 75 20             	pushl  0x20(%ebp)
  80016e:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800171:	50                   	push   %eax
  800172:	ff 75 18             	pushl  0x18(%ebp)
  800175:	8b 45 18             	mov    0x18(%ebp),%eax
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	52                   	push   %edx
  80017e:	50                   	push   %eax
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	e8 12 0c 00 00       	call   800d98 <__udivdi3>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	52                   	push   %edx
  80018a:	50                   	push   %eax
  80018b:	ff 75 0c             	pushl  0xc(%ebp)
  80018e:	ff 75 08             	pushl  0x8(%ebp)
  800191:	e8 ae ff ff ff       	call   800144 <printnum>
  800196:	83 c4 20             	add    $0x20,%esp
  800199:	eb 19                	jmp    8001b4 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80019b:	4b                   	dec    %ebx
  80019c:	85 db                	test   %ebx,%ebx
  80019e:	7e 14                	jle    8001b4 <printnum+0x70>
			putch(padc, putdat);
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	ff 75 0c             	pushl  0xc(%ebp)
  8001a6:	ff 75 20             	pushl  0x20(%ebp)
  8001a9:	ff 55 08             	call   *0x8(%ebp)
  8001ac:	83 c4 10             	add    $0x10,%esp
  8001af:	4b                   	dec    %ebx
  8001b0:	85 db                	test   %ebx,%ebx
  8001b2:	7f ec                	jg     8001a0 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ba:	8b 45 18             	mov    0x18(%ebp),%eax
  8001bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c2:	83 ec 04             	sub    $0x4,%esp
  8001c5:	52                   	push   %edx
  8001c6:	50                   	push   %eax
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	e8 ea 0c 00 00       	call   800eb8 <__umoddi3>
  8001ce:	83 c4 14             	add    $0x14,%esp
  8001d1:	0f be 80 48 11 80 00 	movsbl 0x801148(%eax),%eax
  8001d8:	50                   	push   %eax
  8001d9:	ff 55 08             	call   *0x8(%ebp)
}
  8001dc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5f                   	pop    %edi
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 18             	sub    $0x18,%esp
  8001ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001f2:	8a 45 18             	mov    0x18(%ebp),%al
  8001f5:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  8001f8:	53                   	push   %ebx
  8001f9:	6a 1b                	push   $0x1b
  8001fb:	ff d6                	call   *%esi
	putch('[', putdat);
  8001fd:	83 c4 08             	add    $0x8,%esp
  800200:	53                   	push   %ebx
  800201:	6a 5b                	push   $0x5b
  800203:	ff d6                	call   *%esi
	putch('0', putdat);
  800205:	83 c4 08             	add    $0x8,%esp
  800208:	53                   	push   %ebx
  800209:	6a 30                	push   $0x30
  80020b:	ff d6                	call   *%esi
	putch(';', putdat);
  80020d:	83 c4 08             	add    $0x8,%esp
  800210:	53                   	push   %ebx
  800211:	6a 3b                	push   $0x3b
  800213:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800215:	83 c4 0c             	add    $0xc,%esp
  800218:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  80021c:	50                   	push   %eax
  80021d:	ff 75 14             	pushl  0x14(%ebp)
  800220:	6a 0a                	push   $0xa
  800222:	8b 45 10             	mov    0x10(%ebp),%eax
  800225:	99                   	cltd   
  800226:	52                   	push   %edx
  800227:	50                   	push   %eax
  800228:	53                   	push   %ebx
  800229:	56                   	push   %esi
  80022a:	e8 15 ff ff ff       	call   800144 <printnum>
	putch('m', putdat);
  80022f:	83 c4 18             	add    $0x18,%esp
  800232:	53                   	push   %ebx
  800233:	6a 6d                	push   $0x6d
  800235:	ff d6                	call   *%esi

}
  800237:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5e                   	pop    %esi
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800247:	83 f8 01             	cmp    $0x1,%eax
  80024a:	7e 0f                	jle    80025b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80024c:	8b 01                	mov    (%ecx),%eax
  80024e:	83 c0 08             	add    $0x8,%eax
  800251:	89 01                	mov    %eax,(%ecx)
  800253:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800256:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800259:	eb 0f                	jmp    80026a <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80025b:	8b 01                	mov    (%ecx),%eax
  80025d:	83 c0 04             	add    $0x4,%eax
  800260:	89 01                	mov    %eax,(%ecx)
  800262:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	8b 55 08             	mov    0x8(%ebp),%edx
  800272:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800275:	83 f8 01             	cmp    $0x1,%eax
  800278:	7e 0f                	jle    800289 <getint+0x1d>
		return va_arg(*ap, long long);
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	83 c0 08             	add    $0x8,%eax
  80027f:	89 02                	mov    %eax,(%edx)
  800281:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800284:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800287:	eb 0b                	jmp    800294 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	83 c0 04             	add    $0x4,%eax
  80028e:	89 02                	mov    %eax,(%edx)
  800290:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800293:	99                   	cltd   
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	57                   	push   %edi
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
  80029c:	83 ec 1c             	sub    $0x1c,%esp
  80029f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a2:	0f b6 13             	movzbl (%ebx),%edx
  8002a5:	43                   	inc    %ebx
  8002a6:	83 fa 25             	cmp    $0x25,%edx
  8002a9:	74 1e                	je     8002c9 <vprintfmt+0x33>
			if (ch == '\0')
  8002ab:	85 d2                	test   %edx,%edx
  8002ad:	0f 84 dc 02 00 00    	je     80058f <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	ff 75 0c             	pushl  0xc(%ebp)
  8002b9:	52                   	push   %edx
  8002ba:	ff 55 08             	call   *0x8(%ebp)
  8002bd:	83 c4 10             	add    $0x10,%esp
  8002c0:	0f b6 13             	movzbl (%ebx),%edx
  8002c3:	43                   	inc    %ebx
  8002c4:	83 fa 25             	cmp    $0x25,%edx
  8002c7:	75 e2                	jne    8002ab <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002c9:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8002cd:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8002d4:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8002de:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  8002e5:	0f b6 13             	movzbl (%ebx),%edx
  8002e8:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8002eb:	43                   	inc    %ebx
  8002ec:	83 f8 55             	cmp    $0x55,%eax
  8002ef:	0f 87 75 02 00 00    	ja     80056a <vprintfmt+0x2d4>
  8002f5:	ff 24 85 a4 11 80 00 	jmp    *0x8011a4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fc:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800300:	eb e3                	jmp    8002e5 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800302:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800306:	eb dd                	jmp    8002e5 <vprintfmt+0x4f>

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
  800308:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80030d:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800310:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800314:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800317:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80031a:	83 f8 09             	cmp    $0x9,%eax
  80031d:	77 27                	ja     800346 <vprintfmt+0xb0>
  80031f:	43                   	inc    %ebx
  800320:	eb eb                	jmp    80030d <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800322:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800326:	8b 45 14             	mov    0x14(%ebp),%eax
  800329:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  80032c:	eb 18                	jmp    800346 <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  80032e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800332:	79 b1                	jns    8002e5 <vprintfmt+0x4f>
				width = 0;
  800334:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80033b:	eb a8                	jmp    8002e5 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80033d:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800344:	eb 9f                	jmp    8002e5 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  800346:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80034a:	79 99                	jns    8002e5 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80034c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80034f:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800354:	eb 8f                	jmp    8002e5 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  800356:	41                   	inc    %ecx
			goto reswitch;
  800357:	eb 8c                	jmp    8002e5 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	ff 75 0c             	pushl  0xc(%ebp)
  80035f:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800363:	8b 45 14             	mov    0x14(%ebp),%eax
  800366:	ff 70 fc             	pushl  0xfffffffc(%eax)
  800369:	e9 c4 01 00 00       	jmp    800532 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  80036e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  800378:	85 c0                	test   %eax,%eax
  80037a:	79 02                	jns    80037e <vprintfmt+0xe8>
				err = -err;
  80037c:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80037e:	83 f8 08             	cmp    $0x8,%eax
  800381:	7f 0b                	jg     80038e <vprintfmt+0xf8>
  800383:	8b 3c 85 80 11 80 00 	mov    0x801180(,%eax,4),%edi
  80038a:	85 ff                	test   %edi,%edi
  80038c:	75 08                	jne    800396 <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  80038e:	50                   	push   %eax
  80038f:	68 59 11 80 00       	push   $0x801159
  800394:	eb 06                	jmp    80039c <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  800396:	57                   	push   %edi
  800397:	68 62 11 80 00       	push   $0x801162
  80039c:	ff 75 0c             	pushl  0xc(%ebp)
  80039f:	ff 75 08             	pushl  0x8(%ebp)
  8003a2:	e8 f0 01 00 00       	call   800597 <printfmt>
  8003a7:	e9 89 01 00 00       	jmp    800535 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ac:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8003b6:	85 ff                	test   %edi,%edi
  8003b8:	75 05                	jne    8003bf <vprintfmt+0x129>
				p = "(null)";
  8003ba:	bf 65 11 80 00       	mov    $0x801165,%edi
			if (width > 0 && padc != '-')
  8003bf:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003c3:	7e 3b                	jle    800400 <vprintfmt+0x16a>
  8003c5:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8003c9:	74 35                	je     800400 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	56                   	push   %esi
  8003cf:	57                   	push   %edi
  8003d0:	e8 74 02 00 00       	call   800649 <strnlen>
  8003d5:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003df:	7e 1f                	jle    800400 <vprintfmt+0x16a>
  8003e1:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8003e5:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	ff 75 0c             	pushl  0xc(%ebp)
  8003ee:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8003f1:	ff 55 08             	call   *0x8(%ebp)
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8003fa:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003fe:	7f e8                	jg     8003e8 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800400:	0f be 17             	movsbl (%edi),%edx
  800403:	47                   	inc    %edi
  800404:	85 d2                	test   %edx,%edx
  800406:	74 3e                	je     800446 <vprintfmt+0x1b0>
  800408:	85 f6                	test   %esi,%esi
  80040a:	78 03                	js     80040f <vprintfmt+0x179>
  80040c:	4e                   	dec    %esi
  80040d:	78 37                	js     800446 <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  80040f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800413:	74 12                	je     800427 <vprintfmt+0x191>
  800415:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800418:	83 f8 5e             	cmp    $0x5e,%eax
  80041b:	76 0a                	jbe    800427 <vprintfmt+0x191>
					putch('?', putdat);
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	ff 75 0c             	pushl  0xc(%ebp)
  800423:	6a 3f                	push   $0x3f
  800425:	eb 07                	jmp    80042e <vprintfmt+0x198>
				else
					putch(ch, putdat);
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	ff 75 0c             	pushl  0xc(%ebp)
  80042d:	52                   	push   %edx
  80042e:	ff 55 08             	call   *0x8(%ebp)
  800431:	83 c4 10             	add    $0x10,%esp
  800434:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800437:	0f be 17             	movsbl (%edi),%edx
  80043a:	47                   	inc    %edi
  80043b:	85 d2                	test   %edx,%edx
  80043d:	74 07                	je     800446 <vprintfmt+0x1b0>
  80043f:	85 f6                	test   %esi,%esi
  800441:	78 cc                	js     80040f <vprintfmt+0x179>
  800443:	4e                   	dec    %esi
  800444:	79 c9                	jns    80040f <vprintfmt+0x179>
			for (; width > 0; width--)
  800446:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80044a:	0f 8e 52 fe ff ff    	jle    8002a2 <vprintfmt+0xc>
				putch(' ', putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	ff 75 0c             	pushl  0xc(%ebp)
  800456:	6a 20                	push   $0x20
  800458:	ff 55 08             	call   *0x8(%ebp)
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800461:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800465:	7f e9                	jg     800450 <vprintfmt+0x1ba>
			break;
  800467:	e9 36 fe ff ff       	jmp    8002a2 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	51                   	push   %ecx
  800470:	8d 45 14             	lea    0x14(%ebp),%eax
  800473:	50                   	push   %eax
  800474:	e8 f3 fd ff ff       	call   80026c <getint>
  800479:	89 c6                	mov    %eax,%esi
  80047b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	85 d2                	test   %edx,%edx
  800482:	79 15                	jns    800499 <vprintfmt+0x203>
				putch('-', putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	ff 75 0c             	pushl  0xc(%ebp)
  80048a:	6a 2d                	push   $0x2d
  80048c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80048f:	f7 de                	neg    %esi
  800491:	83 d7 00             	adc    $0x0,%edi
  800494:	f7 df                	neg    %edi
  800496:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800499:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80049e:	eb 70                	jmp    800510 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	51                   	push   %ecx
  8004a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a7:	50                   	push   %eax
  8004a8:	e8 91 fd ff ff       	call   80023e <getuint>
  8004ad:	89 c6                	mov    %eax,%esi
  8004af:	89 d7                	mov    %edx,%edi
			base = 10;
  8004b1:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004b6:	eb 55                	jmp    80050d <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	51                   	push   %ecx
  8004bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 79 fd ff ff       	call   80023e <getuint>
  8004c5:	89 c6                	mov    %eax,%esi
  8004c7:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  8004c9:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8004ce:	eb 3d                	jmp    80050d <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	6a 30                	push   $0x30
  8004d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004db:	83 c4 08             	add    $0x8,%esp
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	6a 78                	push   $0x78
  8004e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8004e6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8004f0:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  8004f5:	eb 11                	jmp    800508 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	51                   	push   %ecx
  8004fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8004fe:	50                   	push   %eax
  8004ff:	e8 3a fd ff ff       	call   80023e <getuint>
  800504:	89 c6                	mov    %eax,%esi
  800506:	89 d7                	mov    %edx,%edi
			base = 16;
  800508:	ba 10 00 00 00       	mov    $0x10,%edx
  80050d:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800510:	83 ec 04             	sub    $0x4,%esp
  800513:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800517:	50                   	push   %eax
  800518:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80051b:	52                   	push   %edx
  80051c:	57                   	push   %edi
  80051d:	56                   	push   %esi
  80051e:	ff 75 0c             	pushl  0xc(%ebp)
  800521:	ff 75 08             	pushl  0x8(%ebp)
  800524:	e8 1b fc ff ff       	call   800144 <printnum>
			break;
  800529:	eb 37                	jmp    800562 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	52                   	push   %edx
  800532:	ff 55 08             	call   *0x8(%ebp)
			break;
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	e9 65 fd ff ff       	jmp    8002a2 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	51                   	push   %ecx
  800541:	8d 45 14             	lea    0x14(%ebp),%eax
  800544:	50                   	push   %eax
  800545:	e8 f4 fc ff ff       	call   80023e <getuint>
  80054a:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  80054c:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800556:	56                   	push   %esi
  800557:	ff 75 0c             	pushl  0xc(%ebp)
  80055a:	ff 75 08             	pushl  0x8(%ebp)
  80055d:	e8 82 fc ff ff       	call   8001e4 <printcolor>
			break;
  800562:	83 c4 20             	add    $0x20,%esp
  800565:	e9 38 fd ff ff       	jmp    8002a2 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	ff 75 0c             	pushl  0xc(%ebp)
  800570:	6a 25                	push   $0x25
  800572:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800575:	4b                   	dec    %ebx
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80057d:	0f 84 1f fd ff ff    	je     8002a2 <vprintfmt+0xc>
  800583:	4b                   	dec    %ebx
  800584:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800588:	75 f9                	jne    800583 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80058a:	e9 13 fd ff ff       	jmp    8002a2 <vprintfmt+0xc>
		}
	}
}
  80058f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800592:	5b                   	pop    %ebx
  800593:	5e                   	pop    %esi
  800594:	5f                   	pop    %edi
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80059d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005a0:	50                   	push   %eax
  8005a1:	ff 75 10             	pushl  0x10(%ebp)
  8005a4:	ff 75 0c             	pushl  0xc(%ebp)
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 e7 fc ff ff       	call   800296 <vprintfmt>
	va_end(ap);
}
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005b7:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005ba:	8b 0a                	mov    (%edx),%ecx
  8005bc:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005bf:	73 07                	jae    8005c8 <sprintputch+0x17>
		*b->buf++ = ch;
  8005c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c4:	88 01                	mov    %al,(%ecx)
  8005c6:	ff 02                	incl   (%edx)
}
  8005c8:	c9                   	leave  
  8005c9:	c3                   	ret    

008005ca <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	83 ec 18             	sub    $0x18,%esp
  8005d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8005d6:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8005d9:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8005dd:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8005e0:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8005e7:	85 d2                	test   %edx,%edx
  8005e9:	74 04                	je     8005ef <vsnprintf+0x25>
  8005eb:	85 c9                	test   %ecx,%ecx
  8005ed:	7f 07                	jg     8005f6 <vsnprintf+0x2c>
		return -E_INVAL;
  8005ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005f4:	eb 1d                	jmp    800613 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  8005f6:	ff 75 14             	pushl  0x14(%ebp)
  8005f9:	ff 75 10             	pushl  0x10(%ebp)
  8005fc:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8005ff:	50                   	push   %eax
  800600:	68 b1 05 80 00       	push   $0x8005b1
  800605:	e8 8c fc ff ff       	call   800296 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80060a:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80060d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800610:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800613:	c9                   	leave  
  800614:	c3                   	ret    

00800615 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800615:	55                   	push   %ebp
  800616:	89 e5                	mov    %esp,%ebp
  800618:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80061e:	50                   	push   %eax
  80061f:	ff 75 10             	pushl  0x10(%ebp)
  800622:	ff 75 0c             	pushl  0xc(%ebp)
  800625:	ff 75 08             	pushl  0x8(%ebp)
  800628:	e8 9d ff ff ff       	call   8005ca <vsnprintf>
	va_end(ap);

	return rc;
}
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    
	...

00800630 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800636:	b8 00 00 00 00       	mov    $0x0,%eax
  80063b:	80 3a 00             	cmpb   $0x0,(%edx)
  80063e:	74 07                	je     800647 <strlen+0x17>
		n++;
  800640:	40                   	inc    %eax
  800641:	42                   	inc    %edx
  800642:	80 3a 00             	cmpb   $0x0,(%edx)
  800645:	75 f9                	jne    800640 <strlen+0x10>
	return n;
}
  800647:	c9                   	leave  
  800648:	c3                   	ret    

00800649 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800649:	55                   	push   %ebp
  80064a:	89 e5                	mov    %esp,%ebp
  80064c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800652:	b8 00 00 00 00       	mov    $0x0,%eax
  800657:	85 d2                	test   %edx,%edx
  800659:	74 0f                	je     80066a <strnlen+0x21>
  80065b:	80 39 00             	cmpb   $0x0,(%ecx)
  80065e:	74 0a                	je     80066a <strnlen+0x21>
		n++;
  800660:	40                   	inc    %eax
  800661:	41                   	inc    %ecx
  800662:	4a                   	dec    %edx
  800663:	74 05                	je     80066a <strnlen+0x21>
  800665:	80 39 00             	cmpb   $0x0,(%ecx)
  800668:	75 f6                	jne    800660 <strnlen+0x17>
	return n;
}
  80066a:	c9                   	leave  
  80066b:	c3                   	ret    

0080066c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	53                   	push   %ebx
  800670:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800673:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800676:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800678:	8a 02                	mov    (%edx),%al
  80067a:	42                   	inc    %edx
  80067b:	88 01                	mov    %al,(%ecx)
  80067d:	41                   	inc    %ecx
  80067e:	84 c0                	test   %al,%al
  800680:	75 f6                	jne    800678 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800682:	89 d8                	mov    %ebx,%eax
  800684:	5b                   	pop    %ebx
  800685:	c9                   	leave  
  800686:	c3                   	ret    

00800687 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	57                   	push   %edi
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
  80068d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800690:	8b 55 0c             	mov    0xc(%ebp),%edx
  800693:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800696:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069d:	39 f3                	cmp    %esi,%ebx
  80069f:	73 10                	jae    8006b1 <strncpy+0x2a>
		*dst++ = *src;
  8006a1:	8a 02                	mov    (%edx),%al
  8006a3:	88 01                	mov    %al,(%ecx)
  8006a5:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8006a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006a9:	74 01                	je     8006ac <strncpy+0x25>
			src++;
  8006ab:	42                   	inc    %edx
  8006ac:	43                   	inc    %ebx
  8006ad:	39 f3                	cmp    %esi,%ebx
  8006af:	72 f0                	jb     8006a1 <strncpy+0x1a>
	}
	return ret;
}
  8006b1:	89 f8                	mov    %edi,%eax
  8006b3:	5b                   	pop    %ebx
  8006b4:	5e                   	pop    %esi
  8006b5:	5f                   	pop    %edi
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	56                   	push   %esi
  8006bc:	53                   	push   %ebx
  8006bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8006c6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	74 19                	je     8006e5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8006cc:	4a                   	dec    %edx
  8006cd:	74 13                	je     8006e2 <strlcpy+0x2a>
  8006cf:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d2:	74 0e                	je     8006e2 <strlcpy+0x2a>
			*dst++ = *src++;
  8006d4:	8a 01                	mov    (%ecx),%al
  8006d6:	41                   	inc    %ecx
  8006d7:	88 03                	mov    %al,(%ebx)
  8006d9:	43                   	inc    %ebx
  8006da:	4a                   	dec    %edx
  8006db:	74 05                	je     8006e2 <strlcpy+0x2a>
  8006dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e0:	75 f2                	jne    8006d4 <strlcpy+0x1c>
		*dst = '\0';
  8006e2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8006e5:	89 d8                	mov    %ebx,%eax
  8006e7:	29 f0                	sub    %esi,%eax
}
  8006e9:	5b                   	pop    %ebx
  8006ea:	5e                   	pop    %esi
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    

008006ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8006f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f9:	74 13                	je     80070e <strcmp+0x21>
  8006fb:	8a 02                	mov    (%edx),%al
  8006fd:	3a 01                	cmp    (%ecx),%al
  8006ff:	75 0d                	jne    80070e <strcmp+0x21>
		p++, q++;
  800701:	42                   	inc    %edx
  800702:	41                   	inc    %ecx
  800703:	80 3a 00             	cmpb   $0x0,(%edx)
  800706:	74 06                	je     80070e <strcmp+0x21>
  800708:	8a 02                	mov    (%edx),%al
  80070a:	3a 01                	cmp    (%ecx),%al
  80070c:	74 f3                	je     800701 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80070e:	0f b6 02             	movzbl (%edx),%eax
  800711:	0f b6 11             	movzbl (%ecx),%edx
  800714:	29 d0                	sub    %edx,%eax
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 55 08             	mov    0x8(%ebp),%edx
  80071f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800722:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800725:	85 c9                	test   %ecx,%ecx
  800727:	74 1f                	je     800748 <strncmp+0x30>
  800729:	80 3a 00             	cmpb   $0x0,(%edx)
  80072c:	74 16                	je     800744 <strncmp+0x2c>
  80072e:	8a 02                	mov    (%edx),%al
  800730:	3a 03                	cmp    (%ebx),%al
  800732:	75 10                	jne    800744 <strncmp+0x2c>
		n--, p++, q++;
  800734:	42                   	inc    %edx
  800735:	43                   	inc    %ebx
  800736:	49                   	dec    %ecx
  800737:	74 0f                	je     800748 <strncmp+0x30>
  800739:	80 3a 00             	cmpb   $0x0,(%edx)
  80073c:	74 06                	je     800744 <strncmp+0x2c>
  80073e:	8a 02                	mov    (%edx),%al
  800740:	3a 03                	cmp    (%ebx),%al
  800742:	74 f0                	je     800734 <strncmp+0x1c>
	if (n == 0)
  800744:	85 c9                	test   %ecx,%ecx
  800746:	75 07                	jne    80074f <strncmp+0x37>
		return 0;
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	eb 0a                	jmp    800759 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80074f:	0f b6 12             	movzbl (%edx),%edx
  800752:	0f b6 03             	movzbl (%ebx),%eax
  800755:	29 c2                	sub    %eax,%edx
  800757:	89 d0                	mov    %edx,%eax
}
  800759:	8b 1c 24             	mov    (%esp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800767:	80 38 00             	cmpb   $0x0,(%eax)
  80076a:	74 0a                	je     800776 <strchr+0x18>
		if (*s == c)
  80076c:	38 10                	cmp    %dl,(%eax)
  80076e:	74 0b                	je     80077b <strchr+0x1d>
  800770:	40                   	inc    %eax
  800771:	80 38 00             	cmpb   $0x0,(%eax)
  800774:	75 f6                	jne    80076c <strchr+0xe>
			return (char *) s;
	return 0;
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800786:	80 38 00             	cmpb   $0x0,(%eax)
  800789:	74 0a                	je     800795 <strfind+0x18>
		if (*s == c)
  80078b:	38 10                	cmp    %dl,(%eax)
  80078d:	74 06                	je     800795 <strfind+0x18>
  80078f:	40                   	inc    %eax
  800790:	80 38 00             	cmpb   $0x0,(%eax)
  800793:	75 f6                	jne    80078b <strfind+0xe>
			break;
	return (char *) s;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	57                   	push   %edi
  80079b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80079e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8007a1:	89 f8                	mov    %edi,%eax
  8007a3:	85 c9                	test   %ecx,%ecx
  8007a5:	74 40                	je     8007e7 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007a7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007ad:	75 30                	jne    8007df <memset+0x48>
  8007af:	f6 c1 03             	test   $0x3,%cl
  8007b2:	75 2b                	jne    8007df <memset+0x48>
		c &= 0xFF;
  8007b4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8007bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007be:	c1 e0 18             	shl    $0x18,%eax
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c4:	c1 e2 10             	shl    $0x10,%edx
  8007c7:	09 d0                	or     %edx,%eax
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cc:	c1 e2 08             	shl    $0x8,%edx
  8007cf:	09 d0                	or     %edx,%eax
  8007d1:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8007d4:	c1 e9 02             	shr    $0x2,%ecx
  8007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007da:	fc                   	cld    
  8007db:	f3 ab                	repz stos %eax,%es:(%edi)
  8007dd:	eb 06                	jmp    8007e5 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e2:	fc                   	cld    
  8007e3:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8007e5:	89 f8                	mov    %edi,%eax
}
  8007e7:	8b 3c 24             	mov    (%esp),%edi
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	57                   	push   %edi
  8007f0:	56                   	push   %esi
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8007f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8007fa:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8007fc:	39 c6                	cmp    %eax,%esi
  8007fe:	73 33                	jae    800833 <memmove+0x47>
  800800:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800803:	39 c2                	cmp    %eax,%edx
  800805:	76 2c                	jbe    800833 <memmove+0x47>
		s += n;
  800807:	89 d6                	mov    %edx,%esi
		d += n;
  800809:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80080c:	f6 c2 03             	test   $0x3,%dl
  80080f:	75 1b                	jne    80082c <memmove+0x40>
  800811:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800817:	75 13                	jne    80082c <memmove+0x40>
  800819:	f6 c1 03             	test   $0x3,%cl
  80081c:	75 0e                	jne    80082c <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80081e:	83 ef 04             	sub    $0x4,%edi
  800821:	83 ee 04             	sub    $0x4,%esi
  800824:	c1 e9 02             	shr    $0x2,%ecx
  800827:	fd                   	std    
  800828:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80082a:	eb 27                	jmp    800853 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80082c:	4f                   	dec    %edi
  80082d:	4e                   	dec    %esi
  80082e:	fd                   	std    
  80082f:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800831:	eb 20                	jmp    800853 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800833:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800839:	75 15                	jne    800850 <memmove+0x64>
  80083b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800841:	75 0d                	jne    800850 <memmove+0x64>
  800843:	f6 c1 03             	test   $0x3,%cl
  800846:	75 08                	jne    800850 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800848:	c1 e9 02             	shr    $0x2,%ecx
  80084b:	fc                   	cld    
  80084c:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80084e:	eb 03                	jmp    800853 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800850:	fc                   	cld    
  800851:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800853:	5e                   	pop    %esi
  800854:	5f                   	pop    %edi
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <memcpy>:

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
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80085d:	ff 75 10             	pushl  0x10(%ebp)
  800860:	ff 75 0c             	pushl  0xc(%ebp)
  800863:	ff 75 08             	pushl  0x8(%ebp)
  800866:	e8 81 ff ff ff       	call   8007ec <memmove>
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800874:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800877:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  80087a:	89 d0                	mov    %edx,%eax
  80087c:	4a                   	dec    %edx
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 1b                	je     80089c <memcmp+0x2f>
		if (*s1 != *s2)
  800881:	8a 01                	mov    (%ecx),%al
  800883:	3a 03                	cmp    (%ebx),%al
  800885:	74 0c                	je     800893 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800887:	0f b6 d0             	movzbl %al,%edx
  80088a:	0f b6 03             	movzbl (%ebx),%eax
  80088d:	29 c2                	sub    %eax,%edx
  80088f:	89 d0                	mov    %edx,%eax
  800891:	eb 0e                	jmp    8008a1 <memcmp+0x34>
		s1++, s2++;
  800893:	41                   	inc    %ecx
  800894:	43                   	inc    %ebx
  800895:	89 d0                	mov    %edx,%eax
  800897:	4a                   	dec    %edx
  800898:	85 c0                	test   %eax,%eax
  80089a:	75 e5                	jne    800881 <memcmp+0x14>
	}

	return 0;
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008b2:	39 d0                	cmp    %edx,%eax
  8008b4:	73 09                	jae    8008bf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008b6:	38 08                	cmp    %cl,(%eax)
  8008b8:	74 05                	je     8008bf <memfind+0x1b>
  8008ba:	40                   	inc    %eax
  8008bb:	39 d0                	cmp    %edx,%eax
  8008bd:	72 f7                	jb     8008b6 <memfind+0x12>
			break;
	return (void *) s;
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	57                   	push   %edi
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8008d0:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8008d5:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008da:	80 3a 20             	cmpb   $0x20,(%edx)
  8008dd:	74 05                	je     8008e4 <strtol+0x23>
  8008df:	80 3a 09             	cmpb   $0x9,(%edx)
  8008e2:	75 0b                	jne    8008ef <strtol+0x2e>
		s++;
  8008e4:	42                   	inc    %edx
  8008e5:	80 3a 20             	cmpb   $0x20,(%edx)
  8008e8:	74 fa                	je     8008e4 <strtol+0x23>
  8008ea:	80 3a 09             	cmpb   $0x9,(%edx)
  8008ed:	74 f5                	je     8008e4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8008ef:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8008f2:	75 03                	jne    8008f7 <strtol+0x36>
		s++;
  8008f4:	42                   	inc    %edx
  8008f5:	eb 0b                	jmp    800902 <strtol+0x41>
	else if (*s == '-')
  8008f7:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8008fa:	75 06                	jne    800902 <strtol+0x41>
		s++, neg = 1;
  8008fc:	42                   	inc    %edx
  8008fd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800902:	85 c9                	test   %ecx,%ecx
  800904:	74 05                	je     80090b <strtol+0x4a>
  800906:	83 f9 10             	cmp    $0x10,%ecx
  800909:	75 15                	jne    800920 <strtol+0x5f>
  80090b:	80 3a 30             	cmpb   $0x30,(%edx)
  80090e:	75 10                	jne    800920 <strtol+0x5f>
  800910:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800914:	75 0a                	jne    800920 <strtol+0x5f>
		s += 2, base = 16;
  800916:	83 c2 02             	add    $0x2,%edx
  800919:	b9 10 00 00 00       	mov    $0x10,%ecx
  80091e:	eb 1a                	jmp    80093a <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800920:	85 c9                	test   %ecx,%ecx
  800922:	75 16                	jne    80093a <strtol+0x79>
  800924:	80 3a 30             	cmpb   $0x30,(%edx)
  800927:	75 08                	jne    800931 <strtol+0x70>
		s++, base = 8;
  800929:	42                   	inc    %edx
  80092a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80092f:	eb 09                	jmp    80093a <strtol+0x79>
	else if (base == 0)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	75 05                	jne    80093a <strtol+0x79>
		base = 10;
  800935:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80093a:	8a 02                	mov    (%edx),%al
  80093c:	83 e8 30             	sub    $0x30,%eax
  80093f:	3c 09                	cmp    $0x9,%al
  800941:	77 08                	ja     80094b <strtol+0x8a>
			dig = *s - '0';
  800943:	0f be 02             	movsbl (%edx),%eax
  800946:	83 e8 30             	sub    $0x30,%eax
  800949:	eb 20                	jmp    80096b <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  80094b:	8a 02                	mov    (%edx),%al
  80094d:	83 e8 61             	sub    $0x61,%eax
  800950:	3c 19                	cmp    $0x19,%al
  800952:	77 08                	ja     80095c <strtol+0x9b>
			dig = *s - 'a' + 10;
  800954:	0f be 02             	movsbl (%edx),%eax
  800957:	83 e8 57             	sub    $0x57,%eax
  80095a:	eb 0f                	jmp    80096b <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  80095c:	8a 02                	mov    (%edx),%al
  80095e:	83 e8 41             	sub    $0x41,%eax
  800961:	3c 19                	cmp    $0x19,%al
  800963:	77 12                	ja     800977 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800965:	0f be 02             	movsbl (%edx),%eax
  800968:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  80096b:	39 c8                	cmp    %ecx,%eax
  80096d:	7d 08                	jge    800977 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  80096f:	42                   	inc    %edx
  800970:	0f af d9             	imul   %ecx,%ebx
  800973:	01 c3                	add    %eax,%ebx
  800975:	eb c3                	jmp    80093a <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800977:	85 f6                	test   %esi,%esi
  800979:	74 02                	je     80097d <strtol+0xbc>
		*endptr = (char *) s;
  80097b:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80097d:	89 d8                	mov    %ebx,%eax
  80097f:	85 ff                	test   %edi,%edi
  800981:	74 02                	je     800985 <strtol+0xc4>
  800983:	f7 d8                	neg    %eax
}
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	c9                   	leave  
  800989:	c3                   	ret    
	...

0080098c <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 55 08             	mov    0x8(%ebp),%edx
  800995:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800998:	bf 00 00 00 00       	mov    $0x0,%edi
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	89 fb                	mov    %edi,%ebx
  8009a1:	89 fe                	mov    %edi,%esi
  8009a3:	55                   	push   %ebp
  8009a4:	9c                   	pushf  
  8009a5:	56                   	push   %esi
  8009a6:	54                   	push   %esp
  8009a7:	5d                   	pop    %ebp
  8009a8:	8d 35 b0 09 80 00    	lea    0x8009b0,%esi
  8009ae:	0f 34                	sysenter 
  8009b0:	83 c4 04             	add    $0x4,%esp
  8009b3:	9d                   	popf   
  8009b4:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <sys_cgetc>:

int
sys_cgetc(void)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	57                   	push   %edi
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ca:	89 fa                	mov    %edi,%edx
  8009cc:	89 f9                	mov    %edi,%ecx
  8009ce:	89 fb                	mov    %edi,%ebx
  8009d0:	89 fe                	mov    %edi,%esi
  8009d2:	55                   	push   %ebp
  8009d3:	9c                   	pushf  
  8009d4:	56                   	push   %esi
  8009d5:	54                   	push   %esp
  8009d6:	5d                   	pop    %ebp
  8009d7:	8d 35 df 09 80 00    	lea    0x8009df,%esi
  8009dd:	0f 34                	sysenter 
  8009df:	83 c4 04             	add    $0x4,%esp
  8009e2:	9d                   	popf   
  8009e3:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	83 ec 0c             	sub    $0xc,%esp
  8009f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8009fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ff:	89 f9                	mov    %edi,%ecx
  800a01:	89 fb                	mov    %edi,%ebx
  800a03:	89 fe                	mov    %edi,%esi
  800a05:	55                   	push   %ebp
  800a06:	9c                   	pushf  
  800a07:	56                   	push   %esi
  800a08:	54                   	push   %esp
  800a09:	5d                   	pop    %ebp
  800a0a:	8d 35 12 0a 80 00    	lea    0x800a12,%esi
  800a10:	0f 34                	sysenter 
  800a12:	83 c4 04             	add    $0x4,%esp
  800a15:	9d                   	popf   
  800a16:	5d                   	pop    %ebp
  800a17:	85 c0                	test   %eax,%eax
  800a19:	7e 17                	jle    800a32 <sys_env_destroy+0x49>
  800a1b:	83 ec 0c             	sub    $0xc,%esp
  800a1e:	50                   	push   %eax
  800a1f:	6a 03                	push   $0x3
  800a21:	68 fc 12 80 00       	push   $0x8012fc
  800a26:	6a 4c                	push   $0x4c
  800a28:	68 19 13 80 00       	push   $0x801319
  800a2d:	e8 06 03 00 00       	call   800d38 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a32:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	b8 02 00 00 00       	mov    $0x2,%eax
  800a45:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4a:	89 fa                	mov    %edi,%edx
  800a4c:	89 f9                	mov    %edi,%ecx
  800a4e:	89 fb                	mov    %edi,%ebx
  800a50:	89 fe                	mov    %edi,%esi
  800a52:	55                   	push   %ebp
  800a53:	9c                   	pushf  
  800a54:	56                   	push   %esi
  800a55:	54                   	push   %esp
  800a56:	5d                   	pop    %ebp
  800a57:	8d 35 5f 0a 80 00    	lea    0x800a5f,%esi
  800a5d:	0f 34                	sysenter 
  800a5f:	83 c4 04             	add    $0x4,%esp
  800a62:	9d                   	popf   
  800a63:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <sys_dump_env>:

int
sys_dump_env(void)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a74:	bf 00 00 00 00       	mov    $0x0,%edi
  800a79:	89 fa                	mov    %edi,%edx
  800a7b:	89 f9                	mov    %edi,%ecx
  800a7d:	89 fb                	mov    %edi,%ebx
  800a7f:	89 fe                	mov    %edi,%esi
  800a81:	55                   	push   %ebp
  800a82:	9c                   	pushf  
  800a83:	56                   	push   %esi
  800a84:	54                   	push   %esp
  800a85:	5d                   	pop    %ebp
  800a86:	8d 35 8e 0a 80 00    	lea    0x800a8e,%esi
  800a8c:	0f 34                	sysenter 
  800a8e:	83 c4 04             	add    $0x4,%esp
  800a91:	9d                   	popf   
  800a92:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5f                   	pop    %edi
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <sys_yield>:

void
sys_yield(void)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa8:	89 fa                	mov    %edi,%edx
  800aaa:	89 f9                	mov    %edi,%ecx
  800aac:	89 fb                	mov    %edi,%ebx
  800aae:	89 fe                	mov    %edi,%esi
  800ab0:	55                   	push   %ebp
  800ab1:	9c                   	pushf  
  800ab2:	56                   	push   %esi
  800ab3:	54                   	push   %esp
  800ab4:	5d                   	pop    %ebp
  800ab5:	8d 35 bd 0a 80 00    	lea    0x800abd,%esi
  800abb:	0f 34                	sysenter 
  800abd:	83 c4 04             	add    $0x4,%esp
  800ac0:	9d                   	popf   
  800ac1:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	83 ec 0c             	sub    $0xc,%esp
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ad9:	b8 05 00 00 00       	mov    $0x5,%eax
  800ade:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae3:	89 fe                	mov    %edi,%esi
  800ae5:	55                   	push   %ebp
  800ae6:	9c                   	pushf  
  800ae7:	56                   	push   %esi
  800ae8:	54                   	push   %esp
  800ae9:	5d                   	pop    %ebp
  800aea:	8d 35 f2 0a 80 00    	lea    0x800af2,%esi
  800af0:	0f 34                	sysenter 
  800af2:	83 c4 04             	add    $0x4,%esp
  800af5:	9d                   	popf   
  800af6:	5d                   	pop    %ebp
  800af7:	85 c0                	test   %eax,%eax
  800af9:	7e 17                	jle    800b12 <sys_page_alloc+0x4b>
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	50                   	push   %eax
  800aff:	6a 05                	push   $0x5
  800b01:	68 fc 12 80 00       	push   $0x8012fc
  800b06:	6a 4c                	push   $0x4c
  800b08:	68 19 13 80 00       	push   $0x801319
  800b0d:	e8 26 02 00 00       	call   800d38 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b12:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b2f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b32:	b8 06 00 00 00       	mov    $0x6,%eax
  800b37:	55                   	push   %ebp
  800b38:	9c                   	pushf  
  800b39:	56                   	push   %esi
  800b3a:	54                   	push   %esp
  800b3b:	5d                   	pop    %ebp
  800b3c:	8d 35 44 0b 80 00    	lea    0x800b44,%esi
  800b42:	0f 34                	sysenter 
  800b44:	83 c4 04             	add    $0x4,%esp
  800b47:	9d                   	popf   
  800b48:	5d                   	pop    %ebp
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	7e 17                	jle    800b64 <sys_page_map+0x4a>
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	50                   	push   %eax
  800b51:	6a 06                	push   $0x6
  800b53:	68 fc 12 80 00       	push   $0x8012fc
  800b58:	6a 4c                	push   $0x4c
  800b5a:	68 19 13 80 00       	push   $0x801319
  800b5f:	e8 d4 01 00 00       	call   800d38 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800b64:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7b:	b8 07 00 00 00       	mov    $0x7,%eax
  800b80:	bf 00 00 00 00       	mov    $0x0,%edi
  800b85:	89 fb                	mov    %edi,%ebx
  800b87:	89 fe                	mov    %edi,%esi
  800b89:	55                   	push   %ebp
  800b8a:	9c                   	pushf  
  800b8b:	56                   	push   %esi
  800b8c:	54                   	push   %esp
  800b8d:	5d                   	pop    %ebp
  800b8e:	8d 35 96 0b 80 00    	lea    0x800b96,%esi
  800b94:	0f 34                	sysenter 
  800b96:	83 c4 04             	add    $0x4,%esp
  800b99:	9d                   	popf   
  800b9a:	5d                   	pop    %ebp
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_unmap+0x4a>
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 07                	push   $0x7
  800ba5:	68 fc 12 80 00       	push   $0x8012fc
  800baa:	6a 4c                	push   $0x4c
  800bac:	68 19 13 80 00       	push   $0x801319
  800bb1:	e8 82 01 00 00       	call   800d38 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bb6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	b8 09 00 00 00       	mov    $0x9,%eax
  800bd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd7:	89 fb                	mov    %edi,%ebx
  800bd9:	89 fe                	mov    %edi,%esi
  800bdb:	55                   	push   %ebp
  800bdc:	9c                   	pushf  
  800bdd:	56                   	push   %esi
  800bde:	54                   	push   %esp
  800bdf:	5d                   	pop    %ebp
  800be0:	8d 35 e8 0b 80 00    	lea    0x800be8,%esi
  800be6:	0f 34                	sysenter 
  800be8:	83 c4 04             	add    $0x4,%esp
  800beb:	9d                   	popf   
  800bec:	5d                   	pop    %ebp
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_env_set_status+0x4a>
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 09                	push   $0x9
  800bf7:	68 fc 12 80 00       	push   $0x8012fc
  800bfc:	6a 4c                	push   $0x4c
  800bfe:	68 19 13 80 00       	push   $0x801319
  800c03:	e8 30 01 00 00       	call   800d38 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c08:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c24:	bf 00 00 00 00       	mov    $0x0,%edi
  800c29:	89 fb                	mov    %edi,%ebx
  800c2b:	89 fe                	mov    %edi,%esi
  800c2d:	55                   	push   %ebp
  800c2e:	9c                   	pushf  
  800c2f:	56                   	push   %esi
  800c30:	54                   	push   %esp
  800c31:	5d                   	pop    %ebp
  800c32:	8d 35 3a 0c 80 00    	lea    0x800c3a,%esi
  800c38:	0f 34                	sysenter 
  800c3a:	83 c4 04             	add    $0x4,%esp
  800c3d:	9d                   	popf   
  800c3e:	5d                   	pop    %ebp
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 17                	jle    800c5a <sys_env_set_trapframe+0x4a>
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 0a                	push   $0xa
  800c49:	68 fc 12 80 00       	push   $0x8012fc
  800c4e:	6a 4c                	push   $0x4c
  800c50:	68 19 13 80 00       	push   $0x801319
  800c55:	e8 de 00 00 00       	call   800d38 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c76:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7b:	89 fb                	mov    %edi,%ebx
  800c7d:	89 fe                	mov    %edi,%esi
  800c7f:	55                   	push   %ebp
  800c80:	9c                   	pushf  
  800c81:	56                   	push   %esi
  800c82:	54                   	push   %esp
  800c83:	5d                   	pop    %ebp
  800c84:	8d 35 8c 0c 80 00    	lea    0x800c8c,%esi
  800c8a:	0f 34                	sysenter 
  800c8c:	83 c4 04             	add    $0x4,%esp
  800c8f:	9d                   	popf   
  800c90:	5d                   	pop    %ebp
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 17                	jle    800cac <sys_env_set_pgfault_upcall+0x4a>
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 0b                	push   $0xb
  800c9b:	68 fc 12 80 00       	push   $0x8012fc
  800ca0:	6a 4c                	push   $0x4c
  800ca2:	68 19 13 80 00       	push   $0x801319
  800ca7:	e8 8c 00 00 00       	call   800d38 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
  800cd0:	55                   	push   %ebp
  800cd1:	9c                   	pushf  
  800cd2:	56                   	push   %esi
  800cd3:	54                   	push   %esp
  800cd4:	5d                   	pop    %ebp
  800cd5:	8d 35 dd 0c 80 00    	lea    0x800cdd,%esi
  800cdb:	0f 34                	sysenter 
  800cdd:	83 c4 04             	add    $0x4,%esp
  800ce0:	9d                   	popf   
  800ce1:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cf8:	bf 00 00 00 00       	mov    $0x0,%edi
  800cfd:	89 f9                	mov    %edi,%ecx
  800cff:	89 fb                	mov    %edi,%ebx
  800d01:	89 fe                	mov    %edi,%esi
  800d03:	55                   	push   %ebp
  800d04:	9c                   	pushf  
  800d05:	56                   	push   %esi
  800d06:	54                   	push   %esp
  800d07:	5d                   	pop    %ebp
  800d08:	8d 35 10 0d 80 00    	lea    0x800d10,%esi
  800d0e:	0f 34                	sysenter 
  800d10:	83 c4 04             	add    $0x4,%esp
  800d13:	9d                   	popf   
  800d14:	5d                   	pop    %ebp
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7e 17                	jle    800d30 <sys_ipc_recv+0x49>
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 0e                	push   $0xe
  800d1f:	68 fc 12 80 00       	push   $0x8012fc
  800d24:	6a 4c                	push   $0x4c
  800d26:	68 19 13 80 00       	push   $0x801319
  800d2b:	e8 08 00 00 00       	call   800d38 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  800d3f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800d42:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d49:	74 16                	je     800d61 <_panic+0x29>
		cprintf("%s: ", argv0);
  800d4b:	83 ec 08             	sub    $0x8,%esp
  800d4e:	ff 35 08 20 80 00    	pushl  0x802008
  800d54:	68 27 13 80 00       	push   $0x801327
  800d59:	e8 d2 f3 ff ff       	call   800130 <cprintf>
  800d5e:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800d61:	ff 75 0c             	pushl  0xc(%ebp)
  800d64:	ff 75 08             	pushl  0x8(%ebp)
  800d67:	ff 35 00 20 80 00    	pushl  0x802000
  800d6d:	68 2c 13 80 00       	push   $0x80132c
  800d72:	e8 b9 f3 ff ff       	call   800130 <cprintf>
	vcprintf(fmt, ap);
  800d77:	83 c4 08             	add    $0x8,%esp
  800d7a:	53                   	push   %ebx
  800d7b:	ff 75 10             	pushl  0x10(%ebp)
  800d7e:	e8 5c f3 ff ff       	call   8000df <vcprintf>
	cprintf("\n");
  800d83:	c7 04 24 9c 10 80 00 	movl   $0x80109c,(%esp)
  800d8a:	e8 a1 f3 ff ff       	call   800130 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800d8f:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800d92:	cc                   	int3   
  800d93:	eb fd                	jmp    800d92 <_panic+0x5a>
}
  800d95:	00 00                	add    %al,(%eax)
	...

00800d98 <__udivdi3>:
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	83 ec 20             	sub    $0x20,%esp
  800da0:	8b 55 14             	mov    0x14(%ebp),%edx
  800da3:	8b 75 08             	mov    0x8(%ebp),%esi
  800da6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800da9:	8b 45 10             	mov    0x10(%ebp),%eax
  800dac:	85 d2                	test   %edx,%edx
  800dae:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800db1:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800db8:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800dbf:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800dc2:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800dc5:	89 fe                	mov    %edi,%esi
  800dc7:	75 5b                	jne    800e24 <__udivdi3+0x8c>
  800dc9:	39 f8                	cmp    %edi,%eax
  800dcb:	76 2b                	jbe    800df8 <__udivdi3+0x60>
  800dcd:	89 fa                	mov    %edi,%edx
  800dcf:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800dd2:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800dd5:	89 c7                	mov    %eax,%edi
  800dd7:	90                   	nop    
  800dd8:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800ddf:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800de2:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800de5:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800de8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800deb:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800dee:	83 c4 20             	add    $0x20,%esp
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	75 0e                	jne    800e0d <__udivdi3+0x75>
  800dff:	b8 01 00 00 00       	mov    $0x1,%eax
  800e04:	31 c9                	xor    %ecx,%ecx
  800e06:	31 d2                	xor    %edx,%edx
  800e08:	f7 f1                	div    %ecx
  800e0a:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	31 d2                	xor    %edx,%edx
  800e11:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e14:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e17:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e1a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e1d:	89 c7                	mov    %eax,%edi
  800e1f:	eb be                	jmp    800ddf <__udivdi3+0x47>
  800e21:	8d 76 00             	lea    0x0(%esi),%esi
  800e24:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800e27:	76 07                	jbe    800e30 <__udivdi3+0x98>
  800e29:	31 ff                	xor    %edi,%edi
  800e2b:	eb ab                	jmp    800dd8 <__udivdi3+0x40>
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
  800e30:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800e34:	89 c7                	mov    %eax,%edi
  800e36:	83 f7 1f             	xor    $0x1f,%edi
  800e39:	75 19                	jne    800e54 <__udivdi3+0xbc>
  800e3b:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800e3e:	77 0a                	ja     800e4a <__udivdi3+0xb2>
  800e40:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e43:	31 ff                	xor    %edi,%edi
  800e45:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800e48:	72 8e                	jb     800dd8 <__udivdi3+0x40>
  800e4a:	bf 01 00 00 00       	mov    $0x1,%edi
  800e4f:	eb 87                	jmp    800dd8 <__udivdi3+0x40>
  800e51:	8d 76 00             	lea    0x0(%esi),%esi
  800e54:	b8 20 00 00 00       	mov    $0x20,%eax
  800e59:	29 f8                	sub    %edi,%eax
  800e5b:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800e5e:	89 f9                	mov    %edi,%ecx
  800e60:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800e63:	d3 e2                	shl    %cl,%edx
  800e65:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e68:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e6b:	d3 e8                	shr    %cl,%eax
  800e6d:	09 c2                	or     %eax,%edx
  800e6f:	89 f9                	mov    %edi,%ecx
  800e71:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800e74:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e77:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e7a:	89 f2                	mov    %esi,%edx
  800e7c:	d3 ea                	shr    %cl,%edx
  800e7e:	89 f9                	mov    %edi,%ecx
  800e80:	d3 e6                	shl    %cl,%esi
  800e82:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e85:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e88:	d3 e8                	shr    %cl,%eax
  800e8a:	09 c6                	or     %eax,%esi
  800e8c:	89 f9                	mov    %edi,%ecx
  800e8e:	89 f0                	mov    %esi,%eax
  800e90:	f7 75 ec             	divl   0xffffffec(%ebp)
  800e93:	89 d6                	mov    %edx,%esi
  800e95:	89 c7                	mov    %eax,%edi
  800e97:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800e9a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e9d:	f7 e7                	mul    %edi
  800e9f:	39 f2                	cmp    %esi,%edx
  800ea1:	77 0f                	ja     800eb2 <__udivdi3+0x11a>
  800ea3:	0f 85 2f ff ff ff    	jne    800dd8 <__udivdi3+0x40>
  800ea9:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800eac:	0f 86 26 ff ff ff    	jbe    800dd8 <__udivdi3+0x40>
  800eb2:	4f                   	dec    %edi
  800eb3:	e9 20 ff ff ff       	jmp    800dd8 <__udivdi3+0x40>

00800eb8 <__umoddi3>:
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	83 ec 30             	sub    $0x30,%esp
  800ec0:	8b 55 14             	mov    0x14(%ebp),%edx
  800ec3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ec6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ec9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecc:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800ecf:	85 d2                	test   %edx,%edx
  800ed1:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800ed8:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800edf:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800ee2:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800ee5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800ee8:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800eeb:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800eee:	75 68                	jne    800f58 <__umoddi3+0xa0>
  800ef0:	39 f8                	cmp    %edi,%eax
  800ef2:	76 3c                	jbe    800f30 <__umoddi3+0x78>
  800ef4:	89 f0                	mov    %esi,%eax
  800ef6:	89 fa                	mov    %edi,%edx
  800ef8:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800efb:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800efe:	85 c9                	test   %ecx,%ecx
  800f00:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800f03:	74 1b                	je     800f20 <__umoddi3+0x68>
  800f05:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f08:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800f0b:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f12:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f15:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800f18:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800f1b:	89 10                	mov    %edx,(%eax)
  800f1d:	89 48 04             	mov    %ecx,0x4(%eax)
  800f20:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f23:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f26:	83 c4 30             	add    $0x30,%esp
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  800f33:	85 f6                	test   %esi,%esi
  800f35:	75 0d                	jne    800f44 <__umoddi3+0x8c>
  800f37:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3c:	31 d2                	xor    %edx,%edx
  800f3e:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f41:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f44:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800f47:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f4a:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f4d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f50:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f53:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f56:	eb a3                	jmp    800efb <__umoddi3+0x43>
  800f58:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f5b:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800f5e:	76 14                	jbe    800f74 <__umoddi3+0xbc>
  800f60:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800f63:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800f66:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800f69:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800f6c:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800f6f:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800f72:	eb ac                	jmp    800f20 <__umoddi3+0x68>
  800f74:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800f78:	89 c6                	mov    %eax,%esi
  800f7a:	83 f6 1f             	xor    $0x1f,%esi
  800f7d:	75 4d                	jne    800fcc <__umoddi3+0x114>
  800f7f:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f82:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800f85:	77 08                	ja     800f8f <__umoddi3+0xd7>
  800f87:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  800f8a:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800f8d:	72 12                	jb     800fa1 <__umoddi3+0xe9>
  800f8f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f92:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f95:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  800f98:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800f9b:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800f9e:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800fa1:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800fa4:	85 d2                	test   %edx,%edx
  800fa6:	0f 84 74 ff ff ff    	je     800f20 <__umoddi3+0x68>
  800fac:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800faf:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fb2:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800fb5:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800fb8:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800fbb:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800fbe:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800fc1:	89 01                	mov    %eax,(%ecx)
  800fc3:	89 51 04             	mov    %edx,0x4(%ecx)
  800fc6:	e9 55 ff ff ff       	jmp    800f20 <__umoddi3+0x68>
  800fcb:	90                   	nop    
  800fcc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fd1:	29 f0                	sub    %esi,%eax
  800fd3:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800fd6:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800fd9:	89 f1                	mov    %esi,%ecx
  800fdb:	d3 e2                	shl    %cl,%edx
  800fdd:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800fe0:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800fe3:	d3 e8                	shr    %cl,%eax
  800fe5:	09 c2                	or     %eax,%edx
  800fe7:	89 f1                	mov    %esi,%ecx
  800fe9:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  800fec:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800fef:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800ff2:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800ff5:	d3 ea                	shr    %cl,%edx
  800ff7:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  800ffa:	89 f1                	mov    %esi,%ecx
  800ffc:	d3 e7                	shl    %cl,%edi
  800ffe:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801001:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801004:	d3 e8                	shr    %cl,%eax
  801006:	09 c7                	or     %eax,%edi
  801008:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80100b:	89 f8                	mov    %edi,%eax
  80100d:	89 f1                	mov    %esi,%ecx
  80100f:	f7 75 dc             	divl   0xffffffdc(%ebp)
  801012:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801015:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801018:	f7 65 cc             	mull   0xffffffcc(%ebp)
  80101b:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  80101e:	89 c7                	mov    %eax,%edi
  801020:	77 3f                	ja     801061 <__umoddi3+0x1a9>
  801022:	74 38                	je     80105c <__umoddi3+0x1a4>
  801024:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  801027:	85 c0                	test   %eax,%eax
  801029:	0f 84 f1 fe ff ff    	je     800f20 <__umoddi3+0x68>
  80102f:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  801032:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801035:	29 f8                	sub    %edi,%eax
  801037:	19 d1                	sbb    %edx,%ecx
  801039:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80103c:	89 ca                	mov    %ecx,%edx
  80103e:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801041:	d3 e2                	shl    %cl,%edx
  801043:	89 f1                	mov    %esi,%ecx
  801045:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801048:	d3 e8                	shr    %cl,%eax
  80104a:	09 c2                	or     %eax,%edx
  80104c:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  80104f:	d3 e8                	shr    %cl,%eax
  801051:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  801054:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  801057:	e9 b6 fe ff ff       	jmp    800f12 <__umoddi3+0x5a>
  80105c:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  80105f:	76 c3                	jbe    801024 <__umoddi3+0x16c>
  801061:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  801064:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  801067:	eb bb                	jmp    801024 <__umoddi3+0x16c>
  801069:	90                   	nop    
  80106a:	90                   	nop    
  80106b:	90                   	nop    
