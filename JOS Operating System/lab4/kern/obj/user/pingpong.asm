
obj/user/pingpong：     文件格式 elf32-i386

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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800038:	83 ec 04             	sub    $0x4,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003b:	e8 b9 0e 00 00       	call   800ef9 <fork>
  800040:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
  800043:	85 c0                	test   %eax,%eax
  800045:	74 2b                	je     800072 <umain+0x3e>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800047:	83 ec 04             	sub    $0x4,%esp
  80004a:	50                   	push   %eax
  80004b:	83 ec 08             	sub    $0x8,%esp
  80004e:	e8 5f 0a 00 00       	call   800ab2 <sys_getenvid>
  800053:	83 c4 08             	add    $0x8,%esp
  800056:	50                   	push   %eax
  800057:	68 e0 14 80 00       	push   $0x8014e0
  80005c:	e8 47 01 00 00       	call   8001a8 <cprintf>
		ipc_send(who, 0, 0, 0);
  800061:	6a 00                	push   $0x0
  800063:	6a 00                	push   $0x0
  800065:	6a 00                	push   $0x0
  800067:	ff 75 f8             	pushl  0xfffffff8(%ebp)
  80006a:	e8 59 10 00 00       	call   8010c8 <ipc_send>
  80006f:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
  80007c:	50                   	push   %eax
  80007d:	e8 c2 0f 00 00       	call   801044 <ipc_recv>
  800082:	89 c3                	mov    %eax,%ebx
		//cprintf("curenv:%x\n",env->env_id);
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800084:	ff 75 f8             	pushl  0xfffffff8(%ebp)
  800087:	50                   	push   %eax
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	e8 22 0a 00 00       	call   800ab2 <sys_getenvid>
  800090:	83 c4 08             	add    $0x8,%esp
  800093:	50                   	push   %eax
  800094:	68 f6 14 80 00       	push   $0x8014f6
  800099:	e8 0a 01 00 00       	call   8001a8 <cprintf>
		if (i == 10)
  80009e:	83 c4 20             	add    $0x20,%esp
  8000a1:	83 fb 0a             	cmp    $0xa,%ebx
  8000a4:	74 16                	je     8000bc <umain+0x88>
			return;
		i++;
  8000a6:	43                   	inc    %ebx
		//cprintf("curenv %d send %d\n",env->env_id,who);
		ipc_send(who, i, 0, 0);
  8000a7:	6a 00                	push   $0x0
  8000a9:	6a 00                	push   $0x0
  8000ab:	53                   	push   %ebx
  8000ac:	ff 75 f8             	pushl  0xfffffff8(%ebp)
  8000af:	e8 14 10 00 00       	call   8010c8 <ipc_send>
		if (i == 10)
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	83 fb 0a             	cmp    $0xa,%ebx
  8000ba:	75 b6                	jne    800072 <umain+0x3e>
			return;
	}
		
}
  8000bc:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  8000cf:	e8 de 09 00 00       	call   800ab2 <sys_getenvid>
  8000d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d9:	c1 e0 07             	shl    $0x7,%eax
  8000dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e1:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e6:	85 f6                	test   %esi,%esi
  8000e8:	7e 07                	jle    8000f1 <libmain+0x2d>
		binaryname = argv[0];
  8000ea:	8b 03                	mov    (%ebx),%eax
  8000ec:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f1:	83 ec 08             	sub    $0x8,%esp
  8000f4:	53                   	push   %ebx
  8000f5:	56                   	push   %esi
  8000f6:	e8 39 ff ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  8000fb:	e8 08 00 00 00       	call   800108 <exit>
}
  800100:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	c9                   	leave  
  800106:	c3                   	ret    
	...

00800108 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  80010e:	6a 00                	push   $0x0
  800110:	e8 4c 09 00 00       	call   800a61 <sys_env_destroy>
}
  800115:	c9                   	leave  
  800116:	c3                   	ret    
	...

00800118 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 04             	sub    $0x4,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 03                	mov    (%ebx),%eax
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80012b:	40                   	inc    %eax
  80012c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 1a                	jne    80014f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 be 08 00 00       	call   800a04 <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014f:	ff 43 04             	incl   0x4(%ebx)
}
  800152:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 18 01 80 00       	push   $0x800118
  800186:	e8 83 01 00 00       	call   80030e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800194:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 64 08 00 00       	call   800a04 <sys_cputs>

	return b.cnt;
  8001a0:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	8b 75 10             	mov    0x10(%ebp),%esi
  8001c8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cb:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ce:	8b 45 18             	mov    0x18(%ebp),%eax
  8001d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d6:	39 d7                	cmp    %edx,%edi
  8001d8:	72 39                	jb     800213 <printnum+0x57>
  8001da:	77 04                	ja     8001e0 <printnum+0x24>
  8001dc:	39 c6                	cmp    %eax,%esi
  8001de:	72 33                	jb     800213 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e0:	83 ec 04             	sub    $0x4,%esp
  8001e3:	ff 75 20             	pushl  0x20(%ebp)
  8001e6:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8001e9:	50                   	push   %eax
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f5:	52                   	push   %edx
  8001f6:	50                   	push   %eax
  8001f7:	57                   	push   %edi
  8001f8:	56                   	push   %esi
  8001f9:	e8 02 10 00 00       	call   801200 <__udivdi3>
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	52                   	push   %edx
  800202:	50                   	push   %eax
  800203:	ff 75 0c             	pushl  0xc(%ebp)
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 ae ff ff ff       	call   8001bc <printnum>
  80020e:	83 c4 20             	add    $0x20,%esp
  800211:	eb 19                	jmp    80022c <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800213:	4b                   	dec    %ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7e 14                	jle    80022c <printnum+0x70>
			putch(padc, putdat);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	ff 75 0c             	pushl  0xc(%ebp)
  80021e:	ff 75 20             	pushl  0x20(%ebp)
  800221:	ff 55 08             	call   *0x8(%ebp)
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	4b                   	dec    %ebx
  800228:	85 db                	test   %ebx,%ebx
  80022a:	7f ec                	jg     800218 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	ff 75 0c             	pushl  0xc(%ebp)
  800232:	8b 45 18             	mov    0x18(%ebp),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	52                   	push   %edx
  80023e:	50                   	push   %eax
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	e8 da 10 00 00       	call   801320 <__umoddi3>
  800246:	83 c4 14             	add    $0x14,%esp
  800249:	0f be 80 b3 15 80 00 	movsbl 0x8015b3(%eax),%eax
  800250:	50                   	push   %eax
  800251:	ff 55 08             	call   *0x8(%ebp)
}
  800254:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 18             	sub    $0x18,%esp
  800264:	8b 75 08             	mov    0x8(%ebp),%esi
  800267:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026a:	8a 45 18             	mov    0x18(%ebp),%al
  80026d:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  800270:	53                   	push   %ebx
  800271:	6a 1b                	push   $0x1b
  800273:	ff d6                	call   *%esi
	putch('[', putdat);
  800275:	83 c4 08             	add    $0x8,%esp
  800278:	53                   	push   %ebx
  800279:	6a 5b                	push   $0x5b
  80027b:	ff d6                	call   *%esi
	putch('0', putdat);
  80027d:	83 c4 08             	add    $0x8,%esp
  800280:	53                   	push   %ebx
  800281:	6a 30                	push   $0x30
  800283:	ff d6                	call   *%esi
	putch(';', putdat);
  800285:	83 c4 08             	add    $0x8,%esp
  800288:	53                   	push   %ebx
  800289:	6a 3b                	push   $0x3b
  80028b:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  80028d:	83 c4 0c             	add    $0xc,%esp
  800290:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800294:	50                   	push   %eax
  800295:	ff 75 14             	pushl  0x14(%ebp)
  800298:	6a 0a                	push   $0xa
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	99                   	cltd   
  80029e:	52                   	push   %edx
  80029f:	50                   	push   %eax
  8002a0:	53                   	push   %ebx
  8002a1:	56                   	push   %esi
  8002a2:	e8 15 ff ff ff       	call   8001bc <printnum>
	putch('m', putdat);
  8002a7:	83 c4 18             	add    $0x18,%esp
  8002aa:	53                   	push   %ebx
  8002ab:	6a 6d                	push   $0x6d
  8002ad:	ff d6                	call   *%esi

}
  8002af:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002bf:	83 f8 01             	cmp    $0x1,%eax
  8002c2:	7e 0f                	jle    8002d3 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002c4:	8b 01                	mov    (%ecx),%eax
  8002c6:	83 c0 08             	add    $0x8,%eax
  8002c9:	89 01                	mov    %eax,(%ecx)
  8002cb:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002ce:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002d1:	eb 0f                	jmp    8002e2 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8002d3:	8b 01                	mov    (%ecx),%eax
  8002d5:	83 c0 04             	add    $0x4,%eax
  8002d8:	89 01                	mov    %eax,(%ecx)
  8002da:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002ed:	83 f8 01             	cmp    $0x1,%eax
  8002f0:	7e 0f                	jle    800301 <getint+0x1d>
		return va_arg(*ap, long long);
  8002f2:	8b 02                	mov    (%edx),%eax
  8002f4:	83 c0 08             	add    $0x8,%eax
  8002f7:	89 02                	mov    %eax,(%edx)
  8002f9:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002fc:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002ff:	eb 0b                	jmp    80030c <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800301:	8b 02                	mov    (%edx),%eax
  800303:	83 c0 04             	add    $0x4,%eax
  800306:	89 02                	mov    %eax,(%edx)
  800308:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  80030b:	99                   	cltd   
}
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 1c             	sub    $0x1c,%esp
  800317:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031a:	0f b6 13             	movzbl (%ebx),%edx
  80031d:	43                   	inc    %ebx
  80031e:	83 fa 25             	cmp    $0x25,%edx
  800321:	74 1e                	je     800341 <vprintfmt+0x33>
			if (ch == '\0')
  800323:	85 d2                	test   %edx,%edx
  800325:	0f 84 dc 02 00 00    	je     800607 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  80032b:	83 ec 08             	sub    $0x8,%esp
  80032e:	ff 75 0c             	pushl  0xc(%ebp)
  800331:	52                   	push   %edx
  800332:	ff 55 08             	call   *0x8(%ebp)
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	0f b6 13             	movzbl (%ebx),%edx
  80033b:	43                   	inc    %ebx
  80033c:	83 fa 25             	cmp    $0x25,%edx
  80033f:	75 e2                	jne    800323 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800341:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  800345:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  80034c:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800351:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  800356:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  80035d:	0f b6 13             	movzbl (%ebx),%edx
  800360:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  800363:	43                   	inc    %ebx
  800364:	83 f8 55             	cmp    $0x55,%eax
  800367:	0f 87 75 02 00 00    	ja     8005e2 <vprintfmt+0x2d4>
  80036d:	ff 24 85 04 16 80 00 	jmp    *0x801604(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800374:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800378:	eb e3                	jmp    80035d <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037a:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  80037e:	eb dd                	jmp    80035d <vprintfmt+0x4f>

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
  800380:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800385:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800388:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  80038c:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80038f:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800392:	83 f8 09             	cmp    $0x9,%eax
  800395:	77 27                	ja     8003be <vprintfmt+0xb0>
  800397:	43                   	inc    %ebx
  800398:	eb eb                	jmp    800385 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039a:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  8003a4:	eb 18                	jmp    8003be <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  8003a6:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003aa:	79 b1                	jns    80035d <vprintfmt+0x4f>
				width = 0;
  8003ac:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  8003b3:	eb a8                	jmp    80035d <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8003b5:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  8003bc:	eb 9f                	jmp    80035d <vprintfmt+0x4f>

			process_precision: if (width < 0)
  8003be:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003c2:	79 99                	jns    80035d <vprintfmt+0x4f>
				width = precision, precision = -1;
  8003c4:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8003c7:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003cc:	eb 8f                	jmp    80035d <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ce:	41                   	inc    %ecx
			goto reswitch;
  8003cf:	eb 8c                	jmp    80035d <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	ff 75 0c             	pushl  0xc(%ebp)
  8003d7:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	ff 70 fc             	pushl  0xfffffffc(%eax)
  8003e1:	e9 c4 01 00 00       	jmp    8005aa <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	79 02                	jns    8003f6 <vprintfmt+0xe8>
				err = -err;
  8003f4:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 08             	cmp    $0x8,%eax
  8003f9:	7f 0b                	jg     800406 <vprintfmt+0xf8>
  8003fb:	8b 3c 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edi
  800402:	85 ff                	test   %edi,%edi
  800404:	75 08                	jne    80040e <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	68 c4 15 80 00       	push   $0x8015c4
  80040c:	eb 06                	jmp    800414 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  80040e:	57                   	push   %edi
  80040f:	68 cd 15 80 00       	push   $0x8015cd
  800414:	ff 75 0c             	pushl  0xc(%ebp)
  800417:	ff 75 08             	pushl  0x8(%ebp)
  80041a:	e8 f0 01 00 00       	call   80060f <printfmt>
  80041f:	e9 89 01 00 00       	jmp    8005ad <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800424:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  80042e:	85 ff                	test   %edi,%edi
  800430:	75 05                	jne    800437 <vprintfmt+0x129>
				p = "(null)";
  800432:	bf d0 15 80 00       	mov    $0x8015d0,%edi
			if (width > 0 && padc != '-')
  800437:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80043b:	7e 3b                	jle    800478 <vprintfmt+0x16a>
  80043d:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  800441:	74 35                	je     800478 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	56                   	push   %esi
  800447:	57                   	push   %edi
  800448:	e8 74 02 00 00       	call   8006c1 <strnlen>
  80044d:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800457:	7e 1f                	jle    800478 <vprintfmt+0x16a>
  800459:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80045d:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	ff 75 0c             	pushl  0xc(%ebp)
  800466:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  800469:	ff 55 08             	call   *0x8(%ebp)
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800472:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800476:	7f e8                	jg     800460 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800478:	0f be 17             	movsbl (%edi),%edx
  80047b:	47                   	inc    %edi
  80047c:	85 d2                	test   %edx,%edx
  80047e:	74 3e                	je     8004be <vprintfmt+0x1b0>
  800480:	85 f6                	test   %esi,%esi
  800482:	78 03                	js     800487 <vprintfmt+0x179>
  800484:	4e                   	dec    %esi
  800485:	78 37                	js     8004be <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  800487:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  80048b:	74 12                	je     80049f <vprintfmt+0x191>
  80048d:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800490:	83 f8 5e             	cmp    $0x5e,%eax
  800493:	76 0a                	jbe    80049f <vprintfmt+0x191>
					putch('?', putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	6a 3f                	push   $0x3f
  80049d:	eb 07                	jmp    8004a6 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 0c             	pushl  0xc(%ebp)
  8004a5:	52                   	push   %edx
  8004a6:	ff 55 08             	call   *0x8(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004af:	0f be 17             	movsbl (%edi),%edx
  8004b2:	47                   	inc    %edi
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	74 07                	je     8004be <vprintfmt+0x1b0>
  8004b7:	85 f6                	test   %esi,%esi
  8004b9:	78 cc                	js     800487 <vprintfmt+0x179>
  8004bb:	4e                   	dec    %esi
  8004bc:	79 c9                	jns    800487 <vprintfmt+0x179>
			for (; width > 0; width--)
  8004be:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004c2:	0f 8e 52 fe ff ff    	jle    80031a <vprintfmt+0xc>
				putch(' ', putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ce:	6a 20                	push   $0x20
  8004d0:	ff 55 08             	call   *0x8(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004d9:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004dd:	7f e9                	jg     8004c8 <vprintfmt+0x1ba>
			break;
  8004df:	e9 36 fe ff ff       	jmp    80031a <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	51                   	push   %ecx
  8004e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004eb:	50                   	push   %eax
  8004ec:	e8 f3 fd ff ff       	call   8002e4 <getint>
  8004f1:	89 c6                	mov    %eax,%esi
  8004f3:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	85 d2                	test   %edx,%edx
  8004fa:	79 15                	jns    800511 <vprintfmt+0x203>
				putch('-', putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	6a 2d                	push   $0x2d
  800504:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800507:	f7 de                	neg    %esi
  800509:	83 d7 00             	adc    $0x0,%edi
  80050c:	f7 df                	neg    %edi
  80050e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800511:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800516:	eb 70                	jmp    800588 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	51                   	push   %ecx
  80051c:	8d 45 14             	lea    0x14(%ebp),%eax
  80051f:	50                   	push   %eax
  800520:	e8 91 fd ff ff       	call   8002b6 <getuint>
  800525:	89 c6                	mov    %eax,%esi
  800527:	89 d7                	mov    %edx,%edi
			base = 10;
  800529:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80052e:	eb 55                	jmp    800585 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	51                   	push   %ecx
  800534:	8d 45 14             	lea    0x14(%ebp),%eax
  800537:	50                   	push   %eax
  800538:	e8 79 fd ff ff       	call   8002b6 <getuint>
  80053d:	89 c6                	mov    %eax,%esi
  80053f:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  800541:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800546:	eb 3d                	jmp    800585 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	ff 75 0c             	pushl  0xc(%ebp)
  80054e:	6a 30                	push   $0x30
  800550:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	ff 75 0c             	pushl  0xc(%ebp)
  800559:	6a 78                	push   $0x78
  80055b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80055e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800568:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  80056d:	eb 11                	jmp    800580 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	51                   	push   %ecx
  800573:	8d 45 14             	lea    0x14(%ebp),%eax
  800576:	50                   	push   %eax
  800577:	e8 3a fd ff ff       	call   8002b6 <getuint>
  80057c:	89 c6                	mov    %eax,%esi
  80057e:	89 d7                	mov    %edx,%edi
			base = 16;
  800580:	ba 10 00 00 00       	mov    $0x10,%edx
  800585:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800588:	83 ec 04             	sub    $0x4,%esp
  80058b:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80058f:	50                   	push   %eax
  800590:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800593:	52                   	push   %edx
  800594:	57                   	push   %edi
  800595:	56                   	push   %esi
  800596:	ff 75 0c             	pushl  0xc(%ebp)
  800599:	ff 75 08             	pushl  0x8(%ebp)
  80059c:	e8 1b fc ff ff       	call   8001bc <printnum>
			break;
  8005a1:	eb 37                	jmp    8005da <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	ff 75 0c             	pushl  0xc(%ebp)
  8005a9:	52                   	push   %edx
  8005aa:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	e9 65 fd ff ff       	jmp    80031a <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	51                   	push   %ecx
  8005b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bc:	50                   	push   %eax
  8005bd:	e8 f4 fc ff ff       	call   8002b6 <getuint>
  8005c2:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  8005c4:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8005ce:	56                   	push   %esi
  8005cf:	ff 75 0c             	pushl  0xc(%ebp)
  8005d2:	ff 75 08             	pushl  0x8(%ebp)
  8005d5:	e8 82 fc ff ff       	call   80025c <printcolor>
			break;
  8005da:	83 c4 20             	add    $0x20,%esp
  8005dd:	e9 38 fd ff ff       	jmp    80031a <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	ff 75 0c             	pushl  0xc(%ebp)
  8005e8:	6a 25                	push   $0x25
  8005ea:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005ed:	4b                   	dec    %ebx
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005f5:	0f 84 1f fd ff ff    	je     80031a <vprintfmt+0xc>
  8005fb:	4b                   	dec    %ebx
  8005fc:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800600:	75 f9                	jne    8005fb <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800602:	e9 13 fd ff ff       	jmp    80031a <vprintfmt+0xc>
		}
	}
}
  800607:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80060a:	5b                   	pop    %ebx
  80060b:	5e                   	pop    %esi
  80060c:	5f                   	pop    %edi
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800615:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800618:	50                   	push   %eax
  800619:	ff 75 10             	pushl  0x10(%ebp)
  80061c:	ff 75 0c             	pushl  0xc(%ebp)
  80061f:	ff 75 08             	pushl  0x8(%ebp)
  800622:	e8 e7 fc ff ff       	call   80030e <vprintfmt>
	va_end(ap);
}
  800627:	c9                   	leave  
  800628:	c3                   	ret    

00800629 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  800629:	55                   	push   %ebp
  80062a:	89 e5                	mov    %esp,%ebp
  80062c:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80062f:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800632:	8b 0a                	mov    (%edx),%ecx
  800634:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800637:	73 07                	jae    800640 <sprintputch+0x17>
		*b->buf++ = ch;
  800639:	8b 45 08             	mov    0x8(%ebp),%eax
  80063c:	88 01                	mov    %al,(%ecx)
  80063e:	ff 02                	incl   (%edx)
}
  800640:	c9                   	leave  
  800641:	c3                   	ret    

00800642 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	83 ec 18             	sub    $0x18,%esp
  800648:	8b 55 08             	mov    0x8(%ebp),%edx
  80064b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80064e:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800651:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800655:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800658:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  80065f:	85 d2                	test   %edx,%edx
  800661:	74 04                	je     800667 <vsnprintf+0x25>
  800663:	85 c9                	test   %ecx,%ecx
  800665:	7f 07                	jg     80066e <vsnprintf+0x2c>
		return -E_INVAL;
  800667:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80066c:	eb 1d                	jmp    80068b <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  80066e:	ff 75 14             	pushl  0x14(%ebp)
  800671:	ff 75 10             	pushl  0x10(%ebp)
  800674:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800677:	50                   	push   %eax
  800678:	68 29 06 80 00       	push   $0x800629
  80067d:	e8 8c fc ff ff       	call   80030e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800682:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800685:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800688:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    

0080068d <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800696:	50                   	push   %eax
  800697:	ff 75 10             	pushl  0x10(%ebp)
  80069a:	ff 75 0c             	pushl  0xc(%ebp)
  80069d:	ff 75 08             	pushl  0x8(%ebp)
  8006a0:	e8 9d ff ff ff       	call   800642 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    
	...

008006a8 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b3:	80 3a 00             	cmpb   $0x0,(%edx)
  8006b6:	74 07                	je     8006bf <strlen+0x17>
		n++;
  8006b8:	40                   	inc    %eax
  8006b9:	42                   	inc    %edx
  8006ba:	80 3a 00             	cmpb   $0x0,(%edx)
  8006bd:	75 f9                	jne    8006b8 <strlen+0x10>
	return n;
}
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cf:	85 d2                	test   %edx,%edx
  8006d1:	74 0f                	je     8006e2 <strnlen+0x21>
  8006d3:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d6:	74 0a                	je     8006e2 <strnlen+0x21>
		n++;
  8006d8:	40                   	inc    %eax
  8006d9:	41                   	inc    %ecx
  8006da:	4a                   	dec    %edx
  8006db:	74 05                	je     8006e2 <strnlen+0x21>
  8006dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e0:	75 f6                	jne    8006d8 <strnlen+0x17>
	return n;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	53                   	push   %ebx
  8006e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006ee:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006f0:	8a 02                	mov    (%edx),%al
  8006f2:	42                   	inc    %edx
  8006f3:	88 01                	mov    %al,(%ecx)
  8006f5:	41                   	inc    %ecx
  8006f6:	84 c0                	test   %al,%al
  8006f8:	75 f6                	jne    8006f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006fa:	89 d8                	mov    %ebx,%eax
  8006fc:	5b                   	pop    %ebx
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	57                   	push   %edi
  800703:	56                   	push   %esi
  800704:	53                   	push   %ebx
  800705:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
  80070b:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80070e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800710:	bb 00 00 00 00       	mov    $0x0,%ebx
  800715:	39 f3                	cmp    %esi,%ebx
  800717:	73 10                	jae    800729 <strncpy+0x2a>
		*dst++ = *src;
  800719:	8a 02                	mov    (%edx),%al
  80071b:	88 01                	mov    %al,(%ecx)
  80071d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80071e:	80 3a 00             	cmpb   $0x0,(%edx)
  800721:	74 01                	je     800724 <strncpy+0x25>
			src++;
  800723:	42                   	inc    %edx
  800724:	43                   	inc    %ebx
  800725:	39 f3                	cmp    %esi,%ebx
  800727:	72 f0                	jb     800719 <strncpy+0x1a>
	}
	return ret;
}
  800729:	89 f8                	mov    %edi,%eax
  80072b:	5b                   	pop    %ebx
  80072c:	5e                   	pop    %esi
  80072d:	5f                   	pop    %edi
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	56                   	push   %esi
  800734:	53                   	push   %ebx
  800735:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80073e:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800740:	85 d2                	test   %edx,%edx
  800742:	74 19                	je     80075d <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800744:	4a                   	dec    %edx
  800745:	74 13                	je     80075a <strlcpy+0x2a>
  800747:	80 39 00             	cmpb   $0x0,(%ecx)
  80074a:	74 0e                	je     80075a <strlcpy+0x2a>
			*dst++ = *src++;
  80074c:	8a 01                	mov    (%ecx),%al
  80074e:	41                   	inc    %ecx
  80074f:	88 03                	mov    %al,(%ebx)
  800751:	43                   	inc    %ebx
  800752:	4a                   	dec    %edx
  800753:	74 05                	je     80075a <strlcpy+0x2a>
  800755:	80 39 00             	cmpb   $0x0,(%ecx)
  800758:	75 f2                	jne    80074c <strlcpy+0x1c>
		*dst = '\0';
  80075a:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  80075d:	89 d8                	mov    %ebx,%eax
  80075f:	29 f0                	sub    %esi,%eax
}
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	8b 55 08             	mov    0x8(%ebp),%edx
  80076b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80076e:	80 3a 00             	cmpb   $0x0,(%edx)
  800771:	74 13                	je     800786 <strcmp+0x21>
  800773:	8a 02                	mov    (%edx),%al
  800775:	3a 01                	cmp    (%ecx),%al
  800777:	75 0d                	jne    800786 <strcmp+0x21>
		p++, q++;
  800779:	42                   	inc    %edx
  80077a:	41                   	inc    %ecx
  80077b:	80 3a 00             	cmpb   $0x0,(%edx)
  80077e:	74 06                	je     800786 <strcmp+0x21>
  800780:	8a 02                	mov    (%edx),%al
  800782:	3a 01                	cmp    (%ecx),%al
  800784:	74 f3                	je     800779 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800786:	0f b6 02             	movzbl (%edx),%eax
  800789:	0f b6 11             	movzbl (%ecx),%edx
  80078c:	29 d0                	sub    %edx,%eax
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	8b 55 08             	mov    0x8(%ebp),%edx
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  80079d:	85 c9                	test   %ecx,%ecx
  80079f:	74 1f                	je     8007c0 <strncmp+0x30>
  8007a1:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a4:	74 16                	je     8007bc <strncmp+0x2c>
  8007a6:	8a 02                	mov    (%edx),%al
  8007a8:	3a 03                	cmp    (%ebx),%al
  8007aa:	75 10                	jne    8007bc <strncmp+0x2c>
		n--, p++, q++;
  8007ac:	42                   	inc    %edx
  8007ad:	43                   	inc    %ebx
  8007ae:	49                   	dec    %ecx
  8007af:	74 0f                	je     8007c0 <strncmp+0x30>
  8007b1:	80 3a 00             	cmpb   $0x0,(%edx)
  8007b4:	74 06                	je     8007bc <strncmp+0x2c>
  8007b6:	8a 02                	mov    (%edx),%al
  8007b8:	3a 03                	cmp    (%ebx),%al
  8007ba:	74 f0                	je     8007ac <strncmp+0x1c>
	if (n == 0)
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	75 07                	jne    8007c7 <strncmp+0x37>
		return 0;
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c5:	eb 0a                	jmp    8007d1 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c7:	0f b6 12             	movzbl (%edx),%edx
  8007ca:	0f b6 03             	movzbl (%ebx),%eax
  8007cd:	29 c2                	sub    %eax,%edx
  8007cf:	89 d0                	mov    %edx,%eax
}
  8007d1:	8b 1c 24             	mov    (%esp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007df:	80 38 00             	cmpb   $0x0,(%eax)
  8007e2:	74 0a                	je     8007ee <strchr+0x18>
		if (*s == c)
  8007e4:	38 10                	cmp    %dl,(%eax)
  8007e6:	74 0b                	je     8007f3 <strchr+0x1d>
  8007e8:	40                   	inc    %eax
  8007e9:	80 38 00             	cmpb   $0x0,(%eax)
  8007ec:	75 f6                	jne    8007e4 <strchr+0xe>
			return (char *) s;
	return 0;
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    

008007f5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007fe:	80 38 00             	cmpb   $0x0,(%eax)
  800801:	74 0a                	je     80080d <strfind+0x18>
		if (*s == c)
  800803:	38 10                	cmp    %dl,(%eax)
  800805:	74 06                	je     80080d <strfind+0x18>
  800807:	40                   	inc    %eax
  800808:	80 38 00             	cmpb   $0x0,(%eax)
  80080b:	75 f6                	jne    800803 <strfind+0xe>
			break;
	return (char *) s;
}
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	57                   	push   %edi
  800813:	8b 7d 08             	mov    0x8(%ebp),%edi
  800816:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800819:	89 f8                	mov    %edi,%eax
  80081b:	85 c9                	test   %ecx,%ecx
  80081d:	74 40                	je     80085f <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80081f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800825:	75 30                	jne    800857 <memset+0x48>
  800827:	f6 c1 03             	test   $0x3,%cl
  80082a:	75 2b                	jne    800857 <memset+0x48>
		c &= 0xFF;
  80082c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800833:	8b 45 0c             	mov    0xc(%ebp),%eax
  800836:	c1 e0 18             	shl    $0x18,%eax
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083c:	c1 e2 10             	shl    $0x10,%edx
  80083f:	09 d0                	or     %edx,%eax
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
  800844:	c1 e2 08             	shl    $0x8,%edx
  800847:	09 d0                	or     %edx,%eax
  800849:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80084c:	c1 e9 02             	shr    $0x2,%ecx
  80084f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800852:	fc                   	cld    
  800853:	f3 ab                	repz stos %eax,%es:(%edi)
  800855:	eb 06                	jmp    80085d <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	fc                   	cld    
  80085b:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  80085d:	89 f8                	mov    %edi,%eax
}
  80085f:	8b 3c 24             	mov    (%esp),%edi
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80086f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800872:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800874:	39 c6                	cmp    %eax,%esi
  800876:	73 33                	jae    8008ab <memmove+0x47>
  800878:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  80087b:	39 c2                	cmp    %eax,%edx
  80087d:	76 2c                	jbe    8008ab <memmove+0x47>
		s += n;
  80087f:	89 d6                	mov    %edx,%esi
		d += n;
  800881:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800884:	f6 c2 03             	test   $0x3,%dl
  800887:	75 1b                	jne    8008a4 <memmove+0x40>
  800889:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088f:	75 13                	jne    8008a4 <memmove+0x40>
  800891:	f6 c1 03             	test   $0x3,%cl
  800894:	75 0e                	jne    8008a4 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800896:	83 ef 04             	sub    $0x4,%edi
  800899:	83 ee 04             	sub    $0x4,%esi
  80089c:	c1 e9 02             	shr    $0x2,%ecx
  80089f:	fd                   	std    
  8008a0:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  8008a2:	eb 27                	jmp    8008cb <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a4:	4f                   	dec    %edi
  8008a5:	4e                   	dec    %esi
  8008a6:	fd                   	std    
  8008a7:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  8008a9:	eb 20                	jmp    8008cb <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ab:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b1:	75 15                	jne    8008c8 <memmove+0x64>
  8008b3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b9:	75 0d                	jne    8008c8 <memmove+0x64>
  8008bb:	f6 c1 03             	test   $0x3,%cl
  8008be:	75 08                	jne    8008c8 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  8008c0:	c1 e9 02             	shr    $0x2,%ecx
  8008c3:	fc                   	cld    
  8008c4:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  8008c6:	eb 03                	jmp    8008cb <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c8:	fc                   	cld    
  8008c9:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <memcpy>:

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
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008d5:	ff 75 10             	pushl  0x10(%ebp)
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	ff 75 08             	pushl  0x8(%ebp)
  8008de:	e8 81 ff ff ff       	call   800864 <memmove>
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	4a                   	dec    %edx
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	74 1b                	je     800914 <memcmp+0x2f>
		if (*s1 != *s2)
  8008f9:	8a 01                	mov    (%ecx),%al
  8008fb:	3a 03                	cmp    (%ebx),%al
  8008fd:	74 0c                	je     80090b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008ff:	0f b6 d0             	movzbl %al,%edx
  800902:	0f b6 03             	movzbl (%ebx),%eax
  800905:	29 c2                	sub    %eax,%edx
  800907:	89 d0                	mov    %edx,%eax
  800909:	eb 0e                	jmp    800919 <memcmp+0x34>
		s1++, s2++;
  80090b:	41                   	inc    %ecx
  80090c:	43                   	inc    %ebx
  80090d:	89 d0                	mov    %edx,%eax
  80090f:	4a                   	dec    %edx
  800910:	85 c0                	test   %eax,%eax
  800912:	75 e5                	jne    8008f9 <memcmp+0x14>
	}

	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5b                   	pop    %ebx
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800925:	89 c2                	mov    %eax,%edx
  800927:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80092a:	39 d0                	cmp    %edx,%eax
  80092c:	73 09                	jae    800937 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092e:	38 08                	cmp    %cl,(%eax)
  800930:	74 05                	je     800937 <memfind+0x1b>
  800932:	40                   	inc    %eax
  800933:	39 d0                	cmp    %edx,%eax
  800935:	72 f7                	jb     80092e <memfind+0x12>
			break;
	return (void *) s;
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 55 08             	mov    0x8(%ebp),%edx
  800942:	8b 75 0c             	mov    0xc(%ebp),%esi
  800945:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800948:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  80094d:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800952:	80 3a 20             	cmpb   $0x20,(%edx)
  800955:	74 05                	je     80095c <strtol+0x23>
  800957:	80 3a 09             	cmpb   $0x9,(%edx)
  80095a:	75 0b                	jne    800967 <strtol+0x2e>
		s++;
  80095c:	42                   	inc    %edx
  80095d:	80 3a 20             	cmpb   $0x20,(%edx)
  800960:	74 fa                	je     80095c <strtol+0x23>
  800962:	80 3a 09             	cmpb   $0x9,(%edx)
  800965:	74 f5                	je     80095c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800967:	80 3a 2b             	cmpb   $0x2b,(%edx)
  80096a:	75 03                	jne    80096f <strtol+0x36>
		s++;
  80096c:	42                   	inc    %edx
  80096d:	eb 0b                	jmp    80097a <strtol+0x41>
	else if (*s == '-')
  80096f:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800972:	75 06                	jne    80097a <strtol+0x41>
		s++, neg = 1;
  800974:	42                   	inc    %edx
  800975:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097a:	85 c9                	test   %ecx,%ecx
  80097c:	74 05                	je     800983 <strtol+0x4a>
  80097e:	83 f9 10             	cmp    $0x10,%ecx
  800981:	75 15                	jne    800998 <strtol+0x5f>
  800983:	80 3a 30             	cmpb   $0x30,(%edx)
  800986:	75 10                	jne    800998 <strtol+0x5f>
  800988:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80098c:	75 0a                	jne    800998 <strtol+0x5f>
		s += 2, base = 16;
  80098e:	83 c2 02             	add    $0x2,%edx
  800991:	b9 10 00 00 00       	mov    $0x10,%ecx
  800996:	eb 1a                	jmp    8009b2 <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800998:	85 c9                	test   %ecx,%ecx
  80099a:	75 16                	jne    8009b2 <strtol+0x79>
  80099c:	80 3a 30             	cmpb   $0x30,(%edx)
  80099f:	75 08                	jne    8009a9 <strtol+0x70>
		s++, base = 8;
  8009a1:	42                   	inc    %edx
  8009a2:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009a7:	eb 09                	jmp    8009b2 <strtol+0x79>
	else if (base == 0)
  8009a9:	85 c9                	test   %ecx,%ecx
  8009ab:	75 05                	jne    8009b2 <strtol+0x79>
		base = 10;
  8009ad:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b2:	8a 02                	mov    (%edx),%al
  8009b4:	83 e8 30             	sub    $0x30,%eax
  8009b7:	3c 09                	cmp    $0x9,%al
  8009b9:	77 08                	ja     8009c3 <strtol+0x8a>
			dig = *s - '0';
  8009bb:	0f be 02             	movsbl (%edx),%eax
  8009be:	83 e8 30             	sub    $0x30,%eax
  8009c1:	eb 20                	jmp    8009e3 <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  8009c3:	8a 02                	mov    (%edx),%al
  8009c5:	83 e8 61             	sub    $0x61,%eax
  8009c8:	3c 19                	cmp    $0x19,%al
  8009ca:	77 08                	ja     8009d4 <strtol+0x9b>
			dig = *s - 'a' + 10;
  8009cc:	0f be 02             	movsbl (%edx),%eax
  8009cf:	83 e8 57             	sub    $0x57,%eax
  8009d2:	eb 0f                	jmp    8009e3 <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  8009d4:	8a 02                	mov    (%edx),%al
  8009d6:	83 e8 41             	sub    $0x41,%eax
  8009d9:	3c 19                	cmp    $0x19,%al
  8009db:	77 12                	ja     8009ef <strtol+0xb6>
			dig = *s - 'A' + 10;
  8009dd:	0f be 02             	movsbl (%edx),%eax
  8009e0:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009e3:	39 c8                	cmp    %ecx,%eax
  8009e5:	7d 08                	jge    8009ef <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  8009e7:	42                   	inc    %edx
  8009e8:	0f af d9             	imul   %ecx,%ebx
  8009eb:	01 c3                	add    %eax,%ebx
  8009ed:	eb c3                	jmp    8009b2 <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009ef:	85 f6                	test   %esi,%esi
  8009f1:	74 02                	je     8009f5 <strtol+0xbc>
		*endptr = (char *) s;
  8009f3:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009f5:	89 d8                	mov    %ebx,%eax
  8009f7:	85 ff                	test   %edi,%edi
  8009f9:	74 02                	je     8009fd <strtol+0xc4>
  8009fb:	f7 d8                	neg    %eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    
	...

00800a04 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a10:	bf 00 00 00 00       	mov    $0x0,%edi
  800a15:	89 f8                	mov    %edi,%eax
  800a17:	89 fb                	mov    %edi,%ebx
  800a19:	89 fe                	mov    %edi,%esi
  800a1b:	55                   	push   %ebp
  800a1c:	9c                   	pushf  
  800a1d:	56                   	push   %esi
  800a1e:	54                   	push   %esp
  800a1f:	5d                   	pop    %ebp
  800a20:	8d 35 28 0a 80 00    	lea    0x800a28,%esi
  800a26:	0f 34                	sysenter 
  800a28:	83 c4 04             	add    $0x4,%esp
  800a2b:	9d                   	popf   
  800a2c:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    

00800a32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	57                   	push   %edi
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a42:	89 fa                	mov    %edi,%edx
  800a44:	89 f9                	mov    %edi,%ecx
  800a46:	89 fb                	mov    %edi,%ebx
  800a48:	89 fe                	mov    %edi,%esi
  800a4a:	55                   	push   %ebp
  800a4b:	9c                   	pushf  
  800a4c:	56                   	push   %esi
  800a4d:	54                   	push   %esp
  800a4e:	5d                   	pop    %ebp
  800a4f:	8d 35 57 0a 80 00    	lea    0x800a57,%esi
  800a55:	0f 34                	sysenter 
  800a57:	83 c4 04             	add    $0x4,%esp
  800a5a:	9d                   	popf   
  800a5b:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	83 ec 0c             	sub    $0xc,%esp
  800a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a72:	bf 00 00 00 00       	mov    $0x0,%edi
  800a77:	89 f9                	mov    %edi,%ecx
  800a79:	89 fb                	mov    %edi,%ebx
  800a7b:	89 fe                	mov    %edi,%esi
  800a7d:	55                   	push   %ebp
  800a7e:	9c                   	pushf  
  800a7f:	56                   	push   %esi
  800a80:	54                   	push   %esp
  800a81:	5d                   	pop    %ebp
  800a82:	8d 35 8a 0a 80 00    	lea    0x800a8a,%esi
  800a88:	0f 34                	sysenter 
  800a8a:	83 c4 04             	add    $0x4,%esp
  800a8d:	9d                   	popf   
  800a8e:	5d                   	pop    %ebp
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	7e 17                	jle    800aaa <sys_env_destroy+0x49>
  800a93:	83 ec 0c             	sub    $0xc,%esp
  800a96:	50                   	push   %eax
  800a97:	6a 03                	push   $0x3
  800a99:	68 5c 17 80 00       	push   $0x80175c
  800a9e:	6a 4c                	push   $0x4c
  800aa0:	68 79 17 80 00       	push   $0x801779
  800aa5:	e8 8a 06 00 00       	call   801134 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aaa:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	c9                   	leave  
  800ab1:	c3                   	ret    

00800ab2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	b8 02 00 00 00       	mov    $0x2,%eax
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac2:	89 fa                	mov    %edi,%edx
  800ac4:	89 f9                	mov    %edi,%ecx
  800ac6:	89 fb                	mov    %edi,%ebx
  800ac8:	89 fe                	mov    %edi,%esi
  800aca:	55                   	push   %ebp
  800acb:	9c                   	pushf  
  800acc:	56                   	push   %esi
  800acd:	54                   	push   %esp
  800ace:	5d                   	pop    %ebp
  800acf:	8d 35 d7 0a 80 00    	lea    0x800ad7,%esi
  800ad5:	0f 34                	sysenter 
  800ad7:	83 c4 04             	add    $0x4,%esp
  800ada:	9d                   	popf   
  800adb:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    

00800ae1 <sys_dump_env>:

int
sys_dump_env(void)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	b8 04 00 00 00       	mov    $0x4,%eax
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
  800af1:	89 fa                	mov    %edi,%edx
  800af3:	89 f9                	mov    %edi,%ecx
  800af5:	89 fb                	mov    %edi,%ebx
  800af7:	89 fe                	mov    %edi,%esi
  800af9:	55                   	push   %ebp
  800afa:	9c                   	pushf  
  800afb:	56                   	push   %esi
  800afc:	54                   	push   %esp
  800afd:	5d                   	pop    %ebp
  800afe:	8d 35 06 0b 80 00    	lea    0x800b06,%esi
  800b04:	0f 34                	sysenter 
  800b06:	83 c4 04             	add    $0x4,%esp
  800b09:	9d                   	popf   
  800b0a:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <sys_yield>:

void
sys_yield(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b20:	89 fa                	mov    %edi,%edx
  800b22:	89 f9                	mov    %edi,%ecx
  800b24:	89 fb                	mov    %edi,%ebx
  800b26:	89 fe                	mov    %edi,%esi
  800b28:	55                   	push   %ebp
  800b29:	9c                   	pushf  
  800b2a:	56                   	push   %esi
  800b2b:	54                   	push   %esp
  800b2c:	5d                   	pop    %ebp
  800b2d:	8d 35 35 0b 80 00    	lea    0x800b35,%esi
  800b33:	0f 34                	sysenter 
  800b35:	83 c4 04             	add    $0x4,%esp
  800b38:	9d                   	popf   
  800b39:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b51:	b8 05 00 00 00       	mov    $0x5,%eax
  800b56:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5b:	89 fe                	mov    %edi,%esi
  800b5d:	55                   	push   %ebp
  800b5e:	9c                   	pushf  
  800b5f:	56                   	push   %esi
  800b60:	54                   	push   %esp
  800b61:	5d                   	pop    %ebp
  800b62:	8d 35 6a 0b 80 00    	lea    0x800b6a,%esi
  800b68:	0f 34                	sysenter 
  800b6a:	83 c4 04             	add    $0x4,%esp
  800b6d:	9d                   	popf   
  800b6e:	5d                   	pop    %ebp
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 17                	jle    800b8a <sys_page_alloc+0x4b>
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	50                   	push   %eax
  800b77:	6a 05                	push   $0x5
  800b79:	68 5c 17 80 00       	push   $0x80175c
  800b7e:	6a 4c                	push   $0x4c
  800b80:	68 79 17 80 00       	push   $0x801779
  800b85:	e8 aa 05 00 00       	call   801134 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba7:	8b 75 18             	mov    0x18(%ebp),%esi
  800baa:	b8 06 00 00 00       	mov    $0x6,%eax
  800baf:	55                   	push   %ebp
  800bb0:	9c                   	pushf  
  800bb1:	56                   	push   %esi
  800bb2:	54                   	push   %esp
  800bb3:	5d                   	pop    %ebp
  800bb4:	8d 35 bc 0b 80 00    	lea    0x800bbc,%esi
  800bba:	0f 34                	sysenter 
  800bbc:	83 c4 04             	add    $0x4,%esp
  800bbf:	9d                   	popf   
  800bc0:	5d                   	pop    %ebp
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_page_map+0x4a>
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 06                	push   $0x6
  800bcb:	68 5c 17 80 00       	push   $0x80175c
  800bd0:	6a 4c                	push   $0x4c
  800bd2:	68 79 17 80 00       	push   $0x801779
  800bd7:	e8 58 05 00 00       	call   801134 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800bdc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	b8 07 00 00 00       	mov    $0x7,%eax
  800bf8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfd:	89 fb                	mov    %edi,%ebx
  800bff:	89 fe                	mov    %edi,%esi
  800c01:	55                   	push   %ebp
  800c02:	9c                   	pushf  
  800c03:	56                   	push   %esi
  800c04:	54                   	push   %esp
  800c05:	5d                   	pop    %ebp
  800c06:	8d 35 0e 0c 80 00    	lea    0x800c0e,%esi
  800c0c:	0f 34                	sysenter 
  800c0e:	83 c4 04             	add    $0x4,%esp
  800c11:	9d                   	popf   
  800c12:	5d                   	pop    %ebp
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 17                	jle    800c2e <sys_page_unmap+0x4a>
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	50                   	push   %eax
  800c1b:	6a 07                	push   $0x7
  800c1d:	68 5c 17 80 00       	push   $0x80175c
  800c22:	6a 4c                	push   $0x4c
  800c24:	68 79 17 80 00       	push   $0x801779
  800c29:	e8 06 05 00 00       	call   801134 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c45:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4f:	89 fb                	mov    %edi,%ebx
  800c51:	89 fe                	mov    %edi,%esi
  800c53:	55                   	push   %ebp
  800c54:	9c                   	pushf  
  800c55:	56                   	push   %esi
  800c56:	54                   	push   %esp
  800c57:	5d                   	pop    %ebp
  800c58:	8d 35 60 0c 80 00    	lea    0x800c60,%esi
  800c5e:	0f 34                	sysenter 
  800c60:	83 c4 04             	add    $0x4,%esp
  800c63:	9d                   	popf   
  800c64:	5d                   	pop    %ebp
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_status+0x4a>
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 09                	push   $0x9
  800c6f:	68 5c 17 80 00       	push   $0x80175c
  800c74:	6a 4c                	push   $0x4c
  800c76:	68 79 17 80 00       	push   $0x801779
  800c7b:	e8 b4 04 00 00       	call   801134 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca1:	89 fb                	mov    %edi,%ebx
  800ca3:	89 fe                	mov    %edi,%esi
  800ca5:	55                   	push   %ebp
  800ca6:	9c                   	pushf  
  800ca7:	56                   	push   %esi
  800ca8:	54                   	push   %esp
  800ca9:	5d                   	pop    %ebp
  800caa:	8d 35 b2 0c 80 00    	lea    0x800cb2,%esi
  800cb0:	0f 34                	sysenter 
  800cb2:	83 c4 04             	add    $0x4,%esp
  800cb5:	9d                   	popf   
  800cb6:	5d                   	pop    %ebp
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_env_set_trapframe+0x4a>
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 0a                	push   $0xa
  800cc1:	68 5c 17 80 00       	push   $0x80175c
  800cc6:	6a 4c                	push   $0x4c
  800cc8:	68 79 17 80 00       	push   $0x801779
  800ccd:	e8 62 04 00 00       	call   801134 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd2:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    

00800cda <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cee:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf3:	89 fb                	mov    %edi,%ebx
  800cf5:	89 fe                	mov    %edi,%esi
  800cf7:	55                   	push   %ebp
  800cf8:	9c                   	pushf  
  800cf9:	56                   	push   %esi
  800cfa:	54                   	push   %esp
  800cfb:	5d                   	pop    %ebp
  800cfc:	8d 35 04 0d 80 00    	lea    0x800d04,%esi
  800d02:	0f 34                	sysenter 
  800d04:	83 c4 04             	add    $0x4,%esp
  800d07:	9d                   	popf   
  800d08:	5d                   	pop    %ebp
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 17                	jle    800d24 <sys_env_set_pgfault_upcall+0x4a>
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	50                   	push   %eax
  800d11:	6a 0b                	push   $0xb
  800d13:	68 5c 17 80 00       	push   $0x80175c
  800d18:	6a 4c                	push   $0x4c
  800d1a:	68 79 17 80 00       	push   $0x801779
  800d1f:	e8 10 04 00 00       	call   801134 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d24:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d43:	be 00 00 00 00       	mov    $0x0,%esi
  800d48:	55                   	push   %ebp
  800d49:	9c                   	pushf  
  800d4a:	56                   	push   %esi
  800d4b:	54                   	push   %esp
  800d4c:	5d                   	pop    %ebp
  800d4d:	8d 35 55 0d 80 00    	lea    0x800d55,%esi
  800d53:	0f 34                	sysenter 
  800d55:	83 c4 04             	add    $0x4,%esp
  800d58:	9d                   	popf   
  800d59:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d70:	bf 00 00 00 00       	mov    $0x0,%edi
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	89 fb                	mov    %edi,%ebx
  800d79:	89 fe                	mov    %edi,%esi
  800d7b:	55                   	push   %ebp
  800d7c:	9c                   	pushf  
  800d7d:	56                   	push   %esi
  800d7e:	54                   	push   %esp
  800d7f:	5d                   	pop    %ebp
  800d80:	8d 35 88 0d 80 00    	lea    0x800d88,%esi
  800d86:	0f 34                	sysenter 
  800d88:	83 c4 04             	add    $0x4,%esp
  800d8b:	9d                   	popf   
  800d8c:	5d                   	pop    %ebp
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7e 17                	jle    800da8 <sys_ipc_recv+0x49>
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	50                   	push   %eax
  800d95:	6a 0e                	push   $0xe
  800d97:	68 5c 17 80 00       	push   $0x80175c
  800d9c:	6a 4c                	push   $0x4c
  800d9e:	68 79 17 80 00       	push   $0x801779
  800da3:	e8 8c 03 00 00       	call   801134 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <pgfault>:
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	53                   	push   %ebx
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
    void *addr = (void *) utf->utf_fault_va;
  800dba:	8b 1a                	mov    (%edx),%ebx
    uint32_t err = utf->utf_err;
  800dbc:	8b 42 04             	mov    0x4(%edx),%eax
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
  800dbf:	a8 02                	test   $0x2,%al
  800dc1:	0f 84 ae 00 00 00    	je     800e75 <pgfault+0xc5>
        //cprintf("it's caused by fault write\n");
        if (vpt[PPN(addr)] & PTE_COW) {//first
  800dc7:	89 d8                	mov    %ebx,%eax
  800dc9:	c1 e8 0c             	shr    $0xc,%eax
  800dcc:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  800dd3:	f6 c4 08             	test   $0x8,%ah
  800dd6:	0f 84 85 00 00 00    	je     800e61 <pgfault+0xb1>
            //ok it's caused by copy on write
            //cprintf("it's caused by copy on write\n");
            if ((r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W))) {//wrong not ROUNDDOWN(addr,PGSIZE)
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	6a 07                	push   $0x7
  800de1:	68 00 f0 7f 00       	push   $0x7ff000
  800de6:	6a 00                	push   $0x0
  800de8:	e8 52 fd ff ff       	call   800b3f <sys_page_alloc>
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	74 0a                	je     800dfe <pgfault+0x4e>
                panic("pgfault->sys_page_alloc:%e",r);
  800df4:	50                   	push   %eax
  800df5:	68 87 17 80 00       	push   $0x801787
  800dfa:	6a 2f                	push   $0x2f
  800dfc:	eb 6d                	jmp    800e6b <pgfault+0xbb>
            }
            //cprintf("before copy data from ROUNDDOWN(%x,PGSIZE) to PFTEMP\n",addr);
            memcpy(PFTEMP,ROUNDDOWN(addr,PGSIZE),PGSIZE);
  800dfe:	89 d8                	mov    %ebx,%eax
  800e00:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e05:	29 c3                	sub    %eax,%ebx
  800e07:	83 ec 04             	sub    $0x4,%esp
  800e0a:	68 00 10 00 00       	push   $0x1000
  800e0f:	53                   	push   %ebx
  800e10:	68 00 f0 7f 00       	push   $0x7ff000
  800e15:	e8 b5 fa ff ff       	call   8008cf <memcpy>
            //cprintf("before map the PFTEMP to the ROUNDDOWN(%x,PGSIZE)\n",addr);
            if ((r= sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_P|PTE_U|PTE_W))) {/*seemly than PTE_USER is wrong*/
  800e1a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e21:	53                   	push   %ebx
  800e22:	6a 00                	push   $0x0
  800e24:	68 00 f0 7f 00       	push   $0x7ff000
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 62 fd ff ff       	call   800b92 <sys_page_map>
  800e30:	83 c4 20             	add    $0x20,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	74 0a                	je     800e41 <pgfault+0x91>
                panic("pgfault->sys_page_map:%e",r);
  800e37:	50                   	push   %eax
  800e38:	68 a2 17 80 00       	push   $0x8017a2
  800e3d:	6a 35                	push   $0x35
  800e3f:	eb 2a                	jmp    800e6b <pgfault+0xbb>
            }
            //cprintf("before unmap the PFTEMP\n");
            if ((r = sys_page_unmap(0,PFTEMP))) {
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	68 00 f0 7f 00       	push   $0x7ff000
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 94 fd ff ff       	call   800be4 <sys_page_unmap>
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	74 37                	je     800e8e <pgfault+0xde>
                panic("pgfault->sys_page_unmap:%e",r);
  800e57:	50                   	push   %eax
  800e58:	68 bb 17 80 00       	push   $0x8017bb
  800e5d:	6a 39                	push   $0x39
  800e5f:	eb 0a                	jmp    800e6b <pgfault+0xbb>
            }
            //cprintf("after unmap the PFTEMP\n");
        } else {
            panic("the fault write page is not copy on write\n");
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	68 3c 18 80 00       	push   $0x80183c
  800e69:	6a 3d                	push   $0x3d
  800e6b:	68 d6 17 80 00       	push   $0x8017d6
  800e70:	e8 bf 02 00 00       	call   801134 <_panic>
        }
    } else {
        panic("the fault page isn't fault write,%eip is %x,va is %x,errcode is %d",utf->utf_eip,addr,err);
  800e75:	83 ec 08             	sub    $0x8,%esp
  800e78:	50                   	push   %eax
  800e79:	53                   	push   %ebx
  800e7a:	ff 72 28             	pushl  0x28(%edx)
  800e7d:	68 68 18 80 00       	push   $0x801868
  800e82:	6a 40                	push   $0x40
  800e84:	68 d6 17 80 00       	push   $0x8017d6
  800e89:	e8 a6 02 00 00       	call   801134 <_panic>
    }
    //it should be ok
    //panic("pgfault not implemented");
}
  800e8e:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <duppage>:

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
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
    int r;
    void *addr;
    pte_t pte;
    pte = vpt[pn];//current env's page table entry
  800e9e:	8b 14 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%edx
    addr = (void *) (pn*PGSIZE);//virtual address
  800ea5:	89 c6                	mov    %eax,%esi
  800ea7:	c1 e6 0c             	shl    $0xc,%esi
    uint32_t perm = pte & PTE_USER;
  800eaa:	89 d3                	mov    %edx,%ebx
  800eac:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
    /*if((uint32_t)addr == USTACKTOP-PGSIZE) {
        cprintf("duppage user stack!!!!!!!!!!\n");
    }*/
    if ((pte & PTE_COW)|(pte & PTE_W)) {
  800eb2:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800eb8:	74 26                	je     800ee0 <duppage+0x4d>
        /*the page need copy on write*/
        perm |= PTE_COW;
  800eba:	80 cf 08             	or     $0x8,%bh
        perm &= ~PTE_W;
  800ebd:	83 e3 fd             	and    $0xfffffffd,%ebx
        if ((r = sys_page_map(0,addr,envid,addr,perm))) {
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	53                   	push   %ebx
  800ec4:	56                   	push   %esi
  800ec5:	51                   	push   %ecx
  800ec6:	56                   	push   %esi
  800ec7:	6a 00                	push   $0x0
  800ec9:	e8 c4 fc ff ff       	call   800b92 <sys_page_map>
  800ece:	83 c4 20             	add    $0x20,%esp
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	75 19                	jne    800ef0 <duppage+0x5d>
            return r;
        }
        return sys_page_map(0,addr,0,addr,perm);//also remap it
  800ed7:	83 ec 0c             	sub    $0xc,%esp
  800eda:	53                   	push   %ebx
  800edb:	56                   	push   %esi
  800edc:	6a 00                	push   $0x0
  800ede:	eb 06                	jmp    800ee6 <duppage+0x53>
        /*now the page can't be writen*/
    }
    // LAB 4: Your code here.
    //panic("duppage not implemented");
    //may be wrong, it's not writable so just map it,although it may be no safe
    return sys_page_map(0, addr, envid, addr, perm);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	53                   	push   %ebx
  800ee4:	56                   	push   %esi
  800ee5:	51                   	push   %ecx
  800ee6:	56                   	push   %esi
  800ee7:	6a 00                	push   $0x0
  800ee9:	e8 a4 fc ff ff       	call   800b92 <sys_page_map>
  800eee:	89 c2                	mov    %eax,%edx
}
  800ef0:	89 d0                	mov    %edx,%eax
  800ef2:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	c9                   	leave  
  800ef8:	c3                   	ret    

00800ef9 <fork>:

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
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 18             	sub    $0x18,%esp
    // LAB 4: Your code here.
    int pde_index;
    int pte_index;
    envid_t envid;
    unsigned pn = 0;
  800f02:	be 00 00 00 00       	mov    $0x0,%esi
    int r;
    set_pgfault_handler(pgfault);/*set the pgfault handler for the father*/
  800f07:	68 b0 0d 80 00       	push   $0x800db0
  800f0c:	e8 83 02 00 00       	call   801194 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
  800f11:	83 c4 10             	add    $0x10,%esp
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
  800f14:	ba 08 00 00 00       	mov    $0x8,%edx
  800f19:	89 d0                	mov    %edx,%eax
  800f1b:	cd 30                	int    $0x30
  800f1d:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
    //cprintf("in fork before sys_exofork\n");
    envid = sys_exofork();//it use int to syscall
    //the child will come back use iret
    //cprintf("after fork->sys_exofork return:%d\n",envid);
    if (envid < 0) {
  800f20:	89 c2                	mov    %eax,%edx
  800f22:	85 c0                	test   %eax,%eax
  800f24:	0f 88 f4 00 00 00    	js     80101e <fork+0x125>
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
  800f2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f2f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800f33:	75 21                	jne    800f56 <fork+0x5d>
  800f35:	e8 78 fb ff ff       	call   800ab2 <sys_getenvid>
  800f3a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f3f:	c1 e0 07             	shl    $0x7,%eax
  800f42:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f47:	a3 04 20 80 00       	mov    %eax,0x802004
  800f4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f51:	e9 c8 00 00 00       	jmp    80101e <fork+0x125>
        /*upper than utop,such map has already done*/
        if (vpd[pde_index]) {
  800f56:	8b 04 bd 00 d0 7b ef 	mov    0xef7bd000(,%edi,4),%eax
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	74 48                	je     800fa9 <fork+0xb0>
            for (pte_index = 0;pte_index < NPTENTRIES;pte_index++) {
  800f61:	bb 00 00 00 00       	mov    $0x0,%ebx
                if (vpt[pn]&& (pn*PGSIZE) != (UXSTACKTOP - PGSIZE)) {
  800f66:	8b 04 b5 00 00 40 ef 	mov    0xef400000(,%esi,4),%eax
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	74 2c                	je     800f9d <fork+0xa4>
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	c1 e0 0c             	shl    $0xc,%eax
  800f76:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  800f7b:	74 20                	je     800f9d <fork+0xa4>
                    /*if the pte is not null and it's not pgfault stack*/
                    if ((r = duppage(envid,pn)))
  800f7d:	83 ec 08             	sub    $0x8,%esp
  800f80:	56                   	push   %esi
  800f81:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800f84:	e8 0a ff ff ff       	call   800e93 <duppage>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	74 0d                	je     800f9d <fork+0xa4>
                        panic("in duppage:%e",r);
  800f90:	50                   	push   %eax
  800f91:	68 e1 17 80 00       	push   $0x8017e1
  800f96:	68 9e 00 00 00       	push   $0x9e
  800f9b:	eb 77                	jmp    801014 <fork+0x11b>
                }
                pn++;
  800f9d:	46                   	inc    %esi
  800f9e:	43                   	inc    %ebx
  800f9f:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  800fa5:	7e bf                	jle    800f66 <fork+0x6d>
  800fa7:	eb 06                	jmp    800faf <fork+0xb6>
            }
        } else {
            pn += NPTENTRIES;/*skip 1024 virtual page*/
  800fa9:	81 c6 00 04 00 00    	add    $0x400,%esi
  800faf:	47                   	inc    %edi
  800fb0:	81 ff ba 03 00 00    	cmp    $0x3ba,%edi
  800fb6:	76 9e                	jbe    800f56 <fork+0x5d>
        }
    }
    //cprintf("after parent map for child\n");
    /*set the pgfault handler for child*/
    //cprintf("after set the pgfault handler\n");
    if ((r = sys_page_alloc(envid,(void *)(UXSTACKTOP - PGSIZE),PTE_P|PTE_U|PTE_W))) {
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	6a 07                	push   $0x7
  800fbd:	68 00 f0 bf ee       	push   $0xeebff000
  800fc2:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800fc5:	e8 75 fb ff ff       	call   800b3f <sys_page_alloc>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	74 0d                	je     800fde <fork+0xe5>
        panic("in fork->sys_page_alloc %e",r);
  800fd1:	50                   	push   %eax
  800fd2:	68 ef 17 80 00       	push   $0x8017ef
  800fd7:	68 aa 00 00 00       	push   $0xaa
  800fdc:	eb 36                	jmp    801014 <fork+0x11b>
    }
    //cprintf("before set the pgfault up call for child\n");
    //cprintf("env->env_pgfault_upcall:%x\n",env->env_pgfault_upcall);
    sys_env_set_pgfault_upcall(envid,env->env_pgfault_upcall);
  800fde:	83 ec 08             	sub    $0x8,%esp
  800fe1:	a1 04 20 80 00       	mov    0x802004,%eax
  800fe6:	8b 40 68             	mov    0x68(%eax),%eax
  800fe9:	50                   	push   %eax
  800fea:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800fed:	e8 e8 fc ff ff       	call   800cda <sys_env_set_pgfault_upcall>
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE))) {
  800ff2:	83 c4 08             	add    $0x8,%esp
  800ff5:	6a 01                	push   $0x1
  800ff7:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800ffa:	e8 37 fc ff ff       	call   800c36 <sys_env_set_status>
  800fff:	83 c4 10             	add    $0x10,%esp
        panic("in fork->sys_env_status %e",r);
    }
    //cprintf("fork ok %d\n",sys_getenvid());
    return envid;
  801002:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801005:	85 c0                	test   %eax,%eax
  801007:	74 15                	je     80101e <fork+0x125>
  801009:	50                   	push   %eax
  80100a:	68 0a 18 80 00       	push   $0x80180a
  80100f:	68 b0 00 00 00       	push   $0xb0
  801014:	68 d6 17 80 00       	push   $0x8017d6
  801019:	e8 16 01 00 00       	call   801134 <_panic>
    //panic("fork not implemented");
}
  80101e:	89 d0                	mov    %edx,%eax
  801020:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  801023:	5b                   	pop    %ebx
  801024:	5e                   	pop    %esi
  801025:	5f                   	pop    %edi
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <sfork>:

// Challenge!
int
sfork(void)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 0c             	sub    $0xc,%esp
    panic("sfork not implemented");
  80102e:	68 25 18 80 00       	push   $0x801825
  801033:	68 bb 00 00 00       	push   $0xbb
  801038:	68 d6 17 80 00       	push   $0x8017d6
  80103d:	e8 f2 00 00 00       	call   801134 <_panic>
	...

00801044 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80104c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104f:	8b 75 10             	mov    0x10(%ebp),%esi
    // LAB 4: Your code here.
    //cprintf("env:%d is recieving\n",env->env_id);
    int r;
    if (!pg) {
  801052:	85 c0                	test   %eax,%eax
  801054:	75 05                	jne    80105b <ipc_recv+0x17>
        /*the reciever need an integer not a page*/
        pg = (void*)UTOP;
  801056:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
    }
    if ((r = sys_ipc_recv(pg))) {
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	50                   	push   %eax
  80105f:	e8 fb fc ff ff       	call   800d5f <sys_ipc_recv>
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	74 16                	je     801081 <ipc_recv+0x3d>
        if (from_env_store) {
  80106b:	85 db                	test   %ebx,%ebx
  80106d:	74 06                	je     801075 <ipc_recv+0x31>
            *from_env_store = 0;
  80106f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        }
        if (perm_store) {
  801075:	85 f6                	test   %esi,%esi
  801077:	74 48                	je     8010c1 <ipc_recv+0x7d>
            *perm_store = 0;
  801079:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        return r;
  80107f:	eb 40                	jmp    8010c1 <ipc_recv+0x7d>
    }
    if (from_env_store) {
  801081:	85 db                	test   %ebx,%ebx
  801083:	74 0a                	je     80108f <ipc_recv+0x4b>
        *from_env_store = env->env_ipc_from;
  801085:	a1 04 20 80 00       	mov    0x802004,%eax
  80108a:	8b 40 78             	mov    0x78(%eax),%eax
  80108d:	89 03                	mov    %eax,(%ebx)
    }
    if (perm_store) {
  80108f:	85 f6                	test   %esi,%esi
  801091:	74 0a                	je     80109d <ipc_recv+0x59>
        *perm_store = env->env_ipc_perm;
  801093:	a1 04 20 80 00       	mov    0x802004,%eax
  801098:	8b 40 7c             	mov    0x7c(%eax),%eax
  80109b:	89 06                	mov    %eax,(%esi)
    }
    cprintf("from env %d to env %d,recieve ok,value:%d\n",env->env_ipc_from,env->env_id,env->env_ipc_value);
  80109d:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8010a3:	8b 42 74             	mov    0x74(%edx),%eax
  8010a6:	50                   	push   %eax
  8010a7:	8b 42 4c             	mov    0x4c(%edx),%eax
  8010aa:	50                   	push   %eax
  8010ab:	8b 42 78             	mov    0x78(%edx),%eax
  8010ae:	50                   	push   %eax
  8010af:	68 ac 18 80 00       	push   $0x8018ac
  8010b4:	e8 ef f0 ff ff       	call   8001a8 <cprintf>
    return env->env_ipc_value;
  8010b9:	a1 04 20 80 00       	mov    0x802004,%eax
  8010be:	8b 40 74             	mov    0x74(%eax),%eax
    panic("ipc_recv not implemented");
    return 0;
}
  8010c1:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8010c4:	5b                   	pop    %ebx
  8010c5:	5e                   	pop    %esi
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <ipc_send>:

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
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	57                   	push   %edi
  8010cc:	56                   	push   %esi
  8010cd:	53                   	push   %ebx
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d7:	8b 75 14             	mov    0x14(%ebp),%esi
    // LAB 4: Your code here.
    int r;
    while (1) {
        if(!pg) {
  8010da:	85 db                	test   %ebx,%ebx
  8010dc:	75 05                	jne    8010e3 <ipc_send+0x1b>
            pg = (void*)UTOP;
  8010de:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
        }
        r = sys_ipc_try_send(to_env,val,pg,perm);
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	57                   	push   %edi
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	e8 3e fc ff ff       	call   800d2c <sys_ipc_try_send>
        if (r == 0 || r == 1) {
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	83 f8 01             	cmp    $0x1,%eax
  8010f4:	76 1e                	jbe    801114 <ipc_send+0x4c>
            break;
        } else if (r != -E_IPC_NOT_RECV) {
  8010f6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010f9:	74 12                	je     80110d <ipc_send+0x45>
            /*unknown err*/
            panic("ipc_send not ok: %e\n",r);
  8010fb:	50                   	push   %eax
  8010fc:	68 fb 18 80 00       	push   $0x8018fb
  801101:	6a 46                	push   $0x46
  801103:	68 10 19 80 00       	push   $0x801910
  801108:	e8 27 00 00 00       	call   801134 <_panic>
        }
        sys_yield();
  80110d:	e8 fe f9 ff ff       	call   800b10 <sys_yield>
  801112:	eb c6                	jmp    8010da <ipc_send+0x12>
    }
    cprintf("env %d to env %d send ok,value:%d\n",env->env_id,to_env,val);
  801114:	57                   	push   %edi
  801115:	ff 75 08             	pushl  0x8(%ebp)
  801118:	a1 04 20 80 00       	mov    0x802004,%eax
  80111d:	8b 40 4c             	mov    0x4c(%eax),%eax
  801120:	50                   	push   %eax
  801121:	68 d8 18 80 00       	push   $0x8018d8
  801126:	e8 7d f0 ff ff       	call   8001a8 <cprintf>
}
  80112b:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	c9                   	leave  
  801132:	c3                   	ret    
	...

00801134 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	53                   	push   %ebx
  801138:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  80113b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80113e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801145:	74 16                	je     80115d <_panic+0x29>
		cprintf("%s: ", argv0);
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	ff 35 08 20 80 00    	pushl  0x802008
  801150:	68 1a 19 80 00       	push   $0x80191a
  801155:	e8 4e f0 ff ff       	call   8001a8 <cprintf>
  80115a:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80115d:	ff 75 0c             	pushl  0xc(%ebp)
  801160:	ff 75 08             	pushl  0x8(%ebp)
  801163:	ff 35 00 20 80 00    	pushl  0x802000
  801169:	68 1f 19 80 00       	push   $0x80191f
  80116e:	e8 35 f0 ff ff       	call   8001a8 <cprintf>
	vcprintf(fmt, ap);
  801173:	83 c4 08             	add    $0x8,%esp
  801176:	53                   	push   %ebx
  801177:	ff 75 10             	pushl  0x10(%ebp)
  80117a:	e8 d8 ef ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  80117f:	c7 04 24 0e 19 80 00 	movl   $0x80190e,(%esp)
  801186:	e8 1d f0 ff ff       	call   8001a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
  80118b:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80118e:	cc                   	int3   
  80118f:	eb fd                	jmp    80118e <_panic+0x5a>
}
  801191:	00 00                	add    %al,(%eax)
	...

00801194 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == NULL) {
  80119a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8011a1:	75 2a                	jne    8011cd <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
        //cprintf("i'm in set pgfault_handler,before alloc\n");
        if(sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W)) {//maybe not PTE_USER
  8011a3:	83 ec 04             	sub    $0x4,%esp
  8011a6:	6a 07                	push   $0x7
  8011a8:	68 00 f0 bf ee       	push   $0xeebff000
  8011ad:	6a 00                	push   $0x0
  8011af:	e8 8b f9 ff ff       	call   800b3f <sys_page_alloc>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	75 1a                	jne    8011d5 <set_pgfault_handler+0x41>
            return;
        }
        //cprintf("i'm in set pgfault_handler,after alloc\n");
        sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	68 d8 11 80 00       	push   $0x8011d8
  8011c3:	6a 00                	push   $0x0
  8011c5:	e8 10 fb ff ff       	call   800cda <sys_env_set_pgfault_upcall>
  8011ca:	83 c4 10             	add    $0x10,%esp
        //cprintf("here in set pgfault handler\n");
		//panic("set_pgfault_handler not implemented");
	}
	// Save handler pointer for assembly to call.
    //cprintf("handler %x;pgfault_handler address %x,upcall address %x,upcall points %x\n",handler,&_pgfault_handler,&_pgfault_upcall,_pgfault_upcall);
	_pgfault_handler = handler;
  8011cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d0:	a3 0c 20 80 00       	mov    %eax,0x80200c
    //cprintf("here\n");
    //it should be ok
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    
	...

008011d8 <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011d9:	a1 0c 20 80 00       	mov    0x80200c,%eax
    //xchg %bx, %bx
	call *%eax
  8011de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011e0:	83 c4 04             	add    $0x4,%esp
	
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
  8011e3:	83 c4 08             	add    $0x8,%esp
/*    //it's wrong
    movl %esp,%eax//old esp is stored in the upper 40byte of the current esp
    addl $40,%eax //eax point to the old esp
    //xchg %bx, %bx
    movl %eax,%edx
    addl $4,%edx //then edx points to the retaddr
    movl %edx,(%eax)//set the esp in the stack to the 
*/   
    movl 32(%esp),%edx //edx is the old eip 
  8011e6:	8b 54 24 20          	mov    0x20(%esp),%edx
    movl 40(%esp),%eax //eax is the old esp
  8011ea:	8b 44 24 28          	mov    0x28(%esp),%eax
    subl $4, %eax // then eax point to the place where the return address will be store
  8011ee:	83 e8 04             	sub    $0x4,%eax
    movl %edx,(%eax)//the old eip is stored in the return address place.maybe this will cause recursive copyonwrite pagefault
  8011f1:	89 10                	mov    %edx,(%eax)
    movl %eax,40(%esp)//then the value of the esp place in the utf points to the old eip
  8011f3:	89 44 24 28          	mov    %eax,0x28(%esp)
    //because the register will be restored, so don't care the eax and edx
	// Restore the trap-time registers.
	// LAB 4: Your code here.
    popal
  8011f7:	61                   	popa   
	// Restore eflags from the stack.
	// LAB 4: Your code here.
    addl $4,%esp
  8011f8:	83 c4 04             	add    $0x4,%esp
    popfl
  8011fb:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    //xchg %bx,%bx
    popl %esp//then esp points to the retaddr
  8011fc:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    //xchg %bx, %bx
    ret
  8011fd:	c3                   	ret    
	...

00801200 <__udivdi3>:
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	83 ec 20             	sub    $0x20,%esp
  801208:	8b 55 14             	mov    0x14(%ebp),%edx
  80120b:	8b 75 08             	mov    0x8(%ebp),%esi
  80120e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801211:	8b 45 10             	mov    0x10(%ebp),%eax
  801214:	85 d2                	test   %edx,%edx
  801216:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  801219:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  801220:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  801227:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  80122a:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  80122d:	89 fe                	mov    %edi,%esi
  80122f:	75 5b                	jne    80128c <__udivdi3+0x8c>
  801231:	39 f8                	cmp    %edi,%eax
  801233:	76 2b                	jbe    801260 <__udivdi3+0x60>
  801235:	89 fa                	mov    %edi,%edx
  801237:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80123a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80123d:	89 c7                	mov    %eax,%edi
  80123f:	90                   	nop    
  801240:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  801247:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  80124a:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  80124d:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  801250:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801253:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801256:	83 c4 20             	add    $0x20,%esp
  801259:	5e                   	pop    %esi
  80125a:	5f                   	pop    %edi
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    
  80125d:	8d 76 00             	lea    0x0(%esi),%esi
  801260:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  801263:	85 c0                	test   %eax,%eax
  801265:	75 0e                	jne    801275 <__udivdi3+0x75>
  801267:	b8 01 00 00 00       	mov    $0x1,%eax
  80126c:	31 c9                	xor    %ecx,%ecx
  80126e:	31 d2                	xor    %edx,%edx
  801270:	f7 f1                	div    %ecx
  801272:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  801275:	89 f0                	mov    %esi,%eax
  801277:	31 d2                	xor    %edx,%edx
  801279:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80127c:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  80127f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  801282:	f7 75 dc             	divl   0xffffffdc(%ebp)
  801285:	89 c7                	mov    %eax,%edi
  801287:	eb be                	jmp    801247 <__udivdi3+0x47>
  801289:	8d 76 00             	lea    0x0(%esi),%esi
  80128c:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  80128f:	76 07                	jbe    801298 <__udivdi3+0x98>
  801291:	31 ff                	xor    %edi,%edi
  801293:	eb ab                	jmp    801240 <__udivdi3+0x40>
  801295:	8d 76 00             	lea    0x0(%esi),%esi
  801298:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  80129c:	89 c7                	mov    %eax,%edi
  80129e:	83 f7 1f             	xor    $0x1f,%edi
  8012a1:	75 19                	jne    8012bc <__udivdi3+0xbc>
  8012a3:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  8012a6:	77 0a                	ja     8012b2 <__udivdi3+0xb2>
  8012a8:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8012ab:	31 ff                	xor    %edi,%edi
  8012ad:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  8012b0:	72 8e                	jb     801240 <__udivdi3+0x40>
  8012b2:	bf 01 00 00 00       	mov    $0x1,%edi
  8012b7:	eb 87                	jmp    801240 <__udivdi3+0x40>
  8012b9:	8d 76 00             	lea    0x0(%esi),%esi
  8012bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8012c1:	29 f8                	sub    %edi,%eax
  8012c3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8012c6:	89 f9                	mov    %edi,%ecx
  8012c8:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  8012cb:	d3 e2                	shl    %cl,%edx
  8012cd:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  8012d0:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  8012d3:	d3 e8                	shr    %cl,%eax
  8012d5:	09 c2                	or     %eax,%edx
  8012d7:	89 f9                	mov    %edi,%ecx
  8012d9:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  8012dc:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  8012df:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	d3 ea                	shr    %cl,%edx
  8012e6:	89 f9                	mov    %edi,%ecx
  8012e8:	d3 e6                	shl    %cl,%esi
  8012ea:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8012ed:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  8012f0:	d3 e8                	shr    %cl,%eax
  8012f2:	09 c6                	or     %eax,%esi
  8012f4:	89 f9                	mov    %edi,%ecx
  8012f6:	89 f0                	mov    %esi,%eax
  8012f8:	f7 75 ec             	divl   0xffffffec(%ebp)
  8012fb:	89 d6                	mov    %edx,%esi
  8012fd:	89 c7                	mov    %eax,%edi
  8012ff:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  801302:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  801305:	f7 e7                	mul    %edi
  801307:	39 f2                	cmp    %esi,%edx
  801309:	77 0f                	ja     80131a <__udivdi3+0x11a>
  80130b:	0f 85 2f ff ff ff    	jne    801240 <__udivdi3+0x40>
  801311:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  801314:	0f 86 26 ff ff ff    	jbe    801240 <__udivdi3+0x40>
  80131a:	4f                   	dec    %edi
  80131b:	e9 20 ff ff ff       	jmp    801240 <__udivdi3+0x40>

00801320 <__umoddi3>:
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	57                   	push   %edi
  801324:	56                   	push   %esi
  801325:	83 ec 30             	sub    $0x30,%esp
  801328:	8b 55 14             	mov    0x14(%ebp),%edx
  80132b:	8b 75 08             	mov    0x8(%ebp),%esi
  80132e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801331:	8b 45 10             	mov    0x10(%ebp),%eax
  801334:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  801337:	85 d2                	test   %edx,%edx
  801339:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  801340:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  801347:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  80134a:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  80134d:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801350:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  801353:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801356:	75 68                	jne    8013c0 <__umoddi3+0xa0>
  801358:	39 f8                	cmp    %edi,%eax
  80135a:	76 3c                	jbe    801398 <__umoddi3+0x78>
  80135c:	89 f0                	mov    %esi,%eax
  80135e:	89 fa                	mov    %edi,%edx
  801360:	f7 75 cc             	divl   0xffffffcc(%ebp)
  801363:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  801366:	85 c9                	test   %ecx,%ecx
  801368:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  80136b:	74 1b                	je     801388 <__umoddi3+0x68>
  80136d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801370:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801373:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  80137a:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80137d:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  801380:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  801383:	89 10                	mov    %edx,(%eax)
  801385:	89 48 04             	mov    %ecx,0x4(%eax)
  801388:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80138b:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  80138e:	83 c4 30             	add    $0x30,%esp
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	c9                   	leave  
  801394:	c3                   	ret    
  801395:	8d 76 00             	lea    0x0(%esi),%esi
  801398:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  80139b:	85 f6                	test   %esi,%esi
  80139d:	75 0d                	jne    8013ac <__umoddi3+0x8c>
  80139f:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a4:	31 d2                	xor    %edx,%edx
  8013a6:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8013a9:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8013ac:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8013af:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8013b2:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8013b5:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8013b8:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8013bb:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8013be:	eb a3                	jmp    801363 <__umoddi3+0x43>
  8013c0:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8013c3:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  8013c6:	76 14                	jbe    8013dc <__umoddi3+0xbc>
  8013c8:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  8013cb:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  8013ce:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  8013d1:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  8013d4:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  8013d7:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8013da:	eb ac                	jmp    801388 <__umoddi3+0x68>
  8013dc:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  8013e0:	89 c6                	mov    %eax,%esi
  8013e2:	83 f6 1f             	xor    $0x1f,%esi
  8013e5:	75 4d                	jne    801434 <__umoddi3+0x114>
  8013e7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8013ea:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  8013ed:	77 08                	ja     8013f7 <__umoddi3+0xd7>
  8013ef:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  8013f2:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  8013f5:	72 12                	jb     801409 <__umoddi3+0xe9>
  8013f7:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8013fa:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8013fd:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  801400:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  801403:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801406:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801409:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  80140c:	85 d2                	test   %edx,%edx
  80140e:	0f 84 74 ff ff ff    	je     801388 <__umoddi3+0x68>
  801414:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801417:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80141a:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  80141d:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  801420:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  801423:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801426:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801429:	89 01                	mov    %eax,(%ecx)
  80142b:	89 51 04             	mov    %edx,0x4(%ecx)
  80142e:	e9 55 ff ff ff       	jmp    801388 <__umoddi3+0x68>
  801433:	90                   	nop    
  801434:	b8 20 00 00 00       	mov    $0x20,%eax
  801439:	29 f0                	sub    %esi,%eax
  80143b:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80143e:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801441:	89 f1                	mov    %esi,%ecx
  801443:	d3 e2                	shl    %cl,%edx
  801445:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  801448:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80144b:	d3 e8                	shr    %cl,%eax
  80144d:	09 c2                	or     %eax,%edx
  80144f:	89 f1                	mov    %esi,%ecx
  801451:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801454:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801457:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80145a:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80145d:	d3 ea                	shr    %cl,%edx
  80145f:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  801462:	89 f1                	mov    %esi,%ecx
  801464:	d3 e7                	shl    %cl,%edi
  801466:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801469:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80146c:	d3 e8                	shr    %cl,%eax
  80146e:	09 c7                	or     %eax,%edi
  801470:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801473:	89 f8                	mov    %edi,%eax
  801475:	89 f1                	mov    %esi,%ecx
  801477:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80147a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  80147d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801480:	f7 65 cc             	mull   0xffffffcc(%ebp)
  801483:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801486:	89 c7                	mov    %eax,%edi
  801488:	77 3f                	ja     8014c9 <__umoddi3+0x1a9>
  80148a:	74 38                	je     8014c4 <__umoddi3+0x1a4>
  80148c:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80148f:	85 c0                	test   %eax,%eax
  801491:	0f 84 f1 fe ff ff    	je     801388 <__umoddi3+0x68>
  801497:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  80149a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80149d:	29 f8                	sub    %edi,%eax
  80149f:	19 d1                	sbb    %edx,%ecx
  8014a1:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8014a4:	89 ca                	mov    %ecx,%edx
  8014a6:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8014a9:	d3 e2                	shl    %cl,%edx
  8014ab:	89 f1                	mov    %esi,%ecx
  8014ad:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8014b0:	d3 e8                	shr    %cl,%eax
  8014b2:	09 c2                	or     %eax,%edx
  8014b4:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8014b7:	d3 e8                	shr    %cl,%eax
  8014b9:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8014bc:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8014bf:	e9 b6 fe ff ff       	jmp    80137a <__umoddi3+0x5a>
  8014c4:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  8014c7:	76 c3                	jbe    80148c <__umoddi3+0x16c>
  8014c9:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  8014cc:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  8014cf:	eb bb                	jmp    80148c <__umoddi3+0x16c>
  8014d1:	90                   	nop    
  8014d2:	90                   	nop    
  8014d3:	90                   	nop    
