	.file "test/test43.tig"
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
L1:
	movl	%ebp, %ecx
	addl	$-24, %ecx
	movl	(%ecx), %ecx
	addl	$3, %ecx
	jmp	L0
L0:
	addl	$24, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

