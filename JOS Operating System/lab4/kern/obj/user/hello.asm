
obj/user/hello：     文件格式 elf32-i386

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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
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
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003a:	68 80 10 80 00       	push   $0x801080
  80003f:	e8 fc 00 00 00       	call   800140 <cprintf>
	cprintf("i am environment %08x\n", env->env_id);
  800044:	83 c4 08             	add    $0x8,%esp
  800047:	a1 04 20 80 00       	mov    0x802004,%eax
  80004c:	8b 40 4c             	mov    0x4c(%eax),%eax
  80004f:	50                   	push   %eax
  800050:	68 8e 10 80 00       	push   $0x80108e
  800055:	e8 e6 00 00 00       	call   800140 <cprintf>
}
  80005a:	c9                   	leave  
  80005b:	c3                   	ret    

0080005c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 75 08             	mov    0x8(%ebp),%esi
  800064:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  800067:	e8 de 09 00 00       	call   800a4a <sys_getenvid>
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	c1 e0 07             	shl    $0x7,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 f6                	test   %esi,%esi
  800080:	7e 07                	jle    800089 <libmain+0x2d>
		binaryname = argv[0];
  800082:	8b 03                	mov    (%ebx),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	53                   	push   %ebx
  80008d:	56                   	push   %esi
  80008e:	e8 a1 ff ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  800093:	e8 08 00 00 00       	call   8000a0 <exit>
}
  800098:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    
	...

008000a0 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 4c 09 00 00       	call   8009f9 <sys_env_destroy>
}
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    
	...

008000b0 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 04             	sub    $0x4,%esp
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000c3:	40                   	inc    %eax
  8000c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 be 08 00 00       	call   80099c <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	ff 43 04             	incl   0x4(%ebx)
}
  8000ea:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f8:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8000ff:	00 00 00 
	b.cnt = 0;
  800102:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800109:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010c:	ff 75 0c             	pushl  0xc(%ebp)
  80010f:	ff 75 08             	pushl  0x8(%ebp)
  800112:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800118:	50                   	push   %eax
  800119:	68 b0 00 80 00       	push   $0x8000b0
  80011e:	e8 83 01 00 00       	call   8002a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800123:	83 c4 08             	add    $0x8,%esp
  800126:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  80012c:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800132:	50                   	push   %eax
  800133:	e8 64 08 00 00       	call   80099c <sys_cputs>

	return b.cnt;
  800138:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800146:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800149:	50                   	push   %eax
  80014a:	ff 75 08             	pushl  0x8(%ebp)
  80014d:	e8 9d ff ff ff       	call   8000ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 0c             	sub    $0xc,%esp
  80015d:	8b 75 10             	mov    0x10(%ebp),%esi
  800160:	8b 7d 14             	mov    0x14(%ebp),%edi
  800163:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800166:	8b 45 18             	mov    0x18(%ebp),%eax
  800169:	ba 00 00 00 00       	mov    $0x0,%edx
  80016e:	39 d7                	cmp    %edx,%edi
  800170:	72 39                	jb     8001ab <printnum+0x57>
  800172:	77 04                	ja     800178 <printnum+0x24>
  800174:	39 c6                	cmp    %eax,%esi
  800176:	72 33                	jb     8001ab <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	ff 75 20             	pushl  0x20(%ebp)
  80017e:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800181:	50                   	push   %eax
  800182:	ff 75 18             	pushl  0x18(%ebp)
  800185:	8b 45 18             	mov    0x18(%ebp),%eax
  800188:	ba 00 00 00 00       	mov    $0x0,%edx
  80018d:	52                   	push   %edx
  80018e:	50                   	push   %eax
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	e8 12 0c 00 00       	call   800da8 <__udivdi3>
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	52                   	push   %edx
  80019a:	50                   	push   %eax
  80019b:	ff 75 0c             	pushl  0xc(%ebp)
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 ae ff ff ff       	call   800154 <printnum>
  8001a6:	83 c4 20             	add    $0x20,%esp
  8001a9:	eb 19                	jmp    8001c4 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ab:	4b                   	dec    %ebx
  8001ac:	85 db                	test   %ebx,%ebx
  8001ae:	7e 14                	jle    8001c4 <printnum+0x70>
			putch(padc, putdat);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	ff 75 0c             	pushl  0xc(%ebp)
  8001b6:	ff 75 20             	pushl  0x20(%ebp)
  8001b9:	ff 55 08             	call   *0x8(%ebp)
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	4b                   	dec    %ebx
  8001c0:	85 db                	test   %ebx,%ebx
  8001c2:	7f ec                	jg     8001b0 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001c4:	83 ec 08             	sub    $0x8,%esp
  8001c7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ca:	8b 45 18             	mov    0x18(%ebp),%eax
  8001cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	52                   	push   %edx
  8001d6:	50                   	push   %eax
  8001d7:	57                   	push   %edi
  8001d8:	56                   	push   %esi
  8001d9:	e8 ea 0c 00 00       	call   800ec8 <__umoddi3>
  8001de:	83 c4 14             	add    $0x14,%esp
  8001e1:	0f be 80 4f 11 80 00 	movsbl 0x80114f(%eax),%eax
  8001e8:	50                   	push   %eax
  8001e9:	ff 55 08             	call   *0x8(%ebp)
}
  8001ec:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5e                   	pop    %esi
  8001f1:	5f                   	pop    %edi
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	56                   	push   %esi
  8001f8:	53                   	push   %ebx
  8001f9:	83 ec 18             	sub    $0x18,%esp
  8001fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800202:	8a 45 18             	mov    0x18(%ebp),%al
  800205:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  800208:	53                   	push   %ebx
  800209:	6a 1b                	push   $0x1b
  80020b:	ff d6                	call   *%esi
	putch('[', putdat);
  80020d:	83 c4 08             	add    $0x8,%esp
  800210:	53                   	push   %ebx
  800211:	6a 5b                	push   $0x5b
  800213:	ff d6                	call   *%esi
	putch('0', putdat);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	53                   	push   %ebx
  800219:	6a 30                	push   $0x30
  80021b:	ff d6                	call   *%esi
	putch(';', putdat);
  80021d:	83 c4 08             	add    $0x8,%esp
  800220:	53                   	push   %ebx
  800221:	6a 3b                	push   $0x3b
  800223:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800225:	83 c4 0c             	add    $0xc,%esp
  800228:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  80022c:	50                   	push   %eax
  80022d:	ff 75 14             	pushl  0x14(%ebp)
  800230:	6a 0a                	push   $0xa
  800232:	8b 45 10             	mov    0x10(%ebp),%eax
  800235:	99                   	cltd   
  800236:	52                   	push   %edx
  800237:	50                   	push   %eax
  800238:	53                   	push   %ebx
  800239:	56                   	push   %esi
  80023a:	e8 15 ff ff ff       	call   800154 <printnum>
	putch('m', putdat);
  80023f:	83 c4 18             	add    $0x18,%esp
  800242:	53                   	push   %ebx
  800243:	6a 6d                	push   $0x6d
  800245:	ff d6                	call   *%esi

}
  800247:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800254:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800257:	83 f8 01             	cmp    $0x1,%eax
  80025a:	7e 0f                	jle    80026b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80025c:	8b 01                	mov    (%ecx),%eax
  80025e:	83 c0 08             	add    $0x8,%eax
  800261:	89 01                	mov    %eax,(%ecx)
  800263:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800266:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800269:	eb 0f                	jmp    80027a <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80026b:	8b 01                	mov    (%ecx),%eax
  80026d:	83 c0 04             	add    $0x4,%eax
  800270:	89 01                	mov    %eax,(%ecx)
  800272:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800285:	83 f8 01             	cmp    $0x1,%eax
  800288:	7e 0f                	jle    800299 <getint+0x1d>
		return va_arg(*ap, long long);
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	83 c0 08             	add    $0x8,%eax
  80028f:	89 02                	mov    %eax,(%edx)
  800291:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800294:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800297:	eb 0b                	jmp    8002a4 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	83 c0 04             	add    $0x4,%eax
  80029e:	89 02                	mov    %eax,(%edx)
  8002a0:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002a3:	99                   	cltd   
}
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
  8002ac:	83 ec 1c             	sub    $0x1c,%esp
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b2:	0f b6 13             	movzbl (%ebx),%edx
  8002b5:	43                   	inc    %ebx
  8002b6:	83 fa 25             	cmp    $0x25,%edx
  8002b9:	74 1e                	je     8002d9 <vprintfmt+0x33>
			if (ch == '\0')
  8002bb:	85 d2                	test   %edx,%edx
  8002bd:	0f 84 dc 02 00 00    	je     80059f <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	ff 75 0c             	pushl  0xc(%ebp)
  8002c9:	52                   	push   %edx
  8002ca:	ff 55 08             	call   *0x8(%ebp)
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	0f b6 13             	movzbl (%ebx),%edx
  8002d3:	43                   	inc    %ebx
  8002d4:	83 fa 25             	cmp    $0x25,%edx
  8002d7:	75 e2                	jne    8002bb <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002d9:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8002dd:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8002e4:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002e9:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8002ee:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  8002f5:	0f b6 13             	movzbl (%ebx),%edx
  8002f8:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8002fb:	43                   	inc    %ebx
  8002fc:	83 f8 55             	cmp    $0x55,%eax
  8002ff:	0f 87 75 02 00 00    	ja     80057a <vprintfmt+0x2d4>
  800305:	ff 24 85 a4 11 80 00 	jmp    *0x8011a4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  80030c:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800310:	eb e3                	jmp    8002f5 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800312:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800316:	eb dd                	jmp    8002f5 <vprintfmt+0x4f>

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
  800318:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80031d:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800320:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800324:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800327:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80032a:	83 f8 09             	cmp    $0x9,%eax
  80032d:	77 27                	ja     800356 <vprintfmt+0xb0>
  80032f:	43                   	inc    %ebx
  800330:	eb eb                	jmp    80031d <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800332:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  80033c:	eb 18                	jmp    800356 <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  80033e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800342:	79 b1                	jns    8002f5 <vprintfmt+0x4f>
				width = 0;
  800344:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80034b:	eb a8                	jmp    8002f5 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80034d:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800354:	eb 9f                	jmp    8002f5 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  800356:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80035a:	79 99                	jns    8002f5 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80035c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80035f:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800364:	eb 8f                	jmp    8002f5 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  800366:	41                   	inc    %ecx
			goto reswitch;
  800367:	eb 8c                	jmp    8002f5 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	ff 75 0c             	pushl  0xc(%ebp)
  80036f:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	ff 70 fc             	pushl  0xfffffffc(%eax)
  800379:	e9 c4 01 00 00       	jmp    800542 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  80037e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800382:	8b 45 14             	mov    0x14(%ebp),%eax
  800385:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  800388:	85 c0                	test   %eax,%eax
  80038a:	79 02                	jns    80038e <vprintfmt+0xe8>
				err = -err;
  80038c:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80038e:	83 f8 08             	cmp    $0x8,%eax
  800391:	7f 0b                	jg     80039e <vprintfmt+0xf8>
  800393:	8b 3c 85 80 11 80 00 	mov    0x801180(,%eax,4),%edi
  80039a:	85 ff                	test   %edi,%edi
  80039c:	75 08                	jne    8003a6 <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  80039e:	50                   	push   %eax
  80039f:	68 60 11 80 00       	push   $0x801160
  8003a4:	eb 06                	jmp    8003ac <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8003a6:	57                   	push   %edi
  8003a7:	68 69 11 80 00       	push   $0x801169
  8003ac:	ff 75 0c             	pushl  0xc(%ebp)
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 f0 01 00 00       	call   8005a7 <printfmt>
  8003b7:	e9 89 01 00 00       	jmp    800545 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003bc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8003c6:	85 ff                	test   %edi,%edi
  8003c8:	75 05                	jne    8003cf <vprintfmt+0x129>
				p = "(null)";
  8003ca:	bf 6c 11 80 00       	mov    $0x80116c,%edi
			if (width > 0 && padc != '-')
  8003cf:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003d3:	7e 3b                	jle    800410 <vprintfmt+0x16a>
  8003d5:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8003d9:	74 35                	je     800410 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	56                   	push   %esi
  8003df:	57                   	push   %edi
  8003e0:	e8 74 02 00 00       	call   800659 <strnlen>
  8003e5:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8003e8:	83 c4 10             	add    $0x10,%esp
  8003eb:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003ef:	7e 1f                	jle    800410 <vprintfmt+0x16a>
  8003f1:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8003f5:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	ff 75 0c             	pushl  0xc(%ebp)
  8003fe:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  800401:	ff 55 08             	call   *0x8(%ebp)
  800404:	83 c4 10             	add    $0x10,%esp
  800407:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80040a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80040e:	7f e8                	jg     8003f8 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800410:	0f be 17             	movsbl (%edi),%edx
  800413:	47                   	inc    %edi
  800414:	85 d2                	test   %edx,%edx
  800416:	74 3e                	je     800456 <vprintfmt+0x1b0>
  800418:	85 f6                	test   %esi,%esi
  80041a:	78 03                	js     80041f <vprintfmt+0x179>
  80041c:	4e                   	dec    %esi
  80041d:	78 37                	js     800456 <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  80041f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800423:	74 12                	je     800437 <vprintfmt+0x191>
  800425:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800428:	83 f8 5e             	cmp    $0x5e,%eax
  80042b:	76 0a                	jbe    800437 <vprintfmt+0x191>
					putch('?', putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	ff 75 0c             	pushl  0xc(%ebp)
  800433:	6a 3f                	push   $0x3f
  800435:	eb 07                	jmp    80043e <vprintfmt+0x198>
				else
					putch(ch, putdat);
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	ff 75 0c             	pushl  0xc(%ebp)
  80043d:	52                   	push   %edx
  80043e:	ff 55 08             	call   *0x8(%ebp)
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800447:	0f be 17             	movsbl (%edi),%edx
  80044a:	47                   	inc    %edi
  80044b:	85 d2                	test   %edx,%edx
  80044d:	74 07                	je     800456 <vprintfmt+0x1b0>
  80044f:	85 f6                	test   %esi,%esi
  800451:	78 cc                	js     80041f <vprintfmt+0x179>
  800453:	4e                   	dec    %esi
  800454:	79 c9                	jns    80041f <vprintfmt+0x179>
			for (; width > 0; width--)
  800456:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80045a:	0f 8e 52 fe ff ff    	jle    8002b2 <vprintfmt+0xc>
				putch(' ', putdat);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	ff 75 0c             	pushl  0xc(%ebp)
  800466:	6a 20                	push   $0x20
  800468:	ff 55 08             	call   *0x8(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800471:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800475:	7f e9                	jg     800460 <vprintfmt+0x1ba>
			break;
  800477:	e9 36 fe ff ff       	jmp    8002b2 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	51                   	push   %ecx
  800480:	8d 45 14             	lea    0x14(%ebp),%eax
  800483:	50                   	push   %eax
  800484:	e8 f3 fd ff ff       	call   80027c <getint>
  800489:	89 c6                	mov    %eax,%esi
  80048b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	85 d2                	test   %edx,%edx
  800492:	79 15                	jns    8004a9 <vprintfmt+0x203>
				putch('-', putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	ff 75 0c             	pushl  0xc(%ebp)
  80049a:	6a 2d                	push   $0x2d
  80049c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80049f:	f7 de                	neg    %esi
  8004a1:	83 d7 00             	adc    $0x0,%edi
  8004a4:	f7 df                	neg    %edi
  8004a6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004a9:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004ae:	eb 70                	jmp    800520 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	51                   	push   %ecx
  8004b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8004b7:	50                   	push   %eax
  8004b8:	e8 91 fd ff ff       	call   80024e <getuint>
  8004bd:	89 c6                	mov    %eax,%esi
  8004bf:	89 d7                	mov    %edx,%edi
			base = 10;
  8004c1:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004c6:	eb 55                	jmp    80051d <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	51                   	push   %ecx
  8004cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8004cf:	50                   	push   %eax
  8004d0:	e8 79 fd ff ff       	call   80024e <getuint>
  8004d5:	89 c6                	mov    %eax,%esi
  8004d7:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  8004d9:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8004de:	eb 3d                	jmp    80051d <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	6a 30                	push   $0x30
  8004e8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004eb:	83 c4 08             	add    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 78                	push   $0x78
  8004f3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8004f6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800500:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  800505:	eb 11                	jmp    800518 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	51                   	push   %ecx
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
  80050e:	50                   	push   %eax
  80050f:	e8 3a fd ff ff       	call   80024e <getuint>
  800514:	89 c6                	mov    %eax,%esi
  800516:	89 d7                	mov    %edx,%edi
			base = 16;
  800518:	ba 10 00 00 00       	mov    $0x10,%edx
  80051d:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800520:	83 ec 04             	sub    $0x4,%esp
  800523:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800527:	50                   	push   %eax
  800528:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80052b:	52                   	push   %edx
  80052c:	57                   	push   %edi
  80052d:	56                   	push   %esi
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	ff 75 08             	pushl  0x8(%ebp)
  800534:	e8 1b fc ff ff       	call   800154 <printnum>
			break;
  800539:	eb 37                	jmp    800572 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
			break;
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	e9 65 fd ff ff       	jmp    8002b2 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	51                   	push   %ecx
  800551:	8d 45 14             	lea    0x14(%ebp),%eax
  800554:	50                   	push   %eax
  800555:	e8 f4 fc ff ff       	call   80024e <getuint>
  80055a:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  80055c:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800566:	56                   	push   %esi
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 82 fc ff ff       	call   8001f4 <printcolor>
			break;
  800572:	83 c4 20             	add    $0x20,%esp
  800575:	e9 38 fd ff ff       	jmp    8002b2 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	ff 75 0c             	pushl  0xc(%ebp)
  800580:	6a 25                	push   $0x25
  800582:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800585:	4b                   	dec    %ebx
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80058d:	0f 84 1f fd ff ff    	je     8002b2 <vprintfmt+0xc>
  800593:	4b                   	dec    %ebx
  800594:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800598:	75 f9                	jne    800593 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80059a:	e9 13 fd ff ff       	jmp    8002b2 <vprintfmt+0xc>
		}
	}
}
  80059f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8005a2:	5b                   	pop    %ebx
  8005a3:	5e                   	pop    %esi
  8005a4:	5f                   	pop    %edi
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    

008005a7 <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005b0:	50                   	push   %eax
  8005b1:	ff 75 10             	pushl  0x10(%ebp)
  8005b4:	ff 75 0c             	pushl  0xc(%ebp)
  8005b7:	ff 75 08             	pushl  0x8(%ebp)
  8005ba:	e8 e7 fc ff ff       	call   8002a6 <vprintfmt>
	va_end(ap);
}
  8005bf:	c9                   	leave  
  8005c0:	c3                   	ret    

008005c1 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8005c1:	55                   	push   %ebp
  8005c2:	89 e5                	mov    %esp,%ebp
  8005c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005c7:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005ca:	8b 0a                	mov    (%edx),%ecx
  8005cc:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005cf:	73 07                	jae    8005d8 <sprintputch+0x17>
		*b->buf++ = ch;
  8005d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d4:	88 01                	mov    %al,(%ecx)
  8005d6:	ff 02                	incl   (%edx)
}
  8005d8:	c9                   	leave  
  8005d9:	c3                   	ret    

008005da <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8005da:	55                   	push   %ebp
  8005db:	89 e5                	mov    %esp,%ebp
  8005dd:	83 ec 18             	sub    $0x18,%esp
  8005e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8005e6:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8005e9:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8005ed:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8005f0:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8005f7:	85 d2                	test   %edx,%edx
  8005f9:	74 04                	je     8005ff <vsnprintf+0x25>
  8005fb:	85 c9                	test   %ecx,%ecx
  8005fd:	7f 07                	jg     800606 <vsnprintf+0x2c>
		return -E_INVAL;
  8005ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800604:	eb 1d                	jmp    800623 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  800606:	ff 75 14             	pushl  0x14(%ebp)
  800609:	ff 75 10             	pushl  0x10(%ebp)
  80060c:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  80060f:	50                   	push   %eax
  800610:	68 c1 05 80 00       	push   $0x8005c1
  800615:	e8 8c fc ff ff       	call   8002a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80061a:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80061d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800620:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800623:	c9                   	leave  
  800624:	c3                   	ret    

00800625 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  800628:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80062e:	50                   	push   %eax
  80062f:	ff 75 10             	pushl  0x10(%ebp)
  800632:	ff 75 0c             	pushl  0xc(%ebp)
  800635:	ff 75 08             	pushl  0x8(%ebp)
  800638:	e8 9d ff ff ff       	call   8005da <vsnprintf>
	va_end(ap);

	return rc;
}
  80063d:	c9                   	leave  
  80063e:	c3                   	ret    
	...

00800640 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800646:	b8 00 00 00 00       	mov    $0x0,%eax
  80064b:	80 3a 00             	cmpb   $0x0,(%edx)
  80064e:	74 07                	je     800657 <strlen+0x17>
		n++;
  800650:	40                   	inc    %eax
  800651:	42                   	inc    %edx
  800652:	80 3a 00             	cmpb   $0x0,(%edx)
  800655:	75 f9                	jne    800650 <strlen+0x10>
	return n;
}
  800657:	c9                   	leave  
  800658:	c3                   	ret    

00800659 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800662:	b8 00 00 00 00       	mov    $0x0,%eax
  800667:	85 d2                	test   %edx,%edx
  800669:	74 0f                	je     80067a <strnlen+0x21>
  80066b:	80 39 00             	cmpb   $0x0,(%ecx)
  80066e:	74 0a                	je     80067a <strnlen+0x21>
		n++;
  800670:	40                   	inc    %eax
  800671:	41                   	inc    %ecx
  800672:	4a                   	dec    %edx
  800673:	74 05                	je     80067a <strnlen+0x21>
  800675:	80 39 00             	cmpb   $0x0,(%ecx)
  800678:	75 f6                	jne    800670 <strnlen+0x17>
	return n;
}
  80067a:	c9                   	leave  
  80067b:	c3                   	ret    

0080067c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	53                   	push   %ebx
  800680:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800683:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800686:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800688:	8a 02                	mov    (%edx),%al
  80068a:	42                   	inc    %edx
  80068b:	88 01                	mov    %al,(%ecx)
  80068d:	41                   	inc    %ecx
  80068e:	84 c0                	test   %al,%al
  800690:	75 f6                	jne    800688 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800692:	89 d8                	mov    %ebx,%eax
  800694:	5b                   	pop    %ebx
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	57                   	push   %edi
  80069b:	56                   	push   %esi
  80069c:	53                   	push   %ebx
  80069d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a3:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006a6:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8006a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ad:	39 f3                	cmp    %esi,%ebx
  8006af:	73 10                	jae    8006c1 <strncpy+0x2a>
		*dst++ = *src;
  8006b1:	8a 02                	mov    (%edx),%al
  8006b3:	88 01                	mov    %al,(%ecx)
  8006b5:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8006b6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006b9:	74 01                	je     8006bc <strncpy+0x25>
			src++;
  8006bb:	42                   	inc    %edx
  8006bc:	43                   	inc    %ebx
  8006bd:	39 f3                	cmp    %esi,%ebx
  8006bf:	72 f0                	jb     8006b1 <strncpy+0x1a>
	}
	return ret;
}
  8006c1:	89 f8                	mov    %edi,%eax
  8006c3:	5b                   	pop    %ebx
  8006c4:	5e                   	pop    %esi
  8006c5:	5f                   	pop    %edi
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	56                   	push   %esi
  8006cc:	53                   	push   %ebx
  8006cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006d3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8006d6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	74 19                	je     8006f5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8006dc:	4a                   	dec    %edx
  8006dd:	74 13                	je     8006f2 <strlcpy+0x2a>
  8006df:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e2:	74 0e                	je     8006f2 <strlcpy+0x2a>
			*dst++ = *src++;
  8006e4:	8a 01                	mov    (%ecx),%al
  8006e6:	41                   	inc    %ecx
  8006e7:	88 03                	mov    %al,(%ebx)
  8006e9:	43                   	inc    %ebx
  8006ea:	4a                   	dec    %edx
  8006eb:	74 05                	je     8006f2 <strlcpy+0x2a>
  8006ed:	80 39 00             	cmpb   $0x0,(%ecx)
  8006f0:	75 f2                	jne    8006e4 <strlcpy+0x1c>
		*dst = '\0';
  8006f2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8006f5:	89 d8                	mov    %ebx,%eax
  8006f7:	29 f0                	sub    %esi,%eax
}
  8006f9:	5b                   	pop    %ebx
  8006fa:	5e                   	pop    %esi
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 55 08             	mov    0x8(%ebp),%edx
  800703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800706:	80 3a 00             	cmpb   $0x0,(%edx)
  800709:	74 13                	je     80071e <strcmp+0x21>
  80070b:	8a 02                	mov    (%edx),%al
  80070d:	3a 01                	cmp    (%ecx),%al
  80070f:	75 0d                	jne    80071e <strcmp+0x21>
		p++, q++;
  800711:	42                   	inc    %edx
  800712:	41                   	inc    %ecx
  800713:	80 3a 00             	cmpb   $0x0,(%edx)
  800716:	74 06                	je     80071e <strcmp+0x21>
  800718:	8a 02                	mov    (%edx),%al
  80071a:	3a 01                	cmp    (%ecx),%al
  80071c:	74 f3                	je     800711 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80071e:	0f b6 02             	movzbl (%edx),%eax
  800721:	0f b6 11             	movzbl (%ecx),%edx
  800724:	29 d0                	sub    %edx,%eax
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	8b 55 08             	mov    0x8(%ebp),%edx
  80072f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800732:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800735:	85 c9                	test   %ecx,%ecx
  800737:	74 1f                	je     800758 <strncmp+0x30>
  800739:	80 3a 00             	cmpb   $0x0,(%edx)
  80073c:	74 16                	je     800754 <strncmp+0x2c>
  80073e:	8a 02                	mov    (%edx),%al
  800740:	3a 03                	cmp    (%ebx),%al
  800742:	75 10                	jne    800754 <strncmp+0x2c>
		n--, p++, q++;
  800744:	42                   	inc    %edx
  800745:	43                   	inc    %ebx
  800746:	49                   	dec    %ecx
  800747:	74 0f                	je     800758 <strncmp+0x30>
  800749:	80 3a 00             	cmpb   $0x0,(%edx)
  80074c:	74 06                	je     800754 <strncmp+0x2c>
  80074e:	8a 02                	mov    (%edx),%al
  800750:	3a 03                	cmp    (%ebx),%al
  800752:	74 f0                	je     800744 <strncmp+0x1c>
	if (n == 0)
  800754:	85 c9                	test   %ecx,%ecx
  800756:	75 07                	jne    80075f <strncmp+0x37>
		return 0;
  800758:	b8 00 00 00 00       	mov    $0x0,%eax
  80075d:	eb 0a                	jmp    800769 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80075f:	0f b6 12             	movzbl (%edx),%edx
  800762:	0f b6 03             	movzbl (%ebx),%eax
  800765:	29 c2                	sub    %eax,%edx
  800767:	89 d0                	mov    %edx,%eax
}
  800769:	8b 1c 24             	mov    (%esp),%ebx
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800777:	80 38 00             	cmpb   $0x0,(%eax)
  80077a:	74 0a                	je     800786 <strchr+0x18>
		if (*s == c)
  80077c:	38 10                	cmp    %dl,(%eax)
  80077e:	74 0b                	je     80078b <strchr+0x1d>
  800780:	40                   	inc    %eax
  800781:	80 38 00             	cmpb   $0x0,(%eax)
  800784:	75 f6                	jne    80077c <strchr+0xe>
			return (char *) s;
	return 0;
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800796:	80 38 00             	cmpb   $0x0,(%eax)
  800799:	74 0a                	je     8007a5 <strfind+0x18>
		if (*s == c)
  80079b:	38 10                	cmp    %dl,(%eax)
  80079d:	74 06                	je     8007a5 <strfind+0x18>
  80079f:	40                   	inc    %eax
  8007a0:	80 38 00             	cmpb   $0x0,(%eax)
  8007a3:	75 f6                	jne    80079b <strfind+0xe>
			break;
	return (char *) s;
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	57                   	push   %edi
  8007ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8007b1:	89 f8                	mov    %edi,%eax
  8007b3:	85 c9                	test   %ecx,%ecx
  8007b5:	74 40                	je     8007f7 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007bd:	75 30                	jne    8007ef <memset+0x48>
  8007bf:	f6 c1 03             	test   $0x3,%cl
  8007c2:	75 2b                	jne    8007ef <memset+0x48>
		c &= 0xFF;
  8007c4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8007cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ce:	c1 e0 18             	shl    $0x18,%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d4:	c1 e2 10             	shl    $0x10,%edx
  8007d7:	09 d0                	or     %edx,%eax
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dc:	c1 e2 08             	shl    $0x8,%edx
  8007df:	09 d0                	or     %edx,%eax
  8007e1:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8007e4:	c1 e9 02             	shr    $0x2,%ecx
  8007e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ea:	fc                   	cld    
  8007eb:	f3 ab                	repz stos %eax,%es:(%edi)
  8007ed:	eb 06                	jmp    8007f5 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f2:	fc                   	cld    
  8007f3:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8007f5:	89 f8                	mov    %edi,%eax
}
  8007f7:	8b 3c 24             	mov    (%esp),%edi
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	57                   	push   %edi
  800800:	56                   	push   %esi
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800807:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80080a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80080c:	39 c6                	cmp    %eax,%esi
  80080e:	73 33                	jae    800843 <memmove+0x47>
  800810:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800813:	39 c2                	cmp    %eax,%edx
  800815:	76 2c                	jbe    800843 <memmove+0x47>
		s += n;
  800817:	89 d6                	mov    %edx,%esi
		d += n;
  800819:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80081c:	f6 c2 03             	test   $0x3,%dl
  80081f:	75 1b                	jne    80083c <memmove+0x40>
  800821:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800827:	75 13                	jne    80083c <memmove+0x40>
  800829:	f6 c1 03             	test   $0x3,%cl
  80082c:	75 0e                	jne    80083c <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80082e:	83 ef 04             	sub    $0x4,%edi
  800831:	83 ee 04             	sub    $0x4,%esi
  800834:	c1 e9 02             	shr    $0x2,%ecx
  800837:	fd                   	std    
  800838:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80083a:	eb 27                	jmp    800863 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80083c:	4f                   	dec    %edi
  80083d:	4e                   	dec    %esi
  80083e:	fd                   	std    
  80083f:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800841:	eb 20                	jmp    800863 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800843:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800849:	75 15                	jne    800860 <memmove+0x64>
  80084b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800851:	75 0d                	jne    800860 <memmove+0x64>
  800853:	f6 c1 03             	test   $0x3,%cl
  800856:	75 08                	jne    800860 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800858:	c1 e9 02             	shr    $0x2,%ecx
  80085b:	fc                   	cld    
  80085c:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80085e:	eb 03                	jmp    800863 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800860:	fc                   	cld    
  800861:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800863:	5e                   	pop    %esi
  800864:	5f                   	pop    %edi
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <memcpy>:

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
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80086d:	ff 75 10             	pushl  0x10(%ebp)
  800870:	ff 75 0c             	pushl  0xc(%ebp)
  800873:	ff 75 08             	pushl  0x8(%ebp)
  800876:	e8 81 ff ff ff       	call   8007fc <memmove>
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	53                   	push   %ebx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800887:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  80088a:	89 d0                	mov    %edx,%eax
  80088c:	4a                   	dec    %edx
  80088d:	85 c0                	test   %eax,%eax
  80088f:	74 1b                	je     8008ac <memcmp+0x2f>
		if (*s1 != *s2)
  800891:	8a 01                	mov    (%ecx),%al
  800893:	3a 03                	cmp    (%ebx),%al
  800895:	74 0c                	je     8008a3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800897:	0f b6 d0             	movzbl %al,%edx
  80089a:	0f b6 03             	movzbl (%ebx),%eax
  80089d:	29 c2                	sub    %eax,%edx
  80089f:	89 d0                	mov    %edx,%eax
  8008a1:	eb 0e                	jmp    8008b1 <memcmp+0x34>
		s1++, s2++;
  8008a3:	41                   	inc    %ecx
  8008a4:	43                   	inc    %ebx
  8008a5:	89 d0                	mov    %edx,%eax
  8008a7:	4a                   	dec    %edx
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	75 e5                	jne    800891 <memcmp+0x14>
	}

	return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008c2:	39 d0                	cmp    %edx,%eax
  8008c4:	73 09                	jae    8008cf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008c6:	38 08                	cmp    %cl,(%eax)
  8008c8:	74 05                	je     8008cf <memfind+0x1b>
  8008ca:	40                   	inc    %eax
  8008cb:	39 d0                	cmp    %edx,%eax
  8008cd:	72 f7                	jb     8008c6 <memfind+0x12>
			break;
	return (void *) s;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	57                   	push   %edi
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8008da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8008e0:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8008e5:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008ea:	80 3a 20             	cmpb   $0x20,(%edx)
  8008ed:	74 05                	je     8008f4 <strtol+0x23>
  8008ef:	80 3a 09             	cmpb   $0x9,(%edx)
  8008f2:	75 0b                	jne    8008ff <strtol+0x2e>
		s++;
  8008f4:	42                   	inc    %edx
  8008f5:	80 3a 20             	cmpb   $0x20,(%edx)
  8008f8:	74 fa                	je     8008f4 <strtol+0x23>
  8008fa:	80 3a 09             	cmpb   $0x9,(%edx)
  8008fd:	74 f5                	je     8008f4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8008ff:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800902:	75 03                	jne    800907 <strtol+0x36>
		s++;
  800904:	42                   	inc    %edx
  800905:	eb 0b                	jmp    800912 <strtol+0x41>
	else if (*s == '-')
  800907:	80 3a 2d             	cmpb   $0x2d,(%edx)
  80090a:	75 06                	jne    800912 <strtol+0x41>
		s++, neg = 1;
  80090c:	42                   	inc    %edx
  80090d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800912:	85 c9                	test   %ecx,%ecx
  800914:	74 05                	je     80091b <strtol+0x4a>
  800916:	83 f9 10             	cmp    $0x10,%ecx
  800919:	75 15                	jne    800930 <strtol+0x5f>
  80091b:	80 3a 30             	cmpb   $0x30,(%edx)
  80091e:	75 10                	jne    800930 <strtol+0x5f>
  800920:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800924:	75 0a                	jne    800930 <strtol+0x5f>
		s += 2, base = 16;
  800926:	83 c2 02             	add    $0x2,%edx
  800929:	b9 10 00 00 00       	mov    $0x10,%ecx
  80092e:	eb 1a                	jmp    80094a <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800930:	85 c9                	test   %ecx,%ecx
  800932:	75 16                	jne    80094a <strtol+0x79>
  800934:	80 3a 30             	cmpb   $0x30,(%edx)
  800937:	75 08                	jne    800941 <strtol+0x70>
		s++, base = 8;
  800939:	42                   	inc    %edx
  80093a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80093f:	eb 09                	jmp    80094a <strtol+0x79>
	else if (base == 0)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	75 05                	jne    80094a <strtol+0x79>
		base = 10;
  800945:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80094a:	8a 02                	mov    (%edx),%al
  80094c:	83 e8 30             	sub    $0x30,%eax
  80094f:	3c 09                	cmp    $0x9,%al
  800951:	77 08                	ja     80095b <strtol+0x8a>
			dig = *s - '0';
  800953:	0f be 02             	movsbl (%edx),%eax
  800956:	83 e8 30             	sub    $0x30,%eax
  800959:	eb 20                	jmp    80097b <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  80095b:	8a 02                	mov    (%edx),%al
  80095d:	83 e8 61             	sub    $0x61,%eax
  800960:	3c 19                	cmp    $0x19,%al
  800962:	77 08                	ja     80096c <strtol+0x9b>
			dig = *s - 'a' + 10;
  800964:	0f be 02             	movsbl (%edx),%eax
  800967:	83 e8 57             	sub    $0x57,%eax
  80096a:	eb 0f                	jmp    80097b <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  80096c:	8a 02                	mov    (%edx),%al
  80096e:	83 e8 41             	sub    $0x41,%eax
  800971:	3c 19                	cmp    $0x19,%al
  800973:	77 12                	ja     800987 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800975:	0f be 02             	movsbl (%edx),%eax
  800978:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  80097b:	39 c8                	cmp    %ecx,%eax
  80097d:	7d 08                	jge    800987 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  80097f:	42                   	inc    %edx
  800980:	0f af d9             	imul   %ecx,%ebx
  800983:	01 c3                	add    %eax,%ebx
  800985:	eb c3                	jmp    80094a <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800987:	85 f6                	test   %esi,%esi
  800989:	74 02                	je     80098d <strtol+0xbc>
		*endptr = (char *) s;
  80098b:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80098d:	89 d8                	mov    %ebx,%eax
  80098f:	85 ff                	test   %edi,%edi
  800991:	74 02                	je     800995 <strtol+0xc4>
  800993:	f7 d8                	neg    %eax
}
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5f                   	pop    %edi
  800998:	c9                   	leave  
  800999:	c3                   	ret    
	...

0080099c <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	89 fb                	mov    %edi,%ebx
  8009b1:	89 fe                	mov    %edi,%esi
  8009b3:	55                   	push   %ebp
  8009b4:	9c                   	pushf  
  8009b5:	56                   	push   %esi
  8009b6:	54                   	push   %esp
  8009b7:	5d                   	pop    %ebp
  8009b8:	8d 35 c0 09 80 00    	lea    0x8009c0,%esi
  8009be:	0f 34                	sysenter 
  8009c0:	83 c4 04             	add    $0x4,%esp
  8009c3:	9d                   	popf   
  8009c4:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8009d5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009da:	89 fa                	mov    %edi,%edx
  8009dc:	89 f9                	mov    %edi,%ecx
  8009de:	89 fb                	mov    %edi,%ebx
  8009e0:	89 fe                	mov    %edi,%esi
  8009e2:	55                   	push   %ebp
  8009e3:	9c                   	pushf  
  8009e4:	56                   	push   %esi
  8009e5:	54                   	push   %esp
  8009e6:	5d                   	pop    %ebp
  8009e7:	8d 35 ef 09 80 00    	lea    0x8009ef,%esi
  8009ed:	0f 34                	sysenter 
  8009ef:	83 c4 04             	add    $0x4,%esp
  8009f2:	9d                   	popf   
  8009f3:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 0c             	sub    $0xc,%esp
  800a02:	8b 55 08             	mov    0x8(%ebp),%edx
  800a05:	b8 03 00 00 00       	mov    $0x3,%eax
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0f:	89 f9                	mov    %edi,%ecx
  800a11:	89 fb                	mov    %edi,%ebx
  800a13:	89 fe                	mov    %edi,%esi
  800a15:	55                   	push   %ebp
  800a16:	9c                   	pushf  
  800a17:	56                   	push   %esi
  800a18:	54                   	push   %esp
  800a19:	5d                   	pop    %ebp
  800a1a:	8d 35 22 0a 80 00    	lea    0x800a22,%esi
  800a20:	0f 34                	sysenter 
  800a22:	83 c4 04             	add    $0x4,%esp
  800a25:	9d                   	popf   
  800a26:	5d                   	pop    %ebp
  800a27:	85 c0                	test   %eax,%eax
  800a29:	7e 17                	jle    800a42 <sys_env_destroy+0x49>
  800a2b:	83 ec 0c             	sub    $0xc,%esp
  800a2e:	50                   	push   %eax
  800a2f:	6a 03                	push   $0x3
  800a31:	68 fc 12 80 00       	push   $0x8012fc
  800a36:	6a 4c                	push   $0x4c
  800a38:	68 19 13 80 00       	push   $0x801319
  800a3d:	e8 06 03 00 00       	call   800d48 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a42:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	c9                   	leave  
  800a49:	c3                   	ret    

00800a4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	b8 02 00 00 00       	mov    $0x2,%eax
  800a55:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5a:	89 fa                	mov    %edi,%edx
  800a5c:	89 f9                	mov    %edi,%ecx
  800a5e:	89 fb                	mov    %edi,%ebx
  800a60:	89 fe                	mov    %edi,%esi
  800a62:	55                   	push   %ebp
  800a63:	9c                   	pushf  
  800a64:	56                   	push   %esi
  800a65:	54                   	push   %esp
  800a66:	5d                   	pop    %ebp
  800a67:	8d 35 6f 0a 80 00    	lea    0x800a6f,%esi
  800a6d:	0f 34                	sysenter 
  800a6f:	83 c4 04             	add    $0x4,%esp
  800a72:	9d                   	popf   
  800a73:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <sys_dump_env>:

int
sys_dump_env(void)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
  800a89:	89 fa                	mov    %edi,%edx
  800a8b:	89 f9                	mov    %edi,%ecx
  800a8d:	89 fb                	mov    %edi,%ebx
  800a8f:	89 fe                	mov    %edi,%esi
  800a91:	55                   	push   %ebp
  800a92:	9c                   	pushf  
  800a93:	56                   	push   %esi
  800a94:	54                   	push   %esp
  800a95:	5d                   	pop    %ebp
  800a96:	8d 35 9e 0a 80 00    	lea    0x800a9e,%esi
  800a9c:	0f 34                	sysenter 
  800a9e:	83 c4 04             	add    $0x4,%esp
  800aa1:	9d                   	popf   
  800aa2:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <sys_yield>:

void
sys_yield(void)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab8:	89 fa                	mov    %edi,%edx
  800aba:	89 f9                	mov    %edi,%ecx
  800abc:	89 fb                	mov    %edi,%ebx
  800abe:	89 fe                	mov    %edi,%esi
  800ac0:	55                   	push   %ebp
  800ac1:	9c                   	pushf  
  800ac2:	56                   	push   %esi
  800ac3:	54                   	push   %esp
  800ac4:	5d                   	pop    %ebp
  800ac5:	8d 35 cd 0a 80 00    	lea    0x800acd,%esi
  800acb:	0f 34                	sysenter 
  800acd:	83 c4 04             	add    $0x4,%esp
  800ad0:	9d                   	popf   
  800ad1:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	83 ec 0c             	sub    $0xc,%esp
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ae9:	b8 05 00 00 00       	mov    $0x5,%eax
  800aee:	bf 00 00 00 00       	mov    $0x0,%edi
  800af3:	89 fe                	mov    %edi,%esi
  800af5:	55                   	push   %ebp
  800af6:	9c                   	pushf  
  800af7:	56                   	push   %esi
  800af8:	54                   	push   %esp
  800af9:	5d                   	pop    %ebp
  800afa:	8d 35 02 0b 80 00    	lea    0x800b02,%esi
  800b00:	0f 34                	sysenter 
  800b02:	83 c4 04             	add    $0x4,%esp
  800b05:	9d                   	popf   
  800b06:	5d                   	pop    %ebp
  800b07:	85 c0                	test   %eax,%eax
  800b09:	7e 17                	jle    800b22 <sys_page_alloc+0x4b>
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	50                   	push   %eax
  800b0f:	6a 05                	push   $0x5
  800b11:	68 fc 12 80 00       	push   $0x8012fc
  800b16:	6a 4c                	push   $0x4c
  800b18:	68 19 13 80 00       	push   $0x801319
  800b1d:	e8 26 02 00 00       	call   800d48 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b22:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	83 ec 0c             	sub    $0xc,%esp
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b3f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b42:	b8 06 00 00 00       	mov    $0x6,%eax
  800b47:	55                   	push   %ebp
  800b48:	9c                   	pushf  
  800b49:	56                   	push   %esi
  800b4a:	54                   	push   %esp
  800b4b:	5d                   	pop    %ebp
  800b4c:	8d 35 54 0b 80 00    	lea    0x800b54,%esi
  800b52:	0f 34                	sysenter 
  800b54:	83 c4 04             	add    $0x4,%esp
  800b57:	9d                   	popf   
  800b58:	5d                   	pop    %ebp
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_page_map+0x4a>
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 06                	push   $0x6
  800b63:	68 fc 12 80 00       	push   $0x8012fc
  800b68:	6a 4c                	push   $0x4c
  800b6a:	68 19 13 80 00       	push   $0x801319
  800b6f:	e8 d4 01 00 00       	call   800d48 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800b74:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	b8 07 00 00 00       	mov    $0x7,%eax
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
  800b95:	89 fb                	mov    %edi,%ebx
  800b97:	89 fe                	mov    %edi,%esi
  800b99:	55                   	push   %ebp
  800b9a:	9c                   	pushf  
  800b9b:	56                   	push   %esi
  800b9c:	54                   	push   %esp
  800b9d:	5d                   	pop    %ebp
  800b9e:	8d 35 a6 0b 80 00    	lea    0x800ba6,%esi
  800ba4:	0f 34                	sysenter 
  800ba6:	83 c4 04             	add    $0x4,%esp
  800ba9:	9d                   	popf   
  800baa:	5d                   	pop    %ebp
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_page_unmap+0x4a>
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 07                	push   $0x7
  800bb5:	68 fc 12 80 00       	push   $0x8012fc
  800bba:	6a 4c                	push   $0x4c
  800bbc:	68 19 13 80 00       	push   $0x801319
  800bc1:	e8 82 01 00 00       	call   800d48 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	b8 09 00 00 00       	mov    $0x9,%eax
  800be2:	bf 00 00 00 00       	mov    $0x0,%edi
  800be7:	89 fb                	mov    %edi,%ebx
  800be9:	89 fe                	mov    %edi,%esi
  800beb:	55                   	push   %ebp
  800bec:	9c                   	pushf  
  800bed:	56                   	push   %esi
  800bee:	54                   	push   %esp
  800bef:	5d                   	pop    %ebp
  800bf0:	8d 35 f8 0b 80 00    	lea    0x800bf8,%esi
  800bf6:	0f 34                	sysenter 
  800bf8:	83 c4 04             	add    $0x4,%esp
  800bfb:	9d                   	popf   
  800bfc:	5d                   	pop    %ebp
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_env_set_status+0x4a>
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 09                	push   $0x9
  800c07:	68 fc 12 80 00       	push   $0x8012fc
  800c0c:	6a 4c                	push   $0x4c
  800c0e:	68 19 13 80 00       	push   $0x801319
  800c13:	e8 30 01 00 00       	call   800d48 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c18:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c34:	bf 00 00 00 00       	mov    $0x0,%edi
  800c39:	89 fb                	mov    %edi,%ebx
  800c3b:	89 fe                	mov    %edi,%esi
  800c3d:	55                   	push   %ebp
  800c3e:	9c                   	pushf  
  800c3f:	56                   	push   %esi
  800c40:	54                   	push   %esp
  800c41:	5d                   	pop    %ebp
  800c42:	8d 35 4a 0c 80 00    	lea    0x800c4a,%esi
  800c48:	0f 34                	sysenter 
  800c4a:	83 c4 04             	add    $0x4,%esp
  800c4d:	9d                   	popf   
  800c4e:	5d                   	pop    %ebp
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 17                	jle    800c6a <sys_env_set_trapframe+0x4a>
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 0a                	push   $0xa
  800c59:	68 fc 12 80 00       	push   $0x8012fc
  800c5e:	6a 4c                	push   $0x4c
  800c60:	68 19 13 80 00       	push   $0x801319
  800c65:	e8 de 00 00 00       	call   800d48 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c86:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8b:	89 fb                	mov    %edi,%ebx
  800c8d:	89 fe                	mov    %edi,%esi
  800c8f:	55                   	push   %ebp
  800c90:	9c                   	pushf  
  800c91:	56                   	push   %esi
  800c92:	54                   	push   %esp
  800c93:	5d                   	pop    %ebp
  800c94:	8d 35 9c 0c 80 00    	lea    0x800c9c,%esi
  800c9a:	0f 34                	sysenter 
  800c9c:	83 c4 04             	add    $0x4,%esp
  800c9f:	9d                   	popf   
  800ca0:	5d                   	pop    %ebp
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_pgfault_upcall+0x4a>
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 0b                	push   $0xb
  800cab:	68 fc 12 80 00       	push   $0x8012fc
  800cb0:	6a 4c                	push   $0x4c
  800cb2:	68 19 13 80 00       	push   $0x801319
  800cb7:	e8 8c 00 00 00       	call   800d48 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdb:	be 00 00 00 00       	mov    $0x0,%esi
  800ce0:	55                   	push   %ebp
  800ce1:	9c                   	pushf  
  800ce2:	56                   	push   %esi
  800ce3:	54                   	push   %esp
  800ce4:	5d                   	pop    %ebp
  800ce5:	8d 35 ed 0c 80 00    	lea    0x800ced,%esi
  800ceb:	0f 34                	sysenter 
  800ced:	83 c4 04             	add    $0x4,%esp
  800cf0:	9d                   	popf   
  800cf1:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d08:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0d:	89 f9                	mov    %edi,%ecx
  800d0f:	89 fb                	mov    %edi,%ebx
  800d11:	89 fe                	mov    %edi,%esi
  800d13:	55                   	push   %ebp
  800d14:	9c                   	pushf  
  800d15:	56                   	push   %esi
  800d16:	54                   	push   %esp
  800d17:	5d                   	pop    %ebp
  800d18:	8d 35 20 0d 80 00    	lea    0x800d20,%esi
  800d1e:	0f 34                	sysenter 
  800d20:	83 c4 04             	add    $0x4,%esp
  800d23:	9d                   	popf   
  800d24:	5d                   	pop    %ebp
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_ipc_recv+0x49>
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 0e                	push   $0xe
  800d2f:	68 fc 12 80 00       	push   $0x8012fc
  800d34:	6a 4c                	push   $0x4c
  800d36:	68 19 13 80 00       	push   $0x801319
  800d3b:	e8 08 00 00 00       	call   800d48 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  800d4f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800d52:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d59:	74 16                	je     800d71 <_panic+0x29>
		cprintf("%s: ", argv0);
  800d5b:	83 ec 08             	sub    $0x8,%esp
  800d5e:	ff 35 08 20 80 00    	pushl  0x802008
  800d64:	68 27 13 80 00       	push   $0x801327
  800d69:	e8 d2 f3 ff ff       	call   800140 <cprintf>
  800d6e:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800d71:	ff 75 0c             	pushl  0xc(%ebp)
  800d74:	ff 75 08             	pushl  0x8(%ebp)
  800d77:	ff 35 00 20 80 00    	pushl  0x802000
  800d7d:	68 2c 13 80 00       	push   $0x80132c
  800d82:	e8 b9 f3 ff ff       	call   800140 <cprintf>
	vcprintf(fmt, ap);
  800d87:	83 c4 08             	add    $0x8,%esp
  800d8a:	53                   	push   %ebx
  800d8b:	ff 75 10             	pushl  0x10(%ebp)
  800d8e:	e8 5c f3 ff ff       	call   8000ef <vcprintf>
	cprintf("\n");
  800d93:	c7 04 24 8c 10 80 00 	movl   $0x80108c,(%esp)
  800d9a:	e8 a1 f3 ff ff       	call   800140 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800d9f:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800da2:	cc                   	int3   
  800da3:	eb fd                	jmp    800da2 <_panic+0x5a>
}
  800da5:	00 00                	add    %al,(%eax)
	...

00800da8 <__udivdi3>:
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	83 ec 20             	sub    $0x20,%esp
  800db0:	8b 55 14             	mov    0x14(%ebp),%edx
  800db3:	8b 75 08             	mov    0x8(%ebp),%esi
  800db6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800db9:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbc:	85 d2                	test   %edx,%edx
  800dbe:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800dc1:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800dc8:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800dcf:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800dd2:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800dd5:	89 fe                	mov    %edi,%esi
  800dd7:	75 5b                	jne    800e34 <__udivdi3+0x8c>
  800dd9:	39 f8                	cmp    %edi,%eax
  800ddb:	76 2b                	jbe    800e08 <__udivdi3+0x60>
  800ddd:	89 fa                	mov    %edi,%edx
  800ddf:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800de2:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800de5:	89 c7                	mov    %eax,%edi
  800de7:	90                   	nop    
  800de8:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800def:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800df2:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800df5:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800df8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800dfb:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800dfe:	83 c4 20             	add    $0x20,%esp
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	75 0e                	jne    800e1d <__udivdi3+0x75>
  800e0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e14:	31 c9                	xor    %ecx,%ecx
  800e16:	31 d2                	xor    %edx,%edx
  800e18:	f7 f1                	div    %ecx
  800e1a:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e1d:	89 f0                	mov    %esi,%eax
  800e1f:	31 d2                	xor    %edx,%edx
  800e21:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e24:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e27:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e2a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e2d:	89 c7                	mov    %eax,%edi
  800e2f:	eb be                	jmp    800def <__udivdi3+0x47>
  800e31:	8d 76 00             	lea    0x0(%esi),%esi
  800e34:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800e37:	76 07                	jbe    800e40 <__udivdi3+0x98>
  800e39:	31 ff                	xor    %edi,%edi
  800e3b:	eb ab                	jmp    800de8 <__udivdi3+0x40>
  800e3d:	8d 76 00             	lea    0x0(%esi),%esi
  800e40:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800e44:	89 c7                	mov    %eax,%edi
  800e46:	83 f7 1f             	xor    $0x1f,%edi
  800e49:	75 19                	jne    800e64 <__udivdi3+0xbc>
  800e4b:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800e4e:	77 0a                	ja     800e5a <__udivdi3+0xb2>
  800e50:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e53:	31 ff                	xor    %edi,%edi
  800e55:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800e58:	72 8e                	jb     800de8 <__udivdi3+0x40>
  800e5a:	bf 01 00 00 00       	mov    $0x1,%edi
  800e5f:	eb 87                	jmp    800de8 <__udivdi3+0x40>
  800e61:	8d 76 00             	lea    0x0(%esi),%esi
  800e64:	b8 20 00 00 00       	mov    $0x20,%eax
  800e69:	29 f8                	sub    %edi,%eax
  800e6b:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800e6e:	89 f9                	mov    %edi,%ecx
  800e70:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800e73:	d3 e2                	shl    %cl,%edx
  800e75:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e78:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e7b:	d3 e8                	shr    %cl,%eax
  800e7d:	09 c2                	or     %eax,%edx
  800e7f:	89 f9                	mov    %edi,%ecx
  800e81:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800e84:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e87:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e8a:	89 f2                	mov    %esi,%edx
  800e8c:	d3 ea                	shr    %cl,%edx
  800e8e:	89 f9                	mov    %edi,%ecx
  800e90:	d3 e6                	shl    %cl,%esi
  800e92:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e95:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e98:	d3 e8                	shr    %cl,%eax
  800e9a:	09 c6                	or     %eax,%esi
  800e9c:	89 f9                	mov    %edi,%ecx
  800e9e:	89 f0                	mov    %esi,%eax
  800ea0:	f7 75 ec             	divl   0xffffffec(%ebp)
  800ea3:	89 d6                	mov    %edx,%esi
  800ea5:	89 c7                	mov    %eax,%edi
  800ea7:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800eaa:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800ead:	f7 e7                	mul    %edi
  800eaf:	39 f2                	cmp    %esi,%edx
  800eb1:	77 0f                	ja     800ec2 <__udivdi3+0x11a>
  800eb3:	0f 85 2f ff ff ff    	jne    800de8 <__udivdi3+0x40>
  800eb9:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800ebc:	0f 86 26 ff ff ff    	jbe    800de8 <__udivdi3+0x40>
  800ec2:	4f                   	dec    %edi
  800ec3:	e9 20 ff ff ff       	jmp    800de8 <__udivdi3+0x40>

00800ec8 <__umoddi3>:
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	83 ec 30             	sub    $0x30,%esp
  800ed0:	8b 55 14             	mov    0x14(%ebp),%edx
  800ed3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ed9:	8b 45 10             	mov    0x10(%ebp),%eax
  800edc:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800edf:	85 d2                	test   %edx,%edx
  800ee1:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800ee8:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800eef:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800ef2:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800ef5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800ef8:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800efb:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800efe:	75 68                	jne    800f68 <__umoddi3+0xa0>
  800f00:	39 f8                	cmp    %edi,%eax
  800f02:	76 3c                	jbe    800f40 <__umoddi3+0x78>
  800f04:	89 f0                	mov    %esi,%eax
  800f06:	89 fa                	mov    %edi,%edx
  800f08:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f0b:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800f0e:	85 c9                	test   %ecx,%ecx
  800f10:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800f13:	74 1b                	je     800f30 <__umoddi3+0x68>
  800f15:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f18:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800f1b:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f22:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f25:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800f28:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800f2b:	89 10                	mov    %edx,(%eax)
  800f2d:	89 48 04             	mov    %ecx,0x4(%eax)
  800f30:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f33:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f36:	83 c4 30             	add    $0x30,%esp
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi
  800f40:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  800f43:	85 f6                	test   %esi,%esi
  800f45:	75 0d                	jne    800f54 <__umoddi3+0x8c>
  800f47:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4c:	31 d2                	xor    %edx,%edx
  800f4e:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f51:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f54:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800f57:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f5a:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f5d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f60:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f63:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f66:	eb a3                	jmp    800f0b <__umoddi3+0x43>
  800f68:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f6b:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800f6e:	76 14                	jbe    800f84 <__umoddi3+0xbc>
  800f70:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800f73:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800f76:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800f79:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800f7c:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800f7f:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800f82:	eb ac                	jmp    800f30 <__umoddi3+0x68>
  800f84:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800f88:	89 c6                	mov    %eax,%esi
  800f8a:	83 f6 1f             	xor    $0x1f,%esi
  800f8d:	75 4d                	jne    800fdc <__umoddi3+0x114>
  800f8f:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f92:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800f95:	77 08                	ja     800f9f <__umoddi3+0xd7>
  800f97:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  800f9a:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800f9d:	72 12                	jb     800fb1 <__umoddi3+0xe9>
  800f9f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fa2:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fa5:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  800fa8:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800fab:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800fae:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800fb1:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800fb4:	85 d2                	test   %edx,%edx
  800fb6:	0f 84 74 ff ff ff    	je     800f30 <__umoddi3+0x68>
  800fbc:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fbf:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fc2:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800fc5:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800fc8:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800fcb:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800fce:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800fd1:	89 01                	mov    %eax,(%ecx)
  800fd3:	89 51 04             	mov    %edx,0x4(%ecx)
  800fd6:	e9 55 ff ff ff       	jmp    800f30 <__umoddi3+0x68>
  800fdb:	90                   	nop    
  800fdc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fe1:	29 f0                	sub    %esi,%eax
  800fe3:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800fe6:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800fe9:	89 f1                	mov    %esi,%ecx
  800feb:	d3 e2                	shl    %cl,%edx
  800fed:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800ff0:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800ff3:	d3 e8                	shr    %cl,%eax
  800ff5:	09 c2                	or     %eax,%edx
  800ff7:	89 f1                	mov    %esi,%ecx
  800ff9:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  800ffc:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800fff:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801002:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801005:	d3 ea                	shr    %cl,%edx
  801007:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  80100a:	89 f1                	mov    %esi,%ecx
  80100c:	d3 e7                	shl    %cl,%edi
  80100e:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801011:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801014:	d3 e8                	shr    %cl,%eax
  801016:	09 c7                	or     %eax,%edi
  801018:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80101b:	89 f8                	mov    %edi,%eax
  80101d:	89 f1                	mov    %esi,%ecx
  80101f:	f7 75 dc             	divl   0xffffffdc(%ebp)
  801022:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801025:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801028:	f7 65 cc             	mull   0xffffffcc(%ebp)
  80102b:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  80102e:	89 c7                	mov    %eax,%edi
  801030:	77 3f                	ja     801071 <__umoddi3+0x1a9>
  801032:	74 38                	je     80106c <__umoddi3+0x1a4>
  801034:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  801037:	85 c0                	test   %eax,%eax
  801039:	0f 84 f1 fe ff ff    	je     800f30 <__umoddi3+0x68>
  80103f:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  801042:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801045:	29 f8                	sub    %edi,%eax
  801047:	19 d1                	sbb    %edx,%ecx
  801049:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80104c:	89 ca                	mov    %ecx,%edx
  80104e:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801051:	d3 e2                	shl    %cl,%edx
  801053:	89 f1                	mov    %esi,%ecx
  801055:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801058:	d3 e8                	shr    %cl,%eax
  80105a:	09 c2                	or     %eax,%edx
  80105c:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  80105f:	d3 e8                	shr    %cl,%eax
  801061:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  801064:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  801067:	e9 b6 fe ff ff       	jmp    800f22 <__umoddi3+0x5a>
  80106c:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  80106f:	76 c3                	jbe    801034 <__umoddi3+0x16c>
  801071:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  801074:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  801077:	eb bb                	jmp    801034 <__umoddi3+0x16c>
  801079:	90                   	nop    
  80107a:	90                   	nop    
  80107b:	90                   	nop    
