	.file "test/test21.tig"
	.text
.globl	L0
L0:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$40, %esp
L5:
	movl	12(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	je	L2
L3:
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -40(%ebp)
	movl	12(%ebp), %ebx
	movl	%ebx, -36(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	%ebp, %ecx
	addl	$12, %ecx
	movl	(%ecx), %ecx
	subl	$1, %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L0
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-36(%ebp), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	 %eax, %ebx
	popl	%esi
	imull	 %ebx, %esi
	movl	 %esi, %ebx
	movl	-40(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-40(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
L1:
	movl	-24(%ebp), %eax
	jmp	L4
L2:
	movl	$1, %ebx
	movl	%ebx, -32(%ebp)
	movl	-32(%ebp), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L1
L4:
	addl	$40, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	tigermain
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$20, %esp
L7:
	pushl	%ecx
	pushl	%edx
	movl	$10, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L0
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	jmp	L6
L6:
	addl	$20, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

