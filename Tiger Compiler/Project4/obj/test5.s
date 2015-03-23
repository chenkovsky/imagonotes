	.file "test/test5.tig"
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
	movl	$8, %ecx
	pushl	 %ecx
	call	allocRecord
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %edx
	movl	$0, %ebx
	movl	%ebx, 0(%edx)
	movl	$0, %ebx
	movl	%ebx, 4(%edx)
	movl	-28(%ebp), %ecx
	movl	%edx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	movl	0(%ecx), %ecx
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

