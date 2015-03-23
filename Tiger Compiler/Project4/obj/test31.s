	.file "test/test31.tig"
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
	subl	$24, %esp
L2:
	movl	$L0, %ebx
	movl	%ebx, -24(%ebp)
	movl	-24(%ebp), %ecx
	jmp	L1
L1:
	addl	$24, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

