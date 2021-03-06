
obj/user/forktree：     文件格式 elf32-i386

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
  80002c:	e8 fb 00 00 00       	call   80012c <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forkchild>:
void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8a 5d 0c             	mov    0xc(%ebp),%bl
	char nxt[DEPTH+1];
    //cprintf("before set next\n");
	if (strlen(cur) >= DEPTH)
  800042:	56                   	push   %esi
  800043:	e8 c8 06 00 00       	call   800710 <strlen>
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	83 f8 02             	cmp    $0x2,%eax
  80004e:	7f 59                	jg     8000a9 <forkchild+0x75>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	0f be c3             	movsbl %bl,%eax
  800056:	50                   	push   %eax
  800057:	56                   	push   %esi
  800058:	68 60 14 80 00       	push   $0x801460
  80005d:	6a 04                	push   $0x4
  80005f:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800062:	50                   	push   %eax
  800063:	e8 8d 06 00 00       	call   8006f5 <snprintf>
    cprintf("in forkchild the child branch %s\n",nxt);
  800068:	83 c4 18             	add    $0x18,%esp
  80006b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80006e:	50                   	push   %eax
  80006f:	68 ac 14 80 00       	push   $0x8014ac
  800074:	e8 97 01 00 00       	call   800210 <cprintf>
	if (fork() == 0) {
  800079:	e8 e3 0e 00 00       	call   800f61 <fork>
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	85 c0                	test   %eax,%eax
  800083:	75 24                	jne    8000a9 <forkchild+0x75>
        cprintf("forkchild nxt in the stack is %s\n",nxt);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  80008b:	50                   	push   %eax
  80008c:	68 d0 14 80 00       	push   $0x8014d0
  800091:	e8 7a 01 00 00       	call   800210 <cprintf>
		forktree(nxt);
  800096:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
  800099:	89 04 24             	mov    %eax,(%esp)
  80009c:	e8 0f 00 00 00       	call   8000b0 <forktree>
		exit();
  8000a1:	e8 ca 00 00 00       	call   800170 <exit>
  8000a6:	83 c4 10             	add    $0x10,%esp
	}
}
  8000a9:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8000ac:	5b                   	pop    %ebx
  8000ad:	5e                   	pop    %esi
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <forktree>:

void
forktree(const char *cur)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  8000ba:	53                   	push   %ebx
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	e8 57 0a 00 00       	call   800b1a <sys_getenvid>
  8000c3:	83 c4 08             	add    $0x8,%esp
  8000c6:	50                   	push   %eax
  8000c7:	68 65 14 80 00       	push   $0x801465
  8000cc:	e8 3f 01 00 00       	call   800210 <cprintf>
    cprintf("fork first child \n");
  8000d1:	c7 04 24 76 14 80 00 	movl   $0x801476,(%esp)
  8000d8:	e8 33 01 00 00       	call   800210 <cprintf>
	forkchild(cur, '0');
  8000dd:	83 c4 08             	add    $0x8,%esp
  8000e0:	6a 30                	push   $0x30
  8000e2:	53                   	push   %ebx
  8000e3:	e8 4c ff ff ff       	call   800034 <forkchild>
    cprintf("fork second child \n");
  8000e8:	c7 04 24 89 14 80 00 	movl   $0x801489,(%esp)
  8000ef:	e8 1c 01 00 00       	call   800210 <cprintf>
	forkchild(cur, '1');
  8000f4:	83 c4 08             	add    $0x8,%esp
  8000f7:	6a 31                	push   $0x31
  8000f9:	53                   	push   %ebx
  8000fa:	e8 35 ff ff ff       	call   800034 <forkchild>
}
  8000ff:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <umain>:

void
umain(void)
{	cprintf("running in %d\n",sys_getenvid());
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
  80010a:	e8 0b 0a 00 00       	call   800b1a <sys_getenvid>
  80010f:	83 c4 08             	add    $0x8,%esp
  800112:	50                   	push   %eax
  800113:	68 9d 14 80 00       	push   $0x80149d
  800118:	e8 f3 00 00 00       	call   800210 <cprintf>
	forktree("");
  80011d:	c7 04 24 9c 14 80 00 	movl   $0x80149c,(%esp)
  800124:	e8 87 ff ff ff       	call   8000b0 <forktree>
}
  800129:	c9                   	leave  
  80012a:	c3                   	ret    
	...

0080012c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
  800131:	8b 75 08             	mov    0x8(%ebp),%esi
  800134:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  800137:	e8 de 09 00 00       	call   800b1a <sys_getenvid>
  80013c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800141:	c1 e0 07             	shl    $0x7,%eax
  800144:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800149:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014e:	85 f6                	test   %esi,%esi
  800150:	7e 07                	jle    800159 <libmain+0x2d>
		binaryname = argv[0];
  800152:	8b 03                	mov    (%ebx),%eax
  800154:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800159:	83 ec 08             	sub    $0x8,%esp
  80015c:	53                   	push   %ebx
  80015d:	56                   	push   %esi
  80015e:	e8 a1 ff ff ff       	call   800104 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  800163:	e8 08 00 00 00       	call   800170 <exit>
}
  800168:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    
	...

00800170 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  800176:	6a 00                	push   $0x0
  800178:	e8 4c 09 00 00       	call   800ac9 <sys_env_destroy>
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    
	...

00800180 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 03                	mov    (%ebx),%eax
  80018c:	8b 55 08             	mov    0x8(%ebp),%edx
  80018f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800193:	40                   	inc    %eax
  800194:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800196:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019b:	75 1a                	jne    8001b7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	68 ff 00 00 00       	push   $0xff
  8001a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 be 08 00 00       	call   800a6c <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b7:	ff 43 04             	incl   0x4(%ebx)
}
  8001ba:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c8:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8001cf:	00 00 00 
	b.cnt = 0;
  8001d2:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8001d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	68 80 01 80 00       	push   $0x800180
  8001ee:	e8 83 01 00 00       	call   800376 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f3:	83 c4 08             	add    $0x8,%esp
  8001f6:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  8001fc:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	e8 64 08 00 00       	call   800a6c <sys_cputs>

	return b.cnt;
  800208:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	50                   	push   %eax
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 9d ff ff ff       	call   8001bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	8b 75 10             	mov    0x10(%ebp),%esi
  800230:	8b 7d 14             	mov    0x14(%ebp),%edi
  800233:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800236:	8b 45 18             	mov    0x18(%ebp),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	39 d7                	cmp    %edx,%edi
  800240:	72 39                	jb     80027b <printnum+0x57>
  800242:	77 04                	ja     800248 <printnum+0x24>
  800244:	39 c6                	cmp    %eax,%esi
  800246:	72 33                	jb     80027b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 20             	pushl  0x20(%ebp)
  80024e:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800251:	50                   	push   %eax
  800252:	ff 75 18             	pushl  0x18(%ebp)
  800255:	8b 45 18             	mov    0x18(%ebp),%eax
  800258:	ba 00 00 00 00       	mov    $0x0,%edx
  80025d:	52                   	push   %edx
  80025e:	50                   	push   %eax
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	e8 12 0f 00 00       	call   801178 <__udivdi3>
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	52                   	push   %edx
  80026a:	50                   	push   %eax
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	ff 75 08             	pushl  0x8(%ebp)
  800271:	e8 ae ff ff ff       	call   800224 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 19                	jmp    800294 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027b:	4b                   	dec    %ebx
  80027c:	85 db                	test   %ebx,%ebx
  80027e:	7e 14                	jle    800294 <printnum+0x70>
			putch(padc, putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	ff 75 0c             	pushl  0xc(%ebp)
  800286:	ff 75 20             	pushl  0x20(%ebp)
  800289:	ff 55 08             	call   *0x8(%ebp)
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	4b                   	dec    %ebx
  800290:	85 db                	test   %ebx,%ebx
  800292:	7f ec                	jg     800280 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	ff 75 0c             	pushl  0xc(%ebp)
  80029a:	8b 45 18             	mov    0x18(%ebp),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a2:	83 ec 04             	sub    $0x4,%esp
  8002a5:	52                   	push   %edx
  8002a6:	50                   	push   %eax
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	e8 ea 0f 00 00       	call   801298 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 9c 15 80 00 	movsbl 0x80159c(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff 55 08             	call   *0x8(%ebp)
}
  8002bc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 18             	sub    $0x18,%esp
  8002cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8a 45 18             	mov    0x18(%ebp),%al
  8002d5:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  8002d8:	53                   	push   %ebx
  8002d9:	6a 1b                	push   $0x1b
  8002db:	ff d6                	call   *%esi
	putch('[', putdat);
  8002dd:	83 c4 08             	add    $0x8,%esp
  8002e0:	53                   	push   %ebx
  8002e1:	6a 5b                	push   $0x5b
  8002e3:	ff d6                	call   *%esi
	putch('0', putdat);
  8002e5:	83 c4 08             	add    $0x8,%esp
  8002e8:	53                   	push   %ebx
  8002e9:	6a 30                	push   $0x30
  8002eb:	ff d6                	call   *%esi
	putch(';', putdat);
  8002ed:	83 c4 08             	add    $0x8,%esp
  8002f0:	53                   	push   %ebx
  8002f1:	6a 3b                	push   $0x3b
  8002f3:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  8002f5:	83 c4 0c             	add    $0xc,%esp
  8002f8:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  8002fc:	50                   	push   %eax
  8002fd:	ff 75 14             	pushl  0x14(%ebp)
  800300:	6a 0a                	push   $0xa
  800302:	8b 45 10             	mov    0x10(%ebp),%eax
  800305:	99                   	cltd   
  800306:	52                   	push   %edx
  800307:	50                   	push   %eax
  800308:	53                   	push   %ebx
  800309:	56                   	push   %esi
  80030a:	e8 15 ff ff ff       	call   800224 <printnum>
	putch('m', putdat);
  80030f:	83 c4 18             	add    $0x18,%esp
  800312:	53                   	push   %ebx
  800313:	6a 6d                	push   $0x6d
  800315:	ff d6                	call   *%esi

}
  800317:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800327:	83 f8 01             	cmp    $0x1,%eax
  80032a:	7e 0f                	jle    80033b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80032c:	8b 01                	mov    (%ecx),%eax
  80032e:	83 c0 08             	add    $0x8,%eax
  800331:	89 01                	mov    %eax,(%ecx)
  800333:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800336:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800339:	eb 0f                	jmp    80034a <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80033b:	8b 01                	mov    (%ecx),%eax
  80033d:	83 c0 04             	add    $0x4,%eax
  800340:	89 01                	mov    %eax,(%ecx)
  800342:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800345:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800355:	83 f8 01             	cmp    $0x1,%eax
  800358:	7e 0f                	jle    800369 <getint+0x1d>
		return va_arg(*ap, long long);
  80035a:	8b 02                	mov    (%edx),%eax
  80035c:	83 c0 08             	add    $0x8,%eax
  80035f:	89 02                	mov    %eax,(%edx)
  800361:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800364:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800367:	eb 0b                	jmp    800374 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800369:	8b 02                	mov    (%edx),%eax
  80036b:	83 c0 04             	add    $0x4,%eax
  80036e:	89 02                	mov    %eax,(%edx)
  800370:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800373:	99                   	cltd   
}
  800374:	c9                   	leave  
  800375:	c3                   	ret    

00800376 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 1c             	sub    $0x1c,%esp
  80037f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800382:	0f b6 13             	movzbl (%ebx),%edx
  800385:	43                   	inc    %ebx
  800386:	83 fa 25             	cmp    $0x25,%edx
  800389:	74 1e                	je     8003a9 <vprintfmt+0x33>
			if (ch == '\0')
  80038b:	85 d2                	test   %edx,%edx
  80038d:	0f 84 dc 02 00 00    	je     80066f <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800393:	83 ec 08             	sub    $0x8,%esp
  800396:	ff 75 0c             	pushl  0xc(%ebp)
  800399:	52                   	push   %edx
  80039a:	ff 55 08             	call   *0x8(%ebp)
  80039d:	83 c4 10             	add    $0x10,%esp
  8003a0:	0f b6 13             	movzbl (%ebx),%edx
  8003a3:	43                   	inc    %ebx
  8003a4:	83 fa 25             	cmp    $0x25,%edx
  8003a7:	75 e2                	jne    80038b <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8003a9:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8003ad:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8003b4:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8003b9:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8003be:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  8003c5:	0f b6 13             	movzbl (%ebx),%edx
  8003c8:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8003cb:	43                   	inc    %ebx
  8003cc:	83 f8 55             	cmp    $0x55,%eax
  8003cf:	0f 87 75 02 00 00    	ja     80064a <vprintfmt+0x2d4>
  8003d5:	ff 24 85 e4 15 80 00 	jmp    *0x8015e4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8003dc:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  8003e0:	eb e3                	jmp    8003c5 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e2:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  8003e6:	eb dd                	jmp    8003c5 <vprintfmt+0x4f>

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
  8003e8:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8003ed:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8003f0:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  8003f4:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8003f7:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8003fa:	83 f8 09             	cmp    $0x9,%eax
  8003fd:	77 27                	ja     800426 <vprintfmt+0xb0>
  8003ff:	43                   	inc    %ebx
  800400:	eb eb                	jmp    8003ed <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  80040c:	eb 18                	jmp    800426 <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  80040e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800412:	79 b1                	jns    8003c5 <vprintfmt+0x4f>
				width = 0;
  800414:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80041b:	eb a8                	jmp    8003c5 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80041d:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800424:	eb 9f                	jmp    8003c5 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  800426:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80042a:	79 99                	jns    8003c5 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80042c:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80042f:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800434:	eb 8f                	jmp    8003c5 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  800436:	41                   	inc    %ecx
			goto reswitch;
  800437:	eb 8c                	jmp    8003c5 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	ff 75 0c             	pushl  0xc(%ebp)
  80043f:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	ff 70 fc             	pushl  0xfffffffc(%eax)
  800449:	e9 c4 01 00 00       	jmp    800612 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  80044e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  800458:	85 c0                	test   %eax,%eax
  80045a:	79 02                	jns    80045e <vprintfmt+0xe8>
				err = -err;
  80045c:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80045e:	83 f8 08             	cmp    $0x8,%eax
  800461:	7f 0b                	jg     80046e <vprintfmt+0xf8>
  800463:	8b 3c 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edi
  80046a:	85 ff                	test   %edi,%edi
  80046c:	75 08                	jne    800476 <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  80046e:	50                   	push   %eax
  80046f:	68 ad 15 80 00       	push   $0x8015ad
  800474:	eb 06                	jmp    80047c <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  800476:	57                   	push   %edi
  800477:	68 b6 15 80 00       	push   $0x8015b6
  80047c:	ff 75 0c             	pushl  0xc(%ebp)
  80047f:	ff 75 08             	pushl  0x8(%ebp)
  800482:	e8 f0 01 00 00       	call   800677 <printfmt>
  800487:	e9 89 01 00 00       	jmp    800615 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  800496:	85 ff                	test   %edi,%edi
  800498:	75 05                	jne    80049f <vprintfmt+0x129>
				p = "(null)";
  80049a:	bf b9 15 80 00       	mov    $0x8015b9,%edi
			if (width > 0 && padc != '-')
  80049f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004a3:	7e 3b                	jle    8004e0 <vprintfmt+0x16a>
  8004a5:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8004a9:	74 35                	je     8004e0 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	56                   	push   %esi
  8004af:	57                   	push   %edi
  8004b0:	e8 74 02 00 00       	call   800729 <strnlen>
  8004b5:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004bf:	7e 1f                	jle    8004e0 <vprintfmt+0x16a>
  8004c1:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8004c5:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ce:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8004d1:	ff 55 08             	call   *0x8(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004da:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004de:	7f e8                	jg     8004c8 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e0:	0f be 17             	movsbl (%edi),%edx
  8004e3:	47                   	inc    %edi
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	74 3e                	je     800526 <vprintfmt+0x1b0>
  8004e8:	85 f6                	test   %esi,%esi
  8004ea:	78 03                	js     8004ef <vprintfmt+0x179>
  8004ec:	4e                   	dec    %esi
  8004ed:	78 37                	js     800526 <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ef:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8004f3:	74 12                	je     800507 <vprintfmt+0x191>
  8004f5:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8004f8:	83 f8 5e             	cmp    $0x5e,%eax
  8004fb:	76 0a                	jbe    800507 <vprintfmt+0x191>
					putch('?', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	6a 3f                	push   $0x3f
  800505:	eb 07                	jmp    80050e <vprintfmt+0x198>
				else
					putch(ch, putdat);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	ff 75 0c             	pushl  0xc(%ebp)
  80050d:	52                   	push   %edx
  80050e:	ff 55 08             	call   *0x8(%ebp)
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800517:	0f be 17             	movsbl (%edi),%edx
  80051a:	47                   	inc    %edi
  80051b:	85 d2                	test   %edx,%edx
  80051d:	74 07                	je     800526 <vprintfmt+0x1b0>
  80051f:	85 f6                	test   %esi,%esi
  800521:	78 cc                	js     8004ef <vprintfmt+0x179>
  800523:	4e                   	dec    %esi
  800524:	79 c9                	jns    8004ef <vprintfmt+0x179>
			for (; width > 0; width--)
  800526:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80052a:	0f 8e 52 fe ff ff    	jle    800382 <vprintfmt+0xc>
				putch(' ', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	ff 75 0c             	pushl  0xc(%ebp)
  800536:	6a 20                	push   $0x20
  800538:	ff 55 08             	call   *0x8(%ebp)
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800541:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800545:	7f e9                	jg     800530 <vprintfmt+0x1ba>
			break;
  800547:	e9 36 fe ff ff       	jmp    800382 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	51                   	push   %ecx
  800550:	8d 45 14             	lea    0x14(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	e8 f3 fd ff ff       	call   80034c <getint>
  800559:	89 c6                	mov    %eax,%esi
  80055b:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 d2                	test   %edx,%edx
  800562:	79 15                	jns    800579 <vprintfmt+0x203>
				putch('-', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	6a 2d                	push   $0x2d
  80056c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80056f:	f7 de                	neg    %esi
  800571:	83 d7 00             	adc    $0x0,%edi
  800574:	f7 df                	neg    %edi
  800576:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800579:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80057e:	eb 70                	jmp    8005f0 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	51                   	push   %ecx
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	50                   	push   %eax
  800588:	e8 91 fd ff ff       	call   80031e <getuint>
  80058d:	89 c6                	mov    %eax,%esi
  80058f:	89 d7                	mov    %edx,%edi
			base = 10;
  800591:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800596:	eb 55                	jmp    8005ed <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	51                   	push   %ecx
  80059c:	8d 45 14             	lea    0x14(%ebp),%eax
  80059f:	50                   	push   %eax
  8005a0:	e8 79 fd ff ff       	call   80031e <getuint>
  8005a5:	89 c6                	mov    %eax,%esi
  8005a7:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  8005a9:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8005ae:	eb 3d                	jmp    8005ed <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	ff 75 0c             	pushl  0xc(%ebp)
  8005b6:	6a 30                	push   $0x30
  8005b8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005bb:	83 c4 08             	add    $0x8,%esp
  8005be:	ff 75 0c             	pushl  0xc(%ebp)
  8005c1:	6a 78                	push   $0x78
  8005c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8005c6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8005d0:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  8005d5:	eb 11                	jmp    8005e8 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	51                   	push   %ecx
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	50                   	push   %eax
  8005df:	e8 3a fd ff ff       	call   80031e <getuint>
  8005e4:	89 c6                	mov    %eax,%esi
  8005e6:	89 d7                	mov    %edx,%edi
			base = 16;
  8005e8:	ba 10 00 00 00       	mov    $0x10,%edx
  8005ed:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  8005f0:	83 ec 04             	sub    $0x4,%esp
  8005f3:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8005f7:	50                   	push   %eax
  8005f8:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8005fb:	52                   	push   %edx
  8005fc:	57                   	push   %edi
  8005fd:	56                   	push   %esi
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	ff 75 08             	pushl  0x8(%ebp)
  800604:	e8 1b fc ff ff       	call   800224 <printnum>
			break;
  800609:	eb 37                	jmp    800642 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	ff 75 0c             	pushl  0xc(%ebp)
  800611:	52                   	push   %edx
  800612:	ff 55 08             	call   *0x8(%ebp)
			break;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	e9 65 fd ff ff       	jmp    800382 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	51                   	push   %ecx
  800621:	8d 45 14             	lea    0x14(%ebp),%eax
  800624:	50                   	push   %eax
  800625:	e8 f4 fc ff ff       	call   80031e <getuint>
  80062a:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  80062c:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800636:	56                   	push   %esi
  800637:	ff 75 0c             	pushl  0xc(%ebp)
  80063a:	ff 75 08             	pushl  0x8(%ebp)
  80063d:	e8 82 fc ff ff       	call   8002c4 <printcolor>
			break;
  800642:	83 c4 20             	add    $0x20,%esp
  800645:	e9 38 fd ff ff       	jmp    800382 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	ff 75 0c             	pushl  0xc(%ebp)
  800650:	6a 25                	push   $0x25
  800652:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800655:	4b                   	dec    %ebx
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80065d:	0f 84 1f fd ff ff    	je     800382 <vprintfmt+0xc>
  800663:	4b                   	dec    %ebx
  800664:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800668:	75 f9                	jne    800663 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80066a:	e9 13 fd ff ff       	jmp    800382 <vprintfmt+0xc>
		}
	}
}
  80066f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800672:	5b                   	pop    %ebx
  800673:	5e                   	pop    %esi
  800674:	5f                   	pop    %edi
  800675:	c9                   	leave  
  800676:	c3                   	ret    

00800677 <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80067d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800680:	50                   	push   %eax
  800681:	ff 75 10             	pushl  0x10(%ebp)
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	ff 75 08             	pushl  0x8(%ebp)
  80068a:	e8 e7 fc ff ff       	call   800376 <vprintfmt>
	va_end(ap);
}
  80068f:	c9                   	leave  
  800690:	c3                   	ret    

00800691 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800697:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80069a:	8b 0a                	mov    (%edx),%ecx
  80069c:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80069f:	73 07                	jae    8006a8 <sprintputch+0x17>
		*b->buf++ = ch;
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	88 01                	mov    %al,(%ecx)
  8006a6:	ff 02                	incl   (%edx)
}
  8006a8:	c9                   	leave  
  8006a9:	c3                   	ret    

008006aa <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	83 ec 18             	sub    $0x18,%esp
  8006b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8006b6:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8006b9:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8006bd:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8006c0:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 04                	je     8006cf <vsnprintf+0x25>
  8006cb:	85 c9                	test   %ecx,%ecx
  8006cd:	7f 07                	jg     8006d6 <vsnprintf+0x2c>
		return -E_INVAL;
  8006cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d4:	eb 1d                	jmp    8006f3 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  8006d6:	ff 75 14             	pushl  0x14(%ebp)
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	68 91 06 80 00       	push   $0x800691
  8006e5:	e8 8c fc ff ff       	call   800376 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ea:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8006ed:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f0:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fe:	50                   	push   %eax
  8006ff:	ff 75 10             	pushl  0x10(%ebp)
  800702:	ff 75 0c             	pushl  0xc(%ebp)
  800705:	ff 75 08             	pushl  0x8(%ebp)
  800708:	e8 9d ff ff ff       	call   8006aa <vsnprintf>
	va_end(ap);

	return rc;
}
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    
	...

00800710 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	80 3a 00             	cmpb   $0x0,(%edx)
  80071e:	74 07                	je     800727 <strlen+0x17>
		n++;
  800720:	40                   	inc    %eax
  800721:	42                   	inc    %edx
  800722:	80 3a 00             	cmpb   $0x0,(%edx)
  800725:	75 f9                	jne    800720 <strlen+0x10>
	return n;
}
  800727:	c9                   	leave  
  800728:	c3                   	ret    

00800729 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	85 d2                	test   %edx,%edx
  800739:	74 0f                	je     80074a <strnlen+0x21>
  80073b:	80 39 00             	cmpb   $0x0,(%ecx)
  80073e:	74 0a                	je     80074a <strnlen+0x21>
		n++;
  800740:	40                   	inc    %eax
  800741:	41                   	inc    %ecx
  800742:	4a                   	dec    %edx
  800743:	74 05                	je     80074a <strnlen+0x21>
  800745:	80 39 00             	cmpb   $0x0,(%ecx)
  800748:	75 f6                	jne    800740 <strnlen+0x17>
	return n;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800756:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800758:	8a 02                	mov    (%edx),%al
  80075a:	42                   	inc    %edx
  80075b:	88 01                	mov    %al,(%ecx)
  80075d:	41                   	inc    %ecx
  80075e:	84 c0                	test   %al,%al
  800760:	75 f6                	jne    800758 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800762:	89 d8                	mov    %ebx,%eax
  800764:	5b                   	pop    %ebx
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	57                   	push   %edi
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800770:	8b 55 0c             	mov    0xc(%ebp),%edx
  800773:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800776:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800778:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077d:	39 f3                	cmp    %esi,%ebx
  80077f:	73 10                	jae    800791 <strncpy+0x2a>
		*dst++ = *src;
  800781:	8a 02                	mov    (%edx),%al
  800783:	88 01                	mov    %al,(%ecx)
  800785:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800786:	80 3a 00             	cmpb   $0x0,(%edx)
  800789:	74 01                	je     80078c <strncpy+0x25>
			src++;
  80078b:	42                   	inc    %edx
  80078c:	43                   	inc    %ebx
  80078d:	39 f3                	cmp    %esi,%ebx
  80078f:	72 f0                	jb     800781 <strncpy+0x1a>
	}
	return ret;
}
  800791:	89 f8                	mov    %edi,%eax
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5f                   	pop    %edi
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	56                   	push   %esi
  80079c:	53                   	push   %ebx
  80079d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8007a6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8007a8:	85 d2                	test   %edx,%edx
  8007aa:	74 19                	je     8007c5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8007ac:	4a                   	dec    %edx
  8007ad:	74 13                	je     8007c2 <strlcpy+0x2a>
  8007af:	80 39 00             	cmpb   $0x0,(%ecx)
  8007b2:	74 0e                	je     8007c2 <strlcpy+0x2a>
			*dst++ = *src++;
  8007b4:	8a 01                	mov    (%ecx),%al
  8007b6:	41                   	inc    %ecx
  8007b7:	88 03                	mov    %al,(%ebx)
  8007b9:	43                   	inc    %ebx
  8007ba:	4a                   	dec    %edx
  8007bb:	74 05                	je     8007c2 <strlcpy+0x2a>
  8007bd:	80 39 00             	cmpb   $0x0,(%ecx)
  8007c0:	75 f2                	jne    8007b4 <strlcpy+0x1c>
		*dst = '\0';
  8007c2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8007c5:	89 d8                	mov    %ebx,%eax
  8007c7:	29 f0                	sub    %esi,%eax
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5e                   	pop    %esi
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8007d6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007d9:	74 13                	je     8007ee <strcmp+0x21>
  8007db:	8a 02                	mov    (%edx),%al
  8007dd:	3a 01                	cmp    (%ecx),%al
  8007df:	75 0d                	jne    8007ee <strcmp+0x21>
		p++, q++;
  8007e1:	42                   	inc    %edx
  8007e2:	41                   	inc    %ecx
  8007e3:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e6:	74 06                	je     8007ee <strcmp+0x21>
  8007e8:	8a 02                	mov    (%edx),%al
  8007ea:	3a 01                	cmp    (%ecx),%al
  8007ec:	74 f3                	je     8007e1 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 02             	movzbl (%edx),%eax
  8007f1:	0f b6 11             	movzbl (%ecx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800802:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800805:	85 c9                	test   %ecx,%ecx
  800807:	74 1f                	je     800828 <strncmp+0x30>
  800809:	80 3a 00             	cmpb   $0x0,(%edx)
  80080c:	74 16                	je     800824 <strncmp+0x2c>
  80080e:	8a 02                	mov    (%edx),%al
  800810:	3a 03                	cmp    (%ebx),%al
  800812:	75 10                	jne    800824 <strncmp+0x2c>
		n--, p++, q++;
  800814:	42                   	inc    %edx
  800815:	43                   	inc    %ebx
  800816:	49                   	dec    %ecx
  800817:	74 0f                	je     800828 <strncmp+0x30>
  800819:	80 3a 00             	cmpb   $0x0,(%edx)
  80081c:	74 06                	je     800824 <strncmp+0x2c>
  80081e:	8a 02                	mov    (%edx),%al
  800820:	3a 03                	cmp    (%ebx),%al
  800822:	74 f0                	je     800814 <strncmp+0x1c>
	if (n == 0)
  800824:	85 c9                	test   %ecx,%ecx
  800826:	75 07                	jne    80082f <strncmp+0x37>
		return 0;
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
  80082d:	eb 0a                	jmp    800839 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 12             	movzbl (%edx),%edx
  800832:	0f b6 03             	movzbl (%ebx),%eax
  800835:	29 c2                	sub    %eax,%edx
  800837:	89 d0                	mov    %edx,%eax
}
  800839:	8b 1c 24             	mov    (%esp),%ebx
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800847:	80 38 00             	cmpb   $0x0,(%eax)
  80084a:	74 0a                	je     800856 <strchr+0x18>
		if (*s == c)
  80084c:	38 10                	cmp    %dl,(%eax)
  80084e:	74 0b                	je     80085b <strchr+0x1d>
  800850:	40                   	inc    %eax
  800851:	80 38 00             	cmpb   $0x0,(%eax)
  800854:	75 f6                	jne    80084c <strchr+0xe>
			return (char *) s;
	return 0;
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800866:	80 38 00             	cmpb   $0x0,(%eax)
  800869:	74 0a                	je     800875 <strfind+0x18>
		if (*s == c)
  80086b:	38 10                	cmp    %dl,(%eax)
  80086d:	74 06                	je     800875 <strfind+0x18>
  80086f:	40                   	inc    %eax
  800870:	80 38 00             	cmpb   $0x0,(%eax)
  800873:	75 f6                	jne    80086b <strfind+0xe>
			break;
	return (char *) s;
}
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	57                   	push   %edi
  80087b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800881:	89 f8                	mov    %edi,%eax
  800883:	85 c9                	test   %ecx,%ecx
  800885:	74 40                	je     8008c7 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800887:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088d:	75 30                	jne    8008bf <memset+0x48>
  80088f:	f6 c1 03             	test   $0x3,%cl
  800892:	75 2b                	jne    8008bf <memset+0x48>
		c &= 0xFF;
  800894:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	c1 e0 18             	shl    $0x18,%eax
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a4:	c1 e2 10             	shl    $0x10,%edx
  8008a7:	09 d0                	or     %edx,%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	c1 e2 08             	shl    $0x8,%edx
  8008af:	09 d0                	or     %edx,%eax
  8008b1:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8008b4:	c1 e9 02             	shr    $0x2,%ecx
  8008b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ba:	fc                   	cld    
  8008bb:	f3 ab                	repz stos %eax,%es:(%edi)
  8008bd:	eb 06                	jmp    8008c5 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c2:	fc                   	cld    
  8008c3:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8008c5:	89 f8                	mov    %edi,%eax
}
  8008c7:	8b 3c 24             	mov    (%esp),%edi
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8008d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008da:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008dc:	39 c6                	cmp    %eax,%esi
  8008de:	73 33                	jae    800913 <memmove+0x47>
  8008e0:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  8008e3:	39 c2                	cmp    %eax,%edx
  8008e5:	76 2c                	jbe    800913 <memmove+0x47>
		s += n;
  8008e7:	89 d6                	mov    %edx,%esi
		d += n;
  8008e9:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ec:	f6 c2 03             	test   $0x3,%dl
  8008ef:	75 1b                	jne    80090c <memmove+0x40>
  8008f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f7:	75 13                	jne    80090c <memmove+0x40>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 0e                	jne    80090c <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8008fe:	83 ef 04             	sub    $0x4,%edi
  800901:	83 ee 04             	sub    $0x4,%esi
  800904:	c1 e9 02             	shr    $0x2,%ecx
  800907:	fd                   	std    
  800908:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 27                	jmp    800933 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090c:	4f                   	dec    %edi
  80090d:	4e                   	dec    %esi
  80090e:	fd                   	std    
  80090f:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800911:	eb 20                	jmp    800933 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800913:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800919:	75 15                	jne    800930 <memmove+0x64>
  80091b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800921:	75 0d                	jne    800930 <memmove+0x64>
  800923:	f6 c1 03             	test   $0x3,%cl
  800926:	75 08                	jne    800930 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fc                   	cld    
  80092c:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 03                	jmp    800933 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800930:	fc                   	cld    
  800931:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <memcpy>:

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
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80093d:	ff 75 10             	pushl  0x10(%ebp)
  800940:	ff 75 0c             	pushl  0xc(%ebp)
  800943:	ff 75 08             	pushl  0x8(%ebp)
  800946:	e8 81 ff ff ff       	call   8008cc <memmove>
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	53                   	push   %ebx
  800951:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800957:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  80095a:	89 d0                	mov    %edx,%eax
  80095c:	4a                   	dec    %edx
  80095d:	85 c0                	test   %eax,%eax
  80095f:	74 1b                	je     80097c <memcmp+0x2f>
		if (*s1 != *s2)
  800961:	8a 01                	mov    (%ecx),%al
  800963:	3a 03                	cmp    (%ebx),%al
  800965:	74 0c                	je     800973 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800967:	0f b6 d0             	movzbl %al,%edx
  80096a:	0f b6 03             	movzbl (%ebx),%eax
  80096d:	29 c2                	sub    %eax,%edx
  80096f:	89 d0                	mov    %edx,%eax
  800971:	eb 0e                	jmp    800981 <memcmp+0x34>
		s1++, s2++;
  800973:	41                   	inc    %ecx
  800974:	43                   	inc    %ebx
  800975:	89 d0                	mov    %edx,%eax
  800977:	4a                   	dec    %edx
  800978:	85 c0                	test   %eax,%eax
  80097a:	75 e5                	jne    800961 <memcmp+0x14>
	}

	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800981:	5b                   	pop    %ebx
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800992:	39 d0                	cmp    %edx,%eax
  800994:	73 09                	jae    80099f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800996:	38 08                	cmp    %cl,(%eax)
  800998:	74 05                	je     80099f <memfind+0x1b>
  80099a:	40                   	inc    %eax
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	72 f7                	jb     800996 <memfind+0x12>
			break;
	return (void *) s;
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8009b0:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8009b5:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	80 3a 20             	cmpb   $0x20,(%edx)
  8009bd:	74 05                	je     8009c4 <strtol+0x23>
  8009bf:	80 3a 09             	cmpb   $0x9,(%edx)
  8009c2:	75 0b                	jne    8009cf <strtol+0x2e>
		s++;
  8009c4:	42                   	inc    %edx
  8009c5:	80 3a 20             	cmpb   $0x20,(%edx)
  8009c8:	74 fa                	je     8009c4 <strtol+0x23>
  8009ca:	80 3a 09             	cmpb   $0x9,(%edx)
  8009cd:	74 f5                	je     8009c4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8009cf:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8009d2:	75 03                	jne    8009d7 <strtol+0x36>
		s++;
  8009d4:	42                   	inc    %edx
  8009d5:	eb 0b                	jmp    8009e2 <strtol+0x41>
	else if (*s == '-')
  8009d7:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8009da:	75 06                	jne    8009e2 <strtol+0x41>
		s++, neg = 1;
  8009dc:	42                   	inc    %edx
  8009dd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e2:	85 c9                	test   %ecx,%ecx
  8009e4:	74 05                	je     8009eb <strtol+0x4a>
  8009e6:	83 f9 10             	cmp    $0x10,%ecx
  8009e9:	75 15                	jne    800a00 <strtol+0x5f>
  8009eb:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ee:	75 10                	jne    800a00 <strtol+0x5f>
  8009f0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f4:	75 0a                	jne    800a00 <strtol+0x5f>
		s += 2, base = 16;
  8009f6:	83 c2 02             	add    $0x2,%edx
  8009f9:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009fe:	eb 1a                	jmp    800a1a <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	75 16                	jne    800a1a <strtol+0x79>
  800a04:	80 3a 30             	cmpb   $0x30,(%edx)
  800a07:	75 08                	jne    800a11 <strtol+0x70>
		s++, base = 8;
  800a09:	42                   	inc    %edx
  800a0a:	b9 08 00 00 00       	mov    $0x8,%ecx
  800a0f:	eb 09                	jmp    800a1a <strtol+0x79>
	else if (base == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	75 05                	jne    800a1a <strtol+0x79>
		base = 10;
  800a15:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1a:	8a 02                	mov    (%edx),%al
  800a1c:	83 e8 30             	sub    $0x30,%eax
  800a1f:	3c 09                	cmp    $0x9,%al
  800a21:	77 08                	ja     800a2b <strtol+0x8a>
			dig = *s - '0';
  800a23:	0f be 02             	movsbl (%edx),%eax
  800a26:	83 e8 30             	sub    $0x30,%eax
  800a29:	eb 20                	jmp    800a4b <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800a2b:	8a 02                	mov    (%edx),%al
  800a2d:	83 e8 61             	sub    $0x61,%eax
  800a30:	3c 19                	cmp    $0x19,%al
  800a32:	77 08                	ja     800a3c <strtol+0x9b>
			dig = *s - 'a' + 10;
  800a34:	0f be 02             	movsbl (%edx),%eax
  800a37:	83 e8 57             	sub    $0x57,%eax
  800a3a:	eb 0f                	jmp    800a4b <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800a3c:	8a 02                	mov    (%edx),%al
  800a3e:	83 e8 41             	sub    $0x41,%eax
  800a41:	3c 19                	cmp    $0x19,%al
  800a43:	77 12                	ja     800a57 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a45:	0f be 02             	movsbl (%edx),%eax
  800a48:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a4b:	39 c8                	cmp    %ecx,%eax
  800a4d:	7d 08                	jge    800a57 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800a4f:	42                   	inc    %edx
  800a50:	0f af d9             	imul   %ecx,%ebx
  800a53:	01 c3                	add    %eax,%ebx
  800a55:	eb c3                	jmp    800a1a <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a57:	85 f6                	test   %esi,%esi
  800a59:	74 02                	je     800a5d <strtol+0xbc>
		*endptr = (char *) s;
  800a5b:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	85 ff                	test   %edi,%edi
  800a61:	74 02                	je     800a65 <strtol+0xc4>
  800a63:	f7 d8                	neg    %eax
}
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    
	...

00800a6c <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a78:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7d:	89 f8                	mov    %edi,%eax
  800a7f:	89 fb                	mov    %edi,%ebx
  800a81:	89 fe                	mov    %edi,%esi
  800a83:	55                   	push   %ebp
  800a84:	9c                   	pushf  
  800a85:	56                   	push   %esi
  800a86:	54                   	push   %esp
  800a87:	5d                   	pop    %ebp
  800a88:	8d 35 90 0a 80 00    	lea    0x800a90,%esi
  800a8e:	0f 34                	sysenter 
  800a90:	83 c4 04             	add    $0x4,%esp
  800a93:	9d                   	popf   
  800a94:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    

00800a9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aaa:	89 fa                	mov    %edi,%edx
  800aac:	89 f9                	mov    %edi,%ecx
  800aae:	89 fb                	mov    %edi,%ebx
  800ab0:	89 fe                	mov    %edi,%esi
  800ab2:	55                   	push   %ebp
  800ab3:	9c                   	pushf  
  800ab4:	56                   	push   %esi
  800ab5:	54                   	push   %esp
  800ab6:	5d                   	pop    %ebp
  800ab7:	8d 35 bf 0a 80 00    	lea    0x800abf,%esi
  800abd:	0f 34                	sysenter 
  800abf:	83 c4 04             	add    $0x4,%esp
  800ac2:	9d                   	popf   
  800ac3:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	b8 03 00 00 00       	mov    $0x3,%eax
  800ada:	bf 00 00 00 00       	mov    $0x0,%edi
  800adf:	89 f9                	mov    %edi,%ecx
  800ae1:	89 fb                	mov    %edi,%ebx
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
  800af9:	7e 17                	jle    800b12 <sys_env_destroy+0x49>
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	50                   	push   %eax
  800aff:	6a 03                	push   $0x3
  800b01:	68 3c 17 80 00       	push   $0x80173c
  800b06:	6a 4c                	push   $0x4c
  800b08:	68 59 17 80 00       	push   $0x801759
  800b0d:	e8 9a 05 00 00       	call   8010ac <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b12:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	b8 02 00 00 00       	mov    $0x2,%eax
  800b25:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2a:	89 fa                	mov    %edi,%edx
  800b2c:	89 f9                	mov    %edi,%ecx
  800b2e:	89 fb                	mov    %edi,%ebx
  800b30:	89 fe                	mov    %edi,%esi
  800b32:	55                   	push   %ebp
  800b33:	9c                   	pushf  
  800b34:	56                   	push   %esi
  800b35:	54                   	push   %esp
  800b36:	5d                   	pop    %ebp
  800b37:	8d 35 3f 0b 80 00    	lea    0x800b3f,%esi
  800b3d:	0f 34                	sysenter 
  800b3f:	83 c4 04             	add    $0x4,%esp
  800b42:	9d                   	popf   
  800b43:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <sys_dump_env>:

int
sys_dump_env(void)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b54:	bf 00 00 00 00       	mov    $0x0,%edi
  800b59:	89 fa                	mov    %edi,%edx
  800b5b:	89 f9                	mov    %edi,%ecx
  800b5d:	89 fb                	mov    %edi,%ebx
  800b5f:	89 fe                	mov    %edi,%esi
  800b61:	55                   	push   %ebp
  800b62:	9c                   	pushf  
  800b63:	56                   	push   %esi
  800b64:	54                   	push   %esp
  800b65:	5d                   	pop    %ebp
  800b66:	8d 35 6e 0b 80 00    	lea    0x800b6e,%esi
  800b6c:	0f 34                	sysenter 
  800b6e:	83 c4 04             	add    $0x4,%esp
  800b71:	9d                   	popf   
  800b72:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <sys_yield>:

void
sys_yield(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b83:	bf 00 00 00 00       	mov    $0x0,%edi
  800b88:	89 fa                	mov    %edi,%edx
  800b8a:	89 f9                	mov    %edi,%ecx
  800b8c:	89 fb                	mov    %edi,%ebx
  800b8e:	89 fe                	mov    %edi,%esi
  800b90:	55                   	push   %ebp
  800b91:	9c                   	pushf  
  800b92:	56                   	push   %esi
  800b93:	54                   	push   %esp
  800b94:	5d                   	pop    %ebp
  800b95:	8d 35 9d 0b 80 00    	lea    0x800b9d,%esi
  800b9b:	0f 34                	sysenter 
  800b9d:	83 c4 04             	add    $0x4,%esp
  800ba0:	9d                   	popf   
  800ba1:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc3:	89 fe                	mov    %edi,%esi
  800bc5:	55                   	push   %ebp
  800bc6:	9c                   	pushf  
  800bc7:	56                   	push   %esi
  800bc8:	54                   	push   %esp
  800bc9:	5d                   	pop    %ebp
  800bca:	8d 35 d2 0b 80 00    	lea    0x800bd2,%esi
  800bd0:	0f 34                	sysenter 
  800bd2:	83 c4 04             	add    $0x4,%esp
  800bd5:	9d                   	popf   
  800bd6:	5d                   	pop    %ebp
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 17                	jle    800bf2 <sys_page_alloc+0x4b>
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 05                	push   $0x5
  800be1:	68 3c 17 80 00       	push   $0x80173c
  800be6:	6a 4c                	push   $0x4c
  800be8:	68 59 17 80 00       	push   $0x801759
  800bed:	e8 ba 04 00 00       	call   8010ac <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf2:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c12:	b8 06 00 00 00       	mov    $0x6,%eax
  800c17:	55                   	push   %ebp
  800c18:	9c                   	pushf  
  800c19:	56                   	push   %esi
  800c1a:	54                   	push   %esp
  800c1b:	5d                   	pop    %ebp
  800c1c:	8d 35 24 0c 80 00    	lea    0x800c24,%esi
  800c22:	0f 34                	sysenter 
  800c24:	83 c4 04             	add    $0x4,%esp
  800c27:	9d                   	popf   
  800c28:	5d                   	pop    %ebp
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7e 17                	jle    800c44 <sys_page_map+0x4a>
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	50                   	push   %eax
  800c31:	6a 06                	push   $0x6
  800c33:	68 3c 17 80 00       	push   $0x80173c
  800c38:	6a 4c                	push   $0x4c
  800c3a:	68 59 17 80 00       	push   $0x801759
  800c3f:	e8 68 04 00 00       	call   8010ac <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800c44:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 07 00 00 00       	mov    $0x7,%eax
  800c60:	bf 00 00 00 00       	mov    $0x0,%edi
  800c65:	89 fb                	mov    %edi,%ebx
  800c67:	89 fe                	mov    %edi,%esi
  800c69:	55                   	push   %ebp
  800c6a:	9c                   	pushf  
  800c6b:	56                   	push   %esi
  800c6c:	54                   	push   %esp
  800c6d:	5d                   	pop    %ebp
  800c6e:	8d 35 76 0c 80 00    	lea    0x800c76,%esi
  800c74:	0f 34                	sysenter 
  800c76:	83 c4 04             	add    $0x4,%esp
  800c79:	9d                   	popf   
  800c7a:	5d                   	pop    %ebp
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 17                	jle    800c96 <sys_page_unmap+0x4a>
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 07                	push   $0x7
  800c85:	68 3c 17 80 00       	push   $0x80173c
  800c8a:	6a 4c                	push   $0x4c
  800c8c:	68 59 17 80 00       	push   $0x801759
  800c91:	e8 16 04 00 00       	call   8010ac <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c96:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    

00800c9e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb7:	89 fb                	mov    %edi,%ebx
  800cb9:	89 fe                	mov    %edi,%esi
  800cbb:	55                   	push   %ebp
  800cbc:	9c                   	pushf  
  800cbd:	56                   	push   %esi
  800cbe:	54                   	push   %esp
  800cbf:	5d                   	pop    %ebp
  800cc0:	8d 35 c8 0c 80 00    	lea    0x800cc8,%esi
  800cc6:	0f 34                	sysenter 
  800cc8:	83 c4 04             	add    $0x4,%esp
  800ccb:	9d                   	popf   
  800ccc:	5d                   	pop    %ebp
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 17                	jle    800ce8 <sys_env_set_status+0x4a>
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 09                	push   $0x9
  800cd7:	68 3c 17 80 00       	push   $0x80173c
  800cdc:	6a 4c                	push   $0x4c
  800cde:	68 59 17 80 00       	push   $0x801759
  800ce3:	e8 c4 03 00 00       	call   8010ac <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d04:	bf 00 00 00 00       	mov    $0x0,%edi
  800d09:	89 fb                	mov    %edi,%ebx
  800d0b:	89 fe                	mov    %edi,%esi
  800d0d:	55                   	push   %ebp
  800d0e:	9c                   	pushf  
  800d0f:	56                   	push   %esi
  800d10:	54                   	push   %esp
  800d11:	5d                   	pop    %ebp
  800d12:	8d 35 1a 0d 80 00    	lea    0x800d1a,%esi
  800d18:	0f 34                	sysenter 
  800d1a:	83 c4 04             	add    $0x4,%esp
  800d1d:	9d                   	popf   
  800d1e:	5d                   	pop    %ebp
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_env_set_trapframe+0x4a>
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 0a                	push   $0xa
  800d29:	68 3c 17 80 00       	push   $0x80173c
  800d2e:	6a 4c                	push   $0x4c
  800d30:	68 59 17 80 00       	push   $0x801759
  800d35:	e8 72 03 00 00       	call   8010ac <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d56:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5b:	89 fb                	mov    %edi,%ebx
  800d5d:	89 fe                	mov    %edi,%esi
  800d5f:	55                   	push   %ebp
  800d60:	9c                   	pushf  
  800d61:	56                   	push   %esi
  800d62:	54                   	push   %esp
  800d63:	5d                   	pop    %ebp
  800d64:	8d 35 6c 0d 80 00    	lea    0x800d6c,%esi
  800d6a:	0f 34                	sysenter 
  800d6c:	83 c4 04             	add    $0x4,%esp
  800d6f:	9d                   	popf   
  800d70:	5d                   	pop    %ebp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7e 17                	jle    800d8c <sys_env_set_pgfault_upcall+0x4a>
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	50                   	push   %eax
  800d79:	6a 0b                	push   $0xb
  800d7b:	68 3c 17 80 00       	push   $0x80173c
  800d80:	6a 4c                	push   $0x4c
  800d82:	68 59 17 80 00       	push   $0x801759
  800d87:	e8 20 03 00 00       	call   8010ac <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	55                   	push   %ebp
  800db1:	9c                   	pushf  
  800db2:	56                   	push   %esi
  800db3:	54                   	push   %esp
  800db4:	5d                   	pop    %ebp
  800db5:	8d 35 bd 0d 80 00    	lea    0x800dbd,%esi
  800dbb:	0f 34                	sysenter 
  800dbd:	83 c4 04             	add    $0x4,%esp
  800dc0:	9d                   	popf   
  800dc1:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    

00800dc7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ddd:	89 f9                	mov    %edi,%ecx
  800ddf:	89 fb                	mov    %edi,%ebx
  800de1:	89 fe                	mov    %edi,%esi
  800de3:	55                   	push   %ebp
  800de4:	9c                   	pushf  
  800de5:	56                   	push   %esi
  800de6:	54                   	push   %esp
  800de7:	5d                   	pop    %ebp
  800de8:	8d 35 f0 0d 80 00    	lea    0x800df0,%esi
  800dee:	0f 34                	sysenter 
  800df0:	83 c4 04             	add    $0x4,%esp
  800df3:	9d                   	popf   
  800df4:	5d                   	pop    %ebp
  800df5:	85 c0                	test   %eax,%eax
  800df7:	7e 17                	jle    800e10 <sys_ipc_recv+0x49>
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	50                   	push   %eax
  800dfd:	6a 0e                	push   $0xe
  800dff:	68 3c 17 80 00       	push   $0x80173c
  800e04:	6a 4c                	push   $0x4c
  800e06:	68 59 17 80 00       	push   $0x801759
  800e0b:	e8 9c 02 00 00       	call   8010ac <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e10:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	c9                   	leave  
  800e17:	c3                   	ret    

00800e18 <pgfault>:
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 04             	sub    $0x4,%esp
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
    void *addr = (void *) utf->utf_fault_va;
  800e22:	8b 1a                	mov    (%edx),%ebx
    uint32_t err = utf->utf_err;
  800e24:	8b 42 04             	mov    0x4(%edx),%eax
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
  800e27:	a8 02                	test   $0x2,%al
  800e29:	0f 84 ae 00 00 00    	je     800edd <pgfault+0xc5>
        //cprintf("it's caused by fault write\n");
        if (vpt[PPN(addr)] & PTE_COW) {//first
  800e2f:	89 d8                	mov    %ebx,%eax
  800e31:	c1 e8 0c             	shr    $0xc,%eax
  800e34:	8b 04 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%eax
  800e3b:	f6 c4 08             	test   $0x8,%ah
  800e3e:	0f 84 85 00 00 00    	je     800ec9 <pgfault+0xb1>
            //ok it's caused by copy on write
            //cprintf("it's caused by copy on write\n");
            if ((r = sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W))) {//wrong not ROUNDDOWN(addr,PGSIZE)
  800e44:	83 ec 04             	sub    $0x4,%esp
  800e47:	6a 07                	push   $0x7
  800e49:	68 00 f0 7f 00       	push   $0x7ff000
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 52 fd ff ff       	call   800ba7 <sys_page_alloc>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	74 0a                	je     800e66 <pgfault+0x4e>
                panic("pgfault->sys_page_alloc:%e",r);
  800e5c:	50                   	push   %eax
  800e5d:	68 67 17 80 00       	push   $0x801767
  800e62:	6a 2f                	push   $0x2f
  800e64:	eb 6d                	jmp    800ed3 <pgfault+0xbb>
            }
            //cprintf("before copy data from ROUNDDOWN(%x,PGSIZE) to PFTEMP\n",addr);
            memcpy(PFTEMP,ROUNDDOWN(addr,PGSIZE),PGSIZE);
  800e66:	89 d8                	mov    %ebx,%eax
  800e68:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e6d:	29 c3                	sub    %eax,%ebx
  800e6f:	83 ec 04             	sub    $0x4,%esp
  800e72:	68 00 10 00 00       	push   $0x1000
  800e77:	53                   	push   %ebx
  800e78:	68 00 f0 7f 00       	push   $0x7ff000
  800e7d:	e8 b5 fa ff ff       	call   800937 <memcpy>
            //cprintf("before map the PFTEMP to the ROUNDDOWN(%x,PGSIZE)\n",addr);
            if ((r= sys_page_map(0,PFTEMP,0,ROUNDDOWN(addr,PGSIZE),PTE_P|PTE_U|PTE_W))) {/*seemly than PTE_USER is wrong*/
  800e82:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e89:	53                   	push   %ebx
  800e8a:	6a 00                	push   $0x0
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	6a 00                	push   $0x0
  800e93:	e8 62 fd ff ff       	call   800bfa <sys_page_map>
  800e98:	83 c4 20             	add    $0x20,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	74 0a                	je     800ea9 <pgfault+0x91>
                panic("pgfault->sys_page_map:%e",r);
  800e9f:	50                   	push   %eax
  800ea0:	68 82 17 80 00       	push   $0x801782
  800ea5:	6a 35                	push   $0x35
  800ea7:	eb 2a                	jmp    800ed3 <pgfault+0xbb>
            }
            //cprintf("before unmap the PFTEMP\n");
            if ((r = sys_page_unmap(0,PFTEMP))) {
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	68 00 f0 7f 00       	push   $0x7ff000
  800eb1:	6a 00                	push   $0x0
  800eb3:	e8 94 fd ff ff       	call   800c4c <sys_page_unmap>
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	74 37                	je     800ef6 <pgfault+0xde>
                panic("pgfault->sys_page_unmap:%e",r);
  800ebf:	50                   	push   %eax
  800ec0:	68 9b 17 80 00       	push   $0x80179b
  800ec5:	6a 39                	push   $0x39
  800ec7:	eb 0a                	jmp    800ed3 <pgfault+0xbb>
            }
            //cprintf("after unmap the PFTEMP\n");
        } else {
            panic("the fault write page is not copy on write\n");
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	68 1c 18 80 00       	push   $0x80181c
  800ed1:	6a 3d                	push   $0x3d
  800ed3:	68 b6 17 80 00       	push   $0x8017b6
  800ed8:	e8 cf 01 00 00       	call   8010ac <_panic>
        }
    } else {
        panic("the fault page isn't fault write,%eip is %x,va is %x,errcode is %d",utf->utf_eip,addr,err);
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	50                   	push   %eax
  800ee1:	53                   	push   %ebx
  800ee2:	ff 72 28             	pushl  0x28(%edx)
  800ee5:	68 48 18 80 00       	push   $0x801848
  800eea:	6a 40                	push   $0x40
  800eec:	68 b6 17 80 00       	push   $0x8017b6
  800ef1:	e8 b6 01 00 00       	call   8010ac <_panic>
    }
    //it should be ok
    //panic("pgfault not implemented");
}
  800ef6:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <duppage>:

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
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	56                   	push   %esi
  800eff:	53                   	push   %ebx
  800f00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f03:	8b 45 0c             	mov    0xc(%ebp),%eax
    int r;
    void *addr;
    pte_t pte;
    pte = vpt[pn];//current env's page table entry
  800f06:	8b 14 85 00 00 40 ef 	mov    0xef400000(,%eax,4),%edx
    addr = (void *) (pn*PGSIZE);//virtual address
  800f0d:	89 c6                	mov    %eax,%esi
  800f0f:	c1 e6 0c             	shl    $0xc,%esi
    uint32_t perm = pte & PTE_USER;
  800f12:	89 d3                	mov    %edx,%ebx
  800f14:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
    /*if((uint32_t)addr == USTACKTOP-PGSIZE) {
        cprintf("duppage user stack!!!!!!!!!!\n");
    }*/
    if ((pte & PTE_COW)|(pte & PTE_W)) {
  800f1a:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f20:	74 26                	je     800f48 <duppage+0x4d>
        /*the page need copy on write*/
        perm |= PTE_COW;
  800f22:	80 cf 08             	or     $0x8,%bh
        perm &= ~PTE_W;
  800f25:	83 e3 fd             	and    $0xfffffffd,%ebx
        if ((r = sys_page_map(0,addr,envid,addr,perm))) {
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	53                   	push   %ebx
  800f2c:	56                   	push   %esi
  800f2d:	51                   	push   %ecx
  800f2e:	56                   	push   %esi
  800f2f:	6a 00                	push   $0x0
  800f31:	e8 c4 fc ff ff       	call   800bfa <sys_page_map>
  800f36:	83 c4 20             	add    $0x20,%esp
  800f39:	89 c2                	mov    %eax,%edx
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	75 19                	jne    800f58 <duppage+0x5d>
            return r;
        }
        return sys_page_map(0,addr,0,addr,perm);//also remap it
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	53                   	push   %ebx
  800f43:	56                   	push   %esi
  800f44:	6a 00                	push   $0x0
  800f46:	eb 06                	jmp    800f4e <duppage+0x53>
        /*now the page can't be writen*/
    }
    // LAB 4: Your code here.
    //panic("duppage not implemented");
    //may be wrong, it's not writable so just map it,although it may be no safe
    return sys_page_map(0, addr, envid, addr, perm);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	53                   	push   %ebx
  800f4c:	56                   	push   %esi
  800f4d:	51                   	push   %ecx
  800f4e:	56                   	push   %esi
  800f4f:	6a 00                	push   $0x0
  800f51:	e8 a4 fc ff ff       	call   800bfa <sys_page_map>
  800f56:	89 c2                	mov    %eax,%edx
}
  800f58:	89 d0                	mov    %edx,%eax
  800f5a:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <fork>:

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
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	53                   	push   %ebx
  800f67:	83 ec 18             	sub    $0x18,%esp
    // LAB 4: Your code here.
    int pde_index;
    int pte_index;
    envid_t envid;
    unsigned pn = 0;
  800f6a:	be 00 00 00 00       	mov    $0x0,%esi
    int r;
    set_pgfault_handler(pgfault);/*set the pgfault handler for the father*/
  800f6f:	68 18 0e 80 00       	push   $0x800e18
  800f74:	e8 93 01 00 00       	call   80110c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
  800f79:	83 c4 10             	add    $0x10,%esp
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
  800f7c:	ba 08 00 00 00       	mov    $0x8,%edx
  800f81:	89 d0                	mov    %edx,%eax
  800f83:	cd 30                	int    $0x30
  800f85:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
    //cprintf("in fork before sys_exofork\n");
    envid = sys_exofork();//it use int to syscall
    //the child will come back use iret
    //cprintf("after fork->sys_exofork return:%d\n",envid);
    if (envid < 0) {
  800f88:	89 c2                	mov    %eax,%edx
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	0f 88 f4 00 00 00    	js     801086 <fork+0x125>
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
  800f92:	bf 00 00 00 00       	mov    $0x0,%edi
  800f97:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800f9b:	75 21                	jne    800fbe <fork+0x5d>
  800f9d:	e8 78 fb ff ff       	call   800b1a <sys_getenvid>
  800fa2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa7:	c1 e0 07             	shl    $0x7,%eax
  800faa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800faf:	a3 04 20 80 00       	mov    %eax,0x802004
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	e9 c8 00 00 00       	jmp    801086 <fork+0x125>
        /*upper than utop,such map has already done*/
        if (vpd[pde_index]) {
  800fbe:	8b 04 bd 00 d0 7b ef 	mov    0xef7bd000(,%edi,4),%eax
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	74 48                	je     801011 <fork+0xb0>
            for (pte_index = 0;pte_index < NPTENTRIES;pte_index++) {
  800fc9:	bb 00 00 00 00       	mov    $0x0,%ebx
                if (vpt[pn]&& (pn*PGSIZE) != (UXSTACKTOP - PGSIZE)) {
  800fce:	8b 04 b5 00 00 40 ef 	mov    0xef400000(,%esi,4),%eax
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	74 2c                	je     801005 <fork+0xa4>
  800fd9:	89 f0                	mov    %esi,%eax
  800fdb:	c1 e0 0c             	shl    $0xc,%eax
  800fde:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  800fe3:	74 20                	je     801005 <fork+0xa4>
                    /*if the pte is not null and it's not pgfault stack*/
                    if ((r = duppage(envid,pn)))
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	56                   	push   %esi
  800fe9:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800fec:	e8 0a ff ff ff       	call   800efb <duppage>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	74 0d                	je     801005 <fork+0xa4>
                        panic("in duppage:%e",r);
  800ff8:	50                   	push   %eax
  800ff9:	68 c1 17 80 00       	push   $0x8017c1
  800ffe:	68 9e 00 00 00       	push   $0x9e
  801003:	eb 77                	jmp    80107c <fork+0x11b>
                }
                pn++;
  801005:	46                   	inc    %esi
  801006:	43                   	inc    %ebx
  801007:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  80100d:	7e bf                	jle    800fce <fork+0x6d>
  80100f:	eb 06                	jmp    801017 <fork+0xb6>
            }
        } else {
            pn += NPTENTRIES;/*skip 1024 virtual page*/
  801011:	81 c6 00 04 00 00    	add    $0x400,%esi
  801017:	47                   	inc    %edi
  801018:	81 ff ba 03 00 00    	cmp    $0x3ba,%edi
  80101e:	76 9e                	jbe    800fbe <fork+0x5d>
        }
    }
    //cprintf("after parent map for child\n");
    /*set the pgfault handler for child*/
    //cprintf("after set the pgfault handler\n");
    if ((r = sys_page_alloc(envid,(void *)(UXSTACKTOP - PGSIZE),PTE_P|PTE_U|PTE_W))) {
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	6a 07                	push   $0x7
  801025:	68 00 f0 bf ee       	push   $0xeebff000
  80102a:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80102d:	e8 75 fb ff ff       	call   800ba7 <sys_page_alloc>
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	74 0d                	je     801046 <fork+0xe5>
        panic("in fork->sys_page_alloc %e",r);
  801039:	50                   	push   %eax
  80103a:	68 cf 17 80 00       	push   $0x8017cf
  80103f:	68 aa 00 00 00       	push   $0xaa
  801044:	eb 36                	jmp    80107c <fork+0x11b>
    }
    //cprintf("before set the pgfault up call for child\n");
    //cprintf("env->env_pgfault_upcall:%x\n",env->env_pgfault_upcall);
    sys_env_set_pgfault_upcall(envid,env->env_pgfault_upcall);
  801046:	83 ec 08             	sub    $0x8,%esp
  801049:	a1 04 20 80 00       	mov    0x802004,%eax
  80104e:	8b 40 68             	mov    0x68(%eax),%eax
  801051:	50                   	push   %eax
  801052:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801055:	e8 e8 fc ff ff       	call   800d42 <sys_env_set_pgfault_upcall>
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE))) {
  80105a:	83 c4 08             	add    $0x8,%esp
  80105d:	6a 01                	push   $0x1
  80105f:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  801062:	e8 37 fc ff ff       	call   800c9e <sys_env_set_status>
  801067:	83 c4 10             	add    $0x10,%esp
        panic("in fork->sys_env_status %e",r);
    }
    //cprintf("fork ok %d\n",sys_getenvid());
    return envid;
  80106a:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
  80106d:	85 c0                	test   %eax,%eax
  80106f:	74 15                	je     801086 <fork+0x125>
  801071:	50                   	push   %eax
  801072:	68 ea 17 80 00       	push   $0x8017ea
  801077:	68 b0 00 00 00       	push   $0xb0
  80107c:	68 b6 17 80 00       	push   $0x8017b6
  801081:	e8 26 00 00 00       	call   8010ac <_panic>
    //panic("fork not implemented");
}
  801086:	89 d0                	mov    %edx,%eax
  801088:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <sfork>:

// Challenge!
int
sfork(void)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 0c             	sub    $0xc,%esp
    panic("sfork not implemented");
  801096:	68 05 18 80 00       	push   $0x801805
  80109b:	68 bb 00 00 00       	push   $0xbb
  8010a0:	68 b6 17 80 00       	push   $0x8017b6
  8010a5:	e8 02 00 00 00       	call   8010ac <_panic>
	...

008010ac <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	53                   	push   %ebx
  8010b0:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  8010b3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8010b6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010bd:	74 16                	je     8010d5 <_panic+0x29>
		cprintf("%s: ", argv0);
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	ff 35 08 20 80 00    	pushl  0x802008
  8010c8:	68 8b 18 80 00       	push   $0x80188b
  8010cd:	e8 3e f1 ff ff       	call   800210 <cprintf>
  8010d2:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8010d5:	ff 75 0c             	pushl  0xc(%ebp)
  8010d8:	ff 75 08             	pushl  0x8(%ebp)
  8010db:	ff 35 00 20 80 00    	pushl  0x802000
  8010e1:	68 90 18 80 00       	push   $0x801890
  8010e6:	e8 25 f1 ff ff       	call   800210 <cprintf>
	vcprintf(fmt, ap);
  8010eb:	83 c4 08             	add    $0x8,%esp
  8010ee:	53                   	push   %ebx
  8010ef:	ff 75 10             	pushl  0x10(%ebp)
  8010f2:	e8 c8 f0 ff ff       	call   8001bf <vcprintf>
	cprintf("\n");
  8010f7:	c7 04 24 9b 14 80 00 	movl   $0x80149b,(%esp)
  8010fe:	e8 0d f1 ff ff       	call   800210 <cprintf>

	// Cause a breakpoint exception
	while (1)
  801103:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  801106:	cc                   	int3   
  801107:	eb fd                	jmp    801106 <_panic+0x5a>
}
  801109:	00 00                	add    %al,(%eax)
	...

0080110c <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == NULL) {
  801112:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801119:	75 2a                	jne    801145 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
        //cprintf("i'm in set pgfault_handler,before alloc\n");
        if(sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W)) {//maybe not PTE_USER
  80111b:	83 ec 04             	sub    $0x4,%esp
  80111e:	6a 07                	push   $0x7
  801120:	68 00 f0 bf ee       	push   $0xeebff000
  801125:	6a 00                	push   $0x0
  801127:	e8 7b fa ff ff       	call   800ba7 <sys_page_alloc>
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	75 1a                	jne    80114d <set_pgfault_handler+0x41>
            return;
        }
        //cprintf("i'm in set pgfault_handler,after alloc\n");
        sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  801133:	83 ec 08             	sub    $0x8,%esp
  801136:	68 50 11 80 00       	push   $0x801150
  80113b:	6a 00                	push   $0x0
  80113d:	e8 00 fc ff ff       	call   800d42 <sys_env_set_pgfault_upcall>
  801142:	83 c4 10             	add    $0x10,%esp
        //cprintf("here in set pgfault handler\n");
		//panic("set_pgfault_handler not implemented");
	}
	// Save handler pointer for assembly to call.
    //cprintf("handler %x;pgfault_handler address %x,upcall address %x,upcall points %x\n",handler,&_pgfault_handler,&_pgfault_upcall,_pgfault_upcall);
	_pgfault_handler = handler;
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	a3 0c 20 80 00       	mov    %eax,0x80200c
    //cprintf("here\n");
    //it should be ok
}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    
	...

00801150 <_pgfault_upcall>:
  801150:	54                   	push   %esp
  801151:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801156:	ff d0                	call   *%eax
  801158:	83 c4 04             	add    $0x4,%esp
  80115b:	83 c4 08             	add    $0x8,%esp
  80115e:	8b 54 24 20          	mov    0x20(%esp),%edx
  801162:	8b 44 24 28          	mov    0x28(%esp),%eax
  801166:	83 e8 04             	sub    $0x4,%eax
  801169:	89 10                	mov    %edx,(%eax)
  80116b:	89 44 24 28          	mov    %eax,0x28(%esp)
  80116f:	61                   	popa   
  801170:	83 c4 04             	add    $0x4,%esp
  801173:	9d                   	popf   
  801174:	5c                   	pop    %esp
  801175:	c3                   	ret    
	...

00801178 <__udivdi3>:
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	83 ec 20             	sub    $0x20,%esp
  801180:	8b 55 14             	mov    0x14(%ebp),%edx
  801183:	8b 75 08             	mov    0x8(%ebp),%esi
  801186:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801189:	8b 45 10             	mov    0x10(%ebp),%eax
  80118c:	85 d2                	test   %edx,%edx
  80118e:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  801191:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  801198:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  80119f:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  8011a2:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  8011a5:	89 fe                	mov    %edi,%esi
  8011a7:	75 5b                	jne    801204 <__udivdi3+0x8c>
  8011a9:	39 f8                	cmp    %edi,%eax
  8011ab:	76 2b                	jbe    8011d8 <__udivdi3+0x60>
  8011ad:	89 fa                	mov    %edi,%edx
  8011af:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8011b2:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8011b5:	89 c7                	mov    %eax,%edi
  8011b7:	90                   	nop    
  8011b8:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  8011bf:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  8011c2:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  8011c5:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  8011c8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8011cb:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  8011ce:	83 c4 20             	add    $0x20,%esp
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    
  8011d5:	8d 76 00             	lea    0x0(%esi),%esi
  8011d8:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	75 0e                	jne    8011ed <__udivdi3+0x75>
  8011df:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e4:	31 c9                	xor    %ecx,%ecx
  8011e6:	31 d2                	xor    %edx,%edx
  8011e8:	f7 f1                	div    %ecx
  8011ea:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  8011ed:	89 f0                	mov    %esi,%eax
  8011ef:	31 d2                	xor    %edx,%edx
  8011f1:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8011f4:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8011f7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8011fa:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8011fd:	89 c7                	mov    %eax,%edi
  8011ff:	eb be                	jmp    8011bf <__udivdi3+0x47>
  801201:	8d 76 00             	lea    0x0(%esi),%esi
  801204:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  801207:	76 07                	jbe    801210 <__udivdi3+0x98>
  801209:	31 ff                	xor    %edi,%edi
  80120b:	eb ab                	jmp    8011b8 <__udivdi3+0x40>
  80120d:	8d 76 00             	lea    0x0(%esi),%esi
  801210:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  801214:	89 c7                	mov    %eax,%edi
  801216:	83 f7 1f             	xor    $0x1f,%edi
  801219:	75 19                	jne    801234 <__udivdi3+0xbc>
  80121b:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  80121e:	77 0a                	ja     80122a <__udivdi3+0xb2>
  801220:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801223:	31 ff                	xor    %edi,%edi
  801225:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  801228:	72 8e                	jb     8011b8 <__udivdi3+0x40>
  80122a:	bf 01 00 00 00       	mov    $0x1,%edi
  80122f:	eb 87                	jmp    8011b8 <__udivdi3+0x40>
  801231:	8d 76 00             	lea    0x0(%esi),%esi
  801234:	b8 20 00 00 00       	mov    $0x20,%eax
  801239:	29 f8                	sub    %edi,%eax
  80123b:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80123e:	89 f9                	mov    %edi,%ecx
  801240:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801243:	d3 e2                	shl    %cl,%edx
  801245:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  801248:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  80124b:	d3 e8                	shr    %cl,%eax
  80124d:	09 c2                	or     %eax,%edx
  80124f:	89 f9                	mov    %edi,%ecx
  801251:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  801254:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  801257:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  80125a:	89 f2                	mov    %esi,%edx
  80125c:	d3 ea                	shr    %cl,%edx
  80125e:	89 f9                	mov    %edi,%ecx
  801260:	d3 e6                	shl    %cl,%esi
  801262:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  801265:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  801268:	d3 e8                	shr    %cl,%eax
  80126a:	09 c6                	or     %eax,%esi
  80126c:	89 f9                	mov    %edi,%ecx
  80126e:	89 f0                	mov    %esi,%eax
  801270:	f7 75 ec             	divl   0xffffffec(%ebp)
  801273:	89 d6                	mov    %edx,%esi
  801275:	89 c7                	mov    %eax,%edi
  801277:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  80127a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  80127d:	f7 e7                	mul    %edi
  80127f:	39 f2                	cmp    %esi,%edx
  801281:	77 0f                	ja     801292 <__udivdi3+0x11a>
  801283:	0f 85 2f ff ff ff    	jne    8011b8 <__udivdi3+0x40>
  801289:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  80128c:	0f 86 26 ff ff ff    	jbe    8011b8 <__udivdi3+0x40>
  801292:	4f                   	dec    %edi
  801293:	e9 20 ff ff ff       	jmp    8011b8 <__udivdi3+0x40>

00801298 <__umoddi3>:
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	83 ec 30             	sub    $0x30,%esp
  8012a0:	8b 55 14             	mov    0x14(%ebp),%edx
  8012a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ac:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  8012af:	85 d2                	test   %edx,%edx
  8012b1:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  8012b8:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  8012bf:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  8012c2:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  8012c5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8012c8:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  8012cb:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  8012ce:	75 68                	jne    801338 <__umoddi3+0xa0>
  8012d0:	39 f8                	cmp    %edi,%eax
  8012d2:	76 3c                	jbe    801310 <__umoddi3+0x78>
  8012d4:	89 f0                	mov    %esi,%eax
  8012d6:	89 fa                	mov    %edi,%edx
  8012d8:	f7 75 cc             	divl   0xffffffcc(%ebp)
  8012db:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  8012de:	85 c9                	test   %ecx,%ecx
  8012e0:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  8012e3:	74 1b                	je     801300 <__umoddi3+0x68>
  8012e5:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8012e8:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  8012eb:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  8012f2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8012f5:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  8012f8:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  8012fb:	89 10                	mov    %edx,(%eax)
  8012fd:	89 48 04             	mov    %ecx,0x4(%eax)
  801300:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801303:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801306:	83 c4 30             	add    $0x30,%esp
  801309:	5e                   	pop    %esi
  80130a:	5f                   	pop    %edi
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    
  80130d:	8d 76 00             	lea    0x0(%esi),%esi
  801310:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  801313:	85 f6                	test   %esi,%esi
  801315:	75 0d                	jne    801324 <__umoddi3+0x8c>
  801317:	b8 01 00 00 00       	mov    $0x1,%eax
  80131c:	31 d2                	xor    %edx,%edx
  80131e:	f7 75 cc             	divl   0xffffffcc(%ebp)
  801321:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  801324:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  801327:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80132a:	f7 75 cc             	divl   0xffffffcc(%ebp)
  80132d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801330:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801333:	f7 75 cc             	divl   0xffffffcc(%ebp)
  801336:	eb a3                	jmp    8012db <__umoddi3+0x43>
  801338:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80133b:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  80133e:	76 14                	jbe    801354 <__umoddi3+0xbc>
  801340:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  801343:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  801346:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801349:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  80134c:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  80134f:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  801352:	eb ac                	jmp    801300 <__umoddi3+0x68>
  801354:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  801358:	89 c6                	mov    %eax,%esi
  80135a:	83 f6 1f             	xor    $0x1f,%esi
  80135d:	75 4d                	jne    8013ac <__umoddi3+0x114>
  80135f:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801362:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  801365:	77 08                	ja     80136f <__umoddi3+0xd7>
  801367:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  80136a:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  80136d:	72 12                	jb     801381 <__umoddi3+0xe9>
  80136f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801372:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801375:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  801378:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80137b:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  80137e:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801381:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801384:	85 d2                	test   %edx,%edx
  801386:	0f 84 74 ff ff ff    	je     801300 <__umoddi3+0x68>
  80138c:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80138f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801392:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801395:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  801398:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  80139b:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  80139e:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  8013a1:	89 01                	mov    %eax,(%ecx)
  8013a3:	89 51 04             	mov    %edx,0x4(%ecx)
  8013a6:	e9 55 ff ff ff       	jmp    801300 <__umoddi3+0x68>
  8013ab:	90                   	nop    
  8013ac:	b8 20 00 00 00       	mov    $0x20,%eax
  8013b1:	29 f0                	sub    %esi,%eax
  8013b3:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  8013b6:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  8013b9:	89 f1                	mov    %esi,%ecx
  8013bb:	d3 e2                	shl    %cl,%edx
  8013bd:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  8013c0:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8013c3:	d3 e8                	shr    %cl,%eax
  8013c5:	09 c2                	or     %eax,%edx
  8013c7:	89 f1                	mov    %esi,%ecx
  8013c9:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  8013cc:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  8013cf:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8013d2:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8013d5:	d3 ea                	shr    %cl,%edx
  8013d7:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  8013da:	89 f1                	mov    %esi,%ecx
  8013dc:	d3 e7                	shl    %cl,%edi
  8013de:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8013e1:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8013e4:	d3 e8                	shr    %cl,%eax
  8013e6:	09 c7                	or     %eax,%edi
  8013e8:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  8013eb:	89 f8                	mov    %edi,%eax
  8013ed:	89 f1                	mov    %esi,%ecx
  8013ef:	f7 75 dc             	divl   0xffffffdc(%ebp)
  8013f2:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8013f5:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  8013f8:	f7 65 cc             	mull   0xffffffcc(%ebp)
  8013fb:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  8013fe:	89 c7                	mov    %eax,%edi
  801400:	77 3f                	ja     801441 <__umoddi3+0x1a9>
  801402:	74 38                	je     80143c <__umoddi3+0x1a4>
  801404:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  801407:	85 c0                	test   %eax,%eax
  801409:	0f 84 f1 fe ff ff    	je     801300 <__umoddi3+0x68>
  80140f:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  801412:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801415:	29 f8                	sub    %edi,%eax
  801417:	19 d1                	sbb    %edx,%ecx
  801419:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  80141c:	89 ca                	mov    %ecx,%edx
  80141e:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801421:	d3 e2                	shl    %cl,%edx
  801423:	89 f1                	mov    %esi,%ecx
  801425:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801428:	d3 e8                	shr    %cl,%eax
  80142a:	09 c2                	or     %eax,%edx
  80142c:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  80142f:	d3 e8                	shr    %cl,%eax
  801431:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  801434:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  801437:	e9 b6 fe ff ff       	jmp    8012f2 <__umoddi3+0x5a>
  80143c:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  80143f:	76 c3                	jbe    801404 <__umoddi3+0x16c>
  801441:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  801444:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  801447:	eb bb                	jmp    801404 <__umoddi3+0x16c>
  801449:	90                   	nop    
  80144a:	90                   	nop    
  80144b:	90                   	nop    
