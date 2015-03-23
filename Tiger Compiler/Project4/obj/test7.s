	.file "test/test7.tig"
	.text
L4:
	.string "str2\0"

L3:
	.string " \0"

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
L6:
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
	xorl	%eax, %eax
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
L8:
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
	movl	$L3, %ecx
	movl	%ecx, %eax
	jmp	L7
L7:
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
L10:
	pushl	%ecx
	pushl	%edx
	movl	$L4, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L0
	addl	$12, %esp
	popl	%edx
	popl	%ecx
	jmp	L9
L9:
	addl	$20, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

