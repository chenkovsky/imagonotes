	.file "test/test24.tig"
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
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$3, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	(%ecx), %ecx
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

