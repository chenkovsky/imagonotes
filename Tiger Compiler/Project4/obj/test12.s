	.file "test/test12.tig"
	.text
.globl	tigermain
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$32, %esp
L5:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	$0, %ebx
	movl	%ebx, -28(%ebp)
	movl	$100, %ebx
	movl	%ebx, -32(%ebp)
L0:
	movl	-28(%ebp), %ebx
	movl	-32(%ebp), %ecx
	cmpl	%ecx, %ebx
	jle	L1
L2:
L3:
	jmp	L4
L1:
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -24(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -28(%ebp)
	jmp	L0
L4:
	addl	$32, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

