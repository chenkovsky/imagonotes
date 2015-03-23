	.file "test/tifn.tig"
	.text
L5:
	.string " \0"

L1:
	.string "hey! Bigger than 3!\0"

.globl	L0
L0:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$40, %esp
L7:
	movl	12(%ebp), %ebx
	movl	$3, %ecx
	cmpl	%ecx, %ebx
	jg	L3
L4:
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -36(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	$4, %ebx
	movl	%ebx, -24(%eax)
	movl	$0, %ebx
	movl	-36(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-36(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
L2:
	movl	-24(%ebp), %eax
	jmp	L6
L3:
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -40(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L1, %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-40(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-40(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L2
L6:
	addl	$40, %esp
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
L9:
	movl	$5, %ebx
	movl	%ebx, -24(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	$L5, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	$2, %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L0
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	jmp	L8
L8:
	addl	$24, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

