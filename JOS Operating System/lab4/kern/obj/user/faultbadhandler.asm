
obj/user/faultbadhandler：     文件格式 elf32-i386

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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	6a 07                	push   $0x7
  80003c:	68 00 f0 bf ee       	push   $0xeebff000
  800041:	6a 00                	push   $0x0
  800043:	e8 ab 01 00 00       	call   8001f3 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800048:	83 c4 08             	add    $0x8,%esp
  80004b:	68 ef be ad de       	push   $0xdeadbeef
  800050:	6a 00                	push   $0x0
  800052:	e8 37 03 00 00       	call   80038e <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800057:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005e:	00 00 00 
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	8b 75 08             	mov    0x8(%ebp),%esi
  80006c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  80006f:	e8 f2 00 00 00       	call   800166 <sys_getenvid>
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	c1 e0 07             	shl    $0x7,%eax
  80007c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800081:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800086:	85 f6                	test   %esi,%esi
  800088:	7e 07                	jle    800091 <libmain+0x2d>
		binaryname = argv[0];
  80008a:	8b 03                	mov    (%ebx),%eax
  80008c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	53                   	push   %ebx
  800095:	56                   	push   %esi
  800096:	e8 99 ff ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  80009b:	e8 08 00 00 00       	call   8000a8 <exit>
}
  8000a0:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    
	...

008000a8 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 60 00 00 00       	call   800115 <sys_env_destroy>
}
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    
	...

008000b8 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c4:	bf 00 00 00 00       	mov    $0x0,%edi
  8000c9:	89 f8                	mov    %edi,%eax
  8000cb:	89 fb                	mov    %edi,%ebx
  8000cd:	89 fe                	mov    %edi,%esi
  8000cf:	55                   	push   %ebp
  8000d0:	9c                   	pushf  
  8000d1:	56                   	push   %esi
  8000d2:	54                   	push   %esp
  8000d3:	5d                   	pop    %ebp
  8000d4:	8d 35 dc 00 80 00    	lea    0x8000dc,%esi
  8000da:	0f 34                	sysenter 
  8000dc:	83 c4 04             	add    $0x4,%esp
  8000df:	9d                   	popf   
  8000e0:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    

008000e6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8000f6:	89 fa                	mov    %edi,%edx
  8000f8:	89 f9                	mov    %edi,%ecx
  8000fa:	89 fb                	mov    %edi,%ebx
  8000fc:	89 fe                	mov    %edi,%esi
  8000fe:	55                   	push   %ebp
  8000ff:	9c                   	pushf  
  800100:	56                   	push   %esi
  800101:	54                   	push   %esp
  800102:	5d                   	pop    %ebp
  800103:	8d 35 0b 01 80 00    	lea    0x80010b,%esi
  800109:	0f 34                	sysenter 
  80010b:	83 c4 04             	add    $0x4,%esp
  80010e:	9d                   	popf   
  80010f:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5f                   	pop    %edi
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	57                   	push   %edi
  800119:	56                   	push   %esi
  80011a:	53                   	push   %ebx
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	8b 55 08             	mov    0x8(%ebp),%edx
  800121:	b8 03 00 00 00       	mov    $0x3,%eax
  800126:	bf 00 00 00 00       	mov    $0x0,%edi
  80012b:	89 f9                	mov    %edi,%ecx
  80012d:	89 fb                	mov    %edi,%ebx
  80012f:	89 fe                	mov    %edi,%esi
  800131:	55                   	push   %ebp
  800132:	9c                   	pushf  
  800133:	56                   	push   %esi
  800134:	54                   	push   %esp
  800135:	5d                   	pop    %ebp
  800136:	8d 35 3e 01 80 00    	lea    0x80013e,%esi
  80013c:	0f 34                	sysenter 
  80013e:	83 c4 04             	add    $0x4,%esp
  800141:	9d                   	popf   
  800142:	5d                   	pop    %ebp
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 17                	jle    80015e <sys_env_destroy+0x49>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	50                   	push   %eax
  80014b:	6a 03                	push   $0x3
  80014d:	68 b7 10 80 00       	push   $0x8010b7
  800152:	6a 4c                	push   $0x4c
  800154:	68 d4 10 80 00       	push   $0x8010d4
  800159:	e8 06 03 00 00       	call   800464 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	b8 02 00 00 00       	mov    $0x2,%eax
  800171:	bf 00 00 00 00       	mov    $0x0,%edi
  800176:	89 fa                	mov    %edi,%edx
  800178:	89 f9                	mov    %edi,%ecx
  80017a:	89 fb                	mov    %edi,%ebx
  80017c:	89 fe                	mov    %edi,%esi
  80017e:	55                   	push   %ebp
  80017f:	9c                   	pushf  
  800180:	56                   	push   %esi
  800181:	54                   	push   %esp
  800182:	5d                   	pop    %ebp
  800183:	8d 35 8b 01 80 00    	lea    0x80018b,%esi
  800189:	0f 34                	sysenter 
  80018b:	83 c4 04             	add    $0x4,%esp
  80018e:	9d                   	popf   
  80018f:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <sys_dump_env>:

int
sys_dump_env(void)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a0:	bf 00 00 00 00       	mov    $0x0,%edi
  8001a5:	89 fa                	mov    %edi,%edx
  8001a7:	89 f9                	mov    %edi,%ecx
  8001a9:	89 fb                	mov    %edi,%ebx
  8001ab:	89 fe                	mov    %edi,%esi
  8001ad:	55                   	push   %ebp
  8001ae:	9c                   	pushf  
  8001af:	56                   	push   %esi
  8001b0:	54                   	push   %esp
  8001b1:	5d                   	pop    %ebp
  8001b2:	8d 35 ba 01 80 00    	lea    0x8001ba,%esi
  8001b8:	0f 34                	sysenter 
  8001ba:	83 c4 04             	add    $0x4,%esp
  8001bd:	9d                   	popf   
  8001be:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <sys_yield>:

void
sys_yield(void)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8001d4:	89 fa                	mov    %edi,%edx
  8001d6:	89 f9                	mov    %edi,%ecx
  8001d8:	89 fb                	mov    %edi,%ebx
  8001da:	89 fe                	mov    %edi,%esi
  8001dc:	55                   	push   %ebp
  8001dd:	9c                   	pushf  
  8001de:	56                   	push   %esi
  8001df:	54                   	push   %esp
  8001e0:	5d                   	pop    %ebp
  8001e1:	8d 35 e9 01 80 00    	lea    0x8001e9,%esi
  8001e7:	0f 34                	sysenter 
  8001e9:	83 c4 04             	add    $0x4,%esp
  8001ec:	9d                   	popf   
  8001ed:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001ee:	5b                   	pop    %ebx
  8001ef:	5e                   	pop    %esi
  8001f0:	5f                   	pop    %edi
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	57                   	push   %edi
  8001f7:	56                   	push   %esi
  8001f8:	53                   	push   %ebx
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800202:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800205:	b8 05 00 00 00       	mov    $0x5,%eax
  80020a:	bf 00 00 00 00       	mov    $0x0,%edi
  80020f:	89 fe                	mov    %edi,%esi
  800211:	55                   	push   %ebp
  800212:	9c                   	pushf  
  800213:	56                   	push   %esi
  800214:	54                   	push   %esp
  800215:	5d                   	pop    %ebp
  800216:	8d 35 1e 02 80 00    	lea    0x80021e,%esi
  80021c:	0f 34                	sysenter 
  80021e:	83 c4 04             	add    $0x4,%esp
  800221:	9d                   	popf   
  800222:	5d                   	pop    %ebp
  800223:	85 c0                	test   %eax,%eax
  800225:	7e 17                	jle    80023e <sys_page_alloc+0x4b>
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	50                   	push   %eax
  80022b:	6a 05                	push   $0x5
  80022d:	68 b7 10 80 00       	push   $0x8010b7
  800232:	6a 4c                	push   $0x4c
  800234:	68 d4 10 80 00       	push   $0x8010d4
  800239:	e8 26 02 00 00       	call   800464 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80023e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800258:	8b 7d 14             	mov    0x14(%ebp),%edi
  80025b:	8b 75 18             	mov    0x18(%ebp),%esi
  80025e:	b8 06 00 00 00       	mov    $0x6,%eax
  800263:	55                   	push   %ebp
  800264:	9c                   	pushf  
  800265:	56                   	push   %esi
  800266:	54                   	push   %esp
  800267:	5d                   	pop    %ebp
  800268:	8d 35 70 02 80 00    	lea    0x800270,%esi
  80026e:	0f 34                	sysenter 
  800270:	83 c4 04             	add    $0x4,%esp
  800273:	9d                   	popf   
  800274:	5d                   	pop    %ebp
  800275:	85 c0                	test   %eax,%eax
  800277:	7e 17                	jle    800290 <sys_page_map+0x4a>
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	50                   	push   %eax
  80027d:	6a 06                	push   $0x6
  80027f:	68 b7 10 80 00       	push   $0x8010b7
  800284:	6a 4c                	push   $0x4c
  800286:	68 d4 10 80 00       	push   $0x8010d4
  80028b:	e8 d4 01 00 00       	call   800464 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800290:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a7:	b8 07 00 00 00       	mov    $0x7,%eax
  8002ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b1:	89 fb                	mov    %edi,%ebx
  8002b3:	89 fe                	mov    %edi,%esi
  8002b5:	55                   	push   %ebp
  8002b6:	9c                   	pushf  
  8002b7:	56                   	push   %esi
  8002b8:	54                   	push   %esp
  8002b9:	5d                   	pop    %ebp
  8002ba:	8d 35 c2 02 80 00    	lea    0x8002c2,%esi
  8002c0:	0f 34                	sysenter 
  8002c2:	83 c4 04             	add    $0x4,%esp
  8002c5:	9d                   	popf   
  8002c6:	5d                   	pop    %ebp
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	7e 17                	jle    8002e2 <sys_page_unmap+0x4a>
  8002cb:	83 ec 0c             	sub    $0xc,%esp
  8002ce:	50                   	push   %eax
  8002cf:	6a 07                	push   $0x7
  8002d1:	68 b7 10 80 00       	push   $0x8010b7
  8002d6:	6a 4c                	push   $0x4c
  8002d8:	68 d4 10 80 00       	push   $0x8010d4
  8002dd:	e8 82 01 00 00       	call   800464 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002e2:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002fe:	bf 00 00 00 00       	mov    $0x0,%edi
  800303:	89 fb                	mov    %edi,%ebx
  800305:	89 fe                	mov    %edi,%esi
  800307:	55                   	push   %ebp
  800308:	9c                   	pushf  
  800309:	56                   	push   %esi
  80030a:	54                   	push   %esp
  80030b:	5d                   	pop    %ebp
  80030c:	8d 35 14 03 80 00    	lea    0x800314,%esi
  800312:	0f 34                	sysenter 
  800314:	83 c4 04             	add    $0x4,%esp
  800317:	9d                   	popf   
  800318:	5d                   	pop    %ebp
  800319:	85 c0                	test   %eax,%eax
  80031b:	7e 17                	jle    800334 <sys_env_set_status+0x4a>
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	50                   	push   %eax
  800321:	6a 09                	push   $0x9
  800323:	68 b7 10 80 00       	push   $0x8010b7
  800328:	6a 4c                	push   $0x4c
  80032a:	68 d4 10 80 00       	push   $0x8010d4
  80032f:	e8 30 01 00 00       	call   800464 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800334:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800337:	5b                   	pop    %ebx
  800338:	5e                   	pop    %esi
  800339:	5f                   	pop    %edi
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	8b 55 08             	mov    0x8(%ebp),%edx
  800348:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800350:	bf 00 00 00 00       	mov    $0x0,%edi
  800355:	89 fb                	mov    %edi,%ebx
  800357:	89 fe                	mov    %edi,%esi
  800359:	55                   	push   %ebp
  80035a:	9c                   	pushf  
  80035b:	56                   	push   %esi
  80035c:	54                   	push   %esp
  80035d:	5d                   	pop    %ebp
  80035e:	8d 35 66 03 80 00    	lea    0x800366,%esi
  800364:	0f 34                	sysenter 
  800366:	83 c4 04             	add    $0x4,%esp
  800369:	9d                   	popf   
  80036a:	5d                   	pop    %ebp
  80036b:	85 c0                	test   %eax,%eax
  80036d:	7e 17                	jle    800386 <sys_env_set_trapframe+0x4a>
  80036f:	83 ec 0c             	sub    $0xc,%esp
  800372:	50                   	push   %eax
  800373:	6a 0a                	push   $0xa
  800375:	68 b7 10 80 00       	push   $0x8010b7
  80037a:	6a 4c                	push   $0x4c
  80037c:	68 d4 10 80 00       	push   $0x8010d4
  800381:	e8 de 00 00 00       	call   800464 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800386:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
  800394:	83 ec 0c             	sub    $0xc,%esp
  800397:	8b 55 08             	mov    0x8(%ebp),%edx
  80039a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039d:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8003a7:	89 fb                	mov    %edi,%ebx
  8003a9:	89 fe                	mov    %edi,%esi
  8003ab:	55                   	push   %ebp
  8003ac:	9c                   	pushf  
  8003ad:	56                   	push   %esi
  8003ae:	54                   	push   %esp
  8003af:	5d                   	pop    %ebp
  8003b0:	8d 35 b8 03 80 00    	lea    0x8003b8,%esi
  8003b6:	0f 34                	sysenter 
  8003b8:	83 c4 04             	add    $0x4,%esp
  8003bb:	9d                   	popf   
  8003bc:	5d                   	pop    %ebp
  8003bd:	85 c0                	test   %eax,%eax
  8003bf:	7e 17                	jle    8003d8 <sys_env_set_pgfault_upcall+0x4a>
  8003c1:	83 ec 0c             	sub    $0xc,%esp
  8003c4:	50                   	push   %eax
  8003c5:	6a 0b                	push   $0xb
  8003c7:	68 b7 10 80 00       	push   $0x8010b7
  8003cc:	6a 4c                	push   $0x4c
  8003ce:	68 d4 10 80 00       	push   $0x8010d4
  8003d3:	e8 8c 00 00 00       	call   800464 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003d8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	c9                   	leave  
  8003df:	c3                   	ret    

008003e0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003f2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003f7:	be 00 00 00 00       	mov    $0x0,%esi
  8003fc:	55                   	push   %ebp
  8003fd:	9c                   	pushf  
  8003fe:	56                   	push   %esi
  8003ff:	54                   	push   %esp
  800400:	5d                   	pop    %ebp
  800401:	8d 35 09 04 80 00    	lea    0x800409,%esi
  800407:	0f 34                	sysenter 
  800409:	83 c4 04             	add    $0x4,%esp
  80040c:	9d                   	popf   
  80040d:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80040e:	5b                   	pop    %ebx
  80040f:	5e                   	pop    %esi
  800410:	5f                   	pop    %edi
  800411:	c9                   	leave  
  800412:	c3                   	ret    

00800413 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	57                   	push   %edi
  800417:	56                   	push   %esi
  800418:	53                   	push   %ebx
  800419:	83 ec 0c             	sub    $0xc,%esp
  80041c:	8b 55 08             	mov    0x8(%ebp),%edx
  80041f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800424:	bf 00 00 00 00       	mov    $0x0,%edi
  800429:	89 f9                	mov    %edi,%ecx
  80042b:	89 fb                	mov    %edi,%ebx
  80042d:	89 fe                	mov    %edi,%esi
  80042f:	55                   	push   %ebp
  800430:	9c                   	pushf  
  800431:	56                   	push   %esi
  800432:	54                   	push   %esp
  800433:	5d                   	pop    %ebp
  800434:	8d 35 3c 04 80 00    	lea    0x80043c,%esi
  80043a:	0f 34                	sysenter 
  80043c:	83 c4 04             	add    $0x4,%esp
  80043f:	9d                   	popf   
  800440:	5d                   	pop    %ebp
  800441:	85 c0                	test   %eax,%eax
  800443:	7e 17                	jle    80045c <sys_ipc_recv+0x49>
  800445:	83 ec 0c             	sub    $0xc,%esp
  800448:	50                   	push   %eax
  800449:	6a 0e                	push   $0xe
  80044b:	68 b7 10 80 00       	push   $0x8010b7
  800450:	6a 4c                	push   $0x4c
  800452:	68 d4 10 80 00       	push   $0x8010d4
  800457:	e8 08 00 00 00       	call   800464 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80045c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80045f:	5b                   	pop    %ebx
  800460:	5e                   	pop    %esi
  800461:	5f                   	pop    %edi
  800462:	c9                   	leave  
  800463:	c3                   	ret    

00800464 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	53                   	push   %ebx
  800468:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  80046b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80046e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800475:	74 16                	je     80048d <_panic+0x29>
		cprintf("%s: ", argv0);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 35 08 20 80 00    	pushl  0x802008
  800480:	68 e2 10 80 00       	push   $0x8010e2
  800485:	e8 ca 00 00 00       	call   800554 <cprintf>
  80048a:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80048d:	ff 75 0c             	pushl  0xc(%ebp)
  800490:	ff 75 08             	pushl  0x8(%ebp)
  800493:	ff 35 00 20 80 00    	pushl  0x802000
  800499:	68 e7 10 80 00       	push   $0x8010e7
  80049e:	e8 b1 00 00 00       	call   800554 <cprintf>
	vcprintf(fmt, ap);
  8004a3:	83 c4 08             	add    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	ff 75 10             	pushl  0x10(%ebp)
  8004aa:	e8 54 00 00 00       	call   800503 <vcprintf>
	cprintf("\n");
  8004af:	c7 04 24 03 11 80 00 	movl   $0x801103,(%esp)
  8004b6:	e8 99 00 00 00       	call   800554 <cprintf>

	// Cause a breakpoint exception
	while (1)
  8004bb:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8004be:	cc                   	int3   
  8004bf:	eb fd                	jmp    8004be <_panic+0x5a>
}
  8004c1:	00 00                	add    %al,(%eax)
	...

008004c4 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	53                   	push   %ebx
  8004c8:	83 ec 04             	sub    $0x4,%esp
  8004cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ce:	8b 03                	mov    (%ebx),%eax
  8004d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004d7:	40                   	inc    %eax
  8004d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004df:	75 1a                	jne    8004fb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	68 ff 00 00 00       	push   $0xff
  8004e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ec:	50                   	push   %eax
  8004ed:	e8 c6 fb ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8004f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004f8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004fb:	ff 43 04             	incl   0x4(%ebx)
}
  8004fe:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800501:	c9                   	leave  
  800502:	c3                   	ret    

00800503 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80050c:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  800513:	00 00 00 
	b.cnt = 0;
  800516:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  80051d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800520:	ff 75 0c             	pushl  0xc(%ebp)
  800523:	ff 75 08             	pushl  0x8(%ebp)
  800526:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  80052c:	50                   	push   %eax
  80052d:	68 c4 04 80 00       	push   $0x8004c4
  800532:	e8 83 01 00 00       	call   8006ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800537:	83 c4 08             	add    $0x8,%esp
  80053a:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800540:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	e8 6c fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
  80054c:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800552:	c9                   	leave  
  800553:	c3                   	ret    

00800554 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80055a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80055d:	50                   	push   %eax
  80055e:	ff 75 08             	pushl  0x8(%ebp)
  800561:	e8 9d ff ff ff       	call   800503 <vcprintf>
	va_end(ap);

	return cnt;
}
  800566:	c9                   	leave  
  800567:	c3                   	ret    

00800568 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	57                   	push   %edi
  80056c:	56                   	push   %esi
  80056d:	53                   	push   %ebx
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	8b 75 10             	mov    0x10(%ebp),%esi
  800574:	8b 7d 14             	mov    0x14(%ebp),%edi
  800577:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80057a:	8b 45 18             	mov    0x18(%ebp),%eax
  80057d:	ba 00 00 00 00       	mov    $0x0,%edx
  800582:	39 d7                	cmp    %edx,%edi
  800584:	72 39                	jb     8005bf <printnum+0x57>
  800586:	77 04                	ja     80058c <printnum+0x24>
  800588:	39 c6                	cmp    %eax,%esi
  80058a:	72 33                	jb     8005bf <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058c:	83 ec 04             	sub    $0x4,%esp
  80058f:	ff 75 20             	pushl  0x20(%ebp)
  800592:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800595:	50                   	push   %eax
  800596:	ff 75 18             	pushl  0x18(%ebp)
  800599:	8b 45 18             	mov    0x18(%ebp),%eax
  80059c:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a1:	52                   	push   %edx
  8005a2:	50                   	push   %eax
  8005a3:	57                   	push   %edi
  8005a4:	56                   	push   %esi
  8005a5:	e8 06 08 00 00       	call   800db0 <__udivdi3>
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	52                   	push   %edx
  8005ae:	50                   	push   %eax
  8005af:	ff 75 0c             	pushl  0xc(%ebp)
  8005b2:	ff 75 08             	pushl  0x8(%ebp)
  8005b5:	e8 ae ff ff ff       	call   800568 <printnum>
  8005ba:	83 c4 20             	add    $0x20,%esp
  8005bd:	eb 19                	jmp    8005d8 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005bf:	4b                   	dec    %ebx
  8005c0:	85 db                	test   %ebx,%ebx
  8005c2:	7e 14                	jle    8005d8 <printnum+0x70>
			putch(padc, putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ca:	ff 75 20             	pushl  0x20(%ebp)
  8005cd:	ff 55 08             	call   *0x8(%ebp)
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	4b                   	dec    %ebx
  8005d4:	85 db                	test   %ebx,%ebx
  8005d6:	7f ec                	jg     8005c4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	ff 75 0c             	pushl  0xc(%ebp)
  8005de:	8b 45 18             	mov    0x18(%ebp),%eax
  8005e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e6:	83 ec 04             	sub    $0x4,%esp
  8005e9:	52                   	push   %edx
  8005ea:	50                   	push   %eax
  8005eb:	57                   	push   %edi
  8005ec:	56                   	push   %esi
  8005ed:	e8 de 08 00 00       	call   800ed0 <__umoddi3>
  8005f2:	83 c4 14             	add    $0x14,%esp
  8005f5:	0f be 80 98 11 80 00 	movsbl 0x801198(%eax),%eax
  8005fc:	50                   	push   %eax
  8005fd:	ff 55 08             	call   *0x8(%ebp)
}
  800600:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800603:	5b                   	pop    %ebx
  800604:	5e                   	pop    %esi
  800605:	5f                   	pop    %edi
  800606:	c9                   	leave  
  800607:	c3                   	ret    

00800608 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 18             	sub    $0x18,%esp
  800610:	8b 75 08             	mov    0x8(%ebp),%esi
  800613:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800616:	8a 45 18             	mov    0x18(%ebp),%al
  800619:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  80061c:	53                   	push   %ebx
  80061d:	6a 1b                	push   $0x1b
  80061f:	ff d6                	call   *%esi
	putch('[', putdat);
  800621:	83 c4 08             	add    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 5b                	push   $0x5b
  800627:	ff d6                	call   *%esi
	putch('0', putdat);
  800629:	83 c4 08             	add    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 30                	push   $0x30
  80062f:	ff d6                	call   *%esi
	putch(';', putdat);
  800631:	83 c4 08             	add    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 3b                	push   $0x3b
  800637:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800639:	83 c4 0c             	add    $0xc,%esp
  80063c:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	ff 75 14             	pushl  0x14(%ebp)
  800644:	6a 0a                	push   $0xa
  800646:	8b 45 10             	mov    0x10(%ebp),%eax
  800649:	99                   	cltd   
  80064a:	52                   	push   %edx
  80064b:	50                   	push   %eax
  80064c:	53                   	push   %ebx
  80064d:	56                   	push   %esi
  80064e:	e8 15 ff ff ff       	call   800568 <printnum>
	putch('m', putdat);
  800653:	83 c4 18             	add    $0x18,%esp
  800656:	53                   	push   %ebx
  800657:	6a 6d                	push   $0x6d
  800659:	ff d6                	call   *%esi

}
  80065b:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	c9                   	leave  
  800661:	c3                   	ret    

00800662 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800668:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80066b:	83 f8 01             	cmp    $0x1,%eax
  80066e:	7e 0f                	jle    80067f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800670:	8b 01                	mov    (%ecx),%eax
  800672:	83 c0 08             	add    $0x8,%eax
  800675:	89 01                	mov    %eax,(%ecx)
  800677:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80067a:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80067d:	eb 0f                	jmp    80068e <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80067f:	8b 01                	mov    (%ecx),%eax
  800681:	83 c0 04             	add    $0x4,%eax
  800684:	89 01                	mov    %eax,(%ecx)
  800686:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800689:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80068e:	c9                   	leave  
  80068f:	c3                   	ret    

00800690 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	8b 55 08             	mov    0x8(%ebp),%edx
  800696:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800699:	83 f8 01             	cmp    $0x1,%eax
  80069c:	7e 0f                	jle    8006ad <getint+0x1d>
		return va_arg(*ap, long long);
  80069e:	8b 02                	mov    (%edx),%eax
  8006a0:	83 c0 08             	add    $0x8,%eax
  8006a3:	89 02                	mov    %eax,(%edx)
  8006a5:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8006a8:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8006ab:	eb 0b                	jmp    8006b8 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8006ad:	8b 02                	mov    (%edx),%eax
  8006af:	83 c0 04             	add    $0x4,%eax
  8006b2:	89 02                	mov    %eax,(%edx)
  8006b4:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8006b7:	99                   	cltd   
}
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	57                   	push   %edi
  8006be:	56                   	push   %esi
  8006bf:	53                   	push   %ebx
  8006c0:	83 ec 1c             	sub    $0x1c,%esp
  8006c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c6:	0f b6 13             	movzbl (%ebx),%edx
  8006c9:	43                   	inc    %ebx
  8006ca:	83 fa 25             	cmp    $0x25,%edx
  8006cd:	74 1e                	je     8006ed <vprintfmt+0x33>
			if (ch == '\0')
  8006cf:	85 d2                	test   %edx,%edx
  8006d1:	0f 84 dc 02 00 00    	je     8009b3 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	ff 75 0c             	pushl  0xc(%ebp)
  8006dd:	52                   	push   %edx
  8006de:	ff 55 08             	call   *0x8(%ebp)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	0f b6 13             	movzbl (%ebx),%edx
  8006e7:	43                   	inc    %ebx
  8006e8:	83 fa 25             	cmp    $0x25,%edx
  8006eb:	75 e2                	jne    8006cf <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8006ed:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8006f1:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8006f8:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  800702:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  800709:	0f b6 13             	movzbl (%ebx),%edx
  80070c:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  80070f:	43                   	inc    %ebx
  800710:	83 f8 55             	cmp    $0x55,%eax
  800713:	0f 87 75 02 00 00    	ja     80098e <vprintfmt+0x2d4>
  800719:	ff 24 85 e4 11 80 00 	jmp    *0x8011e4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800720:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800724:	eb e3                	jmp    800709 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800726:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  80072a:	eb dd                	jmp    800709 <vprintfmt+0x4f>

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
  80072c:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800731:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800734:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800738:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80073b:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80073e:	83 f8 09             	cmp    $0x9,%eax
  800741:	77 27                	ja     80076a <vprintfmt+0xb0>
  800743:	43                   	inc    %ebx
  800744:	eb eb                	jmp    800731 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800746:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800750:	eb 18                	jmp    80076a <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  800752:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800756:	79 b1                	jns    800709 <vprintfmt+0x4f>
				width = 0;
  800758:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80075f:	eb a8                	jmp    800709 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800761:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800768:	eb 9f                	jmp    800709 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  80076a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80076e:	79 99                	jns    800709 <vprintfmt+0x4f>
				width = precision, precision = -1;
  800770:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800773:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800778:	eb 8f                	jmp    800709 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  80077a:	41                   	inc    %ecx
			goto reswitch;
  80077b:	eb 8c                	jmp    800709 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80078d:	e9 c4 01 00 00       	jmp    800956 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  800792:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80079c:	85 c0                	test   %eax,%eax
  80079e:	79 02                	jns    8007a2 <vprintfmt+0xe8>
				err = -err;
  8007a0:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8007a2:	83 f8 08             	cmp    $0x8,%eax
  8007a5:	7f 0b                	jg     8007b2 <vprintfmt+0xf8>
  8007a7:	8b 3c 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edi
  8007ae:	85 ff                	test   %edi,%edi
  8007b0:	75 08                	jne    8007ba <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  8007b2:	50                   	push   %eax
  8007b3:	68 a9 11 80 00       	push   $0x8011a9
  8007b8:	eb 06                	jmp    8007c0 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8007ba:	57                   	push   %edi
  8007bb:	68 b2 11 80 00       	push   $0x8011b2
  8007c0:	ff 75 0c             	pushl  0xc(%ebp)
  8007c3:	ff 75 08             	pushl  0x8(%ebp)
  8007c6:	e8 f0 01 00 00       	call   8009bb <printfmt>
  8007cb:	e9 89 01 00 00       	jmp    800959 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007d0:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8007da:	85 ff                	test   %edi,%edi
  8007dc:	75 05                	jne    8007e3 <vprintfmt+0x129>
				p = "(null)";
  8007de:	bf b5 11 80 00       	mov    $0x8011b5,%edi
			if (width > 0 && padc != '-')
  8007e3:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8007e7:	7e 3b                	jle    800824 <vprintfmt+0x16a>
  8007e9:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8007ed:	74 35                	je     800824 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	56                   	push   %esi
  8007f3:	57                   	push   %edi
  8007f4:	e8 74 02 00 00       	call   800a6d <strnlen>
  8007f9:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800803:	7e 1f                	jle    800824 <vprintfmt+0x16a>
  800805:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800809:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  80080c:	83 ec 08             	sub    $0x8,%esp
  80080f:	ff 75 0c             	pushl  0xc(%ebp)
  800812:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  800815:	ff 55 08             	call   *0x8(%ebp)
  800818:	83 c4 10             	add    $0x10,%esp
  80081b:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80081e:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800822:	7f e8                	jg     80080c <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800824:	0f be 17             	movsbl (%edi),%edx
  800827:	47                   	inc    %edi
  800828:	85 d2                	test   %edx,%edx
  80082a:	74 3e                	je     80086a <vprintfmt+0x1b0>
  80082c:	85 f6                	test   %esi,%esi
  80082e:	78 03                	js     800833 <vprintfmt+0x179>
  800830:	4e                   	dec    %esi
  800831:	78 37                	js     80086a <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  800833:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800837:	74 12                	je     80084b <vprintfmt+0x191>
  800839:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  80083c:	83 f8 5e             	cmp    $0x5e,%eax
  80083f:	76 0a                	jbe    80084b <vprintfmt+0x191>
					putch('?', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	ff 75 0c             	pushl  0xc(%ebp)
  800847:	6a 3f                	push   $0x3f
  800849:	eb 07                	jmp    800852 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	52                   	push   %edx
  800852:	ff 55 08             	call   *0x8(%ebp)
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80085b:	0f be 17             	movsbl (%edi),%edx
  80085e:	47                   	inc    %edi
  80085f:	85 d2                	test   %edx,%edx
  800861:	74 07                	je     80086a <vprintfmt+0x1b0>
  800863:	85 f6                	test   %esi,%esi
  800865:	78 cc                	js     800833 <vprintfmt+0x179>
  800867:	4e                   	dec    %esi
  800868:	79 c9                	jns    800833 <vprintfmt+0x179>
			for (; width > 0; width--)
  80086a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80086e:	0f 8e 52 fe ff ff    	jle    8006c6 <vprintfmt+0xc>
				putch(' ', putdat);
  800874:	83 ec 08             	sub    $0x8,%esp
  800877:	ff 75 0c             	pushl  0xc(%ebp)
  80087a:	6a 20                	push   $0x20
  80087c:	ff 55 08             	call   *0x8(%ebp)
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800885:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800889:	7f e9                	jg     800874 <vprintfmt+0x1ba>
			break;
  80088b:	e9 36 fe ff ff       	jmp    8006c6 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	51                   	push   %ecx
  800894:	8d 45 14             	lea    0x14(%ebp),%eax
  800897:	50                   	push   %eax
  800898:	e8 f3 fd ff ff       	call   800690 <getint>
  80089d:	89 c6                	mov    %eax,%esi
  80089f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8008a1:	83 c4 10             	add    $0x10,%esp
  8008a4:	85 d2                	test   %edx,%edx
  8008a6:	79 15                	jns    8008bd <vprintfmt+0x203>
				putch('-', putdat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	ff 75 0c             	pushl  0xc(%ebp)
  8008ae:	6a 2d                	push   $0x2d
  8008b0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008b3:	f7 de                	neg    %esi
  8008b5:	83 d7 00             	adc    $0x0,%edi
  8008b8:	f7 df                	neg    %edi
  8008ba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008bd:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8008c2:	eb 70                	jmp    800934 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	51                   	push   %ecx
  8008c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008cb:	50                   	push   %eax
  8008cc:	e8 91 fd ff ff       	call   800662 <getuint>
  8008d1:	89 c6                	mov    %eax,%esi
  8008d3:	89 d7                	mov    %edx,%edi
			base = 10;
  8008d5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8008da:	eb 55                	jmp    800931 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	51                   	push   %ecx
  8008e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e3:	50                   	push   %eax
  8008e4:	e8 79 fd ff ff       	call   800662 <getuint>
  8008e9:	89 c6                	mov    %eax,%esi
  8008eb:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  8008ed:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8008f2:	eb 3d                	jmp    800931 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	ff 75 0c             	pushl  0xc(%ebp)
  8008fa:	6a 30                	push   $0x30
  8008fc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008ff:	83 c4 08             	add    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	6a 78                	push   $0x78
  800907:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  80090a:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80090e:	8b 45 14             	mov    0x14(%ebp),%eax
  800911:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800914:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  800919:	eb 11                	jmp    80092c <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	51                   	push   %ecx
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	50                   	push   %eax
  800923:	e8 3a fd ff ff       	call   800662 <getuint>
  800928:	89 c6                	mov    %eax,%esi
  80092a:	89 d7                	mov    %edx,%edi
			base = 16;
  80092c:	ba 10 00 00 00       	mov    $0x10,%edx
  800931:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800934:	83 ec 04             	sub    $0x4,%esp
  800937:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80093b:	50                   	push   %eax
  80093c:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80093f:	52                   	push   %edx
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	ff 75 0c             	pushl  0xc(%ebp)
  800945:	ff 75 08             	pushl  0x8(%ebp)
  800948:	e8 1b fc ff ff       	call   800568 <printnum>
			break;
  80094d:	eb 37                	jmp    800986 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094f:	83 ec 08             	sub    $0x8,%esp
  800952:	ff 75 0c             	pushl  0xc(%ebp)
  800955:	52                   	push   %edx
  800956:	ff 55 08             	call   *0x8(%ebp)
			break;
  800959:	83 c4 10             	add    $0x10,%esp
  80095c:	e9 65 fd ff ff       	jmp    8006c6 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	51                   	push   %ecx
  800965:	8d 45 14             	lea    0x14(%ebp),%eax
  800968:	50                   	push   %eax
  800969:	e8 f4 fc ff ff       	call   800662 <getuint>
  80096e:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800970:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80097a:	56                   	push   %esi
  80097b:	ff 75 0c             	pushl  0xc(%ebp)
  80097e:	ff 75 08             	pushl  0x8(%ebp)
  800981:	e8 82 fc ff ff       	call   800608 <printcolor>
			break;
  800986:	83 c4 20             	add    $0x20,%esp
  800989:	e9 38 fd ff ff       	jmp    8006c6 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	6a 25                	push   $0x25
  800996:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800999:	4b                   	dec    %ebx
  80099a:	83 c4 10             	add    $0x10,%esp
  80099d:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8009a1:	0f 84 1f fd ff ff    	je     8006c6 <vprintfmt+0xc>
  8009a7:	4b                   	dec    %ebx
  8009a8:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8009ac:	75 f9                	jne    8009a7 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8009ae:	e9 13 fd ff ff       	jmp    8006c6 <vprintfmt+0xc>
		}
	}
}
  8009b3:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8009c1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009c4:	50                   	push   %eax
  8009c5:	ff 75 10             	pushl  0x10(%ebp)
  8009c8:	ff 75 0c             	pushl  0xc(%ebp)
  8009cb:	ff 75 08             	pushl  0x8(%ebp)
  8009ce:	e8 e7 fc ff ff       	call   8006ba <vprintfmt>
	va_end(ap);
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8009db:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8009de:	8b 0a                	mov    (%edx),%ecx
  8009e0:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8009e3:	73 07                	jae    8009ec <sprintputch+0x17>
		*b->buf++ = ch;
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	88 01                	mov    %al,(%ecx)
  8009ea:	ff 02                	incl   (%edx)
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 18             	sub    $0x18,%esp
  8009f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8009fa:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8009fd:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800a01:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800a04:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  800a0b:	85 d2                	test   %edx,%edx
  800a0d:	74 04                	je     800a13 <vsnprintf+0x25>
  800a0f:	85 c9                	test   %ecx,%ecx
  800a11:	7f 07                	jg     800a1a <vsnprintf+0x2c>
		return -E_INVAL;
  800a13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a18:	eb 1d                	jmp    800a37 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  800a1a:	ff 75 14             	pushl  0x14(%ebp)
  800a1d:	ff 75 10             	pushl  0x10(%ebp)
  800a20:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800a23:	50                   	push   %eax
  800a24:	68 d5 09 80 00       	push   $0x8009d5
  800a29:	e8 8c fc ff ff       	call   8006ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a2e:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800a31:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a34:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a3f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a42:	50                   	push   %eax
  800a43:	ff 75 10             	pushl  0x10(%ebp)
  800a46:	ff 75 0c             	pushl  0xc(%ebp)
  800a49:	ff 75 08             	pushl  0x8(%ebp)
  800a4c:	e8 9d ff ff ff       	call   8009ee <vsnprintf>
	va_end(ap);

	return rc;
}
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    
	...

00800a54 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	80 3a 00             	cmpb   $0x0,(%edx)
  800a62:	74 07                	je     800a6b <strlen+0x17>
		n++;
  800a64:	40                   	inc    %eax
  800a65:	42                   	inc    %edx
  800a66:	80 3a 00             	cmpb   $0x0,(%edx)
  800a69:	75 f9                	jne    800a64 <strlen+0x10>
	return n;
}
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    

00800a6d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a73:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	85 d2                	test   %edx,%edx
  800a7d:	74 0f                	je     800a8e <strnlen+0x21>
  800a7f:	80 39 00             	cmpb   $0x0,(%ecx)
  800a82:	74 0a                	je     800a8e <strnlen+0x21>
		n++;
  800a84:	40                   	inc    %eax
  800a85:	41                   	inc    %ecx
  800a86:	4a                   	dec    %edx
  800a87:	74 05                	je     800a8e <strnlen+0x21>
  800a89:	80 39 00             	cmpb   $0x0,(%ecx)
  800a8c:	75 f6                	jne    800a84 <strnlen+0x17>
	return n;
}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a97:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800a9a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800a9c:	8a 02                	mov    (%edx),%al
  800a9e:	42                   	inc    %edx
  800a9f:	88 01                	mov    %al,(%ecx)
  800aa1:	41                   	inc    %ecx
  800aa2:	84 c0                	test   %al,%al
  800aa4:	75 f6                	jne    800a9c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800aa6:	89 d8                	mov    %ebx,%eax
  800aa8:	5b                   	pop    %ebx
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab7:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800aba:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800abc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ac1:	39 f3                	cmp    %esi,%ebx
  800ac3:	73 10                	jae    800ad5 <strncpy+0x2a>
		*dst++ = *src;
  800ac5:	8a 02                	mov    (%edx),%al
  800ac7:	88 01                	mov    %al,(%ecx)
  800ac9:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800aca:	80 3a 00             	cmpb   $0x0,(%edx)
  800acd:	74 01                	je     800ad0 <strncpy+0x25>
			src++;
  800acf:	42                   	inc    %edx
  800ad0:	43                   	inc    %ebx
  800ad1:	39 f3                	cmp    %esi,%ebx
  800ad3:	72 f0                	jb     800ac5 <strncpy+0x1a>
	}
	return ret;
}
  800ad5:	89 f8                	mov    %edi,%eax
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	c9                   	leave  
  800adb:	c3                   	ret    

00800adc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800aea:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800aec:	85 d2                	test   %edx,%edx
  800aee:	74 19                	je     800b09 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800af0:	4a                   	dec    %edx
  800af1:	74 13                	je     800b06 <strlcpy+0x2a>
  800af3:	80 39 00             	cmpb   $0x0,(%ecx)
  800af6:	74 0e                	je     800b06 <strlcpy+0x2a>
			*dst++ = *src++;
  800af8:	8a 01                	mov    (%ecx),%al
  800afa:	41                   	inc    %ecx
  800afb:	88 03                	mov    %al,(%ebx)
  800afd:	43                   	inc    %ebx
  800afe:	4a                   	dec    %edx
  800aff:	74 05                	je     800b06 <strlcpy+0x2a>
  800b01:	80 39 00             	cmpb   $0x0,(%ecx)
  800b04:	75 f2                	jne    800af8 <strlcpy+0x1c>
		*dst = '\0';
  800b06:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	29 f0                	sub    %esi,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    

00800b11 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800b1a:	80 3a 00             	cmpb   $0x0,(%edx)
  800b1d:	74 13                	je     800b32 <strcmp+0x21>
  800b1f:	8a 02                	mov    (%edx),%al
  800b21:	3a 01                	cmp    (%ecx),%al
  800b23:	75 0d                	jne    800b32 <strcmp+0x21>
		p++, q++;
  800b25:	42                   	inc    %edx
  800b26:	41                   	inc    %ecx
  800b27:	80 3a 00             	cmpb   $0x0,(%edx)
  800b2a:	74 06                	je     800b32 <strcmp+0x21>
  800b2c:	8a 02                	mov    (%edx),%al
  800b2e:	3a 01                	cmp    (%ecx),%al
  800b30:	74 f3                	je     800b25 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b32:	0f b6 02             	movzbl (%edx),%eax
  800b35:	0f b6 11             	movzbl (%ecx),%edx
  800b38:	29 d0                	sub    %edx,%eax
}
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800b49:	85 c9                	test   %ecx,%ecx
  800b4b:	74 1f                	je     800b6c <strncmp+0x30>
  800b4d:	80 3a 00             	cmpb   $0x0,(%edx)
  800b50:	74 16                	je     800b68 <strncmp+0x2c>
  800b52:	8a 02                	mov    (%edx),%al
  800b54:	3a 03                	cmp    (%ebx),%al
  800b56:	75 10                	jne    800b68 <strncmp+0x2c>
		n--, p++, q++;
  800b58:	42                   	inc    %edx
  800b59:	43                   	inc    %ebx
  800b5a:	49                   	dec    %ecx
  800b5b:	74 0f                	je     800b6c <strncmp+0x30>
  800b5d:	80 3a 00             	cmpb   $0x0,(%edx)
  800b60:	74 06                	je     800b68 <strncmp+0x2c>
  800b62:	8a 02                	mov    (%edx),%al
  800b64:	3a 03                	cmp    (%ebx),%al
  800b66:	74 f0                	je     800b58 <strncmp+0x1c>
	if (n == 0)
  800b68:	85 c9                	test   %ecx,%ecx
  800b6a:	75 07                	jne    800b73 <strncmp+0x37>
		return 0;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	eb 0a                	jmp    800b7d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b73:	0f b6 12             	movzbl (%edx),%edx
  800b76:	0f b6 03             	movzbl (%ebx),%eax
  800b79:	29 c2                	sub    %eax,%edx
  800b7b:	89 d0                	mov    %edx,%eax
}
  800b7d:	8b 1c 24             	mov    (%esp),%ebx
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800b8b:	80 38 00             	cmpb   $0x0,(%eax)
  800b8e:	74 0a                	je     800b9a <strchr+0x18>
		if (*s == c)
  800b90:	38 10                	cmp    %dl,(%eax)
  800b92:	74 0b                	je     800b9f <strchr+0x1d>
  800b94:	40                   	inc    %eax
  800b95:	80 38 00             	cmpb   $0x0,(%eax)
  800b98:	75 f6                	jne    800b90 <strchr+0xe>
			return (char *) s;
	return 0;
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba7:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800baa:	80 38 00             	cmpb   $0x0,(%eax)
  800bad:	74 0a                	je     800bb9 <strfind+0x18>
		if (*s == c)
  800baf:	38 10                	cmp    %dl,(%eax)
  800bb1:	74 06                	je     800bb9 <strfind+0x18>
  800bb3:	40                   	inc    %eax
  800bb4:	80 38 00             	cmpb   $0x0,(%eax)
  800bb7:	75 f6                	jne    800baf <strfind+0xe>
			break;
	return (char *) s;
}
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bc5:	89 f8                	mov    %edi,%eax
  800bc7:	85 c9                	test   %ecx,%ecx
  800bc9:	74 40                	je     800c0b <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bcb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd1:	75 30                	jne    800c03 <memset+0x48>
  800bd3:	f6 c1 03             	test   $0x3,%cl
  800bd6:	75 2b                	jne    800c03 <memset+0x48>
		c &= 0xFF;
  800bd8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be2:	c1 e0 18             	shl    $0x18,%eax
  800be5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be8:	c1 e2 10             	shl    $0x10,%edx
  800beb:	09 d0                	or     %edx,%eax
  800bed:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf0:	c1 e2 08             	shl    $0x8,%edx
  800bf3:	09 d0                	or     %edx,%eax
  800bf5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800bf8:	c1 e9 02             	shr    $0x2,%ecx
  800bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfe:	fc                   	cld    
  800bff:	f3 ab                	repz stos %eax,%es:(%edi)
  800c01:	eb 06                	jmp    800c09 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c06:	fc                   	cld    
  800c07:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c09:	89 f8                	mov    %edi,%eax
}
  800c0b:	8b 3c 24             	mov    (%esp),%edi
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c1b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c1e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c20:	39 c6                	cmp    %eax,%esi
  800c22:	73 33                	jae    800c57 <memmove+0x47>
  800c24:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800c27:	39 c2                	cmp    %eax,%edx
  800c29:	76 2c                	jbe    800c57 <memmove+0x47>
		s += n;
  800c2b:	89 d6                	mov    %edx,%esi
		d += n;
  800c2d:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c30:	f6 c2 03             	test   $0x3,%dl
  800c33:	75 1b                	jne    800c50 <memmove+0x40>
  800c35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3b:	75 13                	jne    800c50 <memmove+0x40>
  800c3d:	f6 c1 03             	test   $0x3,%cl
  800c40:	75 0e                	jne    800c50 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800c42:	83 ef 04             	sub    $0x4,%edi
  800c45:	83 ee 04             	sub    $0x4,%esi
  800c48:	c1 e9 02             	shr    $0x2,%ecx
  800c4b:	fd                   	std    
  800c4c:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800c4e:	eb 27                	jmp    800c77 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c50:	4f                   	dec    %edi
  800c51:	4e                   	dec    %esi
  800c52:	fd                   	std    
  800c53:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800c55:	eb 20                	jmp    800c77 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c57:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5d:	75 15                	jne    800c74 <memmove+0x64>
  800c5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c65:	75 0d                	jne    800c74 <memmove+0x64>
  800c67:	f6 c1 03             	test   $0x3,%cl
  800c6a:	75 08                	jne    800c74 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800c6c:	c1 e9 02             	shr    $0x2,%ecx
  800c6f:	fc                   	cld    
  800c70:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800c72:	eb 03                	jmp    800c77 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c74:	fc                   	cld    
  800c75:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <memcpy>:

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
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c81:	ff 75 10             	pushl  0x10(%ebp)
  800c84:	ff 75 0c             	pushl  0xc(%ebp)
  800c87:	ff 75 08             	pushl  0x8(%ebp)
  800c8a:	e8 81 ff ff ff       	call   800c10 <memmove>
}
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	53                   	push   %ebx
  800c95:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800c98:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800c9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  800c9e:	89 d0                	mov    %edx,%eax
  800ca0:	4a                   	dec    %edx
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	74 1b                	je     800cc0 <memcmp+0x2f>
		if (*s1 != *s2)
  800ca5:	8a 01                	mov    (%ecx),%al
  800ca7:	3a 03                	cmp    (%ebx),%al
  800ca9:	74 0c                	je     800cb7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cab:	0f b6 d0             	movzbl %al,%edx
  800cae:	0f b6 03             	movzbl (%ebx),%eax
  800cb1:	29 c2                	sub    %eax,%edx
  800cb3:	89 d0                	mov    %edx,%eax
  800cb5:	eb 0e                	jmp    800cc5 <memcmp+0x34>
		s1++, s2++;
  800cb7:	41                   	inc    %ecx
  800cb8:	43                   	inc    %ebx
  800cb9:	89 d0                	mov    %edx,%eax
  800cbb:	4a                   	dec    %edx
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	75 e5                	jne    800ca5 <memcmp+0x14>
	}

	return 0;
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	c9                   	leave  
  800cc7:	c3                   	ret    

00800cc8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cd6:	39 d0                	cmp    %edx,%eax
  800cd8:	73 09                	jae    800ce3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cda:	38 08                	cmp    %cl,(%eax)
  800cdc:	74 05                	je     800ce3 <memfind+0x1b>
  800cde:	40                   	inc    %eax
  800cdf:	39 d0                	cmp    %edx,%eax
  800ce1:	72 f7                	jb     800cda <memfind+0x12>
			break;
	return (void *) s;
}
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800cf4:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800cf9:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfe:	80 3a 20             	cmpb   $0x20,(%edx)
  800d01:	74 05                	je     800d08 <strtol+0x23>
  800d03:	80 3a 09             	cmpb   $0x9,(%edx)
  800d06:	75 0b                	jne    800d13 <strtol+0x2e>
		s++;
  800d08:	42                   	inc    %edx
  800d09:	80 3a 20             	cmpb   $0x20,(%edx)
  800d0c:	74 fa                	je     800d08 <strtol+0x23>
  800d0e:	80 3a 09             	cmpb   $0x9,(%edx)
  800d11:	74 f5                	je     800d08 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800d13:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800d16:	75 03                	jne    800d1b <strtol+0x36>
		s++;
  800d18:	42                   	inc    %edx
  800d19:	eb 0b                	jmp    800d26 <strtol+0x41>
	else if (*s == '-')
  800d1b:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800d1e:	75 06                	jne    800d26 <strtol+0x41>
		s++, neg = 1;
  800d20:	42                   	inc    %edx
  800d21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d26:	85 c9                	test   %ecx,%ecx
  800d28:	74 05                	je     800d2f <strtol+0x4a>
  800d2a:	83 f9 10             	cmp    $0x10,%ecx
  800d2d:	75 15                	jne    800d44 <strtol+0x5f>
  800d2f:	80 3a 30             	cmpb   $0x30,(%edx)
  800d32:	75 10                	jne    800d44 <strtol+0x5f>
  800d34:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d38:	75 0a                	jne    800d44 <strtol+0x5f>
		s += 2, base = 16;
  800d3a:	83 c2 02             	add    $0x2,%edx
  800d3d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d42:	eb 1a                	jmp    800d5e <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800d44:	85 c9                	test   %ecx,%ecx
  800d46:	75 16                	jne    800d5e <strtol+0x79>
  800d48:	80 3a 30             	cmpb   $0x30,(%edx)
  800d4b:	75 08                	jne    800d55 <strtol+0x70>
		s++, base = 8;
  800d4d:	42                   	inc    %edx
  800d4e:	b9 08 00 00 00       	mov    $0x8,%ecx
  800d53:	eb 09                	jmp    800d5e <strtol+0x79>
	else if (base == 0)
  800d55:	85 c9                	test   %ecx,%ecx
  800d57:	75 05                	jne    800d5e <strtol+0x79>
		base = 10;
  800d59:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5e:	8a 02                	mov    (%edx),%al
  800d60:	83 e8 30             	sub    $0x30,%eax
  800d63:	3c 09                	cmp    $0x9,%al
  800d65:	77 08                	ja     800d6f <strtol+0x8a>
			dig = *s - '0';
  800d67:	0f be 02             	movsbl (%edx),%eax
  800d6a:	83 e8 30             	sub    $0x30,%eax
  800d6d:	eb 20                	jmp    800d8f <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800d6f:	8a 02                	mov    (%edx),%al
  800d71:	83 e8 61             	sub    $0x61,%eax
  800d74:	3c 19                	cmp    $0x19,%al
  800d76:	77 08                	ja     800d80 <strtol+0x9b>
			dig = *s - 'a' + 10;
  800d78:	0f be 02             	movsbl (%edx),%eax
  800d7b:	83 e8 57             	sub    $0x57,%eax
  800d7e:	eb 0f                	jmp    800d8f <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800d80:	8a 02                	mov    (%edx),%al
  800d82:	83 e8 41             	sub    $0x41,%eax
  800d85:	3c 19                	cmp    $0x19,%al
  800d87:	77 12                	ja     800d9b <strtol+0xb6>
			dig = *s - 'A' + 10;
  800d89:	0f be 02             	movsbl (%edx),%eax
  800d8c:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800d8f:	39 c8                	cmp    %ecx,%eax
  800d91:	7d 08                	jge    800d9b <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800d93:	42                   	inc    %edx
  800d94:	0f af d9             	imul   %ecx,%ebx
  800d97:	01 c3                	add    %eax,%ebx
  800d99:	eb c3                	jmp    800d5e <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d9b:	85 f6                	test   %esi,%esi
  800d9d:	74 02                	je     800da1 <strtol+0xbc>
		*endptr = (char *) s;
  800d9f:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	85 ff                	test   %edi,%edi
  800da5:	74 02                	je     800da9 <strtol+0xc4>
  800da7:	f7 d8                	neg    %eax
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    
	...

00800db0 <__udivdi3>:
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	83 ec 20             	sub    $0x20,%esp
  800db8:	8b 55 14             	mov    0x14(%ebp),%edx
  800dbb:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc4:	85 d2                	test   %edx,%edx
  800dc6:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800dc9:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800dd0:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800dd7:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800dda:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800ddd:	89 fe                	mov    %edi,%esi
  800ddf:	75 5b                	jne    800e3c <__udivdi3+0x8c>
  800de1:	39 f8                	cmp    %edi,%eax
  800de3:	76 2b                	jbe    800e10 <__udivdi3+0x60>
  800de5:	89 fa                	mov    %edi,%edx
  800de7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800dea:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800ded:	89 c7                	mov    %eax,%edi
  800def:	90                   	nop    
  800df0:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800df7:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800dfa:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800dfd:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e00:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e03:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e06:	83 c4 20             	add    $0x20,%esp
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    
  800e0d:	8d 76 00             	lea    0x0(%esi),%esi
  800e10:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e13:	85 c0                	test   %eax,%eax
  800e15:	75 0e                	jne    800e25 <__udivdi3+0x75>
  800e17:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1c:	31 c9                	xor    %ecx,%ecx
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	f7 f1                	div    %ecx
  800e22:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e25:	89 f0                	mov    %esi,%eax
  800e27:	31 d2                	xor    %edx,%edx
  800e29:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e2c:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e2f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e32:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e35:	89 c7                	mov    %eax,%edi
  800e37:	eb be                	jmp    800df7 <__udivdi3+0x47>
  800e39:	8d 76 00             	lea    0x0(%esi),%esi
  800e3c:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800e3f:	76 07                	jbe    800e48 <__udivdi3+0x98>
  800e41:	31 ff                	xor    %edi,%edi
  800e43:	eb ab                	jmp    800df0 <__udivdi3+0x40>
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800e4c:	89 c7                	mov    %eax,%edi
  800e4e:	83 f7 1f             	xor    $0x1f,%edi
  800e51:	75 19                	jne    800e6c <__udivdi3+0xbc>
  800e53:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800e56:	77 0a                	ja     800e62 <__udivdi3+0xb2>
  800e58:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e5b:	31 ff                	xor    %edi,%edi
  800e5d:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800e60:	72 8e                	jb     800df0 <__udivdi3+0x40>
  800e62:	bf 01 00 00 00       	mov    $0x1,%edi
  800e67:	eb 87                	jmp    800df0 <__udivdi3+0x40>
  800e69:	8d 76 00             	lea    0x0(%esi),%esi
  800e6c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e71:	29 f8                	sub    %edi,%eax
  800e73:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800e76:	89 f9                	mov    %edi,%ecx
  800e78:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800e7b:	d3 e2                	shl    %cl,%edx
  800e7d:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e80:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e83:	d3 e8                	shr    %cl,%eax
  800e85:	09 c2                	or     %eax,%edx
  800e87:	89 f9                	mov    %edi,%ecx
  800e89:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800e8c:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e8f:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	d3 ea                	shr    %cl,%edx
  800e96:	89 f9                	mov    %edi,%ecx
  800e98:	d3 e6                	shl    %cl,%esi
  800e9a:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e9d:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800ea0:	d3 e8                	shr    %cl,%eax
  800ea2:	09 c6                	or     %eax,%esi
  800ea4:	89 f9                	mov    %edi,%ecx
  800ea6:	89 f0                	mov    %esi,%eax
  800ea8:	f7 75 ec             	divl   0xffffffec(%ebp)
  800eab:	89 d6                	mov    %edx,%esi
  800ead:	89 c7                	mov    %eax,%edi
  800eaf:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800eb2:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800eb5:	f7 e7                	mul    %edi
  800eb7:	39 f2                	cmp    %esi,%edx
  800eb9:	77 0f                	ja     800eca <__udivdi3+0x11a>
  800ebb:	0f 85 2f ff ff ff    	jne    800df0 <__udivdi3+0x40>
  800ec1:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800ec4:	0f 86 26 ff ff ff    	jbe    800df0 <__udivdi3+0x40>
  800eca:	4f                   	dec    %edi
  800ecb:	e9 20 ff ff ff       	jmp    800df0 <__udivdi3+0x40>

00800ed0 <__umoddi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	83 ec 30             	sub    $0x30,%esp
  800ed8:	8b 55 14             	mov    0x14(%ebp),%edx
  800edb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ede:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ee1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee4:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800ee7:	85 d2                	test   %edx,%edx
  800ee9:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800ef0:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800ef7:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800efa:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800efd:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800f00:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800f03:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800f06:	75 68                	jne    800f70 <__umoddi3+0xa0>
  800f08:	39 f8                	cmp    %edi,%eax
  800f0a:	76 3c                	jbe    800f48 <__umoddi3+0x78>
  800f0c:	89 f0                	mov    %esi,%eax
  800f0e:	89 fa                	mov    %edi,%edx
  800f10:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f13:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800f16:	85 c9                	test   %ecx,%ecx
  800f18:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800f1b:	74 1b                	je     800f38 <__umoddi3+0x68>
  800f1d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f20:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800f23:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f2a:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f2d:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800f30:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800f33:	89 10                	mov    %edx,(%eax)
  800f35:	89 48 04             	mov    %ecx,0x4(%eax)
  800f38:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f3b:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f3e:	83 c4 30             	add    $0x30,%esp
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  800f4b:	85 f6                	test   %esi,%esi
  800f4d:	75 0d                	jne    800f5c <__umoddi3+0x8c>
  800f4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f54:	31 d2                	xor    %edx,%edx
  800f56:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f59:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f5c:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800f5f:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f62:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f65:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f68:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f6b:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f6e:	eb a3                	jmp    800f13 <__umoddi3+0x43>
  800f70:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f73:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800f76:	76 14                	jbe    800f8c <__umoddi3+0xbc>
  800f78:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800f7b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800f7e:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800f81:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800f84:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800f87:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800f8a:	eb ac                	jmp    800f38 <__umoddi3+0x68>
  800f8c:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800f90:	89 c6                	mov    %eax,%esi
  800f92:	83 f6 1f             	xor    $0x1f,%esi
  800f95:	75 4d                	jne    800fe4 <__umoddi3+0x114>
  800f97:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f9a:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800f9d:	77 08                	ja     800fa7 <__umoddi3+0xd7>
  800f9f:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  800fa2:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800fa5:	72 12                	jb     800fb9 <__umoddi3+0xe9>
  800fa7:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800faa:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fad:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  800fb0:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800fb3:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800fb6:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800fb9:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800fbc:	85 d2                	test   %edx,%edx
  800fbe:	0f 84 74 ff ff ff    	je     800f38 <__umoddi3+0x68>
  800fc4:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fc7:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fca:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800fcd:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800fd0:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800fd3:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800fd6:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800fd9:	89 01                	mov    %eax,(%ecx)
  800fdb:	89 51 04             	mov    %edx,0x4(%ecx)
  800fde:	e9 55 ff ff ff       	jmp    800f38 <__umoddi3+0x68>
  800fe3:	90                   	nop    
  800fe4:	b8 20 00 00 00       	mov    $0x20,%eax
  800fe9:	29 f0                	sub    %esi,%eax
  800feb:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800fee:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800ff1:	89 f1                	mov    %esi,%ecx
  800ff3:	d3 e2                	shl    %cl,%edx
  800ff5:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800ff8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800ffb:	d3 e8                	shr    %cl,%eax
  800ffd:	09 c2                	or     %eax,%edx
  800fff:	89 f1                	mov    %esi,%ecx
  801001:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801004:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801007:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80100a:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80100d:	d3 ea                	shr    %cl,%edx
  80100f:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  801012:	89 f1                	mov    %esi,%ecx
  801014:	d3 e7                	shl    %cl,%edi
  801016:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801019:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80101c:	d3 e8                	shr    %cl,%eax
  80101e:	09 c7                	or     %eax,%edi
  801020:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801023:	89 f8                	mov    %edi,%eax
  801025:	89 f1                	mov    %esi,%ecx
  801027:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80102a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  80102d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801030:	f7 65 cc             	mull   0xffffffcc(%ebp)
  801033:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801036:	89 c7                	mov    %eax,%edi
  801038:	77 3f                	ja     801079 <__umoddi3+0x1a9>
  80103a:	74 38                	je     801074 <__umoddi3+0x1a4>
  80103c:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80103f:	85 c0                	test   %eax,%eax
  801041:	0f 84 f1 fe ff ff    	je     800f38 <__umoddi3+0x68>
  801047:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  80104a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80104d:	29 f8                	sub    %edi,%eax
  80104f:	19 d1                	sbb    %edx,%ecx
  801051:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  801054:	89 ca                	mov    %ecx,%edx
  801056:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801059:	d3 e2                	shl    %cl,%edx
  80105b:	89 f1                	mov    %esi,%ecx
  80105d:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801060:	d3 e8                	shr    %cl,%eax
  801062:	09 c2                	or     %eax,%edx
  801064:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  801067:	d3 e8                	shr    %cl,%eax
  801069:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  80106c:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80106f:	e9 b6 fe ff ff       	jmp    800f2a <__umoddi3+0x5a>
  801074:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  801077:	76 c3                	jbe    80103c <__umoddi3+0x16c>
  801079:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  80107c:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80107f:	eb bb                	jmp    80103c <__umoddi3+0x16c>
  801081:	90                   	nop    
  801082:	90                   	nop    
  801083:	90                   	nop    
