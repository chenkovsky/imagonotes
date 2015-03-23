	.file "test/test15.tig"
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
	subl	$28, %esp
L1:
	movl	$3, %ebx
	movl	%ebx, -28(%ebp)
	movl	-28(%ebp), %ebx
	movl	%ebx, -24(%ebp)
L0:
	movl	-24(%ebp), %ecx
	jmp	L3
L2:
	jmp	L0
L3:
	addl	$28, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

