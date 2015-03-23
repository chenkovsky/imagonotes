	.file "test/tbi.tig"
	.text
L15:
	.string "\n\0"

L14:
	.string "\n\0"

L10:
	.string "y\0"

L9:
	.string "x\0"

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
L17:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	%ebp, %ebx
	addl	$-48, %ebx
	movl	%ebx, -56(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$152440024, %ecx
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
L1:
	movl	-24(%ebp), %ebx
	movl	-56(%ebp), %ecx
	movl	(%ecx), %ecx
	cmpl	%ecx, %ebx
	jle	L2
L3:
L4:
	pushl	%ecx
	pushl	%edx
	movl	$L15, %ecx
	pushl	 %ecx
	movl	$152442288, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	jmp	L16
L2:
	movl	$0, %ebx
	movl	%ebx, -28(%ebp)
	movl	%ebp, %ebx
	addl	$-44, %ebx
	movl	%ebx, -52(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$152440024, %ecx
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
L5:
	movl	-28(%ebp), %ebx
	movl	-52(%ebp), %ecx
	movl	(%ecx), %ecx
	cmpl	%ecx, %ebx
	jle	L6
L7:
L8:
	pushl	%ecx
	pushl	%edx
	movl	$L14, %ecx
	pushl	 %ecx
	movl	$152442288, %ecx
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
	jmp	L1
L6:
	movl	-24(%ebp), %ebx
	movl	-28(%ebp), %ecx
	cmpl	%ecx, %ebx
	jg	L12
L13:
	movl	$L10, %ebx
	movl	%ebx, -36(%ebp)
	movl	-36(%ebp), %ebx
	movl	%ebx, -32(%ebp)
L11:
	pushl	%ecx
	pushl	%edx
	movl	-32(%ebp), %ecx
	pushl	 %ecx
	movl	$152442288, %ecx
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
	jmp	L5
L12:
	movl	$L9, %ebx
	movl	%ebx, -40(%ebp)
	movl	-40(%ebp), %ebx
	movl	%ebx, -32(%ebp)
	jmp	L11
L16:
	addl	$56, %esp
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
	subl	$24, %esp
L19:
	movl	$8, %ebx
	movl	%ebx, -24(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$152440024, %ecx
	pushl	 %ecx
	call	L0
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	jmp	L18
L18:
	addl	$24, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

