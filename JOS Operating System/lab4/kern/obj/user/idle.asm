
obj/user/idle：     文件格式 elf32-i386

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
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 80 	movl   $0x801080,0x802000
  800041:	10 80 00 

	// Loop forever, simply trying to yield to a different environment.
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 63 01 00 00       	call   8001ac <sys_yield>

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800049:	cc                   	int3   
  80004a:	eb f8                	jmp    800044 <umain+0x10>

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
  800057:	e8 f2 00 00 00       	call   80014e <sys_getenvid>
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
  800098:	e8 60 00 00 00       	call   8000fd <sys_env_destroy>
}
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    
	...

008000a0 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8000b1:	89 f8                	mov    %edi,%eax
  8000b3:	89 fb                	mov    %edi,%ebx
  8000b5:	89 fe                	mov    %edi,%esi
  8000b7:	55                   	push   %ebp
  8000b8:	9c                   	pushf  
  8000b9:	56                   	push   %esi
  8000ba:	54                   	push   %esp
  8000bb:	5d                   	pop    %ebp
  8000bc:	8d 35 c4 00 80 00    	lea    0x8000c4,%esi
  8000c2:	0f 34                	sysenter 
  8000c4:	83 c4 04             	add    $0x4,%esp
  8000c7:	9d                   	popf   
  8000c8:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	bf 00 00 00 00       	mov    $0x0,%edi
  8000de:	89 fa                	mov    %edi,%edx
  8000e0:	89 f9                	mov    %edi,%ecx
  8000e2:	89 fb                	mov    %edi,%ebx
  8000e4:	89 fe                	mov    %edi,%esi
  8000e6:	55                   	push   %ebp
  8000e7:	9c                   	pushf  
  8000e8:	56                   	push   %esi
  8000e9:	54                   	push   %esp
  8000ea:	5d                   	pop    %ebp
  8000eb:	8d 35 f3 00 80 00    	lea    0x8000f3,%esi
  8000f1:	0f 34                	sysenter 
  8000f3:	83 c4 04             	add    $0x4,%esp
  8000f6:	9d                   	popf   
  8000f7:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	b8 03 00 00 00       	mov    $0x3,%eax
  80010e:	bf 00 00 00 00       	mov    $0x0,%edi
  800113:	89 f9                	mov    %edi,%ecx
  800115:	89 fb                	mov    %edi,%ebx
  800117:	89 fe                	mov    %edi,%esi
  800119:	55                   	push   %ebp
  80011a:	9c                   	pushf  
  80011b:	56                   	push   %esi
  80011c:	54                   	push   %esp
  80011d:	5d                   	pop    %ebp
  80011e:	8d 35 26 01 80 00    	lea    0x800126,%esi
  800124:	0f 34                	sysenter 
  800126:	83 c4 04             	add    $0x4,%esp
  800129:	9d                   	popf   
  80012a:	5d                   	pop    %ebp
  80012b:	85 c0                	test   %eax,%eax
  80012d:	7e 17                	jle    800146 <sys_env_destroy+0x49>
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	50                   	push   %eax
  800133:	6a 03                	push   $0x3
  800135:	68 9c 10 80 00       	push   $0x80109c
  80013a:	6a 4c                	push   $0x4c
  80013c:	68 b9 10 80 00       	push   $0x8010b9
  800141:	e8 06 03 00 00       	call   80044c <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800146:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	b8 02 00 00 00       	mov    $0x2,%eax
  800159:	bf 00 00 00 00       	mov    $0x0,%edi
  80015e:	89 fa                	mov    %edi,%edx
  800160:	89 f9                	mov    %edi,%ecx
  800162:	89 fb                	mov    %edi,%ebx
  800164:	89 fe                	mov    %edi,%esi
  800166:	55                   	push   %ebp
  800167:	9c                   	pushf  
  800168:	56                   	push   %esi
  800169:	54                   	push   %esp
  80016a:	5d                   	pop    %ebp
  80016b:	8d 35 73 01 80 00    	lea    0x800173,%esi
  800171:	0f 34                	sysenter 
  800173:	83 c4 04             	add    $0x4,%esp
  800176:	9d                   	popf   
  800177:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    

0080017d <sys_dump_env>:

int
sys_dump_env(void)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	b8 04 00 00 00       	mov    $0x4,%eax
  800188:	bf 00 00 00 00       	mov    $0x0,%edi
  80018d:	89 fa                	mov    %edi,%edx
  80018f:	89 f9                	mov    %edi,%ecx
  800191:	89 fb                	mov    %edi,%ebx
  800193:	89 fe                	mov    %edi,%esi
  800195:	55                   	push   %ebp
  800196:	9c                   	pushf  
  800197:	56                   	push   %esi
  800198:	54                   	push   %esp
  800199:	5d                   	pop    %ebp
  80019a:	8d 35 a2 01 80 00    	lea    0x8001a2,%esi
  8001a0:	0f 34                	sysenter 
  8001a2:	83 c4 04             	add    $0x4,%esp
  8001a5:	9d                   	popf   
  8001a6:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  8001a7:	5b                   	pop    %ebx
  8001a8:	5e                   	pop    %esi
  8001a9:	5f                   	pop    %edi
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <sys_yield>:

void
sys_yield(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001b7:	bf 00 00 00 00       	mov    $0x0,%edi
  8001bc:	89 fa                	mov    %edi,%edx
  8001be:	89 f9                	mov    %edi,%ecx
  8001c0:	89 fb                	mov    %edi,%ebx
  8001c2:	89 fe                	mov    %edi,%esi
  8001c4:	55                   	push   %ebp
  8001c5:	9c                   	pushf  
  8001c6:	56                   	push   %esi
  8001c7:	54                   	push   %esp
  8001c8:	5d                   	pop    %ebp
  8001c9:	8d 35 d1 01 80 00    	lea    0x8001d1,%esi
  8001cf:	0f 34                	sysenter 
  8001d1:	83 c4 04             	add    $0x4,%esp
  8001d4:	9d                   	popf   
  8001d5:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ed:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8001f7:	89 fe                	mov    %edi,%esi
  8001f9:	55                   	push   %ebp
  8001fa:	9c                   	pushf  
  8001fb:	56                   	push   %esi
  8001fc:	54                   	push   %esp
  8001fd:	5d                   	pop    %ebp
  8001fe:	8d 35 06 02 80 00    	lea    0x800206,%esi
  800204:	0f 34                	sysenter 
  800206:	83 c4 04             	add    $0x4,%esp
  800209:	9d                   	popf   
  80020a:	5d                   	pop    %ebp
  80020b:	85 c0                	test   %eax,%eax
  80020d:	7e 17                	jle    800226 <sys_page_alloc+0x4b>
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	50                   	push   %eax
  800213:	6a 05                	push   $0x5
  800215:	68 9c 10 80 00       	push   $0x80109c
  80021a:	6a 4c                	push   $0x4c
  80021c:	68 b9 10 80 00       	push   $0x8010b9
  800221:	e8 26 02 00 00       	call   80044c <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800226:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800240:	8b 7d 14             	mov    0x14(%ebp),%edi
  800243:	8b 75 18             	mov    0x18(%ebp),%esi
  800246:	b8 06 00 00 00       	mov    $0x6,%eax
  80024b:	55                   	push   %ebp
  80024c:	9c                   	pushf  
  80024d:	56                   	push   %esi
  80024e:	54                   	push   %esp
  80024f:	5d                   	pop    %ebp
  800250:	8d 35 58 02 80 00    	lea    0x800258,%esi
  800256:	0f 34                	sysenter 
  800258:	83 c4 04             	add    $0x4,%esp
  80025b:	9d                   	popf   
  80025c:	5d                   	pop    %ebp
  80025d:	85 c0                	test   %eax,%eax
  80025f:	7e 17                	jle    800278 <sys_page_map+0x4a>
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	50                   	push   %eax
  800265:	6a 06                	push   $0x6
  800267:	68 9c 10 80 00       	push   $0x80109c
  80026c:	6a 4c                	push   $0x4c
  80026e:	68 b9 10 80 00       	push   $0x8010b9
  800273:	e8 d4 01 00 00       	call   80044c <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800278:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	b8 07 00 00 00       	mov    $0x7,%eax
  800294:	bf 00 00 00 00       	mov    $0x0,%edi
  800299:	89 fb                	mov    %edi,%ebx
  80029b:	89 fe                	mov    %edi,%esi
  80029d:	55                   	push   %ebp
  80029e:	9c                   	pushf  
  80029f:	56                   	push   %esi
  8002a0:	54                   	push   %esp
  8002a1:	5d                   	pop    %ebp
  8002a2:	8d 35 aa 02 80 00    	lea    0x8002aa,%esi
  8002a8:	0f 34                	sysenter 
  8002aa:	83 c4 04             	add    $0x4,%esp
  8002ad:	9d                   	popf   
  8002ae:	5d                   	pop    %ebp
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	7e 17                	jle    8002ca <sys_page_unmap+0x4a>
  8002b3:	83 ec 0c             	sub    $0xc,%esp
  8002b6:	50                   	push   %eax
  8002b7:	6a 07                	push   $0x7
  8002b9:	68 9c 10 80 00       	push   $0x80109c
  8002be:	6a 4c                	push   $0x4c
  8002c0:	68 b9 10 80 00       	push   $0x8010b9
  8002c5:	e8 82 01 00 00       	call   80044c <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ca:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e6:	bf 00 00 00 00       	mov    $0x0,%edi
  8002eb:	89 fb                	mov    %edi,%ebx
  8002ed:	89 fe                	mov    %edi,%esi
  8002ef:	55                   	push   %ebp
  8002f0:	9c                   	pushf  
  8002f1:	56                   	push   %esi
  8002f2:	54                   	push   %esp
  8002f3:	5d                   	pop    %ebp
  8002f4:	8d 35 fc 02 80 00    	lea    0x8002fc,%esi
  8002fa:	0f 34                	sysenter 
  8002fc:	83 c4 04             	add    $0x4,%esp
  8002ff:	9d                   	popf   
  800300:	5d                   	pop    %ebp
  800301:	85 c0                	test   %eax,%eax
  800303:	7e 17                	jle    80031c <sys_env_set_status+0x4a>
  800305:	83 ec 0c             	sub    $0xc,%esp
  800308:	50                   	push   %eax
  800309:	6a 09                	push   $0x9
  80030b:	68 9c 10 80 00       	push   $0x80109c
  800310:	6a 4c                	push   $0x4c
  800312:	68 b9 10 80 00       	push   $0x8010b9
  800317:	e8 30 01 00 00       	call   80044c <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80031c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80031f:	5b                   	pop    %ebx
  800320:	5e                   	pop    %esi
  800321:	5f                   	pop    %edi
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 0c             	sub    $0xc,%esp
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800333:	b8 0a 00 00 00       	mov    $0xa,%eax
  800338:	bf 00 00 00 00       	mov    $0x0,%edi
  80033d:	89 fb                	mov    %edi,%ebx
  80033f:	89 fe                	mov    %edi,%esi
  800341:	55                   	push   %ebp
  800342:	9c                   	pushf  
  800343:	56                   	push   %esi
  800344:	54                   	push   %esp
  800345:	5d                   	pop    %ebp
  800346:	8d 35 4e 03 80 00    	lea    0x80034e,%esi
  80034c:	0f 34                	sysenter 
  80034e:	83 c4 04             	add    $0x4,%esp
  800351:	9d                   	popf   
  800352:	5d                   	pop    %ebp
  800353:	85 c0                	test   %eax,%eax
  800355:	7e 17                	jle    80036e <sys_env_set_trapframe+0x4a>
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	50                   	push   %eax
  80035b:	6a 0a                	push   $0xa
  80035d:	68 9c 10 80 00       	push   $0x80109c
  800362:	6a 4c                	push   $0x4c
  800364:	68 b9 10 80 00       	push   $0x8010b9
  800369:	e8 de 00 00 00       	call   80044c <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80036e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	c9                   	leave  
  800375:	c3                   	ret    

00800376 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 0c             	sub    $0xc,%esp
  80037f:	8b 55 08             	mov    0x8(%ebp),%edx
  800382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800385:	b8 0b 00 00 00       	mov    $0xb,%eax
  80038a:	bf 00 00 00 00       	mov    $0x0,%edi
  80038f:	89 fb                	mov    %edi,%ebx
  800391:	89 fe                	mov    %edi,%esi
  800393:	55                   	push   %ebp
  800394:	9c                   	pushf  
  800395:	56                   	push   %esi
  800396:	54                   	push   %esp
  800397:	5d                   	pop    %ebp
  800398:	8d 35 a0 03 80 00    	lea    0x8003a0,%esi
  80039e:	0f 34                	sysenter 
  8003a0:	83 c4 04             	add    $0x4,%esp
  8003a3:	9d                   	popf   
  8003a4:	5d                   	pop    %ebp
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	7e 17                	jle    8003c0 <sys_env_set_pgfault_upcall+0x4a>
  8003a9:	83 ec 0c             	sub    $0xc,%esp
  8003ac:	50                   	push   %eax
  8003ad:	6a 0b                	push   $0xb
  8003af:	68 9c 10 80 00       	push   $0x80109c
  8003b4:	6a 4c                	push   $0x4c
  8003b6:	68 b9 10 80 00       	push   $0x8010b9
  8003bb:	e8 8c 00 00 00       	call   80044c <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003c0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8003c3:	5b                   	pop    %ebx
  8003c4:	5e                   	pop    %esi
  8003c5:	5f                   	pop    %edi
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	57                   	push   %edi
  8003cc:	56                   	push   %esi
  8003cd:	53                   	push   %ebx
  8003ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003da:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003df:	be 00 00 00 00       	mov    $0x0,%esi
  8003e4:	55                   	push   %ebp
  8003e5:	9c                   	pushf  
  8003e6:	56                   	push   %esi
  8003e7:	54                   	push   %esp
  8003e8:	5d                   	pop    %ebp
  8003e9:	8d 35 f1 03 80 00    	lea    0x8003f1,%esi
  8003ef:	0f 34                	sysenter 
  8003f1:	83 c4 04             	add    $0x4,%esp
  8003f4:	9d                   	popf   
  8003f5:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003f6:	5b                   	pop    %ebx
  8003f7:	5e                   	pop    %esi
  8003f8:	5f                   	pop    %edi
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    

008003fb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	57                   	push   %edi
  8003ff:	56                   	push   %esi
  800400:	53                   	push   %ebx
  800401:	83 ec 0c             	sub    $0xc,%esp
  800404:	8b 55 08             	mov    0x8(%ebp),%edx
  800407:	b8 0e 00 00 00       	mov    $0xe,%eax
  80040c:	bf 00 00 00 00       	mov    $0x0,%edi
  800411:	89 f9                	mov    %edi,%ecx
  800413:	89 fb                	mov    %edi,%ebx
  800415:	89 fe                	mov    %edi,%esi
  800417:	55                   	push   %ebp
  800418:	9c                   	pushf  
  800419:	56                   	push   %esi
  80041a:	54                   	push   %esp
  80041b:	5d                   	pop    %ebp
  80041c:	8d 35 24 04 80 00    	lea    0x800424,%esi
  800422:	0f 34                	sysenter 
  800424:	83 c4 04             	add    $0x4,%esp
  800427:	9d                   	popf   
  800428:	5d                   	pop    %ebp
  800429:	85 c0                	test   %eax,%eax
  80042b:	7e 17                	jle    800444 <sys_ipc_recv+0x49>
  80042d:	83 ec 0c             	sub    $0xc,%esp
  800430:	50                   	push   %eax
  800431:	6a 0e                	push   $0xe
  800433:	68 9c 10 80 00       	push   $0x80109c
  800438:	6a 4c                	push   $0x4c
  80043a:	68 b9 10 80 00       	push   $0x8010b9
  80043f:	e8 08 00 00 00       	call   80044c <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800444:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800447:	5b                   	pop    %ebx
  800448:	5e                   	pop    %esi
  800449:	5f                   	pop    %edi
  80044a:	c9                   	leave  
  80044b:	c3                   	ret    

0080044c <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	53                   	push   %ebx
  800450:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  800453:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800456:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80045d:	74 16                	je     800475 <_panic+0x29>
		cprintf("%s: ", argv0);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 35 08 20 80 00    	pushl  0x802008
  800468:	68 c7 10 80 00       	push   $0x8010c7
  80046d:	e8 ca 00 00 00       	call   80053c <cprintf>
  800472:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800475:	ff 75 0c             	pushl  0xc(%ebp)
  800478:	ff 75 08             	pushl  0x8(%ebp)
  80047b:	ff 35 00 20 80 00    	pushl  0x802000
  800481:	68 cc 10 80 00       	push   $0x8010cc
  800486:	e8 b1 00 00 00       	call   80053c <cprintf>
	vcprintf(fmt, ap);
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	ff 75 10             	pushl  0x10(%ebp)
  800492:	e8 54 00 00 00       	call   8004eb <vcprintf>
	cprintf("\n");
  800497:	c7 04 24 e8 10 80 00 	movl   $0x8010e8,(%esp)
  80049e:	e8 99 00 00 00       	call   80053c <cprintf>

	// Cause a breakpoint exception
	while (1)
  8004a3:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8004a6:	cc                   	int3   
  8004a7:	eb fd                	jmp    8004a6 <_panic+0x5a>
}
  8004a9:	00 00                	add    %al,(%eax)
	...

008004ac <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 04             	sub    $0x4,%esp
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b6:	8b 03                	mov    (%ebx),%eax
  8004b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bf:	40                   	inc    %eax
  8004c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c7:	75 1a                	jne    8004e3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	68 ff 00 00 00       	push   $0xff
  8004d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d4:	50                   	push   %eax
  8004d5:	e8 c6 fb ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8004da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004e0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004e3:	ff 43 04             	incl   0x4(%ebx)
}
  8004e6:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004f4:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8004fb:	00 00 00 
	b.cnt = 0;
  8004fe:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800505:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800508:	ff 75 0c             	pushl  0xc(%ebp)
  80050b:	ff 75 08             	pushl  0x8(%ebp)
  80050e:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800514:	50                   	push   %eax
  800515:	68 ac 04 80 00       	push   $0x8004ac
  80051a:	e8 83 01 00 00       	call   8006a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80051f:	83 c4 08             	add    $0x8,%esp
  800522:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800528:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	e8 6c fb ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
  800534:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    

0080053c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800542:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 9d ff ff ff       	call   8004eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 0c             	sub    $0xc,%esp
  800559:	8b 75 10             	mov    0x10(%ebp),%esi
  80055c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80055f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800562:	8b 45 18             	mov    0x18(%ebp),%eax
  800565:	ba 00 00 00 00       	mov    $0x0,%edx
  80056a:	39 d7                	cmp    %edx,%edi
  80056c:	72 39                	jb     8005a7 <printnum+0x57>
  80056e:	77 04                	ja     800574 <printnum+0x24>
  800570:	39 c6                	cmp    %eax,%esi
  800572:	72 33                	jb     8005a7 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800574:	83 ec 04             	sub    $0x4,%esp
  800577:	ff 75 20             	pushl  0x20(%ebp)
  80057a:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  80057d:	50                   	push   %eax
  80057e:	ff 75 18             	pushl  0x18(%ebp)
  800581:	8b 45 18             	mov    0x18(%ebp),%eax
  800584:	ba 00 00 00 00       	mov    $0x0,%edx
  800589:	52                   	push   %edx
  80058a:	50                   	push   %eax
  80058b:	57                   	push   %edi
  80058c:	56                   	push   %esi
  80058d:	e8 06 08 00 00       	call   800d98 <__udivdi3>
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	52                   	push   %edx
  800596:	50                   	push   %eax
  800597:	ff 75 0c             	pushl  0xc(%ebp)
  80059a:	ff 75 08             	pushl  0x8(%ebp)
  80059d:	e8 ae ff ff ff       	call   800550 <printnum>
  8005a2:	83 c4 20             	add    $0x20,%esp
  8005a5:	eb 19                	jmp    8005c0 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005a7:	4b                   	dec    %ebx
  8005a8:	85 db                	test   %ebx,%ebx
  8005aa:	7e 14                	jle    8005c0 <printnum+0x70>
			putch(padc, putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 0c             	pushl  0xc(%ebp)
  8005b2:	ff 75 20             	pushl  0x20(%ebp)
  8005b5:	ff 55 08             	call   *0x8(%ebp)
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	4b                   	dec    %ebx
  8005bc:	85 db                	test   %ebx,%ebx
  8005be:	7f ec                	jg     8005ac <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	ff 75 0c             	pushl  0xc(%ebp)
  8005c6:	8b 45 18             	mov    0x18(%ebp),%eax
  8005c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ce:	83 ec 04             	sub    $0x4,%esp
  8005d1:	52                   	push   %edx
  8005d2:	50                   	push   %eax
  8005d3:	57                   	push   %edi
  8005d4:	56                   	push   %esi
  8005d5:	e8 de 08 00 00       	call   800eb8 <__umoddi3>
  8005da:	83 c4 14             	add    $0x14,%esp
  8005dd:	0f be 80 7d 11 80 00 	movsbl 0x80117d(%eax),%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 55 08             	call   *0x8(%ebp)
}
  8005e8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8005eb:	5b                   	pop    %ebx
  8005ec:	5e                   	pop    %esi
  8005ed:	5f                   	pop    %edi
  8005ee:	c9                   	leave  
  8005ef:	c3                   	ret    

008005f0 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  8005f0:	55                   	push   %ebp
  8005f1:	89 e5                	mov    %esp,%ebp
  8005f3:	56                   	push   %esi
  8005f4:	53                   	push   %ebx
  8005f5:	83 ec 18             	sub    $0x18,%esp
  8005f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fe:	8a 45 18             	mov    0x18(%ebp),%al
  800601:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  800604:	53                   	push   %ebx
  800605:	6a 1b                	push   $0x1b
  800607:	ff d6                	call   *%esi
	putch('[', putdat);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 5b                	push   $0x5b
  80060f:	ff d6                	call   *%esi
	putch('0', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 30                	push   $0x30
  800617:	ff d6                	call   *%esi
	putch(';', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 3b                	push   $0x3b
  80061f:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800621:	83 c4 0c             	add    $0xc,%esp
  800624:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800628:	50                   	push   %eax
  800629:	ff 75 14             	pushl  0x14(%ebp)
  80062c:	6a 0a                	push   $0xa
  80062e:	8b 45 10             	mov    0x10(%ebp),%eax
  800631:	99                   	cltd   
  800632:	52                   	push   %edx
  800633:	50                   	push   %eax
  800634:	53                   	push   %ebx
  800635:	56                   	push   %esi
  800636:	e8 15 ff ff ff       	call   800550 <printnum>
	putch('m', putdat);
  80063b:	83 c4 18             	add    $0x18,%esp
  80063e:	53                   	push   %ebx
  80063f:	6a 6d                	push   $0x6d
  800641:	ff d6                	call   *%esi

}
  800643:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800646:	5b                   	pop    %ebx
  800647:	5e                   	pop    %esi
  800648:	c9                   	leave  
  800649:	c3                   	ret    

0080064a <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800650:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800653:	83 f8 01             	cmp    $0x1,%eax
  800656:	7e 0f                	jle    800667 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800658:	8b 01                	mov    (%ecx),%eax
  80065a:	83 c0 08             	add    $0x8,%eax
  80065d:	89 01                	mov    %eax,(%ecx)
  80065f:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800662:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800665:	eb 0f                	jmp    800676 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800667:	8b 01                	mov    (%ecx),%eax
  800669:	83 c0 04             	add    $0x4,%eax
  80066c:	89 01                	mov    %eax,(%ecx)
  80066e:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800676:	c9                   	leave  
  800677:	c3                   	ret    

00800678 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	8b 55 08             	mov    0x8(%ebp),%edx
  80067e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800681:	83 f8 01             	cmp    $0x1,%eax
  800684:	7e 0f                	jle    800695 <getint+0x1d>
		return va_arg(*ap, long long);
  800686:	8b 02                	mov    (%edx),%eax
  800688:	83 c0 08             	add    $0x8,%eax
  80068b:	89 02                	mov    %eax,(%edx)
  80068d:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800690:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800693:	eb 0b                	jmp    8006a0 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800695:	8b 02                	mov    (%edx),%eax
  800697:	83 c0 04             	add    $0x4,%eax
  80069a:	89 02                	mov    %eax,(%edx)
  80069c:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  80069f:	99                   	cltd   
}
  8006a0:	c9                   	leave  
  8006a1:	c3                   	ret    

008006a2 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	57                   	push   %edi
  8006a6:	56                   	push   %esi
  8006a7:	53                   	push   %ebx
  8006a8:	83 ec 1c             	sub    $0x1c,%esp
  8006ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ae:	0f b6 13             	movzbl (%ebx),%edx
  8006b1:	43                   	inc    %ebx
  8006b2:	83 fa 25             	cmp    $0x25,%edx
  8006b5:	74 1e                	je     8006d5 <vprintfmt+0x33>
			if (ch == '\0')
  8006b7:	85 d2                	test   %edx,%edx
  8006b9:	0f 84 dc 02 00 00    	je     80099b <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff 55 08             	call   *0x8(%ebp)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	0f b6 13             	movzbl (%ebx),%edx
  8006cf:	43                   	inc    %ebx
  8006d0:	83 fa 25             	cmp    $0x25,%edx
  8006d3:	75 e2                	jne    8006b7 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8006d5:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8006d9:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8006e0:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8006ea:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  8006f1:	0f b6 13             	movzbl (%ebx),%edx
  8006f4:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8006f7:	43                   	inc    %ebx
  8006f8:	83 f8 55             	cmp    $0x55,%eax
  8006fb:	0f 87 75 02 00 00    	ja     800976 <vprintfmt+0x2d4>
  800701:	ff 24 85 e4 11 80 00 	jmp    *0x8011e4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800708:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  80070c:	eb e3                	jmp    8006f1 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80070e:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800712:	eb dd                	jmp    8006f1 <vprintfmt+0x4f>

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
  800714:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800719:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80071c:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800720:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800723:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800726:	83 f8 09             	cmp    $0x9,%eax
  800729:	77 27                	ja     800752 <vprintfmt+0xb0>
  80072b:	43                   	inc    %ebx
  80072c:	eb eb                	jmp    800719 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80072e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800738:	eb 18                	jmp    800752 <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  80073a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80073e:	79 b1                	jns    8006f1 <vprintfmt+0x4f>
				width = 0;
  800740:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  800747:	eb a8                	jmp    8006f1 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800749:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800750:	eb 9f                	jmp    8006f1 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  800752:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800756:	79 99                	jns    8006f1 <vprintfmt+0x4f>
				width = precision, precision = -1;
  800758:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80075b:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800760:	eb 8f                	jmp    8006f1 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  800762:	41                   	inc    %ecx
			goto reswitch;
  800763:	eb 8c                	jmp    8006f1 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	ff 75 0c             	pushl  0xc(%ebp)
  80076b:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	ff 70 fc             	pushl  0xfffffffc(%eax)
  800775:	e9 c4 01 00 00       	jmp    80093e <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  80077a:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  800784:	85 c0                	test   %eax,%eax
  800786:	79 02                	jns    80078a <vprintfmt+0xe8>
				err = -err;
  800788:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80078a:	83 f8 08             	cmp    $0x8,%eax
  80078d:	7f 0b                	jg     80079a <vprintfmt+0xf8>
  80078f:	8b 3c 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edi
  800796:	85 ff                	test   %edi,%edi
  800798:	75 08                	jne    8007a2 <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  80079a:	50                   	push   %eax
  80079b:	68 8e 11 80 00       	push   $0x80118e
  8007a0:	eb 06                	jmp    8007a8 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8007a2:	57                   	push   %edi
  8007a3:	68 97 11 80 00       	push   $0x801197
  8007a8:	ff 75 0c             	pushl  0xc(%ebp)
  8007ab:	ff 75 08             	pushl  0x8(%ebp)
  8007ae:	e8 f0 01 00 00       	call   8009a3 <printfmt>
  8007b3:	e9 89 01 00 00       	jmp    800941 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b8:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8007c2:	85 ff                	test   %edi,%edi
  8007c4:	75 05                	jne    8007cb <vprintfmt+0x129>
				p = "(null)";
  8007c6:	bf 9a 11 80 00       	mov    $0x80119a,%edi
			if (width > 0 && padc != '-')
  8007cb:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8007cf:	7e 3b                	jle    80080c <vprintfmt+0x16a>
  8007d1:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8007d5:	74 35                	je     80080c <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	56                   	push   %esi
  8007db:	57                   	push   %edi
  8007dc:	e8 74 02 00 00       	call   800a55 <strnlen>
  8007e1:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8007eb:	7e 1f                	jle    80080c <vprintfmt+0x16a>
  8007ed:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8007f1:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8007fd:	ff 55 08             	call   *0x8(%ebp)
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800806:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80080a:	7f e8                	jg     8007f4 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080c:	0f be 17             	movsbl (%edi),%edx
  80080f:	47                   	inc    %edi
  800810:	85 d2                	test   %edx,%edx
  800812:	74 3e                	je     800852 <vprintfmt+0x1b0>
  800814:	85 f6                	test   %esi,%esi
  800816:	78 03                	js     80081b <vprintfmt+0x179>
  800818:	4e                   	dec    %esi
  800819:	78 37                	js     800852 <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  80081b:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  80081f:	74 12                	je     800833 <vprintfmt+0x191>
  800821:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800824:	83 f8 5e             	cmp    $0x5e,%eax
  800827:	76 0a                	jbe    800833 <vprintfmt+0x191>
					putch('?', putdat);
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	ff 75 0c             	pushl  0xc(%ebp)
  80082f:	6a 3f                	push   $0x3f
  800831:	eb 07                	jmp    80083a <vprintfmt+0x198>
				else
					putch(ch, putdat);
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	ff 75 0c             	pushl  0xc(%ebp)
  800839:	52                   	push   %edx
  80083a:	ff 55 08             	call   *0x8(%ebp)
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800843:	0f be 17             	movsbl (%edi),%edx
  800846:	47                   	inc    %edi
  800847:	85 d2                	test   %edx,%edx
  800849:	74 07                	je     800852 <vprintfmt+0x1b0>
  80084b:	85 f6                	test   %esi,%esi
  80084d:	78 cc                	js     80081b <vprintfmt+0x179>
  80084f:	4e                   	dec    %esi
  800850:	79 c9                	jns    80081b <vprintfmt+0x179>
			for (; width > 0; width--)
  800852:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800856:	0f 8e 52 fe ff ff    	jle    8006ae <vprintfmt+0xc>
				putch(' ', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	6a 20                	push   $0x20
  800864:	ff 55 08             	call   *0x8(%ebp)
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80086d:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800871:	7f e9                	jg     80085c <vprintfmt+0x1ba>
			break;
  800873:	e9 36 fe ff ff       	jmp    8006ae <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	51                   	push   %ecx
  80087c:	8d 45 14             	lea    0x14(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	e8 f3 fd ff ff       	call   800678 <getint>
  800885:	89 c6                	mov    %eax,%esi
  800887:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800889:	83 c4 10             	add    $0x10,%esp
  80088c:	85 d2                	test   %edx,%edx
  80088e:	79 15                	jns    8008a5 <vprintfmt+0x203>
				putch('-', putdat);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	ff 75 0c             	pushl  0xc(%ebp)
  800896:	6a 2d                	push   $0x2d
  800898:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80089b:	f7 de                	neg    %esi
  80089d:	83 d7 00             	adc    $0x0,%edi
  8008a0:	f7 df                	neg    %edi
  8008a2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008a5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8008aa:	eb 70                	jmp    80091c <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	51                   	push   %ecx
  8008b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b3:	50                   	push   %eax
  8008b4:	e8 91 fd ff ff       	call   80064a <getuint>
  8008b9:	89 c6                	mov    %eax,%esi
  8008bb:	89 d7                	mov    %edx,%edi
			base = 10;
  8008bd:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8008c2:	eb 55                	jmp    800919 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	51                   	push   %ecx
  8008c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008cb:	50                   	push   %eax
  8008cc:	e8 79 fd ff ff       	call   80064a <getuint>
  8008d1:	89 c6                	mov    %eax,%esi
  8008d3:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  8008d5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8008da:	eb 3d                	jmp    800919 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	6a 30                	push   $0x30
  8008e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008e7:	83 c4 08             	add    $0x8,%esp
  8008ea:	ff 75 0c             	pushl  0xc(%ebp)
  8008ed:	6a 78                	push   $0x78
  8008ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8008f2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8008fc:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  800901:	eb 11                	jmp    800914 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	51                   	push   %ecx
  800907:	8d 45 14             	lea    0x14(%ebp),%eax
  80090a:	50                   	push   %eax
  80090b:	e8 3a fd ff ff       	call   80064a <getuint>
  800910:	89 c6                	mov    %eax,%esi
  800912:	89 d7                	mov    %edx,%edi
			base = 16;
  800914:	ba 10 00 00 00       	mov    $0x10,%edx
  800919:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  80091c:	83 ec 04             	sub    $0x4,%esp
  80091f:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800923:	50                   	push   %eax
  800924:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800927:	52                   	push   %edx
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	ff 75 0c             	pushl  0xc(%ebp)
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 1b fc ff ff       	call   800550 <printnum>
			break;
  800935:	eb 37                	jmp    80096e <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  800937:	83 ec 08             	sub    $0x8,%esp
  80093a:	ff 75 0c             	pushl  0xc(%ebp)
  80093d:	52                   	push   %edx
  80093e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	e9 65 fd ff ff       	jmp    8006ae <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800949:	83 ec 08             	sub    $0x8,%esp
  80094c:	51                   	push   %ecx
  80094d:	8d 45 14             	lea    0x14(%ebp),%eax
  800950:	50                   	push   %eax
  800951:	e8 f4 fc ff ff       	call   80064a <getuint>
  800956:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800958:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80095c:	89 04 24             	mov    %eax,(%esp)
  80095f:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800962:	56                   	push   %esi
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	ff 75 08             	pushl  0x8(%ebp)
  800969:	e8 82 fc ff ff       	call   8005f0 <printcolor>
			break;
  80096e:	83 c4 20             	add    $0x20,%esp
  800971:	e9 38 fd ff ff       	jmp    8006ae <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800976:	83 ec 08             	sub    $0x8,%esp
  800979:	ff 75 0c             	pushl  0xc(%ebp)
  80097c:	6a 25                	push   $0x25
  80097e:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800981:	4b                   	dec    %ebx
  800982:	83 c4 10             	add    $0x10,%esp
  800985:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800989:	0f 84 1f fd ff ff    	je     8006ae <vprintfmt+0xc>
  80098f:	4b                   	dec    %ebx
  800990:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800994:	75 f9                	jne    80098f <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800996:	e9 13 fd ff ff       	jmp    8006ae <vprintfmt+0xc>
		}
	}
}
  80099b:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8009a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009ac:	50                   	push   %eax
  8009ad:	ff 75 10             	pushl  0x10(%ebp)
  8009b0:	ff 75 0c             	pushl  0xc(%ebp)
  8009b3:	ff 75 08             	pushl  0x8(%ebp)
  8009b6:	e8 e7 fc ff ff       	call   8006a2 <vprintfmt>
	va_end(ap);
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8009c3:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8009c6:	8b 0a                	mov    (%edx),%ecx
  8009c8:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8009cb:	73 07                	jae    8009d4 <sprintputch+0x17>
		*b->buf++ = ch;
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	88 01                	mov    %al,(%ecx)
  8009d2:	ff 02                	incl   (%edx)
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 18             	sub    $0x18,%esp
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8009e2:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8009e5:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8009e9:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8009ec:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8009f3:	85 d2                	test   %edx,%edx
  8009f5:	74 04                	je     8009fb <vsnprintf+0x25>
  8009f7:	85 c9                	test   %ecx,%ecx
  8009f9:	7f 07                	jg     800a02 <vsnprintf+0x2c>
		return -E_INVAL;
  8009fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a00:	eb 1d                	jmp    800a1f <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  800a02:	ff 75 14             	pushl  0x14(%ebp)
  800a05:	ff 75 10             	pushl  0x10(%ebp)
  800a08:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800a0b:	50                   	push   %eax
  800a0c:	68 bd 09 80 00       	push   $0x8009bd
  800a11:	e8 8c fc ff ff       	call   8006a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a16:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800a19:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a27:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a2a:	50                   	push   %eax
  800a2b:	ff 75 10             	pushl  0x10(%ebp)
  800a2e:	ff 75 0c             	pushl  0xc(%ebp)
  800a31:	ff 75 08             	pushl  0x8(%ebp)
  800a34:	e8 9d ff ff ff       	call   8009d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    
	...

00800a3c <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	80 3a 00             	cmpb   $0x0,(%edx)
  800a4a:	74 07                	je     800a53 <strlen+0x17>
		n++;
  800a4c:	40                   	inc    %eax
  800a4d:	42                   	inc    %edx
  800a4e:	80 3a 00             	cmpb   $0x0,(%edx)
  800a51:	75 f9                	jne    800a4c <strlen+0x10>
	return n;
}
  800a53:	c9                   	leave  
  800a54:	c3                   	ret    

00800a55 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a63:	85 d2                	test   %edx,%edx
  800a65:	74 0f                	je     800a76 <strnlen+0x21>
  800a67:	80 39 00             	cmpb   $0x0,(%ecx)
  800a6a:	74 0a                	je     800a76 <strnlen+0x21>
		n++;
  800a6c:	40                   	inc    %eax
  800a6d:	41                   	inc    %ecx
  800a6e:	4a                   	dec    %edx
  800a6f:	74 05                	je     800a76 <strnlen+0x21>
  800a71:	80 39 00             	cmpb   $0x0,(%ecx)
  800a74:	75 f6                	jne    800a6c <strnlen+0x17>
	return n;
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	53                   	push   %ebx
  800a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7f:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800a82:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800a84:	8a 02                	mov    (%edx),%al
  800a86:	42                   	inc    %edx
  800a87:	88 01                	mov    %al,(%ecx)
  800a89:	41                   	inc    %ecx
  800a8a:	84 c0                	test   %al,%al
  800a8c:	75 f6                	jne    800a84 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a8e:	89 d8                	mov    %ebx,%eax
  800a90:	5b                   	pop    %ebx
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9f:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800aa2:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800aa4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aa9:	39 f3                	cmp    %esi,%ebx
  800aab:	73 10                	jae    800abd <strncpy+0x2a>
		*dst++ = *src;
  800aad:	8a 02                	mov    (%edx),%al
  800aaf:	88 01                	mov    %al,(%ecx)
  800ab1:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800ab2:	80 3a 00             	cmpb   $0x0,(%edx)
  800ab5:	74 01                	je     800ab8 <strncpy+0x25>
			src++;
  800ab7:	42                   	inc    %edx
  800ab8:	43                   	inc    %ebx
  800ab9:	39 f3                	cmp    %esi,%ebx
  800abb:	72 f0                	jb     800aad <strncpy+0x1a>
	}
	return ret;
}
  800abd:	89 f8                	mov    %edi,%eax
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800ad2:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800ad4:	85 d2                	test   %edx,%edx
  800ad6:	74 19                	je     800af1 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800ad8:	4a                   	dec    %edx
  800ad9:	74 13                	je     800aee <strlcpy+0x2a>
  800adb:	80 39 00             	cmpb   $0x0,(%ecx)
  800ade:	74 0e                	je     800aee <strlcpy+0x2a>
			*dst++ = *src++;
  800ae0:	8a 01                	mov    (%ecx),%al
  800ae2:	41                   	inc    %ecx
  800ae3:	88 03                	mov    %al,(%ebx)
  800ae5:	43                   	inc    %ebx
  800ae6:	4a                   	dec    %edx
  800ae7:	74 05                	je     800aee <strlcpy+0x2a>
  800ae9:	80 39 00             	cmpb   $0x0,(%ecx)
  800aec:	75 f2                	jne    800ae0 <strlcpy+0x1c>
		*dst = '\0';
  800aee:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	29 f0                	sub    %esi,%eax
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 55 08             	mov    0x8(%ebp),%edx
  800aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800b02:	80 3a 00             	cmpb   $0x0,(%edx)
  800b05:	74 13                	je     800b1a <strcmp+0x21>
  800b07:	8a 02                	mov    (%edx),%al
  800b09:	3a 01                	cmp    (%ecx),%al
  800b0b:	75 0d                	jne    800b1a <strcmp+0x21>
		p++, q++;
  800b0d:	42                   	inc    %edx
  800b0e:	41                   	inc    %ecx
  800b0f:	80 3a 00             	cmpb   $0x0,(%edx)
  800b12:	74 06                	je     800b1a <strcmp+0x21>
  800b14:	8a 02                	mov    (%edx),%al
  800b16:	3a 01                	cmp    (%ecx),%al
  800b18:	74 f3                	je     800b0d <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1a:	0f b6 02             	movzbl (%edx),%eax
  800b1d:	0f b6 11             	movzbl (%ecx),%edx
  800b20:	29 d0                	sub    %edx,%eax
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	53                   	push   %ebx
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800b31:	85 c9                	test   %ecx,%ecx
  800b33:	74 1f                	je     800b54 <strncmp+0x30>
  800b35:	80 3a 00             	cmpb   $0x0,(%edx)
  800b38:	74 16                	je     800b50 <strncmp+0x2c>
  800b3a:	8a 02                	mov    (%edx),%al
  800b3c:	3a 03                	cmp    (%ebx),%al
  800b3e:	75 10                	jne    800b50 <strncmp+0x2c>
		n--, p++, q++;
  800b40:	42                   	inc    %edx
  800b41:	43                   	inc    %ebx
  800b42:	49                   	dec    %ecx
  800b43:	74 0f                	je     800b54 <strncmp+0x30>
  800b45:	80 3a 00             	cmpb   $0x0,(%edx)
  800b48:	74 06                	je     800b50 <strncmp+0x2c>
  800b4a:	8a 02                	mov    (%edx),%al
  800b4c:	3a 03                	cmp    (%ebx),%al
  800b4e:	74 f0                	je     800b40 <strncmp+0x1c>
	if (n == 0)
  800b50:	85 c9                	test   %ecx,%ecx
  800b52:	75 07                	jne    800b5b <strncmp+0x37>
		return 0;
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	eb 0a                	jmp    800b65 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5b:	0f b6 12             	movzbl (%edx),%edx
  800b5e:	0f b6 03             	movzbl (%ebx),%eax
  800b61:	29 c2                	sub    %eax,%edx
  800b63:	89 d0                	mov    %edx,%eax
}
  800b65:	8b 1c 24             	mov    (%esp),%ebx
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800b73:	80 38 00             	cmpb   $0x0,(%eax)
  800b76:	74 0a                	je     800b82 <strchr+0x18>
		if (*s == c)
  800b78:	38 10                	cmp    %dl,(%eax)
  800b7a:	74 0b                	je     800b87 <strchr+0x1d>
  800b7c:	40                   	inc    %eax
  800b7d:	80 38 00             	cmpb   $0x0,(%eax)
  800b80:	75 f6                	jne    800b78 <strchr+0xe>
			return (char *) s;
	return 0;
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800b92:	80 38 00             	cmpb   $0x0,(%eax)
  800b95:	74 0a                	je     800ba1 <strfind+0x18>
		if (*s == c)
  800b97:	38 10                	cmp    %dl,(%eax)
  800b99:	74 06                	je     800ba1 <strfind+0x18>
  800b9b:	40                   	inc    %eax
  800b9c:	80 38 00             	cmpb   $0x0,(%eax)
  800b9f:	75 f6                	jne    800b97 <strfind+0xe>
			break;
	return (char *) s;
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800baa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bad:	89 f8                	mov    %edi,%eax
  800baf:	85 c9                	test   %ecx,%ecx
  800bb1:	74 40                	je     800bf3 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb9:	75 30                	jne    800beb <memset+0x48>
  800bbb:	f6 c1 03             	test   $0x3,%cl
  800bbe:	75 2b                	jne    800beb <memset+0x48>
		c &= 0xFF;
  800bc0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bca:	c1 e0 18             	shl    $0x18,%eax
  800bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd0:	c1 e2 10             	shl    $0x10,%edx
  800bd3:	09 d0                	or     %edx,%eax
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd8:	c1 e2 08             	shl    $0x8,%edx
  800bdb:	09 d0                	or     %edx,%eax
  800bdd:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800be0:	c1 e9 02             	shr    $0x2,%ecx
  800be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be6:	fc                   	cld    
  800be7:	f3 ab                	repz stos %eax,%es:(%edi)
  800be9:	eb 06                	jmp    800bf1 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bee:	fc                   	cld    
  800bef:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bf1:	89 f8                	mov    %edi,%eax
}
  800bf3:	8b 3c 24             	mov    (%esp),%edi
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c03:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c06:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c08:	39 c6                	cmp    %eax,%esi
  800c0a:	73 33                	jae    800c3f <memmove+0x47>
  800c0c:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800c0f:	39 c2                	cmp    %eax,%edx
  800c11:	76 2c                	jbe    800c3f <memmove+0x47>
		s += n;
  800c13:	89 d6                	mov    %edx,%esi
		d += n;
  800c15:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c18:	f6 c2 03             	test   $0x3,%dl
  800c1b:	75 1b                	jne    800c38 <memmove+0x40>
  800c1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c23:	75 13                	jne    800c38 <memmove+0x40>
  800c25:	f6 c1 03             	test   $0x3,%cl
  800c28:	75 0e                	jne    800c38 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800c2a:	83 ef 04             	sub    $0x4,%edi
  800c2d:	83 ee 04             	sub    $0x4,%esi
  800c30:	c1 e9 02             	shr    $0x2,%ecx
  800c33:	fd                   	std    
  800c34:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800c36:	eb 27                	jmp    800c5f <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c38:	4f                   	dec    %edi
  800c39:	4e                   	dec    %esi
  800c3a:	fd                   	std    
  800c3b:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800c3d:	eb 20                	jmp    800c5f <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c45:	75 15                	jne    800c5c <memmove+0x64>
  800c47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4d:	75 0d                	jne    800c5c <memmove+0x64>
  800c4f:	f6 c1 03             	test   $0x3,%cl
  800c52:	75 08                	jne    800c5c <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800c54:	c1 e9 02             	shr    $0x2,%ecx
  800c57:	fc                   	cld    
  800c58:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800c5a:	eb 03                	jmp    800c5f <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c5c:	fc                   	cld    
  800c5d:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <memcpy>:

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
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c69:	ff 75 10             	pushl  0x10(%ebp)
  800c6c:	ff 75 0c             	pushl  0xc(%ebp)
  800c6f:	ff 75 08             	pushl  0x8(%ebp)
  800c72:	e8 81 ff ff ff       	call   800bf8 <memmove>
}
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	53                   	push   %ebx
  800c7d:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800c83:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  800c86:	89 d0                	mov    %edx,%eax
  800c88:	4a                   	dec    %edx
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	74 1b                	je     800ca8 <memcmp+0x2f>
		if (*s1 != *s2)
  800c8d:	8a 01                	mov    (%ecx),%al
  800c8f:	3a 03                	cmp    (%ebx),%al
  800c91:	74 0c                	je     800c9f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c93:	0f b6 d0             	movzbl %al,%edx
  800c96:	0f b6 03             	movzbl (%ebx),%eax
  800c99:	29 c2                	sub    %eax,%edx
  800c9b:	89 d0                	mov    %edx,%eax
  800c9d:	eb 0e                	jmp    800cad <memcmp+0x34>
		s1++, s2++;
  800c9f:	41                   	inc    %ecx
  800ca0:	43                   	inc    %ebx
  800ca1:	89 d0                	mov    %edx,%eax
  800ca3:	4a                   	dec    %edx
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	75 e5                	jne    800c8d <memcmp+0x14>
	}

	return 0;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cad:	5b                   	pop    %ebx
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    

00800cb0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cb9:	89 c2                	mov    %eax,%edx
  800cbb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cbe:	39 d0                	cmp    %edx,%eax
  800cc0:	73 09                	jae    800ccb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc2:	38 08                	cmp    %cl,(%eax)
  800cc4:	74 05                	je     800ccb <memfind+0x1b>
  800cc6:	40                   	inc    %eax
  800cc7:	39 d0                	cmp    %edx,%eax
  800cc9:	72 f7                	jb     800cc2 <memfind+0x12>
			break;
	return (void *) s;
}
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800cdc:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce6:	80 3a 20             	cmpb   $0x20,(%edx)
  800ce9:	74 05                	je     800cf0 <strtol+0x23>
  800ceb:	80 3a 09             	cmpb   $0x9,(%edx)
  800cee:	75 0b                	jne    800cfb <strtol+0x2e>
		s++;
  800cf0:	42                   	inc    %edx
  800cf1:	80 3a 20             	cmpb   $0x20,(%edx)
  800cf4:	74 fa                	je     800cf0 <strtol+0x23>
  800cf6:	80 3a 09             	cmpb   $0x9,(%edx)
  800cf9:	74 f5                	je     800cf0 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800cfb:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800cfe:	75 03                	jne    800d03 <strtol+0x36>
		s++;
  800d00:	42                   	inc    %edx
  800d01:	eb 0b                	jmp    800d0e <strtol+0x41>
	else if (*s == '-')
  800d03:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800d06:	75 06                	jne    800d0e <strtol+0x41>
		s++, neg = 1;
  800d08:	42                   	inc    %edx
  800d09:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d0e:	85 c9                	test   %ecx,%ecx
  800d10:	74 05                	je     800d17 <strtol+0x4a>
  800d12:	83 f9 10             	cmp    $0x10,%ecx
  800d15:	75 15                	jne    800d2c <strtol+0x5f>
  800d17:	80 3a 30             	cmpb   $0x30,(%edx)
  800d1a:	75 10                	jne    800d2c <strtol+0x5f>
  800d1c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d20:	75 0a                	jne    800d2c <strtol+0x5f>
		s += 2, base = 16;
  800d22:	83 c2 02             	add    $0x2,%edx
  800d25:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d2a:	eb 1a                	jmp    800d46 <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800d2c:	85 c9                	test   %ecx,%ecx
  800d2e:	75 16                	jne    800d46 <strtol+0x79>
  800d30:	80 3a 30             	cmpb   $0x30,(%edx)
  800d33:	75 08                	jne    800d3d <strtol+0x70>
		s++, base = 8;
  800d35:	42                   	inc    %edx
  800d36:	b9 08 00 00 00       	mov    $0x8,%ecx
  800d3b:	eb 09                	jmp    800d46 <strtol+0x79>
	else if (base == 0)
  800d3d:	85 c9                	test   %ecx,%ecx
  800d3f:	75 05                	jne    800d46 <strtol+0x79>
		base = 10;
  800d41:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d46:	8a 02                	mov    (%edx),%al
  800d48:	83 e8 30             	sub    $0x30,%eax
  800d4b:	3c 09                	cmp    $0x9,%al
  800d4d:	77 08                	ja     800d57 <strtol+0x8a>
			dig = *s - '0';
  800d4f:	0f be 02             	movsbl (%edx),%eax
  800d52:	83 e8 30             	sub    $0x30,%eax
  800d55:	eb 20                	jmp    800d77 <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800d57:	8a 02                	mov    (%edx),%al
  800d59:	83 e8 61             	sub    $0x61,%eax
  800d5c:	3c 19                	cmp    $0x19,%al
  800d5e:	77 08                	ja     800d68 <strtol+0x9b>
			dig = *s - 'a' + 10;
  800d60:	0f be 02             	movsbl (%edx),%eax
  800d63:	83 e8 57             	sub    $0x57,%eax
  800d66:	eb 0f                	jmp    800d77 <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800d68:	8a 02                	mov    (%edx),%al
  800d6a:	83 e8 41             	sub    $0x41,%eax
  800d6d:	3c 19                	cmp    $0x19,%al
  800d6f:	77 12                	ja     800d83 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800d71:	0f be 02             	movsbl (%edx),%eax
  800d74:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800d77:	39 c8                	cmp    %ecx,%eax
  800d79:	7d 08                	jge    800d83 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800d7b:	42                   	inc    %edx
  800d7c:	0f af d9             	imul   %ecx,%ebx
  800d7f:	01 c3                	add    %eax,%ebx
  800d81:	eb c3                	jmp    800d46 <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d83:	85 f6                	test   %esi,%esi
  800d85:	74 02                	je     800d89 <strtol+0xbc>
		*endptr = (char *) s;
  800d87:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d89:	89 d8                	mov    %ebx,%eax
  800d8b:	85 ff                	test   %edi,%edi
  800d8d:	74 02                	je     800d91 <strtol+0xc4>
  800d8f:	f7 d8                	neg    %eax
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    
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
