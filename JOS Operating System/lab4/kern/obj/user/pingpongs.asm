
obj/user/pingpongs：     文件格式 elf32-i386

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
  80002c:	e8 cf 00 00 00       	call   800100 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
uint32_t val;

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003a:	e8 25 10 00 00       	call   801064 <sfork>
  80003f:	89 45 fc             	mov    %eax,0xfffffffc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	74 4c                	je     800092 <umain+0x5e>
		cprintf("i am %08x; env is %p\n", sys_getenvid(), env);
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	ff 35 08 20 80 00    	pushl  0x802008
  80004f:	83 ec 08             	sub    $0x8,%esp
  800052:	e8 97 0a 00 00       	call   800aee <sys_getenvid>
  800057:	83 c4 08             	add    $0x8,%esp
  80005a:	50                   	push   %eax
  80005b:	68 20 15 80 00       	push   $0x801520
  800060:	e8 7f 01 00 00       	call   8001e4 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800065:	83 c4 0c             	add    $0xc,%esp
  800068:	ff 75 fc             	pushl  0xfffffffc(%ebp)
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	e8 7b 0a 00 00       	call   800aee <sys_getenvid>
  800073:	83 c4 08             	add    $0x8,%esp
  800076:	50                   	push   %eax
  800077:	68 36 15 80 00       	push   $0x801536
  80007c:	e8 63 01 00 00       	call   8001e4 <cprintf>
		ipc_send(who, 0, 0, 0);
  800081:	6a 00                	push   $0x0
  800083:	6a 00                	push   $0x0
  800085:	6a 00                	push   $0x0
  800087:	ff 75 fc             	pushl  0xfffffffc(%ebp)
  80008a:	e8 75 10 00 00       	call   801104 <ipc_send>
  80008f:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	6a 00                	push   $0x0
  800097:	6a 00                	push   $0x0
  800099:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
  80009c:	50                   	push   %eax
  80009d:	e8 de 0f 00 00       	call   801080 <ipc_recv>
		cprintf("%x got %d from %x (env is %p %x)\n", sys_getenvid(), val, who, env, env->env_id);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	8b 15 08 20 80 00    	mov    0x802008,%edx
  8000ab:	8b 42 4c             	mov    0x4c(%edx),%eax
  8000ae:	50                   	push   %eax
  8000af:	52                   	push   %edx
  8000b0:	ff 75 fc             	pushl  0xfffffffc(%ebp)
  8000b3:	ff 35 04 20 80 00    	pushl  0x802004
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	e8 2d 0a 00 00       	call   800aee <sys_getenvid>
  8000c1:	83 c4 08             	add    $0x8,%esp
  8000c4:	50                   	push   %eax
  8000c5:	68 4c 15 80 00       	push   $0x80154c
  8000ca:	e8 15 01 00 00       	call   8001e4 <cprintf>
		if (val == 10)
  8000cf:	83 c4 20             	add    $0x20,%esp
  8000d2:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000d9:	74 20                	je     8000fb <umain+0xc7>
			return;
		++val;
  8000db:	ff 05 04 20 80 00    	incl   0x802004
		ipc_send(who, 0, 0, 0);
  8000e1:	6a 00                	push   $0x0
  8000e3:	6a 00                	push   $0x0
  8000e5:	6a 00                	push   $0x0
  8000e7:	ff 75 fc             	pushl  0xfffffffc(%ebp)
  8000ea:	e8 15 10 00 00       	call   801104 <ipc_send>
		if (val == 10)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f9:	75 97                	jne    800092 <umain+0x5e>
			return;
	}
		
}
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
  8000fd:	00 00                	add    %al,(%eax)
	...

00800100 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	8b 75 08             	mov    0x8(%ebp),%esi
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  80010b:	e8 de 09 00 00       	call   800aee <sys_getenvid>
  800110:	25 ff 03 00 00       	and    $0x3ff,%eax
  800115:	c1 e0 07             	shl    $0x7,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 08 20 80 00       	mov    %eax,0x802008
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800122:	85 f6                	test   %esi,%esi
  800124:	7e 07                	jle    80012d <libmain+0x2d>
		binaryname = argv[0];
  800126:	8b 03                	mov    (%ebx),%eax
  800128:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	53                   	push   %ebx
  800131:	56                   	push   %esi
  800132:	e8 fd fe ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  800137:	e8 08 00 00 00       	call   800144 <exit>
}
  80013c:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	c9                   	leave  
  800142:	c3                   	ret    
	...

00800144 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 4c 09 00 00       	call   800a9d <sys_env_destroy>
}
  800151:	c9                   	leave  
  800152:	c3                   	ret    
	...

00800154 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	53                   	push   %ebx
  800158:	83 ec 04             	sub    $0x4,%esp
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015e:	8b 03                	mov    (%ebx),%eax
  800160:	8b 55 08             	mov    0x8(%ebp),%edx
  800163:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800167:	40                   	inc    %eax
  800168:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80016a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016f:	75 1a                	jne    80018b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800171:	83 ec 08             	sub    $0x8,%esp
  800174:	68 ff 00 00 00       	push   $0xff
  800179:	8d 43 08             	lea    0x8(%ebx),%eax
  80017c:	50                   	push   %eax
  80017d:	e8 be 08 00 00       	call   800a40 <sys_cputs>
		b->idx = 0;
  800182:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800188:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018b:	ff 43 04             	incl   0x4(%ebx)
}
  80018e:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80019c:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8001a3:	00 00 00 
	b.cnt = 0;
  8001a6:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8001ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b0:	ff 75 0c             	pushl  0xc(%ebp)
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  8001bc:	50                   	push   %eax
  8001bd:	68 54 01 80 00       	push   $0x800154
  8001c2:	e8 83 01 00 00       	call   80034a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c7:	83 c4 08             	add    $0x8,%esp
  8001ca:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  8001d0:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  8001d6:	50                   	push   %eax
  8001d7:	e8 64 08 00 00       	call   800a40 <sys_cputs>

	return b.cnt;
  8001dc:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ed:	50                   	push   %eax
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	e8 9d ff ff ff       	call   800193 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	57                   	push   %edi
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	8b 75 10             	mov    0x10(%ebp),%esi
  800204:	8b 7d 14             	mov    0x14(%ebp),%edi
  800207:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020a:	8b 45 18             	mov    0x18(%ebp),%eax
  80020d:	ba 00 00 00 00       	mov    $0x0,%edx
  800212:	39 d7                	cmp    %edx,%edi
  800214:	72 39                	jb     80024f <printnum+0x57>
  800216:	77 04                	ja     80021c <printnum+0x24>
  800218:	39 c6                	cmp    %eax,%esi
  80021a:	72 33                	jb     80024f <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	ff 75 20             	pushl  0x20(%ebp)
  800222:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800225:	50                   	push   %eax
  800226:	ff 75 18             	pushl  0x18(%ebp)
  800229:	8b 45 18             	mov    0x18(%ebp),%eax
  80022c:	ba 00 00 00 00       	mov    $0x0,%edx
  800231:	52                   	push   %edx
  800232:	50                   	push   %eax
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	e8 02 10 00 00       	call   80123c <__udivdi3>
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	52                   	push   %edx
  80023e:	50                   	push   %eax
  80023f:	ff 75 0c             	pushl  0xc(%ebp)
  800242:	ff 75 08             	pushl  0x8(%ebp)
  800245:	e8 ae ff ff ff       	call   8001f8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 19                	jmp    800268 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024f:	4b                   	dec    %ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7e 14                	jle    800268 <printnum+0x70>
			putch(padc, putdat);
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	ff 75 20             	pushl  0x20(%ebp)
  80025d:	ff 55 08             	call   *0x8(%ebp)
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	4b                   	dec    %ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7f ec                	jg     800254 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	8b 45 18             	mov    0x18(%ebp),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	83 ec 04             	sub    $0x4,%esp
  800279:	52                   	push   %edx
  80027a:	50                   	push   %eax
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	e8 da 10 00 00       	call   80135c <__umoddi3>
  800282:	83 c4 14             	add    $0x14,%esp
  800285:	0f be 80 18 16 80 00 	movsbl 0x801618(%eax),%eax
  80028c:	50                   	push   %eax
  80028d:	ff 55 08             	call   *0x8(%ebp)
}
  800290:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 18             	sub    $0x18,%esp
  8002a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a6:	8a 45 18             	mov    0x18(%ebp),%al
  8002a9:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  8002ac:	53                   	push   %ebx
  8002ad:	6a 1b                	push   $0x1b
  8002af:	ff d6                	call   *%esi
	putch('[', putdat);
  8002b1:	83 c4 08             	add    $0x8,%esp
  8002b4:	53                   	push   %ebx
  8002b5:	6a 5b                	push   $0x5b
  8002b7:	ff d6                	call   *%esi
	putch('0', putdat);
  8002b9:	83 c4 08             	add    $0x8,%esp
  8002bc:	53                   	push   %ebx
  8002bd:	6a 30                	push   $0x30
  8002bf:	ff d6                	call   *%esi
	putch(';', putdat);
  8002c1:	83 c4 08             	add    $0x8,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	6a 3b                	push   $0x3b
  8002c7:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  8002c9:	83 c4 0c             	add    $0xc,%esp
  8002cc:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  8002d0:	50                   	push   %eax
  8002d1:	ff 75 14             	pushl  0x14(%ebp)
  8002d4:	6a 0a                	push   $0xa
  8002d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d9:	99                   	cltd   
  8002da:	52                   	push   %edx
  8002db:	50                   	push   %eax
  8002dc:	53                   	push   %ebx
  8002dd:	56                   	push   %esi
  8002de:	e8 15 ff ff ff       	call   8001f8 <printnum>
	putch('m', putdat);
  8002e3:	83 c4 18             	add    $0x18,%esp
  8002e6:	53                   	push   %ebx
  8002e7:	6a 6d                	push   $0x6d
  8002e9:	ff d6                	call   *%esi

}
  8002eb:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002fb:	83 f8 01             	cmp    $0x1,%eax
  8002fe:	7e 0f                	jle    80030f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800300:	8b 01                	mov    (%ecx),%eax
  800302:	83 c0 08             	add    $0x8,%eax
  800305:	89 01                	mov    %eax,(%ecx)
  800307:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80030a:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80030d:	eb 0f                	jmp    80031e <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80030f:	8b 01                	mov    (%ecx),%eax
  800311:	83 c0 04             	add    $0x4,%eax
  800314:	89 01                	mov    %eax,(%ecx)
  800316:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800329:	83 f8 01             	cmp    $0x1,%eax
  80032c:	7e 0f                	jle    80033d <getint+0x1d>
		return va_arg(*ap, long long);
  80032e:	8b 02                	mov    (%edx),%eax
  800330:	83 c0 08             	add    $0x8,%eax
  800333:	89 02                	mov    %eax,(%edx)
  800335:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800338:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80033b:	eb 0b                	jmp    800348 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	83 c0 04             	add    $0x4,%eax
  800342:	89 02                	mov    %eax,(%edx)
  800344:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800347:	99                   	cltd   
}
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	57                   	push   %edi
  80034e:	56                   	push   %esi
  80034f:	53                   	push   %ebx
  800350:	83 ec 1c             	sub    $0x1c,%esp
  800353:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800356:	0f b6 13             	movzbl (%ebx),%edx
  800359:	43                   	inc    %ebx
  80035a:	83 fa 25             	cmp    $0x25,%edx
  80035d:	74 1e                	je     80037d <vprintfmt+0x33>
			if (ch == '\0')
  80035f:	85 d2                	test   %edx,%edx
  800361:	0f 84 dc 02 00 00    	je     800643 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	ff 75 0c             	pushl  0xc(%ebp)
  80036d:	52                   	push   %edx
  80036e:	ff 55 08             	call   *0x8(%ebp)
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	0f b6 13             	movzbl (%ebx),%edx
  800377:	43                   	inc    %ebx
  800378:	83 fa 25             	cmp    $0x25,%edx
  80037b:	75 e2                	jne    80035f <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80037d:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  800381:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  800388:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80038d:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  800392:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  800399:	0f b6 13             	movzbl (%ebx),%edx
  80039c:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  80039f:	43                   	inc    %ebx
  8003a0:	83 f8 55             	cmp    $0x55,%eax
  8003a3:	0f 87 75 02 00 00    	ja     80061e <vprintfmt+0x2d4>
  8003a9:	ff 24 85 64 16 80 00 	jmp    *0x801664(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b0:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  8003b4:	eb e3                	jmp    800399 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b6:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  8003ba:	eb dd                	jmp    800399 <vprintfmt+0x4f>

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
  8003bc:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8003c1:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8003c4:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  8003c8:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8003cb:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8003ce:	83 f8 09             	cmp    $0x9,%eax
  8003d1:	77 27                	ja     8003fa <vprintfmt+0xb0>
  8003d3:	43                   	inc    %ebx
  8003d4:	eb eb                	jmp    8003c1 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  8003e0:	eb 18                	jmp    8003fa <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  8003e2:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003e6:	79 b1                	jns    800399 <vprintfmt+0x4f>
				width = 0;
  8003e8:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  8003ef:	eb a8                	jmp    800399 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8003f1:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  8003f8:	eb 9f                	jmp    800399 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  8003fa:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003fe:	79 99                	jns    800399 <vprintfmt+0x4f>
				width = precision, precision = -1;
  800400:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800403:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800408:	eb 8f                	jmp    800399 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040a:	41                   	inc    %ecx
			goto reswitch;
  80040b:	eb 8c                	jmp    800399 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	ff 75 0c             	pushl  0xc(%ebp)
  800413:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80041d:	e9 c4 01 00 00       	jmp    8005e6 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80042c:	85 c0                	test   %eax,%eax
  80042e:	79 02                	jns    800432 <vprintfmt+0xe8>
				err = -err;
  800430:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800432:	83 f8 08             	cmp    $0x8,%eax
  800435:	7f 0b                	jg     800442 <vprintfmt+0xf8>
  800437:	8b 3c 85 40 16 80 00 	mov    0x801640(,%eax,4),%edi
  80043e:	85 ff                	test   %edi,%edi
  800440:	75 08                	jne    80044a <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  800442:	50                   	push   %eax
  800443:	68 29 16 80 00       	push   $0x801629
  800448:	eb 06                	jmp    800450 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  80044a:	57                   	push   %edi
  80044b:	68 32 16 80 00       	push   $0x801632
  800450:	ff 75 0c             	pushl  0xc(%ebp)
  800453:	ff 75 08             	pushl  0x8(%ebp)
  800456:	e8 f0 01 00 00       	call   80064b <printfmt>
  80045b:	e9 89 01 00 00       	jmp    8005e9 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800460:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  80046a:	85 ff                	test   %edi,%edi
  80046c:	75 05                	jne    800473 <vprintfmt+0x129>
				p = "(null)";
  80046e:	bf 35 16 80 00       	mov    $0x801635,%edi
			if (width > 0 && padc != '-')
  800473:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800477:	7e 3b                	jle    8004b4 <vprintfmt+0x16a>
  800479:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  80047d:	74 35                	je     8004b4 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	56                   	push   %esi
  800483:	57                   	push   %edi
  800484:	e8 74 02 00 00       	call   8006fd <strnlen>
  800489:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800493:	7e 1f                	jle    8004b4 <vprintfmt+0x16a>
  800495:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800499:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004ae:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004b2:	7f e8                	jg     80049c <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b4:	0f be 17             	movsbl (%edi),%edx
  8004b7:	47                   	inc    %edi
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	74 3e                	je     8004fa <vprintfmt+0x1b0>
  8004bc:	85 f6                	test   %esi,%esi
  8004be:	78 03                	js     8004c3 <vprintfmt+0x179>
  8004c0:	4e                   	dec    %esi
  8004c1:	78 37                	js     8004fa <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c3:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8004c7:	74 12                	je     8004db <vprintfmt+0x191>
  8004c9:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 0a                	jbe    8004db <vprintfmt+0x191>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 0c             	pushl  0xc(%ebp)
  8004d7:	6a 3f                	push   $0x3f
  8004d9:	eb 07                	jmp    8004e2 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	52                   	push   %edx
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004eb:	0f be 17             	movsbl (%edi),%edx
  8004ee:	47                   	inc    %edi
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 07                	je     8004fa <vprintfmt+0x1b0>
  8004f3:	85 f6                	test   %esi,%esi
  8004f5:	78 cc                	js     8004c3 <vprintfmt+0x179>
  8004f7:	4e                   	dec    %esi
  8004f8:	79 c9                	jns    8004c3 <vprintfmt+0x179>
			for (; width > 0; width--)
  8004fa:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004fe:	0f 8e 52 fe ff ff    	jle    800356 <vprintfmt+0xc>
				putch(' ', putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	ff 75 0c             	pushl  0xc(%ebp)
  80050a:	6a 20                	push   $0x20
  80050c:	ff 55 08             	call   *0x8(%ebp)
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800515:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800519:	7f e9                	jg     800504 <vprintfmt+0x1ba>
			break;
  80051b:	e9 36 fe ff ff       	jmp    800356 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	51                   	push   %ecx
  800524:	8d 45 14             	lea    0x14(%ebp),%eax
  800527:	50                   	push   %eax
  800528:	e8 f3 fd ff ff       	call   800320 <getint>
  80052d:	89 c6                	mov    %eax,%esi
  80052f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	85 d2                	test   %edx,%edx
  800536:	79 15                	jns    80054d <vprintfmt+0x203>
				putch('-', putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	6a 2d                	push   $0x2d
  800540:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800543:	f7 de                	neg    %esi
  800545:	83 d7 00             	adc    $0x0,%edi
  800548:	f7 df                	neg    %edi
  80054a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80054d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800552:	eb 70                	jmp    8005c4 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	51                   	push   %ecx
  800558:	8d 45 14             	lea    0x14(%ebp),%eax
  80055b:	50                   	push   %eax
  80055c:	e8 91 fd ff ff       	call   8002f2 <getuint>
  800561:	89 c6                	mov    %eax,%esi
  800563:	89 d7                	mov    %edx,%edi
			base = 10;
  800565:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80056a:	eb 55                	jmp    8005c1 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	51                   	push   %ecx
  800570:	8d 45 14             	lea    0x14(%ebp),%eax
  800573:	50                   	push   %eax
  800574:	e8 79 fd ff ff       	call   8002f2 <getuint>
  800579:	89 c6                	mov    %eax,%esi
  80057b:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  80057d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800582:	eb 3d                	jmp    8005c1 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	ff 75 0c             	pushl  0xc(%ebp)
  80058a:	6a 30                	push   $0x30
  80058c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80058f:	83 c4 08             	add    $0x8,%esp
  800592:	ff 75 0c             	pushl  0xc(%ebp)
  800595:	6a 78                	push   $0x78
  800597:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80059a:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8005a4:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  8005a9:	eb 11                	jmp    8005bc <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	51                   	push   %ecx
  8005af:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b2:	50                   	push   %eax
  8005b3:	e8 3a fd ff ff       	call   8002f2 <getuint>
  8005b8:	89 c6                	mov    %eax,%esi
  8005ba:	89 d7                	mov    %edx,%edi
			base = 16;
  8005bc:	ba 10 00 00 00       	mov    $0x10,%edx
  8005c1:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  8005c4:	83 ec 04             	sub    $0x4,%esp
  8005c7:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8005cb:	50                   	push   %eax
  8005cc:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8005cf:	52                   	push   %edx
  8005d0:	57                   	push   %edi
  8005d1:	56                   	push   %esi
  8005d2:	ff 75 0c             	pushl  0xc(%ebp)
  8005d5:	ff 75 08             	pushl  0x8(%ebp)
  8005d8:	e8 1b fc ff ff       	call   8001f8 <printnum>
			break;
  8005dd:	eb 37                	jmp    800616 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	ff 75 0c             	pushl  0xc(%ebp)
  8005e5:	52                   	push   %edx
  8005e6:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005e9:	83 c4 10             	add    $0x10,%esp
  8005ec:	e9 65 fd ff ff       	jmp    800356 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	51                   	push   %ecx
  8005f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f8:	50                   	push   %eax
  8005f9:	e8 f4 fc ff ff       	call   8002f2 <getuint>
  8005fe:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800600:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80060a:	56                   	push   %esi
  80060b:	ff 75 0c             	pushl  0xc(%ebp)
  80060e:	ff 75 08             	pushl  0x8(%ebp)
  800611:	e8 82 fc ff ff       	call   800298 <printcolor>
			break;
  800616:	83 c4 20             	add    $0x20,%esp
  800619:	e9 38 fd ff ff       	jmp    800356 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	ff 75 0c             	pushl  0xc(%ebp)
  800624:	6a 25                	push   $0x25
  800626:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800629:	4b                   	dec    %ebx
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800631:	0f 84 1f fd ff ff    	je     800356 <vprintfmt+0xc>
  800637:	4b                   	dec    %ebx
  800638:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80063c:	75 f9                	jne    800637 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80063e:	e9 13 fd ff ff       	jmp    800356 <vprintfmt+0xc>
		}
	}
}
  800643:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800646:	5b                   	pop    %ebx
  800647:	5e                   	pop    %esi
  800648:	5f                   	pop    %edi
  800649:	c9                   	leave  
  80064a:	c3                   	ret    

0080064b <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800654:	50                   	push   %eax
  800655:	ff 75 10             	pushl  0x10(%ebp)
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	ff 75 08             	pushl  0x8(%ebp)
  80065e:	e8 e7 fc ff ff       	call   80034a <vprintfmt>
	va_end(ap);
}
  800663:	c9                   	leave  
  800664:	c3                   	ret    

00800665 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80066b:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80066e:	8b 0a                	mov    (%edx),%ecx
  800670:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800673:	73 07                	jae    80067c <sprintputch+0x17>
		*b->buf++ = ch;
  800675:	8b 45 08             	mov    0x8(%ebp),%eax
  800678:	88 01                	mov    %al,(%ecx)
  80067a:	ff 02                	incl   (%edx)
}
  80067c:	c9                   	leave  
  80067d:	c3                   	ret    

0080067e <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 18             	sub    $0x18,%esp
  800684:	8b 55 08             	mov    0x8(%ebp),%edx
  800687:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  80068a:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  80068d:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800691:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800694:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  80069b:	85 d2                	test   %edx,%edx
  80069d:	74 04                	je     8006a3 <vsnprintf+0x25>
  80069f:	85 c9                	test   %ecx,%ecx
  8006a1:	7f 07                	jg     8006aa <vsnprintf+0x2c>
		return -E_INVAL;
  8006a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a8:	eb 1d                	jmp    8006c7 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  8006aa:	ff 75 14             	pushl  0x14(%ebp)
  8006ad:	ff 75 10             	pushl  0x10(%ebp)
  8006b0:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8006b3:	50                   	push   %eax
  8006b4:	68 65 06 80 00       	push   $0x800665
  8006b9:	e8 8c fc ff ff       	call   80034a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006be:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8006c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d2:	50                   	push   %eax
  8006d3:	ff 75 10             	pushl  0x10(%ebp)
  8006d6:	ff 75 0c             	pushl  0xc(%ebp)
  8006d9:	ff 75 08             	pushl  0x8(%ebp)
  8006dc:	e8 9d ff ff ff       	call   80067e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    
	...

008006e4 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ef:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f2:	74 07                	je     8006fb <strlen+0x17>
		n++;
  8006f4:	40                   	inc    %eax
  8006f5:	42                   	inc    %edx
  8006f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f9:	75 f9                	jne    8006f4 <strlen+0x10>
	return n;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800703:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	85 d2                	test   %edx,%edx
  80070d:	74 0f                	je     80071e <strnlen+0x21>
  80070f:	80 39 00             	cmpb   $0x0,(%ecx)
  800712:	74 0a                	je     80071e <strnlen+0x21>
		n++;
  800714:	40                   	inc    %eax
  800715:	41                   	inc    %ecx
  800716:	4a                   	dec    %edx
  800717:	74 05                	je     80071e <strnlen+0x21>
  800719:	80 39 00             	cmpb   $0x0,(%ecx)
  80071c:	75 f6                	jne    800714 <strnlen+0x17>
	return n;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800727:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80072a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80072c:	8a 02                	mov    (%edx),%al
  80072e:	42                   	inc    %edx
  80072f:	88 01                	mov    %al,(%ecx)
  800731:	41                   	inc    %ecx
  800732:	84 c0                	test   %al,%al
  800734:	75 f6                	jne    80072c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800736:	89 d8                	mov    %ebx,%eax
  800738:	5b                   	pop    %ebx
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	57                   	push   %edi
  80073f:	56                   	push   %esi
  800740:	53                   	push   %ebx
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
  800747:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80074a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80074c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800751:	39 f3                	cmp    %esi,%ebx
  800753:	73 10                	jae    800765 <strncpy+0x2a>
		*dst++ = *src;
  800755:	8a 02                	mov    (%edx),%al
  800757:	88 01                	mov    %al,(%ecx)
  800759:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80075a:	80 3a 00             	cmpb   $0x0,(%edx)
  80075d:	74 01                	je     800760 <strncpy+0x25>
			src++;
  80075f:	42                   	inc    %edx
  800760:	43                   	inc    %ebx
  800761:	39 f3                	cmp    %esi,%ebx
  800763:	72 f0                	jb     800755 <strncpy+0x1a>
	}
	return ret;
}
  800765:	89 f8                	mov    %edi,%eax
  800767:	5b                   	pop    %ebx
  800768:	5e                   	pop    %esi
  800769:	5f                   	pop    %edi
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
  800771:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800777:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80077a:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80077c:	85 d2                	test   %edx,%edx
  80077e:	74 19                	je     800799 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800780:	4a                   	dec    %edx
  800781:	74 13                	je     800796 <strlcpy+0x2a>
  800783:	80 39 00             	cmpb   $0x0,(%ecx)
  800786:	74 0e                	je     800796 <strlcpy+0x2a>
			*dst++ = *src++;
  800788:	8a 01                	mov    (%ecx),%al
  80078a:	41                   	inc    %ecx
  80078b:	88 03                	mov    %al,(%ebx)
  80078d:	43                   	inc    %ebx
  80078e:	4a                   	dec    %edx
  80078f:	74 05                	je     800796 <strlcpy+0x2a>
  800791:	80 39 00             	cmpb   $0x0,(%ecx)
  800794:	75 f2                	jne    800788 <strlcpy+0x1c>
		*dst = '\0';
  800796:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800799:	89 d8                	mov    %ebx,%eax
  80079b:	29 f0                	sub    %esi,%eax
}
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8007aa:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ad:	74 13                	je     8007c2 <strcmp+0x21>
  8007af:	8a 02                	mov    (%edx),%al
  8007b1:	3a 01                	cmp    (%ecx),%al
  8007b3:	75 0d                	jne    8007c2 <strcmp+0x21>
		p++, q++;
  8007b5:	42                   	inc    %edx
  8007b6:	41                   	inc    %ecx
  8007b7:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ba:	74 06                	je     8007c2 <strcmp+0x21>
  8007bc:	8a 02                	mov    (%edx),%al
  8007be:	3a 01                	cmp    (%ecx),%al
  8007c0:	74 f3                	je     8007b5 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c2:	0f b6 02             	movzbl (%edx),%eax
  8007c5:	0f b6 11             	movzbl (%ecx),%edx
  8007c8:	29 d0                	sub    %edx,%eax
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  8007d9:	85 c9                	test   %ecx,%ecx
  8007db:	74 1f                	je     8007fc <strncmp+0x30>
  8007dd:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e0:	74 16                	je     8007f8 <strncmp+0x2c>
  8007e2:	8a 02                	mov    (%edx),%al
  8007e4:	3a 03                	cmp    (%ebx),%al
  8007e6:	75 10                	jne    8007f8 <strncmp+0x2c>
		n--, p++, q++;
  8007e8:	42                   	inc    %edx
  8007e9:	43                   	inc    %ebx
  8007ea:	49                   	dec    %ecx
  8007eb:	74 0f                	je     8007fc <strncmp+0x30>
  8007ed:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f0:	74 06                	je     8007f8 <strncmp+0x2c>
  8007f2:	8a 02                	mov    (%edx),%al
  8007f4:	3a 03                	cmp    (%ebx),%al
  8007f6:	74 f0                	je     8007e8 <strncmp+0x1c>
	if (n == 0)
  8007f8:	85 c9                	test   %ecx,%ecx
  8007fa:	75 07                	jne    800803 <strncmp+0x37>
		return 0;
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	eb 0a                	jmp    80080d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800803:	0f b6 12             	movzbl (%edx),%edx
  800806:	0f b6 03             	movzbl (%ebx),%eax
  800809:	29 c2                	sub    %eax,%edx
  80080b:	89 d0                	mov    %edx,%eax
}
  80080d:	8b 1c 24             	mov    (%esp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80081b:	80 38 00             	cmpb   $0x0,(%eax)
  80081e:	74 0a                	je     80082a <strchr+0x18>
		if (*s == c)
  800820:	38 10                	cmp    %dl,(%eax)
  800822:	74 0b                	je     80082f <strchr+0x1d>
  800824:	40                   	inc    %eax
  800825:	80 38 00             	cmpb   $0x0,(%eax)
  800828:	75 f6                	jne    800820 <strchr+0xe>
			return (char *) s;
	return 0;
  80082a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80083a:	80 38 00             	cmpb   $0x0,(%eax)
  80083d:	74 0a                	je     800849 <strfind+0x18>
		if (*s == c)
  80083f:	38 10                	cmp    %dl,(%eax)
  800841:	74 06                	je     800849 <strfind+0x18>
  800843:	40                   	inc    %eax
  800844:	80 38 00             	cmpb   $0x0,(%eax)
  800847:	75 f6                	jne    80083f <strfind+0xe>
			break;
	return (char *) s;
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	57                   	push   %edi
  80084f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800852:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800855:	89 f8                	mov    %edi,%eax
  800857:	85 c9                	test   %ecx,%ecx
  800859:	74 40                	je     80089b <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800861:	75 30                	jne    800893 <memset+0x48>
  800863:	f6 c1 03             	test   $0x3,%cl
  800866:	75 2b                	jne    800893 <memset+0x48>
		c &= 0xFF;
  800868:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	c1 e0 18             	shl    $0x18,%eax
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
  800878:	c1 e2 10             	shl    $0x10,%edx
  80087b:	09 d0                	or     %edx,%eax
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800880:	c1 e2 08             	shl    $0x8,%edx
  800883:	09 d0                	or     %edx,%eax
  800885:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800888:	c1 e9 02             	shr    $0x2,%ecx
  80088b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088e:	fc                   	cld    
  80088f:	f3 ab                	repz stos %eax,%es:(%edi)
  800891:	eb 06                	jmp    800899 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
  800896:	fc                   	cld    
  800897:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800899:	89 f8                	mov    %edi,%eax
}
  80089b:	8b 3c 24             	mov    (%esp),%edi
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	57                   	push   %edi
  8008a4:	56                   	push   %esi
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008ae:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008b0:	39 c6                	cmp    %eax,%esi
  8008b2:	73 33                	jae    8008e7 <memmove+0x47>
  8008b4:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  8008b7:	39 c2                	cmp    %eax,%edx
  8008b9:	76 2c                	jbe    8008e7 <memmove+0x47>
		s += n;
  8008bb:	89 d6                	mov    %edx,%esi
		d += n;
  8008bd:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c0:	f6 c2 03             	test   $0x3,%dl
  8008c3:	75 1b                	jne    8008e0 <memmove+0x40>
  8008c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cb:	75 13                	jne    8008e0 <memmove+0x40>
  8008cd:	f6 c1 03             	test   $0x3,%cl
  8008d0:	75 0e                	jne    8008e0 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8008d2:	83 ef 04             	sub    $0x4,%edi
  8008d5:	83 ee 04             	sub    $0x4,%esi
  8008d8:	c1 e9 02             	shr    $0x2,%ecx
  8008db:	fd                   	std    
  8008dc:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  8008de:	eb 27                	jmp    800907 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e0:	4f                   	dec    %edi
  8008e1:	4e                   	dec    %esi
  8008e2:	fd                   	std    
  8008e3:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  8008e5:	eb 20                	jmp    800907 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ed:	75 15                	jne    800904 <memmove+0x64>
  8008ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f5:	75 0d                	jne    800904 <memmove+0x64>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 08                	jne    800904 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  8008fc:	c1 e9 02             	shr    $0x2,%ecx
  8008ff:	fc                   	cld    
  800900:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800902:	eb 03                	jmp    800907 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800904:	fc                   	cld    
  800905:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <memcpy>:

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
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800911:	ff 75 10             	pushl  0x10(%ebp)
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	ff 75 08             	pushl  0x8(%ebp)
  80091a:	e8 81 ff ff ff       	call   8008a0 <memmove>
}
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800928:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  80092b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  80092e:	89 d0                	mov    %edx,%eax
  800930:	4a                   	dec    %edx
  800931:	85 c0                	test   %eax,%eax
  800933:	74 1b                	je     800950 <memcmp+0x2f>
		if (*s1 != *s2)
  800935:	8a 01                	mov    (%ecx),%al
  800937:	3a 03                	cmp    (%ebx),%al
  800939:	74 0c                	je     800947 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093b:	0f b6 d0             	movzbl %al,%edx
  80093e:	0f b6 03             	movzbl (%ebx),%eax
  800941:	29 c2                	sub    %eax,%edx
  800943:	89 d0                	mov    %edx,%eax
  800945:	eb 0e                	jmp    800955 <memcmp+0x34>
		s1++, s2++;
  800947:	41                   	inc    %ecx
  800948:	43                   	inc    %ebx
  800949:	89 d0                	mov    %edx,%eax
  80094b:	4a                   	dec    %edx
  80094c:	85 c0                	test   %eax,%eax
  80094e:	75 e5                	jne    800935 <memcmp+0x14>
	}

	return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800961:	89 c2                	mov    %eax,%edx
  800963:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800966:	39 d0                	cmp    %edx,%eax
  800968:	73 09                	jae    800973 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096a:	38 08                	cmp    %cl,(%eax)
  80096c:	74 05                	je     800973 <memfind+0x1b>
  80096e:	40                   	inc    %eax
  80096f:	39 d0                	cmp    %edx,%eax
  800971:	72 f7                	jb     80096a <memfind+0x12>
			break;
	return (void *) s;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	57                   	push   %edi
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 55 08             	mov    0x8(%ebp),%edx
  80097e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800981:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800984:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800989:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098e:	80 3a 20             	cmpb   $0x20,(%edx)
  800991:	74 05                	je     800998 <strtol+0x23>
  800993:	80 3a 09             	cmpb   $0x9,(%edx)
  800996:	75 0b                	jne    8009a3 <strtol+0x2e>
		s++;
  800998:	42                   	inc    %edx
  800999:	80 3a 20             	cmpb   $0x20,(%edx)
  80099c:	74 fa                	je     800998 <strtol+0x23>
  80099e:	80 3a 09             	cmpb   $0x9,(%edx)
  8009a1:	74 f5                	je     800998 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8009a3:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8009a6:	75 03                	jne    8009ab <strtol+0x36>
		s++;
  8009a8:	42                   	inc    %edx
  8009a9:	eb 0b                	jmp    8009b6 <strtol+0x41>
	else if (*s == '-')
  8009ab:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8009ae:	75 06                	jne    8009b6 <strtol+0x41>
		s++, neg = 1;
  8009b0:	42                   	inc    %edx
  8009b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b6:	85 c9                	test   %ecx,%ecx
  8009b8:	74 05                	je     8009bf <strtol+0x4a>
  8009ba:	83 f9 10             	cmp    $0x10,%ecx
  8009bd:	75 15                	jne    8009d4 <strtol+0x5f>
  8009bf:	80 3a 30             	cmpb   $0x30,(%edx)
  8009c2:	75 10                	jne    8009d4 <strtol+0x5f>
  8009c4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009c8:	75 0a                	jne    8009d4 <strtol+0x5f>
		s += 2, base = 16;
  8009ca:	83 c2 02             	add    $0x2,%edx
  8009cd:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009d2:	eb 1a                	jmp    8009ee <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  8009d4:	85 c9                	test   %ecx,%ecx
  8009d6:	75 16                	jne    8009ee <strtol+0x79>
  8009d8:	80 3a 30             	cmpb   $0x30,(%edx)
  8009db:	75 08                	jne    8009e5 <strtol+0x70>
		s++, base = 8;
  8009dd:	42                   	inc    %edx
  8009de:	b9 08 00 00 00       	mov    $0x8,%ecx
  8009e3:	eb 09                	jmp    8009ee <strtol+0x79>
	else if (base == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	75 05                	jne    8009ee <strtol+0x79>
		base = 10;
  8009e9:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ee:	8a 02                	mov    (%edx),%al
  8009f0:	83 e8 30             	sub    $0x30,%eax
  8009f3:	3c 09                	cmp    $0x9,%al
  8009f5:	77 08                	ja     8009ff <strtol+0x8a>
			dig = *s - '0';
  8009f7:	0f be 02             	movsbl (%edx),%eax
  8009fa:	83 e8 30             	sub    $0x30,%eax
  8009fd:	eb 20                	jmp    800a1f <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  8009ff:	8a 02                	mov    (%edx),%al
  800a01:	83 e8 61             	sub    $0x61,%eax
  800a04:	3c 19                	cmp    $0x19,%al
  800a06:	77 08                	ja     800a10 <strtol+0x9b>
			dig = *s - 'a' + 10;
  800a08:	0f be 02             	movsbl (%edx),%eax
  800a0b:	83 e8 57             	sub    $0x57,%eax
  800a0e:	eb 0f                	jmp    800a1f <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800a10:	8a 02                	mov    (%edx),%al
  800a12:	83 e8 41             	sub    $0x41,%eax
  800a15:	3c 19                	cmp    $0x19,%al
  800a17:	77 12                	ja     800a2b <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a19:	0f be 02             	movsbl (%edx),%eax
  800a1c:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a1f:	39 c8                	cmp    %ecx,%eax
  800a21:	7d 08                	jge    800a2b <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a23:	42                   	inc    %edx
  800a24:	0f af d9             	imul   %ecx,%ebx
  800a27:	01 c3                	add    %eax,%ebx
  800a29:	eb c3                	jmp    8009ee <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a2b:	85 f6                	test   %esi,%esi
  800a2d:	74 02                	je     800a31 <strtol+0xbc>
		*endptr = (char *) s;
  800a2f:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a31:	89 d8                	mov    %ebx,%eax
  800a33:	85 ff                	test   %edi,%edi
  800a35:	74 02                	je     800a39 <strtol+0xc4>
  800a37:	f7 d8                	neg    %eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    
	...

00800a40 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 55 08             	mov    0x8(%ebp),%edx
  800a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a51:	89 f8                	mov    %edi,%eax
  800a53:	89 fb                	mov    %edi,%ebx
  800a55:	89 fe                	mov    %edi,%esi
  800a57:	55                   	push   %ebp
  800a58:	9c                   	pushf  
  800a59:	56                   	push   %esi
  800a5a:	54                   	push   %esp
  800a5b:	5d                   	pop    %ebp
  800a5c:	8d 35 64 0a 80 00    	lea    0x800a64,%esi
  800a62:	0f 34                	sysenter 
  800a64:	83 c4 04             	add    $0x4,%esp
  800a67:	9d                   	popf   
  800a68:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	b8 01 00 00 00       	mov    $0x1,%eax
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7e:	89 fa                	mov    %edi,%edx
  800a80:	89 f9                	mov    %edi,%ecx
  800a82:	89 fb                	mov    %edi,%ebx
  800a84:	89 fe                	mov    %edi,%esi
  800a86:	55                   	push   %ebp
  800a87:	9c                   	pushf  
  800a88:	56                   	push   %esi
  800a89:	54                   	push   %esp
  800a8a:	5d                   	pop    %ebp
  800a8b:	8d 35 93 0a 80 00    	lea    0x800a93,%esi
  800a91:	0f 34                	sysenter 
  800a93:	83 c4 04             	add    $0x4,%esp
  800a96:	9d                   	popf   
  800a97:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 0c             	sub    $0xc,%esp
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	b8 03 00 00 00       	mov    $0x3,%eax
  800aae:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab3:	89 f9                	mov    %edi,%ecx
  800ab5:	89 fb                	mov    %edi,%ebx
  800ab7:	89 fe                	mov    %edi,%esi
  800ab9:	55                   	push   %ebp
  800aba:	9c                   	pushf  
  800abb:	56                   	push   %esi
  800abc:	54                   	push   %esp
  800abd:	5d                   	pop    %ebp
  800abe:	8d 35 c6 0a 80 00    	lea    0x800ac6,%esi
  800ac4:	0f 34                	sysenter 
  800ac6:	83 c4 04             	add    $0x4,%esp
  800ac9:	9d                   	popf   
  800aca:	5d                   	pop    %ebp
  800acb:	85 c0                	test   %eax,%eax
  800acd:	7e 17                	jle    800ae6 <sys_env_destroy+0x49>
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	50                   	push   %eax
  800ad3:	6a 03                	push   $0x3
  800ad5:	68 bc 17 80 00       	push   $0x8017bc
  800ada:	6a 4c                	push   $0x4c
  800adc:	68 d9 17 80 00       	push   $0x8017d9
  800ae1:	e8 8a 06 00 00       	call   801170 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	b8 02 00 00 00       	mov    $0x2,%eax
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
  800afe:	89 fa                	mov    %edi,%edx
  800b00:	89 f9                	mov    %edi,%ecx
  800b02:	89 fb                	mov    %edi,%ebx
  800b04:	89 fe                	mov    %edi,%esi
  800b06:	55                   	push   %ebp
  800b07:	9c                   	pushf  
  800b08:	56                   	push   %esi
  800b09:	54                   	push   %esp
  800b0a:	5d                   	pop    %ebp
  800b0b:	8d 35 13 0b 80 00    	lea    0x800b13,%esi
  800b11:	0f 34                	sysenter 
  800b13:	83 c4 04             	add    $0x4,%esp
  800b16:	9d                   	popf   
  800b17:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <sys_dump_env>:

int
sys_dump_env(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	b8 04 00 00 00       	mov    $0x4,%eax
  800b28:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2d:	89 fa                	mov    %edi,%edx
  800b2f:	89 f9                	mov    %edi,%ecx
  800b31:	89 fb                	mov    %edi,%ebx
  800b33:	89 fe                	mov    %edi,%esi
  800b35:	55                   	push   %ebp
  800b36:	9c                   	pushf  
  800b37:	56                   	push   %esi
  800b38:	54                   	push   %esp
  800b39:	5d                   	pop    %ebp
  800b3a:	8d 35 42 0b 80 00    	lea    0x800b42,%esi
  800b40:	0f 34                	sysenter 
  800b42:	83 c4 04             	add    $0x4,%esp
  800b45:	9d                   	popf   
  800b46:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <sys_yield>:

void
sys_yield(void)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b57:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5c:	89 fa                	mov    %edi,%edx
  800b5e:	89 f9                	mov    %edi,%ecx
  800b60:	89 fb                	mov    %edi,%ebx
  800b62:	89 fe                	mov    %edi,%esi
  800b64:	55                   	push   %ebp
  800b65:	9c                   	pushf  
  800b66:	56                   	push   %esi
  800b67:	54                   	push   %esp
  800b68:	5d                   	pop    %ebp
  800b69:	8d 35 71 0b 80 00    	lea    0x800b71,%esi
  800b6f:	0f 34                	sysenter 
  800b71:	83 c4 04             	add    $0x4,%esp
  800b74:	9d                   	popf   
  800b75:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b92:	bf 00 00 00 00       	mov    $0x0,%edi
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
  800bad:	7e 17                	jle    800bc6 <sys_page_alloc+0x4b>
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 05                	push   $0x5
  800bb5:	68 bc 17 80 00       	push   $0x8017bc
  800bba:	6a 4c                	push   $0x4c
  800bbc:	68 d9 17 80 00       	push   $0x8017d9
  800bc1:	e8 aa 05 00 00       	call   801170 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be3:	8b 75 18             	mov    0x18(%ebp),%esi
  800be6:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800bff:	7e 17                	jle    800c18 <sys_page_map+0x4a>
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 06                	push   $0x6
  800c07:	68 bc 17 80 00       	push   $0x8017bc
  800c0c:	6a 4c                	push   $0x4c
  800c0e:	68 d9 17 80 00       	push   $0x8017d9
  800c13:	e8 58 05 00 00       	call   801170 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800c18:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	b8 07 00 00 00       	mov    $0x7,%eax
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
  800c51:	7e 17                	jle    800c6a <sys_page_unmap+0x4a>
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 07                	push   $0x7
  800c59:	68 bc 17 80 00       	push   $0x8017bc
  800c5e:	6a 4c                	push   $0x4c
  800c60:	68 d9 17 80 00       	push   $0x8017d9
  800c65:	e8 06 05 00 00       	call   801170 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800ca3:	7e 17                	jle    800cbc <sys_env_set_status+0x4a>
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 09                	push   $0x9
  800cab:	68 bc 17 80 00       	push   $0x8017bc
  800cb0:	6a 4c                	push   $0x4c
  800cb2:	68 d9 17 80 00       	push   $0x8017d9
  800cb7:	e8 b4 04 00 00       	call   801170 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdd:	89 fb                	mov    %edi,%ebx
  800cdf:	89 fe                	mov    %edi,%esi
  800ce1:	55                   	push   %ebp
  800ce2:	9c                   	pushf  
  800ce3:	56                   	push   %esi
  800ce4:	54                   	push   %esp
  800ce5:	5d                   	pop    %ebp
  800ce6:	8d 35 ee 0c 80 00    	lea    0x800cee,%esi
  800cec:	0f 34                	sysenter 
  800cee:	83 c4 04             	add    $0x4,%esp
  800cf1:	9d                   	popf   
  800cf2:	5d                   	pop    %ebp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	7e 17                	jle    800d0e <sys_env_set_trapframe+0x4a>
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	50                   	push   %eax
  800cfb:	6a 0a                	push   $0xa
  800cfd:	68 bc 17 80 00       	push   $0x8017bc
  800d02:	6a 4c                	push   $0x4c
  800d04:	68 d9 17 80 00       	push   $0x8017d9
  800d09:	e8 62 04 00 00       	call   801170 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d0e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    

00800d16 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2a:	bf 00 00 00 00       	mov    $0x0,%edi
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
  800d47:	7e 17                	jle    800d60 <sys_env_set_pgfault_upcall+0x4a>
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 0b                	push   $0xb
  800d4f:	68 bc 17 80 00       	push   $0x8017bc
  800d54:	6a 4c                	push   $0x4c
  800d56:	68 d9 17 80 00       	push   $0x8017d9
  800d5b:	e8 10 04 00 00       	call   801170 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7f:	be 00 00 00 00       	mov    $0x0,%esi
  800d84:	55                   	push   %ebp
  800d85:	9c                   	pushf  
  800d86:	56                   	push   %esi
  800d87:	54                   	push   %esp
  800d88:	5d                   	pop    %ebp
  800d89:	8d 35 91 0d 80 00    	lea    0x800d91,%esi
  800d8f:	0f 34                	sysenter 
  800d91:	83 c4 04             	add    $0x4,%esp
  800d94:	9d                   	popf   
  800d95:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    

00800d9b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dac:	bf 00 00 00 00       	mov    $0x0,%edi
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	89 fb                	mov    %edi,%ebx
  800db5:	89 fe                	mov    %edi,%esi
  800db7:	55                   	push   %ebp
  800db8:	9c                   	pushf  
  800db9:	56                   	push   %esi
  800dba:	54                   	push   %esp
  800dbb:	5d                   	pop    %ebp
  800dbc:	8d 35 c4 0d 80 00    	lea    0x800dc4,%esi
  800dc2:	0f 34                	sysenter 
  800dc4:	83 c4 04             	add    $0x4,%esp
  800dc7:	9d                   	popf   
  800dc8:	5d                   	pop    %ebp
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 17                	jle    800de4 <sys_ipc_recv+0x49>
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	50                   	push   %eax
  800dd1:	6a 0e                	push   $0xe
  800dd3:	68 bc 17 80 00       	push   $0x8017bc
  800dd8:	6a 4c                	push   $0x4c
  800dda:	68 d9 17 80 00       	push   $0x8017d9
  800ddf:	e8 8c 03 00 00       	call   801170 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de4:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	c9                   	leave  
  800deb:	c3                   	ret    

00800dec <pgfault>:
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	53                   	push   %ebx
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
    void *addr = (void *) utf->utf_fault_va;
  800df6:	8b 1a                	mov    (%edx),%ebx
    uint32_t err = utf->utf_err;
  800df8:	8b 42 04             	mov    0x4(%edx),%eax
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
  800dfb:	a8 02                	test   $0x2,%al
  800dfd:	0f 84 ae 00 00 00    	je     800eb1 <pgfault+0xc5>
        //cprintf("it's caused by fault write\n");
        if (vpt[PPN(addr)] & PTE_COW) {//first
  800e03:	89 d8                	mov    %ebx,%eax
  800e05:	c1 e8 0c             	shr    $0xc,%eax
  800e08:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  800e0f:	f6 c4 08             	test   $0x8,%ah
  800e12:	0f 84 85 00 00 00    	je     800e9d <pgfault+0xb1>
            //ok it's caused by copy on write
            //cprintf("it's caused by copy on write\n");
            if ((r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W))) {//wrong not ROUNDDOWN(addr,PGSIZE)
  800e18:	83 ec 04             	sub    $0x4,%esp
  800e1b:	6a 07                	push   $0x7
  800e1d:	68 00 f0 7f 00       	push   $0x7ff000
  800e22:	6a 00                	push   $0x0
  800e24:	e8 52 fd ff ff       	call   800b7b <sys_page_alloc>
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	74 0a                	je     800e3a <pgfault+0x4e>
                panic("pgfault->sys_page_alloc:%e",r);
  800e30:	50                   	push   %eax
  800e31:	68 e7 17 80 00       	push   $0x8017e7
  800e36:	6a 2f                	push   $0x2f
  800e38:	eb 6d                	jmp    800ea7 <pgfault+0xbb>
            }
            //cprintf("before copy data from ROUNDDOWN(%x,PGSIZE) to PFTEMP\n",addr);
            memcpy(PFTEMP,ROUNDDOWN(addr,PGSIZE),PGSIZE);
  800e3a:	89 d8                	mov    %ebx,%eax
  800e3c:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e41:	29 c3                	sub    %eax,%ebx
  800e43:	83 ec 04             	sub    $0x4,%esp
  800e46:	68 00 10 00 00       	push   $0x1000
  800e4b:	53                   	push   %ebx
  800e4c:	68 00 f0 7f 00       	push   $0x7ff000
  800e51:	e8 b5 fa ff ff       	call   80090b <memcpy>
            //cprintf("before map the PFTEMP to the ROUNDDOWN(%x,PGSIZE)\n",addr);
            if ((r= sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_P|PTE_U|PTE_W))) {/*seemly than PTE_USER is wrong*/
  800e56:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e5d:	53                   	push   %ebx
  800e5e:	6a 00                	push   $0x0
  800e60:	68 00 f0 7f 00       	push   $0x7ff000
  800e65:	6a 00                	push   $0x0
  800e67:	e8 62 fd ff ff       	call   800bce <sys_page_map>
  800e6c:	83 c4 20             	add    $0x20,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	74 0a                	je     800e7d <pgfault+0x91>
                panic("pgfault->sys_page_map:%e",r);
  800e73:	50                   	push   %eax
  800e74:	68 02 18 80 00       	push   $0x801802
  800e79:	6a 35                	push   $0x35
  800e7b:	eb 2a                	jmp    800ea7 <pgfault+0xbb>
            }
            //cprintf("before unmap the PFTEMP\n");
            if ((r = sys_page_unmap(0,PFTEMP))) {
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	6a 00                	push   $0x0
  800e87:	e8 94 fd ff ff       	call   800c20 <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	74 37                	je     800eca <pgfault+0xde>
                panic("pgfault->sys_page_unmap:%e",r);
  800e93:	50                   	push   %eax
  800e94:	68 1b 18 80 00       	push   $0x80181b
  800e99:	6a 39                	push   $0x39
  800e9b:	eb 0a                	jmp    800ea7 <pgfault+0xbb>
            }
            //cprintf("after unmap the PFTEMP\n");
        } else {
            panic("the fault write page is not copy on write\n");
  800e9d:	83 ec 04             	sub    $0x4,%esp
  800ea0:	68 9c 18 80 00       	push   $0x80189c
  800ea5:	6a 3d                	push   $0x3d
  800ea7:	68 36 18 80 00       	push   $0x801836
  800eac:	e8 bf 02 00 00       	call   801170 <_panic>
        }
    } else {
        panic("the fault page isn't fault write,%eip is %x,va is %x,errcode is %d",utf->utf_eip,addr,err);
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	50                   	push   %eax
  800eb5:	53                   	push   %ebx
  800eb6:	ff 72 28             	pushl  0x28(%edx)
  800eb9:	68 c8 18 80 00       	push   $0x8018c8
  800ebe:	6a 40                	push   $0x40
  800ec0:	68 36 18 80 00       	push   $0x801836
  800ec5:	e8 a6 02 00 00       	call   801170 <_panic>
    }
    //it should be ok
    //panic("pgfault not implemented");
}
  800eca:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <duppage>:

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
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
    int r;
    void *addr;
    pte_t pte;
    pte = vpt[pn];//current env's page table entry
  800eda:	8b 14 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%edx
    addr = (void *) (pn*PGSIZE);//virtual address
  800ee1:	89 c6                	mov    %eax,%esi
  800ee3:	c1 e6 0c             	shl    $0xc,%esi
    uint32_t perm = pte & PTE_USER;
  800ee6:	89 d3                	mov    %edx,%ebx
  800ee8:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
    /*if((uint32_t)addr == USTACKTOP-PGSIZE) {
        cprintf("duppage user stack!!!!!!!!!!\n");
    }*/
    if ((pte & PTE_COW)|(pte & PTE_W)) {
  800eee:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ef4:	74 26                	je     800f1c <duppage+0x4d>
        /*the page need copy on write*/
        perm |= PTE_COW;
  800ef6:	80 cf 08             	or     $0x8,%bh
        perm &= ~PTE_W;
  800ef9:	83 e3 fd             	and    $0xfffffffd,%ebx
        if ((r = sys_page_map(0,addr,envid,addr,perm))) {
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	53                   	push   %ebx
  800f00:	56                   	push   %esi
  800f01:	51                   	push   %ecx
  800f02:	56                   	push   %esi
  800f03:	6a 00                	push   $0x0
  800f05:	e8 c4 fc ff ff       	call   800bce <sys_page_map>
  800f0a:	83 c4 20             	add    $0x20,%esp
  800f0d:	89 c2                	mov    %eax,%edx
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	75 19                	jne    800f2c <duppage+0x5d>
            return r;
        }
        return sys_page_map(0,addr,0,addr,perm);//also remap it
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	53                   	push   %ebx
  800f17:	56                   	push   %esi
  800f18:	6a 00                	push   $0x0
  800f1a:	eb 06                	jmp    800f22 <duppage+0x53>
        /*now the page can't be writen*/
    }
    // LAB 4: Your code here.
    //panic("duppage not implemented");
    //may be wrong, it's not writable so just map it,although it may be no safe
    return sys_page_map(0, addr, envid, addr, perm);
  800f1c:	83 ec 0c             	sub    $0xc,%esp
  800f1f:	53                   	push   %ebx
  800f20:	56                   	push   %esi
  800f21:	51                   	push   %ecx
  800f22:	56                   	push   %esi
  800f23:	6a 00                	push   $0x0
  800f25:	e8 a4 fc ff ff       	call   800bce <sys_page_map>
  800f2a:	89 c2                	mov    %eax,%edx
}
  800f2c:	89 d0                	mov    %edx,%eax
  800f2e:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	c9                   	leave  
  800f34:	c3                   	ret    

00800f35 <fork>:

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
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 18             	sub    $0x18,%esp
    // LAB 4: Your code here.
    int pde_index;
    int pte_index;
    envid_t envid;
    unsigned pn = 0;
  800f3e:	be 00 00 00 00       	mov    $0x0,%esi
    int r;
    set_pgfault_handler(pgfault);/*set the pgfault handler for the father*/
  800f43:	68 ec 0d 80 00       	push   $0x800dec
  800f48:	e8 83 02 00 00       	call   8011d0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
  800f4d:	83 c4 10             	add    $0x10,%esp
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
  800f50:	ba 08 00 00 00       	mov    $0x8,%edx
  800f55:	89 d0                	mov    %edx,%eax
  800f57:	cd 30                	int    $0x30
  800f59:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
    //cprintf("in fork before sys_exofork\n");
    envid = sys_exofork();//it use int to syscall
    //the child will come back use iret
    //cprintf("after fork->sys_exofork return:%d\n",envid);
    if (envid < 0) {
  800f5c:	89 c2                	mov    %eax,%edx
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	0f 88 f4 00 00 00    	js     80105a <fork+0x125>
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
  800f66:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6b:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800f6f:	75 21                	jne    800f92 <fork+0x5d>
  800f71:	e8 78 fb ff ff       	call   800aee <sys_getenvid>
  800f76:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7b:	c1 e0 07             	shl    $0x7,%eax
  800f7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f83:	a3 08 20 80 00       	mov    %eax,0x802008
  800f88:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8d:	e9 c8 00 00 00       	jmp    80105a <fork+0x125>
        /*upper than utop,such map has already done*/
        if (vpd[pde_index]) {
  800f92:	8b 04 bd 00 d0 7b ef 	mov    0xef7bd000(,%edi,4),%eax
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	74 48                	je     800fe5 <fork+0xb0>
            for (pte_index = 0;pte_index < NPTENTRIES;pte_index++) {
  800f9d:	bb 00 00 00 00       	mov    $0x0,%ebx
                if (vpt[pn]&& (pn*PGSIZE) != (UXSTACKTOP - PGSIZE)) {
  800fa2:	8b 04 b5 00 00 40 ef 	mov    0xef400000(,%esi,4),%eax
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	74 2c                	je     800fd9 <fork+0xa4>
  800fad:	89 f0                	mov    %esi,%eax
  800faf:	c1 e0 0c             	shl    $0xc,%eax
  800fb2:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  800fb7:	74 20                	je     800fd9 <fork+0xa4>
                    /*if the pte is not null and it's not pgfault stack*/
                    if ((r = duppage(envid,pn)))
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	56                   	push   %esi
  800fbd:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800fc0:	e8 0a ff ff ff       	call   800ecf <duppage>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	74 0d                	je     800fd9 <fork+0xa4>
                        panic("in duppage:%e",r);
  800fcc:	50                   	push   %eax
  800fcd:	68 41 18 80 00       	push   $0x801841
  800fd2:	68 9e 00 00 00       	push   $0x9e
  800fd7:	eb 77                	jmp    801050 <fork+0x11b>
                }
                pn++;
  800fd9:	46                   	inc    %esi
  800fda:	43                   	inc    %ebx
  800fdb:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  800fe1:	7e bf                	jle    800fa2 <fork+0x6d>
  800fe3:	eb 06                	jmp    800feb <fork+0xb6>
            }
        } else {
            pn += NPTENTRIES;/*skip 1024 virtual page*/
  800fe5:	81 c6 00 04 00 00    	add    $0x400,%esi
  800feb:	47                   	inc    %edi
  800fec:	81 ff ba 03 00 00    	cmp    $0x3ba,%edi
  800ff2:	76 9e                	jbe    800f92 <fork+0x5d>
        }
    }
    //cprintf("after parent map for child\n");
    /*set the pgfault handler for child*/
    //cprintf("after set the pgfault handler\n");
    if ((r = sys_page_alloc(envid,(void *)(UXSTACKTOP - PGSIZE),PTE_P|PTE_U|PTE_W))) {
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	6a 07                	push   $0x7
  800ff9:	68 00 f0 bf ee       	push   $0xeebff000
  800ffe:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801001:	e8 75 fb ff ff       	call   800b7b <sys_page_alloc>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	74 0d                	je     80101a <fork+0xe5>
        panic("in fork->sys_page_alloc %e",r);
  80100d:	50                   	push   %eax
  80100e:	68 4f 18 80 00       	push   $0x80184f
  801013:	68 aa 00 00 00       	push   $0xaa
  801018:	eb 36                	jmp    801050 <fork+0x11b>
    }
    //cprintf("before set the pgfault up call for child\n");
    //cprintf("env->env_pgfault_upcall:%x\n",env->env_pgfault_upcall);
    sys_env_set_pgfault_upcall(envid,env->env_pgfault_upcall);
  80101a:	83 ec 08             	sub    $0x8,%esp
  80101d:	a1 08 20 80 00       	mov    0x802008,%eax
  801022:	8b 40 68             	mov    0x68(%eax),%eax
  801025:	50                   	push   %eax
  801026:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801029:	e8 e8 fc ff ff       	call   800d16 <sys_env_set_pgfault_upcall>
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE))) {
  80102e:	83 c4 08             	add    $0x8,%esp
  801031:	6a 01                	push   $0x1
  801033:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801036:	e8 37 fc ff ff       	call   800c72 <sys_env_set_status>
  80103b:	83 c4 10             	add    $0x10,%esp
        panic("in fork->sys_env_status %e",r);
    }
    //cprintf("fork ok %d\n",sys_getenvid());
    return envid;
  80103e:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  801041:	85 c0                	test   %eax,%eax
  801043:	74 15                	je     80105a <fork+0x125>
  801045:	50                   	push   %eax
  801046:	68 6a 18 80 00       	push   $0x80186a
  80104b:	68 b0 00 00 00       	push   $0xb0
  801050:	68 36 18 80 00       	push   $0x801836
  801055:	e8 16 01 00 00       	call   801170 <_panic>
    //panic("fork not implemented");
}
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5f                   	pop    %edi
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <sfork>:

// Challenge!
int
sfork(void)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 0c             	sub    $0xc,%esp
    panic("sfork not implemented");
  80106a:	68 85 18 80 00       	push   $0x801885
  80106f:	68 bb 00 00 00       	push   $0xbb
  801074:	68 36 18 80 00       	push   $0x801836
  801079:	e8 f2 00 00 00       	call   801170 <_panic>
	...

00801080 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108b:	8b 75 10             	mov    0x10(%ebp),%esi
    // LAB 4: Your code here.
    //cprintf("env:%d is recieving\n",env->env_id);
    int r;
    if (!pg) {
  80108e:	85 c0                	test   %eax,%eax
  801090:	75 05                	jne    801097 <ipc_recv+0x17>
        /*the reciever need an integer not a page*/
        pg = (void*)UTOP;
  801092:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
    }
    if ((r = sys_ipc_recv(pg))) {
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	50                   	push   %eax
  80109b:	e8 fb fc ff ff       	call   800d9b <sys_ipc_recv>
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	74 16                	je     8010bd <ipc_recv+0x3d>
        if (from_env_store) {
  8010a7:	85 db                	test   %ebx,%ebx
  8010a9:	74 06                	je     8010b1 <ipc_recv+0x31>
            *from_env_store = 0;
  8010ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        }
        if (perm_store) {
  8010b1:	85 f6                	test   %esi,%esi
  8010b3:	74 48                	je     8010fd <ipc_recv+0x7d>
            *perm_store = 0;
  8010b5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        return r;
  8010bb:	eb 40                	jmp    8010fd <ipc_recv+0x7d>
    }
    if (from_env_store) {
  8010bd:	85 db                	test   %ebx,%ebx
  8010bf:	74 0a                	je     8010cb <ipc_recv+0x4b>
        *from_env_store = env->env_ipc_from;
  8010c1:	a1 08 20 80 00       	mov    0x802008,%eax
  8010c6:	8b 40 78             	mov    0x78(%eax),%eax
  8010c9:	89 03                	mov    %eax,(%ebx)
    }
    if (perm_store) {
  8010cb:	85 f6                	test   %esi,%esi
  8010cd:	74 0a                	je     8010d9 <ipc_recv+0x59>
        *perm_store = env->env_ipc_perm;
  8010cf:	a1 08 20 80 00       	mov    0x802008,%eax
  8010d4:	8b 40 7c             	mov    0x7c(%eax),%eax
  8010d7:	89 06                	mov    %eax,(%esi)
    }
    cprintf("from env %d to env %d,recieve ok,value:%d\n",env->env_ipc_from,env->env_id,env->env_ipc_value);
  8010d9:	8b 15 08 20 80 00    	mov    0x802008,%edx
  8010df:	8b 42 74             	mov    0x74(%edx),%eax
  8010e2:	50                   	push   %eax
  8010e3:	8b 42 4c             	mov    0x4c(%edx),%eax
  8010e6:	50                   	push   %eax
  8010e7:	8b 42 78             	mov    0x78(%edx),%eax
  8010ea:	50                   	push   %eax
  8010eb:	68 0c 19 80 00       	push   $0x80190c
  8010f0:	e8 ef f0 ff ff       	call   8001e4 <cprintf>
    return env->env_ipc_value;
  8010f5:	a1 08 20 80 00       	mov    0x802008,%eax
  8010fa:	8b 40 74             	mov    0x74(%eax),%eax
    panic("ipc_recv not implemented");
    return 0;
}
  8010fd:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <ipc_send>:

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
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	57                   	push   %edi
  801108:	56                   	push   %esi
  801109:	53                   	push   %ebx
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801110:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801113:	8b 75 14             	mov    0x14(%ebp),%esi
    // LAB 4: Your code here.
    int r;
    while (1) {
        if(!pg) {
  801116:	85 db                	test   %ebx,%ebx
  801118:	75 05                	jne    80111f <ipc_send+0x1b>
            pg = (void*)UTOP;
  80111a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
        }
        r = sys_ipc_try_send(to_env,val,pg,perm);
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	57                   	push   %edi
  801122:	ff 75 08             	pushl  0x8(%ebp)
  801125:	e8 3e fc ff ff       	call   800d68 <sys_ipc_try_send>
        if (r == 0 || r == 1) {
  80112a:	83 c4 10             	add    $0x10,%esp
  80112d:	83 f8 01             	cmp    $0x1,%eax
  801130:	76 1e                	jbe    801150 <ipc_send+0x4c>
            break;
        } else if (r != -E_IPC_NOT_RECV) {
  801132:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801135:	74 12                	je     801149 <ipc_send+0x45>
            /*unknown err*/
            panic("ipc_send not ok: %e\n",r);
  801137:	50                   	push   %eax
  801138:	68 5b 19 80 00       	push   $0x80195b
  80113d:	6a 46                	push   $0x46
  80113f:	68 70 19 80 00       	push   $0x801970
  801144:	e8 27 00 00 00       	call   801170 <_panic>
        }
        sys_yield();
  801149:	e8 fe f9 ff ff       	call   800b4c <sys_yield>
  80114e:	eb c6                	jmp    801116 <ipc_send+0x12>
    }
    cprintf("env %d to env %d send ok,value:%d\n",env->env_id,to_env,val);
  801150:	57                   	push   %edi
  801151:	ff 75 08             	pushl  0x8(%ebp)
  801154:	a1 08 20 80 00       	mov    0x802008,%eax
  801159:	8b 40 4c             	mov    0x4c(%eax),%eax
  80115c:	50                   	push   %eax
  80115d:	68 38 19 80 00       	push   $0x801938
  801162:	e8 7d f0 ff ff       	call   8001e4 <cprintf>
}
  801167:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80116a:	5b                   	pop    %ebx
  80116b:	5e                   	pop    %esi
  80116c:	5f                   	pop    %edi
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    
	...

00801170 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	53                   	push   %ebx
  801174:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  801177:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80117a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801181:	74 16                	je     801199 <_panic+0x29>
		cprintf("%s: ", argv0);
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	ff 35 0c 20 80 00    	pushl  0x80200c
  80118c:	68 7a 19 80 00       	push   $0x80197a
  801191:	e8 4e f0 ff ff       	call   8001e4 <cprintf>
  801196:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801199:	ff 75 0c             	pushl  0xc(%ebp)
  80119c:	ff 75 08             	pushl  0x8(%ebp)
  80119f:	ff 35 00 20 80 00    	pushl  0x802000
  8011a5:	68 7f 19 80 00       	push   $0x80197f
  8011aa:	e8 35 f0 ff ff       	call   8001e4 <cprintf>
	vcprintf(fmt, ap);
  8011af:	83 c4 08             	add    $0x8,%esp
  8011b2:	53                   	push   %ebx
  8011b3:	ff 75 10             	pushl  0x10(%ebp)
  8011b6:	e8 d8 ef ff ff       	call   800193 <vcprintf>
	cprintf("\n");
  8011bb:	c7 04 24 6e 19 80 00 	movl   $0x80196e,(%esp)
  8011c2:	e8 1d f0 ff ff       	call   8001e4 <cprintf>

	// Cause a breakpoint exception
	while (1)
  8011c7:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8011ca:	cc                   	int3   
  8011cb:	eb fd                	jmp    8011ca <_panic+0x5a>
}
  8011cd:	00 00                	add    %al,(%eax)
	...

008011d0 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == NULL) {
  8011d6:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8011dd:	75 2a                	jne    801209 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
        //cprintf("i'm in set pgfault_handler,before alloc\n");
        if(sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W)) {//maybe not PTE_USER
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	6a 07                	push   $0x7
  8011e4:	68 00 f0 bf ee       	push   $0xeebff000
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 8b f9 ff ff       	call   800b7b <sys_page_alloc>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	75 1a                	jne    801211 <set_pgfault_handler+0x41>
            return;
        }
        //cprintf("i'm in set pgfault_handler,after alloc\n");
        sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	68 14 12 80 00       	push   $0x801214
  8011ff:	6a 00                	push   $0x0
  801201:	e8 10 fb ff ff       	call   800d16 <sys_env_set_pgfault_upcall>
  801206:	83 c4 10             	add    $0x10,%esp
        //cprintf("here in set pgfault handler\n");
		//panic("set_pgfault_handler not implemented");
	}
	// Save handler pointer for assembly to call.
    //cprintf("handler %x;pgfault_handler address %x,upcall address %x,upcall points %x\n",handler,&_pgfault_handler,&_pgfault_upcall,_pgfault_upcall);
	_pgfault_handler = handler;
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
  80120c:	a3 10 20 80 00       	mov    %eax,0x802010
    //cprintf("here\n");
    //it should be ok
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    
	...

00801214 <_pgfault_upcall>:
  801214:	54                   	push   %esp
  801215:	a1 10 20 80 00       	mov    0x802010,%eax
  80121a:	ff d0                	call   *%eax
  80121c:	83 c4 04             	add    $0x4,%esp
  80121f:	83 c4 08             	add    $0x8,%esp
  801222:	8b 54 24 20          	mov    0x20(%esp),%edx
  801226:	8b 44 24 28          	mov    0x28(%esp),%eax
  80122a:	83 e8 04             	sub    $0x4,%eax
  80122d:	89 10                	mov    %edx,(%eax)
  80122f:	89 44 24 28          	mov    %eax,0x28(%esp)
  801233:	61                   	popa   
  801234:	83 c4 04             	add    $0x4,%esp
  801237:	9d                   	popf   
  801238:	5c                   	pop    %esp
  801239:	c3                   	ret    
	...

0080123c <__udivdi3>:
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	83 ec 20             	sub    $0x20,%esp
  801244:	8b 55 14             	mov    0x14(%ebp),%edx
  801247:	8b 75 08             	mov    0x8(%ebp),%esi
  80124a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80124d:	8b 45 10             	mov    0x10(%ebp),%eax
  801250:	85 d2                	test   %edx,%edx
  801252:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  801255:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  80125c:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  801263:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  801266:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  801269:	89 fe                	mov    %edi,%esi
  80126b:	75 5b                	jne    8012c8 <__udivdi3+0x8c>
  80126d:	39 f8                	cmp    %edi,%eax
  80126f:	76 2b                	jbe    80129c <__udivdi3+0x60>
  801271:	89 fa                	mov    %edi,%edx
  801273:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  801276:	f7 75 dc             	divl   0xffffffdc(%ebp)
  801279:	89 c7                	mov    %eax,%edi
  80127b:	90                   	nop    
  80127c:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  801283:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  801286:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  801289:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  80128c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  80128f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801292:	83 c4 20             	add    $0x20,%esp
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	c9                   	leave  
  801298:	c3                   	ret    
  801299:	8d 76 00             	lea    0x0(%esi),%esi
  80129c:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	75 0e                	jne    8012b1 <__udivdi3+0x75>
  8012a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a8:	31 c9                	xor    %ecx,%ecx
  8012aa:	31 d2                	xor    %edx,%edx
  8012ac:	f7 f1                	div    %ecx
  8012ae:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  8012b1:	89 f0                	mov    %esi,%eax
  8012b3:	31 d2                	xor    %edx,%edx
  8012b5:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8012b8:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8012bb:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8012be:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8012c1:	89 c7                	mov    %eax,%edi
  8012c3:	eb be                	jmp    801283 <__udivdi3+0x47>
  8012c5:	8d 76 00             	lea    0x0(%esi),%esi
  8012c8:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  8012cb:	76 07                	jbe    8012d4 <__udivdi3+0x98>
  8012cd:	31 ff                	xor    %edi,%edi
  8012cf:	eb ab                	jmp    80127c <__udivdi3+0x40>
  8012d1:	8d 76 00             	lea    0x0(%esi),%esi
  8012d4:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  8012d8:	89 c7                	mov    %eax,%edi
  8012da:	83 f7 1f             	xor    $0x1f,%edi
  8012dd:	75 19                	jne    8012f8 <__udivdi3+0xbc>
  8012df:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  8012e2:	77 0a                	ja     8012ee <__udivdi3+0xb2>
  8012e4:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8012e7:	31 ff                	xor    %edi,%edi
  8012e9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  8012ec:	72 8e                	jb     80127c <__udivdi3+0x40>
  8012ee:	bf 01 00 00 00       	mov    $0x1,%edi
  8012f3:	eb 87                	jmp    80127c <__udivdi3+0x40>
  8012f5:	8d 76 00             	lea    0x0(%esi),%esi
  8012f8:	b8 20 00 00 00       	mov    $0x20,%eax
  8012fd:	29 f8                	sub    %edi,%eax
  8012ff:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  801302:	89 f9                	mov    %edi,%ecx
  801304:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801307:	d3 e2                	shl    %cl,%edx
  801309:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  80130c:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  80130f:	d3 e8                	shr    %cl,%eax
  801311:	09 c2                	or     %eax,%edx
  801313:	89 f9                	mov    %edi,%ecx
  801315:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  801318:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  80131b:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  80131e:	89 f2                	mov    %esi,%edx
  801320:	d3 ea                	shr    %cl,%edx
  801322:	89 f9                	mov    %edi,%ecx
  801324:	d3 e6                	shl    %cl,%esi
  801326:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  801329:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  80132c:	d3 e8                	shr    %cl,%eax
  80132e:	09 c6                	or     %eax,%esi
  801330:	89 f9                	mov    %edi,%ecx
  801332:	89 f0                	mov    %esi,%eax
  801334:	f7 75 ec             	divl   0xffffffec(%ebp)
  801337:	89 d6                	mov    %edx,%esi
  801339:	89 c7                	mov    %eax,%edi
  80133b:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  80133e:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  801341:	f7 e7                	mul    %edi
  801343:	39 f2                	cmp    %esi,%edx
  801345:	77 0f                	ja     801356 <__udivdi3+0x11a>
  801347:	0f 85 2f ff ff ff    	jne    80127c <__udivdi3+0x40>
  80134d:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  801350:	0f 86 26 ff ff ff    	jbe    80127c <__udivdi3+0x40>
  801356:	4f                   	dec    %edi
  801357:	e9 20 ff ff ff       	jmp    80127c <__udivdi3+0x40>

0080135c <__umoddi3>:
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	57                   	push   %edi
  801360:	56                   	push   %esi
  801361:	83 ec 30             	sub    $0x30,%esp
  801364:	8b 55 14             	mov    0x14(%ebp),%edx
  801367:	8b 75 08             	mov    0x8(%ebp),%esi
  80136a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80136d:	8b 45 10             	mov    0x10(%ebp),%eax
  801370:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  801373:	85 d2                	test   %edx,%edx
  801375:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  80137c:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  801383:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  801386:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  801389:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  80138c:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  80138f:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801392:	75 68                	jne    8013fc <__umoddi3+0xa0>
  801394:	39 f8                	cmp    %edi,%eax
  801396:	76 3c                	jbe    8013d4 <__umoddi3+0x78>
  801398:	89 f0                	mov    %esi,%eax
  80139a:	89 fa                	mov    %edi,%edx
  80139c:	f7 75 cc             	divl   0xffffffcc(%ebp)
  80139f:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  8013a2:	85 c9                	test   %ecx,%ecx
  8013a4:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8013a7:	74 1b                	je     8013c4 <__umoddi3+0x68>
  8013a9:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8013ac:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  8013af:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  8013b6:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8013b9:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8013bc:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8013bf:	89 10                	mov    %edx,(%eax)
  8013c1:	89 48 04             	mov    %ecx,0x4(%eax)
  8013c4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8013c7:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  8013ca:	83 c4 30             	add    $0x30,%esp
  8013cd:	5e                   	pop    %esi
  8013ce:	5f                   	pop    %edi
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    
  8013d1:	8d 76 00             	lea    0x0(%esi),%esi
  8013d4:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  8013d7:	85 f6                	test   %esi,%esi
  8013d9:	75 0d                	jne    8013e8 <__umoddi3+0x8c>
  8013db:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e0:	31 d2                	xor    %edx,%edx
  8013e2:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8013e5:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8013e8:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8013eb:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8013ee:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8013f1:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8013f4:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8013f7:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8013fa:	eb a3                	jmp    80139f <__umoddi3+0x43>
  8013fc:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8013ff:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  801402:	76 14                	jbe    801418 <__umoddi3+0xbc>
  801404:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  801407:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80140a:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80140d:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801410:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  801413:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  801416:	eb ac                	jmp    8013c4 <__umoddi3+0x68>
  801418:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  80141c:	89 c6                	mov    %eax,%esi
  80141e:	83 f6 1f             	xor    $0x1f,%esi
  801421:	75 4d                	jne    801470 <__umoddi3+0x114>
  801423:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801426:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  801429:	77 08                	ja     801433 <__umoddi3+0xd7>
  80142b:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  80142e:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  801431:	72 12                	jb     801445 <__umoddi3+0xe9>
  801433:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801436:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801439:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  80143c:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80143f:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801442:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801445:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801448:	85 d2                	test   %edx,%edx
  80144a:	0f 84 74 ff ff ff    	je     8013c4 <__umoddi3+0x68>
  801450:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801453:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801456:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801459:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80145c:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  80145f:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801462:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801465:	89 01                	mov    %eax,(%ecx)
  801467:	89 51 04             	mov    %edx,0x4(%ecx)
  80146a:	e9 55 ff ff ff       	jmp    8013c4 <__umoddi3+0x68>
  80146f:	90                   	nop    
  801470:	b8 20 00 00 00       	mov    $0x20,%eax
  801475:	29 f0                	sub    %esi,%eax
  801477:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80147a:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80147d:	89 f1                	mov    %esi,%ecx
  80147f:	d3 e2                	shl    %cl,%edx
  801481:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  801484:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801487:	d3 e8                	shr    %cl,%eax
  801489:	09 c2                	or     %eax,%edx
  80148b:	89 f1                	mov    %esi,%ecx
  80148d:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801490:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801493:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801496:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801499:	d3 ea                	shr    %cl,%edx
  80149b:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  80149e:	89 f1                	mov    %esi,%ecx
  8014a0:	d3 e7                	shl    %cl,%edi
  8014a2:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8014a5:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8014a8:	d3 e8                	shr    %cl,%eax
  8014aa:	09 c7                	or     %eax,%edi
  8014ac:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  8014af:	89 f8                	mov    %edi,%eax
  8014b1:	89 f1                	mov    %esi,%ecx
  8014b3:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8014b6:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8014b9:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  8014bc:	f7 65 cc             	mull   0xffffffcc(%ebp)
  8014bf:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  8014c2:	89 c7                	mov    %eax,%edi
  8014c4:	77 3f                	ja     801505 <__umoddi3+0x1a9>
  8014c6:	74 38                	je     801500 <__umoddi3+0x1a4>
  8014c8:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	0f 84 f1 fe ff ff    	je     8013c4 <__umoddi3+0x68>
  8014d3:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  8014d6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8014d9:	29 f8                	sub    %edi,%eax
  8014db:	19 d1                	sbb    %edx,%ecx
  8014dd:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8014e0:	89 ca                	mov    %ecx,%edx
  8014e2:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8014e5:	d3 e2                	shl    %cl,%edx
  8014e7:	89 f1                	mov    %esi,%ecx
  8014e9:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8014ec:	d3 e8                	shr    %cl,%eax
  8014ee:	09 c2                	or     %eax,%edx
  8014f0:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8014f3:	d3 e8                	shr    %cl,%eax
  8014f5:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8014f8:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8014fb:	e9 b6 fe ff ff       	jmp    8013b6 <__umoddi3+0x5a>
  801500:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  801503:	76 c3                	jbe    8014c8 <__umoddi3+0x16c>
  801505:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  801508:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80150b:	eb bb                	jmp    8014c8 <__umoddi3+0x16c>
  80150d:	90                   	nop    
  80150e:	90                   	nop    
  80150f:	90                   	nop    
