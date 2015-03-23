	.file "test/test1.tig"
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
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	%ebx, -28(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	$10, %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-28(%ebp), %ecx
	movl	%eax, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$2, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	(%ecx), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	jmp	L0
L0:
	addl	$28, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

