	.file "test/test26.tig"
	.text
L0:
	.string "var\0"

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
L2:
	movl	$3, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$L0, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
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

