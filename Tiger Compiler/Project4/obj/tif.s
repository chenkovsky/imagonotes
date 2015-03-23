	.file "test/tif.tig"
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
	subl	$32, %esp
L5:
	movl	12(%ebp), %ebx
	movl	16(%ebp), %ecx
	cmpl	%ecx, %ebx
	jg	L2
L3:
	movl	16(%ebp), %ebx
	movl	%ebx, -28(%ebp)
	movl	-28(%ebp), %ebx
	movl	%ebx, -24(%ebp)
L1:
	movl	-24(%ebp), %eax
	jmp	L4
L2:
	movl	12(%ebp), %ebx
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
	movl	$4, %ecx
	pushl	 %ecx
	movl	$9, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L0
	addl	$12, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	pushl	 %eax
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
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

