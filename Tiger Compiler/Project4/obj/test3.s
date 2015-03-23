	.file "test/test3.tig"
	.text
L1:
	.string "Somebody\0"

L0:
	.string "Nobody\0"

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
L3:
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
	movl	$1000, %ebx
	movl	%ebx, 4(%edx)
	movl	-28(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	$L1, %ebx
	movl	-24(%ebp), %ecx
	movl	%ebx, 0(%ecx)
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	movl	0(%ecx), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	-24(%ebp), %ecx
	jmp	L2
L2:
	addl	$28, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

