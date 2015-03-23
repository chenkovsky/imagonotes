
obj/kern/kernel：     文件格式 elf32-i386

反汇编 .text 节：

f0100000 <_start-0xc>:
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 d0 11 00 	lgdtl  0x11d018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

        # Leave a few words on the stack for the user trap frame
	movl	$(bootstacktop-SIZEOF_STRUCT_TRAPFRAME),%esp
f0100033:	bc bc cf 11 f0       	mov    $0xf011cfbc,%esp

	# now to C code
	call	i386_init
f0100038:	e8 03 00 00 00       	call   f0100040 <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <i386_init>:


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];
    extern int32_t sysenterhandler;
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 0b 1d f0       	mov    $0xf01d0b70,%eax
f010004b:	2d 47 fc 1c f0       	sub    $0xf01cfc47,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 47 fc 1c f0       	push   $0xf01cfc47
f0100058:	e8 d6 4c 00 00       	call   f0104d33 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 cb 05 00 00       	call   f010062d <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 52 10 f0       	push   $0xf0105200
f010006f:	e8 fe 2c 00 00       	call   f0102d72 <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100074:	e8 19 09 00 00       	call   f0100992 <i386_detect_memory>
	i386_vm_init();
f0100079:	e8 f3 09 00 00       	call   f0100a71 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f010007e:	e8 6d 24 00 00       	call   f01024f0 <env_init>
	idt_init();
f0100083:	e8 34 2d 00 00       	call   f0102dbc <idt_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100088:	e8 b3 2b 00 00       	call   f0102c40 <pic_init>
	kclock_init();
f010008d:	e8 68 2b 00 00       	call   f0102bfa <kclock_init>
    /*set up MSR*/
    wrmsr(IA32_SYSENTER_CS,GD_KT,0);//set the segment
f0100092:	b9 74 01 00 00       	mov    $0x174,%ecx
f0100097:	b8 08 00 00 00       	mov    $0x8,%eax
f010009c:	ba 00 00 00 00       	mov    $0x0,%edx
f01000a1:	0f 30                	wrmsr  
    wrmsr(IA32_SYSENTER_EIP,&sysenterhandler,0);//set the handler
f01000a3:	b9 76 01 00 00       	mov    $0x176,%ecx
f01000a8:	b8 ca 39 10 f0       	mov    $0xf01039ca,%eax
f01000ad:	0f 30                	wrmsr  
    wrmsr(IA32_SYSENTER_ESP,KSTACKTOP,0);//set the stack
f01000af:	b9 75 01 00 00       	mov    $0x175,%ecx
f01000b4:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f01000b9:	0f 30                	wrmsr  
	// Should always have an idle process as first one.
	ENV_CREATE(user_idle);
f01000bb:	83 c4 08             	add    $0x8,%esp
f01000be:	68 b8 9c 00 00       	push   $0x9cb8
f01000c3:	68 c4 d5 11 f0       	push   $0xf011d5c4
f01000c8:	e8 28 28 00 00       	call   f01028f5 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE);
#else
	// Touch all you want.user_primes
	ENV_CREATE(user_primes);
f01000cd:	83 c4 08             	add    $0x8,%esp
f01000d0:	68 33 af 00 00       	push   $0xaf33
f01000d5:	68 5b b0 1b f0       	push   $0xf01bb05b
f01000da:	e8 16 28 00 00       	call   f01028f5 <env_create>
    //ENV_CREATE(user_yield);
#endif // TEST*


	// Schedule and run the first user environment!
	sched_yield();
f01000df:	e8 0c 39 00 00       	call   f01039f0 <sched_yield>

f01000e4 <_panic>:


}


/*
 * Variable panicstr contains argument to first call to panic; used as flag
 * to indicate that the kernel has already called panic.
 */
static const char *panicstr;

/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	53                   	push   %ebx
f01000e8:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f01000eb:	83 3d 60 fc 1c f0 00 	cmpl   $0x0,0xf01cfc60
f01000f2:	75 39                	jne    f010012d <_panic+0x49>
		goto dead;
	panicstr = fmt;
f01000f4:	8b 45 10             	mov    0x10(%ebp),%eax
f01000f7:	a3 60 fc 1c f0       	mov    %eax,0xf01cfc60

	va_start(ap, fmt);
f01000fc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000ff:	83 ec 04             	sub    $0x4,%esp
f0100102:	ff 75 0c             	pushl  0xc(%ebp)
f0100105:	ff 75 08             	pushl  0x8(%ebp)
f0100108:	68 1b 52 10 f0       	push   $0xf010521b
f010010d:	e8 60 2c 00 00       	call   f0102d72 <cprintf>
	vcprintf(fmt, ap);
f0100112:	83 c4 08             	add    $0x8,%esp
f0100115:	53                   	push   %ebx
f0100116:	ff 75 10             	pushl  0x10(%ebp)
f0100119:	e8 2e 2c 00 00       	call   f0102d4c <vcprintf>
	cprintf("\n");
f010011e:	c7 04 24 17 5c 10 f0 	movl   $0xf0105c17,(%esp)
f0100125:	e8 48 2c 00 00       	call   f0102d72 <cprintf>
	va_end(ap);
f010012a:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012d:	83 ec 0c             	sub    $0xc,%esp
f0100130:	6a 00                	push   $0x0
f0100132:	e8 cc 07 00 00       	call   f0100903 <monitor>
f0100137:	eb f1                	jmp    f010012a <_panic+0x46>

f0100139 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100139:	55                   	push   %ebp
f010013a:	89 e5                	mov    %esp,%ebp
f010013c:	53                   	push   %ebx
f010013d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100140:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100143:	ff 75 0c             	pushl  0xc(%ebp)
f0100146:	ff 75 08             	pushl  0x8(%ebp)
f0100149:	68 33 52 10 f0       	push   $0xf0105233
f010014e:	e8 1f 2c 00 00       	call   f0102d72 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	53                   	push   %ebx
f0100157:	ff 75 10             	pushl  0x10(%ebp)
f010015a:	e8 ed 2b 00 00       	call   f0102d4c <vcprintf>
	cprintf("\n");
f010015f:	c7 04 24 17 5c 10 f0 	movl   $0xf0105c17,(%esp)
f0100166:	e8 07 2c 00 00       	call   f0102d72 <cprintf>
	va_end(ap);
}
f010016b:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010016e:	c9                   	leave  
f010016f:	c3                   	ret    

f0100170 <serial_proc_data>:
static bool serial_exists;

int
serial_proc_data(void)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
}

static __inline uint8_t
inb(int port)
{
f0100173:	ba fd 03 00 00       	mov    $0x3fd,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100178:	ec                   	in     (%dx),%al
f0100179:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010017e:	a8 01                	test   $0x1,%al
f0100180:	74 09                	je     f010018b <serial_proc_data+0x1b>
f0100182:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100187:	ec                   	in     (%dx),%al
f0100188:	0f b6 d0             	movzbl %al,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
	return inb(COM1+COM_RX);
}
f010018b:	89 d0                	mov    %edx,%eax
f010018d:	c9                   	leave  
f010018e:	c3                   	ret    

f010018f <serial_intr>:

void
serial_intr(void)
{
f010018f:	55                   	push   %ebp
f0100190:	89 e5                	mov    %esp,%ebp
f0100192:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100195:	83 3d 84 fc 1c f0 00 	cmpl   $0x0,0xf01cfc84
f010019c:	74 10                	je     f01001ae <serial_intr+0x1f>
		cons_intr(serial_proc_data);
f010019e:	83 ec 0c             	sub    $0xc,%esp
f01001a1:	68 70 01 10 f0       	push   $0xf0100170
f01001a6:	e8 de 03 00 00       	call   f0100589 <cons_intr>
f01001ab:	83 c4 10             	add    $0x10,%esp
}
f01001ae:	c9                   	leave  
f01001af:	c3                   	ret    

f01001b0 <serial_init>:

void
serial_init(void)
{
f01001b0:	55                   	push   %ebp
f01001b1:	89 e5                	mov    %esp,%ebp
f01001b3:	53                   	push   %ebx
f01001b4:	83 ec 04             	sub    $0x4,%esp
}

static __inline void
outb(int port, uint8_t data)
{
f01001b7:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01001bc:	b0 00                	mov    $0x0,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001be:	89 da                	mov    %ebx,%edx
f01001c0:	ee                   	out    %al,(%dx)
f01001c1:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01001c6:	b0 80                	mov    $0x80,%al
f01001c8:	ee                   	out    %al,(%dx)
f01001c9:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01001ce:	b0 0c                	mov    $0xc,%al
f01001d0:	89 ca                	mov    %ecx,%edx
f01001d2:	ee                   	out    %al,(%dx)
f01001d3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01001d8:	b0 00                	mov    $0x0,%al
f01001da:	ee                   	out    %al,(%dx)
f01001db:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01001e0:	b0 03                	mov    $0x3,%al
f01001e2:	ee                   	out    %al,(%dx)
f01001e3:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01001e8:	b0 00                	mov    $0x0,%al
f01001ea:	ee                   	out    %al,(%dx)
f01001eb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01001f0:	b0 01                	mov    $0x1,%al
f01001f2:	ee                   	out    %al,(%dx)
f01001f3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001f8:	ec                   	in     (%dx),%al
f01001f9:	3c ff                	cmp    $0xff,%al
f01001fb:	0f 95 c0             	setne  %al
f01001fe:	0f b6 c0             	movzbl %al,%eax
f0100201:	a3 84 fc 1c f0       	mov    %eax,0xf01cfc84
f0100206:	89 da                	mov    %ebx,%edx
f0100208:	ec                   	in     (%dx),%al
f0100209:	89 ca                	mov    %ecx,%edx
f010020b:	ec                   	in     (%dx),%al
	// Turn off the FIFO
	outb(COM1+COM_FCR, 0);
	
	// Set speed; requires DLAB latch
	outb(COM1+COM_LCR, COM_LCR_DLAB);
	outb(COM1+COM_DLL, (uint8_t) (115200 / 9600));
	outb(COM1+COM_DLM, 0);

	// 8 data bits, 1 stop bit, parity off; turn off DLAB latch
	outb(COM1+COM_LCR, COM_LCR_WLEN8 & ~COM_LCR_DLAB);

	// No modem controls
	outb(COM1+COM_MCR, 0);
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010020c:	83 3d 84 fc 1c f0 00 	cmpl   $0x0,0xf01cfc84
f0100213:	74 18                	je     f010022d <serial_init+0x7d>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100215:	83 ec 0c             	sub    $0xc,%esp
f0100218:	0f b7 05 b8 d5 11 f0 	movzwl 0xf011d5b8,%eax
f010021f:	25 ef ff 00 00       	and    $0xffef,%eax
f0100224:	50                   	push   %eax
f0100225:	e8 95 2a 00 00       	call   f0102cbf <irq_setmask_8259A>
f010022a:	83 c4 10             	add    $0x10,%esp
}
f010022d:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100230:	c9                   	leave  
f0100231:	c3                   	ret    

f0100232 <delay>:



/***** Parallel port output code *****/
// For information on PC parallel port programming, see the class References
// page.

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100232:	55                   	push   %ebp
f0100233:	89 e5                	mov    %esp,%ebp
}

static __inline uint8_t
inb(int port)
{
f0100235:	ba 84 00 00 00       	mov    $0x84,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010023a:	ec                   	in     (%dx),%al
f010023b:	ec                   	in     (%dx),%al
f010023c:	ec                   	in     (%dx),%al
f010023d:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010023e:	c9                   	leave  
f010023f:	c3                   	ret    

f0100240 <lpt_putc>:

static void
lpt_putc(int c)
{
f0100240:	55                   	push   %ebp
f0100241:	89 e5                	mov    %esp,%ebp
f0100243:	56                   	push   %esi
f0100244:	53                   	push   %ebx
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100245:	bb 00 00 00 00       	mov    $0x0,%ebx
}

static __inline uint8_t
inb(int port)
{
f010024a:	ba 79 03 00 00       	mov    $0x379,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010024f:	ec                   	in     (%dx),%al
f0100250:	84 c0                	test   %al,%al
f0100252:	78 1a                	js     f010026e <lpt_putc+0x2e>
f0100254:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100259:	e8 d4 ff ff ff       	call   f0100232 <delay>
f010025e:	43                   	inc    %ebx
static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010025f:	89 f2                	mov    %esi,%edx
f0100261:	ec                   	in     (%dx),%al
f0100262:	84 c0                	test   %al,%al
f0100264:	78 08                	js     f010026e <lpt_putc+0x2e>
f0100266:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010026c:	7e eb                	jle    f0100259 <lpt_putc+0x19>
	return data;
}

static __inline void
insb(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsb"			:
			 "=D" (addr), "=c" (cnt)		:
			 "d" (port), "0" (addr), "1" (cnt)	:
			 "memory", "cc");
}

static __inline uint16_t
inw(int port)
{
	uint16_t data;
	__asm __volatile("inw %w1,%0" : "=a" (data) : "d" (port));
	return data;
}

static __inline void
insw(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsw"			:
			 "=D" (addr), "=c" (cnt)		:
			 "d" (port), "0" (addr), "1" (cnt)	:
			 "memory", "cc");
}

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
	return data;
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
			 "=D" (addr), "=c" (cnt)		:
			 "d" (port), "0" (addr), "1" (cnt)	:
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f010026e:	ba 78 03 00 00       	mov    $0x378,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100273:	8a 45 08             	mov    0x8(%ebp),%al
f0100276:	ee                   	out    %al,(%dx)
f0100277:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010027c:	b0 0d                	mov    $0xd,%al
f010027e:	ee                   	out    %al,(%dx)
f010027f:	b0 08                	mov    $0x8,%al
f0100281:	ee                   	out    %al,(%dx)
	outb(0x378+0, c);
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
f0100282:	5b                   	pop    %ebx
f0100283:	5e                   	pop    %esi
f0100284:	c9                   	leave  
f0100285:	c3                   	ret    

f0100286 <cga_init>:




/***** Text-mode CGA/VGA display output *****/

static unsigned addr_6845;
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f0100286:	55                   	push   %ebp
f0100287:	89 e5                	mov    %esp,%ebp
f0100289:	57                   	push   %edi
f010028a:	56                   	push   %esi
f010028b:	53                   	push   %ebx
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010028c:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	was = *cp;
f0100291:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100298:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010029f:	5a a5 
	if (*cp != 0xA55A) {
f01002a1:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01002a7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01002ab:	74 11                	je     f01002be <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01002ad:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
		addr_6845 = MONO_BASE;
f01002b2:	c7 05 88 fc 1c f0 b4 	movl   $0x3b4,0xf01cfc88
f01002b9:	03 00 00 
f01002bc:	eb 0d                	jmp    f01002cb <cga_init+0x45>
	} else {
		*cp = was;
f01002be:	66 89 16             	mov    %dx,(%esi)
		addr_6845 = CGA_BASE;
f01002c1:	c7 05 88 fc 1c f0 d4 	movl   $0x3d4,0xf01cfc88
f01002c8:	03 00 00 
}

static __inline void
outb(int port, uint8_t data)
{
f01002cb:	8b 0d 88 fc 1c f0    	mov    0xf01cfc88,%ecx
f01002d1:	b0 0e                	mov    $0xe,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d3:	89 ca                	mov    %ecx,%edx
f01002d5:	ee                   	out    %al,(%dx)
f01002d6:	8d 79 01             	lea    0x1(%ecx),%edi
f01002d9:	89 fa                	mov    %edi,%edx
f01002db:	ec                   	in     (%dx),%al
f01002dc:	0f b6 d8             	movzbl %al,%ebx
f01002df:	c1 e3 08             	shl    $0x8,%ebx
f01002e2:	b0 0f                	mov    $0xf,%al
f01002e4:	89 ca                	mov    %ecx,%edx
f01002e6:	ee                   	out    %al,(%dx)
f01002e7:	89 fa                	mov    %edi,%edx
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	0f b6 c0             	movzbl %al,%eax
f01002ed:	09 c3                	or     %eax,%ebx
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01002ef:	89 35 8c fc 1c f0    	mov    %esi,0xf01cfc8c
	crt_pos = pos;
f01002f5:	66 89 1d 90 fc 1c f0 	mov    %bx,0xf01cfc90
}
f01002fc:	5b                   	pop    %ebx
f01002fd:	5e                   	pop    %esi
f01002fe:	5f                   	pop    %edi
f01002ff:	c9                   	leave  
f0100300:	c3                   	ret    

f0100301 <cga_putc>:



void
cga_putc(int c)
{
f0100301:	55                   	push   %ebp
f0100302:	89 e5                	mov    %esp,%ebp
f0100304:	53                   	push   %ebx
f0100305:	83 ec 04             	sub    $0x4,%esp
f0100308:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010030b:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f0100311:	75 03                	jne    f0100316 <cga_putc+0x15>
		c |= 0x0700;
f0100313:	80 cd 07             	or     $0x7,%ch

	switch (c & 0xff) {
f0100316:	0f b6 c1             	movzbl %cl,%eax
f0100319:	83 f8 09             	cmp    $0x9,%eax
f010031c:	74 7b                	je     f0100399 <cga_putc+0x98>
f010031e:	83 f8 09             	cmp    $0x9,%eax
f0100321:	7f 0a                	jg     f010032d <cga_putc+0x2c>
f0100323:	83 f8 08             	cmp    $0x8,%eax
f0100326:	74 14                	je     f010033c <cga_putc+0x3b>
f0100328:	e9 ab 00 00 00       	jmp    f01003d8 <cga_putc+0xd7>
f010032d:	83 f8 0a             	cmp    $0xa,%eax
f0100330:	74 3c                	je     f010036e <cga_putc+0x6d>
f0100332:	83 f8 0d             	cmp    $0xd,%eax
f0100335:	74 3f                	je     f0100376 <cga_putc+0x75>
f0100337:	e9 9c 00 00 00       	jmp    f01003d8 <cga_putc+0xd7>
	case '\b':
		if (crt_pos > 0) {
f010033c:	66 83 3d 90 fc 1c f0 	cmpw   $0x0,0xf01cfc90
f0100343:	00 
f0100344:	0f 84 a5 00 00 00    	je     f01003ef <cga_putc+0xee>
			crt_pos--;
f010034a:	66 ff 0d 90 fc 1c f0 	decw   0xf01cfc90
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100351:	0f b7 05 90 fc 1c f0 	movzwl 0xf01cfc90,%eax
f0100358:	89 ca                	mov    %ecx,%edx
f010035a:	b2 00                	mov    $0x0,%dl
f010035c:	83 ca 20             	or     $0x20,%edx
f010035f:	8b 0d 8c fc 1c f0    	mov    0xf01cfc8c,%ecx
f0100365:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
		}
		break;
f0100369:	e9 81 00 00 00       	jmp    f01003ef <cga_putc+0xee>
	case '\n':
		crt_pos += CRT_COLS;
f010036e:	66 83 05 90 fc 1c f0 	addw   $0x50,0xf01cfc90
f0100375:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100376:	66 8b 1d 90 fc 1c f0 	mov    0xf01cfc90,%bx
f010037d:	b9 50 00 00 00       	mov    $0x50,%ecx
f0100382:	ba 00 00 00 00       	mov    $0x0,%edx
f0100387:	89 d8                	mov    %ebx,%eax
f0100389:	66 f7 f1             	div    %cx
f010038c:	89 d8                	mov    %ebx,%eax
f010038e:	66 29 d0             	sub    %dx,%ax
f0100391:	66 a3 90 fc 1c f0    	mov    %ax,0xf01cfc90
		break;
f0100397:	eb 56                	jmp    f01003ef <cga_putc+0xee>
	case '\t':
		cons_putc(' ');
f0100399:	83 ec 0c             	sub    $0xc,%esp
f010039c:	6a 20                	push   $0x20
f010039e:	e8 6d 02 00 00       	call   f0100610 <cons_putc>
		cons_putc(' ');
f01003a3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01003aa:	e8 61 02 00 00       	call   f0100610 <cons_putc>
		cons_putc(' ');
f01003af:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01003b6:	e8 55 02 00 00       	call   f0100610 <cons_putc>
		cons_putc(' ');
f01003bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01003c2:	e8 49 02 00 00       	call   f0100610 <cons_putc>
		cons_putc(' ');
f01003c7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01003ce:	e8 3d 02 00 00       	call   f0100610 <cons_putc>
		break;
f01003d3:	83 c4 10             	add    $0x10,%esp
f01003d6:	eb 17                	jmp    f01003ef <cga_putc+0xee>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003d8:	0f b7 15 90 fc 1c f0 	movzwl 0xf01cfc90,%edx
f01003df:	a1 8c fc 1c f0       	mov    0xf01cfc8c,%eax
f01003e4:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01003e8:	66 ff 05 90 fc 1c f0 	incw   0xf01cfc90
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003ef:	66 81 3d 90 fc 1c f0 	cmpw   $0x7cf,0xf01cfc90
f01003f6:	cf 07 
f01003f8:	76 3f                	jbe    f0100439 <cga_putc+0x138>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003fa:	83 ec 04             	sub    $0x4,%esp
f01003fd:	68 00 0f 00 00       	push   $0xf00
f0100402:	8b 15 8c fc 1c f0    	mov    0xf01cfc8c,%edx
f0100408:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f010040e:	50                   	push   %eax
f010040f:	52                   	push   %edx
f0100410:	e8 73 49 00 00       	call   f0104d88 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100415:	ba 80 07 00 00       	mov    $0x780,%edx
f010041a:	83 c4 10             	add    $0x10,%esp
			crt_buf[i] = 0x0700 | ' ';
f010041d:	a1 8c fc 1c f0       	mov    0xf01cfc8c,%eax
f0100422:	66 c7 04 50 20 07    	movw   $0x720,(%eax,%edx,2)
f0100428:	42                   	inc    %edx
f0100429:	81 fa cf 07 00 00    	cmp    $0x7cf,%edx
f010042f:	7e ec                	jle    f010041d <cga_putc+0x11c>
		crt_pos -= CRT_COLS;
f0100431:	66 83 2d 90 fc 1c f0 	subw   $0x50,0xf01cfc90
f0100438:	50 
}

static __inline void
outb(int port, uint8_t data)
{
f0100439:	8b 1d 88 fc 1c f0    	mov    0xf01cfc88,%ebx
f010043f:	b0 0e                	mov    $0xe,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100441:	89 da                	mov    %ebx,%edx
f0100443:	ee                   	out    %al,(%dx)
f0100444:	8d 4b 01             	lea    0x1(%ebx),%ecx
f0100447:	a0 91 fc 1c f0       	mov    0xf01cfc91,%al
f010044c:	89 ca                	mov    %ecx,%edx
f010044e:	ee                   	out    %al,(%dx)
f010044f:	b0 0f                	mov    $0xf,%al
f0100451:	89 da                	mov    %ebx,%edx
f0100453:	ee                   	out    %al,(%dx)
f0100454:	a0 90 fc 1c f0       	mov    0xf01cfc90,%al
f0100459:	89 ca                	mov    %ecx,%edx
f010045b:	ee                   	out    %al,(%dx)
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
	outb(addr_6845 + 1, crt_pos >> 8);
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f010045c:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010045f:	c9                   	leave  
f0100460:	c3                   	ret    

f0100461 <kbd_proc_data>:


/***** Keyboard input code *****/

#define NO		0

#define SHIFT		(1<<0)
#define CTL		(1<<1)
#define ALT		(1<<2)

#define CAPSLOCK	(1<<3)
#define NUMLOCK		(1<<4)
#define SCROLLLOCK	(1<<5)

#define E0ESC		(1<<6)

static uint8_t shiftcode[256] = 
{
	[0x1D] CTL,
	[0x2A] SHIFT,
	[0x36] SHIFT,
	[0x38] ALT,
	[0x9D] CTL,
	[0xB8] ALT
};

static uint8_t togglecode[256] = 
{
	[0x3A] CAPSLOCK,
	[0x45] NUMLOCK,
	[0x46] SCROLLLOCK
};

static uint8_t normalmap[256] =
{
	NO,   0x1B, '1',  '2',  '3',  '4',  '5',  '6',	// 0x00
	'7',  '8',  '9',  '0',  '-',  '=',  '\b', '\t',
	'q',  'w',  'e',  'r',  't',  'y',  'u',  'i',	// 0x10
	'o',  'p',  '[',  ']',  '\n', NO,   'a',  's',
	'd',  'f',  'g',  'h',  'j',  'k',  'l',  ';',	// 0x20
	'\'', '`',  NO,   '\\', 'z',  'x',  'c',  'v',
	'b',  'n',  'm',  ',',  '.',  '/',  NO,   '*',	// 0x30
	NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
	NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',	// 0x40
	'8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
	'2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,	// 0x50
	[0xC7] KEY_HOME,	[0x9C] '\n' /*KP_Enter*/,
	[0xB5] '/' /*KP_Div*/,	[0xC8] KEY_UP,
	[0xC9] KEY_PGUP,	[0xCB] KEY_LF,
	[0xCD] KEY_RT,		[0xCF] KEY_END,
	[0xD0] KEY_DN,		[0xD1] KEY_PGDN,
	[0xD2] KEY_INS,		[0xD3] KEY_DEL
};

static uint8_t shiftmap[256] = 
{
	NO,   033,  '!',  '@',  '#',  '$',  '%',  '^',	// 0x00
	'&',  '*',  '(',  ')',  '_',  '+',  '\b', '\t',
	'Q',  'W',  'E',  'R',  'T',  'Y',  'U',  'I',	// 0x10
	'O',  'P',  '{',  '}',  '\n', NO,   'A',  'S',
	'D',  'F',  'G',  'H',  'J',  'K',  'L',  ':',	// 0x20
	'"',  '~',  NO,   '|',  'Z',  'X',  'C',  'V',
	'B',  'N',  'M',  '<',  '>',  '?',  NO,   '*',	// 0x30
	NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
	NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',	// 0x40
	'8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
	'2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,	// 0x50
	[0xC7] KEY_HOME,	[0x9C] '\n' /*KP_Enter*/,
	[0xB5] '/' /*KP_Div*/,	[0xC8] KEY_UP,
	[0xC9] KEY_PGUP,	[0xCB] KEY_LF,
	[0xCD] KEY_RT,		[0xCF] KEY_END,
	[0xD0] KEY_DN,		[0xD1] KEY_PGDN,
	[0xD2] KEY_INS,		[0xD3] KEY_DEL
};

#define C(x) (x - '@')

static uint8_t ctlmap[256] = 
{
	NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO, 
	NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO, 
	C('Q'),  C('W'),  C('E'),  C('R'),  C('T'),  C('Y'),  C('U'),  C('I'),
	C('O'),  C('P'),  NO,      NO,      '\r',    NO,      C('A'),  C('S'),
	C('D'),  C('F'),  C('G'),  C('H'),  C('J'),  C('K'),  C('L'),  NO, 
	NO,      NO,      NO,      C('\\'), C('Z'),  C('X'),  C('C'),  C('V'),
	C('B'),  C('N'),  C('M'),  NO,      NO,      C('/'),  NO,      NO,
	[0x97] KEY_HOME,
	[0xB5] C('/'),		[0xC8] KEY_UP,
	[0xC9] KEY_PGUP,	[0xCB] KEY_LF,
	[0xCD] KEY_RT,		[0xCF] KEY_END,
	[0xD0] KEY_DN,		[0xD1] KEY_PGDN,
	[0xD2] KEY_INS,		[0xD3] KEY_DEL
};

static uint8_t *charcode[4] = {
	normalmap,
	shiftmap,
	ctlmap,
	ctlmap
};

/*
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100461:	55                   	push   %ebp
f0100462:	89 e5                	mov    %esp,%ebp
f0100464:	53                   	push   %ebx
f0100465:	83 ec 04             	sub    $0x4,%esp
}

static __inline uint8_t
inb(int port)
{
f0100468:	ba 64 00 00 00       	mov    $0x64,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010046d:	ec                   	in     (%dx),%al
f010046e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100473:	a8 01                	test   $0x1,%al
f0100475:	0f 84 d3 00 00 00    	je     f010054e <kbd_proc_data+0xed>
f010047b:	ba 60 00 00 00       	mov    $0x60,%edx
f0100480:	ec                   	in     (%dx),%al
f0100481:	88 c2                	mov    %al,%dl
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100483:	3c e0                	cmp    $0xe0,%al
f0100485:	75 09                	jne    f0100490 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100487:	83 0d 80 fc 1c f0 40 	orl    $0x40,0xf01cfc80
		return 0;
f010048e:	eb 27                	jmp    f01004b7 <kbd_proc_data+0x56>
	} else if (data & 0x80) {
f0100490:	84 c0                	test   %al,%al
f0100492:	79 2d                	jns    f01004c1 <kbd_proc_data+0x60>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100494:	f6 05 80 fc 1c f0 40 	testb  $0x40,0xf01cfc80
f010049b:	75 03                	jne    f01004a0 <kbd_proc_data+0x3f>
f010049d:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01004a0:	0f b6 c2             	movzbl %dl,%eax
f01004a3:	8a 80 20 d0 11 f0    	mov    0xf011d020(%eax),%al
f01004a9:	83 c8 40             	or     $0x40,%eax
f01004ac:	0f b6 c0             	movzbl %al,%eax
f01004af:	f7 d0                	not    %eax
f01004b1:	21 05 80 fc 1c f0    	and    %eax,0xf01cfc80
		return 0;
f01004b7:	ba 00 00 00 00       	mov    $0x0,%edx
f01004bc:	e9 8d 00 00 00       	jmp    f010054e <kbd_proc_data+0xed>
	} else if (shift & E0ESC) {
f01004c1:	a1 80 fc 1c f0       	mov    0xf01cfc80,%eax
f01004c6:	a8 40                	test   $0x40,%al
f01004c8:	74 0b                	je     f01004d5 <kbd_proc_data+0x74>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01004ca:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01004cd:	83 e0 bf             	and    $0xffffffbf,%eax
f01004d0:	a3 80 fc 1c f0       	mov    %eax,0xf01cfc80
	}

	shift |= shiftcode[data];
f01004d5:	0f b6 ca             	movzbl %dl,%ecx
f01004d8:	0f b6 81 20 d0 11 f0 	movzbl 0xf011d020(%ecx),%eax
f01004df:	0b 05 80 fc 1c f0    	or     0xf01cfc80,%eax
	shift ^= togglecode[data];
f01004e5:	0f b6 91 20 d1 11 f0 	movzbl 0xf011d120(%ecx),%edx
f01004ec:	31 c2                	xor    %eax,%edx
f01004ee:	89 15 80 fc 1c f0    	mov    %edx,0xf01cfc80

	c = charcode[shift & (CTL | SHIFT)][data];
f01004f4:	89 d0                	mov    %edx,%eax
f01004f6:	83 e0 03             	and    $0x3,%eax
f01004f9:	8b 04 85 20 d5 11 f0 	mov    0xf011d520(,%eax,4),%eax
f0100500:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100504:	f6 c2 08             	test   $0x8,%dl
f0100507:	74 18                	je     f0100521 <kbd_proc_data+0xc0>
		if ('a' <= c && c <= 'z')
f0100509:	8d 43 9f             	lea    0xffffff9f(%ebx),%eax
f010050c:	83 f8 19             	cmp    $0x19,%eax
f010050f:	77 05                	ja     f0100516 <kbd_proc_data+0xb5>
			c += 'A' - 'a';
f0100511:	83 eb 20             	sub    $0x20,%ebx
f0100514:	eb 0b                	jmp    f0100521 <kbd_proc_data+0xc0>
		else if ('A' <= c && c <= 'Z')
f0100516:	8d 43 bf             	lea    0xffffffbf(%ebx),%eax
f0100519:	83 f8 19             	cmp    $0x19,%eax
f010051c:	77 03                	ja     f0100521 <kbd_proc_data+0xc0>
			c += 'a' - 'A';
f010051e:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100521:	a1 80 fc 1c f0       	mov    0xf01cfc80,%eax
f0100526:	f7 d0                	not    %eax
f0100528:	a8 06                	test   $0x6,%al
f010052a:	75 20                	jne    f010054c <kbd_proc_data+0xeb>
f010052c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100532:	75 18                	jne    f010054c <kbd_proc_data+0xeb>
		cprintf("Rebooting!\n");
f0100534:	83 ec 0c             	sub    $0xc,%esp
f0100537:	68 4d 52 10 f0       	push   $0xf010524d
f010053c:	e8 31 28 00 00       	call   f0102d72 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
f0100541:	83 c4 10             	add    $0x10,%esp
f0100544:	ba 92 00 00 00       	mov    $0x92,%edx
f0100549:	b0 03                	mov    $0x3,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010054b:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010054c:	89 da                	mov    %ebx,%edx
}
f010054e:	89 d0                	mov    %edx,%eax
f0100550:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100553:	c9                   	leave  
f0100554:	c3                   	ret    

f0100555 <kbd_intr>:

void
kbd_intr(void)
{
f0100555:	55                   	push   %ebp
f0100556:	89 e5                	mov    %esp,%ebp
f0100558:	83 ec 14             	sub    $0x14,%esp
	cons_intr(kbd_proc_data);
f010055b:	68 61 04 10 f0       	push   $0xf0100461
f0100560:	e8 24 00 00 00       	call   f0100589 <cons_intr>
}
f0100565:	c9                   	leave  
f0100566:	c3                   	ret    

f0100567 <kbd_init>:

void
kbd_init(void)
{
f0100567:	55                   	push   %ebp
f0100568:	89 e5                	mov    %esp,%ebp
f010056a:	83 ec 08             	sub    $0x8,%esp
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f010056d:	e8 e3 ff ff ff       	call   f0100555 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100572:	83 ec 0c             	sub    $0xc,%esp
f0100575:	0f b7 05 b8 d5 11 f0 	movzwl 0xf011d5b8,%eax
f010057c:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100581:	50                   	push   %eax
f0100582:	e8 38 27 00 00       	call   f0102cbf <irq_setmask_8259A>
}
f0100587:	c9                   	leave  
f0100588:	c3                   	ret    

f0100589 <cons_intr>:



/***** General device-independent console code *****/
// Here we manage the console input buffer,
// where we stash characters received from the keyboard or serial port
// whenever the corresponding interrupt occurs.

#define CONSBUFSIZE 512

static struct {
	uint8_t buf[CONSBUFSIZE];
	uint32_t rpos;
	uint32_t wpos;
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f0100589:	55                   	push   %ebp
f010058a:	89 e5                	mov    %esp,%ebp
f010058c:	53                   	push   %ebx
f010058d:	83 ec 04             	sub    $0x4,%esp
f0100590:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100593:	eb 26                	jmp    f01005bb <cons_intr+0x32>
		if (c == 0)
f0100595:	85 d2                	test   %edx,%edx
f0100597:	74 22                	je     f01005bb <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f0100599:	a1 a4 fe 1c f0       	mov    0xf01cfea4,%eax
f010059e:	88 90 a0 fc 1c f0    	mov    %dl,0xf01cfca0(%eax)
f01005a4:	40                   	inc    %eax
f01005a5:	a3 a4 fe 1c f0       	mov    %eax,0xf01cfea4
		if (cons.wpos == CONSBUFSIZE)
f01005aa:	3d 00 02 00 00       	cmp    $0x200,%eax
f01005af:	75 0a                	jne    f01005bb <cons_intr+0x32>
			cons.wpos = 0;
f01005b1:	c7 05 a4 fe 1c f0 00 	movl   $0x0,0xf01cfea4
f01005b8:	00 00 00 
f01005bb:	ff d3                	call   *%ebx
f01005bd:	89 c2                	mov    %eax,%edx
f01005bf:	83 f8 ff             	cmp    $0xffffffff,%eax
f01005c2:	75 d1                	jne    f0100595 <cons_intr+0xc>
	}
}
f01005c4:	83 c4 04             	add    $0x4,%esp
f01005c7:	5b                   	pop    %ebx
f01005c8:	c9                   	leave  
f01005c9:	c3                   	ret    

f01005ca <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005ca:	55                   	push   %ebp
f01005cb:	89 e5                	mov    %esp,%ebp
f01005cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005d0:	e8 ba fb ff ff       	call   f010018f <serial_intr>
	kbd_intr();
f01005d5:	e8 7b ff ff ff       	call   f0100555 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005da:	a1 a0 fe 1c f0       	mov    0xf01cfea0,%eax
f01005df:	3b 05 a4 fe 1c f0    	cmp    0xf01cfea4,%eax
f01005e5:	74 22                	je     f0100609 <cons_getc+0x3f>
		c = cons.buf[cons.rpos++];
f01005e7:	0f b6 90 a0 fc 1c f0 	movzbl 0xf01cfca0(%eax),%edx
f01005ee:	40                   	inc    %eax
f01005ef:	a3 a0 fe 1c f0       	mov    %eax,0xf01cfea0
		if (cons.rpos == CONSBUFSIZE)
f01005f4:	3d 00 02 00 00       	cmp    $0x200,%eax
f01005f9:	75 0a                	jne    f0100605 <cons_getc+0x3b>
			cons.rpos = 0;
f01005fb:	c7 05 a0 fe 1c f0 00 	movl   $0x0,0xf01cfea0
f0100602:	00 00 00 
		return c;
f0100605:	89 d0                	mov    %edx,%eax
f0100607:	eb 05                	jmp    f010060e <cons_getc+0x44>
	}
	return 0;
f0100609:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	53                   	push   %ebx
f0100614:	83 ec 10             	sub    $0x10,%esp
f0100617:	8b 5d 08             	mov    0x8(%ebp),%ebx
	lpt_putc(c);
f010061a:	53                   	push   %ebx
f010061b:	e8 20 fc ff ff       	call   f0100240 <lpt_putc>
	cga_putc(c);
f0100620:	89 1c 24             	mov    %ebx,(%esp)
f0100623:	e8 d9 fc ff ff       	call   f0100301 <cga_putc>
}
f0100628:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010062b:	c9                   	leave  
f010062c:	c3                   	ret    

f010062d <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010062d:	55                   	push   %ebp
f010062e:	89 e5                	mov    %esp,%ebp
f0100630:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f0100633:	e8 4e fc ff ff       	call   f0100286 <cga_init>
	kbd_init();
f0100638:	e8 2a ff ff ff       	call   f0100567 <kbd_init>
	serial_init();
f010063d:	e8 6e fb ff ff       	call   f01001b0 <serial_init>

	if (!serial_exists)
f0100642:	83 3d 84 fc 1c f0 00 	cmpl   $0x0,0xf01cfc84
f0100649:	75 10                	jne    f010065b <cons_init+0x2e>
		cprintf("Serial port does not exist!\n");
f010064b:	83 ec 0c             	sub    $0xc,%esp
f010064e:	68 59 52 10 f0       	push   $0xf0105259
f0100653:	e8 1a 27 00 00       	call   f0102d72 <cprintf>
f0100658:	83 c4 10             	add    $0x10,%esp
}
f010065b:	c9                   	leave  
f010065c:	c3                   	ret    

f010065d <cputchar>:


// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065d:	55                   	push   %ebp
f010065e:	89 e5                	mov    %esp,%ebp
f0100660:	83 ec 14             	sub    $0x14,%esp
	cons_putc(c);
f0100663:	ff 75 08             	pushl  0x8(%ebp)
f0100666:	e8 a5 ff ff ff       	call   f0100610 <cons_putc>
}
f010066b:	c9                   	leave  
f010066c:	c3                   	ret    

f010066d <getchar>:

int
getchar(void)
{
f010066d:	55                   	push   %ebp
f010066e:	89 e5                	mov    %esp,%ebp
f0100670:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100673:	e8 52 ff ff ff       	call   f01005ca <cons_getc>
f0100678:	85 c0                	test   %eax,%eax
f010067a:	74 f7                	je     f0100673 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067c:	c9                   	leave  
f010067d:	c3                   	ret    

f010067e <iscons>:

int
iscons(int fdnum)
{
f010067e:	55                   	push   %ebp
f010067f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100681:	b8 01 00 00 00       	mov    $0x1,%eax
f0100686:	c9                   	leave  
f0100687:	c3                   	ret    

f0100688 <print_fun_name>:
    { "backtrace", "back trace the stack", mon_backtrace}
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

void print_fun_name(const struct Eipdebuginfo *info) {
f0100688:	55                   	push   %ebp
f0100689:	89 e5                	mov    %esp,%ebp
f010068b:	56                   	push   %esi
f010068c:	53                   	push   %ebx
f010068d:	8b 75 08             	mov    0x8(%ebp),%esi
    int i;

    for (i = 0; i < info->eip_fn_namelen; i++)
f0100690:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100695:	3b 5e 0c             	cmp    0xc(%esi),%ebx
f0100698:	7d 19                	jge    f01006b3 <print_fun_name+0x2b>
        cputchar(info->eip_fn_name[i]);
f010069a:	83 ec 0c             	sub    $0xc,%esp
f010069d:	8b 46 08             	mov    0x8(%esi),%eax
f01006a0:	0f be 04 03          	movsbl (%ebx,%eax,1),%eax
f01006a4:	50                   	push   %eax
f01006a5:	e8 b3 ff ff ff       	call   f010065d <cputchar>
f01006aa:	83 c4 10             	add    $0x10,%esp
f01006ad:	43                   	inc    %ebx
f01006ae:	3b 5e 0c             	cmp    0xc(%esi),%ebx
f01006b1:	7c e7                	jl     f010069a <print_fun_name+0x12>
}
f01006b3:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f01006b6:	5b                   	pop    %ebx
f01006b7:	5e                   	pop    %esi
f01006b8:	c9                   	leave  
f01006b9:	c3                   	ret    

f01006ba <mon_help>:
/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006ba:	55                   	push   %ebp
f01006bb:	89 e5                	mov    %esp,%ebp
f01006bd:	53                   	push   %ebx
f01006be:	83 ec 04             	sub    $0x4,%esp
    int i;

    for (i = 0; i < NCOMMANDS; i++)
f01006c1:	bb 00 00 00 00       	mov    $0x0,%ebx
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006c6:	83 ec 04             	sub    $0x4,%esp
f01006c9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01006cc:	c1 e0 02             	shl    $0x2,%eax
f01006cf:	ff b0 44 d5 11 f0    	pushl  0xf011d544(%eax)
f01006d5:	ff b0 40 d5 11 f0    	pushl  0xf011d540(%eax)
f01006db:	68 c1 52 10 f0       	push   $0xf01052c1
f01006e0:	e8 8d 26 00 00       	call   f0102d72 <cprintf>
f01006e5:	83 c4 10             	add    $0x10,%esp
f01006e8:	43                   	inc    %ebx
f01006e9:	83 fb 02             	cmp    $0x2,%ebx
f01006ec:	76 d8                	jbe    f01006c6 <mon_help+0xc>
    return 0;
}
f01006ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f3:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01006f6:	c9                   	leave  
f01006f7:	c3                   	ret    

f01006f8 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006f8:	55                   	push   %ebp
f01006f9:	89 e5                	mov    %esp,%ebp
f01006fb:	83 ec 14             	sub    $0x14,%esp
    extern char _start[], etext[], edata[], end[];

    cprintf("Special kernel symbols:\n");
f01006fe:	68 ca 52 10 f0       	push   $0xf01052ca
f0100703:	e8 6a 26 00 00       	call   f0102d72 <cprintf>
    cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100708:	83 c4 0c             	add    $0xc,%esp
f010070b:	68 0c 00 10 00       	push   $0x10000c
f0100710:	68 0c 00 10 f0       	push   $0xf010000c
f0100715:	68 60 53 10 f0       	push   $0xf0105360
f010071a:	e8 53 26 00 00       	call   f0102d72 <cprintf>
    cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010071f:	83 c4 0c             	add    $0xc,%esp
f0100722:	68 fc 51 10 00       	push   $0x1051fc
f0100727:	68 fc 51 10 f0       	push   $0xf01051fc
f010072c:	68 84 53 10 f0       	push   $0xf0105384
f0100731:	e8 3c 26 00 00       	call   f0102d72 <cprintf>
    cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100736:	83 c4 0c             	add    $0xc,%esp
f0100739:	68 47 fc 1c 00       	push   $0x1cfc47
f010073e:	68 47 fc 1c f0       	push   $0xf01cfc47
f0100743:	68 a8 53 10 f0       	push   $0xf01053a8
f0100748:	e8 25 26 00 00       	call   f0102d72 <cprintf>
    cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010074d:	83 c4 0c             	add    $0xc,%esp
f0100750:	68 70 0b 1d 00       	push   $0x1d0b70
f0100755:	68 70 0b 1d f0       	push   $0xf01d0b70
f010075a:	68 cc 53 10 f0       	push   $0xf01053cc
f010075f:	e8 0e 26 00 00       	call   f0102d72 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
f0100764:	83 c4 08             	add    $0x8,%esp
f0100767:	b8 6f 0f 1d f0       	mov    $0xf01d0f6f,%eax
f010076c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100771:	79 05                	jns    f0100778 <mon_kerninfo+0x80>
f0100773:	05 ff 03 00 00       	add    $0x3ff,%eax
f0100778:	c1 f8 0a             	sar    $0xa,%eax
f010077b:	50                   	push   %eax
f010077c:	68 f0 53 10 f0       	push   $0xf01053f0
f0100781:	e8 ec 25 00 00       	call   f0102d72 <cprintf>
            (end-_start+1023)/1024);
    return 0;
}
f0100786:	b8 00 00 00 00       	mov    $0x0,%eax
f010078b:	c9                   	leave  
f010078c:	c3                   	ret    

f010078d <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010078d:	55                   	push   %ebp
f010078e:	89 e5                	mov    %esp,%ebp
f0100790:	57                   	push   %edi
f0100791:	56                   	push   %esi
f0100792:	53                   	push   %ebx
f0100793:	83 ec 38             	sub    $0x38,%esp
    // Your code here.
   void *ebp;
    void *eip;
    struct Eipdebuginfo info;
    cprintf("Stack backtrace:\n");
f0100796:	68 e3 52 10 f0       	push   $0xf01052e3
f010079b:	e8 d2 25 00 00       	call   f0102d72 <cprintf>
    eip = (void*) read_eip();
f01007a0:	e8 bb 01 00 00       	call   f0100960 <read_eip>
f01007a5:	89 c6                	mov    %eax,%esi
}

static __inline uint32_t
read_ebp(void)
{
f01007a7:	83 c4 10             	add    $0x10,%esp
f01007aa:	89 eb                	mov    %ebp,%ebx
    ebp = (void*) read_ebp();
    /*trace the stack until the ebp is zero*/
    do {
f01007ac:	8d 7d c8             	lea    0xffffffc8(%ebp),%edi
        debuginfo_eip((uintptr_t) eip, &info);
f01007af:	83 ec 08             	sub    $0x8,%esp
f01007b2:	57                   	push   %edi
f01007b3:	56                   	push   %esi
f01007b4:	e8 38 3c 00 00       	call   f01043f1 <debuginfo_eip>

        cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01007b9:	ff 73 18             	pushl  0x18(%ebx)
f01007bc:	ff 73 14             	pushl  0x14(%ebx)
f01007bf:	ff 73 10             	pushl  0x10(%ebx)
f01007c2:	ff 73 0c             	pushl  0xc(%ebx)
f01007c5:	ff 73 08             	pushl  0x8(%ebx)
f01007c8:	56                   	push   %esi
f01007c9:	53                   	push   %ebx
f01007ca:	68 1c 54 10 f0       	push   $0xf010541c
f01007cf:	e8 9e 25 00 00       	call   f0102d72 <cprintf>
                (uintptr_t) ebp, (uintptr_t) eip, *((uintptr_t *) ebp + 2),
                *((uintptr_t *) ebp + 3), *((uintptr_t *) ebp + 4),
                *((uintptr_t *) ebp + 5), *((uintptr_t *) ebp + 6));
        cprintf("%s:%d: ", info.eip_file, info.eip_line);
f01007d4:	83 c4 2c             	add    $0x2c,%esp
f01007d7:	ff 75 cc             	pushl  0xffffffcc(%ebp)
f01007da:	ff 75 c8             	pushl  0xffffffc8(%ebp)
f01007dd:	68 2b 52 10 f0       	push   $0xf010522b
f01007e2:	e8 8b 25 00 00       	call   f0102d72 <cprintf>
        print_fun_name(&info);
f01007e7:	89 3c 24             	mov    %edi,(%esp)
f01007ea:	e8 99 fe ff ff       	call   f0100688 <print_fun_name>
        cprintf("+%x\n", eip - info.eip_fn_addr);
f01007ef:	83 c4 08             	add    $0x8,%esp
f01007f2:	89 f0                	mov    %esi,%eax
f01007f4:	2b 45 d8             	sub    0xffffffd8(%ebp),%eax
f01007f7:	50                   	push   %eax
f01007f8:	68 f5 52 10 f0       	push   $0xf01052f5
f01007fd:	e8 70 25 00 00       	call   f0102d72 <cprintf>
        eip = *((void**) ebp + 1);
f0100802:	8b 73 04             	mov    0x4(%ebx),%esi
        ebp = *(void**) ebp;
f0100805:	8b 1b                	mov    (%ebx),%ebx
f0100807:	83 c4 10             	add    $0x10,%esp
    } while (ebp);
f010080a:	85 db                	test   %ebx,%ebx
f010080c:	75 a1                	jne    f01007af <mon_backtrace+0x22>
    return 0;
}
f010080e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100813:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100816:	5b                   	pop    %ebx
f0100817:	5e                   	pop    %esi
f0100818:	5f                   	pop    %edi
f0100819:	c9                   	leave  
f010081a:	c3                   	ret    

f010081b <runcmd>:



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
f010081b:	55                   	push   %ebp
f010081c:	89 e5                	mov    %esp,%ebp
f010081e:	57                   	push   %edi
f010081f:	56                   	push   %esi
f0100820:	53                   	push   %ebx
f0100821:	83 ec 4c             	sub    $0x4c,%esp
f0100824:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int argc;
    char *argv[MAXARGS];
    int i;

    // Parse the command buffer into whitespace-separated arguments
    argc = 0;
f0100827:	bf 00 00 00 00       	mov    $0x0,%edi
    argv[argc] = 0;
f010082c:	c7 45 a8 00 00 00 00 	movl   $0x0,0xffffffa8(%ebp)
    while (1) {
        // gobble whitespace
        while (*buf && strchr(WHITESPACE, *buf))
f0100833:	eb 04                	jmp    f0100839 <runcmd+0x1e>
            *buf++ = 0;
f0100835:	c6 03 00             	movb   $0x0,(%ebx)
f0100838:	43                   	inc    %ebx
f0100839:	80 3b 00             	cmpb   $0x0,(%ebx)
f010083c:	74 49                	je     f0100887 <runcmd+0x6c>
f010083e:	83 ec 08             	sub    $0x8,%esp
f0100841:	0f be 03             	movsbl (%ebx),%eax
f0100844:	50                   	push   %eax
f0100845:	68 fa 52 10 f0       	push   $0xf01052fa
f010084a:	e8 ab 44 00 00       	call   f0104cfa <strchr>
f010084f:	83 c4 10             	add    $0x10,%esp
f0100852:	85 c0                	test   %eax,%eax
f0100854:	75 df                	jne    f0100835 <runcmd+0x1a>
        if (*buf == 0)
f0100856:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100859:	74 2c                	je     f0100887 <runcmd+0x6c>
            break;

        // save and scan past next arg
        if (argc == MAXARGS-1) {
f010085b:	83 ff 0f             	cmp    $0xf,%edi
f010085e:	74 3a                	je     f010089a <runcmd+0x7f>
            cprintf("Too many arguments (max %d)\n", MAXARGS);
            return 0;
        }
        argv[argc++] = buf;
f0100860:	89 5c bd a8          	mov    %ebx,0xffffffa8(%ebp,%edi,4)
f0100864:	47                   	inc    %edi
        while (*buf && !strchr(WHITESPACE, *buf))
f0100865:	eb 01                	jmp    f0100868 <runcmd+0x4d>
            buf++;
f0100867:	43                   	inc    %ebx
f0100868:	80 3b 00             	cmpb   $0x0,(%ebx)
f010086b:	74 1a                	je     f0100887 <runcmd+0x6c>
f010086d:	83 ec 08             	sub    $0x8,%esp
f0100870:	0f be 03             	movsbl (%ebx),%eax
f0100873:	50                   	push   %eax
f0100874:	68 fa 52 10 f0       	push   $0xf01052fa
f0100879:	e8 7c 44 00 00       	call   f0104cfa <strchr>
f010087e:	83 c4 10             	add    $0x10,%esp
f0100881:	85 c0                	test   %eax,%eax
f0100883:	74 e2                	je     f0100867 <runcmd+0x4c>
f0100885:	eb b2                	jmp    f0100839 <runcmd+0x1e>
    }
    argv[argc] = 0;
f0100887:	c7 44 bd a8 00 00 00 	movl   $0x0,0xffffffa8(%ebp,%edi,4)
f010088e:	00 

    // Lookup and invoke the command
    if (argc == 0)
f010088f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100894:	85 ff                	test   %edi,%edi
f0100896:	74 63                	je     f01008fb <runcmd+0xe0>
f0100898:	eb 1f                	jmp    f01008b9 <runcmd+0x9e>
f010089a:	83 ec 08             	sub    $0x8,%esp
f010089d:	6a 10                	push   $0x10
f010089f:	68 ff 52 10 f0       	push   $0xf01052ff
f01008a4:	eb 4b                	jmp    f01008f1 <runcmd+0xd6>
        return 0;
    for (i = 0; i < NCOMMANDS; i++) {
        if (strcmp(argv[0], commands[i].name) == 0)
            return commands[i].func(argc, argv, tf);
f01008a6:	83 ec 04             	sub    $0x4,%esp
f01008a9:	ff 75 0c             	pushl  0xc(%ebp)
f01008ac:	8d 45 a8             	lea    0xffffffa8(%ebp),%eax
f01008af:	50                   	push   %eax
f01008b0:	57                   	push   %edi
f01008b1:	ff 96 48 d5 11 f0    	call   *0xf011d548(%esi)
f01008b7:	eb 42                	jmp    f01008fb <runcmd+0xe0>
f01008b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01008be:	83 ec 08             	sub    $0x8,%esp
f01008c1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008c4:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f01008cb:	ff b6 40 d5 11 f0    	pushl  0xf011d540(%esi)
f01008d1:	ff 75 a8             	pushl  0xffffffa8(%ebp)
f01008d4:	e8 b0 43 00 00       	call   f0104c89 <strcmp>
f01008d9:	83 c4 10             	add    $0x10,%esp
f01008dc:	85 c0                	test   %eax,%eax
f01008de:	74 c6                	je     f01008a6 <runcmd+0x8b>
f01008e0:	43                   	inc    %ebx
f01008e1:	83 fb 02             	cmp    $0x2,%ebx
f01008e4:	76 d8                	jbe    f01008be <runcmd+0xa3>
    }
    cprintf("Unknown command '%s'\n", argv[0]);
f01008e6:	83 ec 08             	sub    $0x8,%esp
f01008e9:	ff 75 a8             	pushl  0xffffffa8(%ebp)
f01008ec:	68 1c 53 10 f0       	push   $0xf010531c
f01008f1:	e8 7c 24 00 00       	call   f0102d72 <cprintf>
    return 0;
f01008f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01008fb:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01008fe:	5b                   	pop    %ebx
f01008ff:	5e                   	pop    %esi
f0100900:	5f                   	pop    %edi
f0100901:	c9                   	leave  
f0100902:	c3                   	ret    

f0100903 <monitor>:

void
monitor(struct Trapframe *tf)
{
f0100903:	55                   	push   %ebp
f0100904:	89 e5                	mov    %esp,%ebp
f0100906:	53                   	push   %ebx
f0100907:	83 ec 10             	sub    $0x10,%esp
f010090a:	8b 5d 08             	mov    0x8(%ebp),%ebx
    char *buf;

    cprintf("Welcome to the JOS kernel monitor!\n");
f010090d:	68 50 54 10 f0       	push   $0xf0105450
f0100912:	e8 5b 24 00 00       	call   f0102d72 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
f0100917:	c7 04 24 74 54 10 f0 	movl   $0xf0105474,(%esp)
f010091e:	e8 4f 24 00 00       	call   f0102d72 <cprintf>

    if (tf != NULL)
f0100923:	83 c4 10             	add    $0x10,%esp
f0100926:	85 db                	test   %ebx,%ebx
f0100928:	74 0c                	je     f0100936 <monitor+0x33>
        print_trapframe(tf);
f010092a:	83 ec 0c             	sub    $0xc,%esp
f010092d:	53                   	push   %ebx
f010092e:	e8 b2 2b 00 00       	call   f01034e5 <print_trapframe>
f0100933:	83 c4 10             	add    $0x10,%esp

    while (1) {
        buf = readline("K> ");
f0100936:	83 ec 0c             	sub    $0xc,%esp
f0100939:	68 32 53 10 f0       	push   $0xf0105332
f010093e:	e8 c1 41 00 00       	call   f0104b04 <readline>
        if (buf != NULL)
f0100943:	83 c4 10             	add    $0x10,%esp
f0100946:	85 c0                	test   %eax,%eax
f0100948:	74 ec                	je     f0100936 <monitor+0x33>
            if (runcmd(buf, tf) < 0)
f010094a:	83 ec 08             	sub    $0x8,%esp
f010094d:	53                   	push   %ebx
f010094e:	50                   	push   %eax
f010094f:	e8 c7 fe ff ff       	call   f010081b <runcmd>
f0100954:	83 c4 10             	add    $0x10,%esp
f0100957:	85 c0                	test   %eax,%eax
f0100959:	79 db                	jns    f0100936 <monitor+0x33>
                break;
    }
}
f010095b:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010095e:	c9                   	leave  
f010095f:	c3                   	ret    

f0100960 <read_eip>:

// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100960:	55                   	push   %ebp
f0100961:	89 e5                	mov    %esp,%ebp
    uint32_t callerpc;
    __asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100963:	8b 45 04             	mov    0x4(%ebp),%eax
    return callerpc;
}
f0100966:	c9                   	leave  
f0100967:	c3                   	ret    

f0100968 <nvram_read>:
    sizeof (gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r) {
f0100968:	55                   	push   %ebp
f0100969:	89 e5                	mov    %esp,%ebp
f010096b:	56                   	push   %esi
f010096c:	53                   	push   %ebx
f010096d:	8b 5d 08             	mov    0x8(%ebp),%ebx
    return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100970:	83 ec 0c             	sub    $0xc,%esp
f0100973:	53                   	push   %ebx
f0100974:	e8 53 22 00 00       	call   f0102bcc <mc146818_read>
f0100979:	89 c6                	mov    %eax,%esi
f010097b:	43                   	inc    %ebx
f010097c:	89 1c 24             	mov    %ebx,(%esp)
f010097f:	e8 48 22 00 00       	call   f0102bcc <mc146818_read>
f0100984:	c1 e0 08             	shl    $0x8,%eax
f0100987:	09 c6                	or     %eax,%esi
}
f0100989:	89 f0                	mov    %esi,%eax
f010098b:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f010098e:	5b                   	pop    %ebx
f010098f:	5e                   	pop    %esi
f0100990:	c9                   	leave  
f0100991:	c3                   	ret    

f0100992 <i386_detect_memory>:

void
i386_detect_memory(void) {
f0100992:	55                   	push   %ebp
f0100993:	89 e5                	mov    %esp,%ebp
f0100995:	83 ec 14             	sub    $0x14,%esp
    // CMOS tells us how many kilobytes there are
    basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0100998:	6a 15                	push   $0x15
f010099a:	e8 c9 ff ff ff       	call   f0100968 <nvram_read>
f010099f:	c1 e0 0a             	shl    $0xa,%eax
f01009a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009a7:	a3 ac fe 1c f0       	mov    %eax,0xf01cfeac
    extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f01009ac:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01009b3:	e8 b0 ff ff ff       	call   f0100968 <nvram_read>
f01009b8:	83 c4 10             	add    $0x10,%esp
f01009bb:	c1 e0 0a             	shl    $0xa,%eax
f01009be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009c3:	a3 b0 fe 1c f0       	mov    %eax,0xf01cfeb0

    // Calculate the maximum physical address based on whether
    // or not there is any extended memory.  See comment in <inc/mmu.h>.
    if (extmem)
f01009c8:	85 c0                	test   %eax,%eax
f01009ca:	74 07                	je     f01009d3 <i386_detect_memory+0x41>
        maxpa = EXTPHYSMEM + extmem;
f01009cc:	05 00 00 10 00       	add    $0x100000,%eax
f01009d1:	eb 05                	jmp    f01009d8 <i386_detect_memory+0x46>
    else
        maxpa = basemem;
f01009d3:	a1 ac fe 1c f0       	mov    0xf01cfeac,%eax
f01009d8:	a3 a8 fe 1c f0       	mov    %eax,0xf01cfea8

    npage = maxpa / PGSIZE;
f01009dd:	a1 a8 fe 1c f0       	mov    0xf01cfea8,%eax
f01009e2:	89 c2                	mov    %eax,%edx
f01009e4:	c1 ea 0c             	shr    $0xc,%edx
f01009e7:	89 15 60 0b 1d f0    	mov    %edx,0xf01d0b60

    cprintf("Physical memory: %dK available, ", (int) (maxpa / 1024));
f01009ed:	83 ec 08             	sub    $0x8,%esp
f01009f0:	c1 e8 0a             	shr    $0xa,%eax
f01009f3:	50                   	push   %eax
f01009f4:	68 9c 54 10 f0       	push   $0xf010549c
f01009f9:	e8 74 23 00 00       	call   f0102d72 <cprintf>
    cprintf("base = %dK, extended = %dK\n", (int) (basemem / 1024), (int) (extmem / 1024));
f01009fe:	83 c4 0c             	add    $0xc,%esp
f0100a01:	a1 b0 fe 1c f0       	mov    0xf01cfeb0,%eax
f0100a06:	c1 e8 0a             	shr    $0xa,%eax
f0100a09:	50                   	push   %eax
f0100a0a:	a1 ac fe 1c f0       	mov    0xf01cfeac,%eax
f0100a0f:	c1 e8 0a             	shr    $0xa,%eax
f0100a12:	50                   	push   %eax
f0100a13:	68 2a 5a 10 f0       	push   $0xf0105a2a
f0100a18:	e8 55 23 00 00       	call   f0102d72 <cprintf>
}
f0100a1d:	c9                   	leave  
f0100a1e:	c3                   	ret    

f0100a1f <boot_alloc>:

// --------------------------------------------------------------
// Set up initial memory mappings and turn on MMU.
// --------------------------------------------------------------

static void check_boot_pgdir(void);
static void check_page_alloc();
static void page_check(void);
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm);

//
// A simple physical memory allocator, used only a few times
// in the process of setting up the virtual memory system.
// page_alloc() is the real allocator.
//
// Allocate n bytes of physical memory aligned on an
// align-byte boundary.  Align must be a power of two.
// Return kernel virtual address.  Returned memory is uninitialized.
//
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
//

static void*
boot_alloc(uint32_t n, uint32_t align) {
f0100a1f:	55                   	push   %ebp
f0100a20:	89 e5                	mov    %esp,%ebp
f0100a22:	57                   	push   %edi
f0100a23:	56                   	push   %esi
f0100a24:	53                   	push   %ebx
f0100a25:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    extern char end[];
    void *v;

    // Initialize boot_freemem if this is the first time.
    // 'end' is a magic symbol automatically generated by the linker,
    // which points to the end of the kernel's bss segment -
    // i.e., the first virtual address that the linker
    // did _not_ assign to any kernel code or global variables.
    if (boot_freemem == 0)
f0100a2b:	83 3d b4 fe 1c f0 00 	cmpl   $0x0,0xf01cfeb4
f0100a32:	75 0a                	jne    f0100a3e <boot_alloc+0x1f>
        boot_freemem = end;
f0100a34:	c7 05 b4 fe 1c f0 70 	movl   $0xf01d0b70,0xf01cfeb4
f0100a3b:	0b 1d f0 

    // LAB 2: Your code here:
    //	Step 1: round boot_freemem up to be aligned properly
    boot_freemem = ROUNDUP(boot_freemem, align);
f0100a3e:	89 df                	mov    %ebx,%edi
f0100a40:	03 3d b4 fe 1c f0    	add    0xf01cfeb4,%edi
f0100a46:	4f                   	dec    %edi
f0100a47:	89 f8                	mov    %edi,%eax
f0100a49:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a4e:	f7 f3                	div    %ebx
f0100a50:	29 d7                	sub    %edx,%edi
    //	Step 2: save current value of boot_freemem as allocated chunk
    //	Step 3: increase boot_freemem to record allocation
    n = ROUNDUP(n, align);
f0100a52:	8d 74 33 ff          	lea    0xffffffff(%ebx,%esi,1),%esi
f0100a56:	89 f0                	mov    %esi,%eax
f0100a58:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a5d:	f7 f3                	div    %ebx
f0100a5f:	29 d6                	sub    %edx,%esi
    v = (void*) boot_freemem;
    boot_freemem = boot_freemem + n;
f0100a61:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0100a64:	89 15 b4 fe 1c f0    	mov    %edx,0xf01cfeb4
    //	Step 4: return allocated chunk

    return v;
}
f0100a6a:	89 f8                	mov    %edi,%eax
f0100a6c:	5b                   	pop    %ebx
f0100a6d:	5e                   	pop    %esi
f0100a6e:	5f                   	pop    %edi
f0100a6f:	c9                   	leave  
f0100a70:	c3                   	ret    

f0100a71 <i386_vm_init>:

// Set up a two-level page table:
//    boot_pgdir is its linear (virtual) address of the root
//    boot_cr3 is the physical adresss of the root
// Then turn on paging.  Then effectively turn off segmentation.
// (i.e., the segment base addrs are set to zero).
//
// This function only sets up the kernel part of the address space
// (ie. addresses >= UTOP).  The user part of the address space
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write).

void
i386_vm_init(void) {
f0100a71:	55                   	push   %ebp
f0100a72:	89 e5                	mov    %esp,%ebp
f0100a74:	53                   	push   %ebx
f0100a75:	83 ec 0c             	sub    $0xc,%esp
    pde_t* pgdir;
    uint32_t cr0;
    size_t n;

    // Delete this line:
    //panic("i386_vm_init: This function is not finished\n");

    //////////////////////////////////////////////////////////////////////
    // create initial page directory.
    pgdir = boot_alloc(PGSIZE, PGSIZE);
f0100a78:	68 00 10 00 00       	push   $0x1000
f0100a7d:	68 00 10 00 00       	push   $0x1000
f0100a82:	e8 98 ff ff ff       	call   f0100a1f <boot_alloc>
f0100a87:	89 c3                	mov    %eax,%ebx
    memset(pgdir, 0, PGSIZE);
f0100a89:	83 c4 0c             	add    $0xc,%esp
f0100a8c:	68 00 10 00 00       	push   $0x1000
f0100a91:	6a 00                	push   $0x0
f0100a93:	50                   	push   %eax
f0100a94:	e8 9a 42 00 00       	call   f0104d33 <memset>
    boot_pgdir = pgdir;
f0100a99:	89 1d 68 0b 1d f0    	mov    %ebx,0xf01d0b68
    boot_cr3 = PADDR(pgdir);
f0100a9f:	83 c4 10             	add    $0x10,%esp
f0100aa2:	89 d8                	mov    %ebx,%eax
f0100aa4:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100aaa:	77 10                	ja     f0100abc <i386_vm_init+0x4b>
f0100aac:	53                   	push   %ebx
f0100aad:	68 c0 54 10 f0       	push   $0xf01054c0
f0100ab2:	68 9d 00 00 00       	push   $0x9d
f0100ab7:	e9 31 01 00 00       	jmp    f0100bed <i386_vm_init+0x17c>
f0100abc:	05 00 00 00 10       	add    $0x10000000,%eax
f0100ac1:	a3 64 0b 1d f0       	mov    %eax,0xf01d0b64
    /*
        uint32_t v = 0;
        uint32_t bit = 0x8;
        cpuid(1, NULL, NULL, NULL, &v); //read info about cpu
        if (v & bit)
            pg_altable = 1;
     */
    //////////////////////////////////////////////////////////////////////
    // Recursively insert PD in itself as a page table, to form
    // a virtual page table at virtual address VPT.
    // (For now, you don't have understand the greater purpose of the
    // following two lines.)

    // Permissions: kernel RW, user NONE
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_W | PTE_P;
f0100ac6:	89 d8                	mov    %ebx,%eax
f0100ac8:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100ace:	77 10                	ja     f0100ae0 <i386_vm_init+0x6f>
f0100ad0:	53                   	push   %ebx
f0100ad1:	68 c0 54 10 f0       	push   $0xf01054c0
f0100ad6:	68 ac 00 00 00       	push   $0xac
f0100adb:	e9 0d 01 00 00       	jmp    f0100bed <i386_vm_init+0x17c>
f0100ae0:	05 00 00 00 10       	add    $0x10000000,%eax
f0100ae5:	83 c8 03             	or     $0x3,%eax
f0100ae8:	89 83 fc 0e 00 00    	mov    %eax,0xefc(%ebx)

    // same for UVPT
    // Permissions: kernel R, user R
    pgdir[PDX(UVPT)] = PADDR(pgdir) | PTE_U | PTE_P;
f0100aee:	89 d8                	mov    %ebx,%eax
f0100af0:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100af6:	77 10                	ja     f0100b08 <i386_vm_init+0x97>
f0100af8:	53                   	push   %ebx
f0100af9:	68 c0 54 10 f0       	push   $0xf01054c0
f0100afe:	68 b0 00 00 00       	push   $0xb0
f0100b03:	e9 e5 00 00 00       	jmp    f0100bed <i386_vm_init+0x17c>
f0100b08:	05 00 00 00 10       	add    $0x10000000,%eax
f0100b0d:	83 c8 05             	or     $0x5,%eax
f0100b10:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)

    //////////////////////////////////////////////////////////////////////
    // Make 'pages' point to an array of size 'npage' of 'struct Page'.
    // The kernel uses this structure to keep track of physical pages;
    // 'npage' equals the number of physical pages in memory.  User-level
    // programs will get read-only access to the array as well.
    // You must allocate the array yourself.
    // Your code goes here:

    pages = boot_alloc(npage * sizeof (struct Page), PGSIZE);
f0100b16:	83 ec 08             	sub    $0x8,%esp
f0100b19:	68 00 10 00 00       	push   $0x1000
f0100b1e:	a1 60 0b 1d f0       	mov    0xf01d0b60,%eax
f0100b23:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b26:	c1 e0 02             	shl    $0x2,%eax
f0100b29:	50                   	push   %eax
f0100b2a:	e8 f0 fe ff ff       	call   f0100a1f <boot_alloc>
f0100b2f:	a3 6c 0b 1d f0       	mov    %eax,0xf01d0b6c
    /*Make 'pages' point to an array of size 'npage' of 'struct Page'.*/

    //////////////////////////////////////////////////////////////////////
    // Make 'envs' point to an array of size 'NENV' of 'struct Env'.
    // LAB 3: Your code here.
    envs = boot_alloc(NENV * sizeof (struct Env), PGSIZE);
f0100b34:	83 c4 08             	add    $0x8,%esp
f0100b37:	68 00 10 00 00       	push   $0x1000
f0100b3c:	68 00 00 02 00       	push   $0x20000
f0100b41:	e8 d9 fe ff ff       	call   f0100a1f <boot_alloc>
f0100b46:	a3 c0 fe 1c f0       	mov    %eax,0xf01cfec0
    //////////////////////////////////////////////////////////////////////
    // Now that we've allocated the initial kernel data structures, we set
    // up the list of free physical pages. Once we've done so, all further
    // memory management will go through the page_* functions. In
    // particular, we can now map memory using boot_map_segment or page_insert
    page_init();
f0100b4b:	e8 ad 07 00 00       	call   f01012fd <page_init>

    check_page_alloc();
f0100b50:	e8 37 01 00 00       	call   f0100c8c <check_page_alloc>

    page_check();
f0100b55:	e8 cb 0d 00 00       	call   f0101925 <page_check>

    //////////////////////////////////////////////////////////////////////
    // Now we set up virtual memory

    //////////////////////////////////////////////////////////////////////
    // Map 'pages' read-only by the user at linear address UPAGES
    // (ie. perm = PTE_U | PTE_P)
    // Permissions:
    //    - the new image at UPAGES -- kernel R, user R
    //    - pages itself -- kernel RW, user NONE
    // Your code goes here:
    /*    if (pg_altable) {
            uint32_t cr4;
            cr4 = rcr4();
            cr4 |= CR4_PSE;
            lcr4(cr4);
        }*/
    boot_map_segment(pgdir, UPAGES, npage * sizeof (struct Page), PADDR(pages), PTE_U | PTE_P);
f0100b5a:	83 c4 10             	add    $0x10,%esp
f0100b5d:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f0100b62:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b67:	77 0d                	ja     f0100b76 <i386_vm_init+0x105>
f0100b69:	50                   	push   %eax
f0100b6a:	68 c0 54 10 f0       	push   $0xf01054c0
f0100b6f:	68 dc 00 00 00       	push   $0xdc
f0100b74:	eb 77                	jmp    f0100bed <i386_vm_init+0x17c>
f0100b76:	05 00 00 00 10       	add    $0x10000000,%eax
f0100b7b:	83 ec 0c             	sub    $0xc,%esp
f0100b7e:	6a 05                	push   $0x5
f0100b80:	50                   	push   %eax
f0100b81:	a1 60 0b 1d f0       	mov    0xf01d0b60,%eax
f0100b86:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b89:	c1 e0 02             	shl    $0x2,%eax
f0100b8c:	50                   	push   %eax
f0100b8d:	68 00 00 00 ef       	push   $0xef000000
f0100b92:	53                   	push   %ebx
f0100b93:	e8 8f 0b 00 00       	call   f0101727 <boot_map_segment>
    /*map the read-only copy of the page structures*/

    //////////////////////////////////////////////////////////////////////
    // Map the 'envs' array read-only by the user at linear address UENVS
    // (ie. perm = PTE_U | PTE_P).
    // Permissions:
    //    - the new image at UENVS  -- kernel R, user R
    //    - envs itself -- kernel RW, user NONE

    boot_map_segment(pgdir, UENVS, npage * sizeof (struct Env), PADDR(envs), PTE_U | PTE_P);
f0100b98:	83 c4 20             	add    $0x20,%esp
f0100b9b:	a1 c0 fe 1c f0       	mov    0xf01cfec0,%eax
f0100ba0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ba5:	77 0d                	ja     f0100bb4 <i386_vm_init+0x143>
f0100ba7:	50                   	push   %eax
f0100ba8:	68 c0 54 10 f0       	push   $0xf01054c0
f0100bad:	68 e6 00 00 00       	push   $0xe6
f0100bb2:	eb 39                	jmp    f0100bed <i386_vm_init+0x17c>
f0100bb4:	05 00 00 00 10       	add    $0x10000000,%eax
f0100bb9:	83 ec 0c             	sub    $0xc,%esp
f0100bbc:	6a 05                	push   $0x5
f0100bbe:	50                   	push   %eax
f0100bbf:	a1 60 0b 1d f0       	mov    0xf01d0b60,%eax
f0100bc4:	c1 e0 07             	shl    $0x7,%eax
f0100bc7:	50                   	push   %eax
f0100bc8:	68 00 00 c0 ee       	push   $0xeec00000
f0100bcd:	53                   	push   %ebx
f0100bce:	e8 54 0b 00 00       	call   f0101727 <boot_map_segment>
    //////////////////////////////////////////////////////////////////////
    // Use the physical memory that bootstack refers to as
    // the kernel stack.  The complete VA
    // range of the stack, [KSTACKTOP-PTSIZE, KSTACKTOP), breaks into two
    // pieces:
    //     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
    //     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed => faults
    //     Permissions: kernel RW, user NONE
    // Your code goes here:
    boot_map_segment(pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0100bd3:	83 c4 20             	add    $0x20,%esp
f0100bd6:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f0100bdb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100be0:	77 15                	ja     f0100bf7 <i386_vm_init+0x186>
f0100be2:	50                   	push   %eax
f0100be3:	68 c0 54 10 f0       	push   $0xf01054c0
f0100be8:	68 f0 00 00 00       	push   $0xf0
f0100bed:	68 46 5a 10 f0       	push   $0xf0105a46
f0100bf2:	e8 ed f4 ff ff       	call   f01000e4 <_panic>
f0100bf7:	05 00 00 00 10       	add    $0x10000000,%eax
f0100bfc:	83 ec 0c             	sub    $0xc,%esp
f0100bff:	6a 03                	push   $0x3
f0100c01:	50                   	push   %eax
f0100c02:	68 00 80 00 00       	push   $0x8000
f0100c07:	68 00 80 bf ef       	push   $0xefbf8000
f0100c0c:	53                   	push   %ebx
f0100c0d:	e8 15 0b 00 00       	call   f0101727 <boot_map_segment>
    //////////////////////////////////////////////////////////////////////
    // Map all of physical memory at KERNBASE.
    // Ie.  the VA range [KERNBASE, 2^32) should map to
    //      the PA range [0, 2^32 - KERNBASE)
    // We might not have 2^32 - KERNBASE bytes of physical memory, but
    // we just set up the amapping anyway.
    // Permissions: kernel RW, user NONE
    // Your code goes here:
    boot_map_segment(pgdir, KERNBASE, 0xFFFFFFFF - KERNBASE, 0, PTE_W | PTE_P);
f0100c12:	83 c4 14             	add    $0x14,%esp
f0100c15:	6a 03                	push   $0x3
f0100c17:	6a 00                	push   $0x0
f0100c19:	68 ff ff ff 0f       	push   $0xfffffff
f0100c1e:	68 00 00 00 f0       	push   $0xf0000000
f0100c23:	53                   	push   %ebx
f0100c24:	e8 fe 0a 00 00       	call   f0101727 <boot_map_segment>
    /*map the kernel space which starts physically from 0 to the virtual space from kernel base*/

    // Check that the initial page directory has been set up correctly.
    check_boot_pgdir();
f0100c29:	83 c4 20             	add    $0x20,%esp
f0100c2c:	e8 49 04 00 00       	call   f010107a <check_boot_pgdir>

    //////////////////////////////////////////////////////////////////////
    // On x86, segmentation maps a VA to a LA (linear addr) and
    // paging maps the LA to a PA.  I.e. VA => LA => PA.  If paging is
    // turned off the LA is used as the PA.  Note: there is no way to
    // turn off segmentation.  The closest thing is to set the base
    // address to 0, so the VA => LA mapping is the identity.

    // Current mapping: VA KERNBASE+x => PA x.
    //     (segmentation base=-KERNBASE and paging is off)

    // From here on down we must maintain this VA KERNBASE + x => PA x
    // mapping, even though we are turning on paging and reconfiguring
    // segmentation.

    // Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
    // (Limits our kernel to <4MB)
    pgdir[0] = pgdir[PDX(KERNBASE)];
f0100c31:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f0100c37:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
f0100c39:	a1 64 0b 1d f0       	mov    0xf01d0b64,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100c3e:	0f 22 d8             	mov    %eax,%cr3
f0100c41:	0f 20 c0             	mov    %cr0,%eax

    // Install page table.
    lcr3(boot_cr3);

    // Turn on paging.
    cr0 = rcr0();
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
f0100c44:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32_t val)
{
f0100c49:	83 e0 f3             	and    $0xfffffff3,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0100c4c:	0f 22 c0             	mov    %eax,%cr0
    cr0 &= ~(CR0_TS | CR0_EM);
    lcr0(cr0);

    // Current mapping: KERNBASE+x => x => x.
    // (x < 4MB so uses paging pgdir[0])

    // Reload all segment registers.
    asm volatile("lgdt gdt_pd");
f0100c4f:	0f 01 15 b0 d5 11 f0 	lgdtl  0xf011d5b0
    asm volatile("movw %%ax,%%gs" ::"a" (GD_UD | 3));
f0100c56:	b8 23 00 00 00       	mov    $0x23,%eax
f0100c5b:	8e e8                	mov    %eax,%gs
    asm volatile("movw %%ax,%%fs" ::"a" (GD_UD | 3));
f0100c5d:	8e e0                	mov    %eax,%fs
    asm volatile("movw %%ax,%%es" ::"a" (GD_KD));
f0100c5f:	b8 10 00 00 00       	mov    $0x10,%eax
f0100c64:	8e c0                	mov    %eax,%es
    asm volatile("movw %%ax,%%ds" ::"a" (GD_KD));
f0100c66:	8e d8                	mov    %eax,%ds
    asm volatile("movw %%ax,%%ss" ::"a" (GD_KD));
f0100c68:	8e d0                	mov    %eax,%ss
    asm volatile("ljmp %0,$1f\n 1:\n" ::"i" (GD_KT)); // reload cs
f0100c6a:	ea 71 0c 10 f0 08 00 	ljmp   $0x8,$0xf0100c71
    asm volatile("lldt %%ax" ::"a" (0));
f0100c71:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c76:	0f 00 d0             	lldt   %ax

    // Final mapping: KERNBASE+x => KERNBASE+x => x.

    // This mapping was only used after paging was turned on but
    // before the segment registers were reloaded.
    pgdir[0] = 0;
f0100c79:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
f0100c7f:	a1 64 0b 1d f0       	mov    0xf01d0b64,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100c84:	0f 22 d8             	mov    %eax,%cr3

    // Flush the TLB for good measure, to kill the pgdir[0] mapping.
    lcr3(boot_cr3);
}
f0100c87:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100c8a:	c9                   	leave  
f0100c8b:	c3                   	ret    

f0100c8c <check_page_alloc>:

//
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//

static void
check_page_alloc() {
f0100c8c:	55                   	push   %ebp
f0100c8d:	89 e5                	mov    %esp,%ebp
f0100c8f:	53                   	push   %ebx
f0100c90:	83 ec 14             	sub    $0x14,%esp
    struct Page *pp, *pp0, *pp1, *pp2;
    struct Page_list fl;

    // if there's a page that shouldn't be on
    // the free list, try to make sure it
    // eventually causes trouble.
    LIST_FOREACH(pp0, &page_free_list, pp_link)
f0100c93:	a1 b8 fe 1c f0       	mov    0xf01cfeb8,%eax
f0100c98:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
f0100c9b:	85 c0                	test   %eax,%eax
f0100c9d:	74 72                	je     f0100d11 <check_page_alloc+0x85>

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100c9f:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
f0100ca2:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0100ca8:	c1 fa 02             	sar    $0x2,%edx
f0100cab:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100cae:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100cb1:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100cb4:	89 c1                	mov    %eax,%ecx
f0100cb6:	c1 e1 08             	shl    $0x8,%ecx
f0100cb9:	01 c8                	add    %ecx,%eax
f0100cbb:	89 c1                	mov    %eax,%ecx
f0100cbd:	c1 e1 10             	shl    $0x10,%ecx
f0100cc0:	01 c8                	add    %ecx,%eax
f0100cc2:	8d 04 42             	lea    (%edx,%eax,2),%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0100cc5:	89 c2                	mov    %eax,%edx
f0100cc7:	c1 e2 0c             	shl    $0xc,%edx
	return page2ppn(pp) << PGSHIFT;
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
		panic("pa2page called with invalid pa");
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0100cca:	89 d0                	mov    %edx,%eax
f0100ccc:	c1 e8 0c             	shr    $0xc,%eax
f0100ccf:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f0100cd5:	72 12                	jb     f0100ce9 <check_page_alloc+0x5d>
f0100cd7:	52                   	push   %edx
f0100cd8:	68 e4 54 10 f0       	push   $0xf01054e4
f0100cdd:	6a 5a                	push   $0x5a
f0100cdf:	68 52 5a 10 f0       	push   $0xf0105a52
f0100ce4:	e9 54 03 00 00       	jmp    f010103d <check_page_alloc+0x3b1>
f0100ce9:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0100cef:	83 ec 04             	sub    $0x4,%esp
f0100cf2:	68 80 00 00 00       	push   $0x80
f0100cf7:	68 97 00 00 00       	push   $0x97
f0100cfc:	50                   	push   %eax
f0100cfd:	e8 31 40 00 00       	call   f0104d33 <memset>
f0100d02:	83 c4 10             	add    $0x10,%esp
f0100d05:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f0100d08:	8b 00                	mov    (%eax),%eax
f0100d0a:	89 45 f8             	mov    %eax,0xfffffff8(%ebp)
f0100d0d:	85 c0                	test   %eax,%eax
f0100d0f:	75 8e                	jne    f0100c9f <check_page_alloc+0x13>
    memset(page2kva(pp0), 0x97, 128);

    // should be able to allocate three pages
    pp0 = pp1 = pp2 = 0;
f0100d11:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0100d18:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
f0100d1f:	c7 45 f8 00 00 00 00 	movl   $0x0,0xfffffff8(%ebp)
    assert(page_alloc(&pp0) == 0);
f0100d26:	83 ec 0c             	sub    $0xc,%esp
f0100d29:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f0100d2c:	50                   	push   %eax
f0100d2d:	e8 49 07 00 00       	call   f010147b <page_alloc>
f0100d32:	83 c4 10             	add    $0x10,%esp
f0100d35:	85 c0                	test   %eax,%eax
f0100d37:	74 14                	je     f0100d4d <check_page_alloc+0xc1>
f0100d39:	68 5e 5a 10 f0       	push   $0xf0105a5e
f0100d3e:	68 74 5a 10 f0       	push   $0xf0105a74
f0100d43:	68 43 01 00 00       	push   $0x143
f0100d48:	e9 eb 02 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(page_alloc(&pp1) == 0);
f0100d4d:	83 ec 0c             	sub    $0xc,%esp
f0100d50:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0100d53:	50                   	push   %eax
f0100d54:	e8 22 07 00 00       	call   f010147b <page_alloc>
f0100d59:	83 c4 10             	add    $0x10,%esp
f0100d5c:	85 c0                	test   %eax,%eax
f0100d5e:	74 14                	je     f0100d74 <check_page_alloc+0xe8>
f0100d60:	68 89 5a 10 f0       	push   $0xf0105a89
f0100d65:	68 74 5a 10 f0       	push   $0xf0105a74
f0100d6a:	68 44 01 00 00       	push   $0x144
f0100d6f:	e9 c4 02 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(page_alloc(&pp2) == 0);
f0100d74:	83 ec 0c             	sub    $0xc,%esp
f0100d77:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0100d7a:	50                   	push   %eax
f0100d7b:	e8 fb 06 00 00       	call   f010147b <page_alloc>
f0100d80:	83 c4 10             	add    $0x10,%esp
f0100d83:	85 c0                	test   %eax,%eax
f0100d85:	74 14                	je     f0100d9b <check_page_alloc+0x10f>
f0100d87:	68 9f 5a 10 f0       	push   $0xf0105a9f
f0100d8c:	68 74 5a 10 f0       	push   $0xf0105a74
f0100d91:	68 45 01 00 00       	push   $0x145
f0100d96:	e9 9d 02 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>

    assert(pp0);
f0100d9b:	83 7d f8 00          	cmpl   $0x0,0xfffffff8(%ebp)
f0100d9f:	75 14                	jne    f0100db5 <check_page_alloc+0x129>
f0100da1:	68 c3 5a 10 f0       	push   $0xf0105ac3
f0100da6:	68 74 5a 10 f0       	push   $0xf0105a74
f0100dab:	68 47 01 00 00       	push   $0x147
f0100db0:	e9 83 02 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(pp1 && pp1 != pp0);
f0100db5:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f0100db9:	74 08                	je     f0100dc3 <check_page_alloc+0x137>
f0100dbb:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100dbe:	3b 45 f8             	cmp    0xfffffff8(%ebp),%eax
f0100dc1:	75 14                	jne    f0100dd7 <check_page_alloc+0x14b>
f0100dc3:	68 b5 5a 10 f0       	push   $0xf0105ab5
f0100dc8:	68 74 5a 10 f0       	push   $0xf0105a74
f0100dcd:	68 48 01 00 00       	push   $0x148
f0100dd2:	e9 61 02 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0100dd7:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0100ddb:	74 0d                	je     f0100dea <check_page_alloc+0x15e>
f0100ddd:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0100de0:	3b 45 f4             	cmp    0xfffffff4(%ebp),%eax
f0100de3:	74 05                	je     f0100dea <check_page_alloc+0x15e>
f0100de5:	3b 45 f8             	cmp    0xfffffff8(%ebp),%eax
f0100de8:	75 14                	jne    f0100dfe <check_page_alloc+0x172>
f0100dea:	68 08 55 10 f0       	push   $0xf0105508
f0100def:	68 74 5a 10 f0       	push   $0xf0105a74
f0100df4:	68 49 01 00 00       	push   $0x149
f0100df9:	e9 3a 02 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100dfe:	8b 55 f8             	mov    0xfffffff8(%ebp),%edx
f0100e01:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0100e07:	c1 fa 02             	sar    $0x2,%edx
f0100e0a:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100e0d:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100e10:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100e13:	89 c1                	mov    %eax,%ecx
f0100e15:	c1 e1 08             	shl    $0x8,%ecx
f0100e18:	01 c8                	add    %ecx,%eax
f0100e1a:	89 c1                	mov    %eax,%ecx
f0100e1c:	c1 e1 10             	shl    $0x10,%ecx
f0100e1f:	01 c8                	add    %ecx,%eax
f0100e21:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0100e24:	c1 e0 0c             	shl    $0xc,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0100e27:	8b 15 60 0b 1d f0    	mov    0xf01d0b60,%edx
f0100e2d:	c1 e2 0c             	shl    $0xc,%edx
f0100e30:	39 d0                	cmp    %edx,%eax
f0100e32:	72 14                	jb     f0100e48 <check_page_alloc+0x1bc>
    assert(page2pa(pp0) < npage * PGSIZE);
f0100e34:	68 c7 5a 10 f0       	push   $0xf0105ac7
f0100e39:	68 74 5a 10 f0       	push   $0xf0105a74
f0100e3e:	68 4a 01 00 00       	push   $0x14a
f0100e43:	e9 f0 01 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100e48:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0100e4b:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0100e51:	c1 fa 02             	sar    $0x2,%edx
f0100e54:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100e57:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100e5a:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100e5d:	89 c1                	mov    %eax,%ecx
f0100e5f:	c1 e1 08             	shl    $0x8,%ecx
f0100e62:	01 c8                	add    %ecx,%eax
f0100e64:	89 c1                	mov    %eax,%ecx
f0100e66:	c1 e1 10             	shl    $0x10,%ecx
f0100e69:	01 c8                	add    %ecx,%eax
f0100e6b:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0100e6e:	c1 e0 0c             	shl    $0xc,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0100e71:	8b 15 60 0b 1d f0    	mov    0xf01d0b60,%edx
f0100e77:	c1 e2 0c             	shl    $0xc,%edx
f0100e7a:	39 d0                	cmp    %edx,%eax
f0100e7c:	72 14                	jb     f0100e92 <check_page_alloc+0x206>
    assert(page2pa(pp1) < npage * PGSIZE);
f0100e7e:	68 e5 5a 10 f0       	push   $0xf0105ae5
f0100e83:	68 74 5a 10 f0       	push   $0xf0105a74
f0100e88:	68 4b 01 00 00       	push   $0x14b
f0100e8d:	e9 a6 01 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100e92:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0100e95:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0100e9b:	c1 fa 02             	sar    $0x2,%edx
f0100e9e:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100ea1:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100ea4:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100ea7:	89 c1                	mov    %eax,%ecx
f0100ea9:	c1 e1 08             	shl    $0x8,%ecx
f0100eac:	01 c8                	add    %ecx,%eax
f0100eae:	89 c1                	mov    %eax,%ecx
f0100eb0:	c1 e1 10             	shl    $0x10,%ecx
f0100eb3:	01 c8                	add    %ecx,%eax
f0100eb5:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0100eb8:	c1 e0 0c             	shl    $0xc,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0100ebb:	8b 15 60 0b 1d f0    	mov    0xf01d0b60,%edx
f0100ec1:	c1 e2 0c             	shl    $0xc,%edx
f0100ec4:	39 d0                	cmp    %edx,%eax
f0100ec6:	72 14                	jb     f0100edc <check_page_alloc+0x250>
    assert(page2pa(pp2) < npage * PGSIZE);
f0100ec8:	68 03 5b 10 f0       	push   $0xf0105b03
f0100ecd:	68 74 5a 10 f0       	push   $0xf0105a74
f0100ed2:	68 4c 01 00 00       	push   $0x14c
f0100ed7:	e9 5c 01 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>

    // temporarily steal the rest of the free pages
    fl = page_free_list;
f0100edc:	8b 1d b8 fe 1c f0    	mov    0xf01cfeb8,%ebx
    LIST_INIT(&page_free_list);
f0100ee2:	c7 05 b8 fe 1c f0 00 	movl   $0x0,0xf01cfeb8
f0100ee9:	00 00 00 

    // should be no free memory
    assert(page_alloc(&pp) == -E_NO_MEM);
f0100eec:	83 ec 0c             	sub    $0xc,%esp
f0100eef:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0100ef2:	50                   	push   %eax
f0100ef3:	e8 83 05 00 00       	call   f010147b <page_alloc>
f0100ef8:	83 c4 10             	add    $0x10,%esp
f0100efb:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0100efe:	74 14                	je     f0100f14 <check_page_alloc+0x288>
f0100f00:	68 21 5b 10 f0       	push   $0xf0105b21
f0100f05:	68 74 5a 10 f0       	push   $0xf0105a74
f0100f0a:	68 53 01 00 00       	push   $0x153
f0100f0f:	e9 24 01 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>

    // free and re-allocate?
    page_free(pp0);
f0100f14:	83 ec 0c             	sub    $0xc,%esp
f0100f17:	ff 75 f8             	pushl  0xfffffff8(%ebp)
f0100f1a:	e8 9e 05 00 00       	call   f01014bd <page_free>
    page_free(pp1);
f0100f1f:	83 c4 04             	add    $0x4,%esp
f0100f22:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0100f25:	e8 93 05 00 00       	call   f01014bd <page_free>
    page_free(pp2);
f0100f2a:	83 c4 04             	add    $0x4,%esp
f0100f2d:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0100f30:	e8 88 05 00 00       	call   f01014bd <page_free>
    pp0 = pp1 = pp2 = 0;
f0100f35:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0100f3c:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
f0100f43:	c7 45 f8 00 00 00 00 	movl   $0x0,0xfffffff8(%ebp)
    assert(page_alloc(&pp0) == 0);
f0100f4a:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f0100f4d:	89 04 24             	mov    %eax,(%esp)
f0100f50:	e8 26 05 00 00       	call   f010147b <page_alloc>
f0100f55:	83 c4 10             	add    $0x10,%esp
f0100f58:	85 c0                	test   %eax,%eax
f0100f5a:	74 14                	je     f0100f70 <check_page_alloc+0x2e4>
f0100f5c:	68 5e 5a 10 f0       	push   $0xf0105a5e
f0100f61:	68 74 5a 10 f0       	push   $0xf0105a74
f0100f66:	68 5a 01 00 00       	push   $0x15a
f0100f6b:	e9 c8 00 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(page_alloc(&pp1) == 0);
f0100f70:	83 ec 0c             	sub    $0xc,%esp
f0100f73:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0100f76:	50                   	push   %eax
f0100f77:	e8 ff 04 00 00       	call   f010147b <page_alloc>
f0100f7c:	83 c4 10             	add    $0x10,%esp
f0100f7f:	85 c0                	test   %eax,%eax
f0100f81:	74 14                	je     f0100f97 <check_page_alloc+0x30b>
f0100f83:	68 89 5a 10 f0       	push   $0xf0105a89
f0100f88:	68 74 5a 10 f0       	push   $0xf0105a74
f0100f8d:	68 5b 01 00 00       	push   $0x15b
f0100f92:	e9 a1 00 00 00       	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(page_alloc(&pp2) == 0);
f0100f97:	83 ec 0c             	sub    $0xc,%esp
f0100f9a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0100f9d:	50                   	push   %eax
f0100f9e:	e8 d8 04 00 00       	call   f010147b <page_alloc>
f0100fa3:	83 c4 10             	add    $0x10,%esp
f0100fa6:	85 c0                	test   %eax,%eax
f0100fa8:	74 11                	je     f0100fbb <check_page_alloc+0x32f>
f0100faa:	68 9f 5a 10 f0       	push   $0xf0105a9f
f0100faf:	68 74 5a 10 f0       	push   $0xf0105a74
f0100fb4:	68 5c 01 00 00       	push   $0x15c
f0100fb9:	eb 7d                	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(pp0);
f0100fbb:	83 7d f8 00          	cmpl   $0x0,0xfffffff8(%ebp)
f0100fbf:	75 11                	jne    f0100fd2 <check_page_alloc+0x346>
f0100fc1:	68 c3 5a 10 f0       	push   $0xf0105ac3
f0100fc6:	68 74 5a 10 f0       	push   $0xf0105a74
f0100fcb:	68 5d 01 00 00       	push   $0x15d
f0100fd0:	eb 66                	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(pp1 && pp1 != pp0);
f0100fd2:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f0100fd6:	74 08                	je     f0100fe0 <check_page_alloc+0x354>
f0100fd8:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100fdb:	3b 45 f8             	cmp    0xfffffff8(%ebp),%eax
f0100fde:	75 11                	jne    f0100ff1 <check_page_alloc+0x365>
f0100fe0:	68 b5 5a 10 f0       	push   $0xf0105ab5
f0100fe5:	68 74 5a 10 f0       	push   $0xf0105a74
f0100fea:	68 5e 01 00 00       	push   $0x15e
f0100fef:	eb 47                	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0100ff1:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0100ff5:	74 0d                	je     f0101004 <check_page_alloc+0x378>
f0100ff7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0100ffa:	3b 45 f4             	cmp    0xfffffff4(%ebp),%eax
f0100ffd:	74 05                	je     f0101004 <check_page_alloc+0x378>
f0100fff:	3b 45 f8             	cmp    0xfffffff8(%ebp),%eax
f0101002:	75 11                	jne    f0101015 <check_page_alloc+0x389>
f0101004:	68 08 55 10 f0       	push   $0xf0105508
f0101009:	68 74 5a 10 f0       	push   $0xf0105a74
f010100e:	68 5f 01 00 00       	push   $0x15f
f0101013:	eb 23                	jmp    f0101038 <check_page_alloc+0x3ac>
    assert(page_alloc(&pp) == -E_NO_MEM);
f0101015:	83 ec 0c             	sub    $0xc,%esp
f0101018:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f010101b:	50                   	push   %eax
f010101c:	e8 5a 04 00 00       	call   f010147b <page_alloc>
f0101021:	83 c4 10             	add    $0x10,%esp
f0101024:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101027:	74 19                	je     f0101042 <check_page_alloc+0x3b6>
f0101029:	68 21 5b 10 f0       	push   $0xf0105b21
f010102e:	68 74 5a 10 f0       	push   $0xf0105a74
f0101033:	68 60 01 00 00       	push   $0x160
f0101038:	68 46 5a 10 f0       	push   $0xf0105a46
f010103d:	e8 a2 f0 ff ff       	call   f01000e4 <_panic>

    // give free list back
    page_free_list = fl;
f0101042:	89 1d b8 fe 1c f0    	mov    %ebx,0xf01cfeb8

    // free the pages we took
    page_free(pp0);
f0101048:	83 ec 0c             	sub    $0xc,%esp
f010104b:	ff 75 f8             	pushl  0xfffffff8(%ebp)
f010104e:	e8 6a 04 00 00       	call   f01014bd <page_free>
    page_free(pp1);
f0101053:	83 c4 04             	add    $0x4,%esp
f0101056:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0101059:	e8 5f 04 00 00       	call   f01014bd <page_free>
    page_free(pp2);
f010105e:	83 c4 04             	add    $0x4,%esp
f0101061:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101064:	e8 54 04 00 00       	call   f01014bd <page_free>

    cprintf("check_page_alloc() succeeded!\n");
f0101069:	c7 04 24 28 55 10 f0 	movl   $0xf0105528,(%esp)
f0101070:	e8 fd 1c 00 00       	call   f0102d72 <cprintf>
}
f0101075:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0101078:	c9                   	leave  
f0101079:	c3                   	ret    

f010107a <check_boot_pgdir>:

//
// Checks that the kernel part of virtual address space
// has been setup roughly correctly(by i386_vm_init()).
//
// This function doesn't test every corner case,
// in fact it doesn't test the permission bits at all,
// but it is a pretty good sanity check.
//
static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va);

static void
check_boot_pgdir(void) {
f010107a:	55                   	push   %ebp
f010107b:	89 e5                	mov    %esp,%ebp
f010107d:	57                   	push   %edi
f010107e:	56                   	push   %esi
f010107f:	53                   	push   %ebx
f0101080:	83 ec 0c             	sub    $0xc,%esp
    uint32_t i, n;
    pde_t *pgdir;

    pgdir = boot_pgdir;
f0101083:	8b 35 68 0b 1d f0    	mov    0xf01d0b68,%esi

    // check pages array
    n = ROUNDUP(npage * sizeof (struct Page), PGSIZE);
f0101089:	a1 60 0b 1d f0       	mov    0xf01d0b60,%eax
f010108e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101091:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
f0101098:	89 c2                	mov    %eax,%edx
f010109a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f01010a0:	89 c7                	mov    %eax,%edi
f01010a2:	29 d7                	sub    %edx,%edi
    for (i = 0; i < n; i += PGSIZE)
f01010a4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010a9:	39 fb                	cmp    %edi,%ebx
f01010ab:	73 52                	jae    f01010ff <check_boot_pgdir+0x85>
        assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01010ad:	83 ec 08             	sub    $0x8,%esp
f01010b0:	8d 83 00 00 00 ef    	lea    0xef000000(%ebx),%eax
f01010b6:	50                   	push   %eax
f01010b7:	56                   	push   %esi
f01010b8:	e8 cc 01 00 00       	call   f0101289 <check_va2pa>
f01010bd:	89 c2                	mov    %eax,%edx
f01010bf:	83 c4 10             	add    $0x10,%esp
f01010c2:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f01010c7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010cc:	77 08                	ja     f01010d6 <check_boot_pgdir+0x5c>
f01010ce:	50                   	push   %eax
f01010cf:	68 c0 54 10 f0       	push   $0xf01054c0
f01010d4:	eb 15                	jmp    f01010eb <check_boot_pgdir+0x71>
f01010d6:	8d 84 03 00 00 00 10 	lea    0x10000000(%ebx,%eax,1),%eax
f01010dd:	39 c2                	cmp    %eax,%edx
f01010df:	74 14                	je     f01010f5 <check_boot_pgdir+0x7b>
f01010e1:	68 48 55 10 f0       	push   $0xf0105548
f01010e6:	68 74 5a 10 f0       	push   $0xf0105a74
f01010eb:	68 81 01 00 00       	push   $0x181
f01010f0:	e9 6c 01 00 00       	jmp    f0101261 <check_boot_pgdir+0x1e7>
f01010f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010fb:	39 fb                	cmp    %edi,%ebx
f01010fd:	72 ae                	jb     f01010ad <check_boot_pgdir+0x33>

    // check envs array (new test for lab 3)
    n = ROUNDUP(NENV * sizeof (struct Env), PGSIZE);
f01010ff:	bf 00 00 02 00       	mov    $0x20000,%edi
    for (i = 0; i < n; i += PGSIZE)
f0101104:	bb 00 00 00 00       	mov    $0x0,%ebx
        assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101109:	83 ec 08             	sub    $0x8,%esp
f010110c:	8d 83 00 00 c0 ee    	lea    0xeec00000(%ebx),%eax
f0101112:	50                   	push   %eax
f0101113:	56                   	push   %esi
f0101114:	e8 70 01 00 00       	call   f0101289 <check_va2pa>
f0101119:	89 c2                	mov    %eax,%edx
f010111b:	83 c4 10             	add    $0x10,%esp
f010111e:	a1 c0 fe 1c f0       	mov    0xf01cfec0,%eax
f0101123:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101128:	77 08                	ja     f0101132 <check_boot_pgdir+0xb8>
f010112a:	50                   	push   %eax
f010112b:	68 c0 54 10 f0       	push   $0xf01054c0
f0101130:	eb 15                	jmp    f0101147 <check_boot_pgdir+0xcd>
f0101132:	8d 84 03 00 00 00 10 	lea    0x10000000(%ebx,%eax,1),%eax
f0101139:	39 c2                	cmp    %eax,%edx
f010113b:	74 14                	je     f0101151 <check_boot_pgdir+0xd7>
f010113d:	68 7c 55 10 f0       	push   $0xf010557c
f0101142:	68 74 5a 10 f0       	push   $0xf0105a74
f0101147:	68 86 01 00 00       	push   $0x186
f010114c:	e9 10 01 00 00       	jmp    f0101261 <check_boot_pgdir+0x1e7>
f0101151:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101157:	39 fb                	cmp    %edi,%ebx
f0101159:	72 ae                	jb     f0101109 <check_boot_pgdir+0x8f>

    // check phys mem
    for (i = 0; i < npage * PGSIZE; i += PGSIZE)
f010115b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101160:	a1 60 0b 1d f0       	mov    0xf01d0b60,%eax
f0101165:	c1 e0 0c             	shl    $0xc,%eax
f0101168:	39 c3                	cmp    %eax,%ebx
f010116a:	73 3d                	jae    f01011a9 <check_boot_pgdir+0x12f>
        assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010116c:	83 ec 08             	sub    $0x8,%esp
f010116f:	8d 83 00 00 00 f0    	lea    0xf0000000(%ebx),%eax
f0101175:	50                   	push   %eax
f0101176:	56                   	push   %esi
f0101177:	e8 0d 01 00 00       	call   f0101289 <check_va2pa>
f010117c:	83 c4 10             	add    $0x10,%esp
f010117f:	39 d8                	cmp    %ebx,%eax
f0101181:	74 14                	je     f0101197 <check_boot_pgdir+0x11d>
f0101183:	68 b0 55 10 f0       	push   $0xf01055b0
f0101188:	68 74 5a 10 f0       	push   $0xf0105a74
f010118d:	68 8a 01 00 00       	push   $0x18a
f0101192:	e9 ca 00 00 00       	jmp    f0101261 <check_boot_pgdir+0x1e7>
f0101197:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010119d:	a1 60 0b 1d f0       	mov    0xf01d0b60,%eax
f01011a2:	c1 e0 0c             	shl    $0xc,%eax
f01011a5:	39 c3                	cmp    %eax,%ebx
f01011a7:	72 c3                	jb     f010116c <check_boot_pgdir+0xf2>

    // check kernel stack
    for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01011a9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011ae:	bf 00 50 11 f0       	mov    $0xf0115000,%edi
        assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01011b3:	83 ec 08             	sub    $0x8,%esp
f01011b6:	8d 83 00 80 bf ef    	lea    0xefbf8000(%ebx),%eax
f01011bc:	50                   	push   %eax
f01011bd:	56                   	push   %esi
f01011be:	e8 c6 00 00 00       	call   f0101289 <check_va2pa>
f01011c3:	89 c2                	mov    %eax,%edx
f01011c5:	83 c4 10             	add    $0x10,%esp
f01011c8:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01011ce:	77 0c                	ja     f01011dc <check_boot_pgdir+0x162>
f01011d0:	68 00 50 11 f0       	push   $0xf0115000
f01011d5:	68 c0 54 10 f0       	push   $0xf01054c0
f01011da:	eb 15                	jmp    f01011f1 <check_boot_pgdir+0x177>
f01011dc:	8d 84 3b 00 00 00 10 	lea    0x10000000(%ebx,%edi,1),%eax
f01011e3:	39 c2                	cmp    %eax,%edx
f01011e5:	74 11                	je     f01011f8 <check_boot_pgdir+0x17e>
f01011e7:	68 d8 55 10 f0       	push   $0xf01055d8
f01011ec:	68 74 5a 10 f0       	push   $0xf0105a74
f01011f1:	68 8e 01 00 00       	push   $0x18e
f01011f6:	eb 69                	jmp    f0101261 <check_boot_pgdir+0x1e7>
f01011f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011fe:	81 fb ff 7f 00 00    	cmp    $0x7fff,%ebx
f0101204:	76 ad                	jbe    f01011b3 <check_boot_pgdir+0x139>

    // check for zero/non-zero in PDEs
    for (i = 0; i < NPDENTRIES; i++) {
f0101206:	bb 00 00 00 00       	mov    $0x0,%ebx
        switch (i) {
f010120b:	8d 83 45 fc ff ff    	lea    0xfffffc45(%ebx),%eax
f0101211:	83 f8 04             	cmp    $0x4,%eax
f0101214:	77 17                	ja     f010122d <check_boot_pgdir+0x1b3>
            case PDX(VPT) :
            case PDX(UVPT) :
            case PDX(KSTACKTOP - 1) :
            case PDX(UPAGES) :
            case PDX(UENVS) :
                        assert(pgdir[i]);
f0101216:	83 3c 9e 00          	cmpl   $0x0,(%esi,%ebx,4)
f010121a:	75 4f                	jne    f010126b <check_boot_pgdir+0x1f1>
f010121c:	68 3e 5b 10 f0       	push   $0xf0105b3e
f0101221:	68 74 5a 10 f0       	push   $0xf0105a74
f0101226:	68 98 01 00 00       	push   $0x198
f010122b:	eb 34                	jmp    f0101261 <check_boot_pgdir+0x1e7>
                break;
            default:
                if (i >= PDX(KERNBASE))
f010122d:	81 fb bf 03 00 00    	cmp    $0x3bf,%ebx
f0101233:	76 17                	jbe    f010124c <check_boot_pgdir+0x1d2>
                    assert(pgdir[i]);
f0101235:	83 3c 9e 00          	cmpl   $0x0,(%esi,%ebx,4)
f0101239:	75 30                	jne    f010126b <check_boot_pgdir+0x1f1>
f010123b:	68 3e 5b 10 f0       	push   $0xf0105b3e
f0101240:	68 74 5a 10 f0       	push   $0xf0105a74
f0101245:	68 9c 01 00 00       	push   $0x19c
f010124a:	eb 15                	jmp    f0101261 <check_boot_pgdir+0x1e7>
                else
                    assert(pgdir[i] == 0);
f010124c:	83 3c 9e 00          	cmpl   $0x0,(%esi,%ebx,4)
f0101250:	74 19                	je     f010126b <check_boot_pgdir+0x1f1>
f0101252:	68 47 5b 10 f0       	push   $0xf0105b47
f0101257:	68 74 5a 10 f0       	push   $0xf0105a74
f010125c:	68 9e 01 00 00       	push   $0x19e
f0101261:	68 46 5a 10 f0       	push   $0xf0105a46
f0101266:	e8 79 ee ff ff       	call   f01000e4 <_panic>
f010126b:	43                   	inc    %ebx
f010126c:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f0101272:	76 97                	jbe    f010120b <check_boot_pgdir+0x191>
                break;
        }
    }
    cprintf("check_boot_pgdir() succeeded!\n");
f0101274:	83 ec 0c             	sub    $0xc,%esp
f0101277:	68 20 56 10 f0       	push   $0xf0105620
f010127c:	e8 f1 1a 00 00       	call   f0102d72 <cprintf>
}
f0101281:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0101284:	5b                   	pop    %ebx
f0101285:	5e                   	pop    %esi
f0101286:	5f                   	pop    %edi
f0101287:	c9                   	leave  
f0101288:	c3                   	ret    

f0101289 <check_va2pa>:

// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va) {
f0101289:	55                   	push   %ebp
f010128a:	89 e5                	mov    %esp,%ebp
f010128c:	83 ec 08             	sub    $0x8,%esp
f010128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    pte_t *p;

    pgdir = &pgdir[PDX(va)];
f0101292:	89 c8                	mov    %ecx,%eax
f0101294:	c1 e8 16             	shr    $0x16,%eax
f0101297:	c1 e0 02             	shl    $0x2,%eax
f010129a:	03 45 08             	add    0x8(%ebp),%eax
    if (!(*pgdir & PTE_P))
f010129d:	f6 00 01             	testb  $0x1,(%eax)
f01012a0:	74 40                	je     f01012e2 <check_va2pa+0x59>
        return ~0;
    p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01012a2:	8b 10                	mov    (%eax),%edx
f01012a4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01012aa:	89 d0                	mov    %edx,%eax
f01012ac:	c1 e8 0c             	shr    $0xc,%eax
f01012af:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01012b5:	72 15                	jb     f01012cc <check_va2pa+0x43>
f01012b7:	52                   	push   %edx
f01012b8:	68 e4 54 10 f0       	push   $0xf01054e4
f01012bd:	68 b1 01 00 00       	push   $0x1b1
f01012c2:	68 46 5a 10 f0       	push   $0xf0105a46
f01012c7:	e8 18 ee ff ff       	call   f01000e4 <_panic>
f01012cc:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
    if (!(p[PTX(va)] & PTE_P))
f01012d2:	89 c8                	mov    %ecx,%eax
f01012d4:	c1 e8 0c             	shr    $0xc,%eax
f01012d7:	25 ff 03 00 00       	and    $0x3ff,%eax
f01012dc:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f01012e0:	75 07                	jne    f01012e9 <check_va2pa+0x60>
        return ~0;
f01012e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01012e7:	eb 12                	jmp    f01012fb <check_va2pa+0x72>
    return PTE_ADDR(p[PTX(va)]);
f01012e9:	89 c8                	mov    %ecx,%eax
f01012eb:	c1 e8 0c             	shr    $0xc,%eax
f01012ee:	25 ff 03 00 00       	and    $0x3ff,%eax
f01012f3:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01012f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f01012fb:	c9                   	leave  
f01012fc:	c3                   	ret    

f01012fd <page_init>:

// --------------------------------------------------------------
// Tracking of physical pages.
// The 'pages' array has one 'struct Page' entry per physical page.
// Pages are reference counted, and free pages are kept on a linked list.
// --------------------------------------------------------------

//
// Initialize page structure and memory free list.
// After this point, ONLY use the functions below
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc()
//

void
page_init(void) {
f01012fd:	55                   	push   %ebp
f01012fe:	89 e5                	mov    %esp,%ebp
f0101300:	57                   	push   %edi
f0101301:	56                   	push   %esi
f0101302:	53                   	push   %ebx
f0101303:	83 ec 0c             	sub    $0xc,%esp
    // The example code here marks all pages as free.
    // However this is not truly the case.  What memory is free?
    //  1) Mark page 0 as in use.
    //     This way we preserve the real-mode IDT and BIOS structures
    //     in case we ever need them.  (Currently we don't, but...)
    //  2) Mark the rest of base memory as free.
    //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM).
    //     Mark it as in use so that it can never be allocated.
    //  4) Then extended memory [EXTPHYSMEM, ...).
    //     Some of it is in use, some is free. Where is the kernel?
    //     Which pages are used for page tables and other data structures?
    //
    // Change the code to reflect this.
    int i;
    LIST_INIT(&page_free_list);
f0101306:	c7 05 b8 fe 1c f0 00 	movl   $0x0,0xf01cfeb8
f010130d:	00 00 00 
    for (i = 1; i < npage; i++) {
f0101310:	bb 01 00 00 00       	mov    $0x1,%ebx
f0101315:	3b 1d 60 0b 1d f0    	cmp    0xf01d0b60,%ebx
f010131b:	73 5e                	jae    f010137b <page_init+0x7e>
        pages[i].pp_ref = 0;
f010131d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0101320:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0101327:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f010132c:	66 c7 44 08 08 00 00 	movw   $0x0,0x8(%eax,%ecx,1)
        LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0101333:	8b 15 b8 fe 1c f0    	mov    0xf01cfeb8,%edx
f0101339:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f010133e:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f0101341:	85 d2                	test   %edx,%edx
f0101343:	74 10                	je     f0101355 <page_init+0x58>
f0101345:	89 ca                	mov    %ecx,%edx
f0101347:	03 15 6c 0b 1d f0    	add    0xf01d0b6c,%edx
f010134d:	a1 b8 fe 1c f0       	mov    0xf01cfeb8,%eax
f0101352:	89 50 04             	mov    %edx,0x4(%eax)
f0101355:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0101358:	c1 e0 02             	shl    $0x2,%eax
f010135b:	8b 0d 6c 0b 1d f0    	mov    0xf01d0b6c,%ecx
f0101361:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f0101364:	89 15 b8 fe 1c f0    	mov    %edx,0xf01cfeb8
f010136a:	c7 44 01 04 b8 fe 1c 	movl   $0xf01cfeb8,0x4(%ecx,%eax,1)
f0101371:	f0 
f0101372:	43                   	inc    %ebx
f0101373:	3b 1d 60 0b 1d f0    	cmp    0xf01d0b60,%ebx
f0101379:	72 a2                	jb     f010131d <page_init+0x20>
    }
    /* init the page array indexed by the PPN.
     * set some page's pp_ref as 1
     */

    //cprintf("here\n");
    pages[0].pp_ref = 1;
f010137b:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f0101380:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
    //LIST_REMOVE(page, pp_link);
    physaddr_t pa;
    for (i = ROUNDUP(IOPHYSMEM, PGSIZE) / PGSIZE; i < ROUNDUP(EXTPHYSMEM, PGSIZE) / PGSIZE; i++) {
f0101386:	bb a0 00 00 00       	mov    $0xa0,%ebx
f010138b:	eb 41                	jmp    f01013ce <page_init+0xd1>
        pages[i].pp_ref = 1;
f010138d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0101390:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0101397:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f010139c:	66 c7 44 08 08 01 00 	movw   $0x1,0x8(%eax,%ecx,1)
        LIST_REMOVE(&pages[i], pp_link);
f01013a3:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f01013a8:	83 3c 08 00          	cmpl   $0x0,(%eax,%ecx,1)
f01013ac:	74 0a                	je     f01013b8 <page_init+0xbb>
f01013ae:	8b 14 08             	mov    (%eax,%ecx,1),%edx
f01013b1:	8b 44 08 04          	mov    0x4(%eax,%ecx,1),%eax
f01013b5:	89 42 04             	mov    %eax,0x4(%edx)
f01013b8:	8b 0d 6c 0b 1d f0    	mov    0xf01d0b6c,%ecx
f01013be:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01013c1:	c1 e0 02             	shl    $0x2,%eax
f01013c4:	8b 54 01 04          	mov    0x4(%ecx,%eax,1),%edx
f01013c8:	8b 04 01             	mov    (%ecx,%eax,1),%eax
f01013cb:	89 02                	mov    %eax,(%edx)
f01013cd:	43                   	inc    %ebx
f01013ce:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
f01013d4:	7c b7                	jl     f010138d <page_init+0x90>
    }
    //cprintf("here1\n");
    //pte_t *p;
    for (i = ROUNDUP(EXTPHYSMEM, PGSIZE) / PGSIZE; i < ROUNDUP(PADDR(boot_freemem), PGSIZE) / PGSIZE; i++) {
f01013d6:	bb 00 01 00 00       	mov    $0x100,%ebx
f01013db:	be 00 10 00 00       	mov    $0x1000,%esi
f01013e0:	eb 41                	jmp    f0101423 <page_init+0x126>
        pages[i].pp_ref = 1;
f01013e2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01013e5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f01013ec:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f01013f1:	66 c7 44 08 08 01 00 	movw   $0x1,0x8(%eax,%ecx,1)
        LIST_REMOVE(&pages[i], pp_link);
f01013f8:	a1 6c 0b 1d f0       	mov    0xf01d0b6c,%eax
f01013fd:	83 3c 08 00          	cmpl   $0x0,(%eax,%ecx,1)
f0101401:	74 0a                	je     f010140d <page_init+0x110>
f0101403:	8b 14 08             	mov    (%eax,%ecx,1),%edx
f0101406:	8b 44 08 04          	mov    0x4(%eax,%ecx,1),%eax
f010140a:	89 42 04             	mov    %eax,0x4(%edx)
f010140d:	8b 0d 6c 0b 1d f0    	mov    0xf01d0b6c,%ecx
f0101413:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0101416:	c1 e0 02             	shl    $0x2,%eax
f0101419:	8b 54 01 04          	mov    0x4(%ecx,%eax,1),%edx
f010141d:	8b 04 01             	mov    (%ecx,%eax,1),%eax
f0101420:	89 02                	mov    %eax,(%edx)
f0101422:	43                   	inc    %ebx
f0101423:	a1 b4 fe 1c f0       	mov    0xf01cfeb4,%eax
f0101428:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010142d:	77 15                	ja     f0101444 <page_init+0x147>
f010142f:	50                   	push   %eax
f0101430:	68 c0 54 10 f0       	push   $0xf01054c0
f0101435:	68 e7 01 00 00       	push   $0x1e7
f010143a:	68 46 5a 10 f0       	push   $0xf0105a46
f010143f:	e8 a0 ec ff ff       	call   f01000e4 <_panic>
f0101444:	8d bc 06 ff ff ff 0f 	lea    0xfffffff(%esi,%eax,1),%edi
f010144b:	89 f8                	mov    %edi,%eax
f010144d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101452:	f7 f6                	div    %esi
f0101454:	89 f8                	mov    %edi,%eax
f0101456:	29 d0                	sub    %edx,%eax
f0101458:	c1 e8 0c             	shr    $0xc,%eax
f010145b:	39 c3                	cmp    %eax,%ebx
f010145d:	72 83                	jb     f01013e2 <page_init+0xe5>
    }
    //cprintf("here2\n");
    //ok
}
f010145f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0101462:	5b                   	pop    %ebx
f0101463:	5e                   	pop    %esi
f0101464:	5f                   	pop    %edi
f0101465:	c9                   	leave  
f0101466:	c3                   	ret    

f0101467 <page_initpp>:

//
// Initialize a Page structure.
// The result has null links and 0 refcount.
// Note that the corresponding physical page is NOT initialized!
//

static void
page_initpp(struct Page *pp) {
f0101467:	55                   	push   %ebp
f0101468:	89 e5                	mov    %esp,%ebp
f010146a:	83 ec 0c             	sub    $0xc,%esp
    memset(pp, 0, sizeof (*pp));
f010146d:	6a 0c                	push   $0xc
f010146f:	6a 00                	push   $0x0
f0101471:	ff 75 08             	pushl  0x8(%ebp)
f0101474:	e8 ba 38 00 00       	call   f0104d33 <memset>
}
f0101479:	c9                   	leave  
f010147a:	c3                   	ret    

f010147b <page_alloc>:

//
// Allocates a physical page.
// Does NOT set the contents of the physical page to zero -
// the caller must do that if necessary.
//
// *pp_store -- is set to point to the Page struct of the newly allocated
// page
//
// RETURNS
//   0 -- on success
//   -E_NO_MEM -- otherwise
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented

int
page_alloc(struct Page **pp_store) {
f010147b:	55                   	push   %ebp
f010147c:	89 e5                	mov    %esp,%ebp
f010147e:	53                   	push   %ebx
f010147f:	83 ec 04             	sub    $0x4,%esp
    // Fill this function in
    /*store physical address of the page entry*/
    struct Page *p = LIST_FIRST(&page_free_list);
f0101482:	8b 1d b8 fe 1c f0    	mov    0xf01cfeb8,%ebx
    if (p) {
        LIST_REMOVE(p, pp_link);
        page_initpp(p);
        *pp_store = p;
        return 0;
    } else {
        /*there's no free page*/
        return -E_NO_MEM;
f0101488:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010148d:	85 db                	test   %ebx,%ebx
f010148f:	74 27                	je     f01014b8 <page_alloc+0x3d>
f0101491:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101494:	74 08                	je     f010149e <page_alloc+0x23>
f0101496:	8b 13                	mov    (%ebx),%edx
f0101498:	8b 43 04             	mov    0x4(%ebx),%eax
f010149b:	89 42 04             	mov    %eax,0x4(%edx)
f010149e:	8b 53 04             	mov    0x4(%ebx),%edx
f01014a1:	8b 03                	mov    (%ebx),%eax
f01014a3:	89 02                	mov    %eax,(%edx)
f01014a5:	83 ec 0c             	sub    $0xc,%esp
f01014a8:	53                   	push   %ebx
f01014a9:	e8 b9 ff ff ff       	call   f0101467 <page_initpp>
f01014ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b1:	89 18                	mov    %ebx,(%eax)
f01014b3:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    //ok
}
f01014b8:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01014bb:	c9                   	leave  
f01014bc:	c3                   	ret    

f01014bd <page_free>:

//
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//

void
page_free(struct Page *pp) {
f01014bd:	55                   	push   %ebp
f01014be:	89 e5                	mov    %esp,%ebp
f01014c0:	8b 55 08             	mov    0x8(%ebp),%edx
    // Fill this function in
    if (!(pp->pp_ref)) {
f01014c3:	66 83 7a 08 00       	cmpw   $0x0,0x8(%edx)
f01014c8:	75 20                	jne    f01014ea <page_free+0x2d>
        LIST_INSERT_HEAD(&page_free_list, pp, pp_link);
f01014ca:	a1 b8 fe 1c f0       	mov    0xf01cfeb8,%eax
f01014cf:	89 02                	mov    %eax,(%edx)
f01014d1:	85 c0                	test   %eax,%eax
f01014d3:	74 08                	je     f01014dd <page_free+0x20>
f01014d5:	a1 b8 fe 1c f0       	mov    0xf01cfeb8,%eax
f01014da:	89 50 04             	mov    %edx,0x4(%eax)
f01014dd:	89 15 b8 fe 1c f0    	mov    %edx,0xf01cfeb8
f01014e3:	c7 42 04 b8 fe 1c f0 	movl   $0xf01cfeb8,0x4(%edx)
    }
    //ok
}
f01014ea:	c9                   	leave  
f01014eb:	c3                   	ret    

f01014ec <page_decref>:

//
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//

void
page_decref(struct Page* pp) {
f01014ec:	55                   	push   %ebp
f01014ed:	89 e5                	mov    %esp,%ebp
f01014ef:	83 ec 08             	sub    $0x8,%esp
f01014f2:	8b 45 08             	mov    0x8(%ebp),%eax
    if (--pp->pp_ref == 0)
f01014f5:	66 ff 48 08          	decw   0x8(%eax)
f01014f9:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01014fe:	75 0c                	jne    f010150c <page_decref+0x20>
        page_free(pp);
f0101500:	83 ec 0c             	sub    $0xc,%esp
f0101503:	50                   	push   %eax
f0101504:	e8 b4 ff ff ff       	call   f01014bd <page_free>
f0101509:	83 c4 10             	add    $0x10,%esp
}
f010150c:	c9                   	leave  
f010150d:	c3                   	ret    

f010150e <pgdir_walk>:

// Given 'pgdir', a pointer to a page directory, pgdir_walk returns
// a pointer to the page table entry (PTE) for linear address 'va'.
// This requires walking the two-level page table structure.
//
// If the relevant page table doesn't exist in the page directory, then:
//    - If create == 0, pgdir_walk returns NULL.
//    - Otherwise, pgdir_walk tries to allocate a new page table
//	with page_alloc.  If this fails, pgdir_walk returns NULL.
//    - pgdir_walk sets pp_ref to 1 for the new page table.
//    - Finally, pgdir_walk returns a pointer into the new page table.
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
//
// Hint 2: the x86 MMU checks permission bits in both the page directory
// and the page table, so it's safe to leave permissions in the page
// more permissive than strictly necessary.

pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create) {
f010150e:	55                   	push   %ebp
f010150f:	89 e5                	mov    %esp,%ebp
f0101511:	57                   	push   %edi
f0101512:	56                   	push   %esi
f0101513:	53                   	push   %ebx
f0101514:	83 ec 0c             	sub    $0xc,%esp
f0101517:	8b 45 0c             	mov    0xc(%ebp),%eax
    // Fill this function in
    //return physical address
    uintptr_t pgdx = PDX(va); //pgdx is the page directory index
f010151a:	89 c7                	mov    %eax,%edi
f010151c:	c1 ef 16             	shr    $0x16,%edi
    uintptr_t pgtx = PTX(va); //pgtx is the page table index
f010151f:	89 c6                	mov    %eax,%esi
f0101521:	c1 ee 0c             	shr    $0xc,%esi
f0101524:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    //uintptr_t offset = PGOFF(va);
    pde_t *pgt; //pgt is the pointer to the page table
    pte_t *pge; //pge is the pointer to the page entry
    struct Page *addr;
    physaddr_t pa;
    pgt = (pde_t *) (*(pgdir + pgdx));
f010152a:	8b 55 08             	mov    0x8(%ebp),%edx
f010152d:	8b 04 ba             	mov    (%edx,%edi,4),%eax
    if (((uintptr_t) pgt) & PTE_P) {
f0101530:	a8 01                	test   $0x1,%al
f0101532:	74 29                	je     f010155d <pgdir_walk+0x4f>
        /*if the page is in the memory*/
        pge = (pte_t *) KADDR(PTE_ADDR(pgt)) + pgtx;
f0101534:	89 c2                	mov    %eax,%edx
f0101536:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010153c:	89 d0                	mov    %edx,%eax
f010153e:	c1 e8 0c             	shr    $0xc,%eax
f0101541:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f0101547:	0f 82 03 01 00 00    	jb     f0101650 <pgdir_walk+0x142>
f010154d:	52                   	push   %edx
f010154e:	68 e4 54 10 f0       	push   $0xf01054e4
f0101553:	68 53 02 00 00       	push   $0x253
f0101558:	e9 e9 00 00 00       	jmp    f0101646 <pgdir_walk+0x138>
        return pge;
        /*return the physical address of the PTE*/
    } else {
        if (!create) {
f010155d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101562:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101566:	0f 84 eb 00 00 00    	je     f0101657 <pgdir_walk+0x149>
            return NULL;
        }
        if (page_alloc(&addr) != 0)
f010156c:	83 ec 0c             	sub    $0xc,%esp
f010156f:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0101572:	50                   	push   %eax
f0101573:	e8 03 ff ff ff       	call   f010147b <page_alloc>
f0101578:	83 c4 10             	add    $0x10,%esp
f010157b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101580:	85 c0                	test   %eax,%eax
f0101582:	0f 85 cf 00 00 00    	jne    f0101657 <pgdir_walk+0x149>
            return NULL;
        /*after page alloc with the addr*/
        addr->pp_ref = 1;
f0101588:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010158b:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101591:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0101594:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f010159a:	c1 fa 02             	sar    $0x2,%edx
f010159d:	8d 04 92             	lea    (%edx,%edx,4),%eax
f01015a0:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01015a3:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01015a6:	89 c1                	mov    %eax,%ecx
f01015a8:	c1 e1 08             	shl    $0x8,%ecx
f01015ab:	01 c8                	add    %ecx,%eax
f01015ad:	89 c1                	mov    %eax,%ecx
f01015af:	c1 e1 10             	shl    $0x10,%ecx
f01015b2:	01 c8                	add    %ecx,%eax
f01015b4:	8d 04 42             	lea    (%edx,%eax,2),%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f01015b7:	89 c3                	mov    %eax,%ebx
f01015b9:	c1 e3 0c             	shl    $0xc,%ebx
        pa = page2pa(addr); //the address which the page struct refers to
        memset((void *) KADDR(pa), 0, PGSIZE); //clear the page
f01015bc:	89 d8                	mov    %ebx,%eax
f01015be:	c1 e8 0c             	shr    $0xc,%eax
f01015c1:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01015c7:	72 0d                	jb     f01015d6 <pgdir_walk+0xc8>
f01015c9:	53                   	push   %ebx
f01015ca:	68 e4 54 10 f0       	push   $0xf01054e4
f01015cf:	68 5f 02 00 00       	push   $0x25f
f01015d4:	eb 70                	jmp    f0101646 <pgdir_walk+0x138>
f01015d6:	8d 83 00 00 00 f0    	lea    0xf0000000(%ebx),%eax
f01015dc:	83 ec 04             	sub    $0x4,%esp
f01015df:	68 00 10 00 00       	push   $0x1000
f01015e4:	6a 00                	push   $0x0
f01015e6:	50                   	push   %eax
f01015e7:	e8 47 37 00 00       	call   f0104d33 <memset>
        pgt = (pde_t *) (PADDR(KADDR(pa)) | PTE_P | PTE_U  | PTE_W); //set the privilige 
f01015ec:	83 c4 10             	add    $0x10,%esp
f01015ef:	89 d8                	mov    %ebx,%eax
f01015f1:	c1 e8 0c             	shr    $0xc,%eax
f01015f4:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01015fa:	72 08                	jb     f0101604 <pgdir_walk+0xf6>
f01015fc:	53                   	push   %ebx
f01015fd:	68 e4 54 10 f0       	push   $0xf01054e4
f0101602:	eb 13                	jmp    f0101617 <pgdir_walk+0x109>
f0101604:	8d 83 00 00 00 f0    	lea    0xf0000000(%ebx),%eax
f010160a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010160f:	77 0d                	ja     f010161e <pgdir_walk+0x110>
f0101611:	50                   	push   %eax
f0101612:	68 c0 54 10 f0       	push   $0xf01054c0
f0101617:	68 60 02 00 00       	push   $0x260
f010161c:	eb 28                	jmp    f0101646 <pgdir_walk+0x138>
f010161e:	05 00 00 00 10       	add    $0x10000000,%eax
f0101623:	83 c8 07             	or     $0x7,%eax
        *(pgdir + pgdx) = (uintptr_t) pgt; //set the page directory entry with the physical adress of the page table
f0101626:	8b 55 08             	mov    0x8(%ebp),%edx
f0101629:	89 04 ba             	mov    %eax,(%edx,%edi,4)
        //pge = (pte_t*) PTE_ADDR(pgt);
        return (pte_t *) KADDR(pa) + pgtx;
f010162c:	89 da                	mov    %ebx,%edx
f010162e:	89 d8                	mov    %ebx,%eax
f0101630:	c1 e8 0c             	shr    $0xc,%eax
f0101633:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f0101639:	72 15                	jb     f0101650 <pgdir_walk+0x142>
f010163b:	53                   	push   %ebx
f010163c:	68 e4 54 10 f0       	push   $0xf01054e4
f0101641:	68 63 02 00 00       	push   $0x263
f0101646:	68 46 5a 10 f0       	push   $0xf0105a46
f010164b:	e8 94 ea ff ff       	call   f01000e4 <_panic>
f0101650:	8d 94 b2 00 00 00 f0 	lea    0xf0000000(%edx,%esi,4),%edx
        /*return the address of the PTE which is in the memory alloced*/
    }
    //maybe ok
}
f0101657:	89 d0                	mov    %edx,%eax
f0101659:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010165c:	5b                   	pop    %ebx
f010165d:	5e                   	pop    %esi
f010165e:	5f                   	pop    %edi
f010165f:	c9                   	leave  
f0101660:	c3                   	ret    

f0101661 <page_insert>:

//
// Map the physical page 'pp' at virtual address 'va'.
// The permissions (the low 12 bits) of the page table
//  entry should be set to 'perm|PTE_P'.
//
// Details
//   - If there is already a page mapped at 'va', it is page_remove()d.
//   - If necessary, on demand, allocates a page table and inserts it into
//     'pgdir'.
//   - pp->pp_ref should be incremented if the insertion succeeds.
//   - The TLB must be invalidated if a page was formerly present at 'va'.
//
// RETURNS:
//   0 on success
//   -E_NO_MEM, if page table couldn't be allocated
//
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//

int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) {
f0101661:	55                   	push   %ebp
f0101662:	89 e5                	mov    %esp,%ebp
f0101664:	57                   	push   %edi
f0101665:	56                   	push   %esi
f0101666:	53                   	push   %ebx
f0101667:	83 ec 10             	sub    $0x10,%esp
f010166a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010166d:	8b 7d 10             	mov    0x10(%ebp),%edi
    // Fill this function in
    pte_t *p;
    if ((p = pgdir_walk(pgdir, va, 1))) {
f0101670:	6a 01                	push   $0x1
f0101672:	57                   	push   %edi
f0101673:	ff 75 08             	pushl  0x8(%ebp)
f0101676:	e8 93 fe ff ff       	call   f010150e <pgdir_walk>
f010167b:	89 c3                	mov    %eax,%ebx
f010167d:	83 c4 10             	add    $0x10,%esp
        if ((*p) & PTE_P) {
            if (pa2page(PTE_ADDR(*p)) != pp) {
                page_remove(pgdir, va);
                pp->pp_ref++;
            }
        } else {
            pp->pp_ref++;
        }
        *p = page2pa(pp) | perm | PTE_P;
        return 0;
    } else {
        return -E_NO_MEM;
f0101680:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101685:	85 db                	test   %ebx,%ebx
f0101687:	0f 84 92 00 00 00    	je     f010171f <page_insert+0xbe>
f010168d:	8b 03                	mov    (%ebx),%eax
f010168f:	a8 01                	test   $0x1,%al
f0101691:	74 53                	je     f01016e6 <page_insert+0x85>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
f0101693:	89 c2                	mov    %eax,%edx
f0101695:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PPN(pa) >= npage)
f010169b:	89 d0                	mov    %edx,%eax
f010169d:	c1 e8 0c             	shr    $0xc,%eax
f01016a0:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01016a6:	72 14                	jb     f01016bc <page_insert+0x5b>
		panic("pa2page called with invalid pa");
f01016a8:	83 ec 04             	sub    $0x4,%esp
f01016ab:	68 40 56 10 f0       	push   $0xf0105640
f01016b0:	6a 53                	push   $0x53
f01016b2:	68 52 5a 10 f0       	push   $0xf0105a52
f01016b7:	e8 28 ea ff ff       	call   f01000e4 <_panic>
f01016bc:	89 d0                	mov    %edx,%eax
f01016be:	c1 e8 0c             	shr    $0xc,%eax
f01016c1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01016c4:	8b 15 6c 0b 1d f0    	mov    0xf01d0b6c,%edx
f01016ca:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01016cd:	39 f0                	cmp    %esi,%eax
f01016cf:	74 19                	je     f01016ea <page_insert+0x89>
f01016d1:	83 ec 08             	sub    $0x8,%esp
f01016d4:	57                   	push   %edi
f01016d5:	ff 75 08             	pushl  0x8(%ebp)
f01016d8:	e8 02 01 00 00       	call   f01017df <page_remove>
f01016dd:	66 ff 46 08          	incw   0x8(%esi)
f01016e1:	83 c4 10             	add    $0x10,%esp
f01016e4:	eb 04                	jmp    f01016ea <page_insert+0x89>
f01016e6:	66 ff 46 08          	incw   0x8(%esi)

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01016ea:	89 f2                	mov    %esi,%edx
f01016ec:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f01016f2:	c1 fa 02             	sar    $0x2,%edx
f01016f5:	8d 04 92             	lea    (%edx,%edx,4),%eax
f01016f8:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01016fb:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01016fe:	89 c1                	mov    %eax,%ecx
f0101700:	c1 e1 08             	shl    $0x8,%ecx
f0101703:	01 c8                	add    %ecx,%eax
f0101705:	89 c1                	mov    %eax,%ecx
f0101707:	c1 e1 10             	shl    $0x10,%ecx
f010170a:	01 c8                	add    %ecx,%eax
f010170c:	8d 04 42             	lea    (%edx,%eax,2),%eax
f010170f:	c1 e0 0c             	shl    $0xc,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101712:	0b 45 14             	or     0x14(%ebp),%eax
f0101715:	83 c8 01             	or     $0x1,%eax
f0101718:	89 03                	mov    %eax,(%ebx)
f010171a:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    //ok
}
f010171f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0101722:	5b                   	pop    %ebx
f0101723:	5e                   	pop    %esi
f0101724:	5f                   	pop    %edi
f0101725:	c9                   	leave  
f0101726:	c3                   	ret    

f0101727 <boot_map_segment>:

//
// Map [la, la+size) of linear address space to physical [pa, pa+size)
// in the page table rooted at pgdir.  Size is a multiple of PGSIZE.
// Use permission bits perm|PTE_P for the entries.
//
// This function is only intended to set up the ``static'' mappings
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk

static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm) {
f0101727:	55                   	push   %ebp
f0101728:	89 e5                	mov    %esp,%ebp
f010172a:	57                   	push   %edi
f010172b:	56                   	push   %esi
f010172c:	53                   	push   %ebx
f010172d:	83 ec 0c             	sub    $0xc,%esp
f0101730:	8b 75 10             	mov    0x10(%ebp),%esi
f0101733:	8b 7d 18             	mov    0x18(%ebp),%edi
    // Fill this function in
    pte_t *addr;
    int i;
    for (i = 0; i < size; i += PGSIZE) {
f0101736:	bb 00 00 00 00       	mov    $0x0,%ebx
f010173b:	39 f3                	cmp    %esi,%ebx
f010173d:	73 2c                	jae    f010176b <boot_map_segment+0x44>
        addr = pgdir_walk(pgdir, (void *) (la + i), 1);
f010173f:	83 ec 04             	sub    $0x4,%esp
f0101742:	6a 01                	push   $0x1
f0101744:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101747:	01 d8                	add    %ebx,%eax
f0101749:	50                   	push   %eax
f010174a:	ff 75 08             	pushl  0x8(%ebp)
f010174d:	e8 bc fd ff ff       	call   f010150e <pgdir_walk>
        *addr = (pa + i) | perm|PTE_P;
f0101752:	8b 55 14             	mov    0x14(%ebp),%edx
f0101755:	01 da                	add    %ebx,%edx
f0101757:	09 fa                	or     %edi,%edx
f0101759:	83 ca 01             	or     $0x1,%edx
f010175c:	89 10                	mov    %edx,(%eax)
f010175e:	83 c4 10             	add    $0x10,%esp
f0101761:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101767:	39 f3                	cmp    %esi,%ebx
f0101769:	72 d4                	jb     f010173f <boot_map_segment+0x18>
    }
    //ok
}
f010176b:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010176e:	5b                   	pop    %ebx
f010176f:	5e                   	pop    %esi
f0101770:	5f                   	pop    %edi
f0101771:	c9                   	leave  
f0101772:	c3                   	ret    

f0101773 <page_lookup>:

//
// Return the page mapped at virtual address 'va'.
// If pte_store is not zero, then we store in it the address
// of the pte for this page.  This is used by page_remove
// but should not be used by other callers.
//
// Return 0 if there is no page mapped at va.
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//

struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store) {
f0101773:	55                   	push   %ebp
f0101774:	89 e5                	mov    %esp,%ebp
f0101776:	53                   	push   %ebx
f0101777:	83 ec 08             	sub    $0x8,%esp
f010177a:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // Fill this function in
    *pte_store = pgdir_walk(pgdir, va, 0);
f010177d:	6a 00                	push   $0x0
f010177f:	ff 75 0c             	pushl  0xc(%ebp)
f0101782:	ff 75 08             	pushl  0x8(%ebp)
f0101785:	e8 84 fd ff ff       	call   f010150e <pgdir_walk>
f010178a:	89 03                	mov    %eax,(%ebx)
    if ((*pte_store) && (**pte_store & PTE_P)) {
f010178c:	83 c4 10             	add    $0x10,%esp
f010178f:	85 c0                	test   %eax,%eax
f0101791:	74 42                	je     f01017d5 <page_lookup+0x62>
f0101793:	8b 00                	mov    (%eax),%eax
f0101795:	a8 01                	test   $0x1,%al
f0101797:	74 3c                	je     f01017d5 <page_lookup+0x62>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
f0101799:	89 c2                	mov    %eax,%edx
f010179b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PPN(pa) >= npage)
f01017a1:	89 d0                	mov    %edx,%eax
f01017a3:	c1 e8 0c             	shr    $0xc,%eax
f01017a6:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01017ac:	72 14                	jb     f01017c2 <page_lookup+0x4f>
		panic("pa2page called with invalid pa");
f01017ae:	83 ec 04             	sub    $0x4,%esp
f01017b1:	68 40 56 10 f0       	push   $0xf0105640
f01017b6:	6a 53                	push   $0x53
f01017b8:	68 52 5a 10 f0       	push   $0xf0105a52
f01017bd:	e8 22 e9 ff ff       	call   f01000e4 <_panic>
f01017c2:	89 d0                	mov    %edx,%eax
f01017c4:	c1 e8 0c             	shr    $0xc,%eax
f01017c7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01017ca:	8b 15 6c 0b 1d f0    	mov    0xf01d0b6c,%edx
f01017d0:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01017d3:	eb 05                	jmp    f01017da <page_lookup+0x67>
        return pa2page(PTE_ADDR(**pte_store));
    }
    return NULL;
f01017d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017da:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01017dd:	c9                   	leave  
f01017de:	c3                   	ret    

f01017df <page_remove>:

//
// Unmaps the physical page at virtual address 'va'.
// If there is no physical page at that address, silently does nothing.
//
// Details:
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
//   - The pg table entry corresponding to 'va' should be set to 0.
//     (if such a PTE exists)
//   - The TLB must be invalidated if you remove an entry from
//     the pg dir/pg table.
//
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01017df:	55                   	push   %ebp
f01017e0:	89 e5                	mov    %esp,%ebp
f01017e2:	56                   	push   %esi
f01017e3:	53                   	push   %ebx
f01017e4:	83 ec 14             	sub    $0x14,%esp
f01017e7:	8b 75 08             	mov    0x8(%ebp),%esi
f01017ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t *p;
    struct Page *pp;
    if ((pp = page_lookup(pgdir, va, &p))) {
f01017ed:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f01017f0:	50                   	push   %eax
f01017f1:	53                   	push   %ebx
f01017f2:	56                   	push   %esi
f01017f3:	e8 7b ff ff ff       	call   f0101773 <page_lookup>
f01017f8:	83 c4 10             	add    $0x10,%esp
f01017fb:	85 c0                	test   %eax,%eax
f01017fd:	74 1f                	je     f010181e <page_remove+0x3f>
        page_decref(pp);
f01017ff:	83 ec 0c             	sub    $0xc,%esp
f0101802:	50                   	push   %eax
f0101803:	e8 e4 fc ff ff       	call   f01014ec <page_decref>
        *p = 0; //set the page table entry as NULL
f0101808:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f010180b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, va);
f0101811:	83 c4 08             	add    $0x8,%esp
f0101814:	53                   	push   %ebx
f0101815:	56                   	push   %esi
f0101816:	e8 0a 00 00 00       	call   f0101825 <tlb_invalidate>
f010181b:	83 c4 10             	add    $0x10,%esp
    }
}
f010181e:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0101821:	5b                   	pop    %ebx
f0101822:	5e                   	pop    %esi
f0101823:	c9                   	leave  
f0101824:	c3                   	ret    

f0101825 <tlb_invalidate>:

//
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101825:	55                   	push   %ebp
f0101826:	89 e5                	mov    %esp,%ebp
f0101828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010182b:	83 3d c4 fe 1c f0 00 	cmpl   $0x0,0xf01cfec4
f0101832:	74 0e                	je     f0101842 <tlb_invalidate+0x1d>
f0101834:	8b 15 c4 fe 1c f0    	mov    0xf01cfec4,%edx
f010183a:	8b 45 08             	mov    0x8(%ebp),%eax
f010183d:	39 42 60             	cmp    %eax,0x60(%edx)
f0101840:	75 03                	jne    f0101845 <tlb_invalidate+0x20>

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101842:	0f 01 39             	invlpg (%ecx)
		invlpg(va);
}
f0101845:	c9                   	leave  
f0101846:	c3                   	ret    

f0101847 <user_mem_check>:

static uintptr_t user_mem_check_addr;

//
// Check that an environment is allowed to access the range of memory
// [va, va+len) with permissions 'perm | PTE_P'.
// Normally 'perm' will contain PTE_U at least, but this is not required.
// 'va' and 'len' need not be page-aligned; you must test every page that
// contains any of that range.  You will test either 'len/PGSIZE',
// 'len/PGSIZE + 1', or 'len/PGSIZE + 2' pages.
//
// A user program can access a virtual address if (1) the address is below
// ULIM, and (2) the page table gives it permission.  These are exactly
// the tests you should implement here.
//
// If there is an error, set the 'user_mem_check_addr' variable to the first
// erroneous virtual address.
//
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//

int
user_mem_check(struct Env *env, const void *va, size_t len, int perm) {
f0101847:	55                   	push   %ebp
f0101848:	89 e5                	mov    %esp,%ebp
f010184a:	57                   	push   %edi
f010184b:	56                   	push   %esi
f010184c:	53                   	push   %ebx
f010184d:	83 ec 0c             	sub    $0xc,%esp
    // LAB 3: Your code here.
    uintptr_t vp;
    pte_t * pgte;
    uintptr_t va_start = (uintptr_t)ROUNDDOWN(va,PGSIZE);
f0101850:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101853:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
    uintptr_t va_end = (uintptr_t)ROUNDUP(va+len-1,PGSIZE);
f0101856:	03 45 10             	add    0x10(%ebp),%eax
f0101859:	8d 80 fe 0f 00 00    	lea    0xffe(%eax),%eax
f010185f:	89 c7                	mov    %eax,%edi
f0101861:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    perm |= PTE_P;
f0101867:	8b 75 14             	mov    0x14(%ebp),%esi
f010186a:	83 ce 01             	or     $0x1,%esi
    for(vp = va_start;vp < va_end;vp += PGSIZE) {
f010186d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101870:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101876:	39 fb                	cmp    %edi,%ebx
f0101878:	73 4f                	jae    f01018c9 <user_mem_check+0x82>
        if(vp >= ULIM) {
f010187a:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101880:	76 08                	jbe    f010188a <user_mem_check+0x43>
            user_mem_check_addr = vp;
f0101882:	89 1d bc fe 1c f0    	mov    %ebx,0xf01cfebc
            return -E_FAULT;
f0101888:	eb 2e                	jmp    f01018b8 <user_mem_check+0x71>
        }
        pgte = pgdir_walk(env->env_pgdir,(void *)vp,0);
f010188a:	83 ec 04             	sub    $0x4,%esp
f010188d:	6a 00                	push   $0x0
f010188f:	53                   	push   %ebx
f0101890:	8b 55 08             	mov    0x8(%ebp),%edx
f0101893:	ff 72 60             	pushl  0x60(%edx)
f0101896:	e8 73 fc ff ff       	call   f010150e <pgdir_walk>
        if(!(pgte != NULL && (*pgte & perm) == perm)) {
f010189b:	83 c4 10             	add    $0x10,%esp
f010189e:	85 c0                	test   %eax,%eax
f01018a0:	74 08                	je     f01018aa <user_mem_check+0x63>
f01018a2:	89 f2                	mov    %esi,%edx
f01018a4:	23 10                	and    (%eax),%edx
f01018a6:	39 f2                	cmp    %esi,%edx
f01018a8:	74 15                	je     f01018bf <user_mem_check+0x78>
            user_mem_check_addr = (vp > (uintptr_t)va)?vp:(uintptr_t)va;
f01018aa:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01018ad:	39 d8                	cmp    %ebx,%eax
f01018af:	73 02                	jae    f01018b3 <user_mem_check+0x6c>
f01018b1:	89 d8                	mov    %ebx,%eax
f01018b3:	a3 bc fe 1c f0       	mov    %eax,0xf01cfebc
            return -E_FAULT;
f01018b8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01018bd:	eb 0f                	jmp    f01018ce <user_mem_check+0x87>
f01018bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01018c5:	39 fb                	cmp    %edi,%ebx
f01018c7:	72 b1                	jb     f010187a <user_mem_check+0x33>
        }
    }
    return 0;
f01018c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018ce:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01018d1:	5b                   	pop    %ebx
f01018d2:	5e                   	pop    %esi
f01018d3:	5f                   	pop    %edi
f01018d4:	c9                   	leave  
f01018d5:	c3                   	ret    

f01018d6 <user_mem_assert>:

//
// Checks that environment 'env' is allowed to access the range
// of memory [va, va+len) with permissions 'perm | PTE_U'.
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed.
//

void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm) {
f01018d6:	55                   	push   %ebp
f01018d7:	89 e5                	mov    %esp,%ebp
f01018d9:	53                   	push   %ebx
f01018da:	83 ec 04             	sub    $0x4,%esp
f01018dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01018e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01018e3:	83 c8 04             	or     $0x4,%eax
f01018e6:	50                   	push   %eax
f01018e7:	ff 75 10             	pushl  0x10(%ebp)
f01018ea:	ff 75 0c             	pushl  0xc(%ebp)
f01018ed:	53                   	push   %ebx
f01018ee:	e8 54 ff ff ff       	call   f0101847 <user_mem_check>
f01018f3:	83 c4 10             	add    $0x10,%esp
f01018f6:	85 c0                	test   %eax,%eax
f01018f8:	79 26                	jns    f0101920 <user_mem_assert+0x4a>
        cprintf("[%08x] user_mem_check assertion failure for "
f01018fa:	83 ec 04             	sub    $0x4,%esp
f01018fd:	ff 35 bc fe 1c f0    	pushl  0xf01cfebc
f0101903:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0101908:	ff 70 4c             	pushl  0x4c(%eax)
f010190b:	68 60 56 10 f0       	push   $0xf0105660
f0101910:	e8 5d 14 00 00       	call   f0102d72 <cprintf>
                "va %08x\n", curenv->env_id, user_mem_check_addr);
        env_destroy(env); // may not return
f0101915:	89 1c 24             	mov    %ebx,(%esp)
f0101918:	e8 c5 11 00 00       	call   f0102ae2 <env_destroy>
f010191d:	83 c4 10             	add    $0x10,%esp
    }
}
f0101920:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0101923:	c9                   	leave  
f0101924:	c3                   	ret    

f0101925 <page_check>:

// check page_insert, page_remove, &c

static void
page_check(void) {
f0101925:	55                   	push   %ebp
f0101926:	89 e5                	mov    %esp,%ebp
f0101928:	56                   	push   %esi
f0101929:	53                   	push   %ebx
f010192a:	83 ec 2c             	sub    $0x2c,%esp
    struct Page *pp, *pp0, *pp1, *pp2;
    struct Page_list fl;
    pte_t *ptep, *ptep1;
    void *va;
    int i;

    // should be able to allocate three pages
    pp0 = pp1 = pp2 = 0;
f010192d:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f0101934:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f010193b:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
    assert(page_alloc(&pp0) == 0);
f0101942:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0101945:	50                   	push   %eax
f0101946:	e8 30 fb ff ff       	call   f010147b <page_alloc>
f010194b:	83 c4 10             	add    $0x10,%esp
f010194e:	85 c0                	test   %eax,%eax
f0101950:	74 14                	je     f0101966 <page_check+0x41>
f0101952:	68 5e 5a 10 f0       	push   $0xf0105a5e
f0101957:	68 74 5a 10 f0       	push   $0xf0105a74
f010195c:	68 2d 03 00 00       	push   $0x32d
f0101961:	e9 bf 0a 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(page_alloc(&pp1) == 0);
f0101966:	83 ec 0c             	sub    $0xc,%esp
f0101969:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f010196c:	50                   	push   %eax
f010196d:	e8 09 fb ff ff       	call   f010147b <page_alloc>
f0101972:	83 c4 10             	add    $0x10,%esp
f0101975:	85 c0                	test   %eax,%eax
f0101977:	74 14                	je     f010198d <page_check+0x68>
f0101979:	68 89 5a 10 f0       	push   $0xf0105a89
f010197e:	68 74 5a 10 f0       	push   $0xf0105a74
f0101983:	68 2e 03 00 00       	push   $0x32e
f0101988:	e9 98 0a 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(page_alloc(&pp2) == 0);
f010198d:	83 ec 0c             	sub    $0xc,%esp
f0101990:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0101993:	50                   	push   %eax
f0101994:	e8 e2 fa ff ff       	call   f010147b <page_alloc>
f0101999:	83 c4 10             	add    $0x10,%esp
f010199c:	85 c0                	test   %eax,%eax
f010199e:	74 14                	je     f01019b4 <page_check+0x8f>
f01019a0:	68 9f 5a 10 f0       	push   $0xf0105a9f
f01019a5:	68 74 5a 10 f0       	push   $0xf0105a74
f01019aa:	68 2f 03 00 00       	push   $0x32f
f01019af:	e9 71 0a 00 00       	jmp    f0102425 <page_check+0xb00>

    assert(pp0);
f01019b4:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f01019b8:	75 14                	jne    f01019ce <page_check+0xa9>
f01019ba:	68 c3 5a 10 f0       	push   $0xf0105ac3
f01019bf:	68 74 5a 10 f0       	push   $0xf0105a74
f01019c4:	68 31 03 00 00       	push   $0x331
f01019c9:	e9 57 0a 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp1 && pp1 != pp0);
f01019ce:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f01019d2:	74 08                	je     f01019dc <page_check+0xb7>
f01019d4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01019d7:	3b 45 f4             	cmp    0xfffffff4(%ebp),%eax
f01019da:	75 14                	jne    f01019f0 <page_check+0xcb>
f01019dc:	68 b5 5a 10 f0       	push   $0xf0105ab5
f01019e1:	68 74 5a 10 f0       	push   $0xf0105a74
f01019e6:	68 32 03 00 00       	push   $0x332
f01019eb:	e9 35 0a 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019f0:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f01019f4:	74 0d                	je     f0101a03 <page_check+0xde>
f01019f6:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01019f9:	3b 45 f0             	cmp    0xfffffff0(%ebp),%eax
f01019fc:	74 05                	je     f0101a03 <page_check+0xde>
f01019fe:	3b 45 f4             	cmp    0xfffffff4(%ebp),%eax
f0101a01:	75 14                	jne    f0101a17 <page_check+0xf2>
f0101a03:	68 08 55 10 f0       	push   $0xf0105508
f0101a08:	68 74 5a 10 f0       	push   $0xf0105a74
f0101a0d:	68 33 03 00 00       	push   $0x333
f0101a12:	e9 0e 0a 00 00       	jmp    f0102425 <page_check+0xb00>

    // temporarily steal the rest of the free pages
    fl = page_free_list;
f0101a17:	8b 35 b8 fe 1c f0    	mov    0xf01cfeb8,%esi
    LIST_INIT(&page_free_list);
f0101a1d:	c7 05 b8 fe 1c f0 00 	movl   $0x0,0xf01cfeb8
f0101a24:	00 00 00 

    // should be no free memory
    assert(page_alloc(&pp) == -E_NO_MEM);
f0101a27:	83 ec 0c             	sub    $0xc,%esp
f0101a2a:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101a2d:	50                   	push   %eax
f0101a2e:	e8 48 fa ff ff       	call   f010147b <page_alloc>
f0101a33:	83 c4 10             	add    $0x10,%esp
f0101a36:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101a39:	74 14                	je     f0101a4f <page_check+0x12a>
f0101a3b:	68 21 5b 10 f0       	push   $0xf0105b21
f0101a40:	68 74 5a 10 f0       	push   $0xf0105a74
f0101a45:	68 3a 03 00 00       	push   $0x33a
f0101a4a:	e9 d6 09 00 00       	jmp    f0102425 <page_check+0xb00>

    // there is no page allocated at address 0
    assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a4f:	83 ec 04             	sub    $0x4,%esp
f0101a52:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
f0101a55:	50                   	push   %eax
f0101a56:	6a 00                	push   $0x0
f0101a58:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101a5e:	e8 10 fd ff ff       	call   f0101773 <page_lookup>
f0101a63:	83 c4 10             	add    $0x10,%esp
f0101a66:	85 c0                	test   %eax,%eax
f0101a68:	74 14                	je     f0101a7e <page_check+0x159>
f0101a6a:	68 98 56 10 f0       	push   $0xf0105698
f0101a6f:	68 74 5a 10 f0       	push   $0xf0105a74
f0101a74:	68 3d 03 00 00       	push   $0x33d
f0101a79:	e9 a7 09 00 00       	jmp    f0102425 <page_check+0xb00>

    // there is no free memory, so we can't allocate a page table
    assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0101a7e:	6a 00                	push   $0x0
f0101a80:	6a 00                	push   $0x0
f0101a82:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101a85:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101a8b:	e8 d1 fb ff ff       	call   f0101661 <page_insert>
f0101a90:	83 c4 10             	add    $0x10,%esp
f0101a93:	85 c0                	test   %eax,%eax
f0101a95:	78 14                	js     f0101aab <page_check+0x186>
f0101a97:	68 d0 56 10 f0       	push   $0xf01056d0
f0101a9c:	68 74 5a 10 f0       	push   $0xf0105a74
f0101aa1:	68 40 03 00 00       	push   $0x340
f0101aa6:	e9 7a 09 00 00       	jmp    f0102425 <page_check+0xb00>

    // free pp0 and try again: pp0 should be used for page table
    page_free(pp0);
f0101aab:	83 ec 0c             	sub    $0xc,%esp
f0101aae:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0101ab1:	e8 07 fa ff ff       	call   f01014bd <page_free>
    assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f0101ab6:	6a 00                	push   $0x0
f0101ab8:	6a 00                	push   $0x0
f0101aba:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101abd:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101ac3:	e8 99 fb ff ff       	call   f0101661 <page_insert>
f0101ac8:	83 c4 20             	add    $0x20,%esp
f0101acb:	85 c0                	test   %eax,%eax
f0101acd:	74 14                	je     f0101ae3 <page_check+0x1be>
f0101acf:	68 fc 56 10 f0       	push   $0xf01056fc
f0101ad4:	68 74 5a 10 f0       	push   $0xf0105a74
f0101ad9:	68 44 03 00 00       	push   $0x344
f0101ade:	e9 42 09 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0101ae3:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f0101ae8:	8b 18                	mov    (%eax),%ebx
f0101aea:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101af0:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0101af3:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0101af9:	c1 fa 02             	sar    $0x2,%edx
f0101afc:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0101aff:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0101b02:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0101b05:	89 c1                	mov    %eax,%ecx
f0101b07:	c1 e1 08             	shl    $0x8,%ecx
f0101b0a:	01 c8                	add    %ecx,%eax
f0101b0c:	89 c1                	mov    %eax,%ecx
f0101b0e:	c1 e1 10             	shl    $0x10,%ecx
f0101b11:	01 c8                	add    %ecx,%eax
f0101b13:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0101b16:	c1 e0 0c             	shl    $0xc,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101b19:	39 c3                	cmp    %eax,%ebx
f0101b1b:	74 14                	je     f0101b31 <page_check+0x20c>
f0101b1d:	68 28 57 10 f0       	push   $0xf0105728
f0101b22:	68 74 5a 10 f0       	push   $0xf0105a74
f0101b27:	68 45 03 00 00       	push   $0x345
f0101b2c:	e9 f4 08 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f0101b31:	83 ec 08             	sub    $0x8,%esp
f0101b34:	6a 00                	push   $0x0
f0101b36:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101b3c:	e8 48 f7 ff ff       	call   f0101289 <check_va2pa>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101b41:	83 c4 10             	add    $0x10,%esp
f0101b44:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101b47:	2b 0d 6c 0b 1d f0    	sub    0xf01d0b6c,%ecx
f0101b4d:	c1 f9 02             	sar    $0x2,%ecx
f0101b50:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101b53:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101b56:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101b59:	89 d3                	mov    %edx,%ebx
f0101b5b:	c1 e3 08             	shl    $0x8,%ebx
f0101b5e:	01 da                	add    %ebx,%edx
f0101b60:	89 d3                	mov    %edx,%ebx
f0101b62:	c1 e3 10             	shl    $0x10,%ebx
f0101b65:	01 da                	add    %ebx,%edx
f0101b67:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101b6a:	c1 e2 0c             	shl    $0xc,%edx
f0101b6d:	39 d0                	cmp    %edx,%eax
f0101b6f:	74 14                	je     f0101b85 <page_check+0x260>
f0101b71:	68 50 57 10 f0       	push   $0xf0105750
f0101b76:	68 74 5a 10 f0       	push   $0xf0105a74
f0101b7b:	68 46 03 00 00       	push   $0x346
f0101b80:	e9 a0 08 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp1->pp_ref == 1);
f0101b85:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101b88:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101b8d:	74 14                	je     f0101ba3 <page_check+0x27e>
f0101b8f:	68 55 5b 10 f0       	push   $0xf0105b55
f0101b94:	68 74 5a 10 f0       	push   $0xf0105a74
f0101b99:	68 47 03 00 00       	push   $0x347
f0101b9e:	e9 82 08 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp0->pp_ref == 1);
f0101ba3:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0101ba6:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101bab:	74 14                	je     f0101bc1 <page_check+0x29c>
f0101bad:	68 66 5b 10 f0       	push   $0xf0105b66
f0101bb2:	68 74 5a 10 f0       	push   $0xf0105a74
f0101bb7:	68 48 03 00 00       	push   $0x348
f0101bbc:	e9 64 08 00 00       	jmp    f0102425 <page_check+0xb00>

    // should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
    assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101bc1:	6a 00                	push   $0x0
f0101bc3:	68 00 10 00 00       	push   $0x1000
f0101bc8:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0101bcb:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101bd1:	e8 8b fa ff ff       	call   f0101661 <page_insert>
f0101bd6:	83 c4 10             	add    $0x10,%esp
f0101bd9:	85 c0                	test   %eax,%eax
f0101bdb:	74 14                	je     f0101bf1 <page_check+0x2cc>
f0101bdd:	68 80 57 10 f0       	push   $0xf0105780
f0101be2:	68 74 5a 10 f0       	push   $0xf0105a74
f0101be7:	68 4b 03 00 00       	push   $0x34b
f0101bec:	e9 34 08 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101bf1:	83 ec 08             	sub    $0x8,%esp
f0101bf4:	68 00 10 00 00       	push   $0x1000
f0101bf9:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101bff:	e8 85 f6 ff ff       	call   f0101289 <check_va2pa>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101c04:	83 c4 10             	add    $0x10,%esp
f0101c07:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101c0a:	2b 0d 6c 0b 1d f0    	sub    0xf01d0b6c,%ecx
f0101c10:	c1 f9 02             	sar    $0x2,%ecx
f0101c13:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101c16:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101c19:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101c1c:	89 d3                	mov    %edx,%ebx
f0101c1e:	c1 e3 08             	shl    $0x8,%ebx
f0101c21:	01 da                	add    %ebx,%edx
f0101c23:	89 d3                	mov    %edx,%ebx
f0101c25:	c1 e3 10             	shl    $0x10,%ebx
f0101c28:	01 da                	add    %ebx,%edx
f0101c2a:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101c2d:	c1 e2 0c             	shl    $0xc,%edx
f0101c30:	39 d0                	cmp    %edx,%eax
f0101c32:	74 14                	je     f0101c48 <page_check+0x323>
f0101c34:	68 b8 57 10 f0       	push   $0xf01057b8
f0101c39:	68 74 5a 10 f0       	push   $0xf0105a74
f0101c3e:	68 4c 03 00 00       	push   $0x34c
f0101c43:	e9 dd 07 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp2->pp_ref == 1);
f0101c48:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101c4b:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101c50:	74 14                	je     f0101c66 <page_check+0x341>
f0101c52:	68 77 5b 10 f0       	push   $0xf0105b77
f0101c57:	68 74 5a 10 f0       	push   $0xf0105a74
f0101c5c:	68 4d 03 00 00       	push   $0x34d
f0101c61:	e9 bf 07 00 00       	jmp    f0102425 <page_check+0xb00>

    // should be no free memory
    assert(page_alloc(&pp) == -E_NO_MEM);
f0101c66:	83 ec 0c             	sub    $0xc,%esp
f0101c69:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101c6c:	50                   	push   %eax
f0101c6d:	e8 09 f8 ff ff       	call   f010147b <page_alloc>
f0101c72:	83 c4 10             	add    $0x10,%esp
f0101c75:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101c78:	74 14                	je     f0101c8e <page_check+0x369>
f0101c7a:	68 21 5b 10 f0       	push   $0xf0105b21
f0101c7f:	68 74 5a 10 f0       	push   $0xf0105a74
f0101c84:	68 50 03 00 00       	push   $0x350
f0101c89:	e9 97 07 00 00       	jmp    f0102425 <page_check+0xb00>

    // should be able to map pp2 at PGSIZE because it's already there
    assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101c8e:	6a 00                	push   $0x0
f0101c90:	68 00 10 00 00       	push   $0x1000
f0101c95:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0101c98:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101c9e:	e8 be f9 ff ff       	call   f0101661 <page_insert>
f0101ca3:	83 c4 10             	add    $0x10,%esp
f0101ca6:	85 c0                	test   %eax,%eax
f0101ca8:	74 14                	je     f0101cbe <page_check+0x399>
f0101caa:	68 80 57 10 f0       	push   $0xf0105780
f0101caf:	68 74 5a 10 f0       	push   $0xf0105a74
f0101cb4:	68 53 03 00 00       	push   $0x353
f0101cb9:	e9 67 07 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101cbe:	83 ec 08             	sub    $0x8,%esp
f0101cc1:	68 00 10 00 00       	push   $0x1000
f0101cc6:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101ccc:	e8 b8 f5 ff ff       	call   f0101289 <check_va2pa>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101cd1:	83 c4 10             	add    $0x10,%esp
f0101cd4:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101cd7:	2b 0d 6c 0b 1d f0    	sub    0xf01d0b6c,%ecx
f0101cdd:	c1 f9 02             	sar    $0x2,%ecx
f0101ce0:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101ce3:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101ce6:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101ce9:	89 d3                	mov    %edx,%ebx
f0101ceb:	c1 e3 08             	shl    $0x8,%ebx
f0101cee:	01 da                	add    %ebx,%edx
f0101cf0:	89 d3                	mov    %edx,%ebx
f0101cf2:	c1 e3 10             	shl    $0x10,%ebx
f0101cf5:	01 da                	add    %ebx,%edx
f0101cf7:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101cfa:	c1 e2 0c             	shl    $0xc,%edx
f0101cfd:	39 d0                	cmp    %edx,%eax
f0101cff:	74 14                	je     f0101d15 <page_check+0x3f0>
f0101d01:	68 b8 57 10 f0       	push   $0xf01057b8
f0101d06:	68 74 5a 10 f0       	push   $0xf0105a74
f0101d0b:	68 54 03 00 00       	push   $0x354
f0101d10:	e9 10 07 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp2->pp_ref == 1);
f0101d15:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101d18:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101d1d:	74 14                	je     f0101d33 <page_check+0x40e>
f0101d1f:	68 77 5b 10 f0       	push   $0xf0105b77
f0101d24:	68 74 5a 10 f0       	push   $0xf0105a74
f0101d29:	68 55 03 00 00       	push   $0x355
f0101d2e:	e9 f2 06 00 00       	jmp    f0102425 <page_check+0xb00>

    // pp2 should NOT be on the free list
    // could happen in ref counts are handled sloppily in page_insert
    assert(page_alloc(&pp) == -E_NO_MEM);
f0101d33:	83 ec 0c             	sub    $0xc,%esp
f0101d36:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101d39:	50                   	push   %eax
f0101d3a:	e8 3c f7 ff ff       	call   f010147b <page_alloc>
f0101d3f:	83 c4 10             	add    $0x10,%esp
f0101d42:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101d45:	74 14                	je     f0101d5b <page_check+0x436>
f0101d47:	68 21 5b 10 f0       	push   $0xf0105b21
f0101d4c:	68 74 5a 10 f0       	push   $0xf0105a74
f0101d51:	68 59 03 00 00       	push   $0x359
f0101d56:	e9 ca 06 00 00       	jmp    f0102425 <page_check+0xb00>

    // check that pgdir_walk returns a pointer to the pte
    ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0101d5b:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f0101d60:	8b 10                	mov    (%eax),%edx
f0101d62:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d68:	89 d0                	mov    %edx,%eax
f0101d6a:	c1 e8 0c             	shr    $0xc,%eax
f0101d6d:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f0101d73:	72 10                	jb     f0101d85 <page_check+0x460>
f0101d75:	52                   	push   %edx
f0101d76:	68 e4 54 10 f0       	push   $0xf01054e4
f0101d7b:	68 5c 03 00 00       	push   $0x35c
f0101d80:	e9 a0 06 00 00       	jmp    f0102425 <page_check+0xb00>
f0101d85:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0101d8b:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
    assert(pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) == ptep + PTX(PGSIZE));
f0101d8e:	83 ec 04             	sub    $0x4,%esp
f0101d91:	6a 00                	push   $0x0
f0101d93:	68 00 10 00 00       	push   $0x1000
f0101d98:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101d9e:	e8 6b f7 ff ff       	call   f010150e <pgdir_walk>
f0101da3:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0101da6:	83 c2 04             	add    $0x4,%edx
f0101da9:	83 c4 10             	add    $0x10,%esp
f0101dac:	39 d0                	cmp    %edx,%eax
f0101dae:	74 14                	je     f0101dc4 <page_check+0x49f>
f0101db0:	68 e8 57 10 f0       	push   $0xf01057e8
f0101db5:	68 74 5a 10 f0       	push   $0xf0105a74
f0101dba:	68 5d 03 00 00       	push   $0x35d
f0101dbf:	e9 61 06 00 00       	jmp    f0102425 <page_check+0xb00>

    // should be able to change permissions too.
    assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0101dc4:	6a 04                	push   $0x4
f0101dc6:	68 00 10 00 00       	push   $0x1000
f0101dcb:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0101dce:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101dd4:	e8 88 f8 ff ff       	call   f0101661 <page_insert>
f0101dd9:	83 c4 10             	add    $0x10,%esp
f0101ddc:	85 c0                	test   %eax,%eax
f0101dde:	74 14                	je     f0101df4 <page_check+0x4cf>
f0101de0:	68 28 58 10 f0       	push   $0xf0105828
f0101de5:	68 74 5a 10 f0       	push   $0xf0105a74
f0101dea:	68 60 03 00 00       	push   $0x360
f0101def:	e9 31 06 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101df4:	83 ec 08             	sub    $0x8,%esp
f0101df7:	68 00 10 00 00       	push   $0x1000
f0101dfc:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101e02:	e8 82 f4 ff ff       	call   f0101289 <check_va2pa>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101e07:	83 c4 10             	add    $0x10,%esp
f0101e0a:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101e0d:	2b 0d 6c 0b 1d f0    	sub    0xf01d0b6c,%ecx
f0101e13:	c1 f9 02             	sar    $0x2,%ecx
f0101e16:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101e19:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101e1c:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101e1f:	89 d3                	mov    %edx,%ebx
f0101e21:	c1 e3 08             	shl    $0x8,%ebx
f0101e24:	01 da                	add    %ebx,%edx
f0101e26:	89 d3                	mov    %edx,%ebx
f0101e28:	c1 e3 10             	shl    $0x10,%ebx
f0101e2b:	01 da                	add    %ebx,%edx
f0101e2d:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101e30:	c1 e2 0c             	shl    $0xc,%edx
f0101e33:	39 d0                	cmp    %edx,%eax
f0101e35:	74 14                	je     f0101e4b <page_check+0x526>
f0101e37:	68 b8 57 10 f0       	push   $0xf01057b8
f0101e3c:	68 74 5a 10 f0       	push   $0xf0105a74
f0101e41:	68 61 03 00 00       	push   $0x361
f0101e46:	e9 da 05 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp2->pp_ref == 1);
f0101e4b:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101e4e:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101e53:	74 14                	je     f0101e69 <page_check+0x544>
f0101e55:	68 77 5b 10 f0       	push   $0xf0105b77
f0101e5a:	68 74 5a 10 f0       	push   $0xf0105a74
f0101e5f:	68 62 03 00 00       	push   $0x362
f0101e64:	e9 bc 05 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e69:	83 ec 04             	sub    $0x4,%esp
f0101e6c:	6a 00                	push   $0x0
f0101e6e:	68 00 10 00 00       	push   $0x1000
f0101e73:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101e79:	e8 90 f6 ff ff       	call   f010150e <pgdir_walk>
f0101e7e:	83 c4 10             	add    $0x10,%esp
f0101e81:	f6 00 04             	testb  $0x4,(%eax)
f0101e84:	75 14                	jne    f0101e9a <page_check+0x575>
f0101e86:	68 64 58 10 f0       	push   $0xf0105864
f0101e8b:	68 74 5a 10 f0       	push   $0xf0105a74
f0101e90:	68 63 03 00 00       	push   $0x363
f0101e95:	e9 8b 05 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(boot_pgdir[0] & PTE_U);
f0101e9a:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f0101e9f:	f6 00 04             	testb  $0x4,(%eax)
f0101ea2:	75 14                	jne    f0101eb8 <page_check+0x593>
f0101ea4:	68 88 5b 10 f0       	push   $0xf0105b88
f0101ea9:	68 74 5a 10 f0       	push   $0xf0105a74
f0101eae:	68 64 03 00 00       	push   $0x364
f0101eb3:	e9 6d 05 00 00       	jmp    f0102425 <page_check+0xb00>

    // should not be able to map at PTSIZE because need free page for page table
    assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101eb8:	6a 00                	push   $0x0
f0101eba:	68 00 00 40 00       	push   $0x400000
f0101ebf:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0101ec2:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101ec8:	e8 94 f7 ff ff       	call   f0101661 <page_insert>
f0101ecd:	83 c4 10             	add    $0x10,%esp
f0101ed0:	85 c0                	test   %eax,%eax
f0101ed2:	78 14                	js     f0101ee8 <page_check+0x5c3>
f0101ed4:	68 98 58 10 f0       	push   $0xf0105898
f0101ed9:	68 74 5a 10 f0       	push   $0xf0105a74
f0101ede:	68 67 03 00 00       	push   $0x367
f0101ee3:	e9 3d 05 00 00       	jmp    f0102425 <page_check+0xb00>

    // insert pp1 at PGSIZE (replacing pp2)
    assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101ee8:	6a 00                	push   $0x0
f0101eea:	68 00 10 00 00       	push   $0x1000
f0101eef:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101ef2:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101ef8:	e8 64 f7 ff ff       	call   f0101661 <page_insert>
f0101efd:	83 c4 10             	add    $0x10,%esp
f0101f00:	85 c0                	test   %eax,%eax
f0101f02:	74 14                	je     f0101f18 <page_check+0x5f3>
f0101f04:	68 cc 58 10 f0       	push   $0xf01058cc
f0101f09:	68 74 5a 10 f0       	push   $0xf0105a74
f0101f0e:	68 6a 03 00 00       	push   $0x36a
f0101f13:	e9 0d 05 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(!(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f18:	83 ec 04             	sub    $0x4,%esp
f0101f1b:	6a 00                	push   $0x0
f0101f1d:	68 00 10 00 00       	push   $0x1000
f0101f22:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101f28:	e8 e1 f5 ff ff       	call   f010150e <pgdir_walk>
f0101f2d:	83 c4 10             	add    $0x10,%esp
f0101f30:	f6 00 04             	testb  $0x4,(%eax)
f0101f33:	74 14                	je     f0101f49 <page_check+0x624>
f0101f35:	68 04 59 10 f0       	push   $0xf0105904
f0101f3a:	68 74 5a 10 f0       	push   $0xf0105a74
f0101f3f:	68 6b 03 00 00       	push   $0x36b
f0101f44:	e9 dc 04 00 00       	jmp    f0102425 <page_check+0xb00>

    // should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
    assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0101f49:	83 ec 08             	sub    $0x8,%esp
f0101f4c:	6a 00                	push   $0x0
f0101f4e:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101f54:	e8 30 f3 ff ff       	call   f0101289 <check_va2pa>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101f59:	83 c4 10             	add    $0x10,%esp
f0101f5c:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101f5f:	2b 0d 6c 0b 1d f0    	sub    0xf01d0b6c,%ecx
f0101f65:	c1 f9 02             	sar    $0x2,%ecx
f0101f68:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101f6b:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101f6e:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101f71:	89 d3                	mov    %edx,%ebx
f0101f73:	c1 e3 08             	shl    $0x8,%ebx
f0101f76:	01 da                	add    %ebx,%edx
f0101f78:	89 d3                	mov    %edx,%ebx
f0101f7a:	c1 e3 10             	shl    $0x10,%ebx
f0101f7d:	01 da                	add    %ebx,%edx
f0101f7f:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101f82:	c1 e2 0c             	shl    $0xc,%edx
f0101f85:	39 d0                	cmp    %edx,%eax
f0101f87:	74 14                	je     f0101f9d <page_check+0x678>
f0101f89:	68 3c 59 10 f0       	push   $0xf010593c
f0101f8e:	68 74 5a 10 f0       	push   $0xf0105a74
f0101f93:	68 6e 03 00 00       	push   $0x36e
f0101f98:	e9 88 04 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101f9d:	83 ec 08             	sub    $0x8,%esp
f0101fa0:	68 00 10 00 00       	push   $0x1000
f0101fa5:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f0101fab:	e8 d9 f2 ff ff       	call   f0101289 <check_va2pa>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101fb0:	83 c4 10             	add    $0x10,%esp
f0101fb3:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101fb6:	2b 0d 6c 0b 1d f0    	sub    0xf01d0b6c,%ecx
f0101fbc:	c1 f9 02             	sar    $0x2,%ecx
f0101fbf:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101fc2:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101fc5:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0101fc8:	89 d3                	mov    %edx,%ebx
f0101fca:	c1 e3 08             	shl    $0x8,%ebx
f0101fcd:	01 da                	add    %ebx,%edx
f0101fcf:	89 d3                	mov    %edx,%ebx
f0101fd1:	c1 e3 10             	shl    $0x10,%ebx
f0101fd4:	01 da                	add    %ebx,%edx
f0101fd6:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101fd9:	c1 e2 0c             	shl    $0xc,%edx
f0101fdc:	39 d0                	cmp    %edx,%eax
f0101fde:	74 14                	je     f0101ff4 <page_check+0x6cf>
f0101fe0:	68 68 59 10 f0       	push   $0xf0105968
f0101fe5:	68 74 5a 10 f0       	push   $0xf0105a74
f0101fea:	68 6f 03 00 00       	push   $0x36f
f0101fef:	e9 31 04 00 00       	jmp    f0102425 <page_check+0xb00>
    // ... and ref counts should reflect this
    assert(pp1->pp_ref == 2);
f0101ff4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101ff7:	66 83 78 08 02       	cmpw   $0x2,0x8(%eax)
f0101ffc:	74 14                	je     f0102012 <page_check+0x6ed>
f0101ffe:	68 9e 5b 10 f0       	push   $0xf0105b9e
f0102003:	68 74 5a 10 f0       	push   $0xf0105a74
f0102008:	68 71 03 00 00       	push   $0x371
f010200d:	e9 13 04 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp2->pp_ref == 0);
f0102012:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102015:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010201a:	74 14                	je     f0102030 <page_check+0x70b>
f010201c:	68 af 5b 10 f0       	push   $0xf0105baf
f0102021:	68 74 5a 10 f0       	push   $0xf0105a74
f0102026:	68 72 03 00 00       	push   $0x372
f010202b:	e9 f5 03 00 00       	jmp    f0102425 <page_check+0xb00>

    // pp2 should be returned by page_alloc
    assert(page_alloc(&pp) == 0 && pp == pp2);
f0102030:	83 ec 0c             	sub    $0xc,%esp
f0102033:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0102036:	50                   	push   %eax
f0102037:	e8 3f f4 ff ff       	call   f010147b <page_alloc>
f010203c:	83 c4 10             	add    $0x10,%esp
f010203f:	85 c0                	test   %eax,%eax
f0102041:	75 08                	jne    f010204b <page_check+0x726>
f0102043:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0102046:	3b 45 ec             	cmp    0xffffffec(%ebp),%eax
f0102049:	74 14                	je     f010205f <page_check+0x73a>
f010204b:	68 98 59 10 f0       	push   $0xf0105998
f0102050:	68 74 5a 10 f0       	push   $0xf0105a74
f0102055:	68 75 03 00 00       	push   $0x375
f010205a:	e9 c6 03 00 00       	jmp    f0102425 <page_check+0xb00>

    // unmapping pp1 at 0 should keep pp1 at PGSIZE
    page_remove(boot_pgdir, 0x0);
f010205f:	83 ec 08             	sub    $0x8,%esp
f0102062:	6a 00                	push   $0x0
f0102064:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f010206a:	e8 70 f7 ff ff       	call   f01017df <page_remove>
    assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f010206f:	83 c4 08             	add    $0x8,%esp
f0102072:	6a 00                	push   $0x0
f0102074:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f010207a:	e8 0a f2 ff ff       	call   f0101289 <check_va2pa>
f010207f:	83 c4 10             	add    $0x10,%esp
f0102082:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102085:	74 14                	je     f010209b <page_check+0x776>
f0102087:	68 bc 59 10 f0       	push   $0xf01059bc
f010208c:	68 74 5a 10 f0       	push   $0xf0105a74
f0102091:	68 79 03 00 00       	push   $0x379
f0102096:	e9 8a 03 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f010209b:	83 ec 08             	sub    $0x8,%esp
f010209e:	68 00 10 00 00       	push   $0x1000
f01020a3:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f01020a9:	e8 db f1 ff ff       	call   f0101289 <check_va2pa>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f01020ae:	83 c4 10             	add    $0x10,%esp
f01020b1:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f01020b4:	2b 0d 6c 0b 1d f0    	sub    0xf01d0b6c,%ecx
f01020ba:	c1 f9 02             	sar    $0x2,%ecx
f01020bd:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f01020c0:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f01020c3:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f01020c6:	89 d3                	mov    %edx,%ebx
f01020c8:	c1 e3 08             	shl    $0x8,%ebx
f01020cb:	01 da                	add    %ebx,%edx
f01020cd:	89 d3                	mov    %edx,%ebx
f01020cf:	c1 e3 10             	shl    $0x10,%ebx
f01020d2:	01 da                	add    %ebx,%edx
f01020d4:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f01020d7:	c1 e2 0c             	shl    $0xc,%edx
f01020da:	39 d0                	cmp    %edx,%eax
f01020dc:	74 14                	je     f01020f2 <page_check+0x7cd>
f01020de:	68 68 59 10 f0       	push   $0xf0105968
f01020e3:	68 74 5a 10 f0       	push   $0xf0105a74
f01020e8:	68 7a 03 00 00       	push   $0x37a
f01020ed:	e9 33 03 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp1->pp_ref == 1);
f01020f2:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01020f5:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f01020fa:	74 14                	je     f0102110 <page_check+0x7eb>
f01020fc:	68 55 5b 10 f0       	push   $0xf0105b55
f0102101:	68 74 5a 10 f0       	push   $0xf0105a74
f0102106:	68 7b 03 00 00       	push   $0x37b
f010210b:	e9 15 03 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp2->pp_ref == 0);
f0102110:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102113:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102118:	74 14                	je     f010212e <page_check+0x809>
f010211a:	68 af 5b 10 f0       	push   $0xf0105baf
f010211f:	68 74 5a 10 f0       	push   $0xf0105a74
f0102124:	68 7c 03 00 00       	push   $0x37c
f0102129:	e9 f7 02 00 00       	jmp    f0102425 <page_check+0xb00>

    // unmapping pp1 at PGSIZE should free it
    page_remove(boot_pgdir, (void*) PGSIZE);
f010212e:	83 ec 08             	sub    $0x8,%esp
f0102131:	68 00 10 00 00       	push   $0x1000
f0102136:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f010213c:	e8 9e f6 ff ff       	call   f01017df <page_remove>
    assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0102141:	83 c4 08             	add    $0x8,%esp
f0102144:	6a 00                	push   $0x0
f0102146:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f010214c:	e8 38 f1 ff ff       	call   f0101289 <check_va2pa>
f0102151:	83 c4 10             	add    $0x10,%esp
f0102154:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102157:	74 14                	je     f010216d <page_check+0x848>
f0102159:	68 bc 59 10 f0       	push   $0xf01059bc
f010215e:	68 74 5a 10 f0       	push   $0xf0105a74
f0102163:	68 80 03 00 00       	push   $0x380
f0102168:	e9 b8 02 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f010216d:	83 ec 08             	sub    $0x8,%esp
f0102170:	68 00 10 00 00       	push   $0x1000
f0102175:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f010217b:	e8 09 f1 ff ff       	call   f0101289 <check_va2pa>
f0102180:	83 c4 10             	add    $0x10,%esp
f0102183:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102186:	74 14                	je     f010219c <page_check+0x877>
f0102188:	68 e0 59 10 f0       	push   $0xf01059e0
f010218d:	68 74 5a 10 f0       	push   $0xf0105a74
f0102192:	68 81 03 00 00       	push   $0x381
f0102197:	e9 89 02 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp1->pp_ref == 0);
f010219c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010219f:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01021a4:	74 14                	je     f01021ba <page_check+0x895>
f01021a6:	68 c0 5b 10 f0       	push   $0xf0105bc0
f01021ab:	68 74 5a 10 f0       	push   $0xf0105a74
f01021b0:	68 82 03 00 00       	push   $0x382
f01021b5:	e9 6b 02 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(pp2->pp_ref == 0);
f01021ba:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01021bd:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01021c2:	74 14                	je     f01021d8 <page_check+0x8b3>
f01021c4:	68 af 5b 10 f0       	push   $0xf0105baf
f01021c9:	68 74 5a 10 f0       	push   $0xf0105a74
f01021ce:	68 83 03 00 00       	push   $0x383
f01021d3:	e9 4d 02 00 00       	jmp    f0102425 <page_check+0xb00>

    // so it should be returned by page_alloc
    assert(page_alloc(&pp) == 0 && pp == pp1);
f01021d8:	83 ec 0c             	sub    $0xc,%esp
f01021db:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f01021de:	50                   	push   %eax
f01021df:	e8 97 f2 ff ff       	call   f010147b <page_alloc>
f01021e4:	83 c4 10             	add    $0x10,%esp
f01021e7:	85 c0                	test   %eax,%eax
f01021e9:	75 08                	jne    f01021f3 <page_check+0x8ce>
f01021eb:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f01021ee:	3b 45 f0             	cmp    0xfffffff0(%ebp),%eax
f01021f1:	74 14                	je     f0102207 <page_check+0x8e2>
f01021f3:	68 08 5a 10 f0       	push   $0xf0105a08
f01021f8:	68 74 5a 10 f0       	push   $0xf0105a74
f01021fd:	68 86 03 00 00       	push   $0x386
f0102202:	e9 1e 02 00 00       	jmp    f0102425 <page_check+0xb00>

    // should be no free memory
    assert(page_alloc(&pp) == -E_NO_MEM);
f0102207:	83 ec 0c             	sub    $0xc,%esp
f010220a:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f010220d:	50                   	push   %eax
f010220e:	e8 68 f2 ff ff       	call   f010147b <page_alloc>
f0102213:	83 c4 10             	add    $0x10,%esp
f0102216:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102219:	74 14                	je     f010222f <page_check+0x90a>
f010221b:	68 21 5b 10 f0       	push   $0xf0105b21
f0102220:	68 74 5a 10 f0       	push   $0xf0105a74
f0102225:	68 89 03 00 00       	push   $0x389
f010222a:	e9 f6 01 00 00       	jmp    f0102425 <page_check+0xb00>

#if 0
    // should be able to page_insert to change a page
    // and see the new data immediately.
    memset(page2kva(pp1), 1, PGSIZE);
    memset(page2kva(pp2), 2, PGSIZE);
    page_insert(boot_pgdir, pp1, 0x0, 0);
    assert(pp1->pp_ref == 1);
    assert(*(int*) 0 == 0x01010101);
    page_insert(boot_pgdir, pp2, 0x0, 0);
    assert(*(int*) 0 == 0x02020202);
    assert(pp2->pp_ref == 1);
    assert(pp1->pp_ref == 0);
    page_remove(boot_pgdir, 0x0);
    assert(pp2->pp_ref == 0);
#endif

    // forcibly take pp0 back
    assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f010222f:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f0102234:	8b 18                	mov    (%eax),%ebx
f0102236:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010223c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f010223f:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0102245:	c1 fa 02             	sar    $0x2,%edx
f0102248:	8d 04 92             	lea    (%edx,%edx,4),%eax
f010224b:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010224e:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102251:	89 c1                	mov    %eax,%ecx
f0102253:	c1 e1 08             	shl    $0x8,%ecx
f0102256:	01 c8                	add    %ecx,%eax
f0102258:	89 c1                	mov    %eax,%ecx
f010225a:	c1 e1 10             	shl    $0x10,%ecx
f010225d:	01 c8                	add    %ecx,%eax
f010225f:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0102262:	c1 e0 0c             	shl    $0xc,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102265:	39 c3                	cmp    %eax,%ebx
f0102267:	74 14                	je     f010227d <page_check+0x958>
f0102269:	68 28 57 10 f0       	push   $0xf0105728
f010226e:	68 74 5a 10 f0       	push   $0xf0105a74
f0102273:	68 9c 03 00 00       	push   $0x39c
f0102278:	e9 a8 01 00 00       	jmp    f0102425 <page_check+0xb00>
    boot_pgdir[0] = 0;
f010227d:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f0102282:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(pp0->pp_ref == 1);
f0102288:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f010228b:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102290:	74 14                	je     f01022a6 <page_check+0x981>
f0102292:	68 66 5b 10 f0       	push   $0xf0105b66
f0102297:	68 74 5a 10 f0       	push   $0xf0105a74
f010229c:	68 9e 03 00 00       	push   $0x39e
f01022a1:	e9 7f 01 00 00       	jmp    f0102425 <page_check+0xb00>
    pp0->pp_ref = 0;
f01022a6:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f01022a9:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

    // check pointer arithmetic in pgdir_walk
    page_free(pp0);
f01022af:	83 ec 0c             	sub    $0xc,%esp
f01022b2:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f01022b5:	e8 03 f2 ff ff       	call   f01014bd <page_free>
    va = (void*) (PGSIZE * NPDENTRIES + PGSIZE);
f01022ba:	bb 00 10 40 00       	mov    $0x401000,%ebx
    ptep = pgdir_walk(boot_pgdir, va, 1);
f01022bf:	83 c4 0c             	add    $0xc,%esp
f01022c2:	6a 01                	push   $0x1
f01022c4:	68 00 10 40 00       	push   $0x401000
f01022c9:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f01022cf:	e8 3a f2 ff ff       	call   f010150e <pgdir_walk>
f01022d4:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
    ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f01022d7:	83 c4 10             	add    $0x10,%esp
f01022da:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f01022df:	8b 50 04             	mov    0x4(%eax),%edx
f01022e2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022e8:	89 d0                	mov    %edx,%eax
f01022ea:	c1 e8 0c             	shr    $0xc,%eax
f01022ed:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01022f3:	72 10                	jb     f0102305 <page_check+0x9e0>
f01022f5:	52                   	push   %edx
f01022f6:	68 e4 54 10 f0       	push   $0xf01054e4
f01022fb:	68 a5 03 00 00       	push   $0x3a5
f0102300:	e9 20 01 00 00       	jmp    f0102425 <page_check+0xb00>
    assert(ptep == ptep1 + PTX(va));
f0102305:	89 d8                	mov    %ebx,%eax
f0102307:	c1 e8 0a             	shr    $0xa,%eax
f010230a:	83 e0 04             	and    $0x4,%eax
f010230d:	8d 84 10 00 00 00 f0 	lea    0xf0000000(%eax,%edx,1),%eax
f0102314:	39 45 e4             	cmp    %eax,0xffffffe4(%ebp)
f0102317:	74 14                	je     f010232d <page_check+0xa08>
f0102319:	68 d1 5b 10 f0       	push   $0xf0105bd1
f010231e:	68 74 5a 10 f0       	push   $0xf0105a74
f0102323:	68 a6 03 00 00       	push   $0x3a6
f0102328:	e9 f8 00 00 00       	jmp    f0102425 <page_check+0xb00>
    boot_pgdir[PDX(va)] = 0;
f010232d:	89 da                	mov    %ebx,%edx
f010232f:	c1 ea 16             	shr    $0x16,%edx
f0102332:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f0102337:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    pp0->pp_ref = 0;
f010233e:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0102341:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102347:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f010234a:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0102350:	c1 fa 02             	sar    $0x2,%edx
f0102353:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102356:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102359:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010235c:	89 c1                	mov    %eax,%ecx
f010235e:	c1 e1 08             	shl    $0x8,%ecx
f0102361:	01 c8                	add    %ecx,%eax
f0102363:	89 c1                	mov    %eax,%ecx
f0102365:	c1 e1 10             	shl    $0x10,%ecx
f0102368:	01 c8                	add    %ecx,%eax
f010236a:	8d 04 42             	lea    (%edx,%eax,2),%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f010236d:	89 c2                	mov    %eax,%edx
f010236f:	c1 e2 0c             	shl    $0xc,%edx
	return page2ppn(pp) << PGSHIFT;
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
		panic("pa2page called with invalid pa");
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102372:	89 d0                	mov    %edx,%eax
f0102374:	c1 e8 0c             	shr    $0xc,%eax
f0102377:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f010237d:	73 71                	jae    f01023f0 <page_check+0xacb>
f010237f:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0102385:	83 ec 04             	sub    $0x4,%esp
f0102388:	68 00 10 00 00       	push   $0x1000
f010238d:	68 ff 00 00 00       	push   $0xff
f0102392:	50                   	push   %eax
f0102393:	e8 9b 29 00 00       	call   f0104d33 <memset>

    // check that new page tables get cleared
    memset(page2kva(pp0), 0xFF, PGSIZE);
    page_free(pp0);
f0102398:	83 c4 04             	add    $0x4,%esp
f010239b:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f010239e:	e8 1a f1 ff ff       	call   f01014bd <page_free>
    pgdir_walk(boot_pgdir, 0x0, 1);
f01023a3:	83 c4 0c             	add    $0xc,%esp
f01023a6:	6a 01                	push   $0x1
f01023a8:	6a 00                	push   $0x0
f01023aa:	ff 35 68 0b 1d f0    	pushl  0xf01d0b68
f01023b0:	e8 59 f1 ff ff       	call   f010150e <pgdir_walk>
}

static inline void*
page2kva(struct Page *pp)
{
f01023b5:	83 c4 10             	add    $0x10,%esp
f01023b8:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01023bb:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f01023c1:	c1 fa 02             	sar    $0x2,%edx
f01023c4:	8d 04 92             	lea    (%edx,%edx,4),%eax
f01023c7:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01023ca:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01023cd:	89 c1                	mov    %eax,%ecx
f01023cf:	c1 e1 08             	shl    $0x8,%ecx
f01023d2:	01 c8                	add    %ecx,%eax
f01023d4:	89 c1                	mov    %eax,%ecx
f01023d6:	c1 e1 10             	shl    $0x10,%ecx
f01023d9:	01 c8                	add    %ecx,%eax
f01023db:	8d 04 42             	lea    (%edx,%eax,2),%eax
f01023de:	89 c2                	mov    %eax,%edx
f01023e0:	c1 e2 0c             	shl    $0xc,%edx
	return KADDR(page2pa(pp));
f01023e3:	89 d0                	mov    %edx,%eax
f01023e5:	c1 e8 0c             	shr    $0xc,%eax
f01023e8:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01023ee:	72 0f                	jb     f01023ff <page_check+0xada>
f01023f0:	52                   	push   %edx
f01023f1:	68 e4 54 10 f0       	push   $0xf01054e4
f01023f6:	6a 5a                	push   $0x5a
f01023f8:	68 52 5a 10 f0       	push   $0xf0105a52
f01023fd:	eb 2b                	jmp    f010242a <page_check+0xb05>
f01023ff:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0102405:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
    ptep = page2kva(pp0);
    for (i = 0; i < NPTENTRIES; i++)
f0102408:	ba 00 00 00 00       	mov    $0x0,%edx
        assert((ptep[i] & PTE_P) == 0);
f010240d:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0102410:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f0102414:	74 19                	je     f010242f <page_check+0xb0a>
f0102416:	68 e9 5b 10 f0       	push   $0xf0105be9
f010241b:	68 74 5a 10 f0       	push   $0xf0105a74
f0102420:	68 b0 03 00 00       	push   $0x3b0
f0102425:	68 46 5a 10 f0       	push   $0xf0105a46
f010242a:	e8 b5 dc ff ff       	call   f01000e4 <_panic>
f010242f:	42                   	inc    %edx
f0102430:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0102436:	7e d5                	jle    f010240d <page_check+0xae8>
    boot_pgdir[0] = 0;
f0102438:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f010243d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    pp0->pp_ref = 0;
f0102443:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0102446:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

    // give free list back
    page_free_list = fl;
f010244c:	89 35 b8 fe 1c f0    	mov    %esi,0xf01cfeb8

    // free the pages we took
    page_free(pp0);
f0102452:	83 ec 0c             	sub    $0xc,%esp
f0102455:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0102458:	e8 60 f0 ff ff       	call   f01014bd <page_free>
    page_free(pp1);
f010245d:	83 c4 04             	add    $0x4,%esp
f0102460:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0102463:	e8 55 f0 ff ff       	call   f01014bd <page_free>
    page_free(pp2);
f0102468:	83 c4 04             	add    $0x4,%esp
f010246b:	ff 75 ec             	pushl  0xffffffec(%ebp)
f010246e:	e8 4a f0 ff ff       	call   f01014bd <page_free>

    cprintf("page_check() succeeded!\n");
f0102473:	c7 04 24 00 5c 10 f0 	movl   $0xf0105c00,(%esp)
f010247a:	e8 f3 08 00 00       	call   f0102d72 <cprintf>
}
f010247f:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0102482:	5b                   	pop    %ebx
f0102483:	5e                   	pop    %esi
f0102484:	c9                   	leave  
f0102485:	c3                   	ret    
	...

f0102488 <envid2env>:
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102488:	55                   	push   %ebp
f0102489:	89 e5                	mov    %esp,%ebp
f010248b:	53                   	push   %ebx
f010248c:	8b 55 08             	mov    0x8(%ebp),%edx
f010248f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    struct Env *e;

    // If envid is zero, return the current environment.
    if (envid == 0) {
f0102492:	85 d2                	test   %edx,%edx
f0102494:	75 09                	jne    f010249f <envid2env+0x17>
        *env_store = curenv;
f0102496:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f010249b:	89 03                	mov    %eax,(%ebx)
        return 0;
f010249d:	eb 47                	jmp    f01024e6 <envid2env+0x5e>
    }

    // Look up the Env structure via the index part of the envid,
    // then check the env_id field in that struct Env
    // to ensure that the envid is not stale
    // (i.e., does not refer to a _previous_ environment
    // that used the same slot in the envs[] array).
    e = &envs[ENVX(envid)];
f010249f:	89 d0                	mov    %edx,%eax
f01024a1:	25 ff 03 00 00       	and    $0x3ff,%eax
f01024a6:	c1 e0 07             	shl    $0x7,%eax
f01024a9:	89 c1                	mov    %eax,%ecx
f01024ab:	03 0d c0 fe 1c f0    	add    0xf01cfec0,%ecx
    if (e->env_status == ENV_FREE || e->env_id != envid) {
f01024b1:	83 79 54 00          	cmpl   $0x0,0x54(%ecx)
f01024b5:	74 20                	je     f01024d7 <envid2env+0x4f>
f01024b7:	39 51 4c             	cmp    %edx,0x4c(%ecx)
f01024ba:	75 1b                	jne    f01024d7 <envid2env+0x4f>
        *env_store = 0;
        return -E_BAD_ENV;
    }

    // Check that the calling environment has legitimate permission
    // to manipulate the specified environment.
    // If checkperm is set, the specified environment
    // must be either the current environment
    // or an immediate child of the current environment.
    if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01024bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01024c0:	74 22                	je     f01024e4 <envid2env+0x5c>
f01024c2:	3b 0d c4 fe 1c f0    	cmp    0xf01cfec4,%ecx
f01024c8:	74 1a                	je     f01024e4 <envid2env+0x5c>
f01024ca:	8b 51 50             	mov    0x50(%ecx),%edx
f01024cd:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f01024d2:	3b 50 4c             	cmp    0x4c(%eax),%edx
f01024d5:	74 0d                	je     f01024e4 <envid2env+0x5c>
        *env_store = 0;
f01024d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return -E_BAD_ENV;
f01024dd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01024e2:	eb 07                	jmp    f01024eb <envid2env+0x63>
    }

    *env_store = e;
f01024e4:	89 0b                	mov    %ecx,(%ebx)
    return 0;
f01024e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01024eb:	8b 1c 24             	mov    (%esp),%ebx
f01024ee:	c9                   	leave  
f01024ef:	c3                   	ret    

f01024f0 <env_init>:

//
// Mark all environments in 'envs' as free, set their env_ids to 0,
// and insert them into the env_free_list.
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f01024f0:	55                   	push   %ebp
f01024f1:	89 e5                	mov    %esp,%ebp
f01024f3:	53                   	push   %ebx
    // LAB 3: Your code here.
    int i;
    struct Env *e;
    LIST_INIT(&env_free_list);
f01024f4:	c7 05 c8 fe 1c f0 00 	movl   $0x0,0xf01cfec8
f01024fb:	00 00 00 
    for (i = NENV-1; i>=0;i--) {/*insert in reverse order*/
f01024fe:	bb ff 03 00 00       	mov    $0x3ff,%ebx
        e = &envs[i];
f0102503:	89 d8                	mov    %ebx,%eax
f0102505:	c1 e0 07             	shl    $0x7,%eax
f0102508:	89 c1                	mov    %eax,%ecx
f010250a:	03 0d c0 fe 1c f0    	add    0xf01cfec0,%ecx
        e->env_id = 0;
f0102510:	c7 41 4c 00 00 00 00 	movl   $0x0,0x4c(%ecx)
        e->env_status = ENV_FREE;
f0102517:	c7 41 54 00 00 00 00 	movl   $0x0,0x54(%ecx)
        LIST_INSERT_HEAD(&env_free_list, e, env_link);
f010251e:	a1 c8 fe 1c f0       	mov    0xf01cfec8,%eax
f0102523:	89 41 44             	mov    %eax,0x44(%ecx)
f0102526:	85 c0                	test   %eax,%eax
f0102528:	74 0b                	je     f0102535 <env_init+0x45>
f010252a:	8d 51 44             	lea    0x44(%ecx),%edx
f010252d:	a1 c8 fe 1c f0       	mov    0xf01cfec8,%eax
f0102532:	89 50 48             	mov    %edx,0x48(%eax)
f0102535:	89 0d c8 fe 1c f0    	mov    %ecx,0xf01cfec8
f010253b:	c7 41 48 c8 fe 1c f0 	movl   $0xf01cfec8,0x48(%ecx)
f0102542:	4b                   	dec    %ebx
f0102543:	79 be                	jns    f0102503 <env_init+0x13>
    }
    //finished
}
f0102545:	5b                   	pop    %ebx
f0102546:	c9                   	leave  
f0102547:	c3                   	ret    

f0102548 <env_setup_vm>:

//
// Initialize the kernel virtual memory layout for environment e.
// Allocate a page directory, set e->env_pgdir and e->env_cr3 accordingly,
// and initialize the kernel portion of the new environment's address space.
// Do NOT (yet) map anything into the user portion
// of the environment's virtual address space.
//
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f0102548:	55                   	push   %ebp
f0102549:	89 e5                	mov    %esp,%ebp
f010254b:	56                   	push   %esi
f010254c:	53                   	push   %ebx
f010254d:	83 ec 1c             	sub    $0x1c,%esp
f0102550:	8b 75 08             	mov    0x8(%ebp),%esi
    int i, r;
    struct Page *p = NULL;
f0102553:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)

    // Allocate a page for the page directory
    if ((r = page_alloc(&p)) < 0)
f010255a:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f010255d:	50                   	push   %eax
f010255e:	e8 18 ef ff ff       	call   f010147b <page_alloc>
f0102563:	83 c4 10             	add    $0x10,%esp
f0102566:	89 c2                	mov    %eax,%edx
f0102568:	85 c0                	test   %eax,%eax
f010256a:	0f 88 1a 01 00 00    	js     f010268a <env_setup_vm+0x142>
        return r;

    // Now, set e->env_pgdir and e->env_cr3,
    // and initialize the page directory.
    //
    // Hint:
    //    - The VA space of all envs is identical above UTOP
    //      (except at VPT and UVPT, which we've set below).
    //	See inc/memlayout.h for permissions and layout.
    //	Can you use boot_pgdir as a template?  Hint: Yes.
    //	(Make sure you got the permissions right in Lab 2.)
    //    - The initial VA below UTOP is empty.
    //    - You do not need to make any more calls to page_alloc.
    //    - Note: pp_ref is not maintained for most physical pages
    //	mapped above UTOP -- but you do need to increment
    //	env_pgdir's pp_ref!

// LAB 3: Your code here.
    p->pp_ref ++;
f0102570:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0102573:	66 ff 40 08          	incw   0x8(%eax)

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102577:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f010257a:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0102580:	c1 fa 02             	sar    $0x2,%edx
f0102583:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102586:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102589:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010258c:	89 c1                	mov    %eax,%ecx
f010258e:	c1 e1 08             	shl    $0x8,%ecx
f0102591:	01 c8                	add    %ecx,%eax
f0102593:	89 c1                	mov    %eax,%ecx
f0102595:	c1 e1 10             	shl    $0x10,%ecx
f0102598:	01 c8                	add    %ecx,%eax
f010259a:	8d 04 42             	lea    (%edx,%eax,2),%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f010259d:	89 c2                	mov    %eax,%edx
f010259f:	c1 e2 0c             	shl    $0xc,%edx
	return page2ppn(pp) << PGSHIFT;
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
		panic("pa2page called with invalid pa");
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01025a2:	89 d0                	mov    %edx,%eax
f01025a4:	c1 e8 0c             	shr    $0xc,%eax
f01025a7:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01025ad:	73 51                	jae    f0102600 <env_setup_vm+0xb8>
f01025af:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f01025b5:	83 ec 04             	sub    $0x4,%esp
f01025b8:	68 00 10 00 00       	push   $0x1000
f01025bd:	6a 00                	push   $0x0
f01025bf:	50                   	push   %eax
f01025c0:	e8 6e 27 00 00       	call   f0104d33 <memset>
f01025c5:	83 c4 10             	add    $0x10,%esp
f01025c8:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01025cb:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f01025d1:	c1 fa 02             	sar    $0x2,%edx
f01025d4:	8d 04 92             	lea    (%edx,%edx,4),%eax
f01025d7:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01025da:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01025dd:	89 c1                	mov    %eax,%ecx
f01025df:	c1 e1 08             	shl    $0x8,%ecx
f01025e2:	01 c8                	add    %ecx,%eax
f01025e4:	89 c1                	mov    %eax,%ecx
f01025e6:	c1 e1 10             	shl    $0x10,%ecx
f01025e9:	01 c8                	add    %ecx,%eax
f01025eb:	8d 04 42             	lea    (%edx,%eax,2),%eax
f01025ee:	89 c2                	mov    %eax,%edx
f01025f0:	c1 e2 0c             	shl    $0xc,%edx
f01025f3:	89 d0                	mov    %edx,%eax
f01025f5:	c1 e8 0c             	shr    $0xc,%eax
f01025f8:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01025fe:	72 12                	jb     f0102612 <env_setup_vm+0xca>
f0102600:	52                   	push   %edx
f0102601:	68 e4 54 10 f0       	push   $0xf01054e4
f0102606:	6a 5a                	push   $0x5a
f0102608:	68 52 5a 10 f0       	push   $0xf0105a52
f010260d:	e8 d2 da ff ff       	call   f01000e4 <_panic>
f0102612:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0102618:	89 46 60             	mov    %eax,0x60(%esi)
f010261b:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f010261e:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0102624:	c1 fa 02             	sar    $0x2,%edx
f0102627:	8d 04 92             	lea    (%edx,%edx,4),%eax
f010262a:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010262d:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102630:	89 c1                	mov    %eax,%ecx
f0102632:	c1 e1 08             	shl    $0x8,%ecx
f0102635:	01 c8                	add    %ecx,%eax
f0102637:	89 c1                	mov    %eax,%ecx
f0102639:	c1 e1 10             	shl    $0x10,%ecx
f010263c:	01 c8                	add    %ecx,%eax
f010263e:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0102641:	c1 e0 0c             	shl    $0xc,%eax
f0102644:	89 46 64             	mov    %eax,0x64(%esi)
    memset(page2kva(p),0,PGSIZE);  
    e->env_pgdir = page2kva(p);
    e->env_cr3 = page2pa(p);
    /*get the page map upon the UTOP*/
    for (i = UTOP; i != 0; i += PTSIZE) {
f0102647:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
        e->env_pgdir[PDX(i)] = boot_pgdir[PDX(i)];
f010264c:	89 da                	mov    %ebx,%edx
f010264e:	c1 ea 16             	shr    $0x16,%edx
f0102651:	8b 4e 60             	mov    0x60(%esi),%ecx
f0102654:	a1 68 0b 1d f0       	mov    0xf01d0b68,%eax
f0102659:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010265c:	89 04 91             	mov    %eax,(%ecx,%edx,4)
f010265f:	81 c3 00 00 40 00    	add    $0x400000,%ebx
f0102665:	75 e5                	jne    f010264c <env_setup_vm+0x104>
    }

    // VPT and UVPT map the env's own page table, with
    // different permissions.
    e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0102667:	8b 56 60             	mov    0x60(%esi),%edx
f010266a:	8b 46 64             	mov    0x64(%esi),%eax
f010266d:	83 c8 03             	or     $0x3,%eax
f0102670:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)
    e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0102676:	8b 56 60             	mov    0x60(%esi),%edx
f0102679:	8b 46 64             	mov    0x64(%esi),%eax
f010267c:	83 c8 05             	or     $0x5,%eax
f010267f:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
    return 0;
f0102685:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010268a:	89 d0                	mov    %edx,%eax
f010268c:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f010268f:	5b                   	pop    %ebx
f0102690:	5e                   	pop    %esi
f0102691:	c9                   	leave  
f0102692:	c3                   	ret    

f0102693 <env_alloc>:

//
// Allocates and initializes a new environment.
// On success, the new environment is stored in *newenv_store.
//
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102693:	55                   	push   %ebp
f0102694:	89 e5                	mov    %esp,%ebp
f0102696:	53                   	push   %ebx
f0102697:	83 ec 04             	sub    $0x4,%esp
    int32_t generation;
    int r;
    struct Env *e;

    if (!(e = LIST_FIRST(&env_free_list)))
f010269a:	8b 1d c8 fe 1c f0    	mov    0xf01cfec8,%ebx
f01026a0:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f01026a5:	85 db                	test   %ebx,%ebx
f01026a7:	0f 84 ec 00 00 00    	je     f0102799 <env_alloc+0x106>
        return -E_NO_FREE_ENV;

    // Allocate and set up the page directory for this environment.
    if ((r = env_setup_vm(e)) < 0)
f01026ad:	83 ec 0c             	sub    $0xc,%esp
f01026b0:	53                   	push   %ebx
f01026b1:	e8 92 fe ff ff       	call   f0102548 <env_setup_vm>
f01026b6:	83 c4 10             	add    $0x10,%esp
f01026b9:	89 c2                	mov    %eax,%edx
f01026bb:	85 c0                	test   %eax,%eax
f01026bd:	0f 88 d6 00 00 00    	js     f0102799 <env_alloc+0x106>
        return r;

    // Generate an env_id for this environment.
    generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01026c3:	8b 53 4c             	mov    0x4c(%ebx),%edx
f01026c6:	81 c2 00 10 00 00    	add    $0x1000,%edx
    if (generation <= 0)    // Don't create a negative env_id.
f01026cc:	81 e2 00 fc ff ff    	and    $0xfffffc00,%edx
f01026d2:	7f 05                	jg     f01026d9 <env_alloc+0x46>
        generation = 1 << ENVGENSHIFT;
f01026d4:	ba 00 10 00 00       	mov    $0x1000,%edx
    e->env_id = generation | (e - envs);
f01026d9:	89 d8                	mov    %ebx,%eax
f01026db:	2b 05 c0 fe 1c f0    	sub    0xf01cfec0,%eax
f01026e1:	c1 f8 07             	sar    $0x7,%eax
f01026e4:	09 d0                	or     %edx,%eax
f01026e6:	89 43 4c             	mov    %eax,0x4c(%ebx)

    // Set the basic status variables.
    e->env_parent_id = parent_id;
f01026e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026ec:	89 43 50             	mov    %eax,0x50(%ebx)
    e->env_ipc_dstva = (void*)UTOP;
f01026ef:	c7 43 70 00 00 c0 ee 	movl   $0xeec00000,0x70(%ebx)
    e->env_ipc_perm = 0;
f01026f6:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
    e->env_ipc_from = 0;
f01026fd:	c7 43 78 00 00 00 00 	movl   $0x0,0x78(%ebx)
    e->env_status = ENV_RUNNABLE;
f0102704:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
    e->env_runs = 0;
f010270b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

    // Clear out all the saved register state,
    // to prevent the register values
    // of a prior environment inhabiting this Env structure
    // from "leaking" into our new environment.
    memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102712:	83 ec 04             	sub    $0x4,%esp
f0102715:	6a 44                	push   $0x44
f0102717:	6a 00                	push   $0x0
f0102719:	53                   	push   %ebx
f010271a:	e8 14 26 00 00       	call   f0104d33 <memset>

    // Set up appropriate initial values for the segment registers.
    // GD_UD is the user data segment selector in the GDT, and 
    // GD_UT is the user text segment selector (see inc/memlayout.h).
    // The low 2 bits of each segment register contains the
    // Requestor Privilege Level (RPL); 3 means user mode.
    e->env_tf.tf_ds = GD_UD | 3;
f010271f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
    e->env_tf.tf_es = GD_UD | 3;
f0102725:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
    e->env_tf.tf_ss = GD_UD | 3;
f010272b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
    e->env_tf.tf_esp = USTACKTOP;
f0102731:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
    e->env_tf.tf_cs = GD_UT | 3;
f0102738:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
    // You will set e->env_tf.tf_eip later.

    // Enable interrupts while in user mode.
    // LAB 4: Your code here.
    //e->env_tf.tf_eflags |= FL_IF;//!!!!!!!!!!!!!!!!!!!!!!!!!
    // Clear the page fault handler until user installs one.
    e->env_pgfault_upcall = 0;
f010273e:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

    // Also clear the IPC receiving flag.
    e->env_ipc_recving = 0;
f0102745:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

    // commit the allocation
    LIST_REMOVE(e, env_link);
f010274c:	83 c4 10             	add    $0x10,%esp
f010274f:	83 7b 44 00          	cmpl   $0x0,0x44(%ebx)
f0102753:	74 09                	je     f010275e <env_alloc+0xcb>
f0102755:	8b 53 44             	mov    0x44(%ebx),%edx
f0102758:	8b 43 48             	mov    0x48(%ebx),%eax
f010275b:	89 42 48             	mov    %eax,0x48(%edx)
f010275e:	8b 53 48             	mov    0x48(%ebx),%edx
f0102761:	8b 43 44             	mov    0x44(%ebx),%eax
f0102764:	89 02                	mov    %eax,(%edx)
    *newenv_store = e;
f0102766:	8b 45 08             	mov    0x8(%ebp),%eax
f0102769:	89 18                	mov    %ebx,(%eax)

    cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010276b:	83 ec 04             	sub    $0x4,%esp
f010276e:	ff 73 4c             	pushl  0x4c(%ebx)
f0102771:	83 3d c4 fe 1c f0 00 	cmpl   $0x0,0xf01cfec4
f0102778:	74 0a                	je     f0102784 <env_alloc+0xf1>
f010277a:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f010277f:	8b 40 4c             	mov    0x4c(%eax),%eax
f0102782:	eb 05                	jmp    f0102789 <env_alloc+0xf6>
f0102784:	b8 00 00 00 00       	mov    $0x0,%eax
f0102789:	50                   	push   %eax
f010278a:	68 19 5c 10 f0       	push   $0xf0105c19
f010278f:	e8 de 05 00 00       	call   f0102d72 <cprintf>
    return 0;
f0102794:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102799:	89 d0                	mov    %edx,%eax
f010279b:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010279e:	c9                   	leave  
f010279f:	c3                   	ret    

f01027a0 <segment_alloc>:

//
// Allocate len bytes of physical memory for environment env,
// and map it at virtual address va in the environment's address space.
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
segment_alloc(struct Env *e, void *va, size_t len)
{
f01027a0:	55                   	push   %ebp
f01027a1:	89 e5                	mov    %esp,%ebp
f01027a3:	57                   	push   %edi
f01027a4:	56                   	push   %esi
f01027a5:	53                   	push   %ebx
f01027a6:	83 ec 0c             	sub    $0xc,%esp
f01027a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01027ac:	8b 7d 10             	mov    0x10(%ebp),%edi
    // LAB 3: Your code here.
    // (But only if you need it for load_icode.)
    //
    // Hint: It is easier to use segment_alloc if the caller can pass
    //   'va' and 'len' values that are not page-aligned.
    //   You should round va down, and round len up.
    int i;
    struct Page* page;
    if (e) {
f01027af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01027b3:	74 6d                	je     f0102822 <segment_alloc+0x82>
        va = ROUNDDOWN(va,PGSIZE);
f01027b5:	89 d8                	mov    %ebx,%eax
f01027b7:	25 ff 0f 00 00       	and    $0xfff,%eax
f01027bc:	29 c3                	sub    %eax,%ebx
        len = ROUNDUP(len,PGSIZE);
f01027be:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f01027c4:	89 c7                	mov    %eax,%edi
f01027c6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        /*alloc and map the page*/
        for (i = 0; i<len;i+=PGSIZE) {
f01027cc:	be 00 00 00 00       	mov    $0x0,%esi
f01027d1:	39 fe                	cmp    %edi,%esi
f01027d3:	73 4d                	jae    f0102822 <segment_alloc+0x82>
            if (page_alloc(&page)) {
f01027d5:	83 ec 0c             	sub    $0xc,%esp
f01027d8:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01027db:	50                   	push   %eax
f01027dc:	e8 9a ec ff ff       	call   f010147b <page_alloc>
f01027e1:	83 c4 10             	add    $0x10,%esp
f01027e4:	85 c0                	test   %eax,%eax
f01027e6:	74 16                	je     f01027fe <segment_alloc+0x5e>
                panic("env_alloc: %e\n", -E_NO_MEM);
f01027e8:	6a fc                	push   $0xfffffffc
f01027ea:	68 2e 5c 10 f0       	push   $0xf0105c2e
f01027ef:	68 eb 00 00 00       	push   $0xeb
f01027f4:	68 3d 5c 10 f0       	push   $0xf0105c3d
f01027f9:	e8 e6 d8 ff ff       	call   f01000e4 <_panic>
            }
            page_insert(e->env_pgdir,page,va,PTE_U|PTE_W|PTE_P);
f01027fe:	6a 07                	push   $0x7
f0102800:	53                   	push   %ebx
f0102801:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0102804:	8b 45 08             	mov    0x8(%ebp),%eax
f0102807:	ff 70 60             	pushl  0x60(%eax)
f010280a:	e8 52 ee ff ff       	call   f0101661 <page_insert>
            va += PGSIZE;
f010280f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102815:	83 c4 10             	add    $0x10,%esp
f0102818:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010281e:	39 fe                	cmp    %edi,%esi
f0102820:	72 b3                	jb     f01027d5 <segment_alloc+0x35>
        }
    }
}
f0102822:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102825:	5b                   	pop    %ebx
f0102826:	5e                   	pop    %esi
f0102827:	5f                   	pop    %edi
f0102828:	c9                   	leave  
f0102829:	c3                   	ret    

f010282a <load_icode>:
//
// Set up the initial program binary, stack, and processor flags
// for a user process.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
//
// This function loads all loadable segments from the ELF binary image
// into the environment's user memory, starting at the appropriate
// virtual addresses indicated in the ELF program header.
// At the same time it clears to zero any portions of these segments
// that are marked in the program header as being mapped
// but not actually present in the ELF file - i.e., the program's bss section.
//
// All this is very similar to what our boot loader does, except the boot
// loader also needs to read the code from disk.  Take a look at
// boot/main.c to get ideas.
//
// Finally, this function maps one page for the program's initial stack.
//
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary, size_t size)
{
f010282a:	55                   	push   %ebp
f010282b:	89 e5                	mov    %esp,%ebp
f010282d:	57                   	push   %edi
f010282e:	56                   	push   %esi
f010282f:	53                   	push   %ebx
f0102830:	83 ec 0c             	sub    $0xc,%esp
    // Hints: 
    //  Load each program segment into virtual memory
    //  at the address specified in the ELF section header.
    //  You should only load segments with ph->p_type == ELF_PROG_LOAD.//ok
    //  Each segment's virtual address can be found in ph->p_va
    //  and its size in memory can be found in ph->p_memsz.
    //  The ph->p_filesz bytes from the ELF binary, starting at
    //  'binary + ph->p_offset', should be copied to virtual address
    //  ph->p_va.  Any remaining memory bytes should be cleared to zero.
    //  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
    //
    //  All page protection bits should be user read/write for now.
    //  ELF segments are not necessarily page-aligned, but you can
    //  assume for this function that no two segments will touch
    //  the same virtual page.
    //
    //  You may find a function like segment_alloc useful.
    //
    //  Loading the segments is much simpler if you can move data
    //  directly into the virtual addresses stored in the ELF binary.
    //  So which page directory should be in force during
    //  this function?
    //
    // Hint:
    //  You must also do something with the program's entry point,
    //  to make sure that the environment starts executing there.
    //  What?  (See env_run() and env_pop_tf() below.)

    // LAB 3: Your code here.
    struct Elf *env_elf = (struct Elf *)binary;
f0102833:	8b 7d 0c             	mov    0xc(%ebp),%edi
    struct Proghdr *ph, *eph;
    struct Page *page;
    //cprintf("before ph\n");
    ph = (struct Proghdr *) ((uint8_t *) env_elf + env_elf->e_phoff);
f0102836:	89 fb                	mov    %edi,%ebx
f0102838:	03 5f 1c             	add    0x1c(%edi),%ebx
    //cprintf("after ph\n");
    eph = ph + env_elf->e_phnum;
f010283b:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
f010283f:	c1 e0 05             	shl    $0x5,%eax
f0102842:	8d 34 18             	lea    (%eax,%ebx,1),%esi
}

static __inline void
lcr3(uint32_t val)
{
f0102845:	8b 55 08             	mov    0x8(%ebp),%edx
f0102848:	8b 42 64             	mov    0x64(%edx),%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010284b:	0f 22 d8             	mov    %eax,%cr3
    lcr3(e->env_cr3);//load cr3    
    for (; ph != eph; ph++) {
f010284e:	39 f3                	cmp    %esi,%ebx
f0102850:	74 4c                	je     f010289e <load_icode+0x74>
        if (ph->p_type == ELF_PROG_LOAD) {
f0102852:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102855:	75 40                	jne    f0102897 <load_icode+0x6d>
            segment_alloc(e, (void*) ph->p_va, ph->p_memsz);//map virtual address
f0102857:	83 ec 04             	sub    $0x4,%esp
f010285a:	ff 73 14             	pushl  0x14(%ebx)
f010285d:	ff 73 08             	pushl  0x8(%ebx)
f0102860:	ff 75 08             	pushl  0x8(%ebp)
f0102863:	e8 38 ff ff ff       	call   f01027a0 <segment_alloc>
            //cprintf("ph->p_va:%x\n",ph->p_va);
            //cprintf("ph->p_offset:%x\n",ph->p_offset);
            //cprintf("ph->p_memsz:%x\n",ph->p_memsz);
            memcpy((void*) ph->p_va, (void*)(binary + ph->p_offset), ph->p_filesz);//copy
f0102868:	83 c4 0c             	add    $0xc,%esp
f010286b:	ff 73 10             	pushl  0x10(%ebx)
f010286e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102871:	03 43 04             	add    0x4(%ebx),%eax
f0102874:	50                   	push   %eax
f0102875:	ff 73 08             	pushl  0x8(%ebx)
f0102878:	e8 76 25 00 00       	call   f0104df3 <memcpy>
            memset((void*)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);//clear the rest memory
f010287d:	83 c4 0c             	add    $0xc,%esp
f0102880:	8b 53 10             	mov    0x10(%ebx),%edx
f0102883:	8b 43 14             	mov    0x14(%ebx),%eax
f0102886:	29 d0                	sub    %edx,%eax
f0102888:	50                   	push   %eax
f0102889:	6a 00                	push   $0x0
f010288b:	03 53 08             	add    0x8(%ebx),%edx
f010288e:	52                   	push   %edx
f010288f:	e8 9f 24 00 00       	call   f0104d33 <memset>
f0102894:	83 c4 10             	add    $0x10,%esp
f0102897:	83 c3 20             	add    $0x20,%ebx
f010289a:	39 f3                	cmp    %esi,%ebx
f010289c:	75 b4                	jne    f0102852 <load_icode+0x28>
}

static __inline void
lcr3(uint32_t val)
{
f010289e:	a1 64 0b 1d f0       	mov    0xf01d0b64,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01028a3:	0f 22 d8             	mov    %eax,%cr3
        }
    }
    lcr3(boot_cr3);//set the cr3 back
    e->env_tf.tf_eip = env_elf->e_entry;//set the env'eip to the entry of the program
f01028a6:	8b 47 18             	mov    0x18(%edi),%eax
f01028a9:	8b 55 08             	mov    0x8(%ebp),%edx
f01028ac:	89 42 30             	mov    %eax,0x30(%edx)
    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.

    // LAB 3: Your code here.
    int err;
    if (page_alloc(&page)) {
f01028af:	83 ec 0c             	sub    $0xc,%esp
f01028b2:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01028b5:	50                   	push   %eax
f01028b6:	e8 c0 eb ff ff       	call   f010147b <page_alloc>
f01028bb:	83 c4 10             	add    $0x10,%esp
f01028be:	85 c0                	test   %eax,%eax
f01028c0:	74 16                	je     f01028d8 <load_icode+0xae>
        err = -E_NO_MEM;
        panic("env_alloc: %e\n", err);
f01028c2:	6a fc                	push   $0xfffffffc
f01028c4:	68 2e 5c 10 f0       	push   $0xf0105c2e
f01028c9:	68 43 01 00 00       	push   $0x143
f01028ce:	68 3d 5c 10 f0       	push   $0xf0105c3d
f01028d3:	e8 0c d8 ff ff       	call   f01000e4 <_panic>
    }
    page_insert(e->env_pgdir,page,(void*)(USTACKTOP - PGSIZE),PTE_U|PTE_W|PTE_P);
f01028d8:	6a 07                	push   $0x7
f01028da:	68 00 d0 bf ee       	push   $0xeebfd000
f01028df:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f01028e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01028e5:	ff 70 60             	pushl  0x60(%eax)
f01028e8:	e8 74 ed ff ff       	call   f0101661 <page_insert>
    /*cprintf("load_icode here\n");
    cprintf("esp: %x\n",e->env_tf.tf_esp );
    cprintf("es: %x\n",e->env_tf.tf_es );
    cprintf("eip: %x\n",e->env_tf.tf_eip);
    cprintf("cs: %x\n",e->env_tf.tf_cs );
    cprintf("ds: %x\n",e->env_tf.tf_ds);
    cprintf("ss: %x\n",e->env_tf.tf_ss);*/
}
f01028ed:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01028f0:	5b                   	pop    %ebx
f01028f1:	5e                   	pop    %esi
f01028f2:	5f                   	pop    %edi
f01028f3:	c9                   	leave  
f01028f4:	c3                   	ret    

f01028f5 <env_create>:

//
// Allocates a new env and loads the named elf binary into it.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
// Where does the result go? 
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f01028f5:	55                   	push   %ebp
f01028f6:	89 e5                	mov    %esp,%ebp
f01028f8:	83 ec 10             	sub    $0x10,%esp
    // LAB 3: Your code here.
    //cprintf("binary%x\n",binary);
    struct Env *env;
    int err = env_alloc(&env, 0);
f01028fb:	6a 00                	push   $0x0
f01028fd:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f0102900:	50                   	push   %eax
f0102901:	e8 8d fd ff ff       	call   f0102693 <env_alloc>
    if (err != -E_NO_FREE_ENV && err != -E_NO_MEM) {
f0102906:	83 c0 05             	add    $0x5,%eax
f0102909:	83 c4 10             	add    $0x10,%esp
f010290c:	83 f8 01             	cmp    $0x1,%eax
f010290f:	76 16                	jbe    f0102927 <env_create+0x32>
        load_icode(env,binary,size);
f0102911:	83 ec 04             	sub    $0x4,%esp
f0102914:	ff 75 0c             	pushl  0xc(%ebp)
f0102917:	ff 75 08             	pushl  0x8(%ebp)
f010291a:	ff 75 fc             	pushl  0xfffffffc(%ebp)
f010291d:	e8 08 ff ff ff       	call   f010282a <load_icode>
f0102922:	83 c4 10             	add    $0x10,%esp
f0102925:	c9                   	leave  
f0102926:	c3                   	ret    
    } else {
        panic("env create error\n");
f0102927:	83 ec 04             	sub    $0x4,%esp
f010292a:	68 48 5c 10 f0       	push   $0xf0105c48
f010292f:	68 63 01 00 00       	push   $0x163
f0102934:	68 3d 5c 10 f0       	push   $0xf0105c3d
f0102939:	e8 a6 d7 ff ff       	call   f01000e4 <_panic>

f010293e <env_free>:
    }
    //cprintf("env alloced %x\n",env);

}

//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f010293e:	55                   	push   %ebp
f010293f:	89 e5                	mov    %esp,%ebp
f0102941:	57                   	push   %edi
f0102942:	56                   	push   %esi
f0102943:	53                   	push   %ebx
f0102944:	83 ec 0c             	sub    $0xc,%esp
    pte_t *pt;
    uint32_t pdeno, pteno;
    physaddr_t pa;

    // If freeing the current environment, switch to boot_pgdir
    // before freeing the page directory, just in case the page
    // gets reused.
    if (e == curenv)
f0102947:	8b 45 08             	mov    0x8(%ebp),%eax
f010294a:	3b 05 c4 fe 1c f0    	cmp    0xf01cfec4,%eax
f0102950:	75 08                	jne    f010295a <env_free+0x1c>
}

static __inline void
lcr3(uint32_t val)
{
f0102952:	a1 64 0b 1d f0       	mov    0xf01d0b64,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102957:	0f 22 d8             	mov    %eax,%cr3
        lcr3(boot_cr3);

    // Note the environment's demise.
    cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010295a:	83 ec 04             	sub    $0x4,%esp
f010295d:	8b 55 08             	mov    0x8(%ebp),%edx
f0102960:	ff 72 4c             	pushl  0x4c(%edx)
f0102963:	83 3d c4 fe 1c f0 00 	cmpl   $0x0,0xf01cfec4
f010296a:	74 0a                	je     f0102976 <env_free+0x38>
f010296c:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0102971:	8b 40 4c             	mov    0x4c(%eax),%eax
f0102974:	eb 05                	jmp    f010297b <env_free+0x3d>
f0102976:	b8 00 00 00 00       	mov    $0x0,%eax
f010297b:	50                   	push   %eax
f010297c:	68 5a 5c 10 f0       	push   $0xf0105c5a
f0102981:	e8 ec 03 00 00       	call   f0102d72 <cprintf>

    // Flush all mapped pages in the user portion of the address space
    static_assert(UTOP % PTSIZE == 0);
f0102986:	83 c4 10             	add    $0x10,%esp
    for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102989:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

        // only look at mapped page tables
        if (!(e->env_pgdir[pdeno] & PTE_P))
f0102990:	8b 55 08             	mov    0x8(%ebp),%edx
f0102993:	8b 42 60             	mov    0x60(%edx),%eax
f0102996:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0102999:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010299c:	a8 01                	test   $0x1,%al
f010299e:	0f 84 a1 00 00 00    	je     f0102a45 <env_free+0x107>
            continue;

        // find the pa and va of the page table
        pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01029a4:	89 c7                	mov    %eax,%edi
f01029a6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pt = (pte_t*) KADDR(pa);
f01029ac:	89 f8                	mov    %edi,%eax
f01029ae:	c1 e8 0c             	shr    $0xc,%eax
f01029b1:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f01029b7:	72 15                	jb     f01029ce <env_free+0x90>
f01029b9:	57                   	push   %edi
f01029ba:	68 e4 54 10 f0       	push   $0xf01054e4
f01029bf:	68 86 01 00 00       	push   $0x186
f01029c4:	68 3d 5c 10 f0       	push   $0xf0105c3d
f01029c9:	e9 b7 00 00 00       	jmp    f0102a85 <env_free+0x147>
f01029ce:	8d b7 00 00 00 f0    	lea    0xf0000000(%edi),%esi

        // unmap all PTEs in this page table
        for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01029d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01029d9:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01029dc:	c1 e0 16             	shl    $0x16,%eax
f01029df:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
            if (pt[pteno] & PTE_P)
f01029e2:	f6 04 9e 01          	testb  $0x1,(%esi,%ebx,4)
f01029e6:	74 1a                	je     f0102a02 <env_free+0xc4>
                page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01029e8:	83 ec 08             	sub    $0x8,%esp
f01029eb:	89 d8                	mov    %ebx,%eax
f01029ed:	c1 e0 0c             	shl    $0xc,%eax
f01029f0:	0b 45 ec             	or     0xffffffec(%ebp),%eax
f01029f3:	50                   	push   %eax
f01029f4:	8b 55 08             	mov    0x8(%ebp),%edx
f01029f7:	ff 72 60             	pushl  0x60(%edx)
f01029fa:	e8 e0 ed ff ff       	call   f01017df <page_remove>
f01029ff:	83 c4 10             	add    $0x10,%esp
f0102a02:	43                   	inc    %ebx
f0102a03:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f0102a09:	76 d7                	jbe    f01029e2 <env_free+0xa4>
        }

        // free the page table itself
        e->env_pgdir[pdeno] = 0;
f0102a0b:	8b 55 08             	mov    0x8(%ebp),%edx
f0102a0e:	8b 42 60             	mov    0x60(%edx),%eax
f0102a11:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0102a14:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102a1b:	89 f8                	mov    %edi,%eax
f0102a1d:	c1 e8 0c             	shr    $0xc,%eax
f0102a20:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f0102a26:	73 4e                	jae    f0102a76 <env_free+0x138>
		panic("pa2page called with invalid pa");
f0102a28:	89 f8                	mov    %edi,%eax
f0102a2a:	c1 e8 0c             	shr    $0xc,%eax
f0102a2d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102a30:	8b 15 6c 0b 1d f0    	mov    0xf01d0b6c,%edx
f0102a36:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102a39:	83 ec 0c             	sub    $0xc,%esp
f0102a3c:	50                   	push   %eax
f0102a3d:	e8 aa ea ff ff       	call   f01014ec <page_decref>
f0102a42:	83 c4 10             	add    $0x10,%esp
f0102a45:	ff 45 f0             	incl   0xfffffff0(%ebp)
f0102a48:	81 7d f0 ba 03 00 00 	cmpl   $0x3ba,0xfffffff0(%ebp)
f0102a4f:	0f 86 3b ff ff ff    	jbe    f0102990 <env_free+0x52>
        page_decref(pa2page(pa));
    }

    // free the page directory
    pa = e->env_cr3;
f0102a55:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a58:	8b 78 64             	mov    0x64(%eax),%edi
    e->env_pgdir = 0;
f0102a5b:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
    e->env_cr3 = 0;
f0102a62:	c7 40 64 00 00 00 00 	movl   $0x0,0x64(%eax)

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102a69:	89 f8                	mov    %edi,%eax
f0102a6b:	c1 e8 0c             	shr    $0xc,%eax
f0102a6e:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f0102a74:	72 14                	jb     f0102a8a <env_free+0x14c>
		panic("pa2page called with invalid pa");
f0102a76:	83 ec 04             	sub    $0x4,%esp
f0102a79:	68 40 56 10 f0       	push   $0xf0105640
f0102a7e:	6a 53                	push   $0x53
f0102a80:	68 52 5a 10 f0       	push   $0xf0105a52
f0102a85:	e8 5a d6 ff ff       	call   f01000e4 <_panic>
f0102a8a:	89 f8                	mov    %edi,%eax
f0102a8c:	c1 e8 0c             	shr    $0xc,%eax
f0102a8f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102a92:	8b 15 6c 0b 1d f0    	mov    0xf01d0b6c,%edx
f0102a98:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102a9b:	83 ec 0c             	sub    $0xc,%esp
f0102a9e:	50                   	push   %eax
f0102a9f:	e8 48 ea ff ff       	call   f01014ec <page_decref>
    page_decref(pa2page(pa));

    // return the environment to the free list
    e->env_status = ENV_FREE;
f0102aa4:	8b 55 08             	mov    0x8(%ebp),%edx
f0102aa7:	c7 42 54 00 00 00 00 	movl   $0x0,0x54(%edx)
    LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0102aae:	a1 c8 fe 1c f0       	mov    0xf01cfec8,%eax
f0102ab3:	89 42 44             	mov    %eax,0x44(%edx)
f0102ab6:	83 c4 10             	add    $0x10,%esp
f0102ab9:	85 c0                	test   %eax,%eax
f0102abb:	74 0e                	je     f0102acb <env_free+0x18d>
f0102abd:	8b 55 08             	mov    0x8(%ebp),%edx
f0102ac0:	83 c2 44             	add    $0x44,%edx
f0102ac3:	a1 c8 fe 1c f0       	mov    0xf01cfec8,%eax
f0102ac8:	89 50 48             	mov    %edx,0x48(%eax)
f0102acb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ace:	a3 c8 fe 1c f0       	mov    %eax,0xf01cfec8
f0102ad3:	c7 40 48 c8 fe 1c f0 	movl   $0xf01cfec8,0x48(%eax)
}
f0102ada:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102add:	5b                   	pop    %ebx
f0102ade:	5e                   	pop    %esi
f0102adf:	5f                   	pop    %edi
f0102ae0:	c9                   	leave  
f0102ae1:	c3                   	ret    

f0102ae2 <env_destroy>:

//
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102ae2:	55                   	push   %ebp
f0102ae3:	89 e5                	mov    %esp,%ebp
f0102ae5:	53                   	push   %ebx
f0102ae6:	83 ec 10             	sub    $0x10,%esp
f0102ae9:	8b 5d 08             	mov    0x8(%ebp),%ebx
    env_free(e);
f0102aec:	53                   	push   %ebx
f0102aed:	e8 4c fe ff ff       	call   f010293e <env_free>

    if (curenv == e) {
f0102af2:	83 c4 10             	add    $0x10,%esp
f0102af5:	39 1d c4 fe 1c f0    	cmp    %ebx,0xf01cfec4
f0102afb:	75 0f                	jne    f0102b0c <env_destroy+0x2a>
        curenv = NULL;
f0102afd:	c7 05 c4 fe 1c f0 00 	movl   $0x0,0xf01cfec4
f0102b04:	00 00 00 
        sched_yield();
f0102b07:	e8 e4 0e 00 00       	call   f01039f0 <sched_yield>
    }
}
f0102b0c:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0102b0f:	c9                   	leave  
f0102b10:	c3                   	ret    

f0102b11 <env_pop_tf>:


//
// Restores the register values in the Trapframe with the 'iret' instruction.
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102b11:	55                   	push   %ebp
f0102b12:	89 e5                	mov    %esp,%ebp
f0102b14:	83 ec 0c             	sub    $0xc,%esp
f0102b17:	8b 45 08             	mov    0x8(%ebp),%eax
    __asm __volatile("movl %0,%%esp\n"
f0102b1a:	89 c4                	mov    %eax,%esp
f0102b1c:	61                   	popa   
f0102b1d:	07                   	pop    %es
f0102b1e:	1f                   	pop    %ds
f0102b1f:	83 c4 08             	add    $0x8,%esp
f0102b22:	cf                   	iret   
                     "\tpopal\n"
                     "\tpopl %%es\n"
                     "\tpopl %%ds\n"
                     "\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
                     "\tiret"
                     : : "g" (tf) : "memory");
    panic("iret failed");  /* mo[stly to placate the compiler */
f0102b23:	68 70 5c 10 f0       	push   $0xf0105c70
f0102b28:	68 be 01 00 00       	push   $0x1be
f0102b2d:	68 3d 5c 10 f0       	push   $0xf0105c3d
f0102b32:	e8 ad d5 ff ff       	call   f01000e4 <_panic>

f0102b37 <env_pop_tf_sysexit>:
}
void env_pop_tf_sysexit(struct Trapframe *tf){
f0102b37:	55                   	push   %ebp
f0102b38:	89 e5                	mov    %esp,%ebp
f0102b3a:	83 ec 0c             	sub    $0xc,%esp
f0102b3d:	8b 45 08             	mov    0x8(%ebp),%eax
    /*__asm __volatile("movl %0,%%esp\n"
                     "\tpopal\n"
                     "\tpopl %%es\n"
                     "\tpopl %%ds\n"
                     "\taddl $0x8,%%esp\n" 
                     "\tiret"
                     : : "g" (tf) : "memory");*/
    //cprintf("sysexit pop_tf to:eip--%x  ebp--%x\n",tf->tf_eip,tf->tf_esp);
    tf->tf_regs.reg_ecx = tf->tf_esp;
f0102b40:	8b 50 3c             	mov    0x3c(%eax),%edx
f0102b43:	89 50 18             	mov    %edx,0x18(%eax)
    tf->tf_regs.reg_edx = tf->tf_eip;
f0102b46:	8b 50 30             	mov    0x30(%eax),%edx
f0102b49:	89 50 14             	mov    %edx,0x14(%eax)
                asm volatile(
f0102b4c:	89 c4                	mov    %eax,%esp
f0102b4e:	61                   	popa   
f0102b4f:	07                   	pop    %es
f0102b50:	1f                   	pop    %ds
f0102b51:	0f 35                	sysexit 
                "movl %0,%%esp\t\n"
                "popal\t\n"
                "popl %%es\t\n"
                "popl %%ds\t\n"
                //"addl $16, %%esp\n\t"
                //"popf\n\t"
                //"sti\n\t"
                "sysexit"
                ::"g"(tf):"cc","memory"
                        );
    panic("sysexit failed");
f0102b53:	68 7c 5c 10 f0       	push   $0xf0105c7c
f0102b58:	68 d6 01 00 00       	push   $0x1d6
f0102b5d:	68 3d 5c 10 f0       	push   $0xf0105c3d
f0102b62:	e8 7d d5 ff ff       	call   f01000e4 <_panic>

f0102b67 <env_run>:
}
//
// Context switch from curenv to env e.
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0102b67:	55                   	push   %ebp
f0102b68:	89 e5                	mov    %esp,%ebp
f0102b6a:	53                   	push   %ebx
f0102b6b:	83 ec 04             	sub    $0x4,%esp
f0102b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
    // Step 1: If this is a context switch (a new environment is running),
    //	   then set 'curenv' to the new environment,
    //	   update its 'env_runs' counter, and
    //	   and use lcr3() to switch to its address space.
    // Step 2: Use env_pop_tf() to restore the environment's
    //         registers and drop into user mode in the
    //         environment.

    // Hint: This function loads the new environment's state from
    //	e->env_tf.  Go back through the code you wrote above
    //	and make sure you have set the relevant parts of
    //	e->env_tf to sensible values.


    // LAB 3: Your code here.

    //LAB 4:  You may change this method for the process enter the kernel
    //  use the sysenter instruction.
    // Hint : you need to use the sysexit to exit to the kernel if it enter 
    //       the kernel use sysenter instruction.
    int is_sysexit = 0;
f0102b71:	ba 00 00 00 00       	mov    $0x0,%edx
    //cprintf("in the env_run function\n");
    //cprintf("Env's id = %x\n",e->env_id);
    if (curenv != NULL) {
f0102b76:	83 3d c4 fe 1c f0 00 	cmpl   $0x0,0xf01cfec4
f0102b7d:	74 17                	je     f0102b96 <env_run+0x2f>
        //cprintf("How does the env go here,is sysenter?%d\n",curenv->env_tf.tf_padding1);
        if (curenv->env_tf.tf_padding1 == 1) {
f0102b7f:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0102b84:	66 83 78 22 01       	cmpw   $0x1,0x22(%eax)
f0102b89:	75 0b                	jne    f0102b96 <env_run+0x2f>
            //cprintf("deal the condition that the env goes here by sysenter\n");
            curenv->env_tf.tf_padding1 = 0;
f0102b8b:	66 c7 40 22 00 00    	movw   $0x0,0x22(%eax)
            //cprintf("the old env has set the padding1 as 0\n");
            is_sysexit = 1;
f0102b91:	ba 01 00 00 00       	mov    $0x1,%edx
        }
    }
    //cprintf("the env arrive here\n");
    if (curenv != e) {//if curenv = e, then the runs times won't be changed.    
f0102b96:	39 1d c4 fe 1c f0    	cmp    %ebx,0xf01cfec4
f0102b9c:	74 09                	je     f0102ba7 <env_run+0x40>
        curenv = e;
f0102b9e:	89 1d c4 fe 1c f0    	mov    %ebx,0xf01cfec4
        curenv->env_runs ++;
f0102ba4:	ff 43 58             	incl   0x58(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
f0102ba7:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0102bac:	8b 40 64             	mov    0x64(%eax),%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102baf:	0f 22 d8             	mov    %eax,%cr3
    }
    
    lcr3(curenv->env_cr3);
    //cprintf("is the eflags of %d interruptable? %d\n",curenv->env_id,(curenv->env_tf.tf_eflags&FL_IF));
    //cprintf("env_run has load the cr3. esp:%x\n",curenv->env_tf.tf_esp);
    //step2
    //cprintf("env_run envid:%d\n",curenv->env_id);
    if(is_sysexit) {
f0102bb2:	85 d2                	test   %edx,%edx
f0102bb4:	74 0c                	je     f0102bc2 <env_run+0x5b>
        env_pop_tf_sysexit(&(e->env_tf));
f0102bb6:	83 ec 0c             	sub    $0xc,%esp
f0102bb9:	53                   	push   %ebx
f0102bba:	e8 78 ff ff ff       	call   f0102b37 <env_pop_tf_sysexit>
f0102bbf:	83 c4 10             	add    $0x10,%esp
    }
    env_pop_tf(&(e->env_tf));
f0102bc2:	83 ec 0c             	sub    $0xc,%esp
f0102bc5:	53                   	push   %ebx
f0102bc6:	e8 46 ff ff ff       	call   f0102b11 <env_pop_tf>
	...

f0102bcc <mc146818_read>:


unsigned
mc146818_read(unsigned reg)
{
f0102bcc:	55                   	push   %ebp
f0102bcd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
f0102bcf:	ba 70 00 00 00       	mov    $0x70,%edx
f0102bd4:	8a 45 08             	mov    0x8(%ebp),%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bd7:	ee                   	out    %al,(%dx)
f0102bd8:	ba 71 00 00 00       	mov    $0x71,%edx
f0102bdd:	ec                   	in     (%dx),%al
f0102bde:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0102be1:	c9                   	leave  
f0102be2:	c3                   	ret    

f0102be3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102be3:	55                   	push   %ebp
f0102be4:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
f0102be6:	ba 70 00 00 00       	mov    $0x70,%edx
f0102beb:	8a 45 08             	mov    0x8(%ebp),%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bee:	ee                   	out    %al,(%dx)
f0102bef:	ba 71 00 00 00       	mov    $0x71,%edx
f0102bf4:	8a 45 0c             	mov    0xc(%ebp),%al
f0102bf7:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102bf8:	c9                   	leave  
f0102bf9:	c3                   	ret    

f0102bfa <kclock_init>:


void
kclock_init(void)
{
f0102bfa:	55                   	push   %ebp
f0102bfb:	89 e5                	mov    %esp,%ebp
f0102bfd:	83 ec 14             	sub    $0x14,%esp
}

static __inline void
outb(int port, uint8_t data)
{
f0102c00:	ba 43 00 00 00       	mov    $0x43,%edx
f0102c05:	b0 34                	mov    $0x34,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c07:	ee                   	out    %al,(%dx)
f0102c08:	ba 40 00 00 00       	mov    $0x40,%edx
f0102c0d:	b0 9c                	mov    $0x9c,%al
f0102c0f:	ee                   	out    %al,(%dx)
f0102c10:	b0 2e                	mov    $0x2e,%al
f0102c12:	ee                   	out    %al,(%dx)
	/* initialize 8253 clock to interrupt 100 times/sec */
	outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
	outb(IO_TIMER1, TIMER_DIV(100) % 256);
	outb(IO_TIMER1, TIMER_DIV(100) / 256);
	cprintf("	Setup timer interrupts via 8259A\n");
f0102c13:	68 8c 5c 10 f0       	push   $0xf0105c8c
f0102c18:	e8 55 01 00 00       	call   f0102d72 <cprintf>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<0));
f0102c1d:	0f b7 05 b8 d5 11 f0 	movzwl 0xf011d5b8,%eax
f0102c24:	25 fe ff 00 00       	and    $0xfffe,%eax
f0102c29:	89 04 24             	mov    %eax,(%esp)
f0102c2c:	e8 8e 00 00 00       	call   f0102cbf <irq_setmask_8259A>
	cprintf("	unmasked timer interrupt\n");
f0102c31:	c7 04 24 af 5c 10 f0 	movl   $0xf0105caf,(%esp)
f0102c38:	e8 35 01 00 00       	call   f0102d72 <cprintf>
}
f0102c3d:	c9                   	leave  
f0102c3e:	c3                   	ret    
	...

f0102c40 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0102c40:	55                   	push   %ebp
f0102c41:	89 e5                	mov    %esp,%ebp
f0102c43:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f0102c46:	c7 05 cc fe 1c f0 01 	movl   $0x1,0xf01cfecc
f0102c4d:	00 00 00 
}

static __inline void
outb(int port, uint8_t data)
{
f0102c50:	ba 21 00 00 00       	mov    $0x21,%edx
f0102c55:	b0 ff                	mov    $0xff,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c57:	ee                   	out    %al,(%dx)
f0102c58:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102c5d:	ee                   	out    %al,(%dx)
f0102c5e:	ba 20 00 00 00       	mov    $0x20,%edx
f0102c63:	b0 11                	mov    $0x11,%al
f0102c65:	ee                   	out    %al,(%dx)
f0102c66:	ba 21 00 00 00       	mov    $0x21,%edx
f0102c6b:	b0 20                	mov    $0x20,%al
f0102c6d:	ee                   	out    %al,(%dx)
f0102c6e:	b0 04                	mov    $0x4,%al
f0102c70:	ee                   	out    %al,(%dx)
f0102c71:	b0 03                	mov    $0x3,%al
f0102c73:	ee                   	out    %al,(%dx)
f0102c74:	ba a0 00 00 00       	mov    $0xa0,%edx
f0102c79:	b0 11                	mov    $0x11,%al
f0102c7b:	ee                   	out    %al,(%dx)
f0102c7c:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102c81:	b0 28                	mov    $0x28,%al
f0102c83:	ee                   	out    %al,(%dx)
f0102c84:	b0 02                	mov    $0x2,%al
f0102c86:	ee                   	out    %al,(%dx)
f0102c87:	b0 01                	mov    $0x1,%al
f0102c89:	ee                   	out    %al,(%dx)
f0102c8a:	ba 20 00 00 00       	mov    $0x20,%edx
f0102c8f:	b0 68                	mov    $0x68,%al
f0102c91:	ee                   	out    %al,(%dx)
f0102c92:	b0 0a                	mov    $0xa,%al
f0102c94:	ee                   	out    %al,(%dx)
f0102c95:	ba a0 00 00 00       	mov    $0xa0,%edx
f0102c9a:	b0 68                	mov    $0x68,%al
f0102c9c:	ee                   	out    %al,(%dx)
f0102c9d:	b0 0a                	mov    $0xa,%al
f0102c9f:	ee                   	out    %al,(%dx)

	// mask all interrupts
	outb(IO_PIC1+1, 0xFF);
	outb(IO_PIC2+1, 0xFF);

	// Set up master (8259A-1)

	// ICW1:  0001g0hi
	//    g:  0 = edge triggering, 1 = level triggering
	//    h:  0 = cascaded PICs, 1 = master only
	//    i:  0 = no ICW4, 1 = ICW4 required
	outb(IO_PIC1, 0x11);

	// ICW2:  Vector offset
	outb(IO_PIC1+1, IRQ_OFFSET);

	// ICW3:  bit mask of IR lines connected to slave PICs (master PIC),
	//        3-bit No of IR line at which slave connects to master(slave PIC).
	outb(IO_PIC1+1, 1<<IRQ_SLAVE);

	// ICW4:  000nbmap
	//    n:  1 = special fully nested mode
	//    b:  1 = buffered mode
	//    m:  0 = slave PIC, 1 = master PIC
	//	  (ignored when b is 0, as the master/slave role
	//	  can be hardwired).
	//    a:  1 = Automatic EOI mode
	//    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
	outb(IO_PIC1+1, 0x3);

	// Set up slave (8259A-2)
	outb(IO_PIC2, 0x11);			// ICW1
	outb(IO_PIC2+1, IRQ_OFFSET + 8);	// ICW2
	outb(IO_PIC2+1, IRQ_SLAVE);		// ICW3
	// NB Automatic EOI mode doesn't tend to work on the slave.
	// Linux source code says it's "to be investigated".
	outb(IO_PIC2+1, 0x01);			// ICW4

	// OCW3:  0ef01prs
	//   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
	//    p:  0 = no polling, 1 = polling mode
	//   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
	outb(IO_PIC1, 0x68);             /* clear specific mask */
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0102ca0:	66 83 3d b8 d5 11 f0 	cmpw   $0xffffffff,0xf011d5b8
f0102ca7:	ff 
f0102ca8:	74 13                	je     f0102cbd <pic_init+0x7d>
		irq_setmask_8259A(irq_mask_8259A);
f0102caa:	83 ec 0c             	sub    $0xc,%esp
f0102cad:	0f b7 05 b8 d5 11 f0 	movzwl 0xf011d5b8,%eax
f0102cb4:	50                   	push   %eax
f0102cb5:	e8 05 00 00 00       	call   f0102cbf <irq_setmask_8259A>
f0102cba:	83 c4 10             	add    $0x10,%esp
}
f0102cbd:	c9                   	leave  
f0102cbe:	c3                   	ret    

f0102cbf <irq_setmask_8259A>:

void
irq_setmask_8259A(uint16_t mask)
{
f0102cbf:	55                   	push   %ebp
f0102cc0:	89 e5                	mov    %esp,%ebp
f0102cc2:	56                   	push   %esi
f0102cc3:	53                   	push   %ebx
f0102cc4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cc7:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0102cc9:	66 a3 b8 d5 11 f0    	mov    %ax,0xf011d5b8
	if (!didinit)
f0102ccf:	83 3d cc fe 1c f0 00 	cmpl   $0x0,0xf01cfecc
f0102cd6:	74 5c                	je     f0102d34 <irq_setmask_8259A+0x75>
}

static __inline void
outb(int port, uint8_t data)
{
f0102cd8:	ba 21 00 00 00       	mov    $0x21,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102cdd:	ee                   	out    %al,(%dx)
f0102cde:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102ce3:	89 f0                	mov    %esi,%eax
f0102ce5:	66 c1 e8 08          	shr    $0x8,%ax
f0102ce9:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0102cea:	83 ec 0c             	sub    $0xc,%esp
f0102ced:	68 ca 5c 10 f0       	push   $0xf0105cca
f0102cf2:	e8 7b 00 00 00       	call   f0102d72 <cprintf>
	for (i = 0; i < 16; i++)
f0102cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102cfc:	83 c4 10             	add    $0x10,%esp
f0102cff:	0f b7 c6             	movzwl %si,%eax
f0102d02:	89 c6                	mov    %eax,%esi
f0102d04:	f7 d6                	not    %esi
		if (~mask & (1<<i))
f0102d06:	89 f0                	mov    %esi,%eax
f0102d08:	88 d9                	mov    %bl,%cl
f0102d0a:	d3 f8                	sar    %cl,%eax
f0102d0c:	a8 01                	test   $0x1,%al
f0102d0e:	74 11                	je     f0102d21 <irq_setmask_8259A+0x62>
			cprintf(" %d", i);
f0102d10:	83 ec 08             	sub    $0x8,%esp
f0102d13:	53                   	push   %ebx
f0102d14:	68 8f 63 10 f0       	push   $0xf010638f
f0102d19:	e8 54 00 00 00       	call   f0102d72 <cprintf>
f0102d1e:	83 c4 10             	add    $0x10,%esp
f0102d21:	43                   	inc    %ebx
f0102d22:	83 fb 0f             	cmp    $0xf,%ebx
f0102d25:	7e df                	jle    f0102d06 <irq_setmask_8259A+0x47>
	cprintf("\n");
f0102d27:	83 ec 0c             	sub    $0xc,%esp
f0102d2a:	68 17 5c 10 f0       	push   $0xf0105c17
f0102d2f:	e8 3e 00 00 00       	call   f0102d72 <cprintf>
}
f0102d34:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0102d37:	5b                   	pop    %ebx
f0102d38:	5e                   	pop    %esi
f0102d39:	c9                   	leave  
f0102d3a:	c3                   	ret    
	...

f0102d3c <putch>:


static void
putch(int ch, int *cnt)
{
f0102d3c:	55                   	push   %ebp
f0102d3d:	89 e5                	mov    %esp,%ebp
f0102d3f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102d42:	ff 75 08             	pushl  0x8(%ebp)
f0102d45:	e8 13 d9 ff ff       	call   f010065d <cputchar>
	*cnt++;
}
f0102d4a:	c9                   	leave  
f0102d4b:	c3                   	ret    

f0102d4c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d4c:	55                   	push   %ebp
f0102d4d:	89 e5                	mov    %esp,%ebp
f0102d4f:	83 ec 08             	sub    $0x8,%esp
	int cnt = 0;
f0102d52:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d59:	ff 75 0c             	pushl  0xc(%ebp)
f0102d5c:	ff 75 08             	pushl  0x8(%ebp)
f0102d5f:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f0102d62:	50                   	push   %eax
f0102d63:	68 3c 2d 10 f0       	push   $0xf0102d3c
f0102d68:	e8 fd 19 00 00       	call   f010476a <vprintfmt>
	return cnt;
f0102d6d:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
f0102d70:	c9                   	leave  
f0102d71:	c3                   	ret    

f0102d72 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102d72:	55                   	push   %ebp
f0102d73:	89 e5                	mov    %esp,%ebp
f0102d75:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102d78:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102d7b:	50                   	push   %eax
f0102d7c:	ff 75 08             	pushl  0x8(%ebp)
f0102d7f:	e8 c8 ff ff ff       	call   f0102d4c <vcprintf>
	va_end(ap);

	return cnt;
}
f0102d84:	c9                   	leave  
f0102d85:	c3                   	ret    
	...

f0102d88 <trapname>:
};


static const char *trapname(int trapno)
{
f0102d88:	55                   	push   %ebp
f0102d89:	89 e5                	mov    %esp,%ebp
f0102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
    static const char * const excnames[] = {
        "Divide error",
        "Debug",
        "Non-Maskable Interrupt",
        "Breakpoint",
        "Overflow",
        "BOUND Range Exceeded",
        "Invalid Opcode",
        "Device Not Available",
        "Double Fault",
        "Coprocessor Segment Overrun",
        "Invalid TSS",
        "Segment Not Present",
        "Stack Fault",
        "General Protection",
        "Page Fault",
        "(unknown trap)",
        "x87 FPU Floating-Point Error",
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0102d8e:	83 f8 13             	cmp    $0x13,%eax
f0102d91:	77 09                	ja     f0102d9c <trapname+0x14>
        return excnames[trapno];
f0102d93:	8b 14 85 c0 5f 10 f0 	mov    0xf0105fc0(,%eax,4),%edx
f0102d9a:	eb 1c                	jmp    f0102db8 <trapname+0x30>
    if (trapno == T_SYSCALL)
f0102d9c:	ba 30 5e 10 f0       	mov    $0xf0105e30,%edx
f0102da1:	83 f8 30             	cmp    $0x30,%eax
f0102da4:	74 12                	je     f0102db8 <trapname+0x30>
        return "System call";
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0102da6:	83 e8 20             	sub    $0x20,%eax
f0102da9:	ba 3c 5e 10 f0       	mov    $0xf0105e3c,%edx
f0102dae:	83 f8 0f             	cmp    $0xf,%eax
f0102db1:	76 05                	jbe    f0102db8 <trapname+0x30>
        return "Hardware Interrupt";
    return "(unknown trap)";
f0102db3:	ba c8 5d 10 f0       	mov    $0xf0105dc8,%edx
}
f0102db8:	89 d0                	mov    %edx,%eax
f0102dba:	c9                   	leave  
f0102dbb:	c3                   	ret    

f0102dbc <idt_init>:


void
idt_init(void)
{
f0102dbc:	55                   	push   %ebp
f0102dbd:	89 e5                	mov    %esp,%ebp
f0102dbf:	53                   	push   %ebx
    extern struct Segdesc gdt[];

    // LAB 3: Your code here.
    extern uint32_t handler0;
    extern uint32_t handler1;
    extern uint32_t handler2;
    extern uint32_t handler3;
    extern uint32_t handler4;
    extern uint32_t handler5;
    extern uint32_t handler6;
    extern uint32_t handler7;
    extern uint32_t handler8;
    extern uint32_t handler9;
    extern uint32_t handler10;
    extern uint32_t handler11;
    extern uint32_t handler12;
    extern uint32_t handler13;
    extern uint32_t handler14;
    extern uint32_t handler15;
    extern uint32_t handler16;
    extern uint32_t handler17;
    extern uint32_t handler18;
    extern uint32_t handler19;
    extern uint32_t handler48;

    extern uint32_t inthandler0;
    extern uint32_t inthandler1;
    extern uint32_t inthandler2;
    extern uint32_t inthandler3;
    extern uint32_t inthandler4;
    extern uint32_t inthandler5;
    extern uint32_t inthandler6;
    extern uint32_t inthandler7;
    extern uint32_t inthandler8;
    extern uint32_t inthandler9;
    extern uint32_t inthandler10;
    extern uint32_t inthandler11;
    extern uint32_t inthandler12;
    extern uint32_t inthandler13;
    extern uint32_t inthandler14;
    extern uint32_t inthandler15;
    //extern uint32_t sysenterhandler;
    SETGATE(idt[T_DIVIDE], 0, GD_KT, &handler0, 0);
f0102dc0:	b9 a4 38 10 f0       	mov    $0xf01038a4,%ecx
f0102dc5:	66 89 0d e0 fe 1c f0 	mov    %cx,0xf01cfee0
f0102dcc:	66 c7 05 e2 fe 1c f0 	movw   $0x8,0xf01cfee2
f0102dd3:	08 00 
f0102dd5:	a0 e4 fe 1c f0       	mov    0xf01cfee4,%al
f0102dda:	83 e0 e0             	and    $0xffffffe0,%eax
f0102ddd:	a2 e4 fe 1c f0       	mov    %al,0xf01cfee4
f0102de2:	83 e0 1f             	and    $0x1f,%eax
f0102de5:	a2 e4 fe 1c f0       	mov    %al,0xf01cfee4
f0102dea:	a0 e5 fe 1c f0       	mov    0xf01cfee5,%al
f0102def:	83 e0 f0             	and    $0xfffffff0,%eax
f0102df2:	83 c8 0e             	or     $0xe,%eax
f0102df5:	a2 e5 fe 1c f0       	mov    %al,0xf01cfee5
f0102dfa:	88 c2                	mov    %al,%dl
f0102dfc:	83 e2 ef             	and    $0xffffffef,%edx
f0102dff:	88 15 e5 fe 1c f0    	mov    %dl,0xf01cfee5
f0102e05:	83 e0 8f             	and    $0xffffff8f,%eax
f0102e08:	a2 e5 fe 1c f0       	mov    %al,0xf01cfee5
f0102e0d:	83 c8 80             	or     $0xffffff80,%eax
f0102e10:	a2 e5 fe 1c f0       	mov    %al,0xf01cfee5
f0102e15:	c1 e9 10             	shr    $0x10,%ecx
f0102e18:	66 89 0d e6 fe 1c f0 	mov    %cx,0xf01cfee6
    SETGATE(idt[T_DEBUG], 0, GD_KT, &handler1, 0);
f0102e1f:	b9 ae 38 10 f0       	mov    $0xf01038ae,%ecx
f0102e24:	66 89 0d e8 fe 1c f0 	mov    %cx,0xf01cfee8
f0102e2b:	66 c7 05 ea fe 1c f0 	movw   $0x8,0xf01cfeea
f0102e32:	08 00 
f0102e34:	a0 ec fe 1c f0       	mov    0xf01cfeec,%al
f0102e39:	83 e0 e0             	and    $0xffffffe0,%eax
f0102e3c:	a2 ec fe 1c f0       	mov    %al,0xf01cfeec
f0102e41:	83 e0 1f             	and    $0x1f,%eax
f0102e44:	a2 ec fe 1c f0       	mov    %al,0xf01cfeec
f0102e49:	a0 ed fe 1c f0       	mov    0xf01cfeed,%al
f0102e4e:	83 e0 f0             	and    $0xfffffff0,%eax
f0102e51:	83 c8 0e             	or     $0xe,%eax
f0102e54:	a2 ed fe 1c f0       	mov    %al,0xf01cfeed
f0102e59:	88 c2                	mov    %al,%dl
f0102e5b:	83 e2 ef             	and    $0xffffffef,%edx
f0102e5e:	88 15 ed fe 1c f0    	mov    %dl,0xf01cfeed
f0102e64:	83 e0 8f             	and    $0xffffff8f,%eax
f0102e67:	a2 ed fe 1c f0       	mov    %al,0xf01cfeed
f0102e6c:	83 c8 80             	or     $0xffffff80,%eax
f0102e6f:	a2 ed fe 1c f0       	mov    %al,0xf01cfeed
f0102e74:	c1 e9 10             	shr    $0x10,%ecx
f0102e77:	66 89 0d ee fe 1c f0 	mov    %cx,0xf01cfeee
    SETGATE(idt[T_NMI], 0, GD_KT, &handler2, 0);
f0102e7e:	b9 b8 38 10 f0       	mov    $0xf01038b8,%ecx
f0102e83:	66 89 0d f0 fe 1c f0 	mov    %cx,0xf01cfef0
f0102e8a:	66 c7 05 f2 fe 1c f0 	movw   $0x8,0xf01cfef2
f0102e91:	08 00 
f0102e93:	a0 f4 fe 1c f0       	mov    0xf01cfef4,%al
f0102e98:	83 e0 e0             	and    $0xffffffe0,%eax
f0102e9b:	a2 f4 fe 1c f0       	mov    %al,0xf01cfef4
f0102ea0:	83 e0 1f             	and    $0x1f,%eax
f0102ea3:	a2 f4 fe 1c f0       	mov    %al,0xf01cfef4
f0102ea8:	a0 f5 fe 1c f0       	mov    0xf01cfef5,%al
f0102ead:	83 e0 f0             	and    $0xfffffff0,%eax
f0102eb0:	83 c8 0e             	or     $0xe,%eax
f0102eb3:	a2 f5 fe 1c f0       	mov    %al,0xf01cfef5
f0102eb8:	88 c2                	mov    %al,%dl
f0102eba:	83 e2 ef             	and    $0xffffffef,%edx
f0102ebd:	88 15 f5 fe 1c f0    	mov    %dl,0xf01cfef5
f0102ec3:	83 e0 8f             	and    $0xffffff8f,%eax
f0102ec6:	a2 f5 fe 1c f0       	mov    %al,0xf01cfef5
f0102ecb:	83 c8 80             	or     $0xffffff80,%eax
f0102ece:	a2 f5 fe 1c f0       	mov    %al,0xf01cfef5
f0102ed3:	c1 e9 10             	shr    $0x10,%ecx
f0102ed6:	66 89 0d f6 fe 1c f0 	mov    %cx,0xf01cfef6
    SETGATE(idt[T_BRKPT], 0, GD_KT, &handler3, 3);/*low Privilege*/
f0102edd:	b8 c2 38 10 f0       	mov    $0xf01038c2,%eax
f0102ee2:	66 a3 f8 fe 1c f0    	mov    %ax,0xf01cfef8
f0102ee8:	66 c7 05 fa fe 1c f0 	movw   $0x8,0xf01cfefa
f0102eef:	08 00 
f0102ef1:	c6 05 fc fe 1c f0 00 	movb   $0x0,0xf01cfefc
f0102ef8:	c6 05 fd fe 1c f0 ee 	movb   $0xee,0xf01cfefd
f0102eff:	c1 e8 10             	shr    $0x10,%eax
f0102f02:	66 a3 fe fe 1c f0    	mov    %ax,0xf01cfefe
    SETGATE(idt[T_OFLOW], 0, GD_KT, &handler4, 0);
f0102f08:	b8 cc 38 10 f0       	mov    $0xf01038cc,%eax
f0102f0d:	66 a3 00 ff 1c f0    	mov    %ax,0xf01cff00
f0102f13:	66 c7 05 02 ff 1c f0 	movw   $0x8,0xf01cff02
f0102f1a:	08 00 
f0102f1c:	c6 05 04 ff 1c f0 00 	movb   $0x0,0xf01cff04
f0102f23:	c6 05 05 ff 1c f0 8e 	movb   $0x8e,0xf01cff05
f0102f2a:	c1 e8 10             	shr    $0x10,%eax
f0102f2d:	66 a3 06 ff 1c f0    	mov    %ax,0xf01cff06
    SETGATE(idt[T_BOUND], 0, GD_KT, &handler5, 0);
f0102f33:	b8 d6 38 10 f0       	mov    $0xf01038d6,%eax
f0102f38:	66 a3 08 ff 1c f0    	mov    %ax,0xf01cff08
f0102f3e:	66 c7 05 0a ff 1c f0 	movw   $0x8,0xf01cff0a
f0102f45:	08 00 
f0102f47:	c6 05 0c ff 1c f0 00 	movb   $0x0,0xf01cff0c
f0102f4e:	c6 05 0d ff 1c f0 8e 	movb   $0x8e,0xf01cff0d
f0102f55:	c1 e8 10             	shr    $0x10,%eax
f0102f58:	66 a3 0e ff 1c f0    	mov    %ax,0xf01cff0e
    SETGATE(idt[T_ILLOP], 0, GD_KT, &handler6, 0);
f0102f5e:	b8 e0 38 10 f0       	mov    $0xf01038e0,%eax
f0102f63:	66 a3 10 ff 1c f0    	mov    %ax,0xf01cff10
f0102f69:	66 c7 05 12 ff 1c f0 	movw   $0x8,0xf01cff12
f0102f70:	08 00 
f0102f72:	c6 05 14 ff 1c f0 00 	movb   $0x0,0xf01cff14
f0102f79:	c6 05 15 ff 1c f0 8e 	movb   $0x8e,0xf01cff15
f0102f80:	c1 e8 10             	shr    $0x10,%eax
f0102f83:	66 a3 16 ff 1c f0    	mov    %ax,0xf01cff16
    SETGATE(idt[T_DEVICE], 0, GD_KT, &handler7, 0);
f0102f89:	b8 ea 38 10 f0       	mov    $0xf01038ea,%eax
f0102f8e:	66 a3 18 ff 1c f0    	mov    %ax,0xf01cff18
f0102f94:	66 c7 05 1a ff 1c f0 	movw   $0x8,0xf01cff1a
f0102f9b:	08 00 
f0102f9d:	c6 05 1c ff 1c f0 00 	movb   $0x0,0xf01cff1c
f0102fa4:	c6 05 1d ff 1c f0 8e 	movb   $0x8e,0xf01cff1d
f0102fab:	c1 e8 10             	shr    $0x10,%eax
f0102fae:	66 a3 1e ff 1c f0    	mov    %ax,0xf01cff1e
    SETGATE(idt[T_DBLFLT], 0, GD_KT, &handler8, 0);
f0102fb4:	b8 f4 38 10 f0       	mov    $0xf01038f4,%eax
f0102fb9:	66 a3 20 ff 1c f0    	mov    %ax,0xf01cff20
f0102fbf:	66 c7 05 22 ff 1c f0 	movw   $0x8,0xf01cff22
f0102fc6:	08 00 
f0102fc8:	c6 05 24 ff 1c f0 00 	movb   $0x0,0xf01cff24
f0102fcf:	c6 05 25 ff 1c f0 8e 	movb   $0x8e,0xf01cff25
f0102fd6:	c1 e8 10             	shr    $0x10,%eax
f0102fd9:	66 a3 26 ff 1c f0    	mov    %ax,0xf01cff26

    SETGATE(idt[T_TSS], 0, GD_KT, &handler10, 0);
f0102fdf:	b8 06 39 10 f0       	mov    $0xf0103906,%eax
f0102fe4:	66 a3 30 ff 1c f0    	mov    %ax,0xf01cff30
f0102fea:	66 c7 05 32 ff 1c f0 	movw   $0x8,0xf01cff32
f0102ff1:	08 00 
f0102ff3:	c6 05 34 ff 1c f0 00 	movb   $0x0,0xf01cff34
f0102ffa:	c6 05 35 ff 1c f0 8e 	movb   $0x8e,0xf01cff35
f0103001:	c1 e8 10             	shr    $0x10,%eax
f0103004:	66 a3 36 ff 1c f0    	mov    %ax,0xf01cff36
    SETGATE(idt[T_SEGNP], 0, GD_KT, &handler11, 0);
f010300a:	b8 0e 39 10 f0       	mov    $0xf010390e,%eax
f010300f:	66 a3 38 ff 1c f0    	mov    %ax,0xf01cff38
f0103015:	66 c7 05 3a ff 1c f0 	movw   $0x8,0xf01cff3a
f010301c:	08 00 
f010301e:	c6 05 3c ff 1c f0 00 	movb   $0x0,0xf01cff3c
f0103025:	c6 05 3d ff 1c f0 8e 	movb   $0x8e,0xf01cff3d
f010302c:	c1 e8 10             	shr    $0x10,%eax
f010302f:	66 a3 3e ff 1c f0    	mov    %ax,0xf01cff3e
    SETGATE(idt[T_STACK], 0, GD_KT, &handler12, 0);
f0103035:	b8 16 39 10 f0       	mov    $0xf0103916,%eax
f010303a:	66 a3 40 ff 1c f0    	mov    %ax,0xf01cff40
f0103040:	66 c7 05 42 ff 1c f0 	movw   $0x8,0xf01cff42
f0103047:	08 00 
f0103049:	c6 05 44 ff 1c f0 00 	movb   $0x0,0xf01cff44
f0103050:	c6 05 45 ff 1c f0 8e 	movb   $0x8e,0xf01cff45
f0103057:	c1 e8 10             	shr    $0x10,%eax
f010305a:	66 a3 46 ff 1c f0    	mov    %ax,0xf01cff46
    SETGATE(idt[T_GPFLT], 0, GD_KT, &handler13, 0);
f0103060:	b8 1e 39 10 f0       	mov    $0xf010391e,%eax
f0103065:	66 a3 48 ff 1c f0    	mov    %ax,0xf01cff48
f010306b:	66 c7 05 4a ff 1c f0 	movw   $0x8,0xf01cff4a
f0103072:	08 00 
f0103074:	c6 05 4c ff 1c f0 00 	movb   $0x0,0xf01cff4c
f010307b:	c6 05 4d ff 1c f0 8e 	movb   $0x8e,0xf01cff4d
f0103082:	c1 e8 10             	shr    $0x10,%eax
f0103085:	66 a3 4e ff 1c f0    	mov    %ax,0xf01cff4e
    SETGATE(idt[T_PGFLT], 0, GD_KT, &handler14, 0);
f010308b:	b8 26 39 10 f0       	mov    $0xf0103926,%eax
f0103090:	66 a3 50 ff 1c f0    	mov    %ax,0xf01cff50
f0103096:	66 c7 05 52 ff 1c f0 	movw   $0x8,0xf01cff52
f010309d:	08 00 
f010309f:	c6 05 54 ff 1c f0 00 	movb   $0x0,0xf01cff54
f01030a6:	c6 05 55 ff 1c f0 8e 	movb   $0x8e,0xf01cff55
f01030ad:	c1 e8 10             	shr    $0x10,%eax
f01030b0:	66 a3 56 ff 1c f0    	mov    %ax,0xf01cff56

    SETGATE(idt[T_FPERR], 0, GD_KT, &handler16, 0);
f01030b6:	b8 32 39 10 f0       	mov    $0xf0103932,%eax
f01030bb:	66 a3 60 ff 1c f0    	mov    %ax,0xf01cff60
f01030c1:	66 c7 05 62 ff 1c f0 	movw   $0x8,0xf01cff62
f01030c8:	08 00 
f01030ca:	c6 05 64 ff 1c f0 00 	movb   $0x0,0xf01cff64
f01030d1:	c6 05 65 ff 1c f0 8e 	movb   $0x8e,0xf01cff65
f01030d8:	c1 e8 10             	shr    $0x10,%eax
f01030db:	66 a3 66 ff 1c f0    	mov    %ax,0xf01cff66
    SETGATE(idt[T_ALIGN], 0, GD_KT, &handler17, 0);
f01030e1:	b8 38 39 10 f0       	mov    $0xf0103938,%eax
f01030e6:	66 a3 68 ff 1c f0    	mov    %ax,0xf01cff68
f01030ec:	66 c7 05 6a ff 1c f0 	movw   $0x8,0xf01cff6a
f01030f3:	08 00 
f01030f5:	c6 05 6c ff 1c f0 00 	movb   $0x0,0xf01cff6c
f01030fc:	c6 05 6d ff 1c f0 8e 	movb   $0x8e,0xf01cff6d
f0103103:	c1 e8 10             	shr    $0x10,%eax
f0103106:	66 a3 6e ff 1c f0    	mov    %ax,0xf01cff6e
    SETGATE(idt[T_MCHK], 0, GD_KT, &handler18, 0);
f010310c:	b8 3e 39 10 f0       	mov    $0xf010393e,%eax
f0103111:	66 a3 70 ff 1c f0    	mov    %ax,0xf01cff70
f0103117:	66 c7 05 72 ff 1c f0 	movw   $0x8,0xf01cff72
f010311e:	08 00 
f0103120:	c6 05 74 ff 1c f0 00 	movb   $0x0,0xf01cff74
f0103127:	c6 05 75 ff 1c f0 8e 	movb   $0x8e,0xf01cff75
f010312e:	c1 e8 10             	shr    $0x10,%eax
f0103131:	66 a3 76 ff 1c f0    	mov    %ax,0xf01cff76
    SETGATE(idt[T_SIMDERR], 0, GD_KT, &handler19, 0);
f0103137:	b8 44 39 10 f0       	mov    $0xf0103944,%eax
f010313c:	66 a3 78 ff 1c f0    	mov    %ax,0xf01cff78
f0103142:	66 c7 05 7a ff 1c f0 	movw   $0x8,0xf01cff7a
f0103149:	08 00 
f010314b:	c6 05 7c ff 1c f0 00 	movb   $0x0,0xf01cff7c
f0103152:	c6 05 7d ff 1c f0 8e 	movb   $0x8e,0xf01cff7d
f0103159:	c1 e8 10             	shr    $0x10,%eax
f010315c:	66 a3 7e ff 1c f0    	mov    %ax,0xf01cff7e
    SETGATE(idt[T_SYSCALL],0,GD_KT,&handler48,3);
f0103162:	b8 4a 39 10 f0       	mov    $0xf010394a,%eax
f0103167:	66 a3 60 00 1d f0    	mov    %ax,0xf01d0060
f010316d:	66 c7 05 62 00 1d f0 	movw   $0x8,0xf01d0062
f0103174:	08 00 
f0103176:	c6 05 64 00 1d f0 00 	movb   $0x0,0xf01d0064
f010317d:	c6 05 65 00 1d f0 ee 	movb   $0xee,0xf01d0065
f0103184:	c1 e8 10             	shr    $0x10,%eax
f0103187:	66 a3 66 00 1d f0    	mov    %ax,0xf01d0066
    SETGATE(idt[IRQ_OFFSET],0,GD_KT,&inthandler0,0);
f010318d:	b8 50 39 10 f0       	mov    $0xf0103950,%eax
f0103192:	66 a3 e0 ff 1c f0    	mov    %ax,0xf01cffe0
f0103198:	66 c7 05 e2 ff 1c f0 	movw   $0x8,0xf01cffe2
f010319f:	08 00 
f01031a1:	c6 05 e4 ff 1c f0 00 	movb   $0x0,0xf01cffe4
f01031a8:	c6 05 e5 ff 1c f0 8e 	movb   $0x8e,0xf01cffe5
f01031af:	c1 e8 10             	shr    $0x10,%eax
f01031b2:	66 a3 e6 ff 1c f0    	mov    %ax,0xf01cffe6
    SETGATE(idt[IRQ_OFFSET+1],0,GD_KT,&inthandler1,0);
f01031b8:	b8 56 39 10 f0       	mov    $0xf0103956,%eax
f01031bd:	66 a3 e8 ff 1c f0    	mov    %ax,0xf01cffe8
f01031c3:	66 c7 05 ea ff 1c f0 	movw   $0x8,0xf01cffea
f01031ca:	08 00 
f01031cc:	c6 05 ec ff 1c f0 00 	movb   $0x0,0xf01cffec
f01031d3:	c6 05 ed ff 1c f0 8e 	movb   $0x8e,0xf01cffed
f01031da:	c1 e8 10             	shr    $0x10,%eax
f01031dd:	66 a3 ee ff 1c f0    	mov    %ax,0xf01cffee
    SETGATE(idt[IRQ_OFFSET+2],0,GD_KT,&inthandler2,0);
f01031e3:	b8 5c 39 10 f0       	mov    $0xf010395c,%eax
f01031e8:	66 a3 f0 ff 1c f0    	mov    %ax,0xf01cfff0
f01031ee:	66 c7 05 f2 ff 1c f0 	movw   $0x8,0xf01cfff2
f01031f5:	08 00 
f01031f7:	c6 05 f4 ff 1c f0 00 	movb   $0x0,0xf01cfff4
f01031fe:	c6 05 f5 ff 1c f0 8e 	movb   $0x8e,0xf01cfff5
f0103205:	c1 e8 10             	shr    $0x10,%eax
f0103208:	66 a3 f6 ff 1c f0    	mov    %ax,0xf01cfff6
    SETGATE(idt[IRQ_OFFSET+3],0,GD_KT,&inthandler3,0);
f010320e:	b8 62 39 10 f0       	mov    $0xf0103962,%eax
f0103213:	66 a3 f8 ff 1c f0    	mov    %ax,0xf01cfff8
f0103219:	66 c7 05 fa ff 1c f0 	movw   $0x8,0xf01cfffa
f0103220:	08 00 
f0103222:	c6 05 fc ff 1c f0 00 	movb   $0x0,0xf01cfffc
f0103229:	c6 05 fd ff 1c f0 8e 	movb   $0x8e,0xf01cfffd
f0103230:	c1 e8 10             	shr    $0x10,%eax
f0103233:	66 a3 fe ff 1c f0    	mov    %ax,0xf01cfffe
    SETGATE(idt[IRQ_OFFSET+4],0,GD_KT,&inthandler4,0);
f0103239:	b8 68 39 10 f0       	mov    $0xf0103968,%eax
f010323e:	66 a3 00 00 1d f0    	mov    %ax,0xf01d0000
f0103244:	66 c7 05 02 00 1d f0 	movw   $0x8,0xf01d0002
f010324b:	08 00 
f010324d:	c6 05 04 00 1d f0 00 	movb   $0x0,0xf01d0004
f0103254:	c6 05 05 00 1d f0 8e 	movb   $0x8e,0xf01d0005
f010325b:	c1 e8 10             	shr    $0x10,%eax
f010325e:	66 a3 06 00 1d f0    	mov    %ax,0xf01d0006
    SETGATE(idt[IRQ_OFFSET+5],0,GD_KT,&inthandler5,0);
f0103264:	b8 6e 39 10 f0       	mov    $0xf010396e,%eax
f0103269:	66 a3 08 00 1d f0    	mov    %ax,0xf01d0008
f010326f:	66 c7 05 0a 00 1d f0 	movw   $0x8,0xf01d000a
f0103276:	08 00 
f0103278:	c6 05 0c 00 1d f0 00 	movb   $0x0,0xf01d000c
f010327f:	c6 05 0d 00 1d f0 8e 	movb   $0x8e,0xf01d000d
f0103286:	c1 e8 10             	shr    $0x10,%eax
f0103289:	66 a3 0e 00 1d f0    	mov    %ax,0xf01d000e
    SETGATE(idt[IRQ_OFFSET+6],0,GD_KT,&inthandler6,0);
f010328f:	b8 74 39 10 f0       	mov    $0xf0103974,%eax
f0103294:	66 a3 10 00 1d f0    	mov    %ax,0xf01d0010
f010329a:	66 c7 05 12 00 1d f0 	movw   $0x8,0xf01d0012
f01032a1:	08 00 
f01032a3:	c6 05 14 00 1d f0 00 	movb   $0x0,0xf01d0014
f01032aa:	c6 05 15 00 1d f0 8e 	movb   $0x8e,0xf01d0015
f01032b1:	c1 e8 10             	shr    $0x10,%eax
f01032b4:	66 a3 16 00 1d f0    	mov    %ax,0xf01d0016
    SETGATE(idt[IRQ_OFFSET+7],0,GD_KT,&inthandler7,0);
f01032ba:	b8 7a 39 10 f0       	mov    $0xf010397a,%eax
f01032bf:	66 a3 18 00 1d f0    	mov    %ax,0xf01d0018
f01032c5:	66 c7 05 1a 00 1d f0 	movw   $0x8,0xf01d001a
f01032cc:	08 00 
f01032ce:	c6 05 1c 00 1d f0 00 	movb   $0x0,0xf01d001c
f01032d5:	c6 05 1d 00 1d f0 8e 	movb   $0x8e,0xf01d001d
f01032dc:	c1 e8 10             	shr    $0x10,%eax
f01032df:	66 a3 1e 00 1d f0    	mov    %ax,0xf01d001e
    SETGATE(idt[IRQ_OFFSET+8],0,GD_KT,&inthandler8,0);
f01032e5:	b8 80 39 10 f0       	mov    $0xf0103980,%eax
f01032ea:	66 a3 20 00 1d f0    	mov    %ax,0xf01d0020
f01032f0:	66 c7 05 22 00 1d f0 	movw   $0x8,0xf01d0022
f01032f7:	08 00 
f01032f9:	c6 05 24 00 1d f0 00 	movb   $0x0,0xf01d0024
f0103300:	c6 05 25 00 1d f0 8e 	movb   $0x8e,0xf01d0025
f0103307:	c1 e8 10             	shr    $0x10,%eax
f010330a:	66 a3 26 00 1d f0    	mov    %ax,0xf01d0026
    SETGATE(idt[IRQ_OFFSET+9],0,GD_KT,&inthandler9,0);
f0103310:	b8 86 39 10 f0       	mov    $0xf0103986,%eax
f0103315:	66 a3 28 00 1d f0    	mov    %ax,0xf01d0028
f010331b:	66 c7 05 2a 00 1d f0 	movw   $0x8,0xf01d002a
f0103322:	08 00 
f0103324:	c6 05 2c 00 1d f0 00 	movb   $0x0,0xf01d002c
f010332b:	a0 2d 00 1d f0       	mov    0xf01d002d,%al
f0103330:	83 c8 0e             	or     $0xe,%eax
f0103333:	83 e0 ee             	and    $0xffffffee,%eax
f0103336:	83 e0 9f             	and    $0xffffff9f,%eax
f0103339:	83 c8 80             	or     $0xffffff80,%eax
f010333c:	a2 2d 00 1d f0       	mov    %al,0xf01d002d
f0103341:	b8 86 39 10 f0       	mov    $0xf0103986,%eax
f0103346:	c1 e8 10             	shr    $0x10,%eax
f0103349:	66 a3 2e 00 1d f0    	mov    %ax,0xf01d002e
    SETGATE(idt[IRQ_OFFSET+10],0,GD_KT,&inthandler10,0);
f010334f:	b8 8c 39 10 f0       	mov    $0xf010398c,%eax
f0103354:	66 a3 30 00 1d f0    	mov    %ax,0xf01d0030
f010335a:	66 c7 05 32 00 1d f0 	movw   $0x8,0xf01d0032
f0103361:	08 00 
f0103363:	c6 05 34 00 1d f0 00 	movb   $0x0,0xf01d0034
f010336a:	c6 05 35 00 1d f0 8e 	movb   $0x8e,0xf01d0035
f0103371:	c1 e8 10             	shr    $0x10,%eax
f0103374:	66 a3 36 00 1d f0    	mov    %ax,0xf01d0036
    SETGATE(idt[IRQ_OFFSET+11],0,GD_KT,&inthandler11,0);
f010337a:	b8 92 39 10 f0       	mov    $0xf0103992,%eax
f010337f:	66 a3 38 00 1d f0    	mov    %ax,0xf01d0038
f0103385:	66 c7 05 3a 00 1d f0 	movw   $0x8,0xf01d003a
f010338c:	08 00 
f010338e:	c6 05 3c 00 1d f0 00 	movb   $0x0,0xf01d003c
f0103395:	c6 05 3d 00 1d f0 8e 	movb   $0x8e,0xf01d003d
f010339c:	c1 e8 10             	shr    $0x10,%eax
f010339f:	66 a3 3e 00 1d f0    	mov    %ax,0xf01d003e
    SETGATE(idt[IRQ_OFFSET+12],0,GD_KT,&inthandler12,0);
f01033a5:	b8 98 39 10 f0       	mov    $0xf0103998,%eax
f01033aa:	66 a3 40 00 1d f0    	mov    %ax,0xf01d0040
f01033b0:	66 c7 05 42 00 1d f0 	movw   $0x8,0xf01d0042
f01033b7:	08 00 
f01033b9:	c6 05 44 00 1d f0 00 	movb   $0x0,0xf01d0044
f01033c0:	c6 05 45 00 1d f0 8e 	movb   $0x8e,0xf01d0045
f01033c7:	c1 e8 10             	shr    $0x10,%eax
f01033ca:	66 a3 46 00 1d f0    	mov    %ax,0xf01d0046
    SETGATE(idt[IRQ_OFFSET+13],0,GD_KT,&inthandler13,0);
f01033d0:	b8 9e 39 10 f0       	mov    $0xf010399e,%eax
f01033d5:	66 a3 48 00 1d f0    	mov    %ax,0xf01d0048
f01033db:	66 c7 05 4a 00 1d f0 	movw   $0x8,0xf01d004a
f01033e2:	08 00 
f01033e4:	c6 05 4c 00 1d f0 00 	movb   $0x0,0xf01d004c
f01033eb:	c6 05 4d 00 1d f0 8e 	movb   $0x8e,0xf01d004d
f01033f2:	c1 e8 10             	shr    $0x10,%eax
f01033f5:	66 a3 4e 00 1d f0    	mov    %ax,0xf01d004e
    SETGATE(idt[IRQ_OFFSET+14],0,GD_KT,&inthandler14,0);
f01033fb:	b8 a4 39 10 f0       	mov    $0xf01039a4,%eax
f0103400:	66 a3 50 00 1d f0    	mov    %ax,0xf01d0050
f0103406:	66 c7 05 52 00 1d f0 	movw   $0x8,0xf01d0052
f010340d:	08 00 
f010340f:	c6 05 54 00 1d f0 00 	movb   $0x0,0xf01d0054
f0103416:	c6 05 55 00 1d f0 8e 	movb   $0x8e,0xf01d0055
f010341d:	c1 e8 10             	shr    $0x10,%eax
f0103420:	66 a3 56 00 1d f0    	mov    %ax,0xf01d0056
    SETGATE(idt[IRQ_OFFSET+15],0,GD_KT,&inthandler15,0);
f0103426:	b8 aa 39 10 f0       	mov    $0xf01039aa,%eax
f010342b:	66 a3 58 00 1d f0    	mov    %ax,0xf01d0058
f0103431:	66 c7 05 5a 00 1d f0 	movw   $0x8,0xf01d005a
f0103438:	08 00 
f010343a:	c6 05 5c 00 1d f0 00 	movb   $0x0,0xf01d005c
f0103441:	c6 05 5d 00 1d f0 8e 	movb   $0x8e,0xf01d005d
f0103448:	c1 e8 10             	shr    $0x10,%eax
f010344b:	66 a3 5e 00 1d f0    	mov    %ax,0xf01d005e
    // Setup a TSS so that we get the right stack
    // when we trap to the kernel.


    ts.ts_esp0 = KSTACKTOP;
f0103451:	c7 05 e4 06 1d f0 00 	movl   $0xefc00000,0xf01d06e4
f0103458:	00 c0 ef 
    ts.ts_ss0 = GD_KD;
f010345b:	66 c7 05 e8 06 1d f0 	movw   $0x10,0xf01d06e8
f0103462:	10 00 

    // Initialize the TSS field of the gdt.
    gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103464:	66 b8 68 00          	mov    $0x68,%ax
f0103468:	bb e0 06 1d f0       	mov    $0xf01d06e0,%ebx
f010346d:	89 d9                	mov    %ebx,%ecx
f010346f:	c1 e1 10             	shl    $0x10,%ecx
f0103472:	25 ff ff 00 00       	and    $0xffff,%eax
f0103477:	09 c8                	or     %ecx,%eax
f0103479:	89 d9                	mov    %ebx,%ecx
f010347b:	c1 e9 10             	shr    $0x10,%ecx
f010347e:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f0103484:	88 ca                	mov    %cl,%dl
f0103486:	80 e6 f0             	and    $0xf0,%dh
f0103489:	80 ce 09             	or     $0x9,%dh
f010348c:	80 ce 10             	or     $0x10,%dh
f010348f:	80 e6 9f             	and    $0x9f,%dh
f0103492:	80 ce 80             	or     $0x80,%dh
f0103495:	81 e2 ff ff f0 ff    	and    $0xfff0ffff,%edx
f010349b:	81 e2 ff ff ef ff    	and    $0xffefffff,%edx
f01034a1:	81 e2 ff ff df ff    	and    $0xffdfffff,%edx
f01034a7:	81 ca 00 00 40 00    	or     $0x400000,%edx
f01034ad:	81 e2 ff ff 7f ff    	and    $0xff7fffff,%edx
f01034b3:	81 e3 00 00 00 ff    	and    $0xff000000,%ebx
f01034b9:	81 e2 ff ff ff 00    	and    $0xffffff,%edx
f01034bf:	09 da                	or     %ebx,%edx
f01034c1:	a3 a8 d5 11 f0       	mov    %eax,0xf011d5a8
f01034c6:	89 15 ac d5 11 f0    	mov    %edx,0xf011d5ac
                             sizeof(struct Taskstate), 0);
    gdt[GD_TSS >> 3].sd_s = 0;
f01034cc:	80 25 ad d5 11 f0 ef 	andb   $0xef,0xf011d5ad
}

static __inline void
ltr(uint16_t sel)
{
f01034d3:	b8 28 00 00 00       	mov    $0x28,%eax
	__asm __volatile("ltr %0" : : "r" (sel));
f01034d8:	0f 00 d8             	ltr    %ax

    // Load the TSS
    ltr(GD_TSS);

    // Load the IDT
    asm volatile("lidt idt_pd");
f01034db:	0f 01 1d bc d5 11 f0 	lidtl  0xf011d5bc
}
f01034e2:	5b                   	pop    %ebx
f01034e3:	c9                   	leave  
f01034e4:	c3                   	ret    

f01034e5 <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f01034e5:	55                   	push   %ebp
f01034e6:	89 e5                	mov    %esp,%ebp
f01034e8:	53                   	push   %ebx
f01034e9:	83 ec 0c             	sub    $0xc,%esp
f01034ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
    cprintf("TRAP frame at %p\n", tf);
f01034ef:	53                   	push   %ebx
f01034f0:	68 4f 5e 10 f0       	push   $0xf0105e4f
f01034f5:	e8 78 f8 ff ff       	call   f0102d72 <cprintf>
    print_regs(&tf->tf_regs);
f01034fa:	89 1c 24             	mov    %ebx,(%esp)
f01034fd:	e8 a9 00 00 00       	call   f01035ab <print_regs>
    cprintf("  es   0x----%04x\n", tf->tf_es);
f0103502:	83 c4 08             	add    $0x8,%esp
f0103505:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103509:	50                   	push   %eax
f010350a:	68 61 5e 10 f0       	push   $0xf0105e61
f010350f:	e8 5e f8 ff ff       	call   f0102d72 <cprintf>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103514:	83 c4 08             	add    $0x8,%esp
f0103517:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010351b:	50                   	push   %eax
f010351c:	68 74 5e 10 f0       	push   $0xf0105e74
f0103521:	e8 4c f8 ff ff       	call   f0102d72 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103526:	83 c4 04             	add    $0x4,%esp
f0103529:	ff 73 28             	pushl  0x28(%ebx)
f010352c:	e8 57 f8 ff ff       	call   f0102d88 <trapname>
f0103531:	83 c4 0c             	add    $0xc,%esp
f0103534:	50                   	push   %eax
f0103535:	ff 73 28             	pushl  0x28(%ebx)
f0103538:	68 87 5e 10 f0       	push   $0xf0105e87
f010353d:	e8 30 f8 ff ff       	call   f0102d72 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
f0103542:	83 c4 08             	add    $0x8,%esp
f0103545:	ff 73 2c             	pushl  0x2c(%ebx)
f0103548:	68 99 5e 10 f0       	push   $0xf0105e99
f010354d:	e8 20 f8 ff ff       	call   f0102d72 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103552:	83 c4 08             	add    $0x8,%esp
f0103555:	ff 73 30             	pushl  0x30(%ebx)
f0103558:	68 a8 5e 10 f0       	push   $0xf0105ea8
f010355d:	e8 10 f8 ff ff       	call   f0102d72 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103562:	83 c4 08             	add    $0x8,%esp
f0103565:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103569:	50                   	push   %eax
f010356a:	68 b7 5e 10 f0       	push   $0xf0105eb7
f010356f:	e8 fe f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103574:	83 c4 08             	add    $0x8,%esp
f0103577:	ff 73 38             	pushl  0x38(%ebx)
f010357a:	68 ca 5e 10 f0       	push   $0xf0105eca
f010357f:	e8 ee f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103584:	83 c4 08             	add    $0x8,%esp
f0103587:	ff 73 3c             	pushl  0x3c(%ebx)
f010358a:	68 d9 5e 10 f0       	push   $0xf0105ed9
f010358f:	e8 de f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103594:	83 c4 08             	add    $0x8,%esp
f0103597:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010359b:	50                   	push   %eax
f010359c:	68 e8 5e 10 f0       	push   $0xf0105ee8
f01035a1:	e8 cc f7 ff ff       	call   f0102d72 <cprintf>
}
f01035a6:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01035a9:	c9                   	leave  
f01035aa:	c3                   	ret    

f01035ab <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f01035ab:	55                   	push   %ebp
f01035ac:	89 e5                	mov    %esp,%ebp
f01035ae:	53                   	push   %ebx
f01035af:	83 ec 0c             	sub    $0xc,%esp
f01035b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
    cprintf("  edi  0x%08x\n", regs->reg_edi);
f01035b5:	ff 33                	pushl  (%ebx)
f01035b7:	68 fb 5e 10 f0       	push   $0xf0105efb
f01035bc:	e8 b1 f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
f01035c1:	83 c4 08             	add    $0x8,%esp
f01035c4:	ff 73 04             	pushl  0x4(%ebx)
f01035c7:	68 0a 5f 10 f0       	push   $0xf0105f0a
f01035cc:	e8 a1 f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01035d1:	83 c4 08             	add    $0x8,%esp
f01035d4:	ff 73 08             	pushl  0x8(%ebx)
f01035d7:	68 19 5f 10 f0       	push   $0xf0105f19
f01035dc:	e8 91 f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01035e1:	83 c4 08             	add    $0x8,%esp
f01035e4:	ff 73 0c             	pushl  0xc(%ebx)
f01035e7:	68 28 5f 10 f0       	push   $0xf0105f28
f01035ec:	e8 81 f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01035f1:	83 c4 08             	add    $0x8,%esp
f01035f4:	ff 73 10             	pushl  0x10(%ebx)
f01035f7:	68 37 5f 10 f0       	push   $0xf0105f37
f01035fc:	e8 71 f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103601:	83 c4 08             	add    $0x8,%esp
f0103604:	ff 73 14             	pushl  0x14(%ebx)
f0103607:	68 46 5f 10 f0       	push   $0xf0105f46
f010360c:	e8 61 f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103611:	83 c4 08             	add    $0x8,%esp
f0103614:	ff 73 18             	pushl  0x18(%ebx)
f0103617:	68 55 5f 10 f0       	push   $0xf0105f55
f010361c:	e8 51 f7 ff ff       	call   f0102d72 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103621:	83 c4 08             	add    $0x8,%esp
f0103624:	ff 73 1c             	pushl  0x1c(%ebx)
f0103627:	68 64 5f 10 f0       	push   $0xf0105f64
f010362c:	e8 41 f7 ff ff       	call   f0102d72 <cprintf>
}
f0103631:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0103634:	c9                   	leave  
f0103635:	c3                   	ret    

f0103636 <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f0103636:	55                   	push   %ebp
f0103637:	89 e5                	mov    %esp,%ebp
f0103639:	53                   	push   %ebx
f010363a:	83 ec 04             	sub    $0x4,%esp
f010363d:	8b 5d 08             	mov    0x8(%ebp),%ebx
    // Handle processor exceptions.
    // LAB 3: Your code here.
    /*if(tf->tf_trapno != 0x20) {
        print_trapframe(tf);
    }*/
    switch (tf->tf_trapno) {
f0103640:	8b 43 28             	mov    0x28(%ebx),%eax
f0103643:	83 f8 03             	cmp    $0x3,%eax
f0103646:	74 26                	je     f010366e <trap_dispatch+0x38>
f0103648:	83 f8 03             	cmp    $0x3,%eax
f010364b:	77 07                	ja     f0103654 <trap_dispatch+0x1e>
f010364d:	83 f8 01             	cmp    $0x1,%eax
f0103650:	74 1c                	je     f010366e <trap_dispatch+0x38>
f0103652:	eb 43                	jmp    f0103697 <trap_dispatch+0x61>
f0103654:	83 f8 0e             	cmp    $0xe,%eax
f0103657:	74 07                	je     f0103660 <trap_dispatch+0x2a>
f0103659:	83 f8 30             	cmp    $0x30,%eax
f010365c:	74 1b                	je     f0103679 <trap_dispatch+0x43>
f010365e:	eb 37                	jmp    f0103697 <trap_dispatch+0x61>
    case T_PGFLT:
        page_fault_handler(tf);
f0103660:	83 ec 0c             	sub    $0xc,%esp
f0103663:	53                   	push   %ebx
f0103664:	e8 0b 01 00 00       	call   f0103774 <page_fault_handler>
        return;
f0103669:	e9 89 00 00 00       	jmp    f01036f7 <trap_dispatch+0xc1>
    case T_BRKPT:
    case T_DEBUG:
        //cprintf("BRKPT here\n");
        monitor(tf);
f010366e:	83 ec 0c             	sub    $0xc,%esp
f0103671:	53                   	push   %ebx
f0103672:	e8 8c d2 ff ff       	call   f0100903 <monitor>
        return;
f0103677:	eb 7e                	jmp    f01036f7 <trap_dispatch+0xc1>
    case T_SYSCALL:
        tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f0103679:	83 ec 08             	sub    $0x8,%esp
f010367c:	ff 73 04             	pushl  0x4(%ebx)
f010367f:	ff 33                	pushl  (%ebx)
f0103681:	ff 73 10             	pushl  0x10(%ebx)
f0103684:	ff 73 18             	pushl  0x18(%ebx)
f0103687:	ff 73 14             	pushl  0x14(%ebx)
f010368a:	ff 73 1c             	pushl  0x1c(%ebx)
f010368d:	e8 da 0a 00 00       	call   f010416c <syscall>
f0103692:	89 43 1c             	mov    %eax,0x1c(%ebx)
                                      tf->tf_regs.reg_edx,
                                      tf->tf_regs.reg_ecx,
                                      tf->tf_regs.reg_ebx,
                                      tf->tf_regs.reg_edi,
                                      tf->tf_regs.reg_esi);
        return;
f0103695:	eb 60                	jmp    f01036f7 <trap_dispatch+0xc1>
    default:
        break;
    }
    // Handle clock interrupts.
    // LAB 4: Your code here.
    if(tf->tf_trapno == IRQ_OFFSET) {
f0103697:	83 7b 28 20          	cmpl   $0x20,0x28(%ebx)
f010369b:	75 05                	jne    f01036a2 <trap_dispatch+0x6c>
        sched_yield();
f010369d:	e8 4e 03 00 00       	call   f01039f0 <sched_yield>
    }
    // Handle spurious interupts
    // The hardware sometimes raises these because of noise on the
    // IRQ line or other reasons. We don't care.
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01036a2:	83 7b 28 27          	cmpl   $0x27,0x28(%ebx)
f01036a6:	75 17                	jne    f01036bf <trap_dispatch+0x89>
        cprintf("Spurious interrupt on irq 7\n");
f01036a8:	83 ec 0c             	sub    $0xc,%esp
f01036ab:	68 73 5f 10 f0       	push   $0xf0105f73
f01036b0:	e8 bd f6 ff ff       	call   f0102d72 <cprintf>
        print_trapframe(tf);
f01036b5:	89 1c 24             	mov    %ebx,(%esp)
f01036b8:	e8 28 fe ff ff       	call   f01034e5 <print_trapframe>
        return;
f01036bd:	eb 38                	jmp    f01036f7 <trap_dispatch+0xc1>
    }


    // Unexpected trap: The user process or the kernel has a bug.
    print_trapframe(tf);
f01036bf:	83 ec 0c             	sub    $0xc,%esp
f01036c2:	53                   	push   %ebx
f01036c3:	e8 1d fe ff ff       	call   f01034e5 <print_trapframe>
    if (tf->tf_cs == GD_KT)
f01036c8:	83 c4 10             	add    $0x10,%esp
f01036cb:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01036d0:	75 17                	jne    f01036e9 <trap_dispatch+0xb3>
        panic("unhandled trap in kernel");
f01036d2:	83 ec 04             	sub    $0x4,%esp
f01036d5:	68 90 5f 10 f0       	push   $0xf0105f90
f01036da:	68 ed 00 00 00       	push   $0xed
f01036df:	68 a9 5f 10 f0       	push   $0xf0105fa9
f01036e4:	e8 fb c9 ff ff       	call   f01000e4 <_panic>
    else {
        env_destroy(curenv);
f01036e9:	83 ec 0c             	sub    $0xc,%esp
f01036ec:	ff 35 c4 fe 1c f0    	pushl  0xf01cfec4
f01036f2:	e8 eb f3 ff ff       	call   f0102ae2 <env_destroy>
        return;
    }
}
f01036f7:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01036fa:	c9                   	leave  
f01036fb:	c3                   	ret    

f01036fc <trap>:

void
trap(struct Trapframe *tf)
{
f01036fc:	55                   	push   %ebp
f01036fd:	89 e5                	mov    %esp,%ebp
f01036ff:	57                   	push   %edi
f0103700:	56                   	push   %esi
f0103701:	8b 75 08             	mov    0x8(%ebp),%esi
    if ((tf->tf_cs & 3) == 3) {
f0103704:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103708:	83 e0 03             	and    $0x3,%eax
f010370b:	83 f8 03             	cmp    $0x3,%eax
f010370e:	75 36                	jne    f0103746 <trap+0x4a>
        // Trapped from user mode.
        // Copy trap frame (which is currently on the stack)
        // into 'curenv->env_tf', so that running the environment
        // will restart at the trap point.
        assert(curenv);
f0103710:	83 3d c4 fe 1c f0 00 	cmpl   $0x0,0xf01cfec4
f0103717:	75 19                	jne    f0103732 <trap+0x36>
f0103719:	68 b5 5f 10 f0       	push   $0xf0105fb5
f010371e:	68 74 5a 10 f0       	push   $0xf0105a74
f0103723:	68 fc 00 00 00       	push   $0xfc
f0103728:	68 a9 5f 10 f0       	push   $0xf0105fa9
f010372d:	e8 b2 c9 ff ff       	call   f01000e4 <_panic>
        curenv->env_tf = *tf;
f0103732:	8b 3d c4 fe 1c f0    	mov    0xf01cfec4,%edi
f0103738:	fc                   	cld    
f0103739:	b9 11 00 00 00       	mov    $0x11,%ecx
f010373e:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
        // The trapframe on the stack should be ignored from here on.
        tf = &curenv->env_tf;
f0103740:	8b 35 c4 fe 1c f0    	mov    0xf01cfec4,%esi
    }

    // Dispatch based on what type of trap occurred
    //cprintf("in trap_dispatch:callno:%d,trapno:%d\n",tf->tf_regs.reg_eax,tf->tf_trapno);
    trap_dispatch(tf);
f0103746:	83 ec 0c             	sub    $0xc,%esp
f0103749:	56                   	push   %esi
f010374a:	e8 e7 fe ff ff       	call   f0103636 <trap_dispatch>
    
    // If we made it to this point, then no other environment was
    // scheduled, so we should return to the current environment
    // if doing so makes sense.
    if (curenv && curenv->env_status == ENV_RUNNABLE)
f010374f:	83 c4 10             	add    $0x10,%esp
f0103752:	83 3d c4 fe 1c f0 00 	cmpl   $0x0,0xf01cfec4
f0103759:	74 14                	je     f010376f <trap+0x73>
f010375b:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103760:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103764:	75 09                	jne    f010376f <trap+0x73>
        env_run(curenv);
f0103766:	83 ec 0c             	sub    $0xc,%esp
f0103769:	50                   	push   %eax
f010376a:	e8 f8 f3 ff ff       	call   f0102b67 <env_run>
    else
        sched_yield();
f010376f:	e8 7c 02 00 00       	call   f01039f0 <sched_yield>

f0103774 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103774:	55                   	push   %ebp
f0103775:	89 e5                	mov    %esp,%ebp
f0103777:	57                   	push   %edi
f0103778:	56                   	push   %esi
f0103779:	53                   	push   %ebx
f010377a:	83 ec 4c             	sub    $0x4c,%esp
f010377d:	8b 5d 08             	mov    0x8(%ebp),%ebx
}

static __inline uint32_t
rcr2(void)
{
f0103780:	0f 20 d7             	mov    %cr2,%edi
    uint32_t fault_va;

    // Read processor's CR2 register to find the faulting address
    fault_va = rcr2();

    // Handle kernel-mode page faults.

    // LAB 3: Your code here.
    if ((tf->tf_cs & 3)!= 3) {//means that the cs is GD_KT
f0103783:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103787:	83 e0 03             	and    $0x3,%eax
f010378a:	83 f8 03             	cmp    $0x3,%eax
f010378d:	74 1b                	je     f01037aa <page_fault_handler+0x36>
        panic("err of page_fault_handler: page fault in the kernel mode.\n the vitual address is %x,eip is %x\n",fault_va,tf->tf_eip);
f010378f:	83 ec 0c             	sub    $0xc,%esp
f0103792:	ff 73 30             	pushl  0x30(%ebx)
f0103795:	57                   	push   %edi
f0103796:	68 10 60 10 f0       	push   $0xf0106010
f010379b:	68 1c 01 00 00       	push   $0x11c
f01037a0:	68 a9 5f 10 f0       	push   $0xf0105fa9
f01037a5:	e8 3a c9 ff ff       	call   f01000e4 <_panic>
    }
    // We've already handled kernel-mode exceptions, so if we get here,
    // the page fault happened in user mode.

    // Call the environment's page fault upcall, if one exists.  Set up a
    // page fault stack frame on the user exception stack (below
    // UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
    //
    // The page fault upcall might cause another page fault, in which case
    // we branch to the page fault upcall recursively, pushing another
    // page fault stack frame on top of the user exception stack.
    //
    // The trap handler needs one word of scratch space at the top of the
    // trap-time stack in order to return.  In the non-recursive case, we
    // don't have to worry about this because the top of the regular user
    // stack is free.  In the recursive case, this means we have to leave
    // an extra word between the current top of the exception stack and
    // the new stack frame because the exception stack _is_ the trap-time
    // stack.
    //
    // If there's no page fault upcall, the environment didn't allocate a
    // page for its exception stack, or the exception stack overflows,
    // then destroy the environment that caused the fault.
    //
    // Hints:
    //   user_mem_assert() and env_run() are useful here.
    //   To change what the user environment runs, modify 'curenv->env_tf'
    //   (the 'tf' variable points at 'curenv->env_tf').

    // LAB 4: Your code here.
    struct UTrapframe uf;
    uint32_t utfa;
    uint32_t retespaddr;
    //cprintf("start page_fault_handler fault va:%x\n",fault_va);
    if (curenv->env_pgfault_upcall) {
f01037aa:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f01037af:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f01037b3:	0f 84 b5 00 00 00    	je     f010386e <page_fault_handler+0xfa>
        //cprintf("before check upcall,upcall:%x\n",curenv->env_pgfault_upcall);
        user_mem_assert(curenv,(void*)curenv->env_pgfault_upcall,sizeof(int),PTE_P|PTE_U);
f01037b9:	6a 05                	push   $0x5
f01037bb:	6a 04                	push   $0x4
f01037bd:	ff 70 68             	pushl  0x68(%eax)
f01037c0:	50                   	push   %eax
f01037c1:	e8 10 e1 ff ff       	call   f01018d6 <user_mem_assert>
        //cprintf("before check stack %d\n",(void *)UXSTACKTOP-PGSIZE);
        user_mem_assert(curenv,(void *)UXSTACKTOP-PGSIZE,PGSIZE,PTE_P|PTE_U|PTE_W);
f01037c6:	6a 07                	push   $0x7
f01037c8:	68 00 10 00 00       	push   $0x1000
f01037cd:	68 00 f0 bf ee       	push   $0xeebff000
f01037d2:	ff 35 c4 fe 1c f0    	pushl  0xf01cfec4
f01037d8:	e8 f9 e0 ff ff       	call   f01018d6 <user_mem_assert>
        //cprintf("after check stack\n");
        memset(&uf,0,sizeof(struct UTrapframe));
f01037dd:	83 c4 1c             	add    $0x1c,%esp
f01037e0:	6a 34                	push   $0x34
f01037e2:	6a 00                	push   $0x0
f01037e4:	8d 45 a8             	lea    0xffffffa8(%ebp),%eax
f01037e7:	50                   	push   %eax
f01037e8:	e8 46 15 00 00       	call   f0104d33 <memset>
        /*set the values in the utrapframe*/
        uf.utf_fault_va = fault_va;
f01037ed:	89 7d a8             	mov    %edi,0xffffffa8(%ebp)
        //cprintf("trap.c the fault va is %x\n",fault_va);
        uf.utf_err = tf->tf_err;//PGFUALT
f01037f0:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01037f3:	89 45 ac             	mov    %eax,0xffffffac(%ebp)
        //cprintf("trap.c the fault err is %d\n",T_PGFLT & 7);
        uf.utf_eip = tf->tf_eip;
f01037f6:	8b 43 30             	mov    0x30(%ebx),%eax
f01037f9:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
        uf.utf_regs = tf->tf_regs;
f01037fc:	8d 7d b0             	lea    0xffffffb0(%ebp),%edi
f01037ff:	fc                   	cld    
f0103800:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103805:	89 de                	mov    %ebx,%esi
f0103807:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
        uf.utf_eflags = tf->tf_eflags;
f0103809:	8b 43 38             	mov    0x38(%ebx),%eax
f010380c:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
        uf.utf_esp = tf->tf_esp;
f010380f:	8b 53 3c             	mov    0x3c(%ebx),%edx
f0103812:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
        //cprintf("after set the registers in trap.c/page_fault_handler\n");
        /*set the values in the utrapframe*/
        if (uf.utf_esp < UXSTACKTOP && uf.utf_esp >= UXSTACKTOP-PGSIZE) {
f0103815:	8d 82 00 10 40 11    	lea    0x11401000(%edx),%eax
f010381b:	83 c4 10             	add    $0x10,%esp
            //cprintf("it's caused recursively \n");
            /*if the esp is in the uxstack*/
            retespaddr = tf->tf_esp - 4;
            utfa = retespaddr - sizeof(struct UTrapframe);//uf.utf_esp
        } else {
            /*if the page fault is caused in user state*/
            /*alloc stack*/
            //cprintf("it's caused first times\n");
            //syscall(SYS_page_alloc,curenv->env_id,(UXSTACKTOP-PGSIZE),PTE_USER,0,0);
            //cprintf("after alloc the page for the stack\n");
            /*clear it*/
            //memset((void*)(UXSTACKTOP-PGSIZE),0,PGSIZE);//may be needn't
            //cprintf("after clean the stack\n");
            retespaddr = UXSTACKTOP - 4;
            utfa = retespaddr -sizeof(struct UTrapframe);//uf.utf_esp
f010381e:	be c8 ff bf ee       	mov    $0xeebfffc8,%esi
f0103823:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0103828:	77 03                	ja     f010382d <page_fault_handler+0xb9>
f010382a:	8d 72 c8             	lea    0xffffffc8(%edx),%esi
        }
        //cprintf("before check utf\n");
        user_mem_assert(curenv,(void*)utfa,sizeof(struct UTrapframe),PTE_P|PTE_U|PTE_W);
f010382d:	6a 07                	push   $0x7
f010382f:	6a 34                	push   $0x34
f0103831:	56                   	push   %esi
f0103832:	ff 35 c4 fe 1c f0    	pushl  0xf01cfec4
f0103838:	e8 99 e0 ff ff       	call   f01018d6 <user_mem_assert>
       // cprintf("after mem assert\n");
        /*set the return eip*/
        //*(uint32_t *)retespaddr = tf->tf_eip;
        memcpy((void *)utfa,&uf,sizeof(struct UTrapframe));
f010383d:	83 c4 0c             	add    $0xc,%esp
f0103840:	6a 34                	push   $0x34
f0103842:	8d 45 a8             	lea    0xffffffa8(%ebp),%eax
f0103845:	50                   	push   %eax
f0103846:	56                   	push   %esi
f0103847:	e8 a7 15 00 00       	call   f0104df3 <memcpy>
        curenv->env_tf.tf_esp = utfa;
f010384c:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103851:	89 70 3c             	mov    %esi,0x3c(%eax)
        curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0103854:	8b 15 c4 fe 1c f0    	mov    0xf01cfec4,%edx
f010385a:	8b 42 68             	mov    0x68(%edx),%eax
f010385d:	89 42 30             	mov    %eax,0x30(%edx)
        /*after set the values, return to the curenv*/
        //cprintf("return to the curenv\n");
        /*may be wrong,depend on how does the pgfault_upcall deal pgfault*/
        env_run(curenv);
f0103860:	83 c4 04             	add    $0x4,%esp
f0103863:	ff 35 c4 fe 1c f0    	pushl  0xf01cfec4
f0103869:	e8 f9 f2 ff ff       	call   f0102b67 <env_run>

    }
    //cprintf("the curenv doesn't have env_pgfault_upcall\n");
    // Destroy the environment that caused the fault.
    cprintf("[%08x] user fault va %08x ip %08x\n",
f010386e:	ff 73 30             	pushl  0x30(%ebx)
f0103871:	57                   	push   %edi
f0103872:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103877:	ff 70 4c             	pushl  0x4c(%eax)
f010387a:	68 70 60 10 f0       	push   $0xf0106070
f010387f:	e8 ee f4 ff ff       	call   f0102d72 <cprintf>
            curenv->env_id, fault_va, tf->tf_eip);
    print_trapframe(tf);
f0103884:	89 1c 24             	mov    %ebx,(%esp)
f0103887:	e8 59 fc ff ff       	call   f01034e5 <print_trapframe>
    env_destroy(curenv);
f010388c:	83 c4 04             	add    $0x4,%esp
f010388f:	ff 35 c4 fe 1c f0    	pushl  0xf01cfec4
f0103895:	e8 48 f2 ff ff       	call   f0102ae2 <env_destroy>
}
f010389a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010389d:	5b                   	pop    %ebx
f010389e:	5e                   	pop    %esi
f010389f:	5f                   	pop    %edi
f01038a0:	c9                   	leave  
f01038a1:	c3                   	ret    
	...

f01038a4 <handler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0 ,T_DIVIDE);
f01038a4:	6a 00                	push   $0x0
f01038a6:	6a 00                	push   $0x0
f01038a8:	e9 03 01 00 00       	jmp    f01039b0 <_alltraps>
f01038ad:	90                   	nop    

f01038ae <handler1>:
TRAPHANDLER_NOEC(handler1 ,T_DEBUG);
f01038ae:	6a 00                	push   $0x0
f01038b0:	6a 01                	push   $0x1
f01038b2:	e9 f9 00 00 00       	jmp    f01039b0 <_alltraps>
f01038b7:	90                   	nop    

f01038b8 <handler2>:
TRAPHANDLER_NOEC(handler2 ,T_NMI);
f01038b8:	6a 00                	push   $0x0
f01038ba:	6a 02                	push   $0x2
f01038bc:	e9 ef 00 00 00       	jmp    f01039b0 <_alltraps>
f01038c1:	90                   	nop    

f01038c2 <handler3>:
TRAPHANDLER_NOEC(handler3 ,T_BRKPT);
f01038c2:	6a 00                	push   $0x0
f01038c4:	6a 03                	push   $0x3
f01038c6:	e9 e5 00 00 00       	jmp    f01039b0 <_alltraps>
f01038cb:	90                   	nop    

f01038cc <handler4>:
TRAPHANDLER_NOEC(handler4 ,T_OFLOW);
f01038cc:	6a 00                	push   $0x0
f01038ce:	6a 04                	push   $0x4
f01038d0:	e9 db 00 00 00       	jmp    f01039b0 <_alltraps>
f01038d5:	90                   	nop    

f01038d6 <handler5>:
TRAPHANDLER_NOEC(handler5 ,T_BOUND);
f01038d6:	6a 00                	push   $0x0
f01038d8:	6a 05                	push   $0x5
f01038da:	e9 d1 00 00 00       	jmp    f01039b0 <_alltraps>
f01038df:	90                   	nop    

f01038e0 <handler6>:
TRAPHANDLER_NOEC(handler6 ,T_ILLOP);
f01038e0:	6a 00                	push   $0x0
f01038e2:	6a 06                	push   $0x6
f01038e4:	e9 c7 00 00 00       	jmp    f01039b0 <_alltraps>
f01038e9:	90                   	nop    

f01038ea <handler7>:
TRAPHANDLER_NOEC(handler7 ,T_DEVICE);
f01038ea:	6a 00                	push   $0x0
f01038ec:	6a 07                	push   $0x7
f01038ee:	e9 bd 00 00 00       	jmp    f01039b0 <_alltraps>
f01038f3:	90                   	nop    

f01038f4 <handler8>:
TRAPHANDLER(handler8,T_DBLFLT);	
f01038f4:	6a 08                	push   $0x8
f01038f6:	e9 b5 00 00 00       	jmp    f01039b0 <_alltraps>
f01038fb:	90                   	nop    

f01038fc <handler9>:
TRAPHANDLER_NOEC(handler9 ,9);//maybe this won't be used
f01038fc:	6a 00                	push   $0x0
f01038fe:	6a 09                	push   $0x9
f0103900:	e9 ab 00 00 00       	jmp    f01039b0 <_alltraps>
f0103905:	90                   	nop    

f0103906 <handler10>:
TRAPHANDLER(handler10 ,T_TSS);
f0103906:	6a 0a                	push   $0xa
f0103908:	e9 a3 00 00 00       	jmp    f01039b0 <_alltraps>
f010390d:	90                   	nop    

f010390e <handler11>:
TRAPHANDLER(handler11 ,T_SEGNP);
f010390e:	6a 0b                	push   $0xb
f0103910:	e9 9b 00 00 00       	jmp    f01039b0 <_alltraps>
f0103915:	90                   	nop    

f0103916 <handler12>:
TRAPHANDLER(handler12 ,T_STACK);
f0103916:	6a 0c                	push   $0xc
f0103918:	e9 93 00 00 00       	jmp    f01039b0 <_alltraps>
f010391d:	90                   	nop    

f010391e <handler13>:
TRAPHANDLER(handler13 ,T_GPFLT);
f010391e:	6a 0d                	push   $0xd
f0103920:	e9 8b 00 00 00       	jmp    f01039b0 <_alltraps>
f0103925:	90                   	nop    

f0103926 <handler14>:
TRAPHANDLER(handler14 ,T_PGFLT);
f0103926:	6a 0e                	push   $0xe
f0103928:	e9 83 00 00 00       	jmp    f01039b0 <_alltraps>
f010392d:	90                   	nop    

f010392e <handler15>:
TRAPHANDLER(handler15, 15);
f010392e:	6a 0f                	push   $0xf
f0103930:	eb 7e                	jmp    f01039b0 <_alltraps>

f0103932 <handler16>:
TRAPHANDLER_NOEC(handler16 ,T_FPERR);
f0103932:	6a 00                	push   $0x0
f0103934:	6a 10                	push   $0x10
f0103936:	eb 78                	jmp    f01039b0 <_alltraps>

f0103938 <handler17>:
TRAPHANDLER_NOEC(handler17 ,T_ALIGN);
f0103938:	6a 00                	push   $0x0
f010393a:	6a 11                	push   $0x11
f010393c:	eb 72                	jmp    f01039b0 <_alltraps>

f010393e <handler18>:
TRAPHANDLER_NOEC(handler18 ,T_MCHK);
f010393e:	6a 00                	push   $0x0
f0103940:	6a 12                	push   $0x12
f0103942:	eb 6c                	jmp    f01039b0 <_alltraps>

f0103944 <handler19>:
TRAPHANDLER_NOEC(handler19 ,T_SIMDERR);
f0103944:	6a 00                	push   $0x0
f0103946:	6a 13                	push   $0x13
f0103948:	eb 66                	jmp    f01039b0 <_alltraps>

f010394a <handler48>:

TRAPHANDLER_NOEC(handler48 ,T_SYSCALL);
f010394a:	6a 00                	push   $0x0
f010394c:	6a 30                	push   $0x30
f010394e:	eb 60                	jmp    f01039b0 <_alltraps>

f0103950 <inthandler0>:

TRAPHANDLER_NOEC(inthandler0, IRQ_OFFSET)
f0103950:	6a 00                	push   $0x0
f0103952:	6a 20                	push   $0x20
f0103954:	eb 5a                	jmp    f01039b0 <_alltraps>

f0103956 <inthandler1>:
TRAPHANDLER_NOEC(inthandler1, IRQ_OFFSET+1)
f0103956:	6a 00                	push   $0x0
f0103958:	6a 21                	push   $0x21
f010395a:	eb 54                	jmp    f01039b0 <_alltraps>

f010395c <inthandler2>:
TRAPHANDLER_NOEC(inthandler2, IRQ_OFFSET+2)
f010395c:	6a 00                	push   $0x0
f010395e:	6a 22                	push   $0x22
f0103960:	eb 4e                	jmp    f01039b0 <_alltraps>

f0103962 <inthandler3>:
TRAPHANDLER_NOEC(inthandler3, IRQ_OFFSET+3)
f0103962:	6a 00                	push   $0x0
f0103964:	6a 23                	push   $0x23
f0103966:	eb 48                	jmp    f01039b0 <_alltraps>

f0103968 <inthandler4>:
TRAPHANDLER_NOEC(inthandler4, IRQ_OFFSET+4)
f0103968:	6a 00                	push   $0x0
f010396a:	6a 24                	push   $0x24
f010396c:	eb 42                	jmp    f01039b0 <_alltraps>

f010396e <inthandler5>:
TRAPHANDLER_NOEC(inthandler5, IRQ_OFFSET+5)
f010396e:	6a 00                	push   $0x0
f0103970:	6a 25                	push   $0x25
f0103972:	eb 3c                	jmp    f01039b0 <_alltraps>

f0103974 <inthandler6>:
TRAPHANDLER_NOEC(inthandler6, IRQ_OFFSET+6)
f0103974:	6a 00                	push   $0x0
f0103976:	6a 26                	push   $0x26
f0103978:	eb 36                	jmp    f01039b0 <_alltraps>

f010397a <inthandler7>:
TRAPHANDLER_NOEC(inthandler7, IRQ_OFFSET+7)
f010397a:	6a 00                	push   $0x0
f010397c:	6a 27                	push   $0x27
f010397e:	eb 30                	jmp    f01039b0 <_alltraps>

f0103980 <inthandler8>:
TRAPHANDLER_NOEC(inthandler8, IRQ_OFFSET+8)
f0103980:	6a 00                	push   $0x0
f0103982:	6a 28                	push   $0x28
f0103984:	eb 2a                	jmp    f01039b0 <_alltraps>

f0103986 <inthandler9>:
TRAPHANDLER_NOEC(inthandler9, IRQ_OFFSET+9)
f0103986:	6a 00                	push   $0x0
f0103988:	6a 29                	push   $0x29
f010398a:	eb 24                	jmp    f01039b0 <_alltraps>

f010398c <inthandler10>:
TRAPHANDLER_NOEC(inthandler10, IRQ_OFFSET+10)
f010398c:	6a 00                	push   $0x0
f010398e:	6a 2a                	push   $0x2a
f0103990:	eb 1e                	jmp    f01039b0 <_alltraps>

f0103992 <inthandler11>:
TRAPHANDLER_NOEC(inthandler11, IRQ_OFFSET+11)
f0103992:	6a 00                	push   $0x0
f0103994:	6a 2b                	push   $0x2b
f0103996:	eb 18                	jmp    f01039b0 <_alltraps>

f0103998 <inthandler12>:
TRAPHANDLER_NOEC(inthandler12, IRQ_OFFSET+12)
f0103998:	6a 00                	push   $0x0
f010399a:	6a 2c                	push   $0x2c
f010399c:	eb 12                	jmp    f01039b0 <_alltraps>

f010399e <inthandler13>:
TRAPHANDLER_NOEC(inthandler13, IRQ_OFFSET+13)
f010399e:	6a 00                	push   $0x0
f01039a0:	6a 2d                	push   $0x2d
f01039a2:	eb 0c                	jmp    f01039b0 <_alltraps>

f01039a4 <inthandler14>:
TRAPHANDLER_NOEC(inthandler14, IRQ_OFFSET+14)
f01039a4:	6a 00                	push   $0x0
f01039a6:	6a 2e                	push   $0x2e
f01039a8:	eb 06                	jmp    f01039b0 <_alltraps>

f01039aa <inthandler15>:
TRAPHANDLER_NOEC(inthandler15, IRQ_OFFSET+15)
f01039aa:	6a 00                	push   $0x0
f01039ac:	6a 2f                	push   $0x2f
f01039ae:	eb 00                	jmp    f01039b0 <_alltraps>

f01039b0 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds
f01039b0:	1e                   	push   %ds
    pushl %es
f01039b1:	06                   	push   %es
    pushal  //push all register
f01039b2:	60                   	pusha  

    movl $GD_KD, %eax
f01039b3:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %es
f01039b8:	8e c0                	mov    %eax,%es
    movw %ax, %ds
f01039ba:	8e d8                	mov    %eax,%ds

    pushl %esp
f01039bc:	54                   	push   %esp

    call trap
f01039bd:	e8 3a fd ff ff       	call   f01036fc <trap>
    popl %esp
f01039c2:	5c                   	pop    %esp
    popal
f01039c3:	61                   	popa   
    pop %es
f01039c4:	07                   	pop    %es
    pop %ds
f01039c5:	1f                   	pop    %ds
    addl $8, %esp
f01039c6:	83 c4 08             	add    $0x8,%esp
//xchg %bx, %bx
    iret
f01039c9:	cf                   	iret   

f01039ca <sysenterhandler>:

//define the function to handle syscall
.globl sysenterhandler;
.type sysenterhandler, @function;
sysenterhandler:
/*it uses kernel stack*/
    cli
f01039ca:	fa                   	cli    
    pushl %ebp//the return esp
f01039cb:	55                   	push   %ebp
    pushl %esi//the return eip
f01039cc:	56                   	push   %esi
    movl 4(%ebp),%esi
f01039cd:	8b 75 04             	mov    0x4(%ebp),%esi
    pushl %esi
f01039d0:	56                   	push   %esi
    movl (%ebp),%esi
f01039d1:	8b 75 00             	mov    0x0(%ebp),%esi
    pushl %ds
f01039d4:	1e                   	push   %ds
    pushl %es
f01039d5:	06                   	push   %es
    pushal  //push all register
f01039d6:	60                   	pusha  
    movl $GD_KD, %eax
f01039d7:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %es
f01039dc:	8e c0                	mov    %eax,%es
    movw %ax, %ds
f01039de:	8e d8                	mov    %eax,%ds
    pushl %esp
f01039e0:	54                   	push   %esp
	call syscallwrap
f01039e1:	e8 79 08 00 00       	call   f010425f <syscallwrap>
    popl %esp
f01039e6:	5c                   	pop    %esp
    popal
f01039e7:	61                   	popa   
    popl  %es
f01039e8:	07                   	pop    %es
    popl  %ds
f01039e9:	1f                   	pop    %ds
    //xchg %bx, %bx
    //popfl
    //xchg %bx, %bx
    popl %edx
f01039ea:	5a                   	pop    %edx
    popl %edx
f01039eb:	5a                   	pop    %edx
    popl %ecx
f01039ec:	59                   	pop    %ecx
    //sti
  	sysexit
f01039ed:	0f 35                	sysexit 
	...

f01039f0 <sched_yield>:

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01039f0:	55                   	push   %ebp
f01039f1:	89 e5                	mov    %esp,%ebp
f01039f3:	53                   	push   %ebx
f01039f4:	83 ec 04             	sub    $0x4,%esp
    // Implement simple round-robin scheduling.
    // Search through 'envs' for a runnable environment,
    // in circular fashion starting after the previously running env,
    // and switch to the first such environment found.
    // It's OK to choose the previously running env if no other env
    // is runnable.
    // But never choose envs[0], the idle environment,
    // unless NOTHING else is runnable.

    // LAB 4: Your code here.
    static int i = 0;//the start index of the envs
    int j = 0;
f01039f7:	bb 00 00 00 00       	mov    $0x0,%ebx
    while (j != NENV) {
        i = (i+1)%NENV;
f01039fc:	8b 0d 48 07 1d f0    	mov    0xf01d0748,%ecx
f0103a02:	8d 51 01             	lea    0x1(%ecx),%edx
f0103a05:	89 d0                	mov    %edx,%eax
f0103a07:	85 d2                	test   %edx,%edx
f0103a09:	79 06                	jns    f0103a11 <sched_yield+0x21>
f0103a0b:	8d 81 00 04 00 00    	lea    0x400(%ecx),%eax
f0103a11:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103a16:	29 c2                	sub    %eax,%edx
f0103a18:	89 d0                	mov    %edx,%eax
f0103a1a:	89 15 48 07 1d f0    	mov    %edx,0xf01d0748
        //cprintf("i%NENV %d\n",i);
        //cprintf("env_status == ENV_RUNNABLE?%d\n",(envs[i].env_status - ENV_RUNNABLE));
        //start from the last environment
        if ( i && (envs[i].env_status == ENV_RUNNABLE)) {
f0103a20:	85 d2                	test   %edx,%edx
f0103a22:	74 17                	je     f0103a3b <sched_yield+0x4b>
f0103a24:	8b 15 c0 fe 1c f0    	mov    0xf01cfec0,%edx
f0103a2a:	c1 e0 07             	shl    $0x7,%eax
f0103a2d:	83 7c 02 54 01       	cmpl   $0x1,0x54(%edx,%eax,1)
f0103a32:	75 07                	jne    f0103a3b <sched_yield+0x4b>
            //if the i isn't the mulptiple of the NENV and it's runnnable
            //cprintf("run the envs[%d]\n",i);
            env_run(&envs[i]);
f0103a34:	83 ec 0c             	sub    $0xc,%esp
f0103a37:	01 d0                	add    %edx,%eax
f0103a39:	eb 17                	jmp    f0103a52 <sched_yield+0x62>
        }
        j++;
f0103a3b:	43                   	inc    %ebx
f0103a3c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103a42:	75 b8                	jne    f01039fc <sched_yield+0xc>
        //loop NENV times
    }
    // Run the special idle environment when nothing else is runnable.
    if (envs[0].env_status == ENV_RUNNABLE)
f0103a44:	a1 c0 fe 1c f0       	mov    0xf01cfec0,%eax
f0103a49:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103a4d:	75 09                	jne    f0103a58 <sched_yield+0x68>
        env_run(&envs[0]);
f0103a4f:	83 ec 0c             	sub    $0xc,%esp
f0103a52:	50                   	push   %eax
f0103a53:	e8 0f f1 ff ff       	call   f0102b67 <env_run>
    else {
        cprintf("Destroyed all environments - nothing more to do!\n");
f0103a58:	83 ec 0c             	sub    $0xc,%esp
f0103a5b:	68 94 60 10 f0       	push   $0xf0106094
f0103a60:	e8 0d f3 ff ff       	call   f0102d72 <cprintf>
        while (1)
            monitor(NULL);
f0103a65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103a6c:	e8 92 ce ff ff       	call   f0100903 <monitor>
f0103a71:	eb f2                	jmp    f0103a65 <sched_yield+0x75>
	...

f0103a74 <sys_cputs>:
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
f0103a74:	55                   	push   %ebp
f0103a75:	89 e5                	mov    %esp,%ebp
f0103a77:	56                   	push   %esi
f0103a78:	53                   	push   %ebx
f0103a79:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103a7c:	8b 75 0c             	mov    0xc(%ebp),%esi
    // Check that the user has permission to read memory [s, s+len).
    // Destroy the environment if not.

    // LAB 3: Your code here.
    user_mem_assert(curenv,s,len,PTE_P);
f0103a7f:	6a 01                	push   $0x1
f0103a81:	56                   	push   %esi
f0103a82:	53                   	push   %ebx
f0103a83:	ff 35 c4 fe 1c f0    	pushl  0xf01cfec4
f0103a89:	e8 48 de ff ff       	call   f01018d6 <user_mem_assert>
    // Print the string supplied by the user.
    cprintf("%.*s", len, s);
f0103a8e:	83 c4 0c             	add    $0xc,%esp
f0103a91:	53                   	push   %ebx
f0103a92:	56                   	push   %esi
f0103a93:	68 c6 60 10 f0       	push   $0xf01060c6
f0103a98:	e8 d5 f2 ff ff       	call   f0102d72 <cprintf>
}
f0103a9d:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0103aa0:	5b                   	pop    %ebx
f0103aa1:	5e                   	pop    %esi
f0103aa2:	c9                   	leave  
f0103aa3:	c3                   	ret    

f0103aa4 <sys_cgetc>:

// Read a character from the system console.
// Returns the character.
static int
sys_cgetc(void)
{
f0103aa4:	55                   	push   %ebp
f0103aa5:	89 e5                	mov    %esp,%ebp
f0103aa7:	83 ec 08             	sub    $0x8,%esp
    int c;

    // The cons_getc() primitive doesn't wait for a character,
    // but the sys_cgetc() system call does.
    while ((c = cons_getc()) == 0)
f0103aaa:	e8 1b cb ff ff       	call   f01005ca <cons_getc>
f0103aaf:	85 c0                	test   %eax,%eax
f0103ab1:	74 f7                	je     f0103aaa <sys_cgetc+0x6>
        /* do nothing */;

    return c;
}
f0103ab3:	c9                   	leave  
f0103ab4:	c3                   	ret    

f0103ab5 <sys_getenvid>:

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0103ab5:	55                   	push   %ebp
f0103ab6:	89 e5                	mov    %esp,%ebp
    return curenv->env_id;
f0103ab8:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103abd:	8b 40 4c             	mov    0x4c(%eax),%eax
}
f0103ac0:	c9                   	leave  
f0103ac1:	c3                   	ret    

f0103ac2 <sys_env_destroy>:

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
f0103ac2:	55                   	push   %ebp
f0103ac3:	89 e5                	mov    %esp,%ebp
f0103ac5:	83 ec 0c             	sub    $0xc,%esp
    int r;
    struct Env *e;

    if ((r = envid2env(envid, &e, 1)) < 0)
f0103ac8:	6a 01                	push   $0x1
f0103aca:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f0103acd:	50                   	push   %eax
f0103ace:	ff 75 08             	pushl  0x8(%ebp)
f0103ad1:	e8 b2 e9 ff ff       	call   f0102488 <envid2env>
f0103ad6:	83 c4 10             	add    $0x10,%esp
f0103ad9:	89 c2                	mov    %eax,%edx
f0103adb:	85 c0                	test   %eax,%eax
f0103add:	78 43                	js     f0103b22 <sys_env_destroy+0x60>
        return r;
    if (e == curenv)
f0103adf:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
f0103ae2:	3b 05 c4 fe 1c f0    	cmp    0xf01cfec4,%eax
f0103ae8:	75 0d                	jne    f0103af7 <sys_env_destroy+0x35>
        cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103aea:	83 ec 08             	sub    $0x8,%esp
f0103aed:	ff 70 4c             	pushl  0x4c(%eax)
f0103af0:	68 cb 60 10 f0       	push   $0xf01060cb
f0103af5:	eb 16                	jmp    f0103b0d <sys_env_destroy+0x4b>
    else
        cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103af7:	83 ec 04             	sub    $0x4,%esp
f0103afa:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
f0103afd:	ff 70 4c             	pushl  0x4c(%eax)
f0103b00:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103b05:	ff 70 4c             	pushl  0x4c(%eax)
f0103b08:	68 e6 60 10 f0       	push   $0xf01060e6
f0103b0d:	e8 60 f2 ff ff       	call   f0102d72 <cprintf>
f0103b12:	83 c4 04             	add    $0x4,%esp
    env_destroy(e);
f0103b15:	ff 75 fc             	pushl  0xfffffffc(%ebp)
f0103b18:	e8 c5 ef ff ff       	call   f0102ae2 <env_destroy>
    return 0;
f0103b1d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103b22:	89 d0                	mov    %edx,%eax
f0103b24:	c9                   	leave  
f0103b25:	c3                   	ret    

f0103b26 <sys_dump_env>:

static int sys_dump_env(void){
f0103b26:	55                   	push   %ebp
f0103b27:	89 e5                	mov    %esp,%ebp
f0103b29:	83 ec 10             	sub    $0x10,%esp
    cprintf("env_id = %08x\n",curenv->env_id);
f0103b2c:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103b31:	ff 70 4c             	pushl  0x4c(%eax)
f0103b34:	68 fe 60 10 f0       	push   $0xf01060fe
f0103b39:	e8 34 f2 ff ff       	call   f0102d72 <cprintf>
    cprintf("env_parent_id = %08x\n",curenv->env_parent_id);
f0103b3e:	83 c4 08             	add    $0x8,%esp
f0103b41:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103b46:	ff 70 50             	pushl  0x50(%eax)
f0103b49:	68 0d 61 10 f0       	push   $0xf010610d
f0103b4e:	e8 1f f2 ff ff       	call   f0102d72 <cprintf>
    cprintf("env_runs = %d\n",curenv->env_runs);
f0103b53:	83 c4 08             	add    $0x8,%esp
f0103b56:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103b5b:	ff 70 58             	pushl  0x58(%eax)
f0103b5e:	68 23 61 10 f0       	push   $0xf0106123
f0103b63:	e8 0a f2 ff ff       	call   f0102d72 <cprintf>
    cprintf("env_pgdir = %08x\n",curenv->env_pgdir);
f0103b68:	83 c4 08             	add    $0x8,%esp
f0103b6b:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103b70:	ff 70 60             	pushl  0x60(%eax)
f0103b73:	68 32 61 10 f0       	push   $0xf0106132
f0103b78:	e8 f5 f1 ff ff       	call   f0102d72 <cprintf>
    cprintf("env_cr3 = %08x\n",curenv->env_cr3);
f0103b7d:	83 c4 08             	add    $0x8,%esp
f0103b80:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103b85:	ff 70 64             	pushl  0x64(%eax)
f0103b88:	68 44 61 10 f0       	push   $0xf0106144
f0103b8d:	e8 e0 f1 ff ff       	call   f0102d72 <cprintf>
    cprintf("env_syscalls = %d\n",curenv->env_syscalls);
f0103b92:	83 c4 08             	add    $0x8,%esp
f0103b95:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103b9a:	ff 70 5c             	pushl  0x5c(%eax)
f0103b9d:	68 54 61 10 f0       	push   $0xf0106154
f0103ba2:	e8 cb f1 ff ff       	call   f0102d72 <cprintf>
    return 0;
}
f0103ba7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bac:	c9                   	leave  
f0103bad:	c3                   	ret    

f0103bae <sys_yield>:
// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0103bae:	55                   	push   %ebp
f0103baf:	89 e5                	mov    %esp,%ebp
f0103bb1:	83 ec 08             	sub    $0x8,%esp
    sched_yield();
f0103bb4:	e8 37 fe ff ff       	call   f01039f0 <sched_yield>

f0103bb9 <sys_exofork>:
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
static envid_t
sys_exofork(void)
{
f0103bb9:	55                   	push   %ebp
f0103bba:	89 e5                	mov    %esp,%ebp
f0103bbc:	57                   	push   %edi
f0103bbd:	56                   	push   %esi
f0103bbe:	83 ec 18             	sub    $0x18,%esp
    // Create the new environment with env_alloc(), from kern/env.c.
    // It should be left as env_alloc created it, except that
    // status is set to ENV_NOT_RUNNABLE, and the register set is copied
    // from the current environment -- but tweaked so sys_exofork
    // will appear to return 0.

    // LAB 4: Your code here.
    //panic("sys_exofork not implemented");
    struct Env *new_env;
    //cprintf("sys_exofork here\n");
    if (env_alloc(&new_env,curenv->env_id)) {
f0103bc1:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103bc6:	ff 70 4c             	pushl  0x4c(%eax)
f0103bc9:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0103bcc:	50                   	push   %eax
f0103bcd:	e8 c1 ea ff ff       	call   f0102693 <env_alloc>
f0103bd2:	83 c4 10             	add    $0x10,%esp
f0103bd5:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f0103bda:	85 c0                	test   %eax,%eax
f0103bdc:	75 39                	jne    f0103c17 <sys_exofork+0x5e>
        //cprintf("env alloc fails\n");
        return -E_NO_FREE_ENV;
    }
    new_env->env_status = ENV_NOT_RUNNABLE;
f0103bde:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0103be1:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    new_env->env_tf = curenv->env_tf;
f0103be8:	8b 7d f4             	mov    0xfffffff4(%ebp),%edi
f0103beb:	8b 35 c4 fe 1c f0    	mov    0xf01cfec4,%esi
f0103bf1:	fc                   	cld    
f0103bf2:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103bf7:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
    new_env->env_pgfault_upcall = curenv->env_pgfault_upcall;
f0103bf9:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103bfe:	8b 50 68             	mov    0x68(%eax),%edx
f0103c01:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0103c04:	89 50 68             	mov    %edx,0x68(%eax)
    //new_env->env_tf.tf_regs.reg_eax = new_env->env_id;
    new_env->env_tf.tf_regs.reg_eax = 0;
f0103c07:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0103c0a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    //cprintf("in sys_exofork,the new_env's id is %d\n",new_env->env_id);
    return new_env->env_id;
f0103c11:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0103c14:	8b 50 4c             	mov    0x4c(%eax),%edx
}
f0103c17:	89 d0                	mov    %edx,%eax
f0103c19:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0103c1c:	5e                   	pop    %esi
f0103c1d:	5f                   	pop    %edi
f0103c1e:	c9                   	leave  
f0103c1f:	c3                   	ret    

f0103c20 <sys_env_set_status>:

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
f0103c20:	55                   	push   %ebp
f0103c21:	89 e5                	mov    %esp,%ebp
f0103c23:	53                   	push   %ebx
f0103c24:	83 ec 04             	sub    $0x4,%esp
f0103c27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // Hint: Use the 'envid2env' function from kern/env.c to translate an
    // envid to a struct Env.
    // You should set envid2env's third argument to 1, which will
    // check whether the current environment has permission to set
    // envid's status.

    // LAB 4: Your code here.
    struct Env *env;
    if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f0103c2a:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
f0103c2d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0103c32:	83 f8 01             	cmp    $0x1,%eax
f0103c35:	77 28                	ja     f0103c5f <sys_env_set_status+0x3f>
        return -E_INVAL;
    }
    if (envid2env(envid,&env,1)) {
f0103c37:	83 ec 04             	sub    $0x4,%esp
f0103c3a:	6a 01                	push   $0x1
f0103c3c:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f0103c3f:	50                   	push   %eax
f0103c40:	ff 75 08             	pushl  0x8(%ebp)
f0103c43:	e8 40 e8 ff ff       	call   f0102488 <envid2env>
f0103c48:	83 c4 10             	add    $0x10,%esp
f0103c4b:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f0103c50:	85 c0                	test   %eax,%eax
f0103c52:	75 0b                	jne    f0103c5f <sys_env_set_status+0x3f>
        return -E_BAD_ENV;
    }
    env->env_status = status;
f0103c54:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f0103c57:	89 58 54             	mov    %ebx,0x54(%eax)
    return 0;
f0103c5a:	ba 00 00 00 00       	mov    $0x0,%edx
    panic("sys_env_set_status not implemented");
}
f0103c5f:	89 d0                	mov    %edx,%eax
f0103c61:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0103c64:	c9                   	leave  
f0103c65:	c3                   	ret    

f0103c66 <sys_env_set_trapframe>:

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3) with interrupts enabled.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
f0103c66:	55                   	push   %ebp
f0103c67:	89 e5                	mov    %esp,%ebp
f0103c69:	57                   	push   %edi
f0103c6a:	56                   	push   %esi
f0103c6b:	53                   	push   %ebx
f0103c6c:	83 ec 10             	sub    $0x10,%esp
f0103c6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103c72:	8b 75 0c             	mov    0xc(%ebp),%esi
    // LAB 4: Your code here.
    // Remember to check whether the user has supplied us with a good
    // address!
    struct Env *env;
    int r;//may be this method is wrong,because i use the padding in the tf to know how it syscall
    cprintf("sys set trapframe:envid:%d,tf:%x\n",envid,tf);
f0103c75:	56                   	push   %esi
f0103c76:	53                   	push   %ebx
f0103c77:	68 7c 62 10 f0       	push   $0xf010627c
f0103c7c:	e8 f1 f0 ff ff       	call   f0102d72 <cprintf>
    if (( r = envid2env(envid,&env,1))) {
f0103c81:	83 c4 0c             	add    $0xc,%esp
f0103c84:	6a 01                	push   $0x1
f0103c86:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0103c89:	50                   	push   %eax
f0103c8a:	53                   	push   %ebx
f0103c8b:	e8 f8 e7 ff ff       	call   f0102488 <envid2env>
f0103c90:	83 c4 10             	add    $0x10,%esp
f0103c93:	89 c2                	mov    %eax,%edx
f0103c95:	85 c0                	test   %eax,%eax
f0103c97:	75 10                	jne    f0103ca9 <sys_env_set_trapframe+0x43>
        return r;
    }
    env->env_tf = *tf;
f0103c99:	8b 7d f0             	mov    0xfffffff0(%ebp),%edi
f0103c9c:	fc                   	cld    
f0103c9d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103ca2:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
    return 0;
f0103ca4:	ba 00 00 00 00       	mov    $0x0,%edx
    panic("sys_set_trapframe not implemented");
}
f0103ca9:	89 d0                	mov    %edx,%eax
f0103cab:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103cae:	5b                   	pop    %ebx
f0103caf:	5e                   	pop    %esi
f0103cb0:	5f                   	pop    %edi
f0103cb1:	c9                   	leave  
f0103cb2:	c3                   	ret    

f0103cb3 <sys_env_set_pgfault_upcall>:

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
f0103cb3:	55                   	push   %ebp
f0103cb4:	89 e5                	mov    %esp,%ebp
f0103cb6:	83 ec 0c             	sub    $0xc,%esp
    // LAB 4: Your code here.
    struct Env *env;
    if (envid2env(envid,&env,1)) {
f0103cb9:	6a 01                	push   $0x1
f0103cbb:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f0103cbe:	50                   	push   %eax
f0103cbf:	ff 75 08             	pushl  0x8(%ebp)
f0103cc2:	e8 c1 e7 ff ff       	call   f0102488 <envid2env>
f0103cc7:	83 c4 10             	add    $0x10,%esp
f0103cca:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f0103ccf:	85 c0                	test   %eax,%eax
f0103cd1:	75 0e                	jne    f0103ce1 <sys_env_set_pgfault_upcall+0x2e>
        return -E_BAD_ENV;
    }
    env->env_pgfault_upcall = func;
f0103cd3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cd6:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
f0103cd9:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
f0103cdc:	ba 00 00 00 00       	mov    $0x0,%edx
    panic("sys_env_set_pgfault_upcall not implemented");
}
f0103ce1:	89 d0                	mov    %edx,%eax
f0103ce3:	c9                   	leave  
f0103ce4:	c3                   	ret    

f0103ce5 <sys_page_alloc>:

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
f0103ce5:	55                   	push   %ebp
f0103ce6:	89 e5                	mov    %esp,%ebp
f0103ce8:	56                   	push   %esi
f0103ce9:	53                   	push   %ebx
f0103cea:	83 ec 10             	sub    $0x10,%esp
f0103ced:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103cf0:	8b 75 10             	mov    0x10(%ebp),%esi
    // Hint: This function is a wrapper around page_alloc() and
    //   page_insert() from kern/pmap.c.
    //   Most of the new code you write should be to check the
    //   parameters for correctness.
    //   If page_insert() fails, remember to free the page you
    //   allocated!

    // LAB 4: Your code here.
    struct Env *env;
    struct Page *page;
    //cprintf("parameter envid = %d,va = %x,perm = %x\n",envid,va,perm);
    if (((uint32_t)va >= UTOP) || (((uint32_t)va) % PGSIZE)) {
f0103cf3:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0103cf9:	77 08                	ja     f0103d03 <sys_page_alloc+0x1e>
f0103cfb:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0103d01:	74 0a                	je     f0103d0d <sys_page_alloc+0x28>
        cprintf("va is invalid\n");
f0103d03:	83 ec 0c             	sub    $0xc,%esp
f0103d06:	68 67 61 10 f0       	push   $0xf0106167
f0103d0b:	eb 14                	jmp    f0103d21 <sys_page_alloc+0x3c>
        return -E_INVAL;
    }
    if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~(PTE_U|PTE_W|PTE_P|PTE_AVAIL))) {
f0103d0d:	89 f0                	mov    %esi,%eax
f0103d0f:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0103d14:	83 f8 05             	cmp    $0x5,%eax
f0103d17:	74 17                	je     f0103d30 <sys_page_alloc+0x4b>
        cprintf("perm is invalid\n");
f0103d19:	83 ec 0c             	sub    $0xc,%esp
f0103d1c:	68 76 61 10 f0       	push   $0xf0106176
f0103d21:	e8 4c f0 ff ff       	call   f0102d72 <cprintf>
        return -E_INVAL;
f0103d26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103d2b:	e9 fa 00 00 00       	jmp    f0103e2a <sys_page_alloc+0x145>
    }
    if (envid2env(envid,&env,1)) {
f0103d30:	83 ec 04             	sub    $0x4,%esp
f0103d33:	6a 01                	push   $0x1
f0103d35:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0103d38:	50                   	push   %eax
f0103d39:	ff 75 08             	pushl  0x8(%ebp)
f0103d3c:	e8 47 e7 ff ff       	call   f0102488 <envid2env>
f0103d41:	83 c4 10             	add    $0x10,%esp
f0103d44:	85 c0                	test   %eax,%eax
f0103d46:	74 17                	je     f0103d5f <sys_page_alloc+0x7a>
        cprintf("env is not ok\n");
f0103d48:	83 ec 0c             	sub    $0xc,%esp
f0103d4b:	68 87 61 10 f0       	push   $0xf0106187
f0103d50:	e8 1d f0 ff ff       	call   f0102d72 <cprintf>
        return -E_BAD_ENV;
f0103d55:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103d5a:	e9 cb 00 00 00       	jmp    f0103e2a <sys_page_alloc+0x145>
    }
    if (page_alloc(&page)) {
f0103d5f:	83 ec 0c             	sub    $0xc,%esp
f0103d62:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0103d65:	50                   	push   %eax
f0103d66:	e8 10 d7 ff ff       	call   f010147b <page_alloc>
f0103d6b:	83 c4 10             	add    $0x10,%esp
f0103d6e:	85 c0                	test   %eax,%eax
f0103d70:	74 0f                	je     f0103d81 <sys_page_alloc+0x9c>
        cprintf("page_alloc is not ok\n");
f0103d72:	83 ec 0c             	sub    $0xc,%esp
f0103d75:	68 96 61 10 f0       	push   $0xf0106196
f0103d7a:	e8 f3 ef ff ff       	call   f0102d72 <cprintf>
        return -E_NO_MEM;
f0103d7f:	eb 2f                	jmp    f0103db0 <sys_page_alloc+0xcb>
    }
    if (page_insert(env->env_pgdir,page,va,perm)) {
f0103d81:	56                   	push   %esi
f0103d82:	53                   	push   %ebx
f0103d83:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0103d86:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0103d89:	ff 70 60             	pushl  0x60(%eax)
f0103d8c:	e8 d0 d8 ff ff       	call   f0101661 <page_insert>
f0103d91:	83 c4 10             	add    $0x10,%esp
f0103d94:	85 c0                	test   %eax,%eax
f0103d96:	74 1f                	je     f0103db7 <sys_page_alloc+0xd2>
        cprintf("page insert is not ok\n");
f0103d98:	83 ec 0c             	sub    $0xc,%esp
f0103d9b:	68 ac 61 10 f0       	push   $0xf01061ac
f0103da0:	e8 cd ef ff ff       	call   f0102d72 <cprintf>
        page_free(page);
f0103da5:	83 c4 04             	add    $0x4,%esp
f0103da8:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0103dab:	e8 0d d7 ff ff       	call   f01014bd <page_free>
        return -E_NO_MEM;
f0103db0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103db5:	eb 73                	jmp    f0103e2a <sys_page_alloc+0x145>

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0103db7:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0103dba:	2b 15 6c 0b 1d f0    	sub    0xf01d0b6c,%edx
f0103dc0:	c1 fa 02             	sar    $0x2,%edx
f0103dc3:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0103dc6:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103dc9:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103dcc:	89 c1                	mov    %eax,%ecx
f0103dce:	c1 e1 08             	shl    $0x8,%ecx
f0103dd1:	01 c8                	add    %ecx,%eax
f0103dd3:	89 c1                	mov    %eax,%ecx
f0103dd5:	c1 e1 10             	shl    $0x10,%ecx
f0103dd8:	01 c8                	add    %ecx,%eax
f0103dda:	8d 04 42             	lea    (%edx,%eax,2),%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
f0103ddd:	89 c2                	mov    %eax,%edx
f0103ddf:	c1 e2 0c             	shl    $0xc,%edx
	return page2ppn(pp) << PGSHIFT;
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
		panic("pa2page called with invalid pa");
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0103de2:	89 d0                	mov    %edx,%eax
f0103de4:	c1 e8 0c             	shr    $0xc,%eax
f0103de7:	3b 05 60 0b 1d f0    	cmp    0xf01d0b60,%eax
f0103ded:	72 12                	jb     f0103e01 <sys_page_alloc+0x11c>
f0103def:	52                   	push   %edx
f0103df0:	68 e4 54 10 f0       	push   $0xf01054e4
f0103df5:	6a 5a                	push   $0x5a
f0103df7:	68 52 5a 10 f0       	push   $0xf0105a52
f0103dfc:	e8 e3 c2 ff ff       	call   f01000e4 <_panic>
f0103e01:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0103e07:	83 ec 04             	sub    $0x4,%esp
f0103e0a:	68 00 10 00 00       	push   $0x1000
f0103e0f:	6a 00                	push   $0x0
f0103e11:	50                   	push   %eax
f0103e12:	e8 1c 0f 00 00       	call   f0104d33 <memset>
}

static __inline void
lcr3(uint32_t val)
{
f0103e17:	83 c4 10             	add    $0x10,%esp
f0103e1a:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103e1f:	8b 40 64             	mov    0x64(%eax),%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103e22:	0f 22 d8             	mov    %eax,%cr3
    }
    memset(page2kva(page),0,PGSIZE);
    lcr3(curenv->env_cr3);
    //cprintf("the alloc is ok\n");
    return 0;
f0103e25:	b8 00 00 00 00       	mov    $0x0,%eax
    panic("sys_page_alloc not implemented");
}
f0103e2a:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0103e2d:	5b                   	pop    %ebx
f0103e2e:	5e                   	pop    %esi
f0103e2f:	c9                   	leave  
f0103e30:	c3                   	ret    

f0103e31 <sys_page_map>:

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
             envid_t dstenvid, void *dstva, int perm)
{
f0103e31:	55                   	push   %ebp
f0103e32:	89 e5                	mov    %esp,%ebp
f0103e34:	57                   	push   %edi
f0103e35:	56                   	push   %esi
f0103e36:	53                   	push   %ebx
f0103e37:	83 ec 10             	sub    $0x10,%esp
f0103e3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
f0103e40:	8b 75 18             	mov    0x18(%ebp),%esi
    // Hint: This function is a wrapper around page_lookup() and
    //   page_insert() from kern/pmap.c.
    //   Again, most of the new code you write should be to check the
    //   parameters for correctness.
    //   Use the third argument to page_lookup() to
    //   check the current permissions on the page.

    // LAB 4: Your code here.
    struct Env *src_env;
    struct Env *dst_env;

    struct Page *page;
    pte_t *pte_store;
    /*if ((uint32_t)srcva == USTACKTOP-PGSIZE||(uint32_t)dstva == USTACKTOP-PGSIZE) {
        cprintf("the stack arguement in KERN pgmap srcenv:%d,srcva:%x,dstenv:%d,dstva:%x,perm:%x\n",srcenvid,srcva,dstenvid,dstva,perm);
    }*/
    if (envid2env(srcenvid,&src_env,1)|| envid2env(dstenvid,&dst_env,1)) {
f0103e43:	6a 01                	push   $0x1
f0103e45:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0103e48:	50                   	push   %eax
f0103e49:	ff 75 08             	pushl  0x8(%ebp)
f0103e4c:	e8 37 e6 ff ff       	call   f0102488 <envid2env>
f0103e51:	83 c4 10             	add    $0x10,%esp
f0103e54:	85 c0                	test   %eax,%eax
f0103e56:	75 18                	jne    f0103e70 <sys_page_map+0x3f>
f0103e58:	83 ec 04             	sub    $0x4,%esp
f0103e5b:	6a 01                	push   $0x1
f0103e5d:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0103e60:	50                   	push   %eax
f0103e61:	ff 75 10             	pushl  0x10(%ebp)
f0103e64:	e8 1f e6 ff ff       	call   f0102488 <envid2env>
f0103e69:	83 c4 10             	add    $0x10,%esp
f0103e6c:	85 c0                	test   %eax,%eax
f0103e6e:	74 0a                	je     f0103e7a <sys_page_map+0x49>
        return -E_BAD_ENV;
f0103e70:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103e75:	e9 b9 00 00 00       	jmp    f0103f33 <sys_page_map+0x102>
    }
    page = page_lookup(src_env->env_pgdir,srcva,&pte_store);
f0103e7a:	83 ec 04             	sub    $0x4,%esp
f0103e7d:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0103e80:	50                   	push   %eax
f0103e81:	53                   	push   %ebx
f0103e82:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0103e85:	ff 70 60             	pushl  0x60(%eax)
f0103e88:	e8 e6 d8 ff ff       	call   f0101773 <page_lookup>
f0103e8d:	89 c2                	mov    %eax,%edx
    //cprintf("in map parameter perm = %x\n",perm);
    if (page == NULL) {
f0103e8f:	83 c4 10             	add    $0x10,%esp
f0103e92:	85 c0                	test   %eax,%eax
f0103e94:	75 0a                	jne    f0103ea0 <sys_page_map+0x6f>
        cprintf("page fails\n");
f0103e96:	83 ec 0c             	sub    $0xc,%esp
f0103e99:	68 c3 61 10 f0       	push   $0xf01061c3
f0103e9e:	eb 4e                	jmp    f0103eee <sys_page_map+0xbd>
        return -E_INVAL;
    }
    if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~(PTE_U|PTE_W|PTE_P|PTE_AVAIL)) || (!(*pte_store & PTE_W) && (perm & PTE_W))) {
f0103ea0:	89 f0                	mov    %esi,%eax
f0103ea2:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0103ea7:	83 f8 05             	cmp    $0x5,%eax
f0103eaa:	75 10                	jne    f0103ebc <sys_page_map+0x8b>
f0103eac:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0103eaf:	f6 00 02             	testb  $0x2,(%eax)
f0103eb2:	75 12                	jne    f0103ec6 <sys_page_map+0x95>
f0103eb4:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0103eba:	74 0a                	je     f0103ec6 <sys_page_map+0x95>
        cprintf("perm invalid\n");
f0103ebc:	83 ec 0c             	sub    $0xc,%esp
f0103ebf:	68 cf 61 10 f0       	push   $0xf01061cf
f0103ec4:	eb 28                	jmp    f0103eee <sys_page_map+0xbd>
        return -E_INVAL;
    }
    if ((((uint32_t)srcva) >= UTOP) || (((uint32_t)dstva) >= UTOP) || (((uint32_t)srcva) % PGSIZE) || (((uint32_t)dstva) % PGSIZE)) {
f0103ec6:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0103ecc:	77 18                	ja     f0103ee6 <sys_page_map+0xb5>
f0103ece:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0103ed4:	77 10                	ja     f0103ee6 <sys_page_map+0xb5>
f0103ed6:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0103edc:	75 08                	jne    f0103ee6 <sys_page_map+0xb5>
f0103ede:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0103ee4:	74 14                	je     f0103efa <sys_page_map+0xc9>
        cprintf("address invalid\n");
f0103ee6:	83 ec 0c             	sub    $0xc,%esp
f0103ee9:	68 dd 61 10 f0       	push   $0xf01061dd
f0103eee:	e8 7f ee ff ff       	call   f0102d72 <cprintf>
        return -E_INVAL;
f0103ef3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103ef8:	eb 39                	jmp    f0103f33 <sys_page_map+0x102>
    }
    if (page_insert(dst_env->env_pgdir,page,dstva,perm)) {
f0103efa:	56                   	push   %esi
f0103efb:	57                   	push   %edi
f0103efc:	52                   	push   %edx
f0103efd:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0103f00:	ff 70 60             	pushl  0x60(%eax)
f0103f03:	e8 59 d7 ff ff       	call   f0101661 <page_insert>
f0103f08:	83 c4 10             	add    $0x10,%esp
f0103f0b:	85 c0                	test   %eax,%eax
f0103f0d:	74 14                	je     f0103f23 <sys_page_map+0xf2>
        cprintf("insert invalid\n");
f0103f0f:	83 ec 0c             	sub    $0xc,%esp
f0103f12:	68 ee 61 10 f0       	push   $0xf01061ee
f0103f17:	e8 56 ee ff ff       	call   f0102d72 <cprintf>
        return -E_NO_MEM;
f0103f1c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103f21:	eb 10                	jmp    f0103f33 <sys_page_map+0x102>
}

static __inline void
lcr3(uint32_t val)
{
f0103f23:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103f28:	8b 40 64             	mov    0x64(%eax),%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103f2b:	0f 22 d8             	mov    %eax,%cr3
    }
    /*page = page_lookup(dst_env->env_pgdir,dstva,&pte_store);
    if ((uint32_t)dstva == USTACKTOP-PGSIZE) {
        cprintf("now the page is COW?%x\n",*pte_store&0x807);
    }*/
    lcr3(curenv->env_cr3);
    return 0;
f0103f2e:	b8 00 00 00 00       	mov    $0x0,%eax
    panic("sys_page_map not implemented");
}
f0103f33:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103f36:	5b                   	pop    %ebx
f0103f37:	5e                   	pop    %esi
f0103f38:	5f                   	pop    %edi
f0103f39:	c9                   	leave  
f0103f3a:	c3                   	ret    

f0103f3b <sys_page_unmap>:

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
f0103f3b:	55                   	push   %ebp
f0103f3c:	89 e5                	mov    %esp,%ebp
f0103f3e:	53                   	push   %ebx
f0103f3f:	83 ec 08             	sub    $0x8,%esp
f0103f42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // Hint: This function is a wrapper around page_remove().

    // LAB 4: Your code here.
    struct Env *env;
    //cprintf("after envid2env in sys_page_unmap\n");
    if (envid2env(envid,&env,1)) {
f0103f45:	6a 01                	push   $0x1
f0103f47:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f0103f4a:	50                   	push   %eax
f0103f4b:	ff 75 08             	pushl  0x8(%ebp)
f0103f4e:	e8 35 e5 ff ff       	call   f0102488 <envid2env>
f0103f53:	83 c4 10             	add    $0x10,%esp
f0103f56:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f0103f5b:	85 c0                	test   %eax,%eax
f0103f5d:	75 39                	jne    f0103f98 <sys_page_unmap+0x5d>
        return -E_BAD_ENV;
    }
    if ((((uint32_t)va) >= UTOP) || (((uint32_t)va) %PGSIZE)) {
f0103f5f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0103f65:	77 08                	ja     f0103f6f <sys_page_unmap+0x34>
f0103f67:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0103f6d:	74 07                	je     f0103f76 <sys_page_unmap+0x3b>
        return -E_INVAL;
f0103f6f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0103f74:	eb 22                	jmp    f0103f98 <sys_page_unmap+0x5d>
    }
    //cprintf("page remove in sys_page_unmap va:%x\n",va);
    page_remove(env->env_pgdir,va);
f0103f76:	83 ec 08             	sub    $0x8,%esp
f0103f79:	53                   	push   %ebx
f0103f7a:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f0103f7d:	ff 70 60             	pushl  0x60(%eax)
f0103f80:	e8 5a d8 ff ff       	call   f01017df <page_remove>
}

static __inline void
lcr3(uint32_t val)
{
f0103f85:	83 c4 10             	add    $0x10,%esp
f0103f88:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0103f8d:	8b 40 64             	mov    0x64(%eax),%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103f90:	0f 22 d8             	mov    %eax,%cr3
    //cprintf("page removed in the sys_page_unmap\n");
    lcr3(curenv->env_cr3);
    return 0;
f0103f93:	ba 00 00 00 00       	mov    $0x0,%edx
    panic("sys_page_unmap not implemented");
}
f0103f98:	89 d0                	mov    %edx,%eax
f0103f9a:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0103f9d:	c9                   	leave  
f0103f9e:	c3                   	ret    

f0103f9f <sys_ipc_try_send>:

// Try to send 'value' to the target env 'envid'.
// If va != 0, then also send page currently mapped at 'va',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target has not requested IPC with sys_ipc_recv.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused ipc_recv system call.
//
// If the sender sends a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc doesn't happen unless no errors occur.
//
// Returns 0 on success where no page mapping occurs,
// 1 on success where a page mapping occurs, and < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
f0103f9f:	55                   	push   %ebp
f0103fa0:	89 e5                	mov    %esp,%ebp
f0103fa2:	57                   	push   %edi
f0103fa3:	56                   	push   %esi
f0103fa4:	53                   	push   %ebx
f0103fa5:	83 ec 10             	sub    $0x10,%esp
f0103fa8:	8b 75 10             	mov    0x10(%ebp),%esi
f0103fab:	8b 7d 14             	mov    0x14(%ebp),%edi
    // LAB 4: Your code here.
    int r;
    int ret = 0;
f0103fae:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
    struct Env *dstenv;
    if ((r = envid2env(envid,&dstenv,0))) {//needn't check
f0103fb5:	6a 00                	push   $0x0
f0103fb7:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0103fba:	50                   	push   %eax
f0103fbb:	ff 75 08             	pushl  0x8(%ebp)
f0103fbe:	e8 c5 e4 ff ff       	call   f0102488 <envid2env>
f0103fc3:	89 c3                	mov    %eax,%ebx
f0103fc5:	83 c4 10             	add    $0x10,%esp
f0103fc8:	85 c0                	test   %eax,%eax
f0103fca:	74 0d                	je     f0103fd9 <sys_ipc_try_send+0x3a>
        cprintf("invalid env\n");
f0103fcc:	83 ec 0c             	sub    $0xc,%esp
f0103fcf:	68 fe 61 10 f0       	push   $0xf01061fe
f0103fd4:	e9 aa 00 00 00       	jmp    f0104083 <sys_ipc_try_send+0xe4>
        return r;
    }
    if (!dstenv->env_ipc_recving) {
f0103fd9:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0103fdc:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0103fe0:	75 0a                	jne    f0103fec <sys_ipc_try_send+0x4d>
        /*not recieving*/
        //cprintf("the dstenv:%d is not recieving\n",dstenv->env_id);
        return -E_IPC_NOT_RECV;
f0103fe2:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0103fe7:	e9 e1 00 00 00       	jmp    f01040cd <sys_ipc_try_send+0x12e>
    }
    if ((uint32_t)srcva < UTOP) {
f0103fec:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0103ff2:	77 35                	ja     f0104029 <sys_ipc_try_send+0x8a>
        /*send a page then check parameter*/
        if ((uint32_t)srcva % PGSIZE) {
f0103ff4:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0103ffa:	74 0a                	je     f0104006 <sys_ipc_try_send+0x67>
            cprintf("invalid srcva\n");
f0103ffc:	83 ec 0c             	sub    $0xc,%esp
f0103fff:	68 0b 62 10 f0       	push   $0xf010620b
f0104004:	eb 14                	jmp    f010401a <sys_ipc_try_send+0x7b>
            return -E_INVAL;
        }
        if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~(PTE_U|PTE_W|PTE_P|PTE_AVAIL))) {// || (!(*pte_store & PTE_W) && (perm & PTE_W))
f0104006:	89 f8                	mov    %edi,%eax
f0104008:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010400d:	83 f8 05             	cmp    $0x5,%eax
f0104010:	74 17                	je     f0104029 <sys_ipc_try_send+0x8a>
            cprintf("invalid perm\n");
f0104012:	83 ec 0c             	sub    $0xc,%esp
f0104015:	68 1a 62 10 f0       	push   $0xf010621a
f010401a:	e8 53 ed ff ff       	call   f0102d72 <cprintf>
            return -E_INVAL;
f010401f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104024:	e9 a4 00 00 00       	jmp    f01040cd <sys_ipc_try_send+0x12e>
        }
    }
    dstenv->env_ipc_recving = 0;//reset it
f0104029:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010402c:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
    dstenv->env_ipc_perm = 0;//initial with low perm
f0104033:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104036:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
    if ((uint32_t)srcva < UTOP && (uint32_t)dstenv->env_ipc_dstva < UTOP) {
f010403d:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104043:	77 64                	ja     f01040a9 <sys_ipc_try_send+0x10a>
f0104045:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104048:	81 78 70 ff ff bf ee 	cmpl   $0xeebfffff,0x70(%eax)
f010404f:	77 58                	ja     f01040a9 <sys_ipc_try_send+0x10a>
        cprintf("syscall send page\n");
f0104051:	83 ec 0c             	sub    $0xc,%esp
f0104054:	68 28 62 10 f0       	push   $0xf0106228
f0104059:	e8 14 ed ff ff       	call   f0102d72 <cprintf>
        if ((r = sys_page_map(0,srcva,envid,(void*)dstenv->env_ipc_dstva,perm))) {
f010405e:	89 3c 24             	mov    %edi,(%esp)
f0104061:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104064:	ff 70 70             	pushl  0x70(%eax)
f0104067:	ff 75 08             	pushl  0x8(%ebp)
f010406a:	56                   	push   %esi
f010406b:	6a 00                	push   $0x0
f010406d:	e8 bf fd ff ff       	call   f0103e31 <sys_page_map>
f0104072:	89 c3                	mov    %eax,%ebx
f0104074:	83 c4 20             	add    $0x20,%esp
f0104077:	85 c0                	test   %eax,%eax
f0104079:	74 11                	je     f010408c <sys_ipc_try_send+0xed>
            cprintf("the page map is not ok\n");
f010407b:	83 ec 0c             	sub    $0xc,%esp
f010407e:	68 3b 62 10 f0       	push   $0xf010623b
f0104083:	e8 ea ec ff ff       	call   f0102d72 <cprintf>
            return r;
f0104088:	89 d8                	mov    %ebx,%eax
f010408a:	eb 41                	jmp    f01040cd <sys_ipc_try_send+0x12e>
        }
        cprintf("syscall send page ok\n");
f010408c:	83 ec 0c             	sub    $0xc,%esp
f010408f:	68 53 62 10 f0       	push   $0xf0106253
f0104094:	e8 d9 ec ff ff       	call   f0102d72 <cprintf>
        dstenv->env_ipc_perm = perm;
f0104099:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010409c:	89 78 7c             	mov    %edi,0x7c(%eax)
        ret = 1;
f010409f:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
f01040a6:	83 c4 10             	add    $0x10,%esp
    }
    dstenv->env_ipc_value = value;
f01040a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040ac:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01040af:	89 50 74             	mov    %edx,0x74(%eax)
    dstenv->env_ipc_from = curenv->env_id;
f01040b2:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f01040b7:	8b 50 4c             	mov    0x4c(%eax),%edx
f01040ba:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01040bd:	89 50 78             	mov    %edx,0x78(%eax)
    //cprintf("set dstenv->env_ipc_from:%d\n",dstenv->env_ipc_from);
    dstenv->env_status = ENV_RUNNABLE;
f01040c0:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01040c3:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
    return ret;
f01040ca:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
    //panic("sys_ipc_try_send not implemented");
}
f01040cd:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01040d0:	5b                   	pop    %ebx
f01040d1:	5e                   	pop    %esi
f01040d2:	5f                   	pop    %edi
f01040d3:	c9                   	leave  
f01040d4:	c3                   	ret    

f01040d5 <sys_ipc_recv>:

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f01040d5:	55                   	push   %ebp
f01040d6:	89 e5                	mov    %esp,%ebp
f01040d8:	53                   	push   %ebx
f01040d9:	83 ec 04             	sub    $0x4,%esp
f01040dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
    // LAB 4: Your code here.
    int r;
    if ((uint32_t)dstva < UTOP) {
f01040df:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01040e5:	77 22                	ja     f0104109 <sys_ipc_recv+0x34>
        /*recv page*/
        if ((uint32_t)dstva % PGSIZE) {
f01040e7:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01040ed:	75 73                	jne    f0104162 <sys_ipc_recv+0x8d>
            return -E_INVAL;
        } else {
            cprintf("want get map page\n");
f01040ef:	83 ec 0c             	sub    $0xc,%esp
f01040f2:	68 69 62 10 f0       	push   $0xf0106269
f01040f7:	e8 76 ec ff ff       	call   f0102d72 <cprintf>
            curenv->env_ipc_dstva = dstva;
f01040fc:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0104101:	89 58 70             	mov    %ebx,0x70(%eax)
f0104104:	83 c4 10             	add    $0x10,%esp
f0104107:	eb 0c                	jmp    f0104115 <sys_ipc_recv+0x40>
        }
    } else {
        /*if not recieve page set the dstva as UTOP*/
        curenv->env_ipc_dstva = (void *) UTOP;
f0104109:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f010410e:	c7 40 70 00 00 c0 ee 	movl   $0xeec00000,0x70(%eax)
    }
    curenv->env_ipc_recving = 1;
f0104115:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f010411a:	c7 40 6c 01 00 00 00 	movl   $0x1,0x6c(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0104121:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0104126:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    curenv->env_ipc_perm = 0;
f010412d:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0104132:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
    curenv->env_ipc_value = 0;
f0104139:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f010413e:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    curenv->env_ipc_from = 0;
f0104145:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f010414a:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
    //cprintf("curenv:%d recv set ok\n",curenv->env_id);
    curenv->env_tf.tf_regs.reg_eax = 0;
f0104151:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0104156:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    sched_yield();
f010415d:	e8 8e f8 ff ff       	call   f01039f0 <sched_yield>
    return 0;//never return
    panic("sys_ipc_recv not implemented");
    return 0;
}
f0104162:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104167:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010416a:	c9                   	leave  
f010416b:	c3                   	ret    

f010416c <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010416c:	55                   	push   %ebp
f010416d:	89 e5                	mov    %esp,%ebp
f010416f:	57                   	push   %edi
f0104170:	56                   	push   %esi
f0104171:	53                   	push   %ebx
f0104172:	83 ec 0c             	sub    $0xc,%esp
f0104175:	8b 55 08             	mov    0x8(%ebp),%edx
f0104178:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010417b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010417e:	8b 75 14             	mov    0x14(%ebp),%esi
    // Call the function corresponding to the 'syscallno' parameter.
    // Return any appropriate return value.
    // LAB 3: Your code here.
    //cprintf("kern syscall\n");
    int r = 0;
f0104181:	bb 00 00 00 00       	mov    $0x0,%ebx
    switch (syscallno) {
    case SYS_cputs:
        //cprintf("cputs\n");
        sys_cputs((char*)a1,(size_t)a2);
        break;
    case SYS_cgetc:
        //cprintf("sys_cgetc\n");
        r = (int32_t)sys_cgetc();
        break;
    case SYS_getenvid:
        //cprintf("sys_getenvid\n");
        r = (int32_t)sys_getenvid();
        break;
    case SYS_env_destroy:
        //cprintf("sys_env_destroy\n");
        r = (int32_t)sys_env_destroy((envid_t)a1);
        break;
    case SYS_dump_env:
        //cprintf("sys_dump_env\n");
        r = sys_dump_env();
        break;
    case SYS_page_alloc:
        r = sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
        break;
    case SYS_page_map:
        r = sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
        break;
    case SYS_page_unmap:
        r = sys_page_unmap((envid_t)a1,(void*)a2);
        break;
    case SYS_exofork:
        r = sys_exofork();
        break;
    case SYS_env_set_status:
        r = sys_env_set_status((envid_t)a1,(int)a2);
        break;
    case SYS_env_set_trapframe:
        r = sys_env_set_trapframe((envid_t)a1,(struct Trapframe *)a2);
        break;
    case SYS_env_set_pgfault_upcall:
        r = sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
        break;
    case SYS_yield:
        sys_yield();
        break;
    case SYS_ipc_try_send:
        r = sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void*)a3,(unsigned) a4);
        break;
    case SYS_ipc_recv:
        r = sys_ipc_recv((void*)a1);
        break;
    default:
        return -E_INVAL;
f0104186:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010418b:	83 fa 0e             	cmp    $0xe,%edx
f010418e:	0f 87 c3 00 00 00    	ja     f0104257 <syscall+0xeb>
f0104194:	ff 24 95 a0 62 10 f0 	jmp    *0xf01062a0(,%edx,4)
f010419b:	83 ec 08             	sub    $0x8,%esp
f010419e:	51                   	push   %ecx
f010419f:	57                   	push   %edi
f01041a0:	e8 cf f8 ff ff       	call   f0103a74 <sys_cputs>
f01041a5:	e9 a0 00 00 00       	jmp    f010424a <syscall+0xde>
f01041aa:	e8 f5 f8 ff ff       	call   f0103aa4 <sys_cgetc>
f01041af:	eb 52                	jmp    f0104203 <syscall+0x97>
f01041b1:	e8 ff f8 ff ff       	call   f0103ab5 <sys_getenvid>
f01041b6:	eb 4b                	jmp    f0104203 <syscall+0x97>
f01041b8:	83 ec 0c             	sub    $0xc,%esp
f01041bb:	57                   	push   %edi
f01041bc:	e8 01 f9 ff ff       	call   f0103ac2 <sys_env_destroy>
f01041c1:	e9 82 00 00 00       	jmp    f0104248 <syscall+0xdc>
f01041c6:	e8 5b f9 ff ff       	call   f0103b26 <sys_dump_env>
f01041cb:	eb 36                	jmp    f0104203 <syscall+0x97>
f01041cd:	83 ec 04             	sub    $0x4,%esp
f01041d0:	56                   	push   %esi
f01041d1:	51                   	push   %ecx
f01041d2:	57                   	push   %edi
f01041d3:	e8 0d fb ff ff       	call   f0103ce5 <sys_page_alloc>
f01041d8:	eb 6e                	jmp    f0104248 <syscall+0xdc>
f01041da:	83 ec 0c             	sub    $0xc,%esp
f01041dd:	ff 75 1c             	pushl  0x1c(%ebp)
f01041e0:	ff 75 18             	pushl  0x18(%ebp)
f01041e3:	56                   	push   %esi
f01041e4:	51                   	push   %ecx
f01041e5:	57                   	push   %edi
f01041e6:	e8 46 fc ff ff       	call   f0103e31 <sys_page_map>
f01041eb:	89 c3                	mov    %eax,%ebx
f01041ed:	83 c4 20             	add    $0x20,%esp
f01041f0:	eb 5b                	jmp    f010424d <syscall+0xe1>
f01041f2:	83 ec 08             	sub    $0x8,%esp
f01041f5:	51                   	push   %ecx
f01041f6:	57                   	push   %edi
f01041f7:	e8 3f fd ff ff       	call   f0103f3b <sys_page_unmap>
f01041fc:	eb 4a                	jmp    f0104248 <syscall+0xdc>
f01041fe:	e8 b6 f9 ff ff       	call   f0103bb9 <sys_exofork>
f0104203:	89 c3                	mov    %eax,%ebx
f0104205:	eb 46                	jmp    f010424d <syscall+0xe1>
f0104207:	83 ec 08             	sub    $0x8,%esp
f010420a:	51                   	push   %ecx
f010420b:	57                   	push   %edi
f010420c:	e8 0f fa ff ff       	call   f0103c20 <sys_env_set_status>
f0104211:	eb 35                	jmp    f0104248 <syscall+0xdc>
f0104213:	83 ec 08             	sub    $0x8,%esp
f0104216:	51                   	push   %ecx
f0104217:	57                   	push   %edi
f0104218:	e8 49 fa ff ff       	call   f0103c66 <sys_env_set_trapframe>
f010421d:	eb 29                	jmp    f0104248 <syscall+0xdc>
f010421f:	83 ec 08             	sub    $0x8,%esp
f0104222:	51                   	push   %ecx
f0104223:	57                   	push   %edi
f0104224:	e8 8a fa ff ff       	call   f0103cb3 <sys_env_set_pgfault_upcall>
f0104229:	eb 1d                	jmp    f0104248 <syscall+0xdc>
f010422b:	e8 7e f9 ff ff       	call   f0103bae <sys_yield>
f0104230:	eb 1b                	jmp    f010424d <syscall+0xe1>
f0104232:	ff 75 18             	pushl  0x18(%ebp)
f0104235:	56                   	push   %esi
f0104236:	51                   	push   %ecx
f0104237:	57                   	push   %edi
f0104238:	e8 62 fd ff ff       	call   f0103f9f <sys_ipc_try_send>
f010423d:	eb 09                	jmp    f0104248 <syscall+0xdc>
f010423f:	83 ec 0c             	sub    $0xc,%esp
f0104242:	57                   	push   %edi
f0104243:	e8 8d fe ff ff       	call   f01040d5 <sys_ipc_recv>
f0104248:	89 c3                	mov    %eax,%ebx
f010424a:	83 c4 10             	add    $0x10,%esp
    }
    curenv->env_syscalls++;
f010424d:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0104252:	ff 40 5c             	incl   0x5c(%eax)
    return r;
f0104255:	89 d8                	mov    %ebx,%eax
    //panic("syscall not implemented");
}
f0104257:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010425a:	5b                   	pop    %ebx
f010425b:	5e                   	pop    %esi
f010425c:	5f                   	pop    %edi
f010425d:	c9                   	leave  
f010425e:	c3                   	ret    

f010425f <syscallwrap>:

void syscallwrap(struct SysFrame *sf){
f010425f:	55                   	push   %ebp
f0104260:	89 e5                	mov    %esp,%ebp
f0104262:	57                   	push   %edi
f0104263:	56                   	push   %esi
f0104264:	53                   	push   %ebx
f0104265:	83 ec 14             	sub    $0x14,%esp
f0104268:	8b 5d 08             	mov    0x8(%ebp),%ebx
    //save some register
    curenv->env_tf.tf_regs = sf->tf_regs;
f010426b:	8b 3d c4 fe 1c f0    	mov    0xf01cfec4,%edi
f0104271:	fc                   	cld    
f0104272:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104277:	89 de                	mov    %ebx,%esi
f0104279:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
    curenv->env_tf.tf_ds = sf->sf_ds;
f010427b:	66 8b 53 24          	mov    0x24(%ebx),%dx
f010427f:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0104284:	66 89 50 24          	mov    %dx,0x24(%eax)
    curenv->env_tf.tf_es = sf->sf_es;
f0104288:	66 8b 53 20          	mov    0x20(%ebx),%dx
f010428c:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f0104291:	66 89 50 20          	mov    %dx,0x20(%eax)
    curenv->env_tf.tf_esp = sf->sf_esp;//the return esp of the user stack
f0104295:	8b 53 30             	mov    0x30(%ebx),%edx
f0104298:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f010429d:	89 50 3c             	mov    %edx,0x3c(%eax)
    curenv->env_tf.tf_eip = sf->sf_eip;//the return address in the lib/syscall which on user stack
f01042a0:	8b 53 2c             	mov    0x2c(%ebx),%edx
f01042a3:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f01042a8:	89 50 30             	mov    %edx,0x30(%eax)
    curenv->env_tf.tf_regs.reg_esi = sf->sf_eip;//the restore the return address to the esi
f01042ab:	8b 53 2c             	mov    0x2c(%ebx),%edx
f01042ae:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f01042b3:	89 50 04             	mov    %edx,0x4(%eax)
    curenv->env_tf.tf_eflags = sf->sf_eflags;
f01042b6:	8b 53 28             	mov    0x28(%ebx),%edx
f01042b9:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f01042be:	89 50 38             	mov    %edx,0x38(%eax)
    //cprintf("is the eflags of %d :%d interruptable in syscallwrap? %d\n",curenv->env_id,sf->sf_eflags,(sf->sf_eflags&FL_IF));
    //curenv->env_tf.tf_regs.reg_ecx = sf->sf_esp;
    //curenv->env_tf.tf_regs.reg_edx = sf->sf_eip;
    /*cprintf("the tf's esp is--%x\n",sf->sf_esp);
    cprintf("the tf's eip is--%x\n",sf->sf_eip);
    cprintf("reg_eax = %x\n",sf->tf_regs.reg_eax);
    //curenv->env_tf.tf_esp = tf->tf_regs.reg_ebp;
    //curenv->env_tf.tf_eip = tf->tf_regs.reg_esi; */  
    /*if(sf->tf_regs.reg_eax == SYS_page_map){
    cprintf("reg_edx = %x\n",sf->tf_regs.reg_edx);
    cprintf("reg_ecx = %x\n",sf->tf_regs.reg_ecx); 
    cprintf("reg_ebx = %x\n",sf->tf_regs.reg_ebx);
    cprintf("reg_edi = %x\n",sf->tf_regs.reg_edi);
    cprintf("reg_esi = %x\n",sf->tf_regs.reg_esi); 
    }*/
    //cprintf("eflags store %x\n",curenv->env_tf.tf_eflags);
    curenv->env_tf.tf_padding1 = 1;//use to check whether this use sysenter
f01042c1:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f01042c6:	66 c7 40 22 01 00    	movw   $0x1,0x22(%eax)
    sf->tf_regs.reg_eax = syscall(sf->tf_regs.reg_eax,
f01042cc:	ff 73 04             	pushl  0x4(%ebx)
f01042cf:	ff 33                	pushl  (%ebx)
f01042d1:	ff 73 10             	pushl  0x10(%ebx)
f01042d4:	ff 73 18             	pushl  0x18(%ebx)
f01042d7:	ff 73 14             	pushl  0x14(%ebx)
f01042da:	ff 73 1c             	pushl  0x1c(%ebx)
f01042dd:	e8 8a fe ff ff       	call   f010416c <syscall>
f01042e2:	89 43 1c             	mov    %eax,0x1c(%ebx)
                                  sf->tf_regs.reg_edx,
                                  sf->tf_regs.reg_ecx,
                                  sf->tf_regs.reg_ebx,
                                  sf->tf_regs.reg_edi,
                                  sf->tf_regs.reg_esi);
    curenv->env_tf.tf_padding1 = 0;
f01042e5:	a1 c4 fe 1c f0       	mov    0xf01cfec4,%eax
f01042ea:	66 c7 40 22 00 00    	movw   $0x0,0x22(%eax)
    //curenv->env_tf.tf_regs.reg_eax = sf->tf_regs.reg_eax;
    sf->tf_regs.reg_esi = sf->sf_eip;
f01042f0:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01042f3:	89 43 04             	mov    %eax,0x4(%ebx)
    //cprintf("got here in syscallwrap\n");
    return;
}
f01042f6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01042f9:	5b                   	pop    %ebx
f01042fa:	5e                   	pop    %esi
f01042fb:	5f                   	pop    %edi
f01042fc:	c9                   	leave  
f01042fd:	c3                   	ret    
	...

f0104300 <stab_binsearch>:
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104300:	55                   	push   %ebp
f0104301:	89 e5                	mov    %esp,%ebp
f0104303:	57                   	push   %edi
f0104304:	56                   	push   %esi
f0104305:	53                   	push   %ebx
f0104306:	83 ec 0c             	sub    $0xc,%esp
f0104309:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010430c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010430f:	8b 08                	mov    (%eax),%ecx
f0104311:	8b 55 10             	mov    0x10(%ebp),%edx
f0104314:	8b 12                	mov    (%edx),%edx
f0104316:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f0104319:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	
	while (l <= r) {
f0104320:	39 d1                	cmp    %edx,%ecx
f0104322:	7f 7f                	jg     f01043a3 <stab_binsearch+0xa3>
		int true_m = (l + r) / 2, m = true_m;
f0104324:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
f0104327:	8d 04 0b             	lea    (%ebx,%ecx,1),%eax
f010432a:	89 c2                	mov    %eax,%edx
f010432c:	c1 ea 1f             	shr    $0x1f,%edx
f010432f:	01 d0                	add    %edx,%eax
f0104331:	89 c3                	mov    %eax,%ebx
f0104333:	d1 fb                	sar    %ebx
f0104335:	89 da                	mov    %ebx,%edx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104337:	39 cb                	cmp    %ecx,%ebx
f0104339:	7c 3b                	jl     f0104376 <stab_binsearch+0x76>
f010433b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010433e:	0f b6 44 87 04       	movzbl 0x4(%edi,%eax,4),%eax
f0104343:	3b 45 14             	cmp    0x14(%ebp),%eax
f0104346:	74 12                	je     f010435a <stab_binsearch+0x5a>
			m--;
f0104348:	4a                   	dec    %edx
f0104349:	39 ca                	cmp    %ecx,%edx
f010434b:	7c 29                	jl     f0104376 <stab_binsearch+0x76>
f010434d:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104350:	0f b6 44 87 04       	movzbl 0x4(%edi,%eax,4),%eax
f0104355:	3b 45 14             	cmp    0x14(%ebp),%eax
f0104358:	75 ee                	jne    f0104348 <stab_binsearch+0x48>
		if (m < l) {	// no match in [l, m]
f010435a:	39 ca                	cmp    %ecx,%edx
f010435c:	7c 18                	jl     f0104376 <stab_binsearch+0x76>
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010435e:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)
		if (stabs[m].n_value < addr) {
f0104365:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0104368:	8b 45 18             	mov    0x18(%ebp),%eax
f010436b:	39 44 b7 08          	cmp    %eax,0x8(%edi,%esi,4)
f010436f:	73 0a                	jae    f010437b <stab_binsearch+0x7b>
			*region_left = m;
f0104371:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104374:	89 16                	mov    %edx,(%esi)
			l = true_m + 1;
f0104376:	8d 4b 01             	lea    0x1(%ebx),%ecx
f0104379:	eb 23                	jmp    f010439e <stab_binsearch+0x9e>
		} else if (stabs[m].n_value > addr) {
f010437b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010437e:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104381:	39 5c 87 08          	cmp    %ebx,0x8(%edi,%eax,4)
f0104385:	76 0d                	jbe    f0104394 <stab_binsearch+0x94>
			*region_right = m - 1;
f0104387:	8d 42 ff             	lea    0xffffffff(%edx),%eax
f010438a:	8b 75 10             	mov    0x10(%ebp),%esi
f010438d:	89 06                	mov    %eax,(%esi)
			r = m - 1;
f010438f:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f0104392:	eb 0a                	jmp    f010439e <stab_binsearch+0x9e>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104394:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104397:	89 10                	mov    %edx,(%eax)
			l = m;
f0104399:	89 d1                	mov    %edx,%ecx
			addr++;
f010439b:	ff 45 18             	incl   0x18(%ebp)
f010439e:	3b 4d e8             	cmp    0xffffffe8(%ebp),%ecx
f01043a1:	7e 81                	jle    f0104324 <stab_binsearch+0x24>
		}
	}

	if (!any_matches)
f01043a3:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f01043a7:	75 0d                	jne    f01043b6 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f01043a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043ac:	8b 02                	mov    (%edx),%eax
f01043ae:	48                   	dec    %eax
f01043af:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01043b2:	89 03                	mov    %eax,(%ebx)
f01043b4:	eb 33                	jmp    f01043e9 <stab_binsearch+0xe9>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01043b6:	8b 75 10             	mov    0x10(%ebp),%esi
f01043b9:	8b 0e                	mov    (%esi),%ecx
f01043bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043be:	3b 08                	cmp    (%eax),%ecx
f01043c0:	7e 22                	jle    f01043e4 <stab_binsearch+0xe4>
f01043c2:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01043c5:	0f b6 44 87 04       	movzbl 0x4(%edi,%eax,4),%eax
f01043ca:	3b 45 14             	cmp    0x14(%ebp),%eax
f01043cd:	74 15                	je     f01043e4 <stab_binsearch+0xe4>
f01043cf:	49                   	dec    %ecx
f01043d0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043d3:	3b 0a                	cmp    (%edx),%ecx
f01043d5:	7e 0d                	jle    f01043e4 <stab_binsearch+0xe4>
f01043d7:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01043da:	0f b6 44 87 04       	movzbl 0x4(%edi,%eax,4),%eax
f01043df:	3b 45 14             	cmp    0x14(%ebp),%eax
f01043e2:	75 eb                	jne    f01043cf <stab_binsearch+0xcf>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f01043e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043e7:	89 0b                	mov    %ecx,(%ebx)
	}
}
f01043e9:	83 c4 0c             	add    $0xc,%esp
f01043ec:	5b                   	pop    %ebx
f01043ed:	5e                   	pop    %esi
f01043ee:	5f                   	pop    %edi
f01043ef:	c9                   	leave  
f01043f0:	c3                   	ret    

f01043f1 <debuginfo_eip>:


// debuginfo_eip(addr, info)
//
//	Fill in the 'info' structure with information about the specified
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01043f1:	55                   	push   %ebp
f01043f2:	89 e5                	mov    %esp,%ebp
f01043f4:	57                   	push   %edi
f01043f5:	56                   	push   %esi
f01043f6:	53                   	push   %ebx
f01043f7:	83 ec 2c             	sub    $0x2c,%esp
f01043fa:	8b 75 08             	mov    0x8(%ebp),%esi
f01043fd:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104400:	c7 07 dc 62 10 f0    	movl   $0xf01062dc,(%edi)
	info->eip_line = 0;
f0104406:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010440d:	c7 47 08 dc 62 10 f0 	movl   $0xf01062dc,0x8(%edi)
	info->eip_fn_namelen = 9;
f0104414:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f010441b:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f010441e:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104425:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010442b:	76 1a                	jbe    f0104447 <debuginfo_eip+0x56>
		stabs = __STAB_BEGIN__;
f010442d:	bb 2c 65 10 f0       	mov    $0xf010652c,%ebx
		stab_end = __STAB_END__;
f0104432:	b8 90 12 11 f0       	mov    $0xf0111290,%eax
		stabstr = __STABSTR_BEGIN__;
f0104437:	c7 45 d8 91 12 11 f0 	movl   $0xf0111291,0xffffffd8(%ebp)
		stabstr_end = __STABSTR_END__;
f010443e:	c7 45 d4 94 46 11 f0 	movl   $0xf0114694,0xffffffd4(%ebp)
f0104445:	eb 1d                	jmp    f0104464 <debuginfo_eip+0x73>
	} else {
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f0104447:	8b 1d 00 00 20 00    	mov    0x200000,%ebx
		stab_end = usd->stab_end;
f010444d:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104452:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104458:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
		stabstr_end = usd->stabstr_end;
f010445b:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104461:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104464:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0104467:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
f010446a:	0f 86 fa 00 00 00    	jbe    f010456a <debuginfo_eip+0x179>
f0104470:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0104473:	80 7a ff 00          	cmpb   $0x0,0xffffffff(%edx)
f0104477:	0f 85 ed 00 00 00    	jne    f010456a <debuginfo_eip+0x179>
		return -1;

	// Now we find the right stabs that define the function containing
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010447d:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104484:	89 c2                	mov    %eax,%edx
f0104486:	29 da                	sub    %ebx,%edx
f0104488:	c1 fa 02             	sar    $0x2,%edx
f010448b:	8d 04 92             	lea    (%edx,%edx,4),%eax
f010448e:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0104491:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0104494:	89 c1                	mov    %eax,%ecx
f0104496:	c1 e1 08             	shl    $0x8,%ecx
f0104499:	01 c8                	add    %ecx,%eax
f010449b:	89 c1                	mov    %eax,%ecx
f010449d:	c1 e1 10             	shl    $0x10,%ecx
f01044a0:	01 c8                	add    %ecx,%eax
f01044a2:	8d 44 42 ff          	lea    0xffffffff(%edx,%eax,2),%eax
f01044a6:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01044a9:	83 ec 0c             	sub    $0xc,%esp
f01044ac:	56                   	push   %esi
f01044ad:	6a 64                	push   $0x64
f01044af:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01044b2:	50                   	push   %eax
f01044b3:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f01044b6:	50                   	push   %eax
f01044b7:	53                   	push   %ebx
f01044b8:	e8 43 fe ff ff       	call   f0104300 <stab_binsearch>
	if (lfile == 0)
f01044bd:	83 c4 20             	add    $0x20,%esp
f01044c0:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f01044c4:	0f 84 a0 00 00 00    	je     f010456a <debuginfo_eip+0x179>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01044ca:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01044cd:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
	rfun = rfile;
f01044d0:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01044d3:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01044d6:	83 ec 0c             	sub    $0xc,%esp
f01044d9:	56                   	push   %esi
f01044da:	6a 24                	push   $0x24
f01044dc:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f01044df:	50                   	push   %eax
f01044e0:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
f01044e3:	50                   	push   %eax
f01044e4:	53                   	push   %ebx
f01044e5:	e8 16 fe ff ff       	call   f0104300 <stab_binsearch>

	if (lfun <= rfun) {
f01044ea:	83 c4 20             	add    $0x20,%esp
f01044ed:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01044f0:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f01044f3:	7f 35                	jg     f010452a <debuginfo_eip+0x139>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01044f5:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01044f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01044ff:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f0104502:	2b 45 d8             	sub    0xffffffd8(%ebp),%eax
f0104505:	39 04 13             	cmp    %eax,(%ebx,%edx,1)
f0104508:	73 09                	jae    f0104513 <debuginfo_eip+0x122>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010450a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f010450d:	03 04 13             	add    (%ebx,%edx,1),%eax
f0104510:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104513:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0104516:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104519:	8b 44 83 08          	mov    0x8(%ebx,%eax,4),%eax
f010451d:	89 47 10             	mov    %eax,0x10(%edi)
		addr -= info->eip_fn_addr;
f0104520:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104522:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
		rline = rfun;
f0104525:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0104528:	eb 0c                	jmp    f0104536 <debuginfo_eip+0x145>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010452a:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f010452d:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0104530:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
		rline = rfile;
f0104533:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104536:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104539:	83 ec 08             	sub    $0x8,%esp
f010453c:	6a 3a                	push   $0x3a
f010453e:	ff 77 08             	pushl  0x8(%edi)
f0104541:	e8 d3 07 00 00       	call   f0104d19 <strfind>
f0104546:	2b 47 08             	sub    0x8(%edi),%eax
f0104549:	89 47 0c             	mov    %eax,0xc(%edi)

	
	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010454c:	89 34 24             	mov    %esi,(%esp)
f010454f:	6a 44                	push   $0x44
f0104551:	8d 45 e0             	lea    0xffffffe0(%ebp),%eax
f0104554:	50                   	push   %eax
f0104555:	8d 45 dc             	lea    0xffffffdc(%ebp),%eax
f0104558:	50                   	push   %eax
f0104559:	53                   	push   %ebx
f010455a:	e8 a1 fd ff ff       	call   f0104300 <stab_binsearch>
	if(lline>rline){
f010455f:	83 c4 20             	add    $0x20,%esp
f0104562:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f0104565:	3b 45 e0             	cmp    0xffffffe0(%ebp),%eax
f0104568:	7e 0a                	jle    f0104574 <debuginfo_eip+0x183>
		return -1;
f010456a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010456f:	e9 9b 00 00 00       	jmp    f010460f <debuginfo_eip+0x21e>
	}
	info->eip_line = stabs[lline].n_desc;
f0104574:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f0104577:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010457a:	0f b7 44 83 06       	movzwl 0x6(%ebx,%eax,4),%eax
f010457f:	89 47 04             	mov    %eax,0x4(%edi)
	
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104582:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f0104585:	eb 03                	jmp    f010458a <debuginfo_eip+0x199>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104587:	ff 4d dc             	decl   0xffffffdc(%ebp)
f010458a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f010458d:	39 d0                	cmp    %edx,%eax
f010458f:	7c 1b                	jl     f01045ac <debuginfo_eip+0x1bb>
f0104591:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104594:	c1 e0 02             	shl    $0x2,%eax
f0104597:	80 7c 03 04 84       	cmpb   $0x84,0x4(%ebx,%eax,1)
f010459c:	74 0e                	je     f01045ac <debuginfo_eip+0x1bb>
f010459e:	80 7c 03 04 64       	cmpb   $0x64,0x4(%ebx,%eax,1)
f01045a3:	75 e2                	jne    f0104587 <debuginfo_eip+0x196>
f01045a5:	83 7c 03 08 00       	cmpl   $0x0,0x8(%ebx,%eax,1)
f01045aa:	74 db                	je     f0104587 <debuginfo_eip+0x196>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01045ac:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f01045af:	3b 45 ec             	cmp    0xffffffec(%ebp),%eax
f01045b2:	7c 1d                	jl     f01045d1 <debuginfo_eip+0x1e0>
f01045b4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01045b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01045be:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f01045c1:	2b 45 d8             	sub    0xffffffd8(%ebp),%eax
f01045c4:	39 04 13             	cmp    %eax,(%ebx,%edx,1)
f01045c7:	73 08                	jae    f01045d1 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01045c9:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f01045cc:	03 04 13             	add    (%ebx,%edx,1),%eax
f01045cf:	89 07                	mov    %eax,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01045d1:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01045d4:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f01045d7:	7d 31                	jge    f010460a <debuginfo_eip+0x219>
		for (lline = lfun + 1;
f01045d9:	40                   	inc    %eax
f01045da:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f01045dd:	89 c2                	mov    %eax,%edx
f01045df:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f01045e2:	7d 26                	jge    f010460a <debuginfo_eip+0x219>
f01045e4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01045e7:	80 7c 83 04 a0       	cmpb   $0xa0,0x4(%ebx,%eax,4)
f01045ec:	75 1c                	jne    f010460a <debuginfo_eip+0x219>
f01045ee:	8b 4d e8             	mov    0xffffffe8(%ebp),%ecx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01045f1:	ff 47 14             	incl   0x14(%edi)
f01045f4:	8d 42 01             	lea    0x1(%edx),%eax
f01045f7:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f01045fa:	89 c2                	mov    %eax,%edx
f01045fc:	39 c8                	cmp    %ecx,%eax
f01045fe:	7d 0a                	jge    f010460a <debuginfo_eip+0x219>
f0104600:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104603:	80 7c 83 04 a0       	cmpb   $0xa0,0x4(%ebx,%eax,4)
f0104608:	74 e7                	je     f01045f1 <debuginfo_eip+0x200>
	
	return 0;
f010460a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010460f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0104612:	5b                   	pop    %ebx
f0104613:	5e                   	pop    %esi
f0104614:	5f                   	pop    %edi
f0104615:	c9                   	leave  
f0104616:	c3                   	ret    
	...

f0104618 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104618:	55                   	push   %ebp
f0104619:	89 e5                	mov    %esp,%ebp
f010461b:	57                   	push   %edi
f010461c:	56                   	push   %esi
f010461d:	53                   	push   %ebx
f010461e:	83 ec 0c             	sub    $0xc,%esp
f0104621:	8b 75 10             	mov    0x10(%ebp),%esi
f0104624:	8b 7d 14             	mov    0x14(%ebp),%edi
f0104627:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010462a:	8b 45 18             	mov    0x18(%ebp),%eax
f010462d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104632:	39 d7                	cmp    %edx,%edi
f0104634:	72 39                	jb     f010466f <printnum+0x57>
f0104636:	77 04                	ja     f010463c <printnum+0x24>
f0104638:	39 c6                	cmp    %eax,%esi
f010463a:	72 33                	jb     f010466f <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010463c:	83 ec 04             	sub    $0x4,%esp
f010463f:	ff 75 20             	pushl  0x20(%ebp)
f0104642:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
f0104645:	50                   	push   %eax
f0104646:	ff 75 18             	pushl  0x18(%ebp)
f0104649:	8b 45 18             	mov    0x18(%ebp),%eax
f010464c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104651:	52                   	push   %edx
f0104652:	50                   	push   %eax
f0104653:	57                   	push   %edi
f0104654:	56                   	push   %esi
f0104655:	e8 ce 08 00 00       	call   f0104f28 <__udivdi3>
f010465a:	83 c4 10             	add    $0x10,%esp
f010465d:	52                   	push   %edx
f010465e:	50                   	push   %eax
f010465f:	ff 75 0c             	pushl  0xc(%ebp)
f0104662:	ff 75 08             	pushl  0x8(%ebp)
f0104665:	e8 ae ff ff ff       	call   f0104618 <printnum>
f010466a:	83 c4 20             	add    $0x20,%esp
f010466d:	eb 19                	jmp    f0104688 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010466f:	4b                   	dec    %ebx
f0104670:	85 db                	test   %ebx,%ebx
f0104672:	7e 14                	jle    f0104688 <printnum+0x70>
			putch(padc, putdat);
f0104674:	83 ec 08             	sub    $0x8,%esp
f0104677:	ff 75 0c             	pushl  0xc(%ebp)
f010467a:	ff 75 20             	pushl  0x20(%ebp)
f010467d:	ff 55 08             	call   *0x8(%ebp)
f0104680:	83 c4 10             	add    $0x10,%esp
f0104683:	4b                   	dec    %ebx
f0104684:	85 db                	test   %ebx,%ebx
f0104686:	7f ec                	jg     f0104674 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104688:	83 ec 08             	sub    $0x8,%esp
f010468b:	ff 75 0c             	pushl  0xc(%ebp)
f010468e:	8b 45 18             	mov    0x18(%ebp),%eax
f0104691:	ba 00 00 00 00       	mov    $0x0,%edx
f0104696:	83 ec 04             	sub    $0x4,%esp
f0104699:	52                   	push   %edx
f010469a:	50                   	push   %eax
f010469b:	57                   	push   %edi
f010469c:	56                   	push   %esi
f010469d:	e8 a6 09 00 00       	call   f0105048 <__umoddi3>
f01046a2:	83 c4 14             	add    $0x14,%esp
f01046a5:	0f be 80 79 63 10 f0 	movsbl 0xf0106379(%eax),%eax
f01046ac:	50                   	push   %eax
f01046ad:	ff 55 08             	call   *0x8(%ebp)
}
f01046b0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01046b3:	5b                   	pop    %ebx
f01046b4:	5e                   	pop    %esi
f01046b5:	5f                   	pop    %edi
f01046b6:	c9                   	leave  
f01046b7:	c3                   	ret    

f01046b8 <printcolor>:

static void printcolor(void(*putch)(int, void*), void *putdat, int color,
		int width, char padc) {
f01046b8:	55                   	push   %ebp
f01046b9:	89 e5                	mov    %esp,%ebp
f01046bb:	56                   	push   %esi
f01046bc:	53                   	push   %ebx
f01046bd:	83 ec 18             	sub    $0x18,%esp
f01046c0:	8b 75 08             	mov    0x8(%ebp),%esi
f01046c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01046c6:	8a 45 18             	mov    0x18(%ebp),%al
f01046c9:	88 45 f7             	mov    %al,0xfffffff7(%ebp)
    /* esc[0;colorm
     * : set graphical mode*/
	putch('\033', putdat);
f01046cc:	53                   	push   %ebx
f01046cd:	6a 1b                	push   $0x1b
f01046cf:	ff d6                	call   *%esi
	putch('[', putdat);
f01046d1:	83 c4 08             	add    $0x8,%esp
f01046d4:	53                   	push   %ebx
f01046d5:	6a 5b                	push   $0x5b
f01046d7:	ff d6                	call   *%esi
	putch('0', putdat);
f01046d9:	83 c4 08             	add    $0x8,%esp
f01046dc:	53                   	push   %ebx
f01046dd:	6a 30                	push   $0x30
f01046df:	ff d6                	call   *%esi
	putch(';', putdat);
f01046e1:	83 c4 08             	add    $0x8,%esp
f01046e4:	53                   	push   %ebx
f01046e5:	6a 3b                	push   $0x3b
f01046e7:	ff d6                	call   *%esi
	printnum(putch, putdat, color, 10, width, padc);
f01046e9:	83 c4 0c             	add    $0xc,%esp
f01046ec:	0f be 45 f7          	movsbl 0xfffffff7(%ebp),%eax
f01046f0:	50                   	push   %eax
f01046f1:	ff 75 14             	pushl  0x14(%ebp)
f01046f4:	6a 0a                	push   $0xa
f01046f6:	8b 45 10             	mov    0x10(%ebp),%eax
f01046f9:	99                   	cltd   
f01046fa:	52                   	push   %edx
f01046fb:	50                   	push   %eax
f01046fc:	53                   	push   %ebx
f01046fd:	56                   	push   %esi
f01046fe:	e8 15 ff ff ff       	call   f0104618 <printnum>
	putch('m', putdat);
f0104703:	83 c4 18             	add    $0x18,%esp
f0104706:	53                   	push   %ebx
f0104707:	6a 6d                	push   $0x6d
f0104709:	ff d6                	call   *%esi

}
f010470b:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f010470e:	5b                   	pop    %ebx
f010470f:	5e                   	pop    %esi
f0104710:	c9                   	leave  
f0104711:	c3                   	ret    

f0104712 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag) {
f0104712:	55                   	push   %ebp
f0104713:	89 e5                	mov    %esp,%ebp
f0104715:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104718:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
f010471b:	83 f8 01             	cmp    $0x1,%eax
f010471e:	7e 0f                	jle    f010472f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
f0104720:	8b 01                	mov    (%ecx),%eax
f0104722:	83 c0 08             	add    $0x8,%eax
f0104725:	89 01                	mov    %eax,(%ecx)
f0104727:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
f010472a:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
f010472d:	eb 0f                	jmp    f010473e <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f010472f:	8b 01                	mov    (%ecx),%eax
f0104731:	83 c0 04             	add    $0x4,%eax
f0104734:	89 01                	mov    %eax,(%ecx)
f0104736:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
f0104739:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010473e:	c9                   	leave  
f010473f:	c3                   	ret    

f0104740 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag) {
f0104740:	55                   	push   %ebp
f0104741:	89 e5                	mov    %esp,%ebp
f0104743:	8b 55 08             	mov    0x8(%ebp),%edx
f0104746:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
f0104749:	83 f8 01             	cmp    $0x1,%eax
f010474c:	7e 0f                	jle    f010475d <getint+0x1d>
		return va_arg(*ap, long long);
f010474e:	8b 02                	mov    (%edx),%eax
f0104750:	83 c0 08             	add    $0x8,%eax
f0104753:	89 02                	mov    %eax,(%edx)
f0104755:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
f0104758:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
f010475b:	eb 0b                	jmp    f0104768 <getint+0x28>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
f010475d:	8b 02                	mov    (%edx),%eax
f010475f:	83 c0 04             	add    $0x4,%eax
f0104762:	89 02                	mov    %eax,(%edx)
f0104764:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
f0104767:	99                   	cltd   
}
f0104768:	c9                   	leave  
f0104769:	c3                   	ret    

f010476a <vprintfmt>:

// Main function to format and print a string.
void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void(*putch)(int, void*), void *putdat, const char *fmt,
		va_list ap) {
f010476a:	55                   	push   %ebp
f010476b:	89 e5                	mov    %esp,%ebp
f010476d:	57                   	push   %edi
f010476e:	56                   	push   %esi
f010476f:	53                   	push   %ebx
f0104770:	83 ec 1c             	sub    $0x1c,%esp
f0104773:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104776:	0f b6 13             	movzbl (%ebx),%edx
f0104779:	43                   	inc    %ebx
f010477a:	83 fa 25             	cmp    $0x25,%edx
f010477d:	74 1e                	je     f010479d <vprintfmt+0x33>
			if (ch == '\0')
f010477f:	85 d2                	test   %edx,%edx
f0104781:	0f 84 dc 02 00 00    	je     f0104a63 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
f0104787:	83 ec 08             	sub    $0x8,%esp
f010478a:	ff 75 0c             	pushl  0xc(%ebp)
f010478d:	52                   	push   %edx
f010478e:	ff 55 08             	call   *0x8(%ebp)
f0104791:	83 c4 10             	add    $0x10,%esp
f0104794:	0f b6 13             	movzbl (%ebx),%edx
f0104797:	43                   	inc    %ebx
f0104798:	83 fa 25             	cmp    $0x25,%edx
f010479b:	75 e2                	jne    f010477f <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
f010479d:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
f01047a1:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
f01047a8:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
f01047ad:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
f01047b2:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
		reswitch: switch (ch = *(unsigned char *) fmt++) {
f01047b9:	0f b6 13             	movzbl (%ebx),%edx
f01047bc:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
f01047bf:	43                   	inc    %ebx
f01047c0:	83 f8 55             	cmp    $0x55,%eax
f01047c3:	0f 87 75 02 00 00    	ja     f0104a3e <vprintfmt+0x2d4>
f01047c9:	ff 24 85 c4 63 10 f0 	jmp    *0xf01063c4(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
f01047d0:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
f01047d4:	eb e3                	jmp    f01047b9 <vprintfmt+0x4f>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01047d6:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
f01047da:	eb dd                	jmp    f01047b9 <vprintfmt+0x4f>

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
f01047dc:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
f01047e1:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f01047e4:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
f01047e8:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01047eb:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f01047ee:	83 f8 09             	cmp    $0x9,%eax
f01047f1:	77 27                	ja     f010481a <vprintfmt+0xb0>
f01047f3:	43                   	inc    %ebx
f01047f4:	eb eb                	jmp    f01047e1 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01047f6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01047fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01047fd:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
f0104800:	eb 18                	jmp    f010481a <vprintfmt+0xb0>

		case '.':
			if (width < 0)
f0104802:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104806:	79 b1                	jns    f01047b9 <vprintfmt+0x4f>
				width = 0;
f0104808:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
f010480f:	eb a8                	jmp    f01047b9 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
f0104811:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
f0104818:	eb 9f                	jmp    f01047b9 <vprintfmt+0x4f>

			process_precision: if (width < 0)
f010481a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f010481e:	79 99                	jns    f01047b9 <vprintfmt+0x4f>
				width = precision, precision = -1;
f0104820:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
f0104823:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
f0104828:	eb 8f                	jmp    f01047b9 <vprintfmt+0x4f>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
f010482a:	41                   	inc    %ecx
			goto reswitch;
f010482b:	eb 8c                	jmp    f01047b9 <vprintfmt+0x4f>

			// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010482d:	83 ec 08             	sub    $0x8,%esp
f0104830:	ff 75 0c             	pushl  0xc(%ebp)
f0104833:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104837:	8b 45 14             	mov    0x14(%ebp),%eax
f010483a:	ff 70 fc             	pushl  0xfffffffc(%eax)
f010483d:	e9 c4 01 00 00       	jmp    f0104a06 <vprintfmt+0x29c>
			break;

			// error message
		case 'e':
			err = va_arg(ap, int);
f0104842:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104846:	8b 45 14             	mov    0x14(%ebp),%eax
f0104849:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
f010484c:	85 c0                	test   %eax,%eax
f010484e:	79 02                	jns    f0104852 <vprintfmt+0xe8>
				err = -err;
f0104850:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0104852:	83 f8 08             	cmp    $0x8,%eax
f0104855:	7f 0b                	jg     f0104862 <vprintfmt+0xf8>
f0104857:	8b 3c 85 a0 63 10 f0 	mov    0xf01063a0(,%eax,4),%edi
f010485e:	85 ff                	test   %edi,%edi
f0104860:	75 08                	jne    f010486a <vprintfmt+0x100>
				printfmt(putch, putdat, "error %d", err);
f0104862:	50                   	push   %eax
f0104863:	68 8a 63 10 f0       	push   $0xf010638a
f0104868:	eb 06                	jmp    f0104870 <vprintfmt+0x106>
			else
				printfmt(putch, putdat, "%s", p);
f010486a:	57                   	push   %edi
f010486b:	68 86 5a 10 f0       	push   $0xf0105a86
f0104870:	ff 75 0c             	pushl  0xc(%ebp)
f0104873:	ff 75 08             	pushl  0x8(%ebp)
f0104876:	e8 f0 01 00 00       	call   f0104a6b <printfmt>
f010487b:	e9 89 01 00 00       	jmp    f0104a09 <vprintfmt+0x29f>
			break;

			// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104880:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104884:	8b 45 14             	mov    0x14(%ebp),%eax
f0104887:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
f010488a:	85 ff                	test   %edi,%edi
f010488c:	75 05                	jne    f0104893 <vprintfmt+0x129>
				p = "(null)";
f010488e:	bf 93 63 10 f0       	mov    $0xf0106393,%edi
			if (width > 0 && padc != '-')
f0104893:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104897:	7e 3b                	jle    f01048d4 <vprintfmt+0x16a>
f0104899:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
f010489d:	74 35                	je     f01048d4 <vprintfmt+0x16a>
				for (width -= strnlen(p, precision); width > 0; width--)
f010489f:	83 ec 08             	sub    $0x8,%esp
f01048a2:	56                   	push   %esi
f01048a3:	57                   	push   %edi
f01048a4:	e8 3c 03 00 00       	call   f0104be5 <strnlen>
f01048a9:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
f01048ac:	83 c4 10             	add    $0x10,%esp
f01048af:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f01048b3:	7e 1f                	jle    f01048d4 <vprintfmt+0x16a>
f01048b5:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
f01048b9:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
f01048bc:	83 ec 08             	sub    $0x8,%esp
f01048bf:	ff 75 0c             	pushl  0xc(%ebp)
f01048c2:	ff 75 e4             	pushl  0xffffffe4(%ebp)
f01048c5:	ff 55 08             	call   *0x8(%ebp)
f01048c8:	83 c4 10             	add    $0x10,%esp
f01048cb:	ff 4d f0             	decl   0xfffffff0(%ebp)
f01048ce:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f01048d2:	7f e8                	jg     f01048bc <vprintfmt+0x152>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01048d4:	0f be 17             	movsbl (%edi),%edx
f01048d7:	47                   	inc    %edi
f01048d8:	85 d2                	test   %edx,%edx
f01048da:	74 3e                	je     f010491a <vprintfmt+0x1b0>
f01048dc:	85 f6                	test   %esi,%esi
f01048de:	78 03                	js     f01048e3 <vprintfmt+0x179>
f01048e0:	4e                   	dec    %esi
f01048e1:	78 37                	js     f010491a <vprintfmt+0x1b0>
				if (altflag && (ch < ' ' || ch > '~'))
f01048e3:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f01048e7:	74 12                	je     f01048fb <vprintfmt+0x191>
f01048e9:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
f01048ec:	83 f8 5e             	cmp    $0x5e,%eax
f01048ef:	76 0a                	jbe    f01048fb <vprintfmt+0x191>
					putch('?', putdat);
f01048f1:	83 ec 08             	sub    $0x8,%esp
f01048f4:	ff 75 0c             	pushl  0xc(%ebp)
f01048f7:	6a 3f                	push   $0x3f
f01048f9:	eb 07                	jmp    f0104902 <vprintfmt+0x198>
				else
					putch(ch, putdat);
f01048fb:	83 ec 08             	sub    $0x8,%esp
f01048fe:	ff 75 0c             	pushl  0xc(%ebp)
f0104901:	52                   	push   %edx
f0104902:	ff 55 08             	call   *0x8(%ebp)
f0104905:	83 c4 10             	add    $0x10,%esp
f0104908:	ff 4d f0             	decl   0xfffffff0(%ebp)
f010490b:	0f be 17             	movsbl (%edi),%edx
f010490e:	47                   	inc    %edi
f010490f:	85 d2                	test   %edx,%edx
f0104911:	74 07                	je     f010491a <vprintfmt+0x1b0>
f0104913:	85 f6                	test   %esi,%esi
f0104915:	78 cc                	js     f01048e3 <vprintfmt+0x179>
f0104917:	4e                   	dec    %esi
f0104918:	79 c9                	jns    f01048e3 <vprintfmt+0x179>
			for (; width > 0; width--)
f010491a:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f010491e:	0f 8e 52 fe ff ff    	jle    f0104776 <vprintfmt+0xc>
				putch(' ', putdat);
f0104924:	83 ec 08             	sub    $0x8,%esp
f0104927:	ff 75 0c             	pushl  0xc(%ebp)
f010492a:	6a 20                	push   $0x20
f010492c:	ff 55 08             	call   *0x8(%ebp)
f010492f:	83 c4 10             	add    $0x10,%esp
f0104932:	ff 4d f0             	decl   0xfffffff0(%ebp)
f0104935:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104939:	7f e9                	jg     f0104924 <vprintfmt+0x1ba>
			break;
f010493b:	e9 36 fe ff ff       	jmp    f0104776 <vprintfmt+0xc>

			// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104940:	83 ec 08             	sub    $0x8,%esp
f0104943:	51                   	push   %ecx
f0104944:	8d 45 14             	lea    0x14(%ebp),%eax
f0104947:	50                   	push   %eax
f0104948:	e8 f3 fd ff ff       	call   f0104740 <getint>
f010494d:	89 c6                	mov    %eax,%esi
f010494f:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
f0104951:	83 c4 10             	add    $0x10,%esp
f0104954:	85 d2                	test   %edx,%edx
f0104956:	79 15                	jns    f010496d <vprintfmt+0x203>
				putch('-', putdat);
f0104958:	83 ec 08             	sub    $0x8,%esp
f010495b:	ff 75 0c             	pushl  0xc(%ebp)
f010495e:	6a 2d                	push   $0x2d
f0104960:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104963:	f7 de                	neg    %esi
f0104965:	83 d7 00             	adc    $0x0,%edi
f0104968:	f7 df                	neg    %edi
f010496a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010496d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
f0104972:	eb 70                	jmp    f01049e4 <vprintfmt+0x27a>

			// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104974:	83 ec 08             	sub    $0x8,%esp
f0104977:	51                   	push   %ecx
f0104978:	8d 45 14             	lea    0x14(%ebp),%eax
f010497b:	50                   	push   %eax
f010497c:	e8 91 fd ff ff       	call   f0104712 <getuint>
f0104981:	89 c6                	mov    %eax,%esi
f0104983:	89 d7                	mov    %edx,%edi
			base = 10;
f0104985:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
f010498a:	eb 55                	jmp    f01049e1 <vprintfmt+0x277>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010498c:	83 ec 08             	sub    $0x8,%esp
f010498f:	51                   	push   %ecx
f0104990:	8d 45 14             	lea    0x14(%ebp),%eax
f0104993:	50                   	push   %eax
f0104994:	e8 79 fd ff ff       	call   f0104712 <getuint>
f0104999:	89 c6                	mov    %eax,%esi
f010499b:	89 d7                	mov    %edx,%edi
			/* set the base = 8
			 * the rest is the same with '%x'
			 * */
			base = 8;
f010499d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
f01049a2:	eb 3d                	jmp    f01049e1 <vprintfmt+0x277>
			//break;

			// pointer
		case 'p':
			putch('0', putdat);
f01049a4:	83 ec 08             	sub    $0x8,%esp
f01049a7:	ff 75 0c             	pushl  0xc(%ebp)
f01049aa:	6a 30                	push   $0x30
f01049ac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01049af:	83 c4 08             	add    $0x8,%esp
f01049b2:	ff 75 0c             	pushl  0xc(%ebp)
f01049b5:	6a 78                	push   $0x78
f01049b7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long) (uintptr_t) va_arg(ap, void *);
f01049ba:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01049be:	8b 45 14             	mov    0x14(%ebp),%eax
f01049c1:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
f01049c4:	bf 00 00 00 00       	mov    $0x0,%edi
			base = 16;
f01049c9:	eb 11                	jmp    f01049dc <vprintfmt+0x272>
			goto number;

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01049cb:	83 ec 08             	sub    $0x8,%esp
f01049ce:	51                   	push   %ecx
f01049cf:	8d 45 14             	lea    0x14(%ebp),%eax
f01049d2:	50                   	push   %eax
f01049d3:	e8 3a fd ff ff       	call   f0104712 <getuint>
f01049d8:	89 c6                	mov    %eax,%esi
f01049da:	89 d7                	mov    %edx,%edi
			base = 16;
f01049dc:	ba 10 00 00 00       	mov    $0x10,%edx
f01049e1:	83 c4 10             	add    $0x10,%esp
			number: printnum(putch, putdat, num, base, width, padc);
f01049e4:	83 ec 04             	sub    $0x4,%esp
f01049e7:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
f01049eb:	50                   	push   %eax
f01049ec:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f01049ef:	52                   	push   %edx
f01049f0:	57                   	push   %edi
f01049f1:	56                   	push   %esi
f01049f2:	ff 75 0c             	pushl  0xc(%ebp)
f01049f5:	ff 75 08             	pushl  0x8(%ebp)
f01049f8:	e8 1b fc ff ff       	call   f0104618 <printnum>
			break;
f01049fd:	eb 37                	jmp    f0104a36 <vprintfmt+0x2cc>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
f01049ff:	83 ec 08             	sub    $0x8,%esp
f0104a02:	ff 75 0c             	pushl  0xc(%ebp)
f0104a05:	52                   	push   %edx
f0104a06:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104a09:	83 c4 10             	add    $0x10,%esp
f0104a0c:	e9 65 fd ff ff       	jmp    f0104776 <vprintfmt+0xc>
		case 'n':
			num = getuint(&ap, lflag);
f0104a11:	83 ec 08             	sub    $0x8,%esp
f0104a14:	51                   	push   %ecx
f0104a15:	8d 45 14             	lea    0x14(%ebp),%eax
f0104a18:	50                   	push   %eax
f0104a19:	e8 f4 fc ff ff       	call   f0104712 <getuint>
f0104a1e:	89 c6                	mov    %eax,%esi
			printcolor(putch, putdat, num, width, padc);
f0104a20:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
f0104a24:	89 04 24             	mov    %eax,(%esp)
f0104a27:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0104a2a:	56                   	push   %esi
f0104a2b:	ff 75 0c             	pushl  0xc(%ebp)
f0104a2e:	ff 75 08             	pushl  0x8(%ebp)
f0104a31:	e8 82 fc ff ff       	call   f01046b8 <printcolor>
			break;
f0104a36:	83 c4 20             	add    $0x20,%esp
f0104a39:	e9 38 fd ff ff       	jmp    f0104776 <vprintfmt+0xc>
			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104a3e:	83 ec 08             	sub    $0x8,%esp
f0104a41:	ff 75 0c             	pushl  0xc(%ebp)
f0104a44:	6a 25                	push   $0x25
f0104a46:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104a49:	4b                   	dec    %ebx
f0104a4a:	83 c4 10             	add    $0x10,%esp
f0104a4d:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
f0104a51:	0f 84 1f fd ff ff    	je     f0104776 <vprintfmt+0xc>
f0104a57:	4b                   	dec    %ebx
f0104a58:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
f0104a5c:	75 f9                	jne    f0104a57 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
f0104a5e:	e9 13 fd ff ff       	jmp    f0104776 <vprintfmt+0xc>
		}
	}
}
f0104a63:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0104a66:	5b                   	pop    %ebx
f0104a67:	5e                   	pop    %esi
f0104a68:	5f                   	pop    %edi
f0104a69:	c9                   	leave  
f0104a6a:	c3                   	ret    

f0104a6b <printfmt>:

void printfmt(void(*putch)(int, void*), void *putdat, const char *fmt, ...) {
f0104a6b:	55                   	push   %ebp
f0104a6c:	89 e5                	mov    %esp,%ebp
f0104a6e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104a71:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a74:	50                   	push   %eax
f0104a75:	ff 75 10             	pushl  0x10(%ebp)
f0104a78:	ff 75 0c             	pushl  0xc(%ebp)
f0104a7b:	ff 75 08             	pushl  0x8(%ebp)
f0104a7e:	e8 e7 fc ff ff       	call   f010476a <vprintfmt>
	va_end(ap);
}
f0104a83:	c9                   	leave  
f0104a84:	c3                   	ret    

f0104a85 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b) {
f0104a85:	55                   	push   %ebp
f0104a86:	89 e5                	mov    %esp,%ebp
f0104a88:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f0104a8b:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
f0104a8e:	8b 0a                	mov    (%edx),%ecx
f0104a90:	3b 4a 04             	cmp    0x4(%edx),%ecx
f0104a93:	73 07                	jae    f0104a9c <sprintputch+0x17>
		*b->buf++ = ch;
f0104a95:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a98:	88 01                	mov    %al,(%ecx)
f0104a9a:	ff 02                	incl   (%edx)
}
f0104a9c:	c9                   	leave  
f0104a9d:	c3                   	ret    

f0104a9e <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
f0104a9e:	55                   	push   %ebp
f0104a9f:	89 e5                	mov    %esp,%ebp
f0104aa1:	83 ec 18             	sub    $0x18,%esp
f0104aa4:	8b 55 08             	mov    0x8(%ebp),%edx
f0104aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = { buf, buf + n - 1, 0 };
f0104aaa:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f0104aad:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
f0104ab1:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f0104ab4:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
f0104abb:	85 d2                	test   %edx,%edx
f0104abd:	74 04                	je     f0104ac3 <vsnprintf+0x25>
f0104abf:	85 c9                	test   %ecx,%ecx
f0104ac1:	7f 07                	jg     f0104aca <vsnprintf+0x2c>
		return -E_INVAL;
f0104ac3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ac8:	eb 1d                	jmp    f0104ae7 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*) sprintputch, &b, fmt, ap);
f0104aca:	ff 75 14             	pushl  0x14(%ebp)
f0104acd:	ff 75 10             	pushl  0x10(%ebp)
f0104ad0:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0104ad3:	50                   	push   %eax
f0104ad4:	68 85 4a 10 f0       	push   $0xf0104a85
f0104ad9:	e8 8c fc ff ff       	call   f010476a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104ade:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0104ae1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104ae4:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
}
f0104ae7:	c9                   	leave  
f0104ae8:	c3                   	ret    

f0104ae9 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...) {
f0104ae9:	55                   	push   %ebp
f0104aea:	89 e5                	mov    %esp,%ebp
f0104aec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104aef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104af2:	50                   	push   %eax
f0104af3:	ff 75 10             	pushl  0x10(%ebp)
f0104af6:	ff 75 0c             	pushl  0xc(%ebp)
f0104af9:	ff 75 08             	pushl  0x8(%ebp)
f0104afc:	e8 9d ff ff ff       	call   f0104a9e <vsnprintf>
	va_end(ap);

	return rc;
}
f0104b01:	c9                   	leave  
f0104b02:	c3                   	ret    
	...

f0104b04 <readline>:
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104b04:	55                   	push   %ebp
f0104b05:	89 e5                	mov    %esp,%ebp
f0104b07:	57                   	push   %edi
f0104b08:	56                   	push   %esi
f0104b09:	53                   	push   %ebx
f0104b0a:	83 ec 0c             	sub    $0xc,%esp
f0104b0d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104b10:	85 c0                	test   %eax,%eax
f0104b12:	74 11                	je     f0104b25 <readline+0x21>
		cprintf("%s", prompt);
f0104b14:	83 ec 08             	sub    $0x8,%esp
f0104b17:	50                   	push   %eax
f0104b18:	68 86 5a 10 f0       	push   $0xf0105a86
f0104b1d:	e8 50 e2 ff ff       	call   f0102d72 <cprintf>
f0104b22:	83 c4 10             	add    $0x10,%esp

	i = 0;
f0104b25:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
f0104b2a:	83 ec 0c             	sub    $0xc,%esp
f0104b2d:	6a 00                	push   $0x0
f0104b2f:	e8 4a bb ff ff       	call   f010067e <iscons>
f0104b34:	89 c7                	mov    %eax,%edi
	while (1) {
f0104b36:	83 c4 10             	add    $0x10,%esp
		c = getchar();
f0104b39:	e8 2f bb ff ff       	call   f010066d <getchar>
f0104b3e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104b40:	85 c0                	test   %eax,%eax
f0104b42:	79 15                	jns    f0104b59 <readline+0x55>
			cprintf("read error: %e\n", c);
f0104b44:	83 ec 08             	sub    $0x8,%esp
f0104b47:	50                   	push   %eax
f0104b48:	68 1c 65 10 f0       	push   $0xf010651c
f0104b4d:	e8 20 e2 ff ff       	call   f0102d72 <cprintf>
			return NULL;
f0104b52:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b57:	eb 69                	jmp    f0104bc2 <readline+0xbe>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104b59:	83 f8 1f             	cmp    $0x1f,%eax
f0104b5c:	7e 21                	jle    f0104b7f <readline+0x7b>
f0104b5e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104b64:	7f 19                	jg     f0104b7f <readline+0x7b>
			if (echoing)
f0104b66:	85 ff                	test   %edi,%edi
f0104b68:	74 0c                	je     f0104b76 <readline+0x72>
				cputchar(c);
f0104b6a:	83 ec 0c             	sub    $0xc,%esp
f0104b6d:	50                   	push   %eax
f0104b6e:	e8 ea ba ff ff       	call   f010065d <cputchar>
f0104b73:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104b76:	88 9e 60 07 1d f0    	mov    %bl,0xf01d0760(%esi)
f0104b7c:	46                   	inc    %esi
f0104b7d:	eb ba                	jmp    f0104b39 <readline+0x35>
		} else if (c == '\b' && i > 0) {
f0104b7f:	83 fb 08             	cmp    $0x8,%ebx
f0104b82:	75 18                	jne    f0104b9c <readline+0x98>
f0104b84:	85 f6                	test   %esi,%esi
f0104b86:	7e 14                	jle    f0104b9c <readline+0x98>
			if (echoing)
f0104b88:	85 ff                	test   %edi,%edi
f0104b8a:	74 0d                	je     f0104b99 <readline+0x95>
				cputchar(c);
f0104b8c:	83 ec 0c             	sub    $0xc,%esp
f0104b8f:	6a 08                	push   $0x8
f0104b91:	e8 c7 ba ff ff       	call   f010065d <cputchar>
f0104b96:	83 c4 10             	add    $0x10,%esp
			i--;
f0104b99:	4e                   	dec    %esi
f0104b9a:	eb 9d                	jmp    f0104b39 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104b9c:	83 fb 0a             	cmp    $0xa,%ebx
f0104b9f:	74 05                	je     f0104ba6 <readline+0xa2>
f0104ba1:	83 fb 0d             	cmp    $0xd,%ebx
f0104ba4:	75 93                	jne    f0104b39 <readline+0x35>
			if (echoing)
f0104ba6:	85 ff                	test   %edi,%edi
f0104ba8:	74 0c                	je     f0104bb6 <readline+0xb2>
				cputchar(c);
f0104baa:	83 ec 0c             	sub    $0xc,%esp
f0104bad:	53                   	push   %ebx
f0104bae:	e8 aa ba ff ff       	call   f010065d <cputchar>
f0104bb3:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104bb6:	c6 86 60 07 1d f0 00 	movb   $0x0,0xf01d0760(%esi)
			return buf;
f0104bbd:	b8 60 07 1d f0       	mov    $0xf01d0760,%eax
		}
	}
}
f0104bc2:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0104bc5:	5b                   	pop    %ebx
f0104bc6:	5e                   	pop    %esi
f0104bc7:	5f                   	pop    %edi
f0104bc8:	c9                   	leave  
f0104bc9:	c3                   	ret    
	...

f0104bcc <strlen>:
#define ASM 1

int
strlen(const char *s)
{
f0104bcc:	55                   	push   %ebp
f0104bcd:	89 e5                	mov    %esp,%ebp
f0104bcf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104bd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bd7:	80 3a 00             	cmpb   $0x0,(%edx)
f0104bda:	74 07                	je     f0104be3 <strlen+0x17>
		n++;
f0104bdc:	40                   	inc    %eax
f0104bdd:	42                   	inc    %edx
f0104bde:	80 3a 00             	cmpb   $0x0,(%edx)
f0104be1:	75 f9                	jne    f0104bdc <strlen+0x10>
	return n;
}
f0104be3:	c9                   	leave  
f0104be4:	c3                   	ret    

f0104be5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104be5:	55                   	push   %ebp
f0104be6:	89 e5                	mov    %esp,%ebp
f0104be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104beb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104bee:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bf3:	85 d2                	test   %edx,%edx
f0104bf5:	74 0f                	je     f0104c06 <strnlen+0x21>
f0104bf7:	80 39 00             	cmpb   $0x0,(%ecx)
f0104bfa:	74 0a                	je     f0104c06 <strnlen+0x21>
		n++;
f0104bfc:	40                   	inc    %eax
f0104bfd:	41                   	inc    %ecx
f0104bfe:	4a                   	dec    %edx
f0104bff:	74 05                	je     f0104c06 <strnlen+0x21>
f0104c01:	80 39 00             	cmpb   $0x0,(%ecx)
f0104c04:	75 f6                	jne    f0104bfc <strnlen+0x17>
	return n;
}
f0104c06:	c9                   	leave  
f0104c07:	c3                   	ret    

f0104c08 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104c08:	55                   	push   %ebp
f0104c09:	89 e5                	mov    %esp,%ebp
f0104c0b:	53                   	push   %ebx
f0104c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104c0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
f0104c12:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
f0104c14:	8a 02                	mov    (%edx),%al
f0104c16:	42                   	inc    %edx
f0104c17:	88 01                	mov    %al,(%ecx)
f0104c19:	41                   	inc    %ecx
f0104c1a:	84 c0                	test   %al,%al
f0104c1c:	75 f6                	jne    f0104c14 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104c1e:	89 d8                	mov    %ebx,%eax
f0104c20:	5b                   	pop    %ebx
f0104c21:	c9                   	leave  
f0104c22:	c3                   	ret    

f0104c23 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104c23:	55                   	push   %ebp
f0104c24:	89 e5                	mov    %esp,%ebp
f0104c26:	57                   	push   %edi
f0104c27:	56                   	push   %esi
f0104c28:	53                   	push   %ebx
f0104c29:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c2f:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
f0104c32:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
f0104c34:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c39:	39 f3                	cmp    %esi,%ebx
f0104c3b:	73 10                	jae    f0104c4d <strncpy+0x2a>
		*dst++ = *src;
f0104c3d:	8a 02                	mov    (%edx),%al
f0104c3f:	88 01                	mov    %al,(%ecx)
f0104c41:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0104c42:	80 3a 00             	cmpb   $0x0,(%edx)
f0104c45:	74 01                	je     f0104c48 <strncpy+0x25>
			src++;
f0104c47:	42                   	inc    %edx
f0104c48:	43                   	inc    %ebx
f0104c49:	39 f3                	cmp    %esi,%ebx
f0104c4b:	72 f0                	jb     f0104c3d <strncpy+0x1a>
	}
	return ret;
}
f0104c4d:	89 f8                	mov    %edi,%eax
f0104c4f:	5b                   	pop    %ebx
f0104c50:	5e                   	pop    %esi
f0104c51:	5f                   	pop    %edi
f0104c52:	c9                   	leave  
f0104c53:	c3                   	ret    

f0104c54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104c54:	55                   	push   %ebp
f0104c55:	89 e5                	mov    %esp,%ebp
f0104c57:	56                   	push   %esi
f0104c58:	53                   	push   %ebx
f0104c59:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104c5f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
f0104c62:	89 de                	mov    %ebx,%esi
	if (size > 0) {
f0104c64:	85 d2                	test   %edx,%edx
f0104c66:	74 19                	je     f0104c81 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
f0104c68:	4a                   	dec    %edx
f0104c69:	74 13                	je     f0104c7e <strlcpy+0x2a>
f0104c6b:	80 39 00             	cmpb   $0x0,(%ecx)
f0104c6e:	74 0e                	je     f0104c7e <strlcpy+0x2a>
			*dst++ = *src++;
f0104c70:	8a 01                	mov    (%ecx),%al
f0104c72:	41                   	inc    %ecx
f0104c73:	88 03                	mov    %al,(%ebx)
f0104c75:	43                   	inc    %ebx
f0104c76:	4a                   	dec    %edx
f0104c77:	74 05                	je     f0104c7e <strlcpy+0x2a>
f0104c79:	80 39 00             	cmpb   $0x0,(%ecx)
f0104c7c:	75 f2                	jne    f0104c70 <strlcpy+0x1c>
		*dst = '\0';
f0104c7e:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
f0104c81:	89 d8                	mov    %ebx,%eax
f0104c83:	29 f0                	sub    %esi,%eax
}
f0104c85:	5b                   	pop    %ebx
f0104c86:	5e                   	pop    %esi
f0104c87:	c9                   	leave  
f0104c88:	c3                   	ret    

f0104c89 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104c89:	55                   	push   %ebp
f0104c8a:	89 e5                	mov    %esp,%ebp
f0104c8c:	8b 55 08             	mov    0x8(%ebp),%edx
f0104c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f0104c92:	80 3a 00             	cmpb   $0x0,(%edx)
f0104c95:	74 13                	je     f0104caa <strcmp+0x21>
f0104c97:	8a 02                	mov    (%edx),%al
f0104c99:	3a 01                	cmp    (%ecx),%al
f0104c9b:	75 0d                	jne    f0104caa <strcmp+0x21>
		p++, q++;
f0104c9d:	42                   	inc    %edx
f0104c9e:	41                   	inc    %ecx
f0104c9f:	80 3a 00             	cmpb   $0x0,(%edx)
f0104ca2:	74 06                	je     f0104caa <strcmp+0x21>
f0104ca4:	8a 02                	mov    (%edx),%al
f0104ca6:	3a 01                	cmp    (%ecx),%al
f0104ca8:	74 f3                	je     f0104c9d <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104caa:	0f b6 02             	movzbl (%edx),%eax
f0104cad:	0f b6 11             	movzbl (%ecx),%edx
f0104cb0:	29 d0                	sub    %edx,%eax
}
f0104cb2:	c9                   	leave  
f0104cb3:	c3                   	ret    

f0104cb4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104cb4:	55                   	push   %ebp
f0104cb5:	89 e5                	mov    %esp,%ebp
f0104cb7:	53                   	push   %ebx
f0104cb8:	8b 55 08             	mov    0x8(%ebp),%edx
f0104cbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
f0104cc1:	85 c9                	test   %ecx,%ecx
f0104cc3:	74 1f                	je     f0104ce4 <strncmp+0x30>
f0104cc5:	80 3a 00             	cmpb   $0x0,(%edx)
f0104cc8:	74 16                	je     f0104ce0 <strncmp+0x2c>
f0104cca:	8a 02                	mov    (%edx),%al
f0104ccc:	3a 03                	cmp    (%ebx),%al
f0104cce:	75 10                	jne    f0104ce0 <strncmp+0x2c>
		n--, p++, q++;
f0104cd0:	42                   	inc    %edx
f0104cd1:	43                   	inc    %ebx
f0104cd2:	49                   	dec    %ecx
f0104cd3:	74 0f                	je     f0104ce4 <strncmp+0x30>
f0104cd5:	80 3a 00             	cmpb   $0x0,(%edx)
f0104cd8:	74 06                	je     f0104ce0 <strncmp+0x2c>
f0104cda:	8a 02                	mov    (%edx),%al
f0104cdc:	3a 03                	cmp    (%ebx),%al
f0104cde:	74 f0                	je     f0104cd0 <strncmp+0x1c>
	if (n == 0)
f0104ce0:	85 c9                	test   %ecx,%ecx
f0104ce2:	75 07                	jne    f0104ceb <strncmp+0x37>
		return 0;
f0104ce4:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ce9:	eb 0a                	jmp    f0104cf5 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104ceb:	0f b6 12             	movzbl (%edx),%edx
f0104cee:	0f b6 03             	movzbl (%ebx),%eax
f0104cf1:	29 c2                	sub    %eax,%edx
f0104cf3:	89 d0                	mov    %edx,%eax
}
f0104cf5:	8b 1c 24             	mov    (%esp),%ebx
f0104cf8:	c9                   	leave  
f0104cf9:	c3                   	ret    

f0104cfa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104cfa:	55                   	push   %ebp
f0104cfb:	89 e5                	mov    %esp,%ebp
f0104cfd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d00:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
f0104d03:	80 38 00             	cmpb   $0x0,(%eax)
f0104d06:	74 0a                	je     f0104d12 <strchr+0x18>
		if (*s == c)
f0104d08:	38 10                	cmp    %dl,(%eax)
f0104d0a:	74 0b                	je     f0104d17 <strchr+0x1d>
f0104d0c:	40                   	inc    %eax
f0104d0d:	80 38 00             	cmpb   $0x0,(%eax)
f0104d10:	75 f6                	jne    f0104d08 <strchr+0xe>
			return (char *) s;
	return 0;
f0104d12:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d17:	c9                   	leave  
f0104d18:	c3                   	ret    

f0104d19 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104d19:	55                   	push   %ebp
f0104d1a:	89 e5                	mov    %esp,%ebp
f0104d1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d1f:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
f0104d22:	80 38 00             	cmpb   $0x0,(%eax)
f0104d25:	74 0a                	je     f0104d31 <strfind+0x18>
		if (*s == c)
f0104d27:	38 10                	cmp    %dl,(%eax)
f0104d29:	74 06                	je     f0104d31 <strfind+0x18>
f0104d2b:	40                   	inc    %eax
f0104d2c:	80 38 00             	cmpb   $0x0,(%eax)
f0104d2f:	75 f6                	jne    f0104d27 <strfind+0xe>
			break;
	return (char *) s;
}
f0104d31:	c9                   	leave  
f0104d32:	c3                   	ret    

f0104d33 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104d33:	55                   	push   %ebp
f0104d34:	89 e5                	mov    %esp,%ebp
f0104d36:	57                   	push   %edi
f0104d37:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104d3d:	89 f8                	mov    %edi,%eax
f0104d3f:	85 c9                	test   %ecx,%ecx
f0104d41:	74 40                	je     f0104d83 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104d43:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104d49:	75 30                	jne    f0104d7b <memset+0x48>
f0104d4b:	f6 c1 03             	test   $0x3,%cl
f0104d4e:	75 2b                	jne    f0104d7b <memset+0x48>
		c &= 0xFF;
f0104d50:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104d57:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d5a:	c1 e0 18             	shl    $0x18,%eax
f0104d5d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d60:	c1 e2 10             	shl    $0x10,%edx
f0104d63:	09 d0                	or     %edx,%eax
f0104d65:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d68:	c1 e2 08             	shl    $0x8,%edx
f0104d6b:	09 d0                	or     %edx,%eax
f0104d6d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
f0104d70:	c1 e9 02             	shr    $0x2,%ecx
f0104d73:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d76:	fc                   	cld    
f0104d77:	f3 ab                	repz stos %eax,%es:(%edi)
f0104d79:	eb 06                	jmp    f0104d81 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d7e:	fc                   	cld    
f0104d7f:	f3 aa                	repz stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
f0104d81:	89 f8                	mov    %edi,%eax
}
f0104d83:	8b 3c 24             	mov    (%esp),%edi
f0104d86:	c9                   	leave  
f0104d87:	c3                   	ret    

f0104d88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104d88:	55                   	push   %ebp
f0104d89:	89 e5                	mov    %esp,%ebp
f0104d8b:	57                   	push   %edi
f0104d8c:	56                   	push   %esi
f0104d8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0104d93:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0104d96:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0104d98:	39 c6                	cmp    %eax,%esi
f0104d9a:	73 33                	jae    f0104dcf <memmove+0x47>
f0104d9c:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f0104d9f:	39 c2                	cmp    %eax,%edx
f0104da1:	76 2c                	jbe    f0104dcf <memmove+0x47>
		s += n;
f0104da3:	89 d6                	mov    %edx,%esi
		d += n;
f0104da5:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104da8:	f6 c2 03             	test   $0x3,%dl
f0104dab:	75 1b                	jne    f0104dc8 <memmove+0x40>
f0104dad:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104db3:	75 13                	jne    f0104dc8 <memmove+0x40>
f0104db5:	f6 c1 03             	test   $0x3,%cl
f0104db8:	75 0e                	jne    f0104dc8 <memmove+0x40>
			asm volatile("std; rep movsl\n"
f0104dba:	83 ef 04             	sub    $0x4,%edi
f0104dbd:	83 ee 04             	sub    $0x4,%esi
f0104dc0:	c1 e9 02             	shr    $0x2,%ecx
f0104dc3:	fd                   	std    
f0104dc4:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
f0104dc6:	eb 27                	jmp    f0104def <memmove+0x67>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104dc8:	4f                   	dec    %edi
f0104dc9:	4e                   	dec    %esi
f0104dca:	fd                   	std    
f0104dcb:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
f0104dcd:	eb 20                	jmp    f0104def <memmove+0x67>
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104dcf:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104dd5:	75 15                	jne    f0104dec <memmove+0x64>
f0104dd7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104ddd:	75 0d                	jne    f0104dec <memmove+0x64>
f0104ddf:	f6 c1 03             	test   $0x3,%cl
f0104de2:	75 08                	jne    f0104dec <memmove+0x64>
			asm volatile("cld; rep movsl\n"
f0104de4:	c1 e9 02             	shr    $0x2,%ecx
f0104de7:	fc                   	cld    
f0104de8:	f3 a5                	repz movsl %ds:(%esi),%es:(%edi)
f0104dea:	eb 03                	jmp    f0104def <memmove+0x67>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104dec:	fc                   	cld    
f0104ded:	f3 a4                	repz movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104def:	5e                   	pop    %esi
f0104df0:	5f                   	pop    %edi
f0104df1:	c9                   	leave  
f0104df2:	c3                   	ret    

f0104df3 <memcpy>:

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
f0104df3:	55                   	push   %ebp
f0104df4:	89 e5                	mov    %esp,%ebp
f0104df6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104df9:	ff 75 10             	pushl  0x10(%ebp)
f0104dfc:	ff 75 0c             	pushl  0xc(%ebp)
f0104dff:	ff 75 08             	pushl  0x8(%ebp)
f0104e02:	e8 81 ff ff ff       	call   f0104d88 <memmove>
}
f0104e07:	c9                   	leave  
f0104e08:	c3                   	ret    

f0104e09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104e09:	55                   	push   %ebp
f0104e0a:	89 e5                	mov    %esp,%ebp
f0104e0c:	53                   	push   %ebx
f0104e0d:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8_t *s1 = (const uint8_t *) v1;
f0104e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
f0104e13:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
f0104e16:	89 d0                	mov    %edx,%eax
f0104e18:	4a                   	dec    %edx
f0104e19:	85 c0                	test   %eax,%eax
f0104e1b:	74 1b                	je     f0104e38 <memcmp+0x2f>
		if (*s1 != *s2)
f0104e1d:	8a 01                	mov    (%ecx),%al
f0104e1f:	3a 03                	cmp    (%ebx),%al
f0104e21:	74 0c                	je     f0104e2f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104e23:	0f b6 d0             	movzbl %al,%edx
f0104e26:	0f b6 03             	movzbl (%ebx),%eax
f0104e29:	29 c2                	sub    %eax,%edx
f0104e2b:	89 d0                	mov    %edx,%eax
f0104e2d:	eb 0e                	jmp    f0104e3d <memcmp+0x34>
		s1++, s2++;
f0104e2f:	41                   	inc    %ecx
f0104e30:	43                   	inc    %ebx
f0104e31:	89 d0                	mov    %edx,%eax
f0104e33:	4a                   	dec    %edx
f0104e34:	85 c0                	test   %eax,%eax
f0104e36:	75 e5                	jne    f0104e1d <memcmp+0x14>
	}

	return 0;
f0104e38:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e3d:	5b                   	pop    %ebx
f0104e3e:	c9                   	leave  
f0104e3f:	c3                   	ret    

f0104e40 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104e40:	55                   	push   %ebp
f0104e41:	89 e5                	mov    %esp,%ebp
f0104e43:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104e49:	89 c2                	mov    %eax,%edx
f0104e4b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104e4e:	39 d0                	cmp    %edx,%eax
f0104e50:	73 09                	jae    f0104e5b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104e52:	38 08                	cmp    %cl,(%eax)
f0104e54:	74 05                	je     f0104e5b <memfind+0x1b>
f0104e56:	40                   	inc    %eax
f0104e57:	39 d0                	cmp    %edx,%eax
f0104e59:	72 f7                	jb     f0104e52 <memfind+0x12>
			break;
	return (void *) s;
}
f0104e5b:	c9                   	leave  
f0104e5c:	c3                   	ret    

f0104e5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104e5d:	55                   	push   %ebp
f0104e5e:	89 e5                	mov    %esp,%ebp
f0104e60:	57                   	push   %edi
f0104e61:	56                   	push   %esi
f0104e62:	53                   	push   %ebx
f0104e63:	8b 55 08             	mov    0x8(%ebp),%edx
f0104e66:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
f0104e6c:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
f0104e71:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104e76:	80 3a 20             	cmpb   $0x20,(%edx)
f0104e79:	74 05                	je     f0104e80 <strtol+0x23>
f0104e7b:	80 3a 09             	cmpb   $0x9,(%edx)
f0104e7e:	75 0b                	jne    f0104e8b <strtol+0x2e>
		s++;
f0104e80:	42                   	inc    %edx
f0104e81:	80 3a 20             	cmpb   $0x20,(%edx)
f0104e84:	74 fa                	je     f0104e80 <strtol+0x23>
f0104e86:	80 3a 09             	cmpb   $0x9,(%edx)
f0104e89:	74 f5                	je     f0104e80 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
f0104e8b:	80 3a 2b             	cmpb   $0x2b,(%edx)
f0104e8e:	75 03                	jne    f0104e93 <strtol+0x36>
		s++;
f0104e90:	42                   	inc    %edx
f0104e91:	eb 0b                	jmp    f0104e9e <strtol+0x41>
	else if (*s == '-')
f0104e93:	80 3a 2d             	cmpb   $0x2d,(%edx)
f0104e96:	75 06                	jne    f0104e9e <strtol+0x41>
		s++, neg = 1;
f0104e98:	42                   	inc    %edx
f0104e99:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104e9e:	85 c9                	test   %ecx,%ecx
f0104ea0:	74 05                	je     f0104ea7 <strtol+0x4a>
f0104ea2:	83 f9 10             	cmp    $0x10,%ecx
f0104ea5:	75 15                	jne    f0104ebc <strtol+0x5f>
f0104ea7:	80 3a 30             	cmpb   $0x30,(%edx)
f0104eaa:	75 10                	jne    f0104ebc <strtol+0x5f>
f0104eac:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104eb0:	75 0a                	jne    f0104ebc <strtol+0x5f>
		s += 2, base = 16;
f0104eb2:	83 c2 02             	add    $0x2,%edx
f0104eb5:	b9 10 00 00 00       	mov    $0x10,%ecx
f0104eba:	eb 1a                	jmp    f0104ed6 <strtol+0x79>
	else if (base == 0 && s[0] == '0')
f0104ebc:	85 c9                	test   %ecx,%ecx
f0104ebe:	75 16                	jne    f0104ed6 <strtol+0x79>
f0104ec0:	80 3a 30             	cmpb   $0x30,(%edx)
f0104ec3:	75 08                	jne    f0104ecd <strtol+0x70>
		s++, base = 8;
f0104ec5:	42                   	inc    %edx
f0104ec6:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104ecb:	eb 09                	jmp    f0104ed6 <strtol+0x79>
	else if (base == 0)
f0104ecd:	85 c9                	test   %ecx,%ecx
f0104ecf:	75 05                	jne    f0104ed6 <strtol+0x79>
		base = 10;
f0104ed1:	b9 0a 00 00 00       	mov    $0xa,%ecx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104ed6:	8a 02                	mov    (%edx),%al
f0104ed8:	83 e8 30             	sub    $0x30,%eax
f0104edb:	3c 09                	cmp    $0x9,%al
f0104edd:	77 08                	ja     f0104ee7 <strtol+0x8a>
			dig = *s - '0';
f0104edf:	0f be 02             	movsbl (%edx),%eax
f0104ee2:	83 e8 30             	sub    $0x30,%eax
f0104ee5:	eb 20                	jmp    f0104f07 <strtol+0xaa>
		else if (*s >= 'a' && *s <= 'z')
f0104ee7:	8a 02                	mov    (%edx),%al
f0104ee9:	83 e8 61             	sub    $0x61,%eax
f0104eec:	3c 19                	cmp    $0x19,%al
f0104eee:	77 08                	ja     f0104ef8 <strtol+0x9b>
			dig = *s - 'a' + 10;
f0104ef0:	0f be 02             	movsbl (%edx),%eax
f0104ef3:	83 e8 57             	sub    $0x57,%eax
f0104ef6:	eb 0f                	jmp    f0104f07 <strtol+0xaa>
		else if (*s >= 'A' && *s <= 'Z')
f0104ef8:	8a 02                	mov    (%edx),%al
f0104efa:	83 e8 41             	sub    $0x41,%eax
f0104efd:	3c 19                	cmp    $0x19,%al
f0104eff:	77 12                	ja     f0104f13 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0104f01:	0f be 02             	movsbl (%edx),%eax
f0104f04:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
f0104f07:	39 c8                	cmp    %ecx,%eax
f0104f09:	7d 08                	jge    f0104f13 <strtol+0xb6>
			break;
		s++, val = (val * base) + dig;
f0104f0b:	42                   	inc    %edx
f0104f0c:	0f af d9             	imul   %ecx,%ebx
f0104f0f:	01 c3                	add    %eax,%ebx
f0104f11:	eb c3                	jmp    f0104ed6 <strtol+0x79>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104f13:	85 f6                	test   %esi,%esi
f0104f15:	74 02                	je     f0104f19 <strtol+0xbc>
		*endptr = (char *) s;
f0104f17:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0104f19:	89 d8                	mov    %ebx,%eax
f0104f1b:	85 ff                	test   %edi,%edi
f0104f1d:	74 02                	je     f0104f21 <strtol+0xc4>
f0104f1f:	f7 d8                	neg    %eax
}
f0104f21:	5b                   	pop    %ebx
f0104f22:	5e                   	pop    %esi
f0104f23:	5f                   	pop    %edi
f0104f24:	c9                   	leave  
f0104f25:	c3                   	ret    
	...

f0104f28 <__udivdi3>:
f0104f28:	55                   	push   %ebp
f0104f29:	89 e5                	mov    %esp,%ebp
f0104f2b:	57                   	push   %edi
f0104f2c:	56                   	push   %esi
f0104f2d:	83 ec 20             	sub    $0x20,%esp
f0104f30:	8b 55 14             	mov    0x14(%ebp),%edx
f0104f33:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f36:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104f39:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f3c:	85 d2                	test   %edx,%edx
f0104f3e:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
f0104f41:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0104f48:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
f0104f4f:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f0104f52:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
f0104f55:	89 fe                	mov    %edi,%esi
f0104f57:	75 5b                	jne    f0104fb4 <__udivdi3+0x8c>
f0104f59:	39 f8                	cmp    %edi,%eax
f0104f5b:	76 2b                	jbe    f0104f88 <__udivdi3+0x60>
f0104f5d:	89 fa                	mov    %edi,%edx
f0104f5f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0104f62:	f7 75 dc             	divl   0xffffffdc(%ebp)
f0104f65:	89 c7                	mov    %eax,%edi
f0104f67:	90                   	nop    
f0104f68:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
f0104f6f:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0104f72:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
f0104f75:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f0104f78:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104f7b:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0104f7e:	83 c4 20             	add    $0x20,%esp
f0104f81:	5e                   	pop    %esi
f0104f82:	5f                   	pop    %edi
f0104f83:	c9                   	leave  
f0104f84:	c3                   	ret    
f0104f85:	8d 76 00             	lea    0x0(%esi),%esi
f0104f88:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f0104f8b:	85 c0                	test   %eax,%eax
f0104f8d:	75 0e                	jne    f0104f9d <__udivdi3+0x75>
f0104f8f:	b8 01 00 00 00       	mov    $0x1,%eax
f0104f94:	31 c9                	xor    %ecx,%ecx
f0104f96:	31 d2                	xor    %edx,%edx
f0104f98:	f7 f1                	div    %ecx
f0104f9a:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f0104f9d:	89 f0                	mov    %esi,%eax
f0104f9f:	31 d2                	xor    %edx,%edx
f0104fa1:	f7 75 dc             	divl   0xffffffdc(%ebp)
f0104fa4:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f0104fa7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0104faa:	f7 75 dc             	divl   0xffffffdc(%ebp)
f0104fad:	89 c7                	mov    %eax,%edi
f0104faf:	eb be                	jmp    f0104f6f <__udivdi3+0x47>
f0104fb1:	8d 76 00             	lea    0x0(%esi),%esi
f0104fb4:	39 7d ec             	cmp    %edi,0xffffffec(%ebp)
f0104fb7:	76 07                	jbe    f0104fc0 <__udivdi3+0x98>
f0104fb9:	31 ff                	xor    %edi,%edi
f0104fbb:	eb ab                	jmp    f0104f68 <__udivdi3+0x40>
f0104fbd:	8d 76 00             	lea    0x0(%esi),%esi
f0104fc0:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
f0104fc4:	89 c7                	mov    %eax,%edi
f0104fc6:	83 f7 1f             	xor    $0x1f,%edi
f0104fc9:	75 19                	jne    f0104fe4 <__udivdi3+0xbc>
f0104fcb:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
f0104fce:	77 0a                	ja     f0104fda <__udivdi3+0xb2>
f0104fd0:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f0104fd3:	31 ff                	xor    %edi,%edi
f0104fd5:	39 55 e8             	cmp    %edx,0xffffffe8(%ebp)
f0104fd8:	72 8e                	jb     f0104f68 <__udivdi3+0x40>
f0104fda:	bf 01 00 00 00       	mov    $0x1,%edi
f0104fdf:	eb 87                	jmp    f0104f68 <__udivdi3+0x40>
f0104fe1:	8d 76 00             	lea    0x0(%esi),%esi
f0104fe4:	b8 20 00 00 00       	mov    $0x20,%eax
f0104fe9:	29 f8                	sub    %edi,%eax
f0104feb:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f0104fee:	89 f9                	mov    %edi,%ecx
f0104ff0:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f0104ff3:	d3 e2                	shl    %cl,%edx
f0104ff5:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f0104ff8:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f0104ffb:	d3 e8                	shr    %cl,%eax
f0104ffd:	09 c2                	or     %eax,%edx
f0104fff:	89 f9                	mov    %edi,%ecx
f0105001:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
f0105004:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
f0105007:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f010500a:	89 f2                	mov    %esi,%edx
f010500c:	d3 ea                	shr    %cl,%edx
f010500e:	89 f9                	mov    %edi,%ecx
f0105010:	d3 e6                	shl    %cl,%esi
f0105012:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0105015:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f0105018:	d3 e8                	shr    %cl,%eax
f010501a:	09 c6                	or     %eax,%esi
f010501c:	89 f9                	mov    %edi,%ecx
f010501e:	89 f0                	mov    %esi,%eax
f0105020:	f7 75 ec             	divl   0xffffffec(%ebp)
f0105023:	89 d6                	mov    %edx,%esi
f0105025:	89 c7                	mov    %eax,%edi
f0105027:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
f010502a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f010502d:	f7 e7                	mul    %edi
f010502f:	39 f2                	cmp    %esi,%edx
f0105031:	77 0f                	ja     f0105042 <__udivdi3+0x11a>
f0105033:	0f 85 2f ff ff ff    	jne    f0104f68 <__udivdi3+0x40>
f0105039:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f010503c:	0f 86 26 ff ff ff    	jbe    f0104f68 <__udivdi3+0x40>
f0105042:	4f                   	dec    %edi
f0105043:	e9 20 ff ff ff       	jmp    f0104f68 <__udivdi3+0x40>

f0105048 <__umoddi3>:
f0105048:	55                   	push   %ebp
f0105049:	89 e5                	mov    %esp,%ebp
f010504b:	57                   	push   %edi
f010504c:	56                   	push   %esi
f010504d:	83 ec 30             	sub    $0x30,%esp
f0105050:	8b 55 14             	mov    0x14(%ebp),%edx
f0105053:	8b 75 08             	mov    0x8(%ebp),%esi
f0105056:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105059:	8b 45 10             	mov    0x10(%ebp),%eax
f010505c:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
f010505f:	85 d2                	test   %edx,%edx
f0105061:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
f0105068:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f010506f:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
f0105072:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
f0105075:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f0105078:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
f010507b:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
f010507e:	75 68                	jne    f01050e8 <__umoddi3+0xa0>
f0105080:	39 f8                	cmp    %edi,%eax
f0105082:	76 3c                	jbe    f01050c0 <__umoddi3+0x78>
f0105084:	89 f0                	mov    %esi,%eax
f0105086:	89 fa                	mov    %edi,%edx
f0105088:	f7 75 cc             	divl   0xffffffcc(%ebp)
f010508b:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f010508e:	85 c9                	test   %ecx,%ecx
f0105090:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
f0105093:	74 1b                	je     f01050b0 <__umoddi3+0x68>
f0105095:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0105098:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f010509b:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f01050a2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01050a5:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f01050a8:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f01050ab:	89 10                	mov    %edx,(%eax)
f01050ad:	89 48 04             	mov    %ecx,0x4(%eax)
f01050b0:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01050b3:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01050b6:	83 c4 30             	add    $0x30,%esp
f01050b9:	5e                   	pop    %esi
f01050ba:	5f                   	pop    %edi
f01050bb:	c9                   	leave  
f01050bc:	c3                   	ret    
f01050bd:	8d 76 00             	lea    0x0(%esi),%esi
f01050c0:	8b 75 cc             	mov    0xffffffcc(%ebp),%esi
f01050c3:	85 f6                	test   %esi,%esi
f01050c5:	75 0d                	jne    f01050d4 <__umoddi3+0x8c>
f01050c7:	b8 01 00 00 00       	mov    $0x1,%eax
f01050cc:	31 d2                	xor    %edx,%edx
f01050ce:	f7 75 cc             	divl   0xffffffcc(%ebp)
f01050d1:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
f01050d4:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f01050d7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f01050da:	f7 75 cc             	divl   0xffffffcc(%ebp)
f01050dd:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f01050e0:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f01050e3:	f7 75 cc             	divl   0xffffffcc(%ebp)
f01050e6:	eb a3                	jmp    f010508b <__umoddi3+0x43>
f01050e8:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f01050eb:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
f01050ee:	76 14                	jbe    f0105104 <__umoddi3+0xbc>
f01050f0:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
f01050f3:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f01050f6:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f01050f9:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f01050fc:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f01050ff:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f0105102:	eb ac                	jmp    f01050b0 <__umoddi3+0x68>
f0105104:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
f0105108:	89 c6                	mov    %eax,%esi
f010510a:	83 f6 1f             	xor    $0x1f,%esi
f010510d:	75 4d                	jne    f010515c <__umoddi3+0x114>
f010510f:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f0105112:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
f0105115:	77 08                	ja     f010511f <__umoddi3+0xd7>
f0105117:	8b 4d cc             	mov    0xffffffcc(%ebp),%ecx
f010511a:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
f010511d:	72 12                	jb     f0105131 <__umoddi3+0xe9>
f010511f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0105122:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0105125:	2b 45 cc             	sub    0xffffffcc(%ebp),%eax
f0105128:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
f010512b:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f010512e:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f0105131:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f0105134:	85 d2                	test   %edx,%edx
f0105136:	0f 84 74 ff ff ff    	je     f01050b0 <__umoddi3+0x68>
f010513c:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f010513f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0105142:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f0105145:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f0105148:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f010514b:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f010514e:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0105151:	89 01                	mov    %eax,(%ecx)
f0105153:	89 51 04             	mov    %edx,0x4(%ecx)
f0105156:	e9 55 ff ff ff       	jmp    f01050b0 <__umoddi3+0x68>
f010515b:	90                   	nop    
f010515c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105161:	29 f0                	sub    %esi,%eax
f0105163:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f0105166:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f0105169:	89 f1                	mov    %esi,%ecx
f010516b:	d3 e2                	shl    %cl,%edx
f010516d:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f0105170:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f0105173:	d3 e8                	shr    %cl,%eax
f0105175:	09 c2                	or     %eax,%edx
f0105177:	89 f1                	mov    %esi,%ecx
f0105179:	d3 65 cc             	shll   %cl,0xffffffcc(%ebp)
f010517c:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f010517f:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f0105182:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0105185:	d3 ea                	shr    %cl,%edx
f0105187:	8b 7d d4             	mov    0xffffffd4(%ebp),%edi
f010518a:	89 f1                	mov    %esi,%ecx
f010518c:	d3 e7                	shl    %cl,%edi
f010518e:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0105191:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f0105194:	d3 e8                	shr    %cl,%eax
f0105196:	09 c7                	or     %eax,%edi
f0105198:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
f010519b:	89 f8                	mov    %edi,%eax
f010519d:	89 f1                	mov    %esi,%ecx
f010519f:	f7 75 dc             	divl   0xffffffdc(%ebp)
f01051a2:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f01051a5:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
f01051a8:	f7 65 cc             	mull   0xffffffcc(%ebp)
f01051ab:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
f01051ae:	89 c7                	mov    %eax,%edi
f01051b0:	77 3f                	ja     f01051f1 <__umoddi3+0x1a9>
f01051b2:	74 38                	je     f01051ec <__umoddi3+0x1a4>
f01051b4:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01051b7:	85 c0                	test   %eax,%eax
f01051b9:	0f 84 f1 fe ff ff    	je     f01050b0 <__umoddi3+0x68>
f01051bf:	8b 4d d4             	mov    0xffffffd4(%ebp),%ecx
f01051c2:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f01051c5:	29 f8                	sub    %edi,%eax
f01051c7:	19 d1                	sbb    %edx,%ecx
f01051c9:	89 4d d4             	mov    %ecx,0xffffffd4(%ebp)
f01051cc:	89 ca                	mov    %ecx,%edx
f01051ce:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f01051d1:	d3 e2                	shl    %cl,%edx
f01051d3:	89 f1                	mov    %esi,%ecx
f01051d5:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f01051d8:	d3 e8                	shr    %cl,%eax
f01051da:	09 c2                	or     %eax,%edx
f01051dc:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f01051df:	d3 e8                	shr    %cl,%eax
f01051e1:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
f01051e4:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f01051e7:	e9 b6 fe ff ff       	jmp    f01050a2 <__umoddi3+0x5a>
f01051ec:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
f01051ef:	76 c3                	jbe    f01051b4 <__umoddi3+0x16c>
f01051f1:	2b 7d cc             	sub    0xffffffcc(%ebp),%edi
f01051f4:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
f01051f7:	eb bb                	jmp    f01051b4 <__umoddi3+0x16c>
f01051f9:	90                   	nop    
f01051fa:	90                   	nop    
f01051fb:	90                   	nop    
