	.file "test/mytest.tig"
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
L7:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -32(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	%eax, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	subl	$1, %ebx
	movl	-32(%ebp), %ecx
	movl	%ebx, (%ecx)
L2:
	movl	-24(%ebp), %ebx
	movl	-32(%ebp), %ecx
	movl	(%ecx), %ecx
	cmpl	%ecx, %ebx
	jle	L3
L4:
L5:
	xorl	%eax, %eax
	jmp	L6
L3:
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	movl	-24(%eax), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	addl	$1, %ebx
	movl	%ebx, -24(%ebp)
	jmp	L2
L6:
	addl	$32, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	L1
L1:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$20, %esp
L9:
	pushl	%ecx
	pushl	%edx
	movl	$1, %ecx
	pushl	 %ecx
	call	L0
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	jmp	L8
L8:
	addl	$20, %esp
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
	subl	$24, %esp
L11:
	movl	$8, %ebx
	movl	%ebx, -24(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L1
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	jmp	L10
L10:
	addl	$24, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

