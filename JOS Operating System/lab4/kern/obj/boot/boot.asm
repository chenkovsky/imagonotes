
obj/boot/boot.out：     文件格式 elf32-i386

反汇编 .text 节：

00007c00 <start>:

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:

  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64                   	fs
    7c22:	7c 0f                	jl     7c33 <protcseg+0x1>
  movl    %cr0, %eax
    7c24:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c2d:	ea 32 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c32

00007c32 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c32:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c36:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c38:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3a:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c3c:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c3e:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c45:	e8 22 00 00 00       	call   7c6c <bootmain>

00007c4a <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
    7c69:	00 90 90 55 89 e5    	add    %dl,0xe5895590(%eax)

00007c6c <bootmain>:
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
    7c6c:	55                   	push   %ebp
    7c6d:	89 e5                	mov    %esp,%ebp
    7c6f:	56                   	push   %esi
    7c70:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7c71:	6a 00                	push   $0x0
    7c73:	68 00 10 00 00       	push   $0x1000
    7c78:	68 00 00 01 00       	push   $0x10000
    7c7d:	e8 65 00 00 00       	call   7ce7 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7c82:	83 c4 0c             	add    $0xc,%esp
    7c85:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7c8c:	45 4c 46 
    7c8f:	75 41                	jne    7cd2 <bootmain+0x66>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7c91:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
	eph = ph + ELFHDR->e_phnum;
    7c97:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7c9e:	81 c3 00 00 01 00    	add    $0x10000,%ebx
    7ca4:	c1 e0 05             	shl    $0x5,%eax
    7ca7:	8d 34 18             	lea    (%eax,%ebx,1),%esi
	for (; ph < eph; ph++)
    7caa:	39 f3                	cmp    %esi,%ebx
    7cac:	73 18                	jae    7cc6 <bootmain+0x5a>
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);
    7cae:	ff 73 04             	pushl  0x4(%ebx)
    7cb1:	ff 73 14             	pushl  0x14(%ebx)
    7cb4:	ff 73 08             	pushl  0x8(%ebx)
    7cb7:	83 c3 20             	add    $0x20,%ebx
    7cba:	e8 28 00 00 00       	call   7ce7 <readseg>
    7cbf:	83 c4 0c             	add    $0xc,%esp
    7cc2:	39 f3                	cmp    %esi,%ebx
    7cc4:	72 e8                	jb     7cae <bootmain+0x42>

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry & 0xFFFFFF))();
    7cc6:	a1 18 00 01 00       	mov    0x10018,%eax
    7ccb:	25 ff ff ff 00       	and    $0xffffff,%eax
    7cd0:	ff d0                	call   *%eax
}

static __inline void
outw(int port, uint16_t data)
{
    7cd2:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7cd7:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7cdc:	66 ef                	out    %ax,(%dx)
    7cde:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7ce3:	66 ef                	out    %ax,(%dx)

bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
    7ce5:	eb fe                	jmp    7ce5 <bootmain+0x79>

00007ce7 <readseg>:
		/* do nothing */;
}

// Read 'count' bytes at 'offset' from kernel into virtual address 'va'.
// Might copy more than asked
void
readseg(uint32_t va, uint32_t count, uint32_t offset)
{
    7ce7:	55                   	push   %ebp
    7ce8:	89 e5                	mov    %esp,%ebp
    7cea:	57                   	push   %edi
    7ceb:	56                   	push   %esi
    7cec:	53                   	push   %ebx
	uint32_t end_va;

	va &= 0xFFFFFF;
    7ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7cf0:	81 e3 ff ff ff 00    	and    $0xffffff,%ebx
	end_va = va + count;
    7cf6:	89 df                	mov    %ebx,%edi
    7cf8:	8b 45 10             	mov    0x10(%ebp),%eax
    7cfb:	03 7d 0c             	add    0xc(%ebp),%edi
	
	// round down to sector boundary
	va &= ~(SECTSIZE - 1);
    7cfe:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7d04:	c1 e8 09             	shr    $0x9,%eax

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
    7d07:	39 fb                	cmp    %edi,%ebx
    7d09:	8d 70 01             	lea    0x1(%eax),%esi
    7d0c:	73 14                	jae    7d22 <readseg+0x3b>
		readsect((uint8_t*) va, offset);
    7d0e:	56                   	push   %esi
    7d0f:	53                   	push   %ebx
		va += SECTSIZE;
    7d10:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d16:	e8 24 00 00 00       	call   7d3f <readsect>
		offset++;
    7d1b:	46                   	inc    %esi
    7d1c:	58                   	pop    %eax
    7d1d:	39 fb                	cmp    %edi,%ebx
    7d1f:	5a                   	pop    %edx
    7d20:	72 ec                	jb     7d0e <readseg+0x27>
	}
}
    7d22:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
    7d25:	5b                   	pop    %ebx
    7d26:	5e                   	pop    %esi
    7d27:	5f                   	pop    %edi
    7d28:	c9                   	leave  
    7d29:	c3                   	ret    

00007d2a <waitdisk>:

void
waitdisk(void)
{
    7d2a:	55                   	push   %ebp
    7d2b:	89 e5                	mov    %esp,%ebp
}

static __inline uint8_t
inb(int port)
{
    7d2d:	ba f7 01 00 00       	mov    $0x1f7,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7d32:	ec                   	in     (%dx),%al
    7d33:	25 c0 00 00 00       	and    $0xc0,%eax
    7d38:	83 f8 40             	cmp    $0x40,%eax
    7d3b:	75 f0                	jne    7d2d <waitdisk+0x3>
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
		/* do nothing */;
}
    7d3d:	c9                   	leave  
    7d3e:	c3                   	ret    

00007d3f <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7d3f:	55                   	push   %ebp
    7d40:	89 e5                	mov    %esp,%ebp
    7d42:	57                   	push   %edi
    7d43:	53                   	push   %ebx
    7d44:	8b 7d 08             	mov    0x8(%ebp),%edi
    7d47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// wait for disk to be ready
	waitdisk();
    7d4a:	e8 db ff ff ff       	call   7d2a <waitdisk>
}

static __inline void
outb(int port, uint8_t data)
{
    7d4f:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7d54:	b0 01                	mov    $0x1,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7d56:	ee                   	out    %al,(%dx)
    7d57:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7d5c:	88 d8                	mov    %bl,%al
    7d5e:	ee                   	out    %al,(%dx)
    7d5f:	89 d8                	mov    %ebx,%eax
    7d61:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7d66:	c1 e8 08             	shr    $0x8,%eax
    7d69:	ee                   	out    %al,(%dx)
    7d6a:	89 d8                	mov    %ebx,%eax
    7d6c:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7d71:	c1 e8 10             	shr    $0x10,%eax
    7d74:	ee                   	out    %al,(%dx)
    7d75:	c1 eb 18             	shr    $0x18,%ebx
    7d78:	83 cb e0             	or     $0xffffffe0,%ebx
    7d7b:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7d80:	88 d8                	mov    %bl,%al
    7d82:	ee                   	out    %al,(%dx)
    7d83:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7d88:	b0 20                	mov    $0x20,%al
    7d8a:	ee                   	out    %al,(%dx)

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7d8b:	e8 9a ff ff ff       	call   7d2a <waitdisk>
}

static __inline void
insl(int port, void *addr, int cnt)
{
    7d90:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d95:	b9 80 00 00 00       	mov    $0x80,%ecx
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7d9a:	fc                   	cld    
    7d9b:	f2 6d                	repnz insl (%dx),%es:(%edi)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7d9d:	5b                   	pop    %ebx
    7d9e:	5f                   	pop    %edi
    7d9f:	c9                   	leave  
    7da0:	c3                   	ret    
