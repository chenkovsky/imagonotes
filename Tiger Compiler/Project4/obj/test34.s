	.file "test/test34.tig"
	.text
L2:
	.string "two\0"

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
L4:
	movl	12(%ebp), %eax
	jmp	L3
L3:
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
L6:
	pushl	%ecx
	pushl	%edx
	movl	$L2, %ecx
	pushl	 %ecx
	movl	$L1, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L0
	addl	$12, %esp
	popl	%edx
	popl	%ecx
	jmp	L5
L5:
	addl	$20, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

