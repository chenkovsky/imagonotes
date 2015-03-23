	.file "test/test37.tig"
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
	subl	$28, %esp
L2:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	$L0, %ebx
	movl	%ebx, -28(%ebp)
	jmp	L1
L1:
	addl	$28, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

