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
	subl	$48, %esp
L38:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	(%ebp), %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	%ebx, -48(%ebp)
L2:
	movl	-24(%ebp), %ebx
	movl	-48(%ebp), %ecx
	cmpl	%ecx, %ebx
	jle	L3
L4:
L5:
	pushl	%ecx
	pushl	%edx
	movl	$L16, %ecx
	pushl	 %ecx
	call	print
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	jmp	L37
L3:
	movl	$0, %ebx
	movl	%ebx, -28(%ebp)
	movl	(%ebp), %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	%ebx, -44(%ebp)
L6:
	movl	-28(%ebp), %ebx
	movl	-44(%ebp), %ecx
	cmpl	%ecx, %ebx
	jle	L7
L8:
L9:
	pushl	%ecx
	pushl	%edx
	movl	$L15, %ecx
	pushl	 %ecx
	call	print
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -24(%ebp)
	jmp	L2
L7:
	movl	(%ebp), %ebx
	movl	-32(%ebx), %ebx
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
	call	print
	addl	$4, %esp
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
	addl	$48, %esp
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
	subl	$92, %esp
L40:
	movl	8(%ebp), %ebx
	movl	(%ebp), %ecx
	movl	-24(%ecx), %ecx
	cmpl	%ecx, %ebx
	je	L35
L36:
	movl	%ebp, %ebx
	addl	$-68, %ebx
	movl	%ebx, -88(%ebp)
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	(%ebp), %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	%ebx, -60(%ebp)
L17:
	movl	-24(%ebp), %ebx
	movl	-60(%ebp), %ecx
	cmpl	%ecx, %ebx
	jle	L18
L19:
L20:
	movl	$0, %ebx
	movl	-88(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-88(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -64(%ebp)
L34:
	movl	-64(%ebp), %eax
	jmp	L39
L35:
	movl	%ebp, %ebx
	addl	$-72, %ebx
	movl	%ebx, -92(%ebp)
	pushl	%ecx
	pushl	%edx
	call	L0
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-92(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-92(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -64(%ebp)
	jmp	L34
L18:
	movl	(%ebp), %ebx
	movl	-28(%ebx), %ebx
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
	movl	(%ebp), %ebx
	movl	-40(%ebx), %ebx
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
	movl	8(%ebp), %ebx
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
	movl	$1, %ebx
	movl	(%ebp), %ecx
	movl	-28(%ecx), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	%ebp, %ecx
	addl	$-24, %ecx
	movl	(%ecx), %ecx
	imull	$4, %ecx
	movl	 %ecx, %ecx
	pop