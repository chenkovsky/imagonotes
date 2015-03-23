
obj/user/faultnostack：     文件格式 elf32-i386

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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
void _pgfault_upcall();

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	68 54 04 80 00       	push   $0x800454
  80003f:	6a 00                	push   $0x0
  800041:	e8 38 03 00 00       	call   80037e <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800046:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004d:	00 00 00 
}
  800050:	c9                   	leave  
  800051:	c3                   	ret    
	...

00800054 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 75 08             	mov    0x8(%ebp),%esi
  80005c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  80005f:	e8 f2 00 00 00       	call   800156 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	c1 e0 07             	shl    $0x7,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 f6                	test   %esi,%esi
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 03                	mov    (%ebx),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	53                   	push   %ebx
  800085:	56                   	push   %esi
  800086:	e8 a9 ff ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  80008b:	e8 08 00 00 00       	call   800098 <exit>
}
  800090:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	c9                   	leave  
  800096:	c3                   	ret    
	...

00800098 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 60 00 00 00       	call   800105 <sys_env_destroy>
}
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    
	...

008000a8 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8000b9:	89 f8                	mov    %edi,%eax
  8000bb:	89 fb                	mov    %edi,%ebx
  8000bd:	89 fe                	mov    %edi,%esi
  8000bf:	55                   	push   %ebp
  8000c0:	9c                   	pushf  
  8000c1:	56                   	push   %esi
  8000c2:	54                   	push   %esp
  8000c3:	5d                   	pop    %ebp
  8000c4:	8d 35 cc 00 80 00    	lea    0x8000cc,%esi
  8000ca:	0f 34                	sysenter 
  8000cc:	83 c4 04             	add    $0x4,%esp
  8000cf:	9d                   	popf   
  8000d0:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8000e6:	89 fa                	mov    %edi,%edx
  8000e8:	89 f9                	mov    %edi,%ecx
  8000ea:	89 fb                	mov    %edi,%ebx
  8000ec:	89 fe                	mov    %edi,%esi
  8000ee:	55                   	push   %ebp
  8000ef:	9c                   	pushf  
  8000f0:	56                   	push   %esi
  8000f1:	54                   	push   %esp
  8000f2:	5d                   	pop    %ebp
  8000f3:	8d 35 fb 00 80 00    	lea    0x8000fb,%esi
  8000f9:	0f 34                	sysenter 
  8000fb:	83 c4 04             	add    $0x4,%esp
  8000fe:	9d                   	popf   
  8000ff:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	8b 55 08             	mov    0x8(%ebp),%edx
  800111:	b8 03 00 00 00       	mov    $0x3,%eax
  800116:	bf 00 00 00 00       	mov    $0x0,%edi
  80011b:	89 f9                	mov    %edi,%ecx
  80011d:	89 fb                	mov    %edi,%ebx
  80011f:	89 fe                	mov    %edi,%esi
  800121:	55                   	push   %ebp
  800122:	9c                   	pushf  
  800123:	56                   	push   %esi
  800124:	54                   	push   %esp
  800125:	5d                   	pop    %ebp
  800126:	8d 35 2e 01 80 00    	lea    0x80012e,%esi
  80012c:	0f 34                	sysenter 
  80012e:	83 c4 04             	add    $0x4,%esp
  800131:	9d                   	popf   
  800132:	5d                   	pop    %ebp
  800133:	85 c0                	test   %eax,%eax
  800135:	7e 17                	jle    80014e <sys_env_destroy+0x49>
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	50                   	push   %eax
  80013b:	6a 03                	push   $0x3
  80013d:	68 f7 10 80 00       	push   $0x8010f7
  800142:	6a 4c                	push   $0x4c
  800144:	68 14 11 80 00       	push   $0x801114
  800149:	e8 2e 03 00 00       	call   80047c <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	b8 02 00 00 00       	mov    $0x2,%eax
  800161:	bf 00 00 00 00       	mov    $0x0,%edi
  800166:	89 fa                	mov    %edi,%edx
  800168:	89 f9                	mov    %edi,%ecx
  80016a:	89 fb                	mov    %edi,%ebx
  80016c:	89 fe                	mov    %edi,%esi
  80016e:	55                   	push   %ebp
  80016f:	9c                   	pushf  
  800170:	56                   	push   %esi
  800171:	54                   	push   %esp
  800172:	5d                   	pop    %ebp
  800173:	8d 35 7b 01 80 00    	lea    0x80017b,%esi
  800179:	0f 34                	sysenter 
  80017b:	83 c4 04             	add    $0x4,%esp
  80017e:	9d                   	popf   
  80017f:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <sys_dump_env>:

int
sys_dump_env(void)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	bf 00 00 00 00       	mov    $0x0,%edi
  800195:	89 fa                	mov    %edi,%edx
  800197:	89 f9                	mov    %edi,%ecx
  800199:	89 fb                	mov    %edi,%ebx
  80019b:	89 fe                	mov    %edi,%esi
  80019d:	55                   	push   %ebp
  80019e:	9c                   	pushf  
  80019f:	56                   	push   %esi
  8001a0:	54                   	push   %esp
  8001a1:	5d                   	pop    %ebp
  8001a2:	8d 35 aa 01 80 00    	lea    0x8001aa,%esi
  8001a8:	0f 34                	sysenter 
  8001aa:	83 c4 04             	add    $0x4,%esp
  8001ad:	9d                   	popf   
  8001ae:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5f                   	pop    %edi
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <sys_yield>:

void
sys_yield(void)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8001c4:	89 fa                	mov    %edi,%edx
  8001c6:	89 f9                	mov    %edi,%ecx
  8001c8:	89 fb                	mov    %edi,%ebx
  8001ca:	89 fe                	mov    %edi,%esi
  8001cc:	55                   	push   %ebp
  8001cd:	9c                   	pushf  
  8001ce:	56                   	push   %esi
  8001cf:	54                   	push   %esp
  8001d0:	5d                   	pop    %ebp
  8001d1:	8d 35 d9 01 80 00    	lea    0x8001d9,%esi
  8001d7:	0f 34                	sysenter 
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	9d                   	popf   
  8001dd:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ff:	89 fe                	mov    %edi,%esi
  800201:	55                   	push   %ebp
  800202:	9c                   	pushf  
  800203:	56                   	push   %esi
  800204:	54                   	push   %esp
  800205:	5d                   	pop    %ebp
  800206:	8d 35 0e 02 80 00    	lea    0x80020e,%esi
  80020c:	0f 34                	sysenter 
  80020e:	83 c4 04             	add    $0x4,%esp
  800211:	9d                   	popf   
  800212:	5d                   	pop    %ebp
  800213:	85 c0                	test   %eax,%eax
  800215:	7e 17                	jle    80022e <sys_page_alloc+0x4b>
  800217:	83 ec 0c             	sub    $0xc,%esp
  80021a:	50                   	push   %eax
  80021b:	6a 05                	push   $0x5
  80021d:	68 f7 10 80 00       	push   $0x8010f7
  800222:	6a 4c                	push   $0x4c
  800224:	68 14 11 80 00       	push   $0x801114
  800229:	e8 4e 02 00 00       	call   80047c <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	57                   	push   %edi
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800248:	8b 7d 14             	mov    0x14(%ebp),%edi
  80024b:	8b 75 18             	mov    0x18(%ebp),%esi
  80024e:	b8 06 00 00 00       	mov    $0x6,%eax
  800253:	55                   	push   %ebp
  800254:	9c                   	pushf  
  800255:	56                   	push   %esi
  800256:	54                   	push   %esp
  800257:	5d                   	pop    %ebp
  800258:	8d 35 60 02 80 00    	lea    0x800260,%esi
  80025e:	0f 34                	sysenter 
  800260:	83 c4 04             	add    $0x4,%esp
  800263:	9d                   	popf   
  800264:	5d                   	pop    %ebp
  800265:	85 c0                	test   %eax,%eax
  800267:	7e 17                	jle    800280 <sys_page_map+0x4a>
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	50                   	push   %eax
  80026d:	6a 06                	push   $0x6
  80026f:	68 f7 10 80 00       	push   $0x8010f7
  800274:	6a 4c                	push   $0x4c
  800276:	68 14 11 80 00       	push   $0x801114
  80027b:	e8 fc 01 00 00       	call   80047c <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800280:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5f                   	pop    %edi
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800297:	b8 07 00 00 00       	mov    $0x7,%eax
  80029c:	bf 00 00 00 00       	mov    $0x0,%edi
  8002a1:	89 fb                	mov    %edi,%ebx
  8002a3:	89 fe                	mov    %edi,%esi
  8002a5:	55                   	push   %ebp
  8002a6:	9c                   	pushf  
  8002a7:	56                   	push   %esi
  8002a8:	54                   	push   %esp
  8002a9:	5d                   	pop    %ebp
  8002aa:	8d 35 b2 02 80 00    	lea    0x8002b2,%esi
  8002b0:	0f 34                	sysenter 
  8002b2:	83 c4 04             	add    $0x4,%esp
  8002b5:	9d                   	popf   
  8002b6:	5d                   	pop    %ebp
  8002b7:	85 c0                	test   %eax,%eax
  8002b9:	7e 17                	jle    8002d2 <sys_page_unmap+0x4a>
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	50                   	push   %eax
  8002bf:	6a 07                	push   $0x7
  8002c1:	68 f7 10 80 00       	push   $0x8010f7
  8002c6:	6a 4c                	push   $0x4c
  8002c8:	68 14 11 80 00       	push   $0x801114
  8002cd:	e8 aa 01 00 00       	call   80047c <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002d2:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    

008002da <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8002f3:	89 fb                	mov    %edi,%ebx
  8002f5:	89 fe                	mov    %edi,%esi
  8002f7:	55                   	push   %ebp
  8002f8:	9c                   	pushf  
  8002f9:	56                   	push   %esi
  8002fa:	54                   	push   %esp
  8002fb:	5d                   	pop    %ebp
  8002fc:	8d 35 04 03 80 00    	lea    0x800304,%esi
  800302:	0f 34                	sysenter 
  800304:	83 c4 04             	add    $0x4,%esp
  800307:	9d                   	popf   
  800308:	5d                   	pop    %ebp
  800309:	85 c0                	test   %eax,%eax
  80030b:	7e 17                	jle    800324 <sys_env_set_status+0x4a>
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	50                   	push   %eax
  800311:	6a 09                	push   $0x9
  800313:	68 f7 10 80 00       	push   $0x8010f7
  800318:	6a 4c                	push   $0x4c
  80031a:	68 14 11 80 00       	push   $0x801114
  80031f:	e8 58 01 00 00       	call   80047c <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800324:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800327:	5b                   	pop    %ebx
  800328:	5e                   	pop    %esi
  800329:	5f                   	pop    %edi
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	57                   	push   %edi
  800330:	56                   	push   %esi
  800331:	53                   	push   %ebx
  800332:	83 ec 0c             	sub    $0xc,%esp
  800335:	8b 55 08             	mov    0x8(%ebp),%edx
  800338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800340:	bf 00 00 00 00       	mov    $0x0,%edi
  800345:	89 fb                	mov    %edi,%ebx
  800347:	89 fe                	mov    %edi,%esi
  800349:	55                   	push   %ebp
  80034a:	9c                   	pushf  
  80034b:	56                   	push   %esi
  80034c:	54                   	push   %esp
  80034d:	5d                   	pop    %ebp
  80034e:	8d 35 56 03 80 00    	lea    0x800356,%esi
  800354:	0f 34                	sysenter 
  800356:	83 c4 04             	add    $0x4,%esp
  800359:	9d                   	popf   
  80035a:	5d                   	pop    %ebp
  80035b:	85 c0                	test   %eax,%eax
  80035d:	7e 17                	jle    800376 <sys_env_set_trapframe+0x4a>
  80035f:	83 ec 0c             	sub    $0xc,%esp
  800362:	50                   	push   %eax
  800363:	6a 0a                	push   $0xa
  800365:	68 f7 10 80 00       	push   $0x8010f7
  80036a:	6a 4c                	push   $0x4c
  80036c:	68 14 11 80 00       	push   $0x801114
  800371:	e8 06 01 00 00       	call   80047c <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800376:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800379:	5b                   	pop    %ebx
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	c9                   	leave  
  80037d:	c3                   	ret    

0080037e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	57                   	push   %edi
  800382:	56                   	push   %esi
  800383:	53                   	push   %ebx
  800384:	83 ec 0c             	sub    $0xc,%esp
  800387:	8b 55 08             	mov    0x8(%ebp),%edx
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800392:	bf 00 00 00 00       	mov    $0x0,%edi
  800397:	89 fb                	mov    %edi,%ebx
  800399:	89 fe                	mov    %edi,%esi
  80039b:	55                   	push   %ebp
  80039c:	9c                   	pushf  
  80039d:	56                   	push   %esi
  80039e:	54                   	push   %esp
  80039f:	5d                   	pop    %ebp
  8003a0:	8d 35 a8 03 80 00    	lea    0x8003a8,%esi
  8003a6:	0f 34                	sysenter 
  8003a8:	83 c4 04             	add    $0x4,%esp
  8003ab:	9d                   	popf   
  8003ac:	5d                   	pop    %ebp
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	7e 17                	jle    8003c8 <sys_env_set_pgfault_upcall+0x4a>
  8003b1:	83 ec 0c             	sub    $0xc,%esp
  8003b4:	50                   	push   %eax
  8003b5:	6a 0b                	push   $0xb
  8003b7:	68 f7 10 80 00       	push   $0x8010f7
  8003bc:	6a 4c                	push   $0x4c
  8003be:	68 14 11 80 00       	push   $0x801114
  8003c3:	e8 b4 00 00 00       	call   80047c <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003c8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8003cb:	5b                   	pop    %ebx
  8003cc:	5e                   	pop    %esi
  8003cd:	5f                   	pop    %edi
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003df:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003e7:	be 00 00 00 00       	mov    $0x0,%esi
  8003ec:	55                   	push   %ebp
  8003ed:	9c                   	pushf  
  8003ee:	56                   	push   %esi
  8003ef:	54                   	push   %esp
  8003f0:	5d                   	pop    %ebp
  8003f1:	8d 35 f9 03 80 00    	lea    0x8003f9,%esi
  8003f7:	0f 34                	sysenter 
  8003f9:	83 c4 04             	add    $0x4,%esp
  8003fc:	9d                   	popf   
  8003fd:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003fe:	5b                   	pop    %ebx
  8003ff:	5e                   	pop    %esi
  800400:	5f                   	pop    %edi
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	57                   	push   %edi
  800407:	56                   	push   %esi
  800408:	53                   	push   %ebx
  800409:	83 ec 0c             	sub    $0xc,%esp
  80040c:	8b 55 08             	mov    0x8(%ebp),%edx
  80040f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800414:	bf 00 00 00 00       	mov    $0x0,%edi
  800419:	89 f9                	mov    %edi,%ecx
  80041b:	89 fb                	mov    %edi,%ebx
  80041d:	89 fe                	mov    %edi,%esi
  80041f:	55                   	push   %ebp
  800420:	9c                   	pushf  
  800421:	56                   	push   %esi
  800422:	54                   	push   %esp
  800423:	5d                   	pop    %ebp
  800424:	8d 35 2c 04 80 00    	lea    0x80042c,%esi
  80042a:	0f 34                	sysenter 
  80042c:	83 c4 04             	add    $0x4,%esp
  80042f:	9d                   	popf   
  800430:	5d                   	pop    %ebp
  800431:	85 c0                	test   %eax,%eax
  800433:	7e 17                	jle    80044c <sys_ipc_recv+0x49>
  800435:	83 ec 0c             	sub    $0xc,%esp
  800438:	50                   	push   %eax
  800439:	6a 0e                	push   $0xe
  80043b:	68 f7 10 80 00       	push   $0x8010f7
  800440:	6a 4c                	push   $0x4c
  800442:	68 14 11 80 00       	push   $0x801114
  800447:	e8 30 00 00 00       	call   80047c <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80044c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80044f:	5b                   	pop    %ebx
  800450:	5e                   	pop    %esi
  800451:	5f                   	pop    %edi
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <_pgfault_upcall>:
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800454:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800455:	a1 0c 20 80 00       	mov    0x80200c,%eax
    //xchg %bx, %bx
	call *%eax
  80045a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80045c:	83 c4 04             	add    $0x4,%esp
	
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
  80045f:	83 c4 08             	add    $0x8,%esp
/*    //it's wrong
    movl %esp,%eax//old esp is stored in the upper 40byte of the current esp
    addl $40,%eax //eax point to the old esp
    //xchg %bx, %bx
    movl %eax,%edx
    addl $4,%edx //then edx points to the retaddr
    movl %edx,(%eax)//set the esp in the stack to the 
*/   
    movl 32(%esp),%edx //edx is the old eip 
  800462:	8b 54 24 20          	mov    0x20(%esp),%edx
    movl 40(%esp),%eax //eax is the old esp
  800466:	8b 44 24 28          	mov    0x28(%esp),%eax
    subl $4, %eax // then eax point to the place where the return address will be store
  80046a:	83 e8 04             	sub    $0x4,%eax
    movl %edx,(%eax)//the old eip is stored in the return address place.maybe this will cause recursive copyonwrite pagefault
  80046d:	89 10                	mov    %edx,(%eax)
    movl %eax,40(%esp)//then the value of the esp place in the utf points to the old eip
  80046f:	89 44 24 28          	mov    %eax,0x28(%esp)
    //because the register will be restored, so don't care the eax and edx
	// Restore the trap-time registers.
	// LAB 4: Your code here.
    popal
  800473:	61                   	popa   
	// Restore eflags from the stack.
	// LAB 4: Your code here.
    addl $4,%esp
  800474:	83 c4 04             	add    $0x4,%esp
    popfl
  800477:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    //xchg %bx,%bx
    popl %esp//then esp points to the retaddr
  800478:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    //xchg %bx, %bx
    ret
  800479:	c3                   	ret    
	...

0080047c <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	53                   	push   %ebx
  800480:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  800483:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800486:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80048d:	74 16                	je     8004a5 <_panic+0x29>
		cprintf("%s: ", argv0);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 35 08 20 80 00    	pushl  0x802008
  800498:	68 22 11 80 00       	push   $0x801122
  80049d:	e8 ca 00 00 00       	call   80056c <cprintf>
  8004a2:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	ff 75 08             	pushl  0x8(%ebp)
  8004ab:	ff 35 00 20 80 00    	pushl  0x802000
  8004b1:	68 27 11 80 00       	push   $0x801127
  8004b6:	e8 b1 00 00 00       	call   80056c <cprintf>
	vcprintf(fmt, ap);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	53                   	push   %ebx
  8004bf:	ff 75 10             	pushl  0x10(%ebp)
  8004c2:	e8 54 00 00 00       	call   80051b <vcprintf>
	cprintf("\n");
  8004c7:	c7 04 24 43 11 80 00 	movl   $0x801143,(%esp)
  8004ce:	e8 99 00 00 00       	call   80056c <cprintf>

	// Cause a breakpoint exception
	while (1)
  8004d3:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8004d6:	cc                   	int3   
  8004d7:	eb fd                	jmp    8004d6 <_panic+0x5a>
}
  8004d9:	00 00                	add    %al,(%eax)
	...

008004dc <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	53                   	push   %ebx
  8004e0:	83 ec 04             	sub    $0x4,%esp
  8004e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004e6:	8b 03                	mov    (%ebx),%eax
  8004e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004ef:	40                   	inc    %eax
  8004f0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004f7:	75 1a                	jne    800513 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	68 ff 00 00 00       	push   $0xff
  800501:	8d 43 08             	lea    0x8(%ebx),%eax
  800504:	50                   	push   %eax
  800505:	e8 9e fb ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  80050a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800510:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800513:	ff 43 04             	incl   0x4(%ebx)
}
  800516:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800524:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  80052b:	00 00 00 
	b.cnt = 0;
  80052e:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800535:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800538:	ff 75 0c             	pushl  0xc(%ebp)
  80053b:	ff 75 08             	pushl  0x8(%ebp)
  80053e:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800544:	50                   	push   %eax
  800545:	68 dc 04 80 00       	push   $0x8004dc
  80054a:	e8 83 01 00 00       	call   8006d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800558:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  80055e:	50                   	push   %eax
  80055f:	e8 44 fb ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
  800564:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800572:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800575:	50                   	push   %eax
  800576:	ff 75 08             	pushl  0x8(%ebp)
  800579:	e8 9d ff ff ff       	call   80051b <vcprintf>
	va_end(ap);

	return cnt;
}
  80057e:	c9                   	leave  
  80057f:	c3                   	ret    

00800580 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 0c             	sub    $0xc,%esp
  800589:	8b 75 10             	mov    0x10(%ebp),%esi
  80058c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80058f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800592:	8b 45 18             	mov    0x18(%ebp),%eax
  800595:	ba 00 00 00 00       	mov    $0x0,%edx
  80059a:	39 d7                	cmp    %edx,%edi
  80059c:	72 39                	jb     8005d7 <printnum+0x57>
  80059e:	77 04                	ja     8005a4 <printnum+0x24>
  8005a0:	39 c6                	cmp    %eax,%esi
  8005a2:	72 33                	jb     8005d7 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005a4:	83 ec 04             	sub    $0x4,%esp
  8005a7:	ff 75 20             	pushl  0x20(%ebp)
  8005aa:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8005ad:	50                   	push   %eax
  8005ae:	ff 75 18             	pushl  0x18(%ebp)
  8005b1:	8b 45 18             	mov    0x18(%ebp),%eax
  8005b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b9:	52                   	push   %edx
  8005ba:	50                   	push   %eax
  8005bb:	57                   	push   %edi
  8005bc:	56                   	push   %esi
  8005bd:	e8 4a 08 00 00       	call   800e0c <__udivdi3>
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	52                   	push   %edx
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ca:	ff 75 08             	pushl  0x8(%ebp)
  8005cd:	e8 ae ff ff ff       	call   800580 <printnum>
  8005d2:	83 c4 20             	add    $0x20,%esp
  8005d5:	eb 19                	jmp    8005f0 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005d7:	4b                   	dec    %ebx
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7e 14                	jle    8005f0 <printnum+0x70>
			putch(padc, putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	ff 75 0c             	pushl  0xc(%ebp)
  8005e2:	ff 75 20             	pushl  0x20(%ebp)
  8005e5:	ff 55 08             	call   *0x8(%ebp)
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	4b                   	dec    %ebx
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f ec                	jg     8005dc <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	ff 75 0c             	pushl  0xc(%ebp)
  8005f6:	8b 45 18             	mov    0x18(%ebp),%eax
  8005f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fe:	83 ec 04             	sub    $0x4,%esp
  800601:	52                   	push   %edx
  800602:	50                   	push   %eax
  800603:	57                   	push   %edi
  800604:	56                   	push   %esi
  800605:	e8 22 09 00 00       	call   800f2c <__umoddi3>
  80060a:	83 c4 14             	add    $0x14,%esp
  80060d:	0f be 80 d8 11 80 00 	movsbl 0x8011d8(%eax),%eax
  800614:	50                   	push   %eax
  800615:	ff 55 08             	call   *0x8(%ebp)
}
  800618:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80061b:	5b                   	pop    %ebx
  80061c:	5e                   	pop    %esi
  80061d:	5f                   	pop    %edi
  80061e:	c9                   	leave  
  80061f:	c3                   	ret    

00800620 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  800620:	55                   	push   %ebp
  800621:	89 e5                	mov    %esp,%ebp
  800623:	56                   	push   %esi
  800624:	53                   	push   %ebx
  800625:	83 ec 18             	sub    $0x18,%esp
  800628:	8b 75 08             	mov    0x8(%ebp),%esi
  80062b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80062e:	8a 45 18             	mov    0x18(%ebp),%al
  800631:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  800634:	53                   	push   %ebx
  800635:	6a 1b                	push   $0x1b
  800637:	ff d6                	call   *%esi
	putch('[', putdat);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 5b                	push   $0x5b
  80063f:	ff d6                	call   *%esi
	putch('0', putdat);
  800641:	83 c4 08             	add    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 30                	push   $0x30
  800647:	ff d6                	call   *%esi
	putch(';', putdat);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 3b                	push   $0x3b
  80064f:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800651:	83 c4 0c             	add    $0xc,%esp
  800654:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800658:	50                   	push   %eax
  800659:	ff 75 14             	pushl  0x14(%ebp)
  80065c:	6a 0a                	push   $0xa
  80065e:	8b 45 10             	mov    0x10(%ebp),%eax
  800661:	99                   	cltd   
  800662:	52                   	push   %edx
  800663:	50                   	push   %eax
  800664:	53                   	push   %ebx
  800665:	56                   	push   %esi
  800666:	e8 15 ff ff ff       	call   800580 <printnum>
	putch('m', putdat);
  80066b:	83 c4 18             	add    $0x18,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 6d                	push   $0x6d
  800671:	ff d6                	call   *%esi

}
  800673:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	c9                   	leave  
  800679:	c3                   	ret    

0080067a <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800680:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800683:	83 f8 01             	cmp    $0x1,%eax
  800686:	7e 0f                	jle    800697 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800688:	8b 01                	mov    (%ecx),%eax
  80068a:	83 c0 08             	add    $0x8,%eax
  80068d:	89 01                	mov    %eax,(%ecx)
  80068f:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800692:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800695:	eb 0f                	jmp    8006a6 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800697:	8b 01                	mov    (%ecx),%eax
  800699:	83 c0 04             	add    $0x4,%eax
  80069c:	89 01                	mov    %eax,(%ecx)
  80069e:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8006a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a6:	c9                   	leave  
  8006a7:	c3                   	ret    

008006a8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8006b1:	83 f8 01             	cmp    $0x1,%eax
  8006b4:	7e 0f                	jle    8006c5 <getint+0x1d>
		return va_arg(*ap, long long);
  8006b6:	8b 02                	mov    (%edx),%eax
  8006b8:	83 c0 08             	add    $0x8,%eax
  8006bb:	89 02                	mov    %eax,(%edx)
  8006bd:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8006c0:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8006c3:	eb 0b                	jmp    8006d0 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  8006c5:	8b 02                	mov    (%edx),%eax
  8006c7:	83 c0 04             	add    $0x4,%eax
  8006ca:	89 02                	mov    %eax,(%edx)
  8006cc:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8006cf:	99                   	cltd   
}
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 1c             	sub    $0x1c,%esp
  8006db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006de:	0f b6 13             	movzbl (%ebx),%edx
  8006e1:	43                   	inc    %ebx
  8006e2:	83 fa 25             	cmp    $0x25,%edx
  8006e5:	74 1e                	je     800705 <vprintfmt+0x33>
			if (ch == '\0')
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	0f 84 dc 02 00 00    	je     8009cb <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	0f b6 13             	movzbl (%ebx),%edx
  8006ff:	43                   	inc    %ebx
  800700:	83 fa 25             	cmp    $0x25,%edx
  800703:	75 e2                	jne    8006e7 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800705:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  800709:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  800710:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800715:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  80071a:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  800721:	0f b6 13             	movzbl (%ebx),%edx
  800724:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  800727:	43                   	inc    %ebx
  800728:	83 f8 55             	cmp    $0x55,%eax
  80072b:	0f 87 75 02 00 00    	ja     8009a6 <vprintfmt+0x2d4>
  800731:	ff 24 85 24 12 80 00 	jmp    *0x801224(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800738:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  80073c:	eb e3                	jmp    800721 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80073e:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800742:	eb dd                	jmp    800721 <vprintfmt+0x4f>

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
  800744:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800749:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80074c:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800750:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800753:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800756:	83 f8 09             	cmp    $0x9,%eax
  800759:	77 27                	ja     800782 <vprintfmt+0xb0>
  80075b:	43                   	inc    %ebx
  80075c:	eb eb                	jmp    800749 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800768:	eb 18                	jmp    800782 <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  80076a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80076e:	79 b1                	jns    800721 <vprintfmt+0x4f>
				width = 0;
  800770:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  800777:	eb a8                	jmp    800721 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800779:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800780:	eb 9f                	jmp    800721 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  800782:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800786:	79 99                	jns    800721 <vprintfmt+0x4f>
				width = precision, precision = -1;
  800788:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80078b:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800790:	eb 8f                	jmp    800721 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  800792:	41                   	inc    %ecx
			goto reswitch;
  800793:	eb 8c                	jmp    800721 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	ff 70 fc             	pushl  0xfffffffc(%eax)
  8007a5:	e9 c4 01 00 00       	jmp    80096e <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  8007aa:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  8007b4:	85 c0                	test   %eax,%eax
  8007b6:	79 02                	jns    8007ba <vprintfmt+0xe8>
				err = -err;
  8007b8:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8007ba:	83 f8 08             	cmp    $0x8,%eax
  8007bd:	7f 0b                	jg     8007ca <vprintfmt+0xf8>
  8007bf:	8b 3c 85 00 12 80 00 	mov    0x801200(,%eax,4),%edi
  8007c6:	85 ff                	test   %edi,%edi
  8007c8:	75 08                	jne    8007d2 <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  8007ca:	50                   	push   %eax
  8007cb:	68 e9 11 80 00       	push   $0x8011e9
  8007d0:	eb 06                	jmp    8007d8 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  8007d2:	57                   	push   %edi
  8007d3:	68 f2 11 80 00       	push   $0x8011f2
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	ff 75 08             	pushl  0x8(%ebp)
  8007de:	e8 f0 01 00 00       	call   8009d3 <printfmt>
  8007e3:	e9 89 01 00 00       	jmp    800971 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007e8:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8007f2:	85 ff                	test   %edi,%edi
  8007f4:	75 05                	jne    8007fb <vprintfmt+0x129>
				p = "(null)";
  8007f6:	bf f5 11 80 00       	mov    $0x8011f5,%edi
			if (width > 0 && padc != '-')
  8007fb:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8007ff:	7e 3b                	jle    80083c <vprintfmt+0x16a>
  800801:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  800805:	74 35                	je     80083c <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	56                   	push   %esi
  80080b:	57                   	push   %edi
  80080c:	e8 74 02 00 00       	call   800a85 <strnlen>
  800811:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80081b:	7e 1f                	jle    80083c <vprintfmt+0x16a>
  80081d:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800821:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	ff 75 0c             	pushl  0xc(%ebp)
  80082a:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  80082d:	ff 55 08             	call   *0x8(%ebp)
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800836:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80083a:	7f e8                	jg     800824 <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80083c:	0f be 17             	movsbl (%edi),%edx
  80083f:	47                   	inc    %edi
  800840:	85 d2                	test   %edx,%edx
  800842:	74 3e                	je     800882 <vprintfmt+0x1b0>
  800844:	85 f6                	test   %esi,%esi
  800846:	78 03                	js     80084b <vprintfmt+0x179>
  800848:	4e                   	dec    %esi
  800849:	78 37                	js     800882 <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  80084b:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  80084f:	74 12                	je     800863 <vprintfmt+0x191>
  800851:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800854:	83 f8 5e             	cmp    $0x5e,%eax
  800857:	76 0a                	jbe    800863 <vprintfmt+0x191>
					putch('?', putdat);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	6a 3f                	push   $0x3f
  800861:	eb 07                	jmp    80086a <vprintfmt+0x198>
				else
					putch(ch, putdat);
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	52                   	push   %edx
  80086a:	ff 55 08             	call   *0x8(%ebp)
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800873:	0f be 17             	movsbl (%edi),%edx
  800876:	47                   	inc    %edi
  800877:	85 d2                	test   %edx,%edx
  800879:	74 07                	je     800882 <vprintfmt+0x1b0>
  80087b:	85 f6                	test   %esi,%esi
  80087d:	78 cc                	js     80084b <vprintfmt+0x179>
  80087f:	4e                   	dec    %esi
  800880:	79 c9                	jns    80084b <vprintfmt+0x179>
			for (; width > 0; width--)
  800882:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800886:	0f 8e 52 fe ff ff    	jle    8006de <vprintfmt+0xc>
				putch(' ', putdat);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	ff 75 0c             	pushl  0xc(%ebp)
  800892:	6a 20                	push   $0x20
  800894:	ff 55 08             	call   *0x8(%ebp)
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80089d:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8008a1:	7f e9                	jg     80088c <vprintfmt+0x1ba>
			break;
  8008a3:	e9 36 fe ff ff       	jmp    8006de <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	51                   	push   %ecx
  8008ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8008af:	50                   	push   %eax
  8008b0:	e8 f3 fd ff ff       	call   8006a8 <getint>
  8008b5:	89 c6                	mov    %eax,%esi
  8008b7:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	85 d2                	test   %edx,%edx
  8008be:	79 15                	jns    8008d5 <vprintfmt+0x203>
				putch('-', putdat);
  8008c0:	83 ec 08             	sub    $0x8,%esp
  8008c3:	ff 75 0c             	pushl  0xc(%ebp)
  8008c6:	6a 2d                	push   $0x2d
  8008c8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008cb:	f7 de                	neg    %esi
  8008cd:	83 d7 00             	adc    $0x0,%edi
  8008d0:	f7 df                	neg    %edi
  8008d2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008d5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8008da:	eb 70                	jmp    80094c <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	51                   	push   %ecx
  8008e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e3:	50                   	push   %eax
  8008e4:	e8 91 fd ff ff       	call   80067a <getuint>
  8008e9:	89 c6                	mov    %eax,%esi
  8008eb:	89 d7                	mov    %edx,%edi
			base = 10;
  8008ed:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8008f2:	eb 55                	jmp    800949 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	51                   	push   %ecx
  8008f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fb:	50                   	push   %eax
  8008fc:	e8 79 fd ff ff       	call   80067a <getuint>
  800901:	89 c6                	mov    %eax,%esi
  800903:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  800905:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  80090a:	eb 3d                	jmp    800949 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	ff 75 0c             	pushl  0xc(%ebp)
  800912:	6a 30                	push   $0x30
  800914:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800917:	83 c4 08             	add    $0x8,%esp
  80091a:	ff 75 0c             	pushl  0xc(%ebp)
  80091d:	6a 78                	push   $0x78
  80091f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  800922:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800926:	8b 45 14             	mov    0x14(%ebp),%eax
  800929:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  80092c:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  800931:	eb 11                	jmp    800944 <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	51                   	push   %ecx
  800937:	8d 45 14             	lea    0x14(%ebp),%eax
  80093a:	50                   	push   %eax
  80093b:	e8 3a fd ff ff       	call   80067a <getuint>
  800940:	89 c6                	mov    %eax,%esi
  800942:	89 d7                	mov    %edx,%edi
			base = 16;
  800944:	ba 10 00 00 00       	mov    $0x10,%edx
  800949:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  80094c:	83 ec 04             	sub    $0x4,%esp
  80094f:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800953:	50                   	push   %eax
  800954:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800957:	52                   	push   %edx
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	ff 75 0c             	pushl  0xc(%ebp)
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	e8 1b fc ff ff       	call   800580 <printnum>
			break;
  800965:	eb 37                	jmp    80099e <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  800967:	83 ec 08             	sub    $0x8,%esp
  80096a:	ff 75 0c             	pushl  0xc(%ebp)
  80096d:	52                   	push   %edx
  80096e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	e9 65 fd ff ff       	jmp    8006de <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800979:	83 ec 08             	sub    $0x8,%esp
  80097c:	51                   	push   %ecx
  80097d:	8d 45 14             	lea    0x14(%ebp),%eax
  800980:	50                   	push   %eax
  800981:	e8 f4 fc ff ff       	call   80067a <getuint>
  800986:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800988:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800992:	56                   	push   %esi
  800993:	ff 75 0c             	pushl  0xc(%ebp)
  800996:	ff 75 08             	pushl  0x8(%ebp)
  800999:	e8 82 fc ff ff       	call   800620 <printcolor>
			break;
  80099e:	83 c4 20             	add    $0x20,%esp
  8009a1:	e9 38 fd ff ff       	jmp    8006de <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009a6:	83 ec 08             	sub    $0x8,%esp
  8009a9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ac:	6a 25                	push   $0x25
  8009ae:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b1:	4b                   	dec    %ebx
  8009b2:	83 c4 10             	add    $0x10,%esp
  8009b5:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8009b9:	0f 84 1f fd ff ff    	je     8006de <vprintfmt+0xc>
  8009bf:	4b                   	dec    %ebx
  8009c0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8009c4:	75 f9                	jne    8009bf <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8009c6:	e9 13 fd ff ff       	jmp    8006de <vprintfmt+0xc>
		}
	}
}
  8009cb:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5f                   	pop    %edi
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8009d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009dc:	50                   	push   %eax
  8009dd:	ff 75 10             	pushl  0x10(%ebp)
  8009e0:	ff 75 0c             	pushl  0xc(%ebp)
  8009e3:	ff 75 08             	pushl  0x8(%ebp)
  8009e6:	e8 e7 fc ff ff       	call   8006d2 <vprintfmt>
	va_end(ap);
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8009f3:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8009f6:	8b 0a                	mov    (%edx),%ecx
  8009f8:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8009fb:	73 07                	jae    800a04 <sprintputch+0x17>
		*b->buf++ = ch;
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	88 01                	mov    %al,(%ecx)
  800a02:	ff 02                	incl   (%edx)
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 18             	sub    $0x18,%esp
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  800a12:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800a15:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800a19:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800a1c:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  800a23:	85 d2                	test   %edx,%edx
  800a25:	74 04                	je     800a2b <vsnprintf+0x25>
  800a27:	85 c9                	test   %ecx,%ecx
  800a29:	7f 07                	jg     800a32 <vsnprintf+0x2c>
		return -E_INVAL;
  800a2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a30:	eb 1d                	jmp    800a4f <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  800a32:	ff 75 14             	pushl  0x14(%ebp)
  800a35:	ff 75 10             	pushl  0x10(%ebp)
  800a38:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800a3b:	50                   	push   %eax
  800a3c:	68 ed 09 80 00       	push   $0x8009ed
  800a41:	e8 8c fc ff ff       	call   8006d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a46:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800a49:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a4c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800a4f:	c9                   	leave  
  800a50:	c3                   	ret    

00800a51 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a57:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a5a:	50                   	push   %eax
  800a5b:	ff 75 10             	pushl  0x10(%ebp)
  800a5e:	ff 75 0c             	pushl  0xc(%ebp)
  800a61:	ff 75 08             	pushl  0x8(%ebp)
  800a64:	e8 9d ff ff ff       	call   800a06 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    
	...

00800a6c <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	80 3a 00             	cmpb   $0x0,(%edx)
  800a7a:	74 07                	je     800a83 <strlen+0x17>
		n++;
  800a7c:	40                   	inc    %eax
  800a7d:	42                   	inc    %edx
  800a7e:	80 3a 00             	cmpb   $0x0,(%edx)
  800a81:	75 f9                	jne    800a7c <strlen+0x10>
	return n;
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	85 d2                	test   %edx,%edx
  800a95:	74 0f                	je     800aa6 <strnlen+0x21>
  800a97:	80 39 00             	cmpb   $0x0,(%ecx)
  800a9a:	74 0a                	je     800aa6 <strnlen+0x21>
		n++;
  800a9c:	40                   	inc    %eax
  800a9d:	41                   	inc    %ecx
  800a9e:	4a                   	dec    %edx
  800a9f:	74 05                	je     800aa6 <strnlen+0x21>
  800aa1:	80 39 00             	cmpb   $0x0,(%ecx)
  800aa4:	75 f6                	jne    800a9c <strnlen+0x17>
	return n;
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	53                   	push   %ebx
  800aac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800ab2:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800ab4:	8a 02                	mov    (%edx),%al
  800ab6:	42                   	inc    %edx
  800ab7:	88 01                	mov    %al,(%ecx)
  800ab9:	41                   	inc    %ecx
  800aba:	84 c0                	test   %al,%al
  800abc:	75 f6                	jne    800ab4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800abe:	89 d8                	mov    %ebx,%eax
  800ac0:	5b                   	pop    %ebx
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acf:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800ad2:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800ad4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ad9:	39 f3                	cmp    %esi,%ebx
  800adb:	73 10                	jae    800aed <strncpy+0x2a>
		*dst++ = *src;
  800add:	8a 02                	mov    (%edx),%al
  800adf:	88 01                	mov    %al,(%ecx)
  800ae1:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800ae2:	80 3a 00             	cmpb   $0x0,(%edx)
  800ae5:	74 01                	je     800ae8 <strncpy+0x25>
			src++;
  800ae7:	42                   	inc    %edx
  800ae8:	43                   	inc    %ebx
  800ae9:	39 f3                	cmp    %esi,%ebx
  800aeb:	72 f0                	jb     800add <strncpy+0x1a>
	}
	return ret;
}
  800aed:	89 f8                	mov    %edi,%eax
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	c9                   	leave  
  800af3:	c3                   	ret    

00800af4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aff:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800b02:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800b04:	85 d2                	test   %edx,%edx
  800b06:	74 19                	je     800b21 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800b08:	4a                   	dec    %edx
  800b09:	74 13                	je     800b1e <strlcpy+0x2a>
  800b0b:	80 39 00             	cmpb   $0x0,(%ecx)
  800b0e:	74 0e                	je     800b1e <strlcpy+0x2a>
			*dst++ = *src++;
  800b10:	8a 01                	mov    (%ecx),%al
  800b12:	41                   	inc    %ecx
  800b13:	88 03                	mov    %al,(%ebx)
  800b15:	43                   	inc    %ebx
  800b16:	4a                   	dec    %edx
  800b17:	74 05                	je     800b1e <strlcpy+0x2a>
  800b19:	80 39 00             	cmpb   $0x0,(%ecx)
  800b1c:	75 f2                	jne    800b10 <strlcpy+0x1c>
		*dst = '\0';
  800b1e:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800b21:	89 d8                	mov    %ebx,%eax
  800b23:	29 f0                	sub    %esi,%eax
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    

00800b29 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800b32:	80 3a 00             	cmpb   $0x0,(%edx)
  800b35:	74 13                	je     800b4a <strcmp+0x21>
  800b37:	8a 02                	mov    (%edx),%al
  800b39:	3a 01                	cmp    (%ecx),%al
  800b3b:	75 0d                	jne    800b4a <strcmp+0x21>
		p++, q++;
  800b3d:	42                   	inc    %edx
  800b3e:	41                   	inc    %ecx
  800b3f:	80 3a 00             	cmpb   $0x0,(%edx)
  800b42:	74 06                	je     800b4a <strcmp+0x21>
  800b44:	8a 02                	mov    (%edx),%al
  800b46:	3a 01                	cmp    (%ecx),%al
  800b48:	74 f3                	je     800b3d <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4a:	0f b6 02             	movzbl (%edx),%eax
  800b4d:	0f b6 11             	movzbl (%ecx),%edx
  800b50:	29 d0                	sub    %edx,%eax
}
  800b52:	c9                   	leave  
  800b53:	c3                   	ret    

00800b54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	53                   	push   %ebx
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800b61:	85 c9                	test   %ecx,%ecx
  800b63:	74 1f                	je     800b84 <strncmp+0x30>
  800b65:	80 3a 00             	cmpb   $0x0,(%edx)
  800b68:	74 16                	je     800b80 <strncmp+0x2c>
  800b6a:	8a 02                	mov    (%edx),%al
  800b6c:	3a 03                	cmp    (%ebx),%al
  800b6e:	75 10                	jne    800b80 <strncmp+0x2c>
		n--, p++, q++;
  800b70:	42                   	inc    %edx
  800b71:	43                   	inc    %ebx
  800b72:	49                   	dec    %ecx
  800b73:	74 0f                	je     800b84 <strncmp+0x30>
  800b75:	80 3a 00             	cmpb   $0x0,(%edx)
  800b78:	74 06                	je     800b80 <strncmp+0x2c>
  800b7a:	8a 02                	mov    (%edx),%al
  800b7c:	3a 03                	cmp    (%ebx),%al
  800b7e:	74 f0                	je     800b70 <strncmp+0x1c>
	if (n == 0)
  800b80:	85 c9                	test   %ecx,%ecx
  800b82:	75 07                	jne    800b8b <strncmp+0x37>
		return 0;
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
  800b89:	eb 0a                	jmp    800b95 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b8b:	0f b6 12             	movzbl (%edx),%edx
  800b8e:	0f b6 03             	movzbl (%ebx),%eax
  800b91:	29 c2                	sub    %eax,%edx
  800b93:	89 d0                	mov    %edx,%eax
}
  800b95:	8b 1c 24             	mov    (%esp),%ebx
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800ba3:	80 38 00             	cmpb   $0x0,(%eax)
  800ba6:	74 0a                	je     800bb2 <strchr+0x18>
		if (*s == c)
  800ba8:	38 10                	cmp    %dl,(%eax)
  800baa:	74 0b                	je     800bb7 <strchr+0x1d>
  800bac:	40                   	inc    %eax
  800bad:	80 38 00             	cmpb   $0x0,(%eax)
  800bb0:	75 f6                	jne    800ba8 <strchr+0xe>
			return (char *) s;
	return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbf:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800bc2:	80 38 00             	cmpb   $0x0,(%eax)
  800bc5:	74 0a                	je     800bd1 <strfind+0x18>
		if (*s == c)
  800bc7:	38 10                	cmp    %dl,(%eax)
  800bc9:	74 06                	je     800bd1 <strfind+0x18>
  800bcb:	40                   	inc    %eax
  800bcc:	80 38 00             	cmpb   $0x0,(%eax)
  800bcf:	75 f6                	jne    800bc7 <strfind+0xe>
			break;
	return (char *) s;
}
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    

00800bd3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bdd:	89 f8                	mov    %edi,%eax
  800bdf:	85 c9                	test   %ecx,%ecx
  800be1:	74 40                	je     800c23 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be9:	75 30                	jne    800c1b <memset+0x48>
  800beb:	f6 c1 03             	test   $0x3,%cl
  800bee:	75 2b                	jne    800c1b <memset+0x48>
		c &= 0xFF;
  800bf0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfa:	c1 e0 18             	shl    $0x18,%eax
  800bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c00:	c1 e2 10             	shl    $0x10,%edx
  800c03:	09 d0                	or     %edx,%eax
  800c05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c08:	c1 e2 08             	shl    $0x8,%edx
  800c0b:	09 d0                	or     %edx,%eax
  800c0d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800c10:	c1 e9 02             	shr    $0x2,%ecx
  800c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c16:	fc                   	cld    
  800c17:	f3 ab                	repz stos %eax,%es:(%edi)
  800c19:	eb 06                	jmp    800c21 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1e:	fc                   	cld    
  800c1f:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c21:	89 f8                	mov    %edi,%eax
}
  800c23:	8b 3c 24             	mov    (%esp),%edi
  800c26:	c9                   	leave  
  800c27:	c3                   	ret    

00800c28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c33:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c36:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c38:	39 c6                	cmp    %eax,%esi
  800c3a:	73 33                	jae    800c6f <memmove+0x47>
  800c3c:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800c3f:	39 c2                	cmp    %eax,%edx
  800c41:	76 2c                	jbe    800c6f <memmove+0x47>
		s += n;
  800c43:	89 d6                	mov    %edx,%esi
		d += n;
  800c45:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c48:	f6 c2 03             	test   $0x3,%dl
  800c4b:	75 1b                	jne    800c68 <memmove+0x40>
  800c4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c53:	75 13                	jne    800c68 <memmove+0x40>
  800c55:	f6 c1 03             	test   $0x3,%cl
  800c58:	75 0e                	jne    800c68 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800c5a:	83 ef 04             	sub    $0x4,%edi
  800c5d:	83 ee 04             	sub    $0x4,%esi
  800c60:	c1 e9 02             	shr    $0x2,%ecx
  800c63:	fd                   	std    
  800c64:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800c66:	eb 27                	jmp    800c8f <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c68:	4f                   	dec    %edi
  800c69:	4e                   	dec    %esi
  800c6a:	fd                   	std    
  800c6b:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800c6d:	eb 20                	jmp    800c8f <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c75:	75 15                	jne    800c8c <memmove+0x64>
  800c77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7d:	75 0d                	jne    800c8c <memmove+0x64>
  800c7f:	f6 c1 03             	test   $0x3,%cl
  800c82:	75 08                	jne    800c8c <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800c84:	c1 e9 02             	shr    $0x2,%ecx
  800c87:	fc                   	cld    
  800c88:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800c8a:	eb 03                	jmp    800c8f <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c8c:	fc                   	cld    
  800c8d:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <memcpy>:

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
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c99:	ff 75 10             	pushl  0x10(%ebp)
  800c9c:	ff 75 0c             	pushl  0xc(%ebp)
  800c9f:	ff 75 08             	pushl  0x8(%ebp)
  800ca2:	e8 81 ff ff ff       	call   800c28 <memmove>
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	53                   	push   %ebx
  800cad:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800cb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  800cb6:	89 d0                	mov    %edx,%eax
  800cb8:	4a                   	dec    %edx
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	74 1b                	je     800cd8 <memcmp+0x2f>
		if (*s1 != *s2)
  800cbd:	8a 01                	mov    (%ecx),%al
  800cbf:	3a 03                	cmp    (%ebx),%al
  800cc1:	74 0c                	je     800ccf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cc3:	0f b6 d0             	movzbl %al,%edx
  800cc6:	0f b6 03             	movzbl (%ebx),%eax
  800cc9:	29 c2                	sub    %eax,%edx
  800ccb:	89 d0                	mov    %edx,%eax
  800ccd:	eb 0e                	jmp    800cdd <memcmp+0x34>
		s1++, s2++;
  800ccf:	41                   	inc    %ecx
  800cd0:	43                   	inc    %ebx
  800cd1:	89 d0                	mov    %edx,%eax
  800cd3:	4a                   	dec    %edx
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	75 e5                	jne    800cbd <memcmp+0x14>
	}

	return 0;
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cdd:	5b                   	pop    %ebx
  800cde:	c9                   	leave  
  800cdf:	c3                   	ret    

00800ce0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ce9:	89 c2                	mov    %eax,%edx
  800ceb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cee:	39 d0                	cmp    %edx,%eax
  800cf0:	73 09                	jae    800cfb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf2:	38 08                	cmp    %cl,(%eax)
  800cf4:	74 05                	je     800cfb <memfind+0x1b>
  800cf6:	40                   	inc    %eax
  800cf7:	39 d0                	cmp    %edx,%eax
  800cf9:	72 f7                	jb     800cf2 <memfind+0x12>
			break;
	return (void *) s;
}
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    

00800cfd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800d0c:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d16:	80 3a 20             	cmpb   $0x20,(%edx)
  800d19:	74 05                	je     800d20 <strtol+0x23>
  800d1b:	80 3a 09             	cmpb   $0x9,(%edx)
  800d1e:	75 0b                	jne    800d2b <strtol+0x2e>
		s++;
  800d20:	42                   	inc    %edx
  800d21:	80 3a 20             	cmpb   $0x20,(%edx)
  800d24:	74 fa                	je     800d20 <strtol+0x23>
  800d26:	80 3a 09             	cmpb   $0x9,(%edx)
  800d29:	74 f5                	je     800d20 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800d2b:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800d2e:	75 03                	jne    800d33 <strtol+0x36>
		s++;
  800d30:	42                   	inc    %edx
  800d31:	eb 0b                	jmp    800d3e <strtol+0x41>
	else if (*s == '-')
  800d33:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800d36:	75 06                	jne    800d3e <strtol+0x41>
		s++, neg = 1;
  800d38:	42                   	inc    %edx
  800d39:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3e:	85 c9                	test   %ecx,%ecx
  800d40:	74 05                	je     800d47 <strtol+0x4a>
  800d42:	83 f9 10             	cmp    $0x10,%ecx
  800d45:	75 15                	jne    800d5c <strtol+0x5f>
  800d47:	80 3a 30             	cmpb   $0x30,(%edx)
  800d4a:	75 10                	jne    800d5c <strtol+0x5f>
  800d4c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d50:	75 0a                	jne    800d5c <strtol+0x5f>
		s += 2, base = 16;
  800d52:	83 c2 02             	add    $0x2,%edx
  800d55:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d5a:	eb 1a                	jmp    800d76 <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800d5c:	85 c9                	test   %ecx,%ecx
  800d5e:	75 16                	jne    800d76 <strtol+0x79>
  800d60:	80 3a 30             	cmpb   $0x30,(%edx)
  800d63:	75 08                	jne    800d6d <strtol+0x70>
		s++, base = 8;
  800d65:	42                   	inc    %edx
  800d66:	b9 08 00 00 00       	mov    $0x8,%ecx
  800d6b:	eb 09                	jmp    800d76 <strtol+0x79>
	else if (base == 0)
  800d6d:	85 c9                	test   %ecx,%ecx
  800d6f:	75 05                	jne    800d76 <strtol+0x79>
		base = 10;
  800d71:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d76:	8a 02                	mov    (%edx),%al
  800d78:	83 e8 30             	sub    $0x30,%eax
  800d7b:	3c 09                	cmp    $0x9,%al
  800d7d:	77 08                	ja     800d87 <strtol+0x8a>
			dig = *s - '0';
  800d7f:	0f be 02             	movsbl (%edx),%eax
  800d82:	83 e8 30             	sub    $0x30,%eax
  800d85:	eb 20                	jmp    800da7 <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800d87:	8a 02                	mov    (%edx),%al
  800d89:	83 e8 61             	sub    $0x61,%eax
  800d8c:	3c 19                	cmp    $0x19,%al
  800d8e:	77 08                	ja     800d98 <strtol+0x9b>
			dig = *s - 'a' + 10;
  800d90:	0f be 02             	movsbl (%edx),%eax
  800d93:	83 e8 57             	sub    $0x57,%eax
  800d96:	eb 0f                	jmp    800da7 <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800d98:	8a 02                	mov    (%edx),%al
  800d9a:	83 e8 41             	sub    $0x41,%eax
  800d9d:	3c 19                	cmp    $0x19,%al
  800d9f:	77 12                	ja     800db3 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800da1:	0f be 02             	movsbl (%edx),%eax
  800da4:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800da7:	39 c8                	cmp    %ecx,%eax
  800da9:	7d 08                	jge    800db3 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800dab:	42                   	inc    %edx
  800dac:	0f af d9             	imul   %ecx,%ebx
  800daf:	01 c3                	add    %eax,%ebx
  800db1:	eb c3                	jmp    800d76 <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800db3:	85 f6                	test   %esi,%esi
  800db5:	74 02                	je     800db9 <strtol+0xbc>
		*endptr = (char *) s;
  800db7:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800db9:	89 d8                	mov    %ebx,%eax
  800dbb:	85 ff                	test   %edi,%edi
  800dbd:	74 02                	je     800dc1 <strtol+0xc4>
  800dbf:	f7 d8                	neg    %eax
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    
	...

00800dc8 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == NULL) {
  800dce:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800dd5:	75 2a                	jne    800e01 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
        //cprintf("i'm in set pgfault_handler,before alloc\n");
        if(sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W)) {//maybe not PTE_USER
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	6a 07                	push   $0x7
  800ddc:	68 00 f0 bf ee       	push   $0xeebff000
  800de1:	6a 00                	push   $0x0
  800de3:	e8 fb f3 ff ff       	call   8001e3 <sys_page_alloc>
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	75 1a                	jne    800e09 <set_pgfault_handler+0x41>
            return;
        }
        //cprintf("i'm in set pgfault_handler,after alloc\n");
        sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  800def:	83 ec 08             	sub    $0x8,%esp
  800df2:	68 54 04 80 00       	push   $0x800454
  800df7:	6a 00                	push   $0x0
  800df9:	e8 80 f5 ff ff       	call   80037e <sys_env_set_pgfault_upcall>
  800dfe:	83 c4 10             	add    $0x10,%esp
        //cprintf("here in set pgfault handler\n");
		//panic("set_pgfault_handler not implemented");
	}
	// Save handler pointer for assembly to call.
    //cprintf("handler %x;pgfault_handler address %x,upcall address %x,upcall points %x\n",handler,&_pgfault_handler,&_pgfault_upcall,_pgfault_upcall);
	_pgfault_handler = handler;
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	a3 0c 20 80 00       	mov    %eax,0x80200c
    //cprintf("here\n");
    //it should be ok
}
  800e09:	c9                   	leave  
  800e0a:	c3                   	ret    
	...

00800e0c <__udivdi3>:
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	83 ec 20             	sub    $0x20,%esp
  800e14:	8b 55 14             	mov    0x14(%ebp),%edx
  800e17:	8b 75 08             	mov    0x8(%ebp),%esi
  800e1a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e20:	85 d2                	test   %edx,%edx
  800e22:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800e25:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800e2c:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800e33:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e36:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e39:	89 fe                	mov    %edi,%esi
  800e3b:	75 5b                	jne    800e98 <__udivdi3+0x8c>
  800e3d:	39 f8                	cmp    %edi,%eax
  800e3f:	76 2b                	jbe    800e6c <__udivdi3+0x60>
  800e41:	89 fa                	mov    %edi,%edx
  800e43:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e46:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e49:	89 c7                	mov    %eax,%edi
  800e4b:	90                   	nop    
  800e4c:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800e53:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800e56:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800e59:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e5c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e5f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e62:	83 c4 20             	add    $0x20,%esp
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    
  800e69:	8d 76 00             	lea    0x0(%esi),%esi
  800e6c:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	75 0e                	jne    800e81 <__udivdi3+0x75>
  800e73:	b8 01 00 00 00       	mov    $0x1,%eax
  800e78:	31 c9                	xor    %ecx,%ecx
  800e7a:	31 d2                	xor    %edx,%edx
  800e7c:	f7 f1                	div    %ecx
  800e7e:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e81:	89 f0                	mov    %esi,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e88:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e8b:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e8e:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e91:	89 c7                	mov    %eax,%edi
  800e93:	eb be                	jmp    800e53 <__udivdi3+0x47>
  800e95:	8d 76 00             	lea    0x0(%esi),%esi
  800e98:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800e9b:	76 07                	jbe    800ea4 <__udivdi3+0x98>
  800e9d:	31 ff                	xor    %edi,%edi
  800e9f:	eb ab                	jmp    800e4c <__udivdi3+0x40>
  800ea1:	8d 76 00             	lea    0x0(%esi),%esi
  800ea4:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800ea8:	89 c7                	mov    %eax,%edi
  800eaa:	83 f7 1f             	xor    $0x1f,%edi
  800ead:	75 19                	jne    800ec8 <__udivdi3+0xbc>
  800eaf:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800eb2:	77 0a                	ja     800ebe <__udivdi3+0xb2>
  800eb4:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800eb7:	31 ff                	xor    %edi,%edi
  800eb9:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800ebc:	72 8e                	jb     800e4c <__udivdi3+0x40>
  800ebe:	bf 01 00 00 00       	mov    $0x1,%edi
  800ec3:	eb 87                	jmp    800e4c <__udivdi3+0x40>
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	b8 20 00 00 00       	mov    $0x20,%eax
  800ecd:	29 f8                	sub    %edi,%eax
  800ecf:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800ed2:	89 f9                	mov    %edi,%ecx
  800ed4:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800ed7:	d3 e2                	shl    %cl,%edx
  800ed9:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800edc:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800edf:	d3 e8                	shr    %cl,%eax
  800ee1:	09 c2                	or     %eax,%edx
  800ee3:	89 f9                	mov    %edi,%ecx
  800ee5:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800ee8:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800eeb:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800eee:	89 f2                	mov    %esi,%edx
  800ef0:	d3 ea                	shr    %cl,%edx
  800ef2:	89 f9                	mov    %edi,%ecx
  800ef4:	d3 e6                	shl    %cl,%esi
  800ef6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800ef9:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800efc:	d3 e8                	shr    %cl,%eax
  800efe:	09 c6                	or     %eax,%esi
  800f00:	89 f9                	mov    %edi,%ecx
  800f02:	89 f0                	mov    %esi,%eax
  800f04:	f7 75 ec             	divl   0xffffffec(%ebp)
  800f07:	89 d6                	mov    %edx,%esi
  800f09:	89 c7                	mov    %eax,%edi
  800f0b:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800f0e:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800f11:	f7 e7                	mul    %edi
  800f13:	39 f2                	cmp    %esi,%edx
  800f15:	77 0f                	ja     800f26 <__udivdi3+0x11a>
  800f17:	0f 85 2f ff ff ff    	jne    800e4c <__udivdi3+0x40>
  800f1d:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800f20:	0f 86 26 ff ff ff    	jbe    800e4c <__udivdi3+0x40>
  800f26:	4f                   	dec    %edi
  800f27:	e9 20 ff ff ff       	jmp    800e4c <__udivdi3+0x40>

00800f2c <__umoddi3>:
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	83 ec 30             	sub    $0x30,%esp
  800f34:	8b 55 14             	mov    0x14(%ebp),%edx
  800f37:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f40:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800f43:	85 d2                	test   %edx,%edx
  800f45:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800f4c:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f53:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800f56:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f59:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800f5c:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800f5f:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800f62:	75 68                	jne    800fcc <__umoddi3+0xa0>
  800f64:	39 f8                	cmp    %edi,%eax
  800f66:	76 3c                	jbe    800fa4 <__umoddi3+0x78>
  800f68:	89 f0                	mov    %esi,%eax
  800f6a:	89 fa                	mov    %edi,%edx
  800f6c:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f6f:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800f72:	85 c9                	test   %ecx,%ecx
  800f74:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800f77:	74 1b                	je     800f94 <__umoddi3+0x68>
  800f79:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f7c:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800f7f:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f86:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f89:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800f8c:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800f8f:	89 10                	mov    %edx,(%eax)
  800f91:	89 48 04             	mov    %ecx,0x4(%eax)
  800f94:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f97:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f9a:	83 c4 30             	add    $0x30,%esp
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    
  800fa1:	8d 76 00             	lea    0x0(%esi),%esi
  800fa4:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  800fa7:	85 f6                	test   %esi,%esi
  800fa9:	75 0d                	jne    800fb8 <__umoddi3+0x8c>
  800fab:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb0:	31 d2                	xor    %edx,%edx
  800fb2:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800fb5:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800fb8:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800fbb:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800fbe:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800fc1:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fc4:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800fc7:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800fca:	eb a3                	jmp    800f6f <__umoddi3+0x43>
  800fcc:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fcf:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800fd2:	76 14                	jbe    800fe8 <__umoddi3+0xbc>
  800fd4:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800fd7:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800fda:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800fdd:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800fe0:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800fe3:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800fe6:	eb ac                	jmp    800f94 <__umoddi3+0x68>
  800fe8:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800fec:	89 c6                	mov    %eax,%esi
  800fee:	83 f6 1f             	xor    $0x1f,%esi
  800ff1:	75 4d                	jne    801040 <__umoddi3+0x114>
  800ff3:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800ff6:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800ff9:	77 08                	ja     801003 <__umoddi3+0xd7>
  800ffb:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  800ffe:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  801001:	72 12                	jb     801015 <__umoddi3+0xe9>
  801003:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801006:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801009:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  80100c:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80100f:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801012:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801015:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  801018:	85 d2                	test   %edx,%edx
  80101a:	0f 84 74 ff ff ff    	je     800f94 <__umoddi3+0x68>
  801020:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801023:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801026:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  801029:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  80102c:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  80102f:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  801032:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  801035:	89 01                	mov    %eax,(%ecx)
  801037:	89 51 04             	mov    %edx,0x4(%ecx)
  80103a:	e9 55 ff ff ff       	jmp    800f94 <__umoddi3+0x68>
  80103f:	90                   	nop    
  801040:	b8 20 00 00 00       	mov    $0x20,%eax
  801045:	29 f0                	sub    %esi,%eax
  801047:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  80104a:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80104d:	89 f1                	mov    %esi,%ecx
  80104f:	d3 e2                	shl    %cl,%edx
  801051:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  801054:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801057:	d3 e8                	shr    %cl,%eax
  801059:	09 c2                	or     %eax,%edx
  80105b:	89 f1                	mov    %esi,%ecx
  80105d:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  801060:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801063:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801066:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  801069:	d3 ea                	shr    %cl,%edx
  80106b:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  80106e:	89 f1                	mov    %esi,%ecx
  801070:	d3 e7                	shl    %cl,%edi
  801072:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801075:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801078:	d3 e8                	shr    %cl,%eax
  80107a:	09 c7                	or     %eax,%edi
  80107c:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  80107f:	89 f8                	mov    %edi,%eax
  801081:	89 f1                	mov    %esi,%ecx
  801083:	f7 75 dc             	divl   0xffffffdc(%ebp)
  801086:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801089:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  80108c:	f7 65 cc             	mull   0xffffffcc(%ebp)
  80108f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801092:	89 c7                	mov    %eax,%edi
  801094:	77 3f                	ja     8010d5 <__umoddi3+0x1a9>
  801096:	74 38                	je     8010d0 <__umoddi3+0x1a4>
  801098:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80109b:	85 c0                	test   %eax,%eax
  80109d:	0f 84 f1 fe ff ff    	je     800f94 <__umoddi3+0x68>
  8010a3:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  8010a6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8010a9:	29 f8                	sub    %edi,%eax
  8010ab:	19 d1                	sbb    %edx,%ecx
  8010ad:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  8010b0:	89 ca                	mov    %ecx,%edx
  8010b2:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8010b5:	d3 e2                	shl    %cl,%edx
  8010b7:	89 f1                	mov    %esi,%ecx
  8010b9:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8010bc:	d3 e8                	shr    %cl,%eax
  8010be:	09 c2                	or     %eax,%edx
  8010c0:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8010c3:	d3 e8                	shr    %cl,%eax
  8010c5:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8010c8:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8010cb:	e9 b6 fe ff ff       	jmp    800f86 <__umoddi3+0x5a>
  8010d0:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  8010d3:	76 c3                	jbe    801098 <__umoddi3+0x16c>
  8010d5:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  8010d8:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  8010db:	eb bb                	jmp    801098 <__umoddi3+0x16c>
  8010dd:	90                   	nop    
  8010de:	90                   	nop    
  8010df:	90                   	nop    
