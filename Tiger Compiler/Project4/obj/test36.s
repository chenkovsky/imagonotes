	.file "test/test36.tig"
	.text
L1:
	.string "one\0"

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
L3:
	movl	12(%ebp), %eax
	jmp	L2
L2:
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
	subl	$20, %esp
L5:
	pushl	%ecx
	pushl	%edx
	movl	$5, %ecx
	pushl	 %ecx
	movl	$L1, %ecx
	pushl	 %ecx
	movl	$3, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L0
	addl	$16, %esp
	popl	%edx
	popl	%ecx
	jmp	L4
L4:
	addl	$20, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

