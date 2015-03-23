	.file "test/tfo.tig"
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
	subl	$44, %esp
L8:
	movl	$4, %ebx
	movl	%ebx, -24(%ebp)
	movl	$0, %ebx
	movl	%ebx, -28(%ebp)
	movl	-24(%ebp), %ebx
	movl	%ebx, -40(%ebp)
L0:
	movl	-28(%ebp), %ebx
	movl	-40(%ebp), %ecx
	cmpl	%ecx, %ebx
	jle	L1
L2:
L3:
	jmp	L7
L1:
	pushl	%ecx
	pushl	%edx
	movl	-28(%ebp), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	-28(%ebp), %ebx
	movl	$3, %ecx
	cmpl	%ecx, %ebx
	je	L5
L6:
L4:
	movl	-32(%ebp), %ecx
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -28(%ebp)
	jmp	L0
L5:
	movl	%ebp, %ebx
	addl	$-36, %ebx
	movl	%ebx, -44(%ebp)
	jmp	L3
L9:
	movl	$0, %ebx
	movl	-44(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-44(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -32(%ebp)
	jmp	L4
L7:
	addl	$44, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

