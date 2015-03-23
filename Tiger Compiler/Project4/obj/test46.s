	.file "test/test46.tig"
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
	subl	$24, %esp
L5:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	$1, %edx
	movl	-24(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	je	L0
L1:
	xorl	%edx, %edx
L0:
	movl	$1, %edx
	movl	-24(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	jne	L2
L3:
	xorl	%edx, %edx
L2:
	jmp	L4
L4:
	addl	$24, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

