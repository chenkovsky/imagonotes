	.file "test/queens.tig"
	.text
L16:
	.string "\n\0"

L15:
	.string "\n\0"

L11:
	.string " .\0"

L10:
	.string " O\0"

.globl	L0
L0:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$56, %esp
L38:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	%ebp, %ebx
	addl	$-48, %ebx
	movl	%ebx, -56(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	%eax, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	-56(%ebp), %ecx
	movl	%ebx, (%ecx)
L2:
	movl	-24(%ebp), %ebx
	movl	-56(%ebp), %ecx
	movl	(%ecx), %ecx
	cmpl	%ecx, %ebx
	jle	L3
L4:
L5:
	pushl	%ecx
	pushl	%edx
	movl	$L16, %ecx
	pushl	 %ecx
	movl	$139192512, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	jmp	L37
L3:
	movl	$0, %ebx
	movl	%ebx, -28(%ebp)
	movl	%ebp, %ebx
	addl	$-44, %ebx
	movl	%ebx, -52(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	%eax, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	-52(%ebp), %ecx
	movl	%ebx, (%ecx)
L6:
	movl	-28(%ebp), %ebx
	movl	-52(%ebp), %ecx
	movl	(%ecx), %ecx
	cmpl	%ecx, %ebx
	jle	L7
L8:
L9:
	pushl	%ecx
	pushl	%edx
	movl	$L15, %ecx
	pushl	 %ecx
	movl	$139192512, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -24(%ebp)
	jmp	L2
L7:
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-32(%eax), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	imull	$4, %ebx
	movl	 %ebx, %ebx
	popl	%esi
	addl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	(%ebx), %ebx
	movl	-28(%ebp), %ecx
	cmpl	%ecx, %ebx
	je	L13
L14:
	movl	$L11, %ebx
	movl	%ebx, -36(%ebp)
	movl	-36(%ebp), %ebx
	movl	%ebx, -32(%ebp)
L12:
	pushl	%ecx
	pushl	%edx
	movl	-32(%ebp), %ecx
	pushl	 %ecx
	movl	$139192512, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -28(%ebp)
	jmp	L6
L13:
	movl	$L10, %ebx
	movl	%ebx, -40(%ebp)
	movl	-40(%ebp), %ebx
	movl	%ebx, -32(%ebp)
	jmp	L12
L37:
	addl	$56, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	L1
L1:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$100, %esp
L40:
	movl	12(%ebp), %ebx
	movl	%ebx, -100(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-100(%ebp), %ebx
	movl	-24(%eax), %ecx
	cmpl	%ecx, %ebx
	je	L35
L36:
	movl	%ebp, %ebx
	addl	$-68, %ebx
	movl	%ebx, -92(%ebp)
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	%ebp, %ebx
	addl	$-60, %ebx
	movl	%ebx, -88(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	%eax, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	-88(%ebp), %ecx
	movl	%ebx, (%ecx)
L17:
	movl	-24(%ebp), %ebx
	movl	-88(%ebp), %ecx
	movl	(%ecx), %ecx
	cmpl	%ecx, %ebx
	jle	L18
L19:
L20:
	movl	$0, %ebx
	movl	-92(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-92(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -64(%ebp)
L34:
	movl	-64(%ebp), %eax
	jmp	L39
L35:
	movl	%ebp, %ebx
	addl	$-72, %ebx
	movl	%ebx, -96(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$139199032, %ecx
	pushl	 %ecx
	call	L0
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-96(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-96(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -64(%ebp)
	jmp	L34
L18:
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-28(%eax), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	imull	$4, %ebx
	movl	 %ebx, %ebx
	popl	%esi
	addl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	(%ebx), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	je	L22
L23:
	movl	$0, %ebx
	movl	%ebx, -32(%ebp)
	movl	-32(%ebp), %ebx
	movl	%ebx, -28(%ebp)
L21:
	movl	-28(%ebp), %ecx
L27:
	movl	%ebp, %ebx
	addl	$-48, %ebx
	movl	%ebx, -80(%ebp)
	movl	$1, %edx
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-40(%eax), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	$4, %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	addl	$7, %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	12(%ebp), %ebx
	movl	 %ebx, %ebx
	popl	%esi
	subl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	 %ebx, %ebx
	popl	%esi
	imull	 %ebx, %esi
	movl	 %esi, %ebx
	movl	 %ebx, %ebx
	popl	%esi
	addl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	(%ebx), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	je	L29
L30:
	xorl	%edx, %edx
L29:
	movl	-80(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-80(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -40(%ebp)
L26:
	movl	-40(%ebp), %ecx
L32:
	movl	%ebp, %ebx
	addl	$-56, %ebx
	movl	%ebx, -76(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	$1, %ebx
	movl	-28(%eax), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	%ebp, %ecx
	addl	$-24, %ecx
	movl	(%ecx), %ecx
	imull	$4, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	$1, %ebx
	movl	-36(%eax), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	12(%ebp), %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	$1, %ebx
	movl	-40(%eax), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	%ebp, %ecx
	addl	$-24, %ecx
	movl	(%ecx), %ecx
	addl	$7, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	12(%ebp), %ecx
	movl	 %ecx, %ecx
	popl	%esi
	subl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-24(%ebp), %ebx
	movl	-32(%eax), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	%ebp, %ecx
	addl	$12, %ecx
	movl	(%ecx), %ecx
	imull	$4, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	%ebp, %ecx
	addl	$12, %ecx
	movl	(%ecx), %ecx
	addl	$1, %ecx
	pushl	 %ecx
	movl	$139199032, %ecx
	pushl	 %ecx
	call	L1
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	$0, %ebx
	movl	-28(%eax), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	%ebp, %ecx
	addl	$-24, %ecx
	movl	(%ecx), %ecx
	imull	$4, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	$0, %ebx
	movl	-36(%eax), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	12(%ebp), %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	$0, %ebx
	movl	-40(%eax), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	%ebp, %ecx
	addl	$-24, %ecx
	movl	(%ecx), %ecx
	addl	$7, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	12(%ebp), %ecx
	movl	 %ecx, %ecx
	popl	%esi
	subl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	movl	$0, %ebx
	movl	-76(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-76(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -52(%ebp)
L31:
	movl	-52(%ebp), %ecx
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -24(%ebp)
	jmp	L17
L22:
	movl	%ebp, %ebx
	addl	$-36, %ebx
	movl	%ebx, -84(%ebp)
	movl	$1, %edx
	pushl	%ecx
	pushl	%edx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-36(%eax), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	$4, %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	-24(%ebp), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	12(%ebp), %ebx
	movl	 %ebx, %ebx
	popl	%esi
	addl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	 %ebx, %ebx
	popl	%esi
	imull	 %ebx, %esi
	movl	 %esi, %ebx
	movl	 %ebx, %ebx
	popl	%esi
	addl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	(%ebx), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	je	L24
L25:
	xorl	%edx, %edx
L24:
	movl	-84(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-84(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -28(%ebp)
	jmp	L21
L28:
	movl	$0, %ebx
	movl	%ebx, -44(%ebp)
	movl	-44(%ebp), %ebx
	movl	%ebx, -40(%ebp)
	jmp	L26
L33:
	jmp	L31
L39:
	addl	$100, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	tigermain
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$56, %esp
L42:
	movl	$8, %ebx
	movl	%ebx, -24(%ebp)
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -56(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	-24(%ebp), %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-56(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -52(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	-24(%ebp), %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-52(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	%ebp, %ebx
	addl	$-36, %ebx
	movl	%ebx, -48(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$1, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	subl	 %ecx, %esi
	movl	 %esi, %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-48(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	%ebp, %ebx
	addl	$-40, %ebx
	movl	%ebx, -44(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$1, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	subl	 %ecx, %esi
	movl	 %esi, %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-44(%ebp), %ecx
	movl	%eax, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	$139187296, %ecx
	pushl	 %ecx
	call	L1
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	jmp	L41
L41:
	addl	$56, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

