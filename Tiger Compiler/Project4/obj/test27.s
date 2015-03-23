	.file "test/test27.tig"
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
	subl	$20, %esp
L2:
	movl	12(%ebp), %eax
	jmp	L1
L1:
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
L4:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L0
	addl	$8, %esp
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
	jmp	L3
L3:
	addl	$24, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

