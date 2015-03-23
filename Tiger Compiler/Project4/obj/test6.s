	.file "test/test6.tig"
	.text
L3:
	.string "str2\0"

L2:
	.string "str\0"

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
L5:
	pushl	%ecx
	pushl	%edx
	movl	%ebp, %ecx
	addl	$12, %ecx
	movl	(%ecx), %ecx
	addl	$1, %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L1
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
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
L7:
	pushl	%ecx
	pushl	%edx
	movl	$L2, %ecx
	pushl	 %ecx
	movl	12(%ebp), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L0
	addl	$12, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
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
L9:
	pushl	%ecx
	pushl	%edx
	movl	$L3, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L0
	addl	$12, %esp
	popl	%edx
	popl	%ecx
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

