
obj/user/primes：     文件格式 elf32-i386

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

00800034 <primeproc>:
#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	6a 00                	push   $0x0
  800042:	6a 00                	push   $0x0
  800044:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  800047:	50                   	push   %eax
  800048:	e8 93 10 00 00       	call   8010e0 <ipc_recv>
  80004d:	89 c6                	mov    %eax,%esi
	cprintf("%d ", p);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	50                   	push   %eax
  800053:	68 20 15 80 00       	push   $0x801520
  800058:	e8 e7 01 00 00       	call   800244 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  80005d:	e8 33 0f 00 00       	call   800f95 <fork>
  800062:	89 c7                	mov    %eax,%edi
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	79 12                	jns    80007d <primeproc+0x49>
		panic("fork: %e", id);
  80006b:	50                   	push   %eax
  80006c:	68 24 15 80 00       	push   $0x801524
  800071:	6a 1a                	push   $0x1a
  800073:	68 2d 15 80 00       	push   $0x80152d
  800078:	e8 d7 00 00 00       	call   800154 <_panic>
	if (id == 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	74 bc                	je     80003d <primeproc+0x9>
		goto top;
	
	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800081:	83 ec 04             	sub    $0x4,%esp
  800084:	6a 00                	push   $0x0
  800086:	6a 00                	push   $0x0
  800088:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
  80008b:	50                   	push   %eax
  80008c:	e8 4f 10 00 00       	call   8010e0 <ipc_recv>
  800091:	89 c3                	mov    %eax,%ebx
        cprintf("my p is %d\n",p);
  800093:	83 c4 08             	add    $0x8,%esp
  800096:	56                   	push   %esi
  800097:	68 3b 15 80 00       	push   $0x80153b
  80009c:	e8 a3 01 00 00       	call   800244 <cprintf>
		if (i % p)
  8000a1:	89 d8                	mov    %ebx,%eax
  8000a3:	99                   	cltd   
  8000a4:	f7 fe                	idiv   %esi
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	85 d2                	test   %edx,%edx
  8000ab:	74 d4                	je     800081 <primeproc+0x4d>
			ipc_send(id, i, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	53                   	push   %ebx
  8000b2:	57                   	push   %edi
  8000b3:	e8 ac 10 00 00       	call   801164 <ipc_send>
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	eb c4                	jmp    800081 <primeproc+0x4d>

008000bd <umain>:
	}
}

void
umain(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000c2:	e8 ce 0e 00 00       	call   800f95 <fork>
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	79 12                	jns    8000df <umain+0x22>
		panic("fork: %e", id);
  8000cd:	50                   	push   %eax
  8000ce:	68 24 15 80 00       	push   $0x801524
  8000d3:	6a 2e                	push   $0x2e
  8000d5:	68 2d 15 80 00       	push   $0x80152d
  8000da:	e8 75 00 00 00       	call   800154 <_panic>
	if (id == 0)
  8000df:	85 c0                	test   %eax,%eax
  8000e1:	75 05                	jne    8000e8 <umain+0x2b>
		primeproc();
  8000e3:	e8 4c ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
  8000e8:	bb 02 00 00 00       	mov    $0x2,%ebx
		ipc_send(id, i, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	53                   	push   %ebx
  8000f2:	56                   	push   %esi
  8000f3:	e8 6c 10 00 00       	call   801164 <ipc_send>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	43                   	inc    %ebx
  8000fc:	eb ef                	jmp    8000ed <umain+0x30>
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
  80010b:	e8 3e 0a 00 00       	call   800b4e <sys_getenvid>
  800110:	25 ff 03 00 00       	and    $0x3ff,%eax
  800115:	c1 e0 07             	shl    $0x7,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 04 20 80 00       	mov    %eax,0x802004
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
  800132:	e8 86 ff ff ff       	call   8000bd <umain>
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
  80014c:	e8 ac 09 00 00       	call   800afd <sys_env_destroy>
}
  800151:	c9                   	leave  
  800152:	c3                   	ret    
	...

00800154 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	53                   	push   %ebx
  800158:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  80015b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80015e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800165:	74 16                	je     80017d <_panic+0x29>
		cprintf("%s: ", argv0);
  800167:	83 ec 08             	sub    $0x8,%esp
  80016a:	ff 35 08 20 80 00    	pushl  0x802008
  800170:	68 5e 15 80 00       	push   $0x80155e
  800175:	e8 ca 00 00 00       	call   800244 <cprintf>
  80017a:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	ff 35 00 20 80 00    	pushl  0x802000
  800189:	68 63 15 80 00       	push   $0x801563
  80018e:	e8 b1 00 00 00       	call   800244 <cprintf>
	vcprintf(fmt, ap);
  800193:	83 c4 08             	add    $0x8,%esp
  800196:	53                   	push   %ebx
  800197:	ff 75 10             	pushl  0x10(%ebp)
  80019a:	e8 54 00 00 00       	call   8001f3 <vcprintf>
	cprintf("\n");
  80019f:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  8001a6:	e8 99 00 00 00       	call   800244 <cprintf>

	// Cause a breakpoint exception
	while (1)
  8001ab:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8001ae:	cc                   	int3   
  8001af:	eb fd                	jmp    8001ae <_panic+0x5a>
}
  8001b1:	00 00                	add    %al,(%eax)
	...

008001b4 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 04             	sub    $0x4,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 03                	mov    (%ebx),%eax
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c7:	40                   	inc    %eax
  8001c8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cf:	75 1a                	jne    8001eb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	68 ff 00 00 00       	push   $0xff
  8001d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001dc:	50                   	push   %eax
  8001dd:	e8 be 08 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  8001e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001eb:	ff 43 04             	incl   0x4(%ebx)
}
  8001ee:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001fc:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  800203:	00 00 00 
	b.cnt = 0;
  800206:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  80020d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800210:	ff 75 0c             	pushl  0xc(%ebp)
  800213:	ff 75 08             	pushl  0x8(%ebp)
  800216:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  80021c:	50                   	push   %eax
  80021d:	68 b4 01 80 00       	push   $0x8001b4
  800222:	e8 83 01 00 00       	call   8003aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800227:	83 c4 08             	add    $0x8,%esp
  80022a:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800230:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800236:	50                   	push   %eax
  800237:	e8 64 08 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
  80023c:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024d:	50                   	push   %eax
  80024e:	ff 75 08             	pushl  0x8(%ebp)
  800251:	e8 9d ff ff ff       	call   8001f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	57                   	push   %edi
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	8b 75 10             	mov    0x10(%ebp),%esi
  800264:	8b 7d 14             	mov    0x14(%ebp),%edi
  800267:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026a:	8b 45 18             	mov    0x18(%ebp),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	39 d7                	cmp    %edx,%edi
  800274:	72 39                	jb     8002af <printnum+0x57>
  800276:	77 04                	ja     80027c <printnum+0x24>
  800278:	39 c6                	cmp    %eax,%esi
  80027a:	72 33                	jb     8002af <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027c:	83 ec 04             	sub    $0x4,%esp
  80027f:	ff 75 20             	pushl  0x20(%ebp)
  800282:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800285:	50                   	push   %eax
  800286:	ff 75 18             	pushl  0x18(%ebp)
  800289:	8b 45 18             	mov    0x18(%ebp),%eax
  80028c:	ba 00 00 00 00       	mov    $0x0,%edx
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	e8 a2 0f 00 00       	call   80123c <__udivdi3>
  80029a:	83 c4 10             	add    $0x10,%esp
  80029d:	52                   	push   %edx
  80029e:	50                   	push   %eax
  80029f:	ff 75 0c             	pushl  0xc(%ebp)
  8002a2:	ff 75 08             	pushl  0x8(%ebp)
  8002a5:	e8 ae ff ff ff       	call   800258 <printnum>
  8002aa:	83 c4 20             	add    $0x20,%esp
  8002ad:	eb 19                	jmp    8002c8 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002af:	4b                   	dec    %ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7e 14                	jle    8002c8 <printnum+0x70>
			putch(padc, putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ba:	ff 75 20             	pushl  0x20(%ebp)
  8002bd:	ff 55 08             	call   *0x8(%ebp)
  8002c0:	83 c4 10             	add    $0x10,%esp
  8002c3:	4b                   	dec    %ebx
  8002c4:	85 db                	test   %ebx,%ebx
  8002c6:	7f ec                	jg     8002b4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c8:	83 ec 08             	sub    $0x8,%esp
  8002cb:	ff 75 0c             	pushl  0xc(%ebp)
  8002ce:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d6:	83 ec 04             	sub    $0x4,%esp
  8002d9:	52                   	push   %edx
  8002da:	50                   	push   %eax
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	e8 7a 10 00 00       	call   80135c <__umoddi3>
  8002e2:	83 c4 14             	add    $0x14,%esp
  8002e5:	0f be 80 12 16 80 00 	movsbl 0x801612(%eax),%eax
  8002ec:	50                   	push   %eax
  8002ed:	ff 55 08             	call   *0x8(%ebp)
}
  8002f0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8002f3:	5b                   	pop    %ebx
  8002f4:	5e                   	pop    %esi
  8002f5:	5f                   	pop    %edi
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
  8002fd:	83 ec 18             	sub    $0x18,%esp
  800300:	8b 75 08             	mov    0x8(%ebp),%esi
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800306:	8a 45 18             	mov    0x18(%ebp),%al
  800309:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  80030c:	53                   	push   %ebx
  80030d:	6a 1b                	push   $0x1b
  80030f:	ff d6                	call   *%esi
	putch('[', putdat);
  800311:	83 c4 08             	add    $0x8,%esp
  800314:	53                   	push   %ebx
  800315:	6a 5b                	push   $0x5b
  800317:	ff d6                	call   *%esi
	putch('0', putdat);
  800319:	83 c4 08             	add    $0x8,%esp
  80031c:	53                   	push   %ebx
  80031d:	6a 30                	push   $0x30
  80031f:	ff d6                	call   *%esi
	putch(';', putdat);
  800321:	83 c4 08             	add    $0x8,%esp
  800324:	53                   	push   %ebx
  800325:	6a 3b                	push   $0x3b
  800327:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800329:	83 c4 0c             	add    $0xc,%esp
  80032c:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800330:	50                   	push   %eax
  800331:	ff 75 14             	pushl  0x14(%ebp)
  800334:	6a 0a                	push   $0xa
  800336:	8b 45 10             	mov    0x10(%ebp),%eax
  800339:	99                   	cltd   
  80033a:	52                   	push   %edx
  80033b:	50                   	push   %eax
  80033c:	53                   	push   %ebx
  80033d:	56                   	push   %esi
  80033e:	e8 15 ff ff ff       	call   800258 <printnum>
	putch('m', putdat);
  800343:	83 c4 18             	add    $0x18,%esp
  800346:	53                   	push   %ebx
  800347:	6a 6d                	push   $0x6d
  800349:	ff d6                	call   *%esi

}
  80034b:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	c9                   	leave  
  800351:	c3                   	ret    

00800352 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80035b:	83 f8 01             	cmp    $0x1,%eax
  80035e:	7e 0f                	jle    80036f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800360:	8b 01                	mov    (%ecx),%eax
  800362:	83 c0 08             	add    $0x8,%eax
  800365:	89 01                	mov    %eax,(%ecx)
  800367:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80036a:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80036d:	eb 0f                	jmp    80037e <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80036f:	8b 01                	mov    (%ecx),%eax
  800371:	83 c0 04             	add    $0x4,%eax
  800374:	89 01                	mov    %eax,(%ecx)
  800376:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	8b 55 08             	mov    0x8(%ebp),%edx
  800386:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800389:	83 f8 01             	cmp    $0x1,%eax
  80038c:	7e 0f                	jle    80039d <getint+0x1d>
		return va_arg(*ap, long long);
  80038e:	8b 02                	mov    (%edx),%eax
  800390:	83 c0 08             	add    $0x8,%eax
  800393:	89 02                	mov    %eax,(%edx)
  800395:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800398:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80039b:	eb 0b                	jmp    8003a8 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	83 c0 04             	add    $0x4,%eax
  8003a2:	89 02                	mov    %eax,(%edx)
  8003a4:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8003a7:	99                   	cltd   
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    

008003aa <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	57                   	push   %edi
  8003ae:	56                   	push   %esi
  8003af:	53                   	push   %ebx
  8003b0:	83 ec 1c             	sub    $0x1c,%esp
  8003b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b6:	0f b6 13             	movzbl (%ebx),%edx
  8003b9:	43                   	inc    %ebx
  8003ba:	83 fa 25             	cmp    $0x25,%edx
  8003bd:	74 1e                	je     8003dd <vprintfmt+0x33>
			if (ch == '\0')
  8003bf:	85 d2                	test   %edx,%edx
  8003c1:	0f 84 dc 02 00 00    	je     8006a3 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8003c7:	83 ec 08             	sub    $0x8,%esp
  8003ca:	ff 75 0c             	pushl  0xc(%ebp)
  8003cd:	52                   	push   %edx
  8003ce:	ff 55 08             	call   *0x8(%ebp)
  8003d1:	83 c4 10             	add    $0x10,%esp
  8003d4:	0f b6 13             	movzbl (%ebx),%edx
  8003d7:	43                   	inc    %ebx
  8003d8:	83 fa 25             	cmp    $0x25,%edx
  8003db:	75 e2                	jne    8003bf <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8003dd:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8003e1:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8003e8:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8003f2:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  8003f9:	0f b6 13             	movzbl (%ebx),%edx
  8003fc:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8003ff:	43                   	inc    %ebx
  800400:	83 f8 55             	cmp    $0x55,%eax
  800403:	0f 87 75 02 00 00    	ja     80067e <vprintfmt+0x2d4>
  800409:	ff 24 85 64 16 80 00 	jmp    *0x801664(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800410:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800414:	eb e3                	jmp    8003f9 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800416:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  80041a:	eb dd                	jmp    8003f9 <vprintfmt+0x4f>

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
  80041c:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800421:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800424:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800428:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80042b:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80042e:	83 f8 09             	cmp    $0x9,%eax
  800431:	77 27                	ja     80045a <vprintfmt+0xb0>
  800433:	43                   	inc    %ebx
  800434:	eb eb                	jmp    800421 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800436:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800440:	eb 18                	jmp    80045a <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  800442:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800446:	79 b1                	jns    8003f9 <vprintfmt+0x4f>
				width = 0;
  800448:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80044f:	eb a8                	jmp    8003f9 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800451:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800458:	eb 9f                	jmp    8003f9 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  80045a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80045e:	79 99                	jns    8003f9 <vprintfmt+0x4f>
				width = precision, precision = -1;
  800460:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800463:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800468:	eb 8f                	jmp    8003f9 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046a:	41                   	inc    %ecx
			goto reswitch;
  80046b:	eb 8c                	jmp    8003f9 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	ff 75 0c             	pushl  0xc(%ebp)
  800473:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80047d:	e9 c4 01 00 00       	jmp    800646 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  800482:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80048c:	85 c0                	test   %eax,%eax
  80048e:	79 02                	jns    800492 <vprintfmt+0xe8>
				err = -err;
  800490:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800492:	83 f8 08             	cmp    $0x8,%eax
  800495:	7f 0b                	jg     8004a2 <vprintfmt+0xf8>
  800497:	8b 3c 85 40 16 80 00 	mov    0x801640(,%eax,4),%edi
  80049e:	85 ff                	test   %edi,%edi
  8004a0:	75 08                	jne    8004aa <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  8004a2:	50                   	push   %eax
  8004a3:	68 23 16 80 00       	push   $0x801623
  8004a8:	eb 06                	jmp    8004b0 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8004aa:	57                   	push   %edi
  8004ab:	68 2c 16 80 00       	push   $0x80162c
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	ff 75 08             	pushl  0x8(%ebp)
  8004b6:	e8 f0 01 00 00       	call   8006ab <printfmt>
  8004bb:	e9 89 01 00 00       	jmp    800649 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c0:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8004ca:	85 ff                	test   %edi,%edi
  8004cc:	75 05                	jne    8004d3 <vprintfmt+0x129>
				p = "(null)";
  8004ce:	bf 2f 16 80 00       	mov    $0x80162f,%edi
			if (width > 0 && padc != '-')
  8004d3:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004d7:	7e 3b                	jle    800514 <vprintfmt+0x16a>
  8004d9:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8004dd:	74 35                	je     800514 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	56                   	push   %esi
  8004e3:	57                   	push   %edi
  8004e4:	e8 74 02 00 00       	call   80075d <strnlen>
  8004e9:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004f3:	7e 1f                	jle    800514 <vprintfmt+0x16a>
  8004f5:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8004f9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80050e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800512:	7f e8                	jg     8004fc <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800514:	0f be 17             	movsbl (%edi),%edx
  800517:	47                   	inc    %edi
  800518:	85 d2                	test   %edx,%edx
  80051a:	74 3e                	je     80055a <vprintfmt+0x1b0>
  80051c:	85 f6                	test   %esi,%esi
  80051e:	78 03                	js     800523 <vprintfmt+0x179>
  800520:	4e                   	dec    %esi
  800521:	78 37                	js     80055a <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  800523:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800527:	74 12                	je     80053b <vprintfmt+0x191>
  800529:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  80052c:	83 f8 5e             	cmp    $0x5e,%eax
  80052f:	76 0a                	jbe    80053b <vprintfmt+0x191>
					putch('?', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	ff 75 0c             	pushl  0xc(%ebp)
  800537:	6a 3f                	push   $0x3f
  800539:	eb 07                	jmp    800542 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80054b:	0f be 17             	movsbl (%edi),%edx
  80054e:	47                   	inc    %edi
  80054f:	85 d2                	test   %edx,%edx
  800551:	74 07                	je     80055a <vprintfmt+0x1b0>
  800553:	85 f6                	test   %esi,%esi
  800555:	78 cc                	js     800523 <vprintfmt+0x179>
  800557:	4e                   	dec    %esi
  800558:	79 c9                	jns    800523 <vprintfmt+0x179>
			for (; width > 0; width--)
  80055a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80055e:	0f 8e 52 fe ff ff    	jle    8003b6 <vprintfmt+0xc>
				putch(' ', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	6a 20                	push   $0x20
  80056c:	ff 55 08             	call   *0x8(%ebp)
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800575:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800579:	7f e9                	jg     800564 <vprintfmt+0x1ba>
			break;
  80057b:	e9 36 fe ff ff       	jmp    8003b6 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	51                   	push   %ecx
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	50                   	push   %eax
  800588:	e8 f3 fd ff ff       	call   800380 <getint>
  80058d:	89 c6                	mov    %eax,%esi
  80058f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	85 d2                	test   %edx,%edx
  800596:	79 15                	jns    8005ad <vprintfmt+0x203>
				putch('-', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	6a 2d                	push   $0x2d
  8005a0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a3:	f7 de                	neg    %esi
  8005a5:	83 d7 00             	adc    $0x0,%edi
  8005a8:	f7 df                	neg    %edi
  8005aa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ad:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8005b2:	eb 70                	jmp    800624 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	51                   	push   %ecx
  8005b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bb:	50                   	push   %eax
  8005bc:	e8 91 fd ff ff       	call   800352 <getuint>
  8005c1:	89 c6                	mov    %eax,%esi
  8005c3:	89 d7                	mov    %edx,%edi
			base = 10;
  8005c5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8005ca:	eb 55                	jmp    800621 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	51                   	push   %ecx
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	50                   	push   %eax
  8005d4:	e8 79 fd ff ff       	call   800352 <getuint>
  8005d9:	89 c6                	mov    %eax,%esi
  8005db:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  8005dd:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8005e2:	eb 3d                	jmp    800621 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ea:	6a 30                	push   $0x30
  8005ec:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005ef:	83 c4 08             	add    $0x8,%esp
  8005f2:	ff 75 0c             	pushl  0xc(%ebp)
  8005f5:	6a 78                	push   $0x78
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005fa:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800604:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  800609:	eb 11                	jmp    80061c <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	51                   	push   %ecx
  80060f:	8d 45 14             	lea    0x14(%ebp),%eax
  800612:	50                   	push   %eax
  800613:	e8 3a fd ff ff       	call   800352 <getuint>
  800618:	89 c6                	mov    %eax,%esi
  80061a:	89 d7                	mov    %edx,%edi
			base = 16;
  80061c:	ba 10 00 00 00       	mov    $0x10,%edx
  800621:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800624:	83 ec 04             	sub    $0x4,%esp
  800627:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80062b:	50                   	push   %eax
  80062c:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80062f:	52                   	push   %edx
  800630:	57                   	push   %edi
  800631:	56                   	push   %esi
  800632:	ff 75 0c             	pushl  0xc(%ebp)
  800635:	ff 75 08             	pushl  0x8(%ebp)
  800638:	e8 1b fc ff ff       	call   800258 <printnum>
			break;
  80063d:	eb 37                	jmp    800676 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	ff 75 0c             	pushl  0xc(%ebp)
  800645:	52                   	push   %edx
  800646:	ff 55 08             	call   *0x8(%ebp)
			break;
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	e9 65 fd ff ff       	jmp    8003b6 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	51                   	push   %ecx
  800655:	8d 45 14             	lea    0x14(%ebp),%eax
  800658:	50                   	push   %eax
  800659:	e8 f4 fc ff ff       	call   800352 <getuint>
  80065e:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800660:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80066a:	56                   	push   %esi
  80066b:	ff 75 0c             	pushl  0xc(%ebp)
  80066e:	ff 75 08             	pushl  0x8(%ebp)
  800671:	e8 82 fc ff ff       	call   8002f8 <printcolor>
			break;
  800676:	83 c4 20             	add    $0x20,%esp
  800679:	e9 38 fd ff ff       	jmp    8003b6 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	ff 75 0c             	pushl  0xc(%ebp)
  800684:	6a 25                	push   $0x25
  800686:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800689:	4b                   	dec    %ebx
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800691:	0f 84 1f fd ff ff    	je     8003b6 <vprintfmt+0xc>
  800697:	4b                   	dec    %ebx
  800698:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80069c:	75 f9                	jne    800697 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80069e:	e9 13 fd ff ff       	jmp    8003b6 <vprintfmt+0xc>
		}
	}
}
  8006a3:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8006a6:	5b                   	pop    %ebx
  8006a7:	5e                   	pop    %esi
  8006a8:	5f                   	pop    %edi
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006b4:	50                   	push   %eax
  8006b5:	ff 75 10             	pushl  0x10(%ebp)
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	ff 75 08             	pushl  0x8(%ebp)
  8006be:	e8 e7 fc ff ff       	call   8003aa <vprintfmt>
	va_end(ap);
}
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8006cb:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8006ce:	8b 0a                	mov    (%edx),%ecx
  8006d0:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8006d3:	73 07                	jae    8006dc <sprintputch+0x17>
		*b->buf++ = ch;
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	88 01                	mov    %al,(%ecx)
  8006da:	ff 02                	incl   (%edx)
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	83 ec 18             	sub    $0x18,%esp
  8006e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8006ea:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8006ed:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8006f1:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8006f4:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	74 04                	je     800703 <vsnprintf+0x25>
  8006ff:	85 c9                	test   %ecx,%ecx
  800701:	7f 07                	jg     80070a <vsnprintf+0x2c>
		return -E_INVAL;
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800708:	eb 1d                	jmp    800727 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  80070a:	ff 75 14             	pushl  0x14(%ebp)
  80070d:	ff 75 10             	pushl  0x10(%ebp)
  800710:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800713:	50                   	push   %eax
  800714:	68 c5 06 80 00       	push   $0x8006c5
  800719:	e8 8c fc ff ff       	call   8003aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071e:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800721:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800724:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800727:	c9                   	leave  
  800728:	c3                   	ret    

00800729 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800732:	50                   	push   %eax
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	ff 75 0c             	pushl  0xc(%ebp)
  800739:	ff 75 08             	pushl  0x8(%ebp)
  80073c:	e8 9d ff ff ff       	call   8006de <vsnprintf>
	va_end(ap);

	return rc;
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    
	...

00800744 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	80 3a 00             	cmpb   $0x0,(%edx)
  800752:	74 07                	je     80075b <strlen+0x17>
		n++;
  800754:	40                   	inc    %eax
  800755:	42                   	inc    %edx
  800756:	80 3a 00             	cmpb   $0x0,(%edx)
  800759:	75 f9                	jne    800754 <strlen+0x10>
	return n;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	85 d2                	test   %edx,%edx
  80076d:	74 0f                	je     80077e <strnlen+0x21>
  80076f:	80 39 00             	cmpb   $0x0,(%ecx)
  800772:	74 0a                	je     80077e <strnlen+0x21>
		n++;
  800774:	40                   	inc    %eax
  800775:	41                   	inc    %ecx
  800776:	4a                   	dec    %edx
  800777:	74 05                	je     80077e <strnlen+0x21>
  800779:	80 39 00             	cmpb   $0x0,(%ecx)
  80077c:	75 f6                	jne    800774 <strnlen+0x17>
	return n;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80078a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80078c:	8a 02                	mov    (%edx),%al
  80078e:	42                   	inc    %edx
  80078f:	88 01                	mov    %al,(%ecx)
  800791:	41                   	inc    %ecx
  800792:	84 c0                	test   %al,%al
  800794:	75 f6                	jne    80078c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800796:	89 d8                	mov    %ebx,%eax
  800798:	5b                   	pop    %ebx
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	57                   	push   %edi
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8007aa:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8007ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b1:	39 f3                	cmp    %esi,%ebx
  8007b3:	73 10                	jae    8007c5 <strncpy+0x2a>
		*dst++ = *src;
  8007b5:	8a 02                	mov    (%edx),%al
  8007b7:	88 01                	mov    %al,(%ecx)
  8007b9:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8007ba:	80 3a 00             	cmpb   $0x0,(%edx)
  8007bd:	74 01                	je     8007c0 <strncpy+0x25>
			src++;
  8007bf:	42                   	inc    %edx
  8007c0:	43                   	inc    %ebx
  8007c1:	39 f3                	cmp    %esi,%ebx
  8007c3:	72 f0                	jb     8007b5 <strncpy+0x1a>
	}
	return ret;
}
  8007c5:	89 f8                	mov    %edi,%eax
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5f                   	pop    %edi
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8007da:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 19                	je     8007f9 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8007e0:	4a                   	dec    %edx
  8007e1:	74 13                	je     8007f6 <strlcpy+0x2a>
  8007e3:	80 39 00             	cmpb   $0x0,(%ecx)
  8007e6:	74 0e                	je     8007f6 <strlcpy+0x2a>
			*dst++ = *src++;
  8007e8:	8a 01                	mov    (%ecx),%al
  8007ea:	41                   	inc    %ecx
  8007eb:	88 03                	mov    %al,(%ebx)
  8007ed:	43                   	inc    %ebx
  8007ee:	4a                   	dec    %edx
  8007ef:	74 05                	je     8007f6 <strlcpy+0x2a>
  8007f1:	80 39 00             	cmpb   $0x0,(%ecx)
  8007f4:	75 f2                	jne    8007e8 <strlcpy+0x1c>
		*dst = '\0';
  8007f6:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8007f9:	89 d8                	mov    %ebx,%eax
  8007fb:	29 f0                	sub    %esi,%eax
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
  800807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80080a:	80 3a 00             	cmpb   $0x0,(%edx)
  80080d:	74 13                	je     800822 <strcmp+0x21>
  80080f:	8a 02                	mov    (%edx),%al
  800811:	3a 01                	cmp    (%ecx),%al
  800813:	75 0d                	jne    800822 <strcmp+0x21>
		p++, q++;
  800815:	42                   	inc    %edx
  800816:	41                   	inc    %ecx
  800817:	80 3a 00             	cmpb   $0x0,(%edx)
  80081a:	74 06                	je     800822 <strcmp+0x21>
  80081c:	8a 02                	mov    (%edx),%al
  80081e:	3a 01                	cmp    (%ecx),%al
  800820:	74 f3                	je     800815 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800822:	0f b6 02             	movzbl (%edx),%eax
  800825:	0f b6 11             	movzbl (%ecx),%edx
  800828:	29 d0                	sub    %edx,%eax
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	8b 55 08             	mov    0x8(%ebp),%edx
  800833:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800836:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800839:	85 c9                	test   %ecx,%ecx
  80083b:	74 1f                	je     80085c <strncmp+0x30>
  80083d:	80 3a 00             	cmpb   $0x0,(%edx)
  800840:	74 16                	je     800858 <strncmp+0x2c>
  800842:	8a 02                	mov    (%edx),%al
  800844:	3a 03                	cmp    (%ebx),%al
  800846:	75 10                	jne    800858 <strncmp+0x2c>
		n--, p++, q++;
  800848:	42                   	inc    %edx
  800849:	43                   	inc    %ebx
  80084a:	49                   	dec    %ecx
  80084b:	74 0f                	je     80085c <strncmp+0x30>
  80084d:	80 3a 00             	cmpb   $0x0,(%edx)
  800850:	74 06                	je     800858 <strncmp+0x2c>
  800852:	8a 02                	mov    (%edx),%al
  800854:	3a 03                	cmp    (%ebx),%al
  800856:	74 f0                	je     800848 <strncmp+0x1c>
	if (n == 0)
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	75 07                	jne    800863 <strncmp+0x37>
		return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
  800861:	eb 0a                	jmp    80086d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800863:	0f b6 12             	movzbl (%edx),%edx
  800866:	0f b6 03             	movzbl (%ebx),%eax
  800869:	29 c2                	sub    %eax,%edx
  80086b:	89 d0                	mov    %edx,%eax
}
  80086d:	8b 1c 24             	mov    (%esp),%ebx
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80087b:	80 38 00             	cmpb   $0x0,(%eax)
  80087e:	74 0a                	je     80088a <strchr+0x18>
		if (*s == c)
  800880:	38 10                	cmp    %dl,(%eax)
  800882:	74 0b                	je     80088f <strchr+0x1d>
  800884:	40                   	inc    %eax
  800885:	80 38 00             	cmpb   $0x0,(%eax)
  800888:	75 f6                	jne    800880 <strchr+0xe>
			return (char *) s;
	return 0;
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088f:	c9                   	leave  
  800890:	c3                   	ret    

00800891 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80089a:	80 38 00             	cmpb   $0x0,(%eax)
  80089d:	74 0a                	je     8008a9 <strfind+0x18>
		if (*s == c)
  80089f:	38 10                	cmp    %dl,(%eax)
  8008a1:	74 06                	je     8008a9 <strfind+0x18>
  8008a3:	40                   	inc    %eax
  8008a4:	80 38 00             	cmpb   $0x0,(%eax)
  8008a7:	75 f6                	jne    80089f <strfind+0xe>
			break;
	return (char *) s;
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	57                   	push   %edi
  8008af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b5:	89 f8                	mov    %edi,%eax
  8008b7:	85 c9                	test   %ecx,%ecx
  8008b9:	74 40                	je     8008fb <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c1:	75 30                	jne    8008f3 <memset+0x48>
  8008c3:	f6 c1 03             	test   $0x3,%cl
  8008c6:	75 2b                	jne    8008f3 <memset+0x48>
		c &= 0xFF;
  8008c8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d2:	c1 e0 18             	shl    $0x18,%eax
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	c1 e2 10             	shl    $0x10,%edx
  8008db:	09 d0                	or     %edx,%eax
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e0:	c1 e2 08             	shl    $0x8,%edx
  8008e3:	09 d0                	or     %edx,%eax
  8008e5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ee:	fc                   	cld    
  8008ef:	f3 ab                	repz stos %eax,%es:(%edi)
  8008f1:	eb 06                	jmp    8008f9 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f6:	fc                   	cld    
  8008f7:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8008f9:	89 f8                	mov    %edi,%eax
}
  8008fb:	8b 3c 24             	mov    (%esp),%edi
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80090b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80090e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800910:	39 c6                	cmp    %eax,%esi
  800912:	73 33                	jae    800947 <memmove+0x47>
  800914:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800917:	39 c2                	cmp    %eax,%edx
  800919:	76 2c                	jbe    800947 <memmove+0x47>
		s += n;
  80091b:	89 d6                	mov    %edx,%esi
		d += n;
  80091d:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800920:	f6 c2 03             	test   $0x3,%dl
  800923:	75 1b                	jne    800940 <memmove+0x40>
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 13                	jne    800940 <memmove+0x40>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	83 ee 04             	sub    $0x4,%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	fd                   	std    
  80093c:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 27                	jmp    800967 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800940:	4f                   	dec    %edi
  800941:	4e                   	dec    %esi
  800942:	fd                   	std    
  800943:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800945:	eb 20                	jmp    800967 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800947:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094d:	75 15                	jne    800964 <memmove+0x64>
  80094f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800955:	75 0d                	jne    800964 <memmove+0x64>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 08                	jne    800964 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  80095c:	c1 e9 02             	shr    $0x2,%ecx
  80095f:	fc                   	cld    
  800960:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800962:	eb 03                	jmp    800967 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800964:	fc                   	cld    
  800965:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <memcpy>:

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
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800971:	ff 75 10             	pushl  0x10(%ebp)
  800974:	ff 75 0c             	pushl  0xc(%ebp)
  800977:	ff 75 08             	pushl  0x8(%ebp)
  80097a:	e8 81 ff ff ff       	call   800900 <memmove>
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	53                   	push   %ebx
  800985:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800988:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  80098b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  80098e:	89 d0                	mov    %edx,%eax
  800990:	4a                   	dec    %edx
  800991:	85 c0                	test   %eax,%eax
  800993:	74 1b                	je     8009b0 <memcmp+0x2f>
		if (*s1 != *s2)
  800995:	8a 01                	mov    (%ecx),%al
  800997:	3a 03                	cmp    (%ebx),%al
  800999:	74 0c                	je     8009a7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099b:	0f b6 d0             	movzbl %al,%edx
  80099e:	0f b6 03             	movzbl (%ebx),%eax
  8009a1:	29 c2                	sub    %eax,%edx
  8009a3:	89 d0                	mov    %edx,%eax
  8009a5:	eb 0e                	jmp    8009b5 <memcmp+0x34>
		s1++, s2++;
  8009a7:	41                   	inc    %ecx
  8009a8:	43                   	inc    %ebx
  8009a9:	89 d0                	mov    %edx,%eax
  8009ab:	4a                   	dec    %edx
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	75 e5                	jne    800995 <memcmp+0x14>
	}

	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c6:	39 d0                	cmp    %edx,%eax
  8009c8:	73 09                	jae    8009d3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ca:	38 08                	cmp    %cl,(%eax)
  8009cc:	74 05                	je     8009d3 <memfind+0x1b>
  8009ce:	40                   	inc    %eax
  8009cf:	39 d0                	cmp    %edx,%eax
  8009d1:	72 f7                	jb     8009ca <memfind+0x12>
			break;
	return (void *) s;
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 55 08             	mov    0x8(%ebp),%edx
  8009de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8009e9:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	80 3a 20             	cmpb   $0x20,(%edx)
  8009f1:	74 05                	je     8009f8 <strtol+0x23>
  8009f3:	80 3a 09             	cmpb   $0x9,(%edx)
  8009f6:	75 0b                	jne    800a03 <strtol+0x2e>
		s++;
  8009f8:	42                   	inc    %edx
  8009f9:	80 3a 20             	cmpb   $0x20,(%edx)
  8009fc:	74 fa                	je     8009f8 <strtol+0x23>
  8009fe:	80 3a 09             	cmpb   $0x9,(%edx)
  800a01:	74 f5                	je     8009f8 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800a03:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800a06:	75 03                	jne    800a0b <strtol+0x36>
		s++;
  800a08:	42                   	inc    %edx
  800a09:	eb 0b                	jmp    800a16 <strtol+0x41>
	else if (*s == '-')
  800a0b:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800a0e:	75 06                	jne    800a16 <strtol+0x41>
		s++, neg = 1;
  800a10:	42                   	inc    %edx
  800a11:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a16:	85 c9                	test   %ecx,%ecx
  800a18:	74 05                	je     800a1f <strtol+0x4a>
  800a1a:	83 f9 10             	cmp    $0x10,%ecx
  800a1d:	75 15                	jne    800a34 <strtol+0x5f>
  800a1f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a22:	75 10                	jne    800a34 <strtol+0x5f>
  800a24:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a28:	75 0a                	jne    800a34 <strtol+0x5f>
		s += 2, base = 16;
  800a2a:	83 c2 02             	add    $0x2,%edx
  800a2d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a32:	eb 1a                	jmp    800a4e <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800a34:	85 c9                	test   %ecx,%ecx
  800a36:	75 16                	jne    800a4e <strtol+0x79>
  800a38:	80 3a 30             	cmpb   $0x30,(%edx)
  800a3b:	75 08                	jne    800a45 <strtol+0x70>
		s++, base = 8;
  800a3d:	42                   	inc    %edx
  800a3e:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a43:	eb 09                	jmp    800a4e <strtol+0x79>
	else if (base == 0)
  800a45:	85 c9                	test   %ecx,%ecx
  800a47:	75 05                	jne    800a4e <strtol+0x79>
		base = 10;
  800a49:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4e:	8a 02                	mov    (%edx),%al
  800a50:	83 e8 30             	sub    $0x30,%eax
  800a53:	3c 09                	cmp    $0x9,%al
  800a55:	77 08                	ja     800a5f <strtol+0x8a>
			dig = *s - '0';
  800a57:	0f be 02             	movsbl (%edx),%eax
  800a5a:	83 e8 30             	sub    $0x30,%eax
  800a5d:	eb 20                	jmp    800a7f <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800a5f:	8a 02                	mov    (%edx),%al
  800a61:	83 e8 61             	sub    $0x61,%eax
  800a64:	3c 19                	cmp    $0x19,%al
  800a66:	77 08                	ja     800a70 <strtol+0x9b>
			dig = *s - 'a' + 10;
  800a68:	0f be 02             	movsbl (%edx),%eax
  800a6b:	83 e8 57             	sub    $0x57,%eax
  800a6e:	eb 0f                	jmp    800a7f <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800a70:	8a 02                	mov    (%edx),%al
  800a72:	83 e8 41             	sub    $0x41,%eax
  800a75:	3c 19                	cmp    $0x19,%al
  800a77:	77 12                	ja     800a8b <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a79:	0f be 02             	movsbl (%edx),%eax
  800a7c:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a7f:	39 c8                	cmp    %ecx,%eax
  800a81:	7d 08                	jge    800a8b <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a83:	42                   	inc    %edx
  800a84:	0f af d9             	imul   %ecx,%ebx
  800a87:	01 c3                	add    %eax,%ebx
  800a89:	eb c3                	jmp    800a4e <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8b:	85 f6                	test   %esi,%esi
  800a8d:	74 02                	je     800a91 <strtol+0xbc>
		*endptr = (char *) s;
  800a8f:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a91:	89 d8                	mov    %ebx,%eax
  800a93:	85 ff                	test   %edi,%edi
  800a95:	74 02                	je     800a99 <strtol+0xc4>
  800a97:	f7 d8                	neg    %eax
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    
	...

00800aa0 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aac:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab1:	89 f8                	mov    %edi,%eax
  800ab3:	89 fb                	mov    %edi,%ebx
  800ab5:	89 fe                	mov    %edi,%esi
  800ab7:	55                   	push   %ebp
  800ab8:	9c                   	pushf  
  800ab9:	56                   	push   %esi
  800aba:	54                   	push   %esp
  800abb:	5d                   	pop    %ebp
  800abc:	8d 35 c4 0a 80 00    	lea    0x800ac4,%esi
  800ac2:	0f 34                	sysenter 
  800ac4:	83 c4 04             	add    $0x4,%esp
  800ac7:	9d                   	popf   
  800ac8:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <sys_cgetc>:

int
sys_cgetc(void)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ade:	89 fa                	mov    %edi,%edx
  800ae0:	89 f9                	mov    %edi,%ecx
  800ae2:	89 fb                	mov    %edi,%ebx
  800ae4:	89 fe                	mov    %edi,%esi
  800ae6:	55                   	push   %ebp
  800ae7:	9c                   	pushf  
  800ae8:	56                   	push   %esi
  800ae9:	54                   	push   %esp
  800aea:	5d                   	pop    %ebp
  800aeb:	8d 35 f3 0a 80 00    	lea    0x800af3,%esi
  800af1:	0f 34                	sysenter 
  800af3:	83 c4 04             	add    $0x4,%esp
  800af6:	9d                   	popf   
  800af7:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b13:	89 f9                	mov    %edi,%ecx
  800b15:	89 fb                	mov    %edi,%ebx
  800b17:	89 fe                	mov    %edi,%esi
  800b19:	55                   	push   %ebp
  800b1a:	9c                   	pushf  
  800b1b:	56                   	push   %esi
  800b1c:	54                   	push   %esp
  800b1d:	5d                   	pop    %ebp
  800b1e:	8d 35 26 0b 80 00    	lea    0x800b26,%esi
  800b24:	0f 34                	sysenter 
  800b26:	83 c4 04             	add    $0x4,%esp
  800b29:	9d                   	popf   
  800b2a:	5d                   	pop    %ebp
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 17                	jle    800b46 <sys_env_destroy+0x49>
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	50                   	push   %eax
  800b33:	6a 03                	push   $0x3
  800b35:	68 bc 17 80 00       	push   $0x8017bc
  800b3a:	6a 4c                	push   $0x4c
  800b3c:	68 d9 17 80 00       	push   $0x8017d9
  800b41:	e8 0e f6 ff ff       	call   800154 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b46:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	b8 02 00 00 00       	mov    $0x2,%eax
  800b59:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5e:	89 fa                	mov    %edi,%edx
  800b60:	89 f9                	mov    %edi,%ecx
  800b62:	89 fb                	mov    %edi,%ebx
  800b64:	89 fe                	mov    %edi,%esi
  800b66:	55                   	push   %ebp
  800b67:	9c                   	pushf  
  800b68:	56                   	push   %esi
  800b69:	54                   	push   %esp
  800b6a:	5d                   	pop    %ebp
  800b6b:	8d 35 73 0b 80 00    	lea    0x800b73,%esi
  800b71:	0f 34                	sysenter 
  800b73:	83 c4 04             	add    $0x4,%esp
  800b76:	9d                   	popf   
  800b77:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <sys_dump_env>:

int
sys_dump_env(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	b8 04 00 00 00       	mov    $0x4,%eax
  800b88:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8d:	89 fa                	mov    %edi,%edx
  800b8f:	89 f9                	mov    %edi,%ecx
  800b91:	89 fb                	mov    %edi,%ebx
  800b93:	89 fe                	mov    %edi,%esi
  800b95:	55                   	push   %ebp
  800b96:	9c                   	pushf  
  800b97:	56                   	push   %esi
  800b98:	54                   	push   %esp
  800b99:	5d                   	pop    %ebp
  800b9a:	8d 35 a2 0b 80 00    	lea    0x800ba2,%esi
  800ba0:	0f 34                	sysenter 
  800ba2:	83 c4 04             	add    $0x4,%esp
  800ba5:	9d                   	popf   
  800ba6:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    

00800bac <sys_yield>:

void
sys_yield(void)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bb7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbc:	89 fa                	mov    %edi,%edx
  800bbe:	89 f9                	mov    %edi,%ecx
  800bc0:	89 fb                	mov    %edi,%ebx
  800bc2:	89 fe                	mov    %edi,%esi
  800bc4:	55                   	push   %ebp
  800bc5:	9c                   	pushf  
  800bc6:	56                   	push   %esi
  800bc7:	54                   	push   %esp
  800bc8:	5d                   	pop    %ebp
  800bc9:	8d 35 d1 0b 80 00    	lea    0x800bd1,%esi
  800bcf:	0f 34                	sysenter 
  800bd1:	83 c4 04             	add    $0x4,%esp
  800bd4:	9d                   	popf   
  800bd5:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bed:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf7:	89 fe                	mov    %edi,%esi
  800bf9:	55                   	push   %ebp
  800bfa:	9c                   	pushf  
  800bfb:	56                   	push   %esi
  800bfc:	54                   	push   %esp
  800bfd:	5d                   	pop    %ebp
  800bfe:	8d 35 06 0c 80 00    	lea    0x800c06,%esi
  800c04:	0f 34                	sysenter 
  800c06:	83 c4 04             	add    $0x4,%esp
  800c09:	9d                   	popf   
  800c0a:	5d                   	pop    %ebp
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 17                	jle    800c26 <sys_page_alloc+0x4b>
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 05                	push   $0x5
  800c15:	68 bc 17 80 00       	push   $0x8017bc
  800c1a:	6a 4c                	push   $0x4c
  800c1c:	68 d9 17 80 00       	push   $0x8017d9
  800c21:	e8 2e f5 ff ff       	call   800154 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c26:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c40:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c43:	8b 75 18             	mov    0x18(%ebp),%esi
  800c46:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4b:	55                   	push   %ebp
  800c4c:	9c                   	pushf  
  800c4d:	56                   	push   %esi
  800c4e:	54                   	push   %esp
  800c4f:	5d                   	pop    %ebp
  800c50:	8d 35 58 0c 80 00    	lea    0x800c58,%esi
  800c56:	0f 34                	sysenter 
  800c58:	83 c4 04             	add    $0x4,%esp
  800c5b:	9d                   	popf   
  800c5c:	5d                   	pop    %ebp
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_map+0x4a>
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 bc 17 80 00       	push   $0x8017bc
  800c6c:	6a 4c                	push   $0x4c
  800c6e:	68 d9 17 80 00       	push   $0x8017d9
  800c73:	e8 dc f4 ff ff       	call   800154 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800c78:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	c9                   	leave  
  800c7f:	c3                   	ret    

00800c80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	b8 07 00 00 00       	mov    $0x7,%eax
  800c94:	bf 00 00 00 00       	mov    $0x0,%edi
  800c99:	89 fb                	mov    %edi,%ebx
  800c9b:	89 fe                	mov    %edi,%esi
  800c9d:	55                   	push   %ebp
  800c9e:	9c                   	pushf  
  800c9f:	56                   	push   %esi
  800ca0:	54                   	push   %esp
  800ca1:	5d                   	pop    %ebp
  800ca2:	8d 35 aa 0c 80 00    	lea    0x800caa,%esi
  800ca8:	0f 34                	sysenter 
  800caa:	83 c4 04             	add    $0x4,%esp
  800cad:	9d                   	popf   
  800cae:	5d                   	pop    %ebp
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 17                	jle    800cca <sys_page_unmap+0x4a>
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 07                	push   $0x7
  800cb9:	68 bc 17 80 00       	push   $0x8017bc
  800cbe:	6a 4c                	push   $0x4c
  800cc0:	68 d9 17 80 00       	push   $0x8017d9
  800cc5:	e8 8a f4 ff ff       	call   800154 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cca:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    

00800cd2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ceb:	89 fb                	mov    %edi,%ebx
  800ced:	89 fe                	mov    %edi,%esi
  800cef:	55                   	push   %ebp
  800cf0:	9c                   	pushf  
  800cf1:	56                   	push   %esi
  800cf2:	54                   	push   %esp
  800cf3:	5d                   	pop    %ebp
  800cf4:	8d 35 fc 0c 80 00    	lea    0x800cfc,%esi
  800cfa:	0f 34                	sysenter 
  800cfc:	83 c4 04             	add    $0x4,%esp
  800cff:	9d                   	popf   
  800d00:	5d                   	pop    %ebp
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_env_set_status+0x4a>
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 09                	push   $0x9
  800d0b:	68 bc 17 80 00       	push   $0x8017bc
  800d10:	6a 4c                	push   $0x4c
  800d12:	68 d9 17 80 00       	push   $0x8017d9
  800d17:	e8 38 f4 ff ff       	call   800154 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d38:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3d:	89 fb                	mov    %edi,%ebx
  800d3f:	89 fe                	mov    %edi,%esi
  800d41:	55                   	push   %ebp
  800d42:	9c                   	pushf  
  800d43:	56                   	push   %esi
  800d44:	54                   	push   %esp
  800d45:	5d                   	pop    %ebp
  800d46:	8d 35 4e 0d 80 00    	lea    0x800d4e,%esi
  800d4c:	0f 34                	sysenter 
  800d4e:	83 c4 04             	add    $0x4,%esp
  800d51:	9d                   	popf   
  800d52:	5d                   	pop    %ebp
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 17                	jle    800d6e <sys_env_set_trapframe+0x4a>
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	50                   	push   %eax
  800d5b:	6a 0a                	push   $0xa
  800d5d:	68 bc 17 80 00       	push   $0x8017bc
  800d62:	6a 4c                	push   $0x4c
  800d64:	68 d9 17 80 00       	push   $0x8017d9
  800d69:	e8 e6 f3 ff ff       	call   800154 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d6e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	c9                   	leave  
  800d75:	c3                   	ret    

00800d76 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d8f:	89 fb                	mov    %edi,%ebx
  800d91:	89 fe                	mov    %edi,%esi
  800d93:	55                   	push   %ebp
  800d94:	9c                   	pushf  
  800d95:	56                   	push   %esi
  800d96:	54                   	push   %esp
  800d97:	5d                   	pop    %ebp
  800d98:	8d 35 a0 0d 80 00    	lea    0x800da0,%esi
  800d9e:	0f 34                	sysenter 
  800da0:	83 c4 04             	add    $0x4,%esp
  800da3:	9d                   	popf   
  800da4:	5d                   	pop    %ebp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_env_set_pgfault_upcall+0x4a>
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 0b                	push   $0xb
  800daf:	68 bc 17 80 00       	push   $0x8017bc
  800db4:	6a 4c                	push   $0x4c
  800db6:	68 d9 17 80 00       	push   $0x8017d9
  800dbb:	e8 94 f3 ff ff       	call   800154 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddf:	be 00 00 00 00       	mov    $0x0,%esi
  800de4:	55                   	push   %ebp
  800de5:	9c                   	pushf  
  800de6:	56                   	push   %esi
  800de7:	54                   	push   %esp
  800de8:	5d                   	pop    %ebp
  800de9:	8d 35 f1 0d 80 00    	lea    0x800df1,%esi
  800def:	0f 34                	sysenter 
  800df1:	83 c4 04             	add    $0x4,%esp
  800df4:	9d                   	popf   
  800df5:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e11:	89 f9                	mov    %edi,%ecx
  800e13:	89 fb                	mov    %edi,%ebx
  800e15:	89 fe                	mov    %edi,%esi
  800e17:	55                   	push   %ebp
  800e18:	9c                   	pushf  
  800e19:	56                   	push   %esi
  800e1a:	54                   	push   %esp
  800e1b:	5d                   	pop    %ebp
  800e1c:	8d 35 24 0e 80 00    	lea    0x800e24,%esi
  800e22:	0f 34                	sysenter 
  800e24:	83 c4 04             	add    $0x4,%esp
  800e27:	9d                   	popf   
  800e28:	5d                   	pop    %ebp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_ipc_recv+0x49>
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 0e                	push   $0xe
  800e33:	68 bc 17 80 00       	push   $0x8017bc
  800e38:	6a 4c                	push   $0x4c
  800e3a:	68 d9 17 80 00       	push   $0x8017d9
  800e3f:	e8 10 f3 ff ff       	call   800154 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <pgfault>:
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
    void *addr = (void *) utf->utf_fault_va;
  800e56:	8b 1a                	mov    (%edx),%ebx
    uint32_t err = utf->utf_err;
  800e58:	8b 42 04             	mov    0x4(%edx),%eax
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
  800e5b:	a8 02                	test   $0x2,%al
  800e5d:	0f 84 ae 00 00 00    	je     800f11 <pgfault+0xc5>
        //cprintf("it's caused by fault write\n");
        if (vpt[PPN(addr)] & PTE_COW) {//first
  800e63:	89 d8                	mov    %ebx,%eax
  800e65:	c1 e8 0c             	shr    $0xc,%eax
  800e68:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  800e6f:	f6 c4 08             	test   $0x8,%ah
  800e72:	0f 84 85 00 00 00    	je     800efd <pgfault+0xb1>
            //ok it's caused by copy on write
            //cprintf("it's caused by copy on write\n");
            if ((r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W))) {//wrong not ROUNDDOWN(addr,PGSIZE)
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	6a 07                	push   $0x7
  800e7d:	68 00 f0 7f 00       	push   $0x7ff000
  800e82:	6a 00                	push   $0x0
  800e84:	e8 52 fd ff ff       	call   800bdb <sys_page_alloc>
  800e89:	83 c4 10             	add    $0x10,%esp
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	74 0a                	je     800e9a <pgfault+0x4e>
                panic("pgfault->sys_page_alloc:%e",r);
  800e90:	50                   	push   %eax
  800e91:	68 e7 17 80 00       	push   $0x8017e7
  800e96:	6a 2f                	push   $0x2f
  800e98:	eb 6d                	jmp    800f07 <pgfault+0xbb>
            }
            //cprintf("before copy data from ROUNDDOWN(%x,PGSIZE) to PFTEMP\n",addr);
            memcpy(PFTEMP,ROUNDDOWN(addr,PGSIZE),PGSIZE);
  800e9a:	89 d8                	mov    %ebx,%eax
  800e9c:	25 ff 0f 00 00       	and    $0xfff,%eax
  800ea1:	29 c3                	sub    %eax,%ebx
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	68 00 10 00 00       	push   $0x1000
  800eab:	53                   	push   %ebx
  800eac:	68 00 f0 7f 00       	push   $0x7ff000
  800eb1:	e8 b5 fa ff ff       	call   80096b <memcpy>
            //cprintf("before map the PFTEMP to the ROUNDDOWN(%x,PGSIZE)\n",addr);
            if ((r= sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_P|PTE_U|PTE_W))) {/*seemly than PTE_USER is wrong*/
  800eb6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ebd:	53                   	push   %ebx
  800ebe:	6a 00                	push   $0x0
  800ec0:	68 00 f0 7f 00       	push   $0x7ff000
  800ec5:	6a 00                	push   $0x0
  800ec7:	e8 62 fd ff ff       	call   800c2e <sys_page_map>
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	74 0a                	je     800edd <pgfault+0x91>
                panic("pgfault->sys_page_map:%e",r);
  800ed3:	50                   	push   %eax
  800ed4:	68 02 18 80 00       	push   $0x801802
  800ed9:	6a 35                	push   $0x35
  800edb:	eb 2a                	jmp    800f07 <pgfault+0xbb>
            }
            //cprintf("before unmap the PFTEMP\n");
            if ((r = sys_page_unmap(0,PFTEMP))) {
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	68 00 f0 7f 00       	push   $0x7ff000
  800ee5:	6a 00                	push   $0x0
  800ee7:	e8 94 fd ff ff       	call   800c80 <sys_page_unmap>
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	74 37                	je     800f2a <pgfault+0xde>
                panic("pgfault->sys_page_unmap:%e",r);
  800ef3:	50                   	push   %eax
  800ef4:	68 1b 18 80 00       	push   $0x80181b
  800ef9:	6a 39                	push   $0x39
  800efb:	eb 0a                	jmp    800f07 <pgfault+0xbb>
            }
            //cprintf("after unmap the PFTEMP\n");
        } else {
            panic("the fault write page is not copy on write\n");
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	68 9c 18 80 00       	push   $0x80189c
  800f05:	6a 3d                	push   $0x3d
  800f07:	68 36 18 80 00       	push   $0x801836
  800f0c:	e8 43 f2 ff ff       	call   800154 <_panic>
        }
    } else {
        panic("the fault page isn't fault write,%eip is %x,va is %x,errcode is %d",utf->utf_eip,addr,err);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	50                   	push   %eax
  800f15:	53                   	push   %ebx
  800f16:	ff 72 28             	pushl  0x28(%edx)
  800f19:	68 c8 18 80 00       	push   $0x8018c8
  800f1e:	6a 40                	push   $0x40
  800f20:	68 36 18 80 00       	push   $0x801836
  800f25:	e8 2a f2 ff ff       	call   800154 <_panic>
    }
    //it should be ok
    //panic("pgfault not implemented");
}
  800f2a:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <duppage>:

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
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f37:	8b 45 0c             	mov    0xc(%ebp),%eax
    int r;
    void *addr;
    pte_t pte;
    pte = vpt[pn];//current env's page table entry
  800f3a:	8b 14 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%edx
    addr = (void *) (pn*PGSIZE);//virtual address
  800f41:	89 c6                	mov    %eax,%esi
  800f43:	c1 e6 0c             	shl    $0xc,%esi
    uint32_t perm = pte & PTE_USER;
  800f46:	89 d3                	mov    %edx,%ebx
  800f48:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
    /*if((uint32_t)addr == USTACKTOP-PGSIZE) {
        cprintf("duppage user stack!!!!!!!!!!\n");
    }*/
    if ((pte & PTE_COW)|(pte & PTE_W)) {
  800f4e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f54:	74 26                	je     800f7c <duppage+0x4d>
        /*the page need copy on write*/
        perm |= PTE_COW;
  800f56:	80 cf 08             	or     $0x8,%bh
        perm &= ~PTE_W;
  800f59:	83 e3 fd             	and    $0xfffffffd,%ebx
        if ((r = sys_page_map(0,addr,envid,addr,perm))) {
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	53                   	push   %ebx
  800f60:	56                   	push   %esi
  800f61:	51                   	push   %ecx
  800f62:	56                   	push   %esi
  800f63:	6a 00                	push   $0x0
  800f65:	e8 c4 fc ff ff       	call   800c2e <sys_page_map>
  800f6a:	83 c4 20             	add    $0x20,%esp
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	75 19                	jne    800f8c <duppage+0x5d>
            return r;
        }
        return sys_page_map(0,addr,0,addr,perm);//also remap it
  800f73:	83 ec 0c             	sub    $0xc,%esp
  800f76:	53                   	push   %ebx
  800f77:	56                   	push   %esi
  800f78:	6a 00                	push   $0x0
  800f7a:	eb 06                	jmp    800f82 <duppage+0x53>
        /*now the page can't be writen*/
    }
    // LAB 4: Your code here.
    //panic("duppage not implemented");
    //may be wrong, it's not writable so just map it,although it may be no safe
    return sys_page_map(0, addr, envid, addr, perm);
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	53                   	push   %ebx
  800f80:	56                   	push   %esi
  800f81:	51                   	push   %ecx
  800f82:	56                   	push   %esi
  800f83:	6a 00                	push   $0x0
  800f85:	e8 a4 fc ff ff       	call   800c2e <sys_page_map>
  800f8a:	89 c2                	mov    %eax,%edx
}
  800f8c:	89 d0                	mov    %edx,%eax
  800f8e:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <fork>:

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
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 18             	sub    $0x18,%esp
    // LAB 4: Your code here.
    int pde_index;
    int pte_index;
    envid_t envid;
    unsigned pn = 0;
  800f9e:	be 00 00 00 00       	mov    $0x0,%esi
    int r;
    set_pgfault_handler(pgfault);/*set the pgfault handler for the father*/
  800fa3:	68 4c 0e 80 00       	push   $0x800e4c
  800fa8:	e8 23 02 00 00       	call   8011d0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
  800fad:	83 c4 10             	add    $0x10,%esp
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
  800fb0:	ba 08 00 00 00       	mov    $0x8,%edx
  800fb5:	89 d0                	mov    %edx,%eax
  800fb7:	cd 30                	int    $0x30
  800fb9:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
    //cprintf("in fork before sys_exofork\n");
    envid = sys_exofork();//it use int to syscall
    //the child will come back use iret
    //cprintf("after fork->sys_exofork return:%d\n",envid);
    if (envid < 0) {
  800fbc:	89 c2                	mov    %eax,%edx
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	0f 88 f4 00 00 00    	js     8010ba <fork+0x125>
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
  800fc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800fcb:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800fcf:	75 21                	jne    800ff2 <fork+0x5d>
  800fd1:	e8 78 fb ff ff       	call   800b4e <sys_getenvid>
  800fd6:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fdb:	c1 e0 07             	shl    $0x7,%eax
  800fde:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe3:	a3 04 20 80 00       	mov    %eax,0x802004
  800fe8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fed:	e9 c8 00 00 00       	jmp    8010ba <fork+0x125>
        /*upper than utop,such map has already done*/
        if (vpd[pde_index]) {
  800ff2:	8b 04 bd 00 d0 7b ef 	mov    0xef7bd000(,%edi,4),%eax
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	74 48                	je     801045 <fork+0xb0>
            for (pte_index = 0;pte_index < NPTENTRIES;pte_index++) {
  800ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
                if (vpt[pn]&& (pn*PGSIZE) != (UXSTACKTOP - PGSIZE)) {
  801002:	8b 04 b5 00 00 40 ef 	mov    0xef400000(,%esi,4),%eax
  801009:	85 c0                	test   %eax,%eax
  80100b:	74 2c                	je     801039 <fork+0xa4>
  80100d:	89 f0                	mov    %esi,%eax
  80100f:	c1 e0 0c             	shl    $0xc,%eax
  801012:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  801017:	74 20                	je     801039 <fork+0xa4>
                    /*if the pte is not null and it's not pgfault stack*/
                    if ((r = duppage(envid,pn)))
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	56                   	push   %esi
  80101d:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801020:	e8 0a ff ff ff       	call   800f2f <duppage>
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	74 0d                	je     801039 <fork+0xa4>
                        panic("in duppage:%e",r);
  80102c:	50                   	push   %eax
  80102d:	68 41 18 80 00       	push   $0x801841
  801032:	68 9e 00 00 00       	push   $0x9e
  801037:	eb 77                	jmp    8010b0 <fork+0x11b>
                }
                pn++;
  801039:	46                   	inc    %esi
  80103a:	43                   	inc    %ebx
  80103b:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  801041:	7e bf                	jle    801002 <fork+0x6d>
  801043:	eb 06                	jmp    80104b <fork+0xb6>
            }
        } else {
            pn += NPTENTRIES;/*skip 1024 virtual page*/
  801045:	81 c6 00 04 00 00    	add    $0x400,%esi
  80104b:	47                   	inc    %edi
  80104c:	81 ff ba 03 00 00    	cmp    $0x3ba,%edi
  801052:	76 9e                	jbe    800ff2 <fork+0x5d>
        }
    }
    //cprintf("after parent map for child\n");
    /*set the pgfault handler for child*/
    //cprintf("after set the pgfault handler\n");
    if ((r = sys_page_alloc(envid,(void *)(UXSTACKTOP - PGSIZE),PTE_P|PTE_U|PTE_W))) {
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	6a 07                	push   $0x7
  801059:	68 00 f0 bf ee       	push   $0xeebff000
  80105e:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801061:	e8 75 fb ff ff       	call   800bdb <sys_page_alloc>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	74 0d                	je     80107a <fork+0xe5>
        panic("in fork->sys_page_alloc %e",r);
  80106d:	50                   	push   %eax
  80106e:	68 4f 18 80 00       	push   $0x80184f
  801073:	68 aa 00 00 00       	push   $0xaa
  801078:	eb 36                	jmp    8010b0 <fork+0x11b>
    }
    //cprintf("before set the pgfault up call for child\n");
    //cprintf("env->env_pgfault_upcall:%x\n",env->env_pgfault_upcall);
    sys_env_set_pgfault_upcall(envid,env->env_pgfault_upcall);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	a1 04 20 80 00       	mov    0x802004,%eax
  801082:	8b 40 68             	mov    0x68(%eax),%eax
  801085:	50                   	push   %eax
  801086:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801089:	e8 e8 fc ff ff       	call   800d76 <sys_env_set_pgfault_upcall>
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE))) {
  80108e:	83 c4 08             	add    $0x8,%esp
  801091:	6a 01                	push   $0x1
  801093:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801096:	e8 37 fc ff ff       	call   800cd2 <sys_env_set_status>
  80109b:	83 c4 10             	add    $0x10,%esp
        panic("in fork->sys_env_status %e",r);
    }
    //cprintf("fork ok %d\n",sys_getenvid());
    return envid;
  80109e:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	74 15                	je     8010ba <fork+0x125>
  8010a5:	50                   	push   %eax
  8010a6:	68 6a 18 80 00       	push   $0x80186a
  8010ab:	68 b0 00 00 00       	push   $0xb0
  8010b0:	68 36 18 80 00       	push   $0x801836
  8010b5:	e8 9a f0 ff ff       	call   800154 <_panic>
    //panic("fork not implemented");
}
  8010ba:	89 d0                	mov    %edx,%eax
  8010bc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 0c             	sub    $0xc,%esp
    panic("sfork not implemented");
  8010ca:	68 85 18 80 00       	push   $0x801885
  8010cf:	68 bb 00 00 00       	push   $0xbb
  8010d4:	68 36 18 80 00       	push   $0x801836
  8010d9:	e8 76 f0 ff ff       	call   800154 <_panic>
	...

008010e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010eb:	8b 75 10             	mov    0x10(%ebp),%esi
    // LAB 4: Your code here.
    //cprintf("env:%d is recieving\n",env->env_id);
    int r;
    if (!pg) {
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	75 05                	jne    8010f7 <ipc_recv+0x17>
        /*the reciever need an integer not a page*/
        pg = (void*)UTOP;
  8010f2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
    }
    if ((r = sys_ipc_recv(pg))) {
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	50                   	push   %eax
  8010fb:	e8 fb fc ff ff       	call   800dfb <sys_ipc_recv>
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	74 16                	je     80111d <ipc_recv+0x3d>
        if (from_env_store) {
  801107:	85 db                	test   %ebx,%ebx
  801109:	74 06                	je     801111 <ipc_recv+0x31>
            *from_env_store = 0;
  80110b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        }
        if (perm_store) {
  801111:	85 f6                	test   %esi,%esi
  801113:	74 48                	je     80115d <ipc_recv+0x7d>
            *perm_store = 0;
  801115:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        }
        return r;
  80111b:	eb 40                	jmp    80115d <ipc_recv+0x7d>
    }
    if (from_env_store) {
  80111d:	85 db                	test   %ebx,%ebx
  80111f:	74 0a                	je     80112b <ipc_recv+0x4b>
        *from_env_store = env->env_ipc_from;
  801121:	a1 04 20 80 00       	mov    0x802004,%eax
  801126:	8b 40 78             	mov    0x78(%eax),%eax
  801129:	89 03                	mov    %eax,(%ebx)
    }
    if (perm_store) {
  80112b:	85 f6                	test   %esi,%esi
  80112d:	74 0a                	je     801139 <ipc_recv+0x59>
        *perm_store = env->env_ipc_perm;
  80112f:	a1 04 20 80 00       	mov    0x802004,%eax
  801134:	8b 40 7c             	mov    0x7c(%eax),%eax
  801137:	89 06                	mov    %eax,(%esi)
    }
    cprintf("from env %d to env %d,recieve ok,value:%d\n",env->env_ipc_from,env->env_id,env->env_ipc_value);
  801139:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80113f:	8b 42 74             	mov    0x74(%edx),%eax
  801142:	50                   	push   %eax
  801143:	8b 42 4c             	mov    0x4c(%edx),%eax
  801146:	50                   	push   %eax
  801147:	8b 42 78             	mov    0x78(%edx),%eax
  80114a:	50                   	push   %eax
  80114b:	68 0c 19 80 00       	push   $0x80190c
  801150:	e8 ef f0 ff ff       	call   800244 <cprintf>
    return env->env_ipc_value;
  801155:	a1 04 20 80 00       	mov    0x802004,%eax
  80115a:	8b 40 74             	mov    0x74(%eax),%eax
    panic("ipc_recv not implemented");
    return 0;
}
  80115d:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <ipc_send>:

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
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 0c             	sub    $0xc,%esp
  80116d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801170:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801173:	8b 75 14             	mov    0x14(%ebp),%esi
    // LAB 4: Your code here.
    int r;
    while (1) {
        if(!pg) {
  801176:	85 db                	test   %ebx,%ebx
  801178:	75 05                	jne    80117f <ipc_send+0x1b>
            pg = (void*)UTOP;
  80117a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
        }
        r = sys_ipc_try_send(to_env,val,pg,perm);
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	57                   	push   %edi
  801182:	ff 75 08             	pushl  0x8(%ebp)
  801185:	e8 3e fc ff ff       	call   800dc8 <sys_ipc_try_send>
        if (r == 0 || r == 1) {
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	83 f8 01             	cmp    $0x1,%eax
  801190:	76 1e                	jbe    8011b0 <ipc_send+0x4c>
            break;
        } else if (r != -E_IPC_NOT_RECV) {
  801192:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801195:	74 12                	je     8011a9 <ipc_send+0x45>
            /*unknown err*/
            panic("ipc_send not ok: %e\n",r);
  801197:	50                   	push   %eax
  801198:	68 5b 19 80 00       	push   $0x80195b
  80119d:	6a 46                	push   $0x46
  80119f:	68 70 19 80 00       	push   $0x801970
  8011a4:	e8 ab ef ff ff       	call   800154 <_panic>
        }
        sys_yield();
  8011a9:	e8 fe f9 ff ff       	call   800bac <sys_yield>
  8011ae:	eb c6                	jmp    801176 <ipc_send+0x12>
    }
    cprintf("env %d to env %d send ok,value:%d\n",env->env_id,to_env,val);
  8011b0:	57                   	push   %edi
  8011b1:	ff 75 08             	pushl  0x8(%ebp)
  8011b4:	a1 04 20 80 00       	mov    0x802004,%eax
  8011b9:	8b 40 4c             	mov    0x4c(%eax),%eax
  8011bc:	50                   	push   %eax
  8011bd:	68 38 19 80 00       	push   $0x801938
  8011c2:	e8 7d f0 ff ff       	call   800244 <cprintf>
}
  8011c7:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    
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
  8011d6:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8011dd:	75 2a                	jne    801209 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
        //cprintf("i'm in set pgfault_handler,before alloc\n");
        if(sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W)) {//maybe not PTE_USER
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	6a 07                	push   $0x7
  8011e4:	68 00 f0 bf ee       	push   $0xeebff000
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 eb f9 ff ff       	call   800bdb <sys_page_alloc>
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
  801201:	e8 70 fb ff ff       	call   800d76 <sys_env_set_pgfault_upcall>
  801206:	83 c4 10             	add    $0x10,%esp
        //cprintf("here in set pgfault handler\n");
		//panic("set_pgfault_handler not implemented");
	}
	// Save handler pointer for assembly to call.
    //cprintf("handler %x;pgfault_handler address %x,upcall address %x,upcall points %x\n",handler,&_pgfault_handler,&_pgfault_upcall,_pgfault_upcall);
	_pgfault_handler = handler;
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
  80120c:	a3 0c 20 80 00       	mov    %eax,0x80200c
    //cprintf("here\n");
    //it should be ok
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    
	...

00801214 <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801214:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801215:	a1 0c 20 80 00       	mov    0x80200c,%eax
    //xchg %bx, %bx
	call *%eax
  80121a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80121c:	83 c4 04             	add    $0x4,%esp
	
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
  80121f:	83 c4 08             	add    $0x8,%esp
/*    //it's wrong
    movl %esp,%eax//old esp is stored in the upper 40byte of the current esp
    addl $40,%eax //eax point to the old esp
    //xchg %bx, %bx
    movl %eax,%edx
    addl $4,%edx //then edx points to the retaddr
    movl %edx,(%eax)//set the esp in the stack to the 
*/   
    movl 32(%esp),%edx //edx is the old eip 
  801222:	8b 54 24 20          	mov    0x20(%esp),%edx
    movl 40(%esp),%eax //eax is the old esp
  801226:	8b 44 24 28          	mov    0x28(%esp),%eax
    subl $4, %eax // then eax point to the place where the return address will be store
  80122a:	83 e8 04             	sub    $0x4,%eax
    movl %edx,(%eax)//the old eip is stored in the return address place.maybe this will cause recursive copyonwrite pagefault
  80122d:	89 10                	mov    %edx,(%eax)
    movl %eax,40(%esp)//then the value of the esp place in the utf points to the old eip
  80122f:	89 44 24 28          	mov    %eax,0x28(%esp)
    //because the register will be restored, so don't care the eax and edx
	// Restore the trap-time registers.
	// LAB 4: Your code here.
    popal
  801233:	61                   	popa   
	// Restore eflags from the stack.
	// LAB 4: Your code here.
    addl $4,%esp
  801234:	83 c4 04             	add    $0x4,%esp
    popfl
  801237:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    //xchg %bx,%bx
    popl %esp//then esp points to the retaddr
  801238:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    //xchg %bx, %bx
    ret
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
