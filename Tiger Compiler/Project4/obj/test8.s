	.file "test/test8.tig"
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
L4:
	movl	$10, %ebx
	movl	$20, %ecx
	cmpl	%ecx, %ebx
	jg	L1
L2:
	movl	$40, %ebx
	movl	%ebx, -28(%ebp)
	movl	-28(%ebp), %ebx
	movl	%ebx, -24(%ebp)
L0:
	movl	-24(%ebp), %ecx
	jmp	L3
L1:
	movl	$30, %ebx
	movl	%ebx, -32(%ebp)
	movl	-32(%ebp), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L0
L3:
	addl	$32, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

