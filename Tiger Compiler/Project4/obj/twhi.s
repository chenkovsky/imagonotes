	.file "test/twhi.tig"
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
	subl	$36, %esp
L8:
	movl	$10, %ebx
	movl	%ebx, -24(%ebp)
L0:
	movl	-24(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	jge	L1
L2:
L3:
	jmp	L7
L1:
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	%ebx, -24(%ebp)
	movl	-24(%ebp), %ebx
	movl	$2, %ecx
	cmpl	%ecx, %ebx
	je	L5
L6:
L4:
	movl	-28(%ebp), %ecx
	jmp	L0
L5:
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -36(%ebp)
	jmp	L3
L9:
	movl	$0, %ebx
	movl	-36(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-36(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -28(%ebp)
	jmp	L4
L7:
	addl	$36, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

