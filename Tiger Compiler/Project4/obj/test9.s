	.file "test/test9.tig"
	.text
L0:
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
	subl	$32, %esp
L5:
	movl	$5, %ebx
	movl	$4, %ecx
	cmpl	%ecx, %ebx
	jg	L2
L3:
	movl	$L0, %ebx
	movl	%ebx, -28(%ebp)
	movl	-28(%ebp), %ebx
	movl	%ebx, -24(%ebp)
L1:
	movl	-24(%ebp), %ecx
	jmp	L4
L2:
	movl	$13, %ebx
	movl	%ebx, -32(%ebp)
	movl	-32(%ebp), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L1
L4:
	addl	$32, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

