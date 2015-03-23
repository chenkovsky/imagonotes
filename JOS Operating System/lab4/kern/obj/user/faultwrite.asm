
obj/user/faultwrite：     文件格式 elf32-i386

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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	c9                   	leave  
  800042:	c3                   	ret    
	...

00800044 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	8b 75 08             	mov    0x8(%ebp),%esi
  80004c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    //extern struct Env *curenv;
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = ENVX(curenv->env_id)
    env = &envs[ENVX(sys_getenvid())];
  80004f:	e8 f2 00 00 00       	call   800146 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	c1 e0 07             	shl    $0x7,%eax
  80005c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800061:	a3 04 20 80 00       	mov    %eax,0x802004
    //cprintf("in libmain envid = %d\n",sys_getenvid());
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 f6                	test   %esi,%esi
  800068:	7e 07                	jle    800071 <libmain+0x2d>
		binaryname = argv[0];
  80006a:	8b 03                	mov    (%ebx),%eax
  80006c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800071:	83 ec 08             	sub    $0x8,%esp
  800074:	53                   	push   %ebx
  800075:	56                   	push   %esi
  800076:	e8 b9 ff ff ff       	call   800034 <umain>
    //cprintf("the env will exit!!\n");
	// exit gracefully
	exit();
  80007b:	e8 08 00 00 00       	call   800088 <exit>
}
  800080:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	c9                   	leave  
  800086:	c3                   	ret    
	...

00800088 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
    //cprintf("in the exit,sys_env_destroy will be called\n");
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 60 00 00 00       	call   8000f5 <sys_env_destroy>
}
  800095:	c9                   	leave  
  800096:	c3                   	ret    
	...

00800098 <sys_cputs>:
}

void
sys_cputs(const char *s, size_t len)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	57                   	push   %edi
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
  80009e:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a9:	89 f8                	mov    %edi,%eax
  8000ab:	89 fb                	mov    %edi,%ebx
  8000ad:	89 fe                	mov    %edi,%esi
  8000af:	55                   	push   %ebp
  8000b0:	9c                   	pushf  
  8000b1:	56                   	push   %esi
  8000b2:	54                   	push   %esp
  8000b3:	5d                   	pop    %ebp
  8000b4:	8d 35 bc 00 80 00    	lea    0x8000bc,%esi
  8000ba:	0f 34                	sysenter 
  8000bc:	83 c4 04             	add    $0x4,%esp
  8000bf:	9d                   	popf   
  8000c0:	5d                   	pop    %ebp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8000d6:	89 fa                	mov    %edi,%edx
  8000d8:	89 f9                	mov    %edi,%ecx
  8000da:	89 fb                	mov    %edi,%ebx
  8000dc:	89 fe                	mov    %edi,%esi
  8000de:	55                   	push   %ebp
  8000df:	9c                   	pushf  
  8000e0:	56                   	push   %esi
  8000e1:	54                   	push   %esp
  8000e2:	5d                   	pop    %ebp
  8000e3:	8d 35 eb 00 80 00    	lea    0x8000eb,%esi
  8000e9:	0f 34                	sysenter 
  8000eb:	83 c4 04             	add    $0x4,%esp
  8000ee:	9d                   	popf   
  8000ef:	5d                   	pop    %ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	bf 00 00 00 00       	mov    $0x0,%edi
  80010b:	89 f9                	mov    %edi,%ecx
  80010d:	89 fb                	mov    %edi,%ebx
  80010f:	89 fe                	mov    %edi,%esi
  800111:	55                   	push   %ebp
  800112:	9c                   	pushf  
  800113:	56                   	push   %esi
  800114:	54                   	push   %esp
  800115:	5d                   	pop    %ebp
  800116:	8d 35 1e 01 80 00    	lea    0x80011e,%esi
  80011c:	0f 34                	sysenter 
  80011e:	83 c4 04             	add    $0x4,%esp
  800121:	9d                   	popf   
  800122:	5d                   	pop    %ebp
  800123:	85 c0                	test   %eax,%eax
  800125:	7e 17                	jle    80013e <sys_env_destroy+0x49>
  800127:	83 ec 0c             	sub    $0xc,%esp
  80012a:	50                   	push   %eax
  80012b:	6a 03                	push   $0x3
  80012d:	68 97 10 80 00       	push   $0x801097
  800132:	6a 4c                	push   $0x4c
  800134:	68 b4 10 80 00       	push   $0x8010b4
  800139:	e8 06 03 00 00       	call   800444 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	b8 02 00 00 00       	mov    $0x2,%eax
  800151:	bf 00 00 00 00       	mov    $0x0,%edi
  800156:	89 fa                	mov    %edi,%edx
  800158:	89 f9                	mov    %edi,%ecx
  80015a:	89 fb                	mov    %edi,%ebx
  80015c:	89 fe                	mov    %edi,%esi
  80015e:	55                   	push   %ebp
  80015f:	9c                   	pushf  
  800160:	56                   	push   %esi
  800161:	54                   	push   %esp
  800162:	5d                   	pop    %ebp
  800163:	8d 35 6b 01 80 00    	lea    0x80016b,%esi
  800169:	0f 34                	sysenter 
  80016b:	83 c4 04             	add    $0x4,%esp
  80016e:	9d                   	popf   
  80016f:	5d                   	pop    %ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <sys_dump_env>:

int
sys_dump_env(void)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	b8 04 00 00 00       	mov    $0x4,%eax
  800180:	bf 00 00 00 00       	mov    $0x0,%edi
  800185:	89 fa                	mov    %edi,%edx
  800187:	89 f9                	mov    %edi,%ecx
  800189:	89 fb                	mov    %edi,%ebx
  80018b:	89 fe                	mov    %edi,%esi
  80018d:	55                   	push   %ebp
  80018e:	9c                   	pushf  
  80018f:	56                   	push   %esi
  800190:	54                   	push   %esp
  800191:	5d                   	pop    %ebp
  800192:	8d 35 9a 01 80 00    	lea    0x80019a,%esi
  800198:	0f 34                	sysenter 
  80019a:	83 c4 04             	add    $0x4,%esp
  80019d:	9d                   	popf   
  80019e:	5d                   	pop    %ebp
    return syscall(SYS_dump_env, 0, 0, 0, 0, 0, 0);
}
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5f                   	pop    %edi
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <sys_yield>:

void
sys_yield(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001af:	bf 00 00 00 00       	mov    $0x0,%edi
  8001b4:	89 fa                	mov    %edi,%edx
  8001b6:	89 f9                	mov    %edi,%ecx
  8001b8:	89 fb                	mov    %edi,%ebx
  8001ba:	89 fe                	mov    %edi,%esi
  8001bc:	55                   	push   %ebp
  8001bd:	9c                   	pushf  
  8001be:	56                   	push   %esi
  8001bf:	54                   	push   %esp
  8001c0:	5d                   	pop    %ebp
  8001c1:	8d 35 c9 01 80 00    	lea    0x8001c9,%esi
  8001c7:	0f 34                	sysenter 
  8001c9:	83 c4 04             	add    $0x4,%esp
  8001cc:	9d                   	popf   
  8001cd:	5d                   	pop    %ebp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ef:	89 fe                	mov    %edi,%esi
  8001f1:	55                   	push   %ebp
  8001f2:	9c                   	pushf  
  8001f3:	56                   	push   %esi
  8001f4:	54                   	push   %esp
  8001f5:	5d                   	pop    %ebp
  8001f6:	8d 35 fe 01 80 00    	lea    0x8001fe,%esi
  8001fc:	0f 34                	sysenter 
  8001fe:	83 c4 04             	add    $0x4,%esp
  800201:	9d                   	popf   
  800202:	5d                   	pop    %ebp
  800203:	85 c0                	test   %eax,%eax
  800205:	7e 17                	jle    80021e <sys_page_alloc+0x4b>
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	50                   	push   %eax
  80020b:	6a 05                	push   $0x5
  80020d:	68 97 10 80 00       	push   $0x801097
  800212:	6a 4c                	push   $0x4c
  800214:	68 b4 10 80 00       	push   $0x8010b4
  800219:	e8 26 02 00 00       	call   800444 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80021e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800221:	5b                   	pop    %ebx
  800222:	5e                   	pop    %esi
  800223:	5f                   	pop    %edi
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	57                   	push   %edi
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800238:	8b 7d 14             	mov    0x14(%ebp),%edi
  80023b:	8b 75 18             	mov    0x18(%ebp),%esi
  80023e:	b8 06 00 00 00       	mov    $0x6,%eax
  800243:	55                   	push   %ebp
  800244:	9c                   	pushf  
  800245:	56                   	push   %esi
  800246:	54                   	push   %esp
  800247:	5d                   	pop    %ebp
  800248:	8d 35 50 02 80 00    	lea    0x800250,%esi
  80024e:	0f 34                	sysenter 
  800250:	83 c4 04             	add    $0x4,%esp
  800253:	9d                   	popf   
  800254:	5d                   	pop    %ebp
  800255:	85 c0                	test   %eax,%eax
  800257:	7e 17                	jle    800270 <sys_page_map+0x4a>
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	50                   	push   %eax
  80025d:	6a 06                	push   $0x6
  80025f:	68 97 10 80 00       	push   $0x801097
  800264:	6a 4c                	push   $0x4c
  800266:	68 b4 10 80 00       	push   $0x8010b4
  80026b:	e8 d4 01 00 00       	call   800444 <_panic>
    //asm volatile("xchg %%bx,%%bx":);
	int i = syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
    //asm volatile("xchg %%bx,%%bx":);
    return i;
}
  800270:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	b8 07 00 00 00       	mov    $0x7,%eax
  80028c:	bf 00 00 00 00       	mov    $0x0,%edi
  800291:	89 fb                	mov    %edi,%ebx
  800293:	89 fe                	mov    %edi,%esi
  800295:	55                   	push   %ebp
  800296:	9c                   	pushf  
  800297:	56                   	push   %esi
  800298:	54                   	push   %esp
  800299:	5d                   	pop    %ebp
  80029a:	8d 35 a2 02 80 00    	lea    0x8002a2,%esi
  8002a0:	0f 34                	sysenter 
  8002a2:	83 c4 04             	add    $0x4,%esp
  8002a5:	9d                   	popf   
  8002a6:	5d                   	pop    %ebp
  8002a7:	85 c0                	test   %eax,%eax
  8002a9:	7e 17                	jle    8002c2 <sys_page_unmap+0x4a>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	50                   	push   %eax
  8002af:	6a 07                	push   $0x7
  8002b1:	68 97 10 80 00       	push   $0x801097
  8002b6:	6a 4c                	push   $0x4c
  8002b8:	68 b4 10 80 00       	push   $0x8010b4
  8002bd:	e8 82 01 00 00       	call   800444 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002c2:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002de:	bf 00 00 00 00       	mov    $0x0,%edi
  8002e3:	89 fb                	mov    %edi,%ebx
  8002e5:	89 fe                	mov    %edi,%esi
  8002e7:	55                   	push   %ebp
  8002e8:	9c                   	pushf  
  8002e9:	56                   	push   %esi
  8002ea:	54                   	push   %esp
  8002eb:	5d                   	pop    %ebp
  8002ec:	8d 35 f4 02 80 00    	lea    0x8002f4,%esi
  8002f2:	0f 34                	sysenter 
  8002f4:	83 c4 04             	add    $0x4,%esp
  8002f7:	9d                   	popf   
  8002f8:	5d                   	pop    %ebp
  8002f9:	85 c0                	test   %eax,%eax
  8002fb:	7e 17                	jle    800314 <sys_env_set_status+0x4a>
  8002fd:	83 ec 0c             	sub    $0xc,%esp
  800300:	50                   	push   %eax
  800301:	6a 09                	push   $0x9
  800303:	68 97 10 80 00       	push   $0x801097
  800308:	6a 4c                	push   $0x4c
  80030a:	68 b4 10 80 00       	push   $0x8010b4
  80030f:	e8 30 01 00 00       	call   800444 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800314:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800317:	5b                   	pop    %ebx
  800318:	5e                   	pop    %esi
  800319:	5f                   	pop    %edi
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
  800322:	83 ec 0c             	sub    $0xc,%esp
  800325:	8b 55 08             	mov    0x8(%ebp),%edx
  800328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800330:	bf 00 00 00 00       	mov    $0x0,%edi
  800335:	89 fb                	mov    %edi,%ebx
  800337:	89 fe                	mov    %edi,%esi
  800339:	55                   	push   %ebp
  80033a:	9c                   	pushf  
  80033b:	56                   	push   %esi
  80033c:	54                   	push   %esp
  80033d:	5d                   	pop    %ebp
  80033e:	8d 35 46 03 80 00    	lea    0x800346,%esi
  800344:	0f 34                	sysenter 
  800346:	83 c4 04             	add    $0x4,%esp
  800349:	9d                   	popf   
  80034a:	5d                   	pop    %ebp
  80034b:	85 c0                	test   %eax,%eax
  80034d:	7e 17                	jle    800366 <sys_env_set_trapframe+0x4a>
  80034f:	83 ec 0c             	sub    $0xc,%esp
  800352:	50                   	push   %eax
  800353:	6a 0a                	push   $0xa
  800355:	68 97 10 80 00       	push   $0x801097
  80035a:	6a 4c                	push   $0x4c
  80035c:	68 b4 10 80 00       	push   $0x8010b4
  800361:	e8 de 00 00 00       	call   800444 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800366:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
  800374:	83 ec 0c             	sub    $0xc,%esp
  800377:	8b 55 08             	mov    0x8(%ebp),%edx
  80037a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800382:	bf 00 00 00 00       	mov    $0x0,%edi
  800387:	89 fb                	mov    %edi,%ebx
  800389:	89 fe                	mov    %edi,%esi
  80038b:	55                   	push   %ebp
  80038c:	9c                   	pushf  
  80038d:	56                   	push   %esi
  80038e:	54                   	push   %esp
  80038f:	5d                   	pop    %ebp
  800390:	8d 35 98 03 80 00    	lea    0x800398,%esi
  800396:	0f 34                	sysenter 
  800398:	83 c4 04             	add    $0x4,%esp
  80039b:	9d                   	popf   
  80039c:	5d                   	pop    %ebp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	7e 17                	jle    8003b8 <sys_env_set_pgfault_upcall+0x4a>
  8003a1:	83 ec 0c             	sub    $0xc,%esp
  8003a4:	50                   	push   %eax
  8003a5:	6a 0b                	push   $0xb
  8003a7:	68 97 10 80 00       	push   $0x801097
  8003ac:	6a 4c                	push   $0x4c
  8003ae:	68 b4 10 80 00       	push   $0x8010b4
  8003b3:	e8 8c 00 00 00       	call   800444 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003b8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8003bb:	5b                   	pop    %ebx
  8003bc:	5e                   	pop    %esi
  8003bd:	5f                   	pop    %edi
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	57                   	push   %edi
  8003c4:	56                   	push   %esi
  8003c5:	53                   	push   %ebx
  8003c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003cf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003d2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003d7:	be 00 00 00 00       	mov    $0x0,%esi
  8003dc:	55                   	push   %ebp
  8003dd:	9c                   	pushf  
  8003de:	56                   	push   %esi
  8003df:	54                   	push   %esp
  8003e0:	5d                   	pop    %ebp
  8003e1:	8d 35 e9 03 80 00    	lea    0x8003e9,%esi
  8003e7:	0f 34                	sysenter 
  8003e9:	83 c4 04             	add    $0x4,%esp
  8003ec:	9d                   	popf   
  8003ed:	5d                   	pop    %ebp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ee:	5b                   	pop    %ebx
  8003ef:	5e                   	pop    %esi
  8003f0:	5f                   	pop    %edi
  8003f1:	c9                   	leave  
  8003f2:	c3                   	ret    

008003f3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	57                   	push   %edi
  8003f7:	56                   	push   %esi
  8003f8:	53                   	push   %ebx
  8003f9:	83 ec 0c             	sub    $0xc,%esp
  8003fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ff:	b8 0e 00 00 00       	mov    $0xe,%eax
  800404:	bf 00 00 00 00       	mov    $0x0,%edi
  800409:	89 f9                	mov    %edi,%ecx
  80040b:	89 fb                	mov    %edi,%ebx
  80040d:	89 fe                	mov    %edi,%esi
  80040f:	55                   	push   %ebp
  800410:	9c                   	pushf  
  800411:	56                   	push   %esi
  800412:	54                   	push   %esp
  800413:	5d                   	pop    %ebp
  800414:	8d 35 1c 04 80 00    	lea    0x80041c,%esi
  80041a:	0f 34                	sysenter 
  80041c:	83 c4 04             	add    $0x4,%esp
  80041f:	9d                   	popf   
  800420:	5d                   	pop    %ebp
  800421:	85 c0                	test   %eax,%eax
  800423:	7e 17                	jle    80043c <sys_ipc_recv+0x49>
  800425:	83 ec 0c             	sub    $0xc,%esp
  800428:	50                   	push   %eax
  800429:	6a 0e                	push   $0xe
  80042b:	68 97 10 80 00       	push   $0x801097
  800430:	6a 4c                	push   $0x4c
  800432:	68 b4 10 80 00       	push   $0x8010b4
  800437:	e8 08 00 00 00       	call   800444 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80043c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80043f:	5b                   	pop    %ebx
  800440:	5e                   	pop    %esi
  800441:	5f                   	pop    %edi
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <_panic>:
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	53                   	push   %ebx
  800448:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  80044b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80044e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800455:	74 16                	je     80046d <_panic+0x29>
		cprintf("%s: ", argv0);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 35 08 20 80 00    	pushl  0x802008
  800460:	68 c2 10 80 00       	push   $0x8010c2
  800465:	e8 ca 00 00 00       	call   800534 <cprintf>
  80046a:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80046d:	ff 75 0c             	pushl  0xc(%ebp)
  800470:	ff 75 08             	pushl  0x8(%ebp)
  800473:	ff 35 00 20 80 00    	pushl  0x802000
  800479:	68 c7 10 80 00       	push   $0x8010c7
  80047e:	e8 b1 00 00 00       	call   800534 <cprintf>
	vcprintf(fmt, ap);
  800483:	83 c4 08             	add    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 75 10             	pushl  0x10(%ebp)
  80048a:	e8 54 00 00 00       	call   8004e3 <vcprintf>
	cprintf("\n");
  80048f:	c7 04 24 e3 10 80 00 	movl   $0x8010e3,(%esp)
  800496:	e8 99 00 00 00       	call   800534 <cprintf>

	// Cause a breakpoint exception
	while (1)
  80049b:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80049e:	cc                   	int3   
  80049f:	eb fd                	jmp    80049e <_panic+0x5a>
}
  8004a1:	00 00                	add    %al,(%eax)
	...

008004a4 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	53                   	push   %ebx
  8004a8:	83 ec 04             	sub    $0x4,%esp
  8004ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ae:	8b 03                	mov    (%ebx),%eax
  8004b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004b7:	40                   	inc    %eax
  8004b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004bf:	75 1a                	jne    8004db <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	68 ff 00 00 00       	push   $0xff
  8004c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8004cc:	50                   	push   %eax
  8004cd:	e8 c6 fb ff ff       	call   800098 <sys_cputs>
		b->idx = 0;
  8004d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004d8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004db:	ff 43 04             	incl   0x4(%ebx)
}
  8004de:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    

008004e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004ec:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8004f3:	00 00 00 
	b.cnt = 0;
  8004f6:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8004fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	ff 75 08             	pushl  0x8(%ebp)
  800506:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  80050c:	50                   	push   %eax
  80050d:	68 a4 04 80 00       	push   $0x8004a4
  800512:	e8 83 01 00 00       	call   80069a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800517:	83 c4 08             	add    $0x8,%esp
  80051a:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800520:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800526:	50                   	push   %eax
  800527:	e8 6c fb ff ff       	call   800098 <sys_cputs>

	return b.cnt;
  80052c:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80053d:	50                   	push   %eax
  80053e:	ff 75 08             	pushl  0x8(%ebp)
  800541:	e8 9d ff ff ff       	call   8004e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800546:	c9                   	leave  
  800547:	c3                   	ret    

00800548 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	57                   	push   %edi
  80054c:	56                   	push   %esi
  80054d:	53                   	push   %ebx
  80054e:	83 ec 0c             	sub    $0xc,%esp
  800551:	8b 75 10             	mov    0x10(%ebp),%esi
  800554:	8b 7d 14             	mov    0x14(%ebp),%edi
  800557:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80055a:	8b 45 18             	mov    0x18(%ebp),%eax
  80055d:	ba 00 00 00 00       	mov    $0x0,%edx
  800562:	39 d7                	cmp    %edx,%edi
  800564:	72 39                	jb     80059f <printnum+0x57>
  800566:	77 04                	ja     80056c <printnum+0x24>
  800568:	39 c6                	cmp    %eax,%esi
  80056a:	72 33                	jb     80059f <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80056c:	83 ec 04             	sub    $0x4,%esp
  80056f:	ff 75 20             	pushl  0x20(%ebp)
  800572:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800575:	50                   	push   %eax
  800576:	ff 75 18             	pushl  0x18(%ebp)
  800579:	8b 45 18             	mov    0x18(%ebp),%eax
  80057c:	ba 00 00 00 00       	mov    $0x0,%edx
  800581:	52                   	push   %edx
  800582:	50                   	push   %eax
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	e8 06 08 00 00       	call   800d90 <__udivdi3>
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	52                   	push   %edx
  80058e:	50                   	push   %eax
  80058f:	ff 75 0c             	pushl  0xc(%ebp)
  800592:	ff 75 08             	pushl  0x8(%ebp)
  800595:	e8 ae ff ff ff       	call   800548 <printnum>
  80059a:	83 c4 20             	add    $0x20,%esp
  80059d:	eb 19                	jmp    8005b8 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80059f:	4b                   	dec    %ebx
  8005a0:	85 db                	test   %ebx,%ebx
  8005a2:	7e 14                	jle    8005b8 <printnum+0x70>
			putch(padc, putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	ff 75 0c             	pushl  0xc(%ebp)
  8005aa:	ff 75 20             	pushl  0x20(%ebp)
  8005ad:	ff 55 08             	call   *0x8(%ebp)
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	4b                   	dec    %ebx
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f ec                	jg     8005a4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	ff 75 0c             	pushl  0xc(%ebp)
  8005be:	8b 45 18             	mov    0x18(%ebp),%eax
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c6:	83 ec 04             	sub    $0x4,%esp
  8005c9:	52                   	push   %edx
  8005ca:	50                   	push   %eax
  8005cb:	57                   	push   %edi
  8005cc:	56                   	push   %esi
  8005cd:	e8 de 08 00 00       	call   800eb0 <__umoddi3>
  8005d2:	83 c4 14             	add    $0x14,%esp
  8005d5:	0f be 80 78 11 80 00 	movsbl 0x801178(%eax),%eax
  8005dc:	50                   	push   %eax
  8005dd:	ff 55 08             	call   *0x8(%ebp)
}
  8005e0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8005e3:	5b                   	pop    %ebx
  8005e4:	5e                   	pop    %esi
  8005e5:	5f                   	pop    %edi
  8005e6:	c9                   	leave  
  8005e7:	c3                   	ret    

008005e8 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 18             	sub    $0x18,%esp
  8005f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f6:	8a 45 18             	mov    0x18(%ebp),%al
  8005f9:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
  8005fc:	53                   	push   %ebx
  8005fd:	6a 1b                	push   $0x1b
  8005ff:	ff d6                	call   *%esi
	putch('[', putdat);
  800601:	83 c4 08             	add    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 5b                	push   $0x5b
  800607:	ff d6                	call   *%esi
	putch('0', putdat);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 30                	push   $0x30
  80060f:	ff d6                	call   *%esi
	putch(';', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 3b                	push   $0x3b
  800617:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
  800619:	83 c4 0c             	add    $0xc,%esp
  80061c:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
  800620:	50                   	push   %eax
  800621:	ff 75 14             	pushl  0x14(%ebp)
  800624:	6a 0a                	push   $0xa
  800626:	8b 45 10             	mov    0x10(%ebp),%eax
  800629:	99                   	cltd   
  80062a:	52                   	push   %edx
  80062b:	50                   	push   %eax
  80062c:	53                   	push   %ebx
  80062d:	56                   	push   %esi
  80062e:	e8 15 ff ff ff       	call   800548 <printnum>
	putch('m', putdat);
  800633:	83 c4 18             	add    $0x18,%esp
  800636:	53                   	push   %ebx
  800637:	6a 6d                	push   $0x6d
  800639:	ff d6                	call   *%esi

}
  80063b:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5e                   	pop    %esi
  800640:	c9                   	leave  
  800641:	c3                   	ret    

00800642 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800648:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80064b:	83 f8 01             	cmp    $0x1,%eax
  80064e:	7e 0f                	jle    80065f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800650:	8b 01                	mov    (%ecx),%eax
  800652:	83 c0 08             	add    $0x8,%eax
  800655:	89 01                	mov    %eax,(%ecx)
  800657:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80065a:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80065d:	eb 0f                	jmp    80066e <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065f:	8b 01                	mov    (%ecx),%eax
  800661:	83 c0 04             	add    $0x4,%eax
  800664:	89 01                	mov    %eax,(%ecx)
  800666:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80066e:	c9                   	leave  
  80066f:	c3                   	ret    

00800670 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	8b 55 08             	mov    0x8(%ebp),%edx
  800676:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800679:	83 f8 01             	cmp    $0x1,%eax
  80067c:	7e 0f                	jle    80068d <getint+0x1d>
		return va_arg(*ap, long long);
  80067e:	8b 02                	mov    (%edx),%eax
  800680:	83 c0 08             	add    $0x8,%eax
  800683:	89 02                	mov    %eax,(%edx)
  800685:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800688:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80068b:	eb 0b                	jmp    800698 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80068d:	8b 02                	mov    (%edx),%eax
  80068f:	83 c0 04             	add    $0x4,%eax
  800692:	89 02                	mov    %eax,(%edx)
  800694:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800697:	99                   	cltd   
}
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	57                   	push   %edi
  80069e:	56                   	push   %esi
  80069f:	53                   	push   %ebx
  8006a0:	83 ec 1c             	sub    $0x1c,%esp
  8006a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a6:	0f b6 13             	movzbl (%ebx),%edx
  8006a9:	43                   	inc    %ebx
  8006aa:	83 fa 25             	cmp    $0x25,%edx
  8006ad:	74 1e                	je     8006cd <vprintfmt+0x33>
			if (ch == '\0')
  8006af:	85 d2                	test   %edx,%edx
  8006b1:	0f 84 dc 02 00 00    	je     800993 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	ff 75 0c             	pushl  0xc(%ebp)
  8006bd:	52                   	push   %edx
  8006be:	ff 55 08             	call   *0x8(%ebp)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	0f b6 13             	movzbl (%ebx),%edx
  8006c7:	43                   	inc    %ebx
  8006c8:	83 fa 25             	cmp    $0x25,%edx
  8006cb:	75 e2                	jne    8006af <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8006cd:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8006d1:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8006d8:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8006dd:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8006e2:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
  8006e9:	0f b6 13             	movzbl (%ebx),%edx
  8006ec:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8006ef:	43                   	inc    %ebx
  8006f0:	83 f8 55             	cmp    $0x55,%eax
  8006f3:	0f 87 75 02 00 00    	ja     80096e <vprintfmt+0x2d4>
  8006f9:	ff 24 85 c4 11 80 00 	jmp    *0x8011c4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800700:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800704:	eb e3                	jmp    8006e9 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800706:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  80070a:	eb dd                	jmp    8006e9 <vprintfmt+0x4f>

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
  80070c:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800711:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800714:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800718:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80071b:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80071e:	83 f8 09             	cmp    $0x9,%eax
  800721:	77 27                	ja     80074a <vprintfmt+0xb0>
  800723:	43                   	inc    %ebx
  800724:	eb eb                	jmp    800711 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800726:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800730:	eb 18                	jmp    80074a <vprintfmt+0xb0>

		case '.':
			if (width < 0)
  800732:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800736:	79 b1                	jns    8006e9 <vprintfmt+0x4f>
				width = 0;
  800738:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80073f:	eb a8                	jmp    8006e9 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800741:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800748:	eb 9f                	jmp    8006e9 <vprintfmt+0x4f>

			process_precision: if (width < 0)
  80074a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80074e:	79 99                	jns    8006e9 <vprintfmt+0x4f>
				width = precision, precision = -1;
  800750:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800753:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800758:	eb 8f                	jmp    8006e9 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  80075a:	41                   	inc    %ecx
			goto reswitch;
  80075b:	eb 8c                	jmp    8006e9 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	ff 75 0c             	pushl  0xc(%ebp)
  800763:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80076d:	e9 c4 01 00 00       	jmp    800936 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
  800772:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80077c:	85 c0                	test   %eax,%eax
  80077e:	79 02                	jns    800782 <vprintfmt+0xe8>
				err = -err;
  800780:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800782:	83 f8 08             	cmp    $0x8,%eax
  800785:	7f 0b                	jg     800792 <vprintfmt+0xf8>
  800787:	8b 3c 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%edi
  80078e:	85 ff                	test   %edi,%edi
  800790:	75 08                	jne    80079a <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
  800792:	50                   	push   %eax
  800793:	68 89 11 80 00       	push   $0x801189
  800798:	eb 06                	jmp    8007a0 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
  80079a:	57                   	push   %edi
  80079b:	68 92 11 80 00       	push   $0x801192
  8007a0:	ff 75 0c             	pushl  0xc(%ebp)
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 f0 01 00 00       	call   80099b <printfmt>
  8007ab:	e9 89 01 00 00       	jmp    800939 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b0:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8007ba:	85 ff                	test   %edi,%edi
  8007bc:	75 05                	jne    8007c3 <vprintfmt+0x129>
				p = "(null)";
  8007be:	bf 95 11 80 00       	mov    $0x801195,%edi
			if (width > 0 && padc != '-')
  8007c3:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8007c7:	7e 3b                	jle    800804 <vprintfmt+0x16a>
  8007c9:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8007cd:	74 35                	je     800804 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	56                   	push   %esi
  8007d3:	57                   	push   %edi
  8007d4:	e8 74 02 00 00       	call   800a4d <strnlen>
  8007d9:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8007e3:	7e 1f                	jle    800804 <vprintfmt+0x16a>
  8007e5:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8007e9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8007f5:	ff 55 08             	call   *0x8(%ebp)
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8007fe:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800802:	7f e8                	jg     8007ec <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800804:	0f be 17             	movsbl (%edi),%edx
  800807:	47                   	inc    %edi
  800808:	85 d2                	test   %edx,%edx
  80080a:	74 3e                	je     80084a <vprintfmt+0x1b0>
  80080c:	85 f6                	test   %esi,%esi
  80080e:	78 03                	js     800813 <vprintfmt+0x179>
  800810:	4e                   	dec    %esi
  800811:	78 37                	js     80084a <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
  800813:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800817:	74 12                	je     80082b <vprintfmt+0x191>
  800819:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  80081c:	83 f8 5e             	cmp    $0x5e,%eax
  80081f:	76 0a                	jbe    80082b <vprintfmt+0x191>
					putch('?', putdat);
  800821:	83 ec 08             	sub    $0x8,%esp
  800824:	ff 75 0c             	pushl  0xc(%ebp)
  800827:	6a 3f                	push   $0x3f
  800829:	eb 07                	jmp    800832 <vprintfmt+0x198>
				else
					putch(ch, putdat);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	52                   	push   %edx
  800832:	ff 55 08             	call   *0x8(%ebp)
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80083b:	0f be 17             	movsbl (%edi),%edx
  80083e:	47                   	inc    %edi
  80083f:	85 d2                	test   %edx,%edx
  800841:	74 07                	je     80084a <vprintfmt+0x1b0>
  800843:	85 f6                	test   %esi,%esi
  800845:	78 cc                	js     800813 <vprintfmt+0x179>
  800847:	4e                   	dec    %esi
  800848:	79 c9                	jns    800813 <vprintfmt+0x179>
			for (; width > 0; width--)
  80084a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80084e:	0f 8e 52 fe ff ff    	jle    8006a6 <vprintfmt+0xc>
				putch(' ', putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	ff 75 0c             	pushl  0xc(%ebp)
  80085a:	6a 20                	push   $0x20
  80085c:	ff 55 08             	call   *0x8(%ebp)
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800865:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800869:	7f e9                	jg     800854 <vprintfmt+0x1ba>
			break;
  80086b:	e9 36 fe ff ff       	jmp    8006a6 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	51                   	push   %ecx
  800874:	8d 45 14             	lea    0x14(%ebp),%eax
  800877:	50                   	push   %eax
  800878:	e8 f3 fd ff ff       	call   800670 <getint>
  80087d:	89 c6                	mov    %eax,%esi
  80087f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800881:	83 c4 10             	add    $0x10,%esp
  800884:	85 d2                	test   %edx,%edx
  800886:	79 15                	jns    80089d <vprintfmt+0x203>
				putch('-', putdat);
  800888:	83 ec 08             	sub    $0x8,%esp
  80088b:	ff 75 0c             	pushl  0xc(%ebp)
  80088e:	6a 2d                	push   $0x2d
  800890:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800893:	f7 de                	neg    %esi
  800895:	83 d7 00             	adc    $0x0,%edi
  800898:	f7 df                	neg    %edi
  80089a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80089d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8008a2:	eb 70                	jmp    800914 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	51                   	push   %ecx
  8008a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ab:	50                   	push   %eax
  8008ac:	e8 91 fd ff ff       	call   800642 <getuint>
  8008b1:	89 c6                	mov    %eax,%esi
  8008b3:	89 d7                	mov    %edx,%edi
			base = 10;
  8008b5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8008ba:	eb 55                	jmp    800911 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008bc:	83 ec 08             	sub    $0x8,%esp
  8008bf:	51                   	push   %ecx
  8008c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c3:	50                   	push   %eax
  8008c4:	e8 79 fd ff ff       	call   800642 <getuint>
  8008c9:	89 c6                	mov    %eax,%esi
  8008cb:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
  8008cd:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8008d2:	eb 3d                	jmp    800911 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	6a 30                	push   $0x30
  8008dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008df:	83 c4 08             	add    $0x8,%esp
  8008e2:	ff 75 0c             	pushl  0xc(%ebp)
  8008e5:	6a 78                	push   $0x78
  8008e7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
  8008ea:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8008f4:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
  8008f9:	eb 11                	jmp    80090c <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	51                   	push   %ecx
  8008ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800902:	50                   	push   %eax
  800903:	e8 3a fd ff ff       	call   800642 <getuint>
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d7                	mov    %edx,%edi
			base = 16;
  80090c:	ba 10 00 00 00       	mov    $0x10,%edx
  800911:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
  800914:	83 ec 04             	sub    $0x4,%esp
  800917:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80091b:	50                   	push   %eax
  80091c:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80091f:	52                   	push   %edx
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	ff 75 08             	pushl  0x8(%ebp)
  800928:	e8 1b fc ff ff       	call   800548 <printnum>
			break;
  80092d:	eb 37                	jmp    800966 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80092f:	83 ec 08             	sub    $0x8,%esp
  800932:	ff 75 0c             	pushl  0xc(%ebp)
  800935:	52                   	push   %edx
  800936:	ff 55 08             	call   *0x8(%ebp)
			break;
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	e9 65 fd ff ff       	jmp    8006a6 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
  800941:	83 ec 08             	sub    $0x8,%esp
  800944:	51                   	push   %ecx
  800945:	8d 45 14             	lea    0x14(%ebp),%eax
  800948:	50                   	push   %eax
  800949:	e8 f4 fc ff ff       	call   800642 <getuint>
  80094e:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
  800950:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800954:	89 04 24             	mov    %eax,(%esp)
  800957:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80095a:	56                   	push   %esi
  80095b:	ff 75 0c             	pushl  0xc(%ebp)
  80095e:	ff 75 08             	pushl  0x8(%ebp)
  800961:	e8 82 fc ff ff       	call   8005e8 <printcolor>
			break;
  800966:	83 c4 20             	add    $0x20,%esp
  800969:	e9 38 fd ff ff       	jmp    8006a6 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096e:	83 ec 08             	sub    $0x8,%esp
  800971:	ff 75 0c             	pushl  0xc(%ebp)
  800974:	6a 25                	push   $0x25
  800976:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800979:	4b                   	dec    %ebx
  80097a:	83 c4 10             	add    $0x10,%esp
  80097d:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800981:	0f 84 1f fd ff ff    	je     8006a6 <vprintfmt+0xc>
  800987:	4b                   	dec    %ebx
  800988:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80098c:	75 f9                	jne    800987 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80098e:	e9 13 fd ff ff       	jmp    8006a6 <vprintfmt+0xc>
		}
	}
}
  800993:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	c9                   	leave  
  80099a:	c3                   	ret    

0080099b <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8009a1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009a4:	50                   	push   %eax
  8009a5:	ff 75 10             	pushl  0x10(%ebp)
  8009a8:	ff 75 0c             	pushl  0xc(%ebp)
  8009ab:	ff 75 08             	pushl  0x8(%ebp)
  8009ae:	e8 e7 fc ff ff       	call   80069a <vprintfmt>
	va_end(ap);
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8009bb:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8009be:	8b 0a                	mov    (%edx),%ecx
  8009c0:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8009c3:	73 07                	jae    8009cc <sprintputch+0x17>
		*b->buf++ = ch;
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	88 01                	mov    %al,(%ecx)
  8009ca:	ff 02                	incl   (%edx)
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 18             	sub    $0x18,%esp
  8009d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
  8009da:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8009dd:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8009e1:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8009e4:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8009eb:	85 d2                	test   %edx,%edx
  8009ed:	74 04                	je     8009f3 <vsnprintf+0x25>
  8009ef:	85 c9                	test   %ecx,%ecx
  8009f1:	7f 07                	jg     8009fa <vsnprintf+0x2c>
		return -E_INVAL;
  8009f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f8:	eb 1d                	jmp    800a17 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
  8009fa:	ff 75 14             	pushl  0x14(%ebp)
  8009fd:	ff 75 10             	pushl  0x10(%ebp)
  800a00:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800a03:	50                   	push   %eax
  800a04:	68 b5 09 80 00       	push   $0x8009b5
  800a09:	e8 8c fc ff ff       	call   80069a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a0e:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800a11:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a14:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a1f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a22:	50                   	push   %eax
  800a23:	ff 75 10             	pushl  0x10(%ebp)
  800a26:	ff 75 0c             	pushl  0xc(%ebp)
  800a29:	ff 75 08             	pushl  0x8(%ebp)
  800a2c:	e8 9d ff ff ff       	call   8009ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    
	...

00800a34 <strlen>:
#define ASM 1

int
strlen(const char *s)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	80 3a 00             	cmpb   $0x0,(%edx)
  800a42:	74 07                	je     800a4b <strlen+0x17>
		n++;
  800a44:	40                   	inc    %eax
  800a45:	42                   	inc    %edx
  800a46:	80 3a 00             	cmpb   $0x0,(%edx)
  800a49:	75 f9                	jne    800a44 <strlen+0x10>
	return n;
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a53:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	85 d2                	test   %edx,%edx
  800a5d:	74 0f                	je     800a6e <strnlen+0x21>
  800a5f:	80 39 00             	cmpb   $0x0,(%ecx)
  800a62:	74 0a                	je     800a6e <strnlen+0x21>
		n++;
  800a64:	40                   	inc    %eax
  800a65:	41                   	inc    %ecx
  800a66:	4a                   	dec    %edx
  800a67:	74 05                	je     800a6e <strnlen+0x21>
  800a69:	80 39 00             	cmpb   $0x0,(%ecx)
  800a6c:	75 f6                	jne    800a64 <strnlen+0x17>
	return n;
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a77:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800a7a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800a7c:	8a 02                	mov    (%edx),%al
  800a7e:	42                   	inc    %edx
  800a7f:	88 01                	mov    %al,(%ecx)
  800a81:	41                   	inc    %ecx
  800a82:	84 c0                	test   %al,%al
  800a84:	75 f6                	jne    800a7c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a86:	89 d8                	mov    %ebx,%eax
  800a88:	5b                   	pop    %ebx
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a97:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800a9a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aa1:	39 f3                	cmp    %esi,%ebx
  800aa3:	73 10                	jae    800ab5 <strncpy+0x2a>
		*dst++ = *src;
  800aa5:	8a 02                	mov    (%edx),%al
  800aa7:	88 01                	mov    %al,(%ecx)
  800aa9:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800aaa:	80 3a 00             	cmpb   $0x0,(%edx)
  800aad:	74 01                	je     800ab0 <strncpy+0x25>
			src++;
  800aaf:	42                   	inc    %edx
  800ab0:	43                   	inc    %ebx
  800ab1:	39 f3                	cmp    %esi,%ebx
  800ab3:	72 f0                	jb     800aa5 <strncpy+0x1a>
	}
	return ret;
}
  800ab5:	89 f8                	mov    %edi,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800aca:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800acc:	85 d2                	test   %edx,%edx
  800ace:	74 19                	je     800ae9 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800ad0:	4a                   	dec    %edx
  800ad1:	74 13                	je     800ae6 <strlcpy+0x2a>
  800ad3:	80 39 00             	cmpb   $0x0,(%ecx)
  800ad6:	74 0e                	je     800ae6 <strlcpy+0x2a>
			*dst++ = *src++;
  800ad8:	8a 01                	mov    (%ecx),%al
  800ada:	41                   	inc    %ecx
  800adb:	88 03                	mov    %al,(%ebx)
  800add:	43                   	inc    %ebx
  800ade:	4a                   	dec    %edx
  800adf:	74 05                	je     800ae6 <strlcpy+0x2a>
  800ae1:	80 39 00             	cmpb   $0x0,(%ecx)
  800ae4:	75 f2                	jne    800ad8 <strlcpy+0x1c>
		*dst = '\0';
  800ae6:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	29 f0                	sub    %esi,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    

00800af1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  800afa:	80 3a 00             	cmpb   $0x0,(%edx)
  800afd:	74 13                	je     800b12 <strcmp+0x21>
  800aff:	8a 02                	mov    (%edx),%al
  800b01:	3a 01                	cmp    (%ecx),%al
  800b03:	75 0d                	jne    800b12 <strcmp+0x21>
		p++, q++;
  800b05:	42                   	inc    %edx
  800b06:	41                   	inc    %ecx
  800b07:	80 3a 00             	cmpb   $0x0,(%edx)
  800b0a:	74 06                	je     800b12 <strcmp+0x21>
  800b0c:	8a 02                	mov    (%edx),%al
  800b0e:	3a 01                	cmp    (%ecx),%al
  800b10:	74 f3                	je     800b05 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b12:	0f b6 02             	movzbl (%edx),%eax
  800b15:	0f b6 11             	movzbl (%ecx),%edx
  800b18:	29 d0                	sub    %edx,%eax
}
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	53                   	push   %ebx
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800b29:	85 c9                	test   %ecx,%ecx
  800b2b:	74 1f                	je     800b4c <strncmp+0x30>
  800b2d:	80 3a 00             	cmpb   $0x0,(%edx)
  800b30:	74 16                	je     800b48 <strncmp+0x2c>
  800b32:	8a 02                	mov    (%edx),%al
  800b34:	3a 03                	cmp    (%ebx),%al
  800b36:	75 10                	jne    800b48 <strncmp+0x2c>
		n--, p++, q++;
  800b38:	42                   	inc    %edx
  800b39:	43                   	inc    %ebx
  800b3a:	49                   	dec    %ecx
  800b3b:	74 0f                	je     800b4c <strncmp+0x30>
  800b3d:	80 3a 00             	cmpb   $0x0,(%edx)
  800b40:	74 06                	je     800b48 <strncmp+0x2c>
  800b42:	8a 02                	mov    (%edx),%al
  800b44:	3a 03                	cmp    (%ebx),%al
  800b46:	74 f0                	je     800b38 <strncmp+0x1c>
	if (n == 0)
  800b48:	85 c9                	test   %ecx,%ecx
  800b4a:	75 07                	jne    800b53 <strncmp+0x37>
		return 0;
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b51:	eb 0a                	jmp    800b5d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b53:	0f b6 12             	movzbl (%edx),%edx
  800b56:	0f b6 03             	movzbl (%ebx),%eax
  800b59:	29 c2                	sub    %eax,%edx
  800b5b:	89 d0                	mov    %edx,%eax
}
  800b5d:	8b 1c 24             	mov    (%esp),%ebx
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800b6b:	80 38 00             	cmpb   $0x0,(%eax)
  800b6e:	74 0a                	je     800b7a <strchr+0x18>
		if (*s == c)
  800b70:	38 10                	cmp    %dl,(%eax)
  800b72:	74 0b                	je     800b7f <strchr+0x1d>
  800b74:	40                   	inc    %eax
  800b75:	80 38 00             	cmpb   $0x0,(%eax)
  800b78:	75 f6                	jne    800b70 <strchr+0xe>
			return (char *) s;
	return 0;
  800b7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800b8a:	80 38 00             	cmpb   $0x0,(%eax)
  800b8d:	74 0a                	je     800b99 <strfind+0x18>
		if (*s == c)
  800b8f:	38 10                	cmp    %dl,(%eax)
  800b91:	74 06                	je     800b99 <strfind+0x18>
  800b93:	40                   	inc    %eax
  800b94:	80 38 00             	cmpb   $0x0,(%eax)
  800b97:	75 f6                	jne    800b8f <strfind+0xe>
			break;
	return (char *) s;
}
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba5:	89 f8                	mov    %edi,%eax
  800ba7:	85 c9                	test   %ecx,%ecx
  800ba9:	74 40                	je     800beb <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb1:	75 30                	jne    800be3 <memset+0x48>
  800bb3:	f6 c1 03             	test   $0x3,%cl
  800bb6:	75 2b                	jne    800be3 <memset+0x48>
		c &= 0xFF;
  800bb8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc2:	c1 e0 18             	shl    $0x18,%eax
  800bc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc8:	c1 e2 10             	shl    $0x10,%edx
  800bcb:	09 d0                	or     %edx,%eax
  800bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd0:	c1 e2 08             	shl    $0x8,%edx
  800bd3:	09 d0                	or     %edx,%eax
  800bd5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800bd8:	c1 e9 02             	shr    $0x2,%ecx
  800bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bde:	fc                   	cld    
  800bdf:	f3 ab                	repz stos %eax,%es:(%edi)
  800be1:	eb 06                	jmp    800be9 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be6:	fc                   	cld    
  800be7:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800be9:	89 f8                	mov    %edi,%eax
}
  800beb:	8b 3c 24             	mov    (%esp),%edi
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800bfb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800bfe:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c00:	39 c6                	cmp    %eax,%esi
  800c02:	73 33                	jae    800c37 <memmove+0x47>
  800c04:	8d 14 31             	lea    (%ecx,%esi,1),%edx
  800c07:	39 c2                	cmp    %eax,%edx
  800c09:	76 2c                	jbe    800c37 <memmove+0x47>
		s += n;
  800c0b:	89 d6                	mov    %edx,%esi
		d += n;
  800c0d:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c10:	f6 c2 03             	test   $0x3,%dl
  800c13:	75 1b                	jne    800c30 <memmove+0x40>
  800c15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c1b:	75 13                	jne    800c30 <memmove+0x40>
  800c1d:	f6 c1 03             	test   $0x3,%cl
  800c20:	75 0e                	jne    800c30 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800c22:	83 ef 04             	sub    $0x4,%edi
  800c25:	83 ee 04             	sub    $0x4,%esi
  800c28:	c1 e9 02             	shr    $0x2,%ecx
  800c2b:	fd                   	std    
  800c2c:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800c2e:	eb 27                	jmp    800c57 <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c30:	4f                   	dec    %edi
  800c31:	4e                   	dec    %esi
  800c32:	fd                   	std    
  800c33:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
  800c35:	eb 20                	jmp    800c57 <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c37:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c3d:	75 15                	jne    800c54 <memmove+0x64>
  800c3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c45:	75 0d                	jne    800c54 <memmove+0x64>
  800c47:	f6 c1 03             	test   $0x3,%cl
  800c4a:	75 08                	jne    800c54 <memmove+0x64>
			asm volatile("cld; rep movsl\n"
  800c4c:	c1 e9 02             	shr    $0x2,%ecx
  800c4f:	fc                   	cld    
  800c50:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
  800c52:	eb 03                	jmp    800c57 <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c54:	fc                   	cld    
  800c55:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	c9                   	leave  
  800c5a:	c3                   	ret    

00800c5b <memcpy>:

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
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c61:	ff 75 10             	pushl  0x10(%ebp)
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	ff 75 08             	pushl  0x8(%ebp)
  800c6a:	e8 81 ff ff ff       	call   800bf0 <memmove>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	53                   	push   %ebx
  800c75:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
  800c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800c7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  800c7e:	89 d0                	mov    %edx,%eax
  800c80:	4a                   	dec    %edx
  800c81:	85 c0                	test   %eax,%eax
  800c83:	74 1b                	je     800ca0 <memcmp+0x2f>
		if (*s1 != *s2)
  800c85:	8a 01                	mov    (%ecx),%al
  800c87:	3a 03                	cmp    (%ebx),%al
  800c89:	74 0c                	je     800c97 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c8b:	0f b6 d0             	movzbl %al,%edx
  800c8e:	0f b6 03             	movzbl (%ebx),%eax
  800c91:	29 c2                	sub    %eax,%edx
  800c93:	89 d0                	mov    %edx,%eax
  800c95:	eb 0e                	jmp    800ca5 <memcmp+0x34>
		s1++, s2++;
  800c97:	41                   	inc    %ecx
  800c98:	43                   	inc    %ebx
  800c99:	89 d0                	mov    %edx,%eax
  800c9b:	4a                   	dec    %edx
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	75 e5                	jne    800c85 <memcmp+0x14>
	}

	return 0;
  800ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    

00800ca8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb6:	39 d0                	cmp    %edx,%eax
  800cb8:	73 09                	jae    800cc3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cba:	38 08                	cmp    %cl,(%eax)
  800cbc:	74 05                	je     800cc3 <memfind+0x1b>
  800cbe:	40                   	inc    %eax
  800cbf:	39 d0                	cmp    %edx,%eax
  800cc1:	72 f7                	jb     800cba <memfind+0x12>
			break;
	return (void *) s;
}
  800cc3:	c9                   	leave  
  800cc4:	c3                   	ret    

00800cc5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800cd4:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800cd9:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cde:	80 3a 20             	cmpb   $0x20,(%edx)
  800ce1:	74 05                	je     800ce8 <strtol+0x23>
  800ce3:	80 3a 09             	cmpb   $0x9,(%edx)
  800ce6:	75 0b                	jne    800cf3 <strtol+0x2e>
		s++;
  800ce8:	42                   	inc    %edx
  800ce9:	80 3a 20             	cmpb   $0x20,(%edx)
  800cec:	74 fa                	je     800ce8 <strtol+0x23>
  800cee:	80 3a 09             	cmpb   $0x9,(%edx)
  800cf1:	74 f5                	je     800ce8 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800cf3:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800cf6:	75 03                	jne    800cfb <strtol+0x36>
		s++;
  800cf8:	42                   	inc    %edx
  800cf9:	eb 0b                	jmp    800d06 <strtol+0x41>
	else if (*s == '-')
  800cfb:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800cfe:	75 06                	jne    800d06 <strtol+0x41>
		s++, neg = 1;
  800d00:	42                   	inc    %edx
  800d01:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d06:	85 c9                	test   %ecx,%ecx
  800d08:	74 05                	je     800d0f <strtol+0x4a>
  800d0a:	83 f9 10             	cmp    $0x10,%ecx
  800d0d:	75 15                	jne    800d24 <strtol+0x5f>
  800d0f:	80 3a 30             	cmpb   $0x30,(%edx)
  800d12:	75 10                	jne    800d24 <strtol+0x5f>
  800d14:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d18:	75 0a                	jne    800d24 <strtol+0x5f>
		s += 2, base = 16;
  800d1a:	83 c2 02             	add    $0x2,%edx
  800d1d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d22:	eb 1a                	jmp    800d3e <strtol+0x79>
	else if (base == 0 && s[0] == '0')
  800d24:	85 c9                	test   %ecx,%ecx
  800d26:	75 16                	jne    800d3e <strtol+0x79>
  800d28:	80 3a 30             	cmpb   $0x30,(%edx)
  800d2b:	75 08                	jne    800d35 <strtol+0x70>
		s++, base = 8;
  800d2d:	42                   	inc    %edx
  800d2e:	b9 08 00 00 00       	mov    $0x8,%ecx
  800d33:	eb 09                	jmp    800d3e <strtol+0x79>
	else if (base == 0)
  800d35:	85 c9                	test   %ecx,%ecx
  800d37:	75 05                	jne    800d3e <strtol+0x79>
		base = 10;
  800d39:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3e:	8a 02                	mov    (%edx),%al
  800d40:	83 e8 30             	sub    $0x30,%eax
  800d43:	3c 09                	cmp    $0x9,%al
  800d45:	77 08                	ja     800d4f <strtol+0x8a>
			dig = *s - '0';
  800d47:	0f be 02             	movsbl (%edx),%eax
  800d4a:	83 e8 30             	sub    $0x30,%eax
  800d4d:	eb 20                	jmp    800d6f <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
  800d4f:	8a 02                	mov    (%edx),%al
  800d51:	83 e8 61             	sub    $0x61,%eax
  800d54:	3c 19                	cmp    $0x19,%al
  800d56:	77 08                	ja     800d60 <strtol+0x9b>
			dig = *s - 'a' + 10;
  800d58:	0f be 02             	movsbl (%edx),%eax
  800d5b:	83 e8 57             	sub    $0x57,%eax
  800d5e:	eb 0f                	jmp    800d6f <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
  800d60:	8a 02                	mov    (%edx),%al
  800d62:	83 e8 41             	sub    $0x41,%eax
  800d65:	3c 19                	cmp    $0x19,%al
  800d67:	77 12                	ja     800d7b <strtol+0xb6>
			dig = *s - 'A' + 10;
  800d69:	0f be 02             	movsbl (%edx),%eax
  800d6c:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800d6f:	39 c8                	cmp    %ecx,%eax
  800d71:	7d 08                	jge    800d7b <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
  800d73:	42                   	inc    %edx
  800d74:	0f af d9             	imul   %ecx,%ebx
  800d77:	01 c3                	add    %eax,%ebx
  800d79:	eb c3                	jmp    800d3e <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d7b:	85 f6                	test   %esi,%esi
  800d7d:	74 02                	je     800d81 <strtol+0xbc>
		*endptr = (char *) s;
  800d7f:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d81:	89 d8                	mov    %ebx,%eax
  800d83:	85 ff                	test   %edi,%edi
  800d85:	74 02                	je     800d89 <strtol+0xc4>
  800d87:	f7 d8                	neg    %eax
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    
	...

00800d90 <__udivdi3>:
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	83 ec 20             	sub    $0x20,%esp
  800d98:	8b 55 14             	mov    0x14(%ebp),%edx
  800d9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800da1:	8b 45 10             	mov    0x10(%ebp),%eax
  800da4:	85 d2                	test   %edx,%edx
  800da6:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800da9:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800db0:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800db7:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800dba:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800dbd:	89 fe                	mov    %edi,%esi
  800dbf:	75 5b                	jne    800e1c <__udivdi3+0x8c>
  800dc1:	39 f8                	cmp    %edi,%eax
  800dc3:	76 2b                	jbe    800df0 <__udivdi3+0x60>
  800dc5:	89 fa                	mov    %edi,%edx
  800dc7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800dca:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800dcd:	89 c7                	mov    %eax,%edi
  800dcf:	90                   	nop    
  800dd0:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800dd7:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800dda:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800ddd:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800de0:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800de3:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800de6:	83 c4 20             	add    $0x20,%esp
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    
  800ded:	8d 76 00             	lea    0x0(%esi),%esi
  800df0:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800df3:	85 c0                	test   %eax,%eax
  800df5:	75 0e                	jne    800e05 <__udivdi3+0x75>
  800df7:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfc:	31 c9                	xor    %ecx,%ecx
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f1                	div    %ecx
  800e02:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e05:	89 f0                	mov    %esi,%eax
  800e07:	31 d2                	xor    %edx,%edx
  800e09:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e0c:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e0f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e12:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e15:	89 c7                	mov    %eax,%edi
  800e17:	eb be                	jmp    800dd7 <__udivdi3+0x47>
  800e19:	8d 76 00             	lea    0x0(%esi),%esi
  800e1c:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
  800e1f:	76 07                	jbe    800e28 <__udivdi3+0x98>
  800e21:	31 ff                	xor    %edi,%edi
  800e23:	eb ab                	jmp    800dd0 <__udivdi3+0x40>
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800e2c:	89 c7                	mov    %eax,%edi
  800e2e:	83 f7 1f             	xor    $0x1f,%edi
  800e31:	75 19                	jne    800e4c <__udivdi3+0xbc>
  800e33:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800e36:	77 0a                	ja     800e42 <__udivdi3+0xb2>
  800e38:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e3b:	31 ff                	xor    %edi,%edi
  800e3d:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
  800e40:	72 8e                	jb     800dd0 <__udivdi3+0x40>
  800e42:	bf 01 00 00 00       	mov    $0x1,%edi
  800e47:	eb 87                	jmp    800dd0 <__udivdi3+0x40>
  800e49:	8d 76 00             	lea    0x0(%esi),%esi
  800e4c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e51:	29 f8                	sub    %edi,%eax
  800e53:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800e56:	89 f9                	mov    %edi,%ecx
  800e58:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800e5b:	d3 e2                	shl    %cl,%edx
  800e5d:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e60:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e63:	d3 e8                	shr    %cl,%eax
  800e65:	09 c2                	or     %eax,%edx
  800e67:	89 f9                	mov    %edi,%ecx
  800e69:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800e6c:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e6f:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e72:	89 f2                	mov    %esi,%edx
  800e74:	d3 ea                	shr    %cl,%edx
  800e76:	89 f9                	mov    %edi,%ecx
  800e78:	d3 e6                	shl    %cl,%esi
  800e7a:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e7d:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e80:	d3 e8                	shr    %cl,%eax
  800e82:	09 c6                	or     %eax,%esi
  800e84:	89 f9                	mov    %edi,%ecx
  800e86:	89 f0                	mov    %esi,%eax
  800e88:	f7 75 ec             	divl   0xffffffec(%ebp)
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	89 c7                	mov    %eax,%edi
  800e8f:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800e92:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e95:	f7 e7                	mul    %edi
  800e97:	39 f2                	cmp    %esi,%edx
  800e99:	77 0f                	ja     800eaa <__udivdi3+0x11a>
  800e9b:	0f 85 2f ff ff ff    	jne    800dd0 <__udivdi3+0x40>
  800ea1:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800ea4:	0f 86 26 ff ff ff    	jbe    800dd0 <__udivdi3+0x40>
  800eaa:	4f                   	dec    %edi
  800eab:	e9 20 ff ff ff       	jmp    800dd0 <__udivdi3+0x40>

00800eb0 <__umoddi3>:
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	83 ec 30             	sub    $0x30,%esp
  800eb8:	8b 55 14             	mov    0x14(%ebp),%edx
  800ebb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ebe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ec1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec4:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800ec7:	85 d2                	test   %edx,%edx
  800ec9:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800ed0:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800ed7:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800eda:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800edd:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800ee0:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800ee3:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800ee6:	75 68                	jne    800f50 <__umoddi3+0xa0>
  800ee8:	39 f8                	cmp    %edi,%eax
  800eea:	76 3c                	jbe    800f28 <__umoddi3+0x78>
  800eec:	89 f0                	mov    %esi,%eax
  800eee:	89 fa                	mov    %edi,%edx
  800ef0:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800ef3:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800ef6:	85 c9                	test   %ecx,%ecx
  800ef8:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800efb:	74 1b                	je     800f18 <__umoddi3+0x68>
  800efd:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f00:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800f03:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f0a:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f0d:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800f10:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800f13:	89 10                	mov    %edx,(%eax)
  800f15:	89 48 04             	mov    %ecx,0x4(%eax)
  800f18:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f1b:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f1e:	83 c4 30             	add    $0x30,%esp
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
  800f2b:	85 f6                	test   %esi,%esi
  800f2d:	75 0d                	jne    800f3c <__umoddi3+0x8c>
  800f2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f34:	31 d2                	xor    %edx,%edx
  800f36:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f39:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f3c:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800f3f:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f42:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f45:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f48:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f4b:	f7 75 cc             	divl   0xffffffcc(%ebp)
  800f4e:	eb a3                	jmp    800ef3 <__umoddi3+0x43>
  800f50:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f53:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800f56:	76 14                	jbe    800f6c <__umoddi3+0xbc>
  800f58:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800f5b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800f5e:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800f61:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800f64:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800f67:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800f6a:	eb ac                	jmp    800f18 <__umoddi3+0x68>
  800f6c:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800f70:	89 c6                	mov    %eax,%esi
  800f72:	83 f6 1f             	xor    $0x1f,%esi
  800f75:	75 4d                	jne    800fc4 <__umoddi3+0x114>
  800f77:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f7a:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800f7d:	77 08                	ja     800f87 <__umoddi3+0xd7>
  800f7f:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
  800f82:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800f85:	72 12                	jb     800f99 <__umoddi3+0xe9>
  800f87:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f8a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f8d:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
  800f90:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800f93:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800f96:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f99:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800f9c:	85 d2                	test   %edx,%edx
  800f9e:	0f 84 74 ff ff ff    	je     800f18 <__umoddi3+0x68>
  800fa4:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fa7:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800faa:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800fad:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800fb0:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800fb3:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800fb6:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800fb9:	89 01                	mov    %eax,(%ecx)
  800fbb:	89 51 04             	mov    %edx,0x4(%ecx)
  800fbe:	e9 55 ff ff ff       	jmp    800f18 <__umoddi3+0x68>
  800fc3:	90                   	nop    
  800fc4:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc9:	29 f0                	sub    %esi,%eax
  800fcb:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800fce:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800fd1:	89 f1                	mov    %esi,%ecx
  800fd3:	d3 e2                	shl    %cl,%edx
  800fd5:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
  800fd8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800fdb:	d3 e8                	shr    %cl,%eax
  800fdd:	09 c2                	or     %eax,%edx
  800fdf:	89 f1                	mov    %esi,%ecx
  800fe1:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
  800fe4:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800fe7:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800fea:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fed:	d3 ea                	shr    %cl,%edx
  800fef:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
  800ff2:	89 f1                	mov    %esi,%ecx
  800ff4:	d3 e7                	shl    %cl,%edi
  800ff6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800ff9:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800ffc:	d3 e8                	shr    %cl,%eax
  800ffe:	09 c7                	or     %eax,%edi
  801000:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  801003:	89 f8                	mov    %edi,%eax
  801005:	89 f1                	mov    %esi,%ecx
  801007:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80100a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  80100d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801010:	f7 65 cc             	mull   0xffffffcc(%ebp)
  801013:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801016:	89 c7                	mov    %eax,%edi
  801018:	77 3f                	ja     801059 <__umoddi3+0x1a9>
  80101a:	74 38                	je     801054 <__umoddi3+0x1a4>
  80101c:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80101f:	85 c0                	test   %eax,%eax
  801021:	0f 84 f1 fe ff ff    	je     800f18 <__umoddi3+0x68>
  801027:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
  80102a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  80102d:	29 f8                	sub    %edi,%eax
  80102f:	19 d1                	sbb    %edx,%ecx
  801031:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
  801034:	89 ca                	mov    %ecx,%edx
  801036:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  801039:	d3 e2                	shl    %cl,%edx
  80103b:	89 f1                	mov    %esi,%ecx
  80103d:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  801040:	d3 e8                	shr    %cl,%eax
  801042:	09 c2                	or     %eax,%edx
  801044:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  801047:	d3 e8                	shr    %cl,%eax
  801049:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  80104c:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  80104f:	e9 b6 fe ff ff       	jmp    800f0a <__umoddi3+0x5a>
  801054:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  801057:	76 c3                	jbe    80101c <__umoddi3+0x16c>
  801059:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
  80105c:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  80105f:	eb bb                	jmp    80101c <__umoddi3+0x16c>
  801061:	90                   	nop    
  801062:	90                   	nop    
  801063:	90                   	nop    
