
obj/user/faultdie：     文件格式 elf32-i386

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
  80002c:	e8 4b 00 00 00       	call   80007c <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	52                   	push   %edx
  800044:	ff 30                	pushl  (%eax)
  800046:	68 20 11 80 00       	push   $0x801120
  80004b:	e8 10 01 00 00       	call   800160 <cprintf>
	sys_env_destroy(sys_getenvid());
  800050:	e8 15 0a 00 00       	call   800a6a <sys_getenvid>
  800055:	89 04 24             	mov    %eax,(%esp)
  800058:	e8 bc 09 00 00       	call   800a19 <sys_env_destroy>
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <umain>:

void
umain(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800065:	68 34 00 80 00       	push   $0x800034
  80006a:	e8 f9 0c 00 00       	call   800d68 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80006f:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800076:	00 00 00 
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
	...

0080007c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	8b 75 08             	mov    0x8(%ebp),%esi
  800084:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  800087:	e8 de 09 00 00       	call   800a6a <sys_getenvid>
  80008c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800091:	c1 e0 07             	shl    $0x7,%eax
  800094:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800099:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009e:	85 f6                	test   %esi,%esi
  8000a0:	7e 07                	jle    8000a9 <libmain+0x2d>
		binaryname = argv[0];
  8000a2:	8b 03                	mov    (%ebx),%eax
  8000a4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a9:	83 ec 08             	sub    $0x8,%esp
  8000ac:	53                   	push   %ebx
  8000ad:	56                   	push   %esi
  8000ae:	e8 ac ff ff ff       	call   80005f <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  8000b3:	e8 08 00 00 00       	call   8000c0 <exit>
}
  8000b8:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    
	...

008000c0 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  8000c6:	6a 00                	push   $0x0
  8000c8:	e8 4c 09 00 00       	call   800a19 <sys_env_destroy>
}
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    
	...

008000d0 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 03                	mov    (%ebx),%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e3:	40                   	inc    %eax
  8000e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000eb:	75 1a                	jne    800107 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	68 ff 00 00 00       	push   $0xff
  8000f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f8:	50                   	push   %eax
  8000f9:	e8 be 08 00 00       	call   8009bc <sys_cputs>
		b->idx = 0;
  8000fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800104:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800107:	ff 43 04             	incl   0x4(%ebx)
}
  80010a:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 d0 00 80 00       	push   $0x8000d0
  80013e:	e8 83 01 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  80014c:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	e8 64 08 00 00       	call   8009bc <sys_cputs>

	return b.cnt;
  800158:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 9d ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	8b 75 10             	mov    0x10(%ebp),%esi
  800180:	8b 7d 14             	mov    0x14(%ebp),%edi
  800183:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800186:	8b 45 18             	mov    0x18(%ebp),%eax
  800189:	ba 00 00 00 00       	mov    $0x0,%edx
  80018e:	39 d7                	cmp    %edx,%edi
  800190:	72 39                	jb     8001cb <printnum+0x57>
  800192:	77 04                	ja     800198 <printnum+0x24>
  800194:	39 c6                	cmp    %eax,%esi
  800196:	72 33                	jb     8001cb <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800198:	83 ec 04             	sub    $0x4,%esp
  80019b:	ff 75 20             	pushl  0x20(%ebp)
  80019e:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8001a1:	50                   	push   %eax
  8001a2:	ff 75 18             	pushl  0x18(%ebp)
  8001a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8001a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ad:	52                   	push   %edx
  8001ae:	50                   	push   %eax
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	e8 7e 0c 00 00       	call   800e34 <__udivdi3>
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	52                   	push   %edx
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 0c             	pushl  0xc(%ebp)
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 ae ff ff ff       	call   800174 <printnum>
  8001c6:	83 c4 20             	add    $0x20,%esp
  8001c9:	eb 19                	jmp    8001e4 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cb:	4b                   	dec    %ebx
  8001cc:	85 db                	test   %ebx,%ebx
  8001ce:	7e 14                	jle    8001e4 <printnum+0x70>
			putch(padc, putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	ff 75 0c             	pushl  0xc(%ebp)
  8001d6:	ff 75 20             	pushl  0x20(%ebp)
  8001d9:	ff 55 08             	call   *0x8(%ebp)
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	4b                   	dec    %ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f ec                	jg     8001d0 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ea:	8b 45 18             	mov    0x18(%ebp),%eax
  8001ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f2:	83 ec 04             	sub    $0x4,%esp
  8001f5:	52                   	push   %edx
  8001f6:	50                   	push   %eax
  8001f7:	57                   	push   %edi
  8001f8:	56                   	push   %esi
  8001f9:	e8 56 0d 00 00       	call   800f54 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 e6 11 80 00 	movsbl 0x8011e6(%eax),%eax
  800208:	50                   	push   %eax
  800209:	ff 55 08             	call   *0x8(%ebp)
}
  80020c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	83 ec 18             	sub    $0x18,%esp
  80021c:	8b 75 08             	mov    0x8(%ebp),%esi
  80021f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800222:	8a 45 18             	mov    0x18(%ebp),%al
  800225:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  800228:	53                   	push   %ebx
  800229:	6a 1b                	push   $0x1b
  80022b:	ff d6                	call   *%esi
	putch('[', putdat);
  80022d:	83 c4 08             	add    $0x8,%esp
  800230:	53                   	push   %ebx
  800231:	6a 5b                	push   $0x5b
  800233:	ff d6                	call   *%esi
	putch('0', putdat);
  800235:	83 c4 08             	add    $0x8,%esp
  800238:	53                   	push   %ebx
  800239:	6a 30                	push   $0x30
  80023b:	ff d6                	call   *%esi
	putch(';', putdat);
  80023d:	83 c4 08             	add    $0x8,%esp
  800240:	53                   	push   %ebx
  800241:	6a 3b                	push   $0x3b
  800243:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800245:	83 c4 0c             	add    $0xc,%esp
  800248:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  80024c:	50                   	push   %eax
  80024d:	ff 75 14             	pushl  0x14(%ebp)
  800250:	6a 0a                	push   $0xa
  800252:	8b 45 10             	mov    0x10(%ebp),%eax
  800255:	99                   	cltd   
  800256:	52                   	push   %edx
  800257:	50                   	push   %eax
  800258:	53                   	push   %ebx
  800259:	56                   	push   %esi
  80025a:	e8 15 ff ff ff       	call   800174 <printnum>
	putch('m', putdat);
  80025f:	83 c4 18             	add    $0x18,%esp
  800262:	53                   	push   %ebx
  800263:	6a 6d                	push   $0x6d
  800265:	ff d6                	call   *%esi

}
  800267:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800277:	83 f8 01             	cmp    $0x1,%eax
  80027a:	7e 0f                	jle    80028b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 01                	mov    (%ecx),%eax
  80027e:	83 c0 08             	add    $0x8,%eax
  800281:	89 01                	mov    %eax,(%ecx)
  800283:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800286:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800289:	eb 0f                	jmp    80029a <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80028b:	8b 01                	mov    (%ecx),%eax
  80028d:	83 c0 04             	add    $0x4,%eax
  800290:	89 01                	mov    %eax,(%ecx)
  800292:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002a5:	83 f8 01             	cmp    $0x1,%eax
  8002a8:	7e 0f                	jle    8002b9 <getint+0x1d>
		return va_arg(*ap, long long);
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	83 c0 08             	add    $0x8,%eax
  8002af:	89 02                	mov    %eax,(%edx)
  8002b1:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002b4:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002b7:	eb 0b                	jmp    8002c4 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	83 c0 04             	add    $0x4,%eax
  8002be:	89 02                	mov    %eax,(%edx)
  8002c0:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002c3:	99                   	cltd   
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 1c             	sub    $0x1c,%esp
  8002cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d2:	0f b6 13             	movzbl (%ebx),%edx
  8002d5:	43                   	inc    %ebx
  8002d6:	83 fa 25             	cmp    $0x25,%edx
  8002d9:	74 1e                	je     8002f9 <vprintfmt+0x33>
			if (ch == '\0')
  8002db:	85 d2                	test   %edx,%edx
  8002dd:	0f 84 dc 02 00 00    	je     8005bf <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	ff 75 0c             	pushl  0xc(%ebp)
  8002e9:	52                   	push   %edx
  8002ea:	ff 55 08             	call   *0x8(%ebp)
  8002ed:	83 c4 10             	add    $0x10,%esp
  8002f0:	0f b6 13             	movzbl (%ebx),%edx
  8002f3:	43                   	inc    %ebx
  8002f4:	83 fa 25             	cmp    $0x25,%edx
  8002f7:	75 e2                	jne    8002db <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002f9:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8002fd:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  800304:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800309:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  80030e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  800315:	0f b6 13             	movzbl (%ebx),%edx
  800318:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  80031b:	43                   	inc    %ebx
  80031c:	83 f8 55             	cmp    $0x55,%eax
  80031f:	0f 87 75 02 00 00    	ja     80059a <vprintfmt+0x2d4>
  800325:	ff 24 85 44 12 80 00 	jmp    *0x801244(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  80032c:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800330:	eb e3                	jmp    800315 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800332:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800336:	eb dd                	jmp    800315 <vprintfmt+0x4f>

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
  800338:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80033d:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800340:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800344:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800347:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80034a:	83 f8 09             	cmp    $0x9,%eax
  80034d:	77 27                	ja     800376 <vprintfmt+0xb0>
  80034f:	43                   	inc    %ebx
  800350:	eb eb                	jmp    80033d <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800352:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  80035c:	eb 18                	jmp    800376 <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  80035e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800362:	79 b1                	jns    800315 <vprintfmt+0x4f>
				width = 0;
  800364:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80036b:	eb a8                	jmp    800315 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80036d:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800374:	eb 9f                	jmp    800315 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  800376:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80037a:	79 99                	jns    800315 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80037c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80037f:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800384:	eb 8f                	jmp    800315 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  800386:	41                   	inc    %ecx
			goto reswitch;
  800387:	eb 8c                	jmp    800315 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	ff 75 0c             	pushl  0xc(%ebp)
  80038f:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	ff 70 fc             	pushl  0xfffffffc(%eax)
  800399:	e9 c4 01 00 00       	jmp    800562 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  80039e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	79 02                	jns    8003ae <vprintfmt+0xe8>
				err = -err;
  8003ac:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8003ae:	83 f8 08             	cmp    $0x8,%eax
  8003b1:	7f 0b                	jg     8003be <vprintfmt+0xf8>
  8003b3:	8b 3c 85 20 12 80 00 	mov    0x801220(,%eax,4),%edi
  8003ba:	85 ff                	test   %edi,%edi
  8003bc:	75 08                	jne    8003c6 <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  8003be:	50                   	push   %eax
  8003bf:	68 f7 11 80 00       	push   $0x8011f7
  8003c4:	eb 06                	jmp    8003cc <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8003c6:	57                   	push   %edi
  8003c7:	68 00 12 80 00       	push   $0x801200
  8003cc:	ff 75 0c             	pushl  0xc(%ebp)
  8003cf:	ff 75 08             	pushl  0x8(%ebp)
  8003d2:	e8 f0 01 00 00       	call   8005c7 <printfmt>
  8003d7:	e9 89 01 00 00       	jmp    800565 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003dc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8003e6:	85 ff                	test   %edi,%edi
  8003e8:	75 05                	jne    8003ef <vprintfmt+0x129>
				p = "(null)";
  8003ea:	bf 03 12 80 00       	mov    $0x801203,%edi
			if (width > 0 && padc != '-')
  8003ef:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003f3:	7e 3b                	jle    800430 <vprintfmt+0x16a>
  8003f5:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8003f9:	74 35                	je     800430 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	56                   	push   %esi
  8003ff:	57                   	push   %edi
  800400:	e8 74 02 00 00       	call   800679 <strnlen>
  800405:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  800408:	83 c4 10             	add    $0x10,%esp
  80040b:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80040f:	7e 1f                	jle    800430 <vprintfmt+0x16a>
  800411:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800415:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  800418:	83 ec 08             	sub    $0x8,%esp
  80041b:	ff 75 0c             	pushl  0xc(%ebp)
  80041e:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  800421:	ff 55 08             	call   *0x8(%ebp)
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80042a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80042e:	7f e8                	jg     800418 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800430:	0f be 17             	movsbl (%edi),%edx
  800433:	47                   	inc    %edi
  800434:	85 d2                	test   %edx,%edx
  800436:	74 3e                	je     800476 <vprintfmt+0x1b0>
  800438:	85 f6                	test   %esi,%esi
  80043a:	78 03                	js     80043f <vprintfmt+0x179>
  80043c:	4e                   	dec    %esi
  80043d:	78 37                	js     800476 <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  80043f:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800443:	74 12                	je     800457 <vprintfmt+0x191>
  800445:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800448:	83 f8 5e             	cmp    $0x5e,%eax
  80044b:	76 0a                	jbe    800457 <vprintfmt+0x191>
					putch('?', putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	ff 75 0c             	pushl  0xc(%ebp)
  800453:	6a 3f                	push   $0x3f
  800455:	eb 07                	jmp    80045e <vprintfmt+0x198>
				else
					putch(ch, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 0c             	pushl  0xc(%ebp)
  80045d:	52                   	push   %edx
  80045e:	ff 55 08             	call   *0x8(%ebp)
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800467:	0f be 17             	movsbl (%edi),%edx
  80046a:	47                   	inc    %edi
  80046b:	85 d2                	test   %edx,%edx
  80046d:	74 07                	je     800476 <vprintfmt+0x1b0>
  80046f:	85 f6                	test   %esi,%esi
  800471:	78 cc                	js     80043f <vprintfmt+0x179>
  800473:	4e                   	dec    %esi
  800474:	79 c9                	jns    80043f <vprintfmt+0x179>
			for (; width > 0; width--)
  800476:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80047a:	0f 8e 52 fe ff ff    	jle    8002d2 <vprintfmt+0xc>
				putch(' ', putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 0c             	pushl  0xc(%ebp)
  800486:	6a 20                	push   $0x20
  800488:	ff 55 08             	call   *0x8(%ebp)
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800491:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800495:	7f e9                	jg     800480 <vprintfmt+0x1ba>
			break;
  800497:	e9 36 fe ff ff       	jmp    8002d2 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	51                   	push   %ecx
  8004a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a3:	50                   	push   %eax
  8004a4:	e8 f3 fd ff ff       	call   80029c <getint>
  8004a9:	89 c6                	mov    %eax,%esi
  8004ab:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	79 15                	jns    8004c9 <vprintfmt+0x203>
				putch('-', putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ba:	6a 2d                	push   $0x2d
  8004bc:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004bf:	f7 de                	neg    %esi
  8004c1:	83 d7 00             	adc    $0x0,%edi
  8004c4:	f7 df                	neg    %edi
  8004c6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004c9:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004ce:	eb 70                	jmp    800540 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	51                   	push   %ecx
  8004d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8004d7:	50                   	push   %eax
  8004d8:	e8 91 fd ff ff       	call   80026e <getuint>
  8004dd:	89 c6                	mov    %eax,%esi
  8004df:	89 d7                	mov    %edx,%edi
			base = 10;
  8004e1:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004e6:	eb 55                	jmp    80053d <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	51                   	push   %ecx
  8004ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	e8 79 fd ff ff       	call   80026e <getuint>
  8004f5:	89 c6                	mov    %eax,%esi
  8004f7:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  8004f9:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8004fe:	eb 3d                	jmp    80053d <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	ff 75 0c             	pushl  0xc(%ebp)
  800506:	6a 30                	push   $0x30
  800508:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80050b:	83 c4 08             	add    $0x8,%esp
  80050e:	ff 75 0c             	pushl  0xc(%ebp)
  800511:	6a 78                	push   $0x78
  800513:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800516:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800520:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  800525:	eb 11                	jmp    800538 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	51                   	push   %ecx
  80052b:	8d 45 14             	lea    0x14(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	e8 3a fd ff ff       	call   80026e <getuint>
  800534:	89 c6                	mov    %eax,%esi
  800536:	89 d7                	mov    %edx,%edi
			base = 16;
  800538:	ba 10 00 00 00       	mov    $0x10,%edx
  80053d:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800540:	83 ec 04             	sub    $0x4,%esp
  800543:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800547:	50                   	push   %eax
  800548:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80054b:	52                   	push   %edx
  80054c:	57                   	push   %edi
  80054d:	56                   	push   %esi
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	ff 75 08             	pushl  0x8(%ebp)
  800554:	e8 1b fc ff ff       	call   800174 <printnum>
			break;
  800559:	eb 37                	jmp    800592 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	52                   	push   %edx
  800562:	ff 55 08             	call   *0x8(%ebp)
			break;
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	e9 65 fd ff ff       	jmp    8002d2 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	51                   	push   %ecx
  800571:	8d 45 14             	lea    0x14(%ebp),%eax
  800574:	50                   	push   %eax
  800575:	e8 f4 fc ff ff       	call   80026e <getuint>
  80057a:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  80057c:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800586:	56                   	push   %esi
  800587:	ff 75 0c             	pushl  0xc(%ebp)
  80058a:	ff 75 08             	pushl  0x8(%ebp)
  80058d:	e8 82 fc ff ff       	call   800214 <printcolor>
			break;
  800592:	83 c4 20             	add    $0x20,%esp
  800595:	e9 38 fd ff ff       	jmp    8002d2 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	ff 75 0c             	pushl  0xc(%ebp)
  8005a0:	6a 25                	push   $0x25
  8005a2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005a5:	4b                   	dec    %ebx
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005ad:	0f 84 1f fd ff ff    	je     8002d2 <vprintfmt+0xc>
  8005b3:	4b                   	dec    %ebx
  8005b4:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005b8:	75 f9                	jne    8005b3 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005ba:	e9 13 fd ff ff       	jmp    8002d2 <vprintfmt+0xc>
		}
	}
}
  8005bf:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8005c2:	5b                   	pop    %ebx
  8005c3:	5e                   	pop    %esi
  8005c4:	5f                   	pop    %edi
  8005c5:	c9                   	leave  
  8005c6:	c3                   	ret    

008005c7 <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005cd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d0:	50                   	push   %eax
  8005d1:	ff 75 10             	pushl  0x10(%ebp)
  8005d4:	ff 75 0c             	pushl  0xc(%ebp)
  8005d7:	ff 75 08             	pushl  0x8(%ebp)
  8005da:	e8 e7 fc ff ff       	call   8002c6 <vprintfmt>
	va_end(ap);
}
  8005df:	c9                   	leave  
  8005e0:	c3                   	ret    

008005e1 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005e7:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005ea:	8b 0a                	mov    (%edx),%ecx
  8005ec:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005ef:	73 07                	jae    8005f8 <sprintputch+0x17>
		*b->buf++ = ch;
  8005f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f4:	88 01                	mov    %al,(%ecx)
  8005f6:	ff 02                	incl   (%edx)
}
  8005f8:	c9                   	leave  
  8005f9:	c3                   	ret    

008005fa <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8005fa:	55                   	push   %ebp
  8005fb:	89 e5                	mov    %esp,%ebp
  8005fd:	83 ec 18             	sub    $0x18,%esp
  800600:	8b 55 08             	mov    0x8(%ebp),%edx
  800603:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800606:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800609:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  80060d:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800610:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  800617:	85 d2                	test   %edx,%edx
  800619:	74 04                	je     80061f <vsnprintf+0x25>
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	7f 07                	jg     800626 <vsnprintf+0x2c>
		return -E_INVAL;
  80061f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800624:	eb 1d                	jmp    800643 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  800626:	ff 75 14             	pushl  0x14(%ebp)
  800629:	ff 75 10             	pushl  0x10(%ebp)
  80062c:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	68 e1 05 80 00       	push   $0x8005e1
  800635:	e8 8c fc ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80063a:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80063d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800640:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800643:	c9                   	leave  
  800644:	c3                   	ret    

00800645 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800645:	55                   	push   %ebp
  800646:	89 e5                	mov    %esp,%ebp
  800648:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80064e:	50                   	push   %eax
  80064f:	ff 75 10             	pushl  0x10(%ebp)
  800652:	ff 75 0c             	pushl  0xc(%ebp)
  800655:	ff 75 08             	pushl  0x8(%ebp)
  800658:	e8 9d ff ff ff       	call   8005fa <vsnprintf>
	va_end(ap);

	return rc;
}
  80065d:	c9                   	leave  
  80065e:	c3                   	ret    
	...

00800660 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800666:	b8 00 00 00 00       	mov    $0x0,%eax
  80066b:	80 3a 00             	cmpb   $0x0,(%edx)
  80066e:	74 07                	je     800677 <strlen+0x17>
		n++;
  800670:	40                   	inc    %eax
  800671:	42                   	inc    %edx
  800672:	80 3a 00             	cmpb   $0x0,(%edx)
  800675:	75 f9                	jne    800670 <strlen+0x10>
	return n;
}
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800682:	b8 00 00 00 00       	mov    $0x0,%eax
  800687:	85 d2                	test   %edx,%edx
  800689:	74 0f                	je     80069a <strnlen+0x21>
  80068b:	80 39 00             	cmpb   $0x0,(%ecx)
  80068e:	74 0a                	je     80069a <strnlen+0x21>
		n++;
  800690:	40                   	inc    %eax
  800691:	41                   	inc    %ecx
  800692:	4a                   	dec    %edx
  800693:	74 05                	je     80069a <strnlen+0x21>
  800695:	80 39 00             	cmpb   $0x0,(%ecx)
  800698:	75 f6                	jne    800690 <strnlen+0x17>
	return n;
}
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	53                   	push   %ebx
  8006a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006a6:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006a8:	8a 02                	mov    (%edx),%al
  8006aa:	42                   	inc    %edx
  8006ab:	88 01                	mov    %al,(%ecx)
  8006ad:	41                   	inc    %ecx
  8006ae:	84 c0                	test   %al,%al
  8006b0:	75 f6                	jne    8006a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006b2:	89 d8                	mov    %ebx,%eax
  8006b4:	5b                   	pop    %ebx
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	57                   	push   %edi
  8006bb:	56                   	push   %esi
  8006bc:	53                   	push   %ebx
  8006bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006c3:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006c6:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cd:	39 f3                	cmp    %esi,%ebx
  8006cf:	73 10                	jae    8006e1 <strncpy+0x2a>
		*dst++ = *src;
  8006d1:	8a 02                	mov    (%edx),%al
  8006d3:	88 01                	mov    %al,(%ecx)
  8006d5:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8006d6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006d9:	74 01                	je     8006dc <strncpy+0x25>
			src++;
  8006db:	42                   	inc    %edx
  8006dc:	43                   	inc    %ebx
  8006dd:	39 f3                	cmp    %esi,%ebx
  8006df:	72 f0                	jb     8006d1 <strncpy+0x1a>
	}
	return ret;
}
  8006e1:	89 f8                	mov    %edi,%eax
  8006e3:	5b                   	pop    %ebx
  8006e4:	5e                   	pop    %esi
  8006e5:	5f                   	pop    %edi
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
  8006ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8006f6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8006f8:	85 d2                	test   %edx,%edx
  8006fa:	74 19                	je     800715 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8006fc:	4a                   	dec    %edx
  8006fd:	74 13                	je     800712 <strlcpy+0x2a>
  8006ff:	80 39 00             	cmpb   $0x0,(%ecx)
  800702:	74 0e                	je     800712 <strlcpy+0x2a>
			*dst++ = *src++;
  800704:	8a 01                	mov    (%ecx),%al
  800706:	41                   	inc    %ecx
  800707:	88 03                	mov    %al,(%ebx)
  800709:	43                   	inc    %ebx
  80070a:	4a                   	dec    %edx
  80070b:	74 05                	je     800712 <strlcpy+0x2a>
  80070d:	80 39 00             	cmpb   $0x0,(%ecx)
  800710:	75 f2                	jne    800704 <strlcpy+0x1c>
		*dst = '\0';
  800712:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800715:	89 d8                	mov    %ebx,%eax
  800717:	29 f0                	sub    %esi,%eax
}
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	c9                   	leave  
  80071c:	c3                   	ret    

0080071d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	8b 55 08             	mov    0x8(%ebp),%edx
  800723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800726:	80 3a 00             	cmpb   $0x0,(%edx)
  800729:	74 13                	je     80073e <strcmp+0x21>
  80072b:	8a 02                	mov    (%edx),%al
  80072d:	3a 01                	cmp    (%ecx),%al
  80072f:	75 0d                	jne    80073e <strcmp+0x21>
		p++, q++;
  800731:	42                   	inc    %edx
  800732:	41                   	inc    %ecx
  800733:	80 3a 00             	cmpb   $0x0,(%edx)
  800736:	74 06                	je     80073e <strcmp+0x21>
  800738:	8a 02                	mov    (%edx),%al
  80073a:	3a 01                	cmp    (%ecx),%al
  80073c:	74 f3                	je     800731 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80073e:	0f b6 02             	movzbl (%edx),%eax
  800741:	0f b6 11             	movzbl (%ecx),%edx
  800744:	29 d0                	sub    %edx,%eax
}
  800746:	c9                   	leave  
  800747:	c3                   	ret    

00800748 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	53                   	push   %ebx
  80074c:	8b 55 08             	mov    0x8(%ebp),%edx
  80074f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800752:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800755:	85 c9                	test   %ecx,%ecx
  800757:	74 1f                	je     800778 <strncmp+0x30>
  800759:	80 3a 00             	cmpb   $0x0,(%edx)
  80075c:	74 16                	je     800774 <strncmp+0x2c>
  80075e:	8a 02                	mov    (%edx),%al
  800760:	3a 03                	cmp    (%ebx),%al
  800762:	75 10                	jne    800774 <strncmp+0x2c>
		n--, p++, q++;
  800764:	42                   	inc    %edx
  800765:	43                   	inc    %ebx
  800766:	49                   	dec    %ecx
  800767:	74 0f                	je     800778 <strncmp+0x30>
  800769:	80 3a 00             	cmpb   $0x0,(%edx)
  80076c:	74 06                	je     800774 <strncmp+0x2c>
  80076e:	8a 02                	mov    (%edx),%al
  800770:	3a 03                	cmp    (%ebx),%al
  800772:	74 f0                	je     800764 <strncmp+0x1c>
	if (n == 0)
  800774:	85 c9                	test   %ecx,%ecx
  800776:	75 07                	jne    80077f <strncmp+0x37>
		return 0;
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 0a                	jmp    800789 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80077f:	0f b6 12             	movzbl (%edx),%edx
  800782:	0f b6 03             	movzbl (%ebx),%eax
  800785:	29 c2                	sub    %eax,%edx
  800787:	89 d0                	mov    %edx,%eax
}
  800789:	8b 1c 24             	mov    (%esp),%ebx
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    

0080078e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800797:	80 38 00             	cmpb   $0x0,(%eax)
  80079a:	74 0a                	je     8007a6 <strchr+0x18>
		if (*s == c)
  80079c:	38 10                	cmp    %dl,(%eax)
  80079e:	74 0b                	je     8007ab <strchr+0x1d>
  8007a0:	40                   	inc    %eax
  8007a1:	80 38 00             	cmpb   $0x0,(%eax)
  8007a4:	75 f6                	jne    80079c <strchr+0xe>
			return (char *) s;
	return 0;
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007b6:	80 38 00             	cmpb   $0x0,(%eax)
  8007b9:	74 0a                	je     8007c5 <strfind+0x18>
		if (*s == c)
  8007bb:	38 10                	cmp    %dl,(%eax)
  8007bd:	74 06                	je     8007c5 <strfind+0x18>
  8007bf:	40                   	inc    %eax
  8007c0:	80 38 00             	cmpb   $0x0,(%eax)
  8007c3:	75 f6                	jne    8007bb <strfind+0xe>
			break;
	return (char *) s;
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	57                   	push   %edi
  8007cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8007d1:	89 f8                	mov    %edi,%eax
  8007d3:	85 c9                	test   %ecx,%ecx
  8007d5:	74 40                	je     800817 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007dd:	75 30                	jne    80080f <memset+0x48>
  8007df:	f6 c1 03             	test   $0x3,%cl
  8007e2:	75 2b                	jne    80080f <memset+0x48>
		c &= 0xFF;
  8007e4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8007eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ee:	c1 e0 18             	shl    $0x18,%eax
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f4:	c1 e2 10             	shl    $0x10,%edx
  8007f7:	09 d0                	or     %edx,%eax
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fc:	c1 e2 08             	shl    $0x8,%edx
  8007ff:	09 d0                	or     %edx,%eax
  800801:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800804:	c1 e9 02             	shr    $0x2,%ecx
  800807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080a:	fc                   	cld    
  80080b:	f3 ab                	repz stos %eax,%es:(%edi)
  80080d:	eb 06                	jmp    800815 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80080f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800812:	fc                   	cld    
  800813:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800815:	89 f8                	mov    %edi,%eax
}
  800817:	8b 3c 24             	mov    (%esp),%edi
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	57                   	push   %edi
  800820:	56                   	push   %esi
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800827:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80082a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80082c:	39 c6                	cmp    %eax,%esi
  80082e:	73 33                	jae    800863 <memmove+0x47>
  800830:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800833:	39 c2                	cmp    %eax,%edx
  800835:	76 2c                	jbe    800863 <memmove+0x47>
		s += n;
  800837:	89 d6                	mov    %edx,%esi
		d += n;
  800839:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80083c:	f6 c2 03             	test   $0x3,%dl
  80083f:	75 1b                	jne    80085c <memmove+0x40>
  800841:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800847:	75 13                	jne    80085c <memmove+0x40>
  800849:	f6 c1 03             	test   $0x3,%cl
  80084c:	75 0e                	jne    80085c <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80084e:	83 ef 04             	sub    $0x4,%edi
  800851:	83 ee 04             	sub    $0x4,%esi
  800854:	c1 e9 02             	shr    $0x2,%ecx
  800857:	fd                   	std    
  800858:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80085a:	eb 27                	jmp    800883 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80085c:	4f                   	dec    %edi
  80085d:	4e                   	dec    %esi
  80085e:	fd                   	std    
  80085f:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800861:	eb 20                	jmp    800883 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800863:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800869:	75 15                	jne    800880 <memmove+0x64>
  80086b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800871:	75 0d                	jne    800880 <memmove+0x64>
  800873:	f6 c1 03             	test   $0x3,%cl
  800876:	75 08                	jne    800880 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800878:	c1 e9 02             	shr    $0x2,%ecx
  80087b:	fc                   	cld    
  80087c:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80087e:	eb 03                	jmp    800883 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800880:	fc                   	cld    
  800881:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <memcpy>:

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
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80088d:	ff 75 10             	pushl  0x10(%ebp)
  800890:	ff 75 0c             	pushl  0xc(%ebp)
  800893:	ff 75 08             	pushl  0x8(%ebp)
  800896:	e8 81 ff ff ff       	call   80081c <memmove>
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	53                   	push   %ebx
  8008a1:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  8008aa:	89 d0                	mov    %edx,%eax
  8008ac:	4a                   	dec    %edx
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	74 1b                	je     8008cc <memcmp+0x2f>
		if (*s1 != *s2)
  8008b1:	8a 01                	mov    (%ecx),%al
  8008b3:	3a 03                	cmp    (%ebx),%al
  8008b5:	74 0c                	je     8008c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008b7:	0f b6 d0             	movzbl %al,%edx
  8008ba:	0f b6 03             	movzbl (%ebx),%eax
  8008bd:	29 c2                	sub    %eax,%edx
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	eb 0e                	jmp    8008d1 <memcmp+0x34>
		s1++, s2++;
  8008c3:	41                   	inc    %ecx
  8008c4:	43                   	inc    %ebx
  8008c5:	89 d0                	mov    %edx,%eax
  8008c7:	4a                   	dec    %edx
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	75 e5                	jne    8008b1 <memcmp+0x14>
	}

	return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008dd:	89 c2                	mov    %eax,%edx
  8008df:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008e2:	39 d0                	cmp    %edx,%eax
  8008e4:	73 09                	jae    8008ef <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008e6:	38 08                	cmp    %cl,(%eax)
  8008e8:	74 05                	je     8008ef <memfind+0x1b>
  8008ea:	40                   	inc    %eax
  8008eb:	39 d0                	cmp    %edx,%eax
  8008ed:	72 f7                	jb     8008e6 <memfind+0x12>
			break;
	return (void *) s;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800900:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800905:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80090a:	80 3a 20             	cmpb   $0x20,(%edx)
  80090d:	74 05                	je     800914 <strtol+0x23>
  80090f:	80 3a 09             	cmpb   $0x9,(%edx)
  800912:	75 0b                	jne    80091f <strtol+0x2e>
		s++;
  800914:	42                   	inc    %edx
  800915:	80 3a 20             	cmpb   $0x20,(%edx)
  800918:	74 fa                	je     800914 <strtol+0x23>
  80091a:	80 3a 09             	cmpb   $0x9,(%edx)
  80091d:	74 f5                	je     800914 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80091f:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800922:	75 03                	jne    800927 <strtol+0x36>
		s++;
  800924:	42                   	inc    %edx
  800925:	eb 0b                	jmp    800932 <strtol+0x41>
	else if (*s == '-')
  800927:	80 3a 2d             	cmpb   $0x2d,(%edx)
  80092a:	75 06                	jne    800932 <strtol+0x41>
		s++, neg = 1;
  80092c:	42                   	inc    %edx
  80092d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800932:	85 c9                	test   %ecx,%ecx
  800934:	74 05                	je     80093b <strtol+0x4a>
  800936:	83 f9 10             	cmp    $0x10,%ecx
  800939:	75 15                	jne    800950 <strtol+0x5f>
  80093b:	80 3a 30             	cmpb   $0x30,(%edx)
  80093e:	75 10                	jne    800950 <strtol+0x5f>
  800940:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800944:	75 0a                	jne    800950 <strtol+0x5f>
		s += 2, base = 16;
  800946:	83 c2 02             	add    $0x2,%edx
  800949:	b9 10 00 00 00       	mov    $0x10,%ecx
  80094e:	eb 1a                	jmp    80096a <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800950:	85 c9                	test   %ecx,%ecx
  800952:	75 16                	jne    80096a <strtol+0x79>
  800954:	80 3a 30             	cmpb   $0x30,(%edx)
  800957:	75 08                	jne    800961 <strtol+0x70>
		s++, base = 8;
  800959:	42                   	inc    %edx
  80095a:	b9 08 00 00 00       	mov    $0x8,%ecx
  80095f:	eb 09                	jmp    80096a <strtol+0x79>
	else if (base == 0)
  800961:	85 c9                	test   %ecx,%ecx
  800963:	75 05                	jne    80096a <strtol+0x79>
		base = 10;
  800965:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80096a:	8a 02                	mov    (%edx),%al
  80096c:	83 e8 30             	sub    $0x30,%eax
  80096f:	3c 09                	cmp    $0x9,%al
  800971:	77 08                	ja     80097b <strtol+0x8a>
			dig = *s - '0';
  800973:	0f be 02             	movsbl (%edx),%eax
  800976:	83 e8 30             	sub    $0x30,%eax
  800979:	eb 20                	jmp    80099b <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  80097b:	8a 02                	mov    (%edx),%al
  80097d:	83 e8 61             	sub    $0x61,%eax
  800980:	3c 19                	cmp    $0x19,%al
  800982:	77 08                	ja     80098c <strtol+0x9b>
			dig = *s - 'a' + 10;
  800984:	0f be 02             	movsbl (%edx),%eax
  800987:	83 e8 57             	sub    $0x57,%eax
  80098a:	eb 0f                	jmp    80099b <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  80098c:	8a 02                	mov    (%edx),%al
  80098e:	83 e8 41             	sub    $0x41,%eax
  800991:	3c 19                	cmp    $0x19,%al
  800993:	77 12                	ja     8009a7 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800995:	0f be 02             	movsbl (%edx),%eax
  800998:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  80099b:	39 c8                	cmp    %ecx,%eax
  80099d:	7d 08                	jge    8009a7 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  80099f:	42                   	inc    %edx
  8009a0:	0f af d9             	imul   %ecx,%ebx
  8009a3:	01 c3                	add    %eax,%ebx
  8009a5:	eb c3                	jmp    80096a <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009a7:	85 f6                	test   %esi,%esi
  8009a9:	74 02                	je     8009ad <strtol+0xbc>
		*endptr = (char *) s;
  8009ab:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009ad:	89 d8                	mov    %ebx,%eax
  8009af:	85 ff                	test   %edi,%edi
  8009b1:	74 02                	je     8009b5 <strtol+0xc4>
  8009b3:	f7 d8                	neg    %eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    
	...

008009bc <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cd:	89 f8                	mov    %edi,%eax
  8009cf:	89 fb                	mov    %edi,%ebx
  8009d1:	89 fe                	mov    %edi,%esi
  8009d3:	55                   	push   %ebp
  8009d4:	9c                   	pushf  
  8009d5:	56                   	push   %esi
  8009d6:	54                   	push   %esp
  8009d7:	5d                   	pop    %ebp
  8009d8:	8d 35 e0 09 80 00    	lea    0x8009e0,%esi
  8009de:	0f 34                	sysenter 
  8009e0:	83 c4 04             	add    $0x4,%esp
  8009e3:	9d                   	popf   
  8009e4:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <sys_cgetc>:

int
sys_cgetc(void)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	57                   	push   %edi
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8009f5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fa:	89 fa                	mov    %edi,%edx
  8009fc:	89 f9                	mov    %edi,%ecx
  8009fe:	89 fb                	mov    %edi,%ebx
  800a00:	89 fe                	mov    %edi,%esi
  800a02:	55                   	push   %ebp
  800a03:	9c                   	pushf  
  800a04:	56                   	push   %esi
  800a05:	54                   	push   %esp
  800a06:	5d                   	pop    %ebp
  800a07:	8d 35 0f 0a 80 00    	lea    0x800a0f,%esi
  800a0d:	0f 34                	sysenter 
  800a0f:	83 c4 04             	add    $0x4,%esp
  800a12:	9d                   	popf   
  800a13:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a14:	5b                   	pop    %ebx
  800a15:	5e                   	pop    %esi
  800a16:	5f                   	pop    %edi
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	57                   	push   %edi
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	83 ec 0c             	sub    $0xc,%esp
  800a22:	8b 55 08             	mov    0x8(%ebp),%edx
  800a25:	b8 03 00 00 00       	mov    $0x3,%eax
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2f:	89 f9                	mov    %edi,%ecx
  800a31:	89 fb                	mov    %edi,%ebx
  800a33:	89 fe                	mov    %edi,%esi
  800a35:	55                   	push   %ebp
  800a36:	9c                   	pushf  
  800a37:	56                   	push   %esi
  800a38:	54                   	push   %esp
  800a39:	5d                   	pop    %ebp
  800a3a:	8d 35 42 0a 80 00    	lea    0x800a42,%esi
  800a40:	0f 34                	sysenter 
  800a42:	83 c4 04             	add    $0x4,%esp
  800a45:	9d                   	popf   
  800a46:	5d                   	pop    %ebp
  800a47:	85 c0                	test   %eax,%eax
  800a49:	7e 17                	jle    800a62 <sys_env_destroy+0x49>
  800a4b:	83 ec 0c             	sub    $0xc,%esp
  800a4e:	50                   	push   %eax
  800a4f:	6a 03                	push   $0x3
  800a51:	68 9c 13 80 00       	push   $0x80139c
  800a56:	6a 4c                	push   $0x4c
  800a58:	68 b9 13 80 00       	push   $0x8013b9
  800a5d:	e8 72 03 00 00       	call   800dd4 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a62:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	b8 02 00 00 00       	mov    $0x2,%eax
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7a:	89 fa                	mov    %edi,%edx
  800a7c:	89 f9                	mov    %edi,%ecx
  800a7e:	89 fb                	mov    %edi,%ebx
  800a80:	89 fe                	mov    %edi,%esi
  800a82:	55                   	push   %ebp
  800a83:	9c                   	pushf  
  800a84:	56                   	push   %esi
  800a85:	54                   	push   %esp
  800a86:	5d                   	pop    %ebp
  800a87:	8d 35 8f 0a 80 00    	lea    0x800a8f,%esi
  800a8d:	0f 34                	sysenter 
  800a8f:	83 c4 04             	add    $0x4,%esp
  800a92:	9d                   	popf   
  800a93:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <sys_dump_env>:

int
sys_dump_env(void)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa9:	89 fa                	mov    %edi,%edx
  800aab:	89 f9                	mov    %edi,%ecx
  800aad:	89 fb                	mov    %edi,%ebx
  800aaf:	89 fe                	mov    %edi,%esi
  800ab1:	55                   	push   %ebp
  800ab2:	9c                   	pushf  
  800ab3:	56                   	push   %esi
  800ab4:	54                   	push   %esp
  800ab5:	5d                   	pop    %ebp
  800ab6:	8d 35 be 0a 80 00    	lea    0x800abe,%esi
  800abc:	0f 34                	sysenter 
  800abe:	83 c4 04             	add    $0x4,%esp
  800ac1:	9d                   	popf   
  800ac2:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <sys_yield>:

void
sys_yield(void)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ad3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad8:	89 fa                	mov    %edi,%edx
  800ada:	89 f9                	mov    %edi,%ecx
  800adc:	89 fb                	mov    %edi,%ebx
  800ade:	89 fe                	mov    %edi,%esi
  800ae0:	55                   	push   %ebp
  800ae1:	9c                   	pushf  
  800ae2:	56                   	push   %esi
  800ae3:	54                   	push   %esp
  800ae4:	5d                   	pop    %ebp
  800ae5:	8d 35 ed 0a 80 00    	lea    0x800aed,%esi
  800aeb:	0f 34                	sysenter 
  800aed:	83 c4 04             	add    $0x4,%esp
  800af0:	9d                   	popf   
  800af1:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b09:	b8 05 00 00 00       	mov    $0x5,%eax
  800b0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b13:	89 fe                	mov    %edi,%esi
  800b15:	55                   	push   %ebp
  800b16:	9c                   	pushf  
  800b17:	56                   	push   %esi
  800b18:	54                   	push   %esp
  800b19:	5d                   	pop    %ebp
  800b1a:	8d 35 22 0b 80 00    	lea    0x800b22,%esi
  800b20:	0f 34                	sysenter 
  800b22:	83 c4 04             	add    $0x4,%esp
  800b25:	9d                   	popf   
  800b26:	5d                   	pop    %ebp
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 17                	jle    800b42 <sys_page_alloc+0x4b>
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	50                   	push   %eax
  800b2f:	6a 05                	push   $0x5
  800b31:	68 9c 13 80 00       	push   $0x80139c
  800b36:	6a 4c                	push   $0x4c
  800b38:	68 b9 13 80 00       	push   $0x8013b9
  800b3d:	e8 92 02 00 00       	call   800dd4 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b42:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	83 ec 0c             	sub    $0xc,%esp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b5f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b62:	b8 06 00 00 00       	mov    $0x6,%eax
  800b67:	55                   	push   %ebp
  800b68:	9c                   	pushf  
  800b69:	56                   	push   %esi
  800b6a:	54                   	push   %esp
  800b6b:	5d                   	pop    %ebp
  800b6c:	8d 35 74 0b 80 00    	lea    0x800b74,%esi
  800b72:	0f 34                	sysenter 
  800b74:	83 c4 04             	add    $0x4,%esp
  800b77:	9d                   	popf   
  800b78:	5d                   	pop    %ebp
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	7e 17                	jle    800b94 <sys_page_map+0x4a>
  800b7d:	83 ec 0c             	sub    $0xc,%esp
  800b80:	50                   	push   %eax
  800b81:	6a 06                	push   $0x6
  800b83:	68 9c 13 80 00       	push   $0x80139c
  800b88:	6a 4c                	push   $0x4c
  800b8a:	68 b9 13 80 00       	push   $0x8013b9
  800b8f:	e8 40 02 00 00       	call   800dd4 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800b94:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    

00800b9c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bab:	b8 07 00 00 00       	mov    $0x7,%eax
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb5:	89 fb                	mov    %edi,%ebx
  800bb7:	89 fe                	mov    %edi,%esi
  800bb9:	55                   	push   %ebp
  800bba:	9c                   	pushf  
  800bbb:	56                   	push   %esi
  800bbc:	54                   	push   %esp
  800bbd:	5d                   	pop    %ebp
  800bbe:	8d 35 c6 0b 80 00    	lea    0x800bc6,%esi
  800bc4:	0f 34                	sysenter 
  800bc6:	83 c4 04             	add    $0x4,%esp
  800bc9:	9d                   	popf   
  800bca:	5d                   	pop    %ebp
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	7e 17                	jle    800be6 <sys_page_unmap+0x4a>
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	50                   	push   %eax
  800bd3:	6a 07                	push   $0x7
  800bd5:	68 9c 13 80 00       	push   $0x80139c
  800bda:	6a 4c                	push   $0x4c
  800bdc:	68 b9 13 80 00       	push   $0x8013b9
  800be1:	e8 ee 01 00 00       	call   800dd4 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	b8 09 00 00 00       	mov    $0x9,%eax
  800c02:	bf 00 00 00 00       	mov    $0x0,%edi
  800c07:	89 fb                	mov    %edi,%ebx
  800c09:	89 fe                	mov    %edi,%esi
  800c0b:	55                   	push   %ebp
  800c0c:	9c                   	pushf  
  800c0d:	56                   	push   %esi
  800c0e:	54                   	push   %esp
  800c0f:	5d                   	pop    %ebp
  800c10:	8d 35 18 0c 80 00    	lea    0x800c18,%esi
  800c16:	0f 34                	sysenter 
  800c18:	83 c4 04             	add    $0x4,%esp
  800c1b:	9d                   	popf   
  800c1c:	5d                   	pop    %ebp
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_env_set_status+0x4a>
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 09                	push   $0x9
  800c27:	68 9c 13 80 00       	push   $0x80139c
  800c2c:	6a 4c                	push   $0x4c
  800c2e:	68 b9 13 80 00       	push   $0x8013b9
  800c33:	e8 9c 01 00 00       	call   800dd4 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c54:	bf 00 00 00 00       	mov    $0x0,%edi
  800c59:	89 fb                	mov    %edi,%ebx
  800c5b:	89 fe                	mov    %edi,%esi
  800c5d:	55                   	push   %ebp
  800c5e:	9c                   	pushf  
  800c5f:	56                   	push   %esi
  800c60:	54                   	push   %esp
  800c61:	5d                   	pop    %ebp
  800c62:	8d 35 6a 0c 80 00    	lea    0x800c6a,%esi
  800c68:	0f 34                	sysenter 
  800c6a:	83 c4 04             	add    $0x4,%esp
  800c6d:	9d                   	popf   
  800c6e:	5d                   	pop    %ebp
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7e 17                	jle    800c8a <sys_env_set_trapframe+0x4a>
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	50                   	push   %eax
  800c77:	6a 0a                	push   $0xa
  800c79:	68 9c 13 80 00       	push   $0x80139c
  800c7e:	6a 4c                	push   $0x4c
  800c80:	68 b9 13 80 00       	push   $0x8013b9
  800c85:	e8 4a 01 00 00       	call   800dd4 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c8a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cab:	89 fb                	mov    %edi,%ebx
  800cad:	89 fe                	mov    %edi,%esi
  800caf:	55                   	push   %ebp
  800cb0:	9c                   	pushf  
  800cb1:	56                   	push   %esi
  800cb2:	54                   	push   %esp
  800cb3:	5d                   	pop    %ebp
  800cb4:	8d 35 bc 0c 80 00    	lea    0x800cbc,%esi
  800cba:	0f 34                	sysenter 
  800cbc:	83 c4 04             	add    $0x4,%esp
  800cbf:	9d                   	popf   
  800cc0:	5d                   	pop    %ebp
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_pgfault_upcall+0x4a>
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 0b                	push   $0xb
  800ccb:	68 9c 13 80 00       	push   $0x80139c
  800cd0:	6a 4c                	push   $0x4c
  800cd2:	68 b9 13 80 00       	push   $0x8013b9
  800cd7:	e8 f8 00 00 00       	call   800dd4 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfb:	be 00 00 00 00       	mov    $0x0,%esi
  800d00:	55                   	push   %ebp
  800d01:	9c                   	pushf  
  800d02:	56                   	push   %esi
  800d03:	54                   	push   %esp
  800d04:	5d                   	pop    %ebp
  800d05:	8d 35 0d 0d 80 00    	lea    0x800d0d,%esi
  800d0b:	0f 34                	sysenter 
  800d0d:	83 c4 04             	add    $0x4,%esp
  800d10:	9d                   	popf   
  800d11:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    

00800d17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d28:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2d:	89 f9                	mov    %edi,%ecx
  800d2f:	89 fb                	mov    %edi,%ebx
  800d31:	89 fe                	mov    %edi,%esi
  800d33:	55                   	push   %ebp
  800d34:	9c                   	pushf  
  800d35:	56                   	push   %esi
  800d36:	54                   	push   %esp
  800d37:	5d                   	pop    %ebp
  800d38:	8d 35 40 0d 80 00    	lea    0x800d40,%esi
  800d3e:	0f 34                	sysenter 
  800d40:	83 c4 04             	add    $0x4,%esp
  800d43:	9d                   	popf   
  800d44:	5d                   	pop    %ebp
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_ipc_recv+0x49>
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 0e                	push   $0xe
  800d4f:	68 9c 13 80 00       	push   $0x80139c
  800d54:	6a 4c                	push   $0x4c
  800d56:	68 b9 13 80 00       	push   $0x8013b9
  800d5b:	e8 74 00 00 00       	call   800dd4 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == NULL) {
  800d6e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d75:	75 2a                	jne    800da1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
        //cprintf("i'm in set pgfault_handler,before alloc\n");
        if(sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W)) {//maybe not PTE_USER
  800d77:	83 ec 04             	sub    $0x4,%esp
  800d7a:	6a 07                	push   $0x7
  800d7c:	68 00 f0 bf ee       	push   $0xeebff000
  800d81:	6a 00                	push   $0x0
  800d83:	e8 6f fd ff ff       	call   800af7 <sys_page_alloc>
  800d88:	83 c4 10             	add    $0x10,%esp
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	75 1a                	jne    800da9 <set_pgfault_handler+0x41>
            return;
        }
        //cprintf("i'm in set pgfault_handler,after alloc\n");
        sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  800d8f:	83 ec 08             	sub    $0x8,%esp
  800d92:	68 ac 0d 80 00       	push   $0x800dac
  800d97:	6a 00                	push   $0x0
  800d99:	e8 f4 fe ff ff       	call   800c92 <sys_env_set_pgfault_upcall>
  800d9e:	83 c4 10             	add    $0x10,%esp
        //cprintf("here in set pgfault handler\n");
		//panic("set_pgfault_handler not implemented");
	}
	// Save handler pointer for assembly to call.
    //cprintf("handler %x;pgfault_handler address %x,upcall address %x,upcall points %x\n",handler,&_pgfault_handler,&_pgfault_upcall,_pgfault_upcall);
	_pgfault_handler = handler;
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	a3 08 20 80 00       	mov    %eax,0x802008
    //cprintf("here\n");
    //it should be ok
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    
	...

00800dac <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dad:	a1 08 20 80 00       	mov    0x802008,%eax
    //xchg %bx, %bx
	call *%eax
  800db2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800db4:	83 c4 04             	add    $0x4,%esp
	
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
  800db7:	83 c4 08             	add    $0x8,%esp
/*    //it's wrong
    movl %esp,%eax//old esp is stored in the upper 40byte of the current esp
    addl $40,%eax //eax point to the old esp
    //xchg %bx, %bx
    movl %eax,%edx
    addl $4,%edx //then edx points to the retaddr
    movl %edx,(%eax)//set the esp in the stack to the 
*/   
    movl 32(%esp),%edx //edx is the old eip 
  800dba:	8b 54 24 20          	mov    0x20(%esp),%edx
    movl 40(%esp),%eax //eax is the old esp
  800dbe:	8b 44 24 28          	mov    0x28(%esp),%eax
    subl $4, %eax // then eax point to the place where the return address will be store
  800dc2:	83 e8 04             	sub    $0x4,%eax
    movl %edx,(%eax)//the old eip is stored in the return address place.maybe this will cause recursive copyonwrite pagefault
  800dc5:	89 10                	mov    %edx,(%eax)
    movl %eax,40(%esp)//then the value of the esp place in the utf points to the old eip
  800dc7:	89 44 24 28          	mov    %eax,0x28(%esp)
    //because the register will be restored, so don't care the eax and edx
	// Restore the trap-time registers.
	// LAB 4: Your code here.
    popal
  800dcb:	61                   	popa   
	// Restore eflags from the stack.
	// LAB 4: Your code here.
    addl $4,%esp
  800dcc:	83 c4 04             	add    $0x4,%esp
    popfl
  800dcf:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    //xchg %bx,%bx
    popl %esp//then esp points to the retaddr
  800dd0:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    //xchg %bx, %bx
    ret
  800dd1:	c3                   	ret    
	...

00800dd4 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  800ddb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800dde:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800de5:	74 16                	je     800dfd <_panic+0x29>
		cprintf("%s: ", argv0);
  800de7:	83 ec 08             	sub    $0x8,%esp
  800dea:	ff 35 0c 20 80 00    	pushl  0x80200c
  800df0:	68 c7 13 80 00       	push   $0x8013c7
  800df5:	e8 66 f3 ff ff       	call   800160 <cprintf>
  800dfa:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800dfd:	ff 75 0c             	pushl  0xc(%ebp)
  800e00:	ff 75 08             	pushl  0x8(%ebp)
  800e03:	ff 35 00 20 80 00    	pushl  0x802000
  800e09:	68 cc 13 80 00       	push   $0x8013cc
  800e0e:	e8 4d f3 ff ff       	call   800160 <cprintf>
	vcprintf(fmt, ap);
  800e13:	83 c4 08             	add    $0x8,%esp
  800e16:	53                   	push   %ebx
  800e17:	ff 75 10             	pushl  0x10(%ebp)
  800e1a:	e8 f0 f2 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  800e1f:	c7 04 24 3a 11 80 00 	movl   $0x80113a,(%esp)
  800e26:	e8 35 f3 ff ff       	call   800160 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800e2b:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800e2e:	cc                   	int3   
  800e2f:	eb fd                	jmp    800e2e <_panic+0x5a>
}
  800e31:	00 00                	add    %al,(%eax)
	...

00800e34 <__udivdi3>:
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	83 ec 20             	sub    $0x20,%esp
  800e3c:	8b 55 14             	mov    0x14(%ebp),%edx
  800e3f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e42:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e45:	8b 45 10             	mov    0x10(%ebp),%eax
  800e48:	85 d2                	test   %edx,%edx
  800e4a:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800e4d:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800e54:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800e5b:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e5e:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e61:	89 fe                	mov    %edi,%esi
  800e63:	75 5b                	jne    800ec0 <__udivdi3+0x8c>
  800e65:	39 f8                	cmp    %edi,%eax
  800e67:	76 2b                	jbe    800e94 <__udivdi3+0x60>
  800e69:	89 fa                	mov    %edi,%edx
  800e6b:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e6e:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e71:	89 c7                	mov    %eax,%edi
  800e73:	90                   	nop    
  800e74:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800e7b:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800e7e:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800e81:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e84:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e87:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e8a:	83 c4 20             	add    $0x20,%esp
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    
  800e91:	8d 76 00             	lea    0x0(%esi),%esi
  800e94:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e97:	85 c0                	test   %eax,%eax
  800e99:	75 0e                	jne    800ea9 <__udivdi3+0x75>
  800e9b:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea0:	31 c9                	xor    %ecx,%ecx
  800ea2:	31 d2                	xor    %edx,%edx
  800ea4:	f7 f1                	div    %ecx
  800ea6:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800eb0:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800eb3:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800eb6:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800eb9:	89 c7                	mov    %eax,%edi
  800ebb:	eb be                	jmp    800e7b <__udivdi3+0x47>
  800ebd:	8d 76 00             	lea    0x0(%esi),%esi
  800ec0:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800ec3:	76 07                	jbe    800ecc <__udivdi3+0x98>
  800ec5:	31 ff                	xor    %edi,%edi
  800ec7:	eb ab                	jmp    800e74 <__udivdi3+0x40>
  800ec9:	8d 76 00             	lea    0x0(%esi),%esi
  800ecc:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800ed0:	89 c7                	mov    %eax,%edi
  800ed2:	83 f7 1f             	xor    $0x1f,%edi
  800ed5:	75 19                	jne    800ef0 <__udivdi3+0xbc>
  800ed7:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800eda:	77 0a                	ja     800ee6 <__udivdi3+0xb2>
  800edc:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800edf:	31 ff                	xor    %edi,%edi
  800ee1:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800ee4:	72 8e                	jb     800e74 <__udivdi3+0x40>
  800ee6:	bf 01 00 00 00       	mov    $0x1,%edi
  800eeb:	eb 87                	jmp    800e74 <__udivdi3+0x40>
  800eed:	8d 76 00             	lea    0x0(%esi),%esi
  800ef0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ef5:	29 f8                	sub    %edi,%eax
  800ef7:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800efa:	89 f9                	mov    %edi,%ecx
  800efc:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800eff:	d3 e2                	shl    %cl,%edx
  800f01:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800f04:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	09 c2                	or     %eax,%edx
  800f0b:	89 f9                	mov    %edi,%ecx
  800f0d:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800f10:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800f13:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800f16:	89 f2                	mov    %esi,%edx
  800f18:	d3 ea                	shr    %cl,%edx
  800f1a:	89 f9                	mov    %edi,%ecx
  800f1c:	d3 e6                	shl    %cl,%esi
  800f1e:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800f21:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800f24:	d3 e8                	shr    %cl,%eax
  800f26:	09 c6                	or     %eax,%esi
  800f28:	89 f9                	mov    %edi,%ecx
  800f2a:	89 f0                	mov    %esi,%eax
  800f2c:	f7 75 ec             	divl   0xffffffec(%ebp)
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	89 c7                	mov    %eax,%edi
  800f33:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800f36:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800f39:	f7 e7                	mul    %edi
  800f3b:	39 f2                	cmp    %esi,%edx
  800f3d:	77 0f                	ja     800f4e <__udivdi3+0x11a>
  800f3f:	0f 85 2f ff ff ff    	jne    800e74 <__udivdi3+0x40>
  800f45:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800f48:	0f 86 26 ff ff ff    	jbe    800e74 <__udivdi3+0x40>
  800f4e:	4f                   	dec    %edi
  800f4f:	e9 20 ff ff ff       	jmp    800e74 <__udivdi3+0x40>

00800f54 <__umoddi3>:
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	57                   	push   %edi
  800f58:	56                   	push   %esi
  800f59:	83 ec 30             	sub    $0x30,%esp
  800f5c:	8b 55 14             	mov    0x14(%ebp),%edx
  800f5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f62:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f65:	8b 45 10             	mov    0x10(%ebp),%eax
  800f68:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800f6b:	85 d2                	test   %edx,%edx
  800f6d:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800f74:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f7b:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800f7e:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f81:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800f84:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800f87:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800f8a:	75 68                	jne    800ff4 <__umoddi3+0xa0>
  800f8c:	39 f8                	cmp    %edi,%eax
  800f8e:	76 3c                	jbe    800fcc <__umoddi3+0x78>
  800f90:	89 f0                	mov    %esi,%eax
  800f92:	89 fa                	mov    %edi,%edx
  800f94:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f97:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800f9a:	85 c9                	test   %ecx,%ecx
  800f9c:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800f9f:	74 1b                	je     800fbc <__umoddi3+0x68>
  800fa1:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fa4:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800fa7:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800fae:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800fb1:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800fb4:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800fb7:	89 10                	mov    %edx,(%eax)
  800fb9:	89 48 04             	mov    %ecx,0x4(%eax)
  800fbc:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800fbf:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800fc2:	83 c4 30             	add    $0x30,%esp
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    
  800fc9:	8d 76 00             	lea    0x0(%esi),%esi
  800fcc:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  800fcf:	85 f6                	test   %esi,%esi
  800fd1:	75 0d                	jne    800fe0 <__umoddi3+0x8c>
  800fd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd8:	31 d2                	xor    %edx,%edx
  800fda:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800fdd:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800fe0:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800fe3:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800fe6:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800fe9:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fec:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800fef:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800ff2:	eb a3                	jmp    800f97 <__umoddi3+0x43>
  800ff4:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800ff7:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800ffa:	76 14                	jbe    801010 <__umoddi3+0xbc>
  800ffc:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800fff:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  801002:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801005:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801008:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  80100b:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80100e:	eb ac                	jmp    800fbc <__umoddi3+0x68>
  801010:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  801014:	89 c6                	mov    %eax,%esi
  801016:	83 f6 1f             	xor    $0x1f,%esi
  801019:	75 4d                	jne    801068 <__umoddi3+0x114>
  80101b:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80101e:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  801021:	77 08                	ja     80102b <__umoddi3+0xd7>
  801023:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  801026:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  801029:	72 12                	jb     80103d <__umoddi3+0xe9>
  80102b:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80102e:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801031:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  801034:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  801037:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  80103a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  80103d:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801040:	85 d2                	test   %edx,%edx
  801042:	0f 84 74 ff ff ff    	je     800fbc <__umoddi3+0x68>
  801048:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80104b:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80104e:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801051:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  801054:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  801057:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80105a:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  80105d:	89 01                	mov    %eax,(%ecx)
  80105f:	89 51 04             	mov    %edx,0x4(%ecx)
  801062:	e9 55 ff ff ff       	jmp    800fbc <__umoddi3+0x68>
  801067:	90                   	nop    
  801068:	b8 20 00 00 00       	mov    $0x20,%eax
  80106d:	29 f0                	sub    %esi,%eax
  80106f:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  801072:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801075:	89 f1                	mov    %esi,%ecx
  801077:	d3 e2                	shl    %cl,%edx
  801079:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  80107c:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80107f:	d3 e8                	shr    %cl,%eax
  801081:	09 c2                	or     %eax,%edx
  801083:	89 f1                	mov    %esi,%ecx
  801085:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801088:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80108b:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80108e:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801091:	d3 ea                	shr    %cl,%edx
  801093:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  801096:	89 f1                	mov    %esi,%ecx
  801098:	d3 e7                	shl    %cl,%edi
  80109a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80109d:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8010a0:	d3 e8                	shr    %cl,%eax
  8010a2:	09 c7                	or     %eax,%edi
  8010a4:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  8010a7:	89 f8                	mov    %edi,%eax
  8010a9:	89 f1                	mov    %esi,%ecx
  8010ab:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8010ae:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8010b1:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  8010b4:	f7 65 cc             	mull   0xffffffcc(%ebp)
  8010b7:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  8010ba:	89 c7                	mov    %eax,%edi
  8010bc:	77 3f                	ja     8010fd <__umoddi3+0x1a9>
  8010be:	74 38                	je     8010f8 <__umoddi3+0x1a4>
  8010c0:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	0f 84 f1 fe ff ff    	je     800fbc <__umoddi3+0x68>
  8010cb:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  8010ce:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8010d1:	29 f8                	sub    %edi,%eax
  8010d3:	19 d1                	sbb    %edx,%ecx
  8010d5:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8010d8:	89 ca                	mov    %ecx,%edx
  8010da:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8010dd:	d3 e2                	shl    %cl,%edx
  8010df:	89 f1                	mov    %esi,%ecx
  8010e1:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8010e4:	d3 e8                	shr    %cl,%eax
  8010e6:	09 c2                	or     %eax,%edx
  8010e8:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8010eb:	d3 e8                	shr    %cl,%eax
  8010ed:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8010f0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8010f3:	e9 b6 fe ff ff       	jmp    800fae <__umoddi3+0x5a>
  8010f8:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  8010fb:	76 c3                	jbe    8010c0 <__umoddi3+0x16c>
  8010fd:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  801100:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  801103:	eb bb                	jmp    8010c0 <__umoddi3+0x16c>
  801105:	90                   	nop    
  801106:	90                   	nop    
  801107:	90                   	nop    
