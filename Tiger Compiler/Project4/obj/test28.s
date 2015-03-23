	.file "test/test28.tig"
	.text
L0:
	.string "Name\0"

.globl	tigermain
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$28, %esp
L2:
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	%ebx, -28(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$8, %ecx
	pushl	 %ecx
	call	allocRecord
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %edx
	movl	$L0, %ebx
	movl	%ebx, 0(%edx)
	movl	$0, %ebx
	movl	%ebx, 4(%edx)
	movl	-28(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-24(%ebp), %ecx
	jmp	L1
L1:
	addl	$28, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

