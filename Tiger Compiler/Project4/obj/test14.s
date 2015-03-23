	.file "test/test14.tig"
	.text
L0:
	.string "aname\0"

.globl	tigermain
tigermain:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$48, %esp
L5:
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	%ebx, -48(%ebp)
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
	movl	-48(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -44(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	$3, %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-44(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-24(%ebp), %ebx
	movl	-28(%ebp), %ecx
	cmpl	%ecx, %ebx
	jne	L2
L3:
	movl	$4, %ebx
	movl	%ebx, -36(%ebp)
	movl	-36(%ebp), %ebx
	movl	%ebx, -32(%ebp)
L1:
	movl	-32(%ebp), %ecx
	jmp	L4
L2:
	movl	$3, %ebx
	movl	%ebx, -40(%ebp)
	movl	-40(%ebp), %ebx
	movl	%ebx, -32(%ebp)
	jmp	L1
L4:
	addl	$48, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

