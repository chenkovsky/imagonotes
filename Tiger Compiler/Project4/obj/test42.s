	.file "test/test42.tig"
	.text
L8:
	.string "sdf\0"

L7:
	.string "sfd\0"

L6:
	.string "kati\0"

L5:
	.string "Allos\0"

L4:
	.string "Kapou\0"

L3:
	.string "Kapoios\0"

L2:
	.string "\0"

L1:
	.string "somewhere\0"

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
	subl	$64, %esp
L10:
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	%ebx, -64(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	movl	$10, %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-64(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -60(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$16, %ecx
	pushl	 %ecx
	call	allocRecord
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %edx
	movl	$L0, %ebx
	movl	%ebx, 0(%edx)
	movl	$L1, %ebx
	movl	%ebx, 4(%edx)
	movl	$0, %ebx
	movl	%ebx, 8(%edx)
	movl	$0, %ebx
	movl	%ebx, 12(%edx)
	pushl	%ecx
	pushl	%edx
	pushl	 %edx
	movl	$5, %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-60(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -56(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L2, %ecx
	pushl	 %ecx
	movl	$100, %ecx
	pushl	 %ecx
	call	initArray
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-56(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	%ebp, %ebx
	addl	$-36, %ebx
	movl	%ebx, -52(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$16, %ecx
	pushl	 %ecx
	call	allocRecord
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %edx
	movl	$L3, %ebx
	movl	%ebx, 0(%edx)
	movl	$L4, %ebx
	movl	%ebx, 4(%edx)
	movl	$2432, %ebx
	movl	%ebx, 8(%edx)
	movl	$44, %ebx
	movl	%ebx, 12(%edx)
	movl	-52(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	%ebp, %ebx
	addl	$-40, %ebx
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
	movl	$L5, %ebx
	movl	%ebx, 0(%edx)
	movl	%edx, %ebx
	addl	$4, %ebx
	movl	%ebx, -44(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$1900, %ecx
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
	movl	-48(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	$1, %ebx
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$0, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	movl	$3, %ebx
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$9, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	movl	$L6, %ebx
	movl	-28(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$3, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	(%ecx), %ecx
	movl	%ebx, 0(%ecx)
	movl	$23, %ebx
	movl	-28(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$1, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	(%ecx), %ecx
	movl	%ebx, 12(%ecx)
	movl	$L7, %ebx
	movl	-32(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$34, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	movl	$L8, %ebx
	movl	-36(%ebp), %ecx
	movl	%ebx, 0(%ecx)
	movl	$2323, %ebx
	movl	-40(%ebp), %ecx
	movl	4(%ecx), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$0, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	movl	$2323, %ebx
	movl	-40(%ebp), %ecx
	movl	4(%ecx), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$2, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ebx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$0, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	(%ecx), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	-40(%ebp), %ecx
	movl	4(%ecx), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$0, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	(%ecx), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	-32(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$34, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	(%ecx), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	-28(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$4, %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	$3, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	imull	 %ecx, %esi
	movl	 %esi, %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	(%ecx), %ecx
	movl	0(%ecx), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	-36(%ebp), %ecx
	movl	0(%ecx), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	jmp	L9
L9:
	addl	$64, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

