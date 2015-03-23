	.file "test/tlink.tig"
	.text
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
L3:
	pushl	%ecx
	pushl	%edx
	movl	$155287632, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	12(%eax), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	12(%ebp), %ecx
	movl	 %ecx, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	movl	%ecx, %eax
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
	movl	$3, %ecx
	pushl	 %ecx
	movl	$155287632, %ecx
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
L7:
	pushl	%ecx
	pushl	%edx
	movl	$2, %ecx
	pushl	 %ecx
	movl	$155286240, %ecx
	pushl	 %ecx
	call	L0
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	pushl	 %eax
	movl	$155286240, %ecx
	pushl	 %ecx
	call	printi
	addl	$8, %esp
	popl	%edx
	popl	%ecx
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

