	.file "test/test11.tig"
	.text
L4:
	.string " \0"

.globl	tigermain
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$28, %esp
L6:
	movl	$10, %ebx
	movl	%ebx, -24(%ebp)
	movl	$L4, %ebx
	movl	%ebx, -28(%ebp)
L0:
	movl	-24(%ebp), %ebx
	movl	-28(%ebp), %ecx
	cmpl	%ecx, %ebx
	jle	L1
L2:
L3:
	jmp	L5
L1:
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	%ebx, -24(%ebp)
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -24(%ebp)
	jmp	L0
L5:
	addl	$28, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

