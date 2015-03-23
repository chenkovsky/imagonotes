	.file "test/merge.tig"
	.text
L56:
	.string " \0"

L55:
	.string "\n\0"

L48:
	.string "0\0"

L47:
	.string "-\0"

L43:
	.string "0\0"

L25:
	.string "0\0"

L15:
	.string "\n\0"

L14:
	.string " \0"

L4:
	.string "9\0"

L3:
	.string "0\0"

.globl	L1
L1:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$44, %esp
L61:
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	movl	-24(%eax), %ecx
	pushl	 %ecx
	movl	$2, %ecx
	pushl	 %ecx
	call	ord
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	%eax, -44(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L3, %ecx
	pushl	 %ecx
	movl	$2, %ecx
	pushl	 %ecx
	call	ord
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-44(%ebp), %ebx
	cmpl	%eax, %ebx
	jge	L6
L7:
	movl	$0, %ebx
	movl	%ebx, -28(%ebp)
	movl	-28(%ebp), %ebx
	movl	%ebx, -24(%ebp)
L5:
	movl	-24(%ebp), %eax
	jmp	L60
L6:
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -40(%ebp)
	movl	$1, %edx
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	movl	-24(%eax), %ecx
	pushl	 %ecx
	movl	$2, %ecx
	pushl	 %ecx
	call	ord
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	%eax, -36(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L4, %ecx
	pushl	 %ecx
	movl	$2, %ecx
	pushl	 %ecx
	call	ord
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-36(%ebp), %ebx
	cmpl	%eax, %ebx
	jle	L8
L9:
	xorl	%edx, %edx
L8:
	movl	-40(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-40(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L5
L60:
	addl	$44, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	L2
L2:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$40, %esp
L10:
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-24(%eax), %ebx
	movl	$L14, %ecx
	cmpl	%ecx, %ebx
	je	L17
L18:
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -40(%ebp)
	movl	$1, %edx
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-24(%eax), %ebx
	movl	$L15, %ecx
	cmpl	%ecx, %ebx
	je	L19
L20:
	xorl	%edx, %edx
L19:
	movl	-40(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-40(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
L16:
	movl	-24(%ebp), %ecx
L11:
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	%eax, %ebx
	addl	$-24, %ebx
	movl	%ebx, -36(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$2, %ecx
	pushl	 %ecx
	call	getchar
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-36(%ebp), %ecx
	movl	%eax, (%ecx)
	jmp	L10
L17:
	movl	$1, %ebx
	movl	%ebx, -32(%ebp)
	movl	-32(%ebp), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L16
L12:
L13:
	xorl	%eax, %eax
	jmp	L62
L62:
	addl	$40, %esp
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
	subl	$44, %esp
L64:
	movl	$0, %ebx
	movl	%ebx, -24(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$1, %ecx
	pushl	 %ecx
	call	L2
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%ebp, %ebx
	addl	$12, %ebx
	movl	(%ebx), %ebx
	addl	$0, %ebx
	movl	%ebx, -44(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	movl	-24(%eax), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L1
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-44(%ebp), %ecx
	movl	%eax, (%ecx)
L21:
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	movl	-24(%eax), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L1
	addl	$8, %esp
	popl	%edx
	popl	%ecx
L22:
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	%ebx, -40(%ebp)
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	(%ebx), %ebx
	imull	$10, %ebx
	movl	%ebx, -32(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	movl	-24(%eax), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	ord
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-32(%ebp), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	 %eax, %ebx
	popl	%esi
	addl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	%ebx, -36(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L25, %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	ord
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-36(%ebp), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	 %eax, %ebx
	popl	%esi
	subl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	-40(%ebp), %ecx
	movl	%ebx, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	get_staticlink
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	%eax, %ebx
	addl	$-24, %ebx
	movl	%ebx, -28(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$1, %ecx
	pushl	 %ecx
	call	getchar
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-28(%ebp), %ecx
	movl	%eax, (%ecx)
	jmp	L21
L23:
L24:
	movl	-24(%ebp), %eax
	jmp	L63
L63:
	addl	$44, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	L26
L26:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$56, %esp
L66:
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	%ebx, -56(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$4, %ecx
	pushl	 %ecx
	call	allocRecord
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %edx
	movl	$0, %ebx
	movl	%ebx, 0(%edx)
	movl	-56(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -52(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	-24(%ebp), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L0
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-52(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-24(%ebp), %ecx
	movl	0(%ecx), %ecx
L31:
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
	movl	-28(%ebp), %ebx
	movl	%ebx, 0(%edx)
	movl	%edx, %ebx
	addl	$4, %ebx
	movl	%ebx, -44(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$1, %ecx
	pushl	 %ecx
	call	L26
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-44(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-48(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-48(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -32(%ebp)
L30:
	movl	-32(%ebp), %eax
	jmp	L65
L32:
	movl	$0, %ebx
	movl	%ebx, -36(%ebp)
	movl	-36(%ebp), %ebx
	movl	%ebx, -32(%ebp)
	jmp	L30
L65:
	addl	$56, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	L27
L27:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$80, %esp
L68:
	movl	12(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	je	L40
L41:
	movl	%ebp, %ebx
	addl	$-52, %ebx
	movl	%ebx, -80(%ebp)
	movl	16(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	je	L37
L38:
	movl	%ebp, %ebx
	addl	$-40, %ebx
	movl	%ebx, -76(%ebp)
	movl	12(%ebp), %ebx
	movl	0(%ebx), %ebx
	movl	16(%ebp), %ecx
	movl	0(%ecx), %ecx
	cmpl	%ecx, %ebx
	jl	L34
L35:
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -64(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$8, %ecx
	pushl	 %ecx
	call	allocRecord
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %edx
	movl	16(%ebp), %ebx
	movl	0(%ebx), %ebx
	movl	%ebx, 0(%edx)
	movl	%edx, %ebx
	addl	$4, %ebx
	movl	%ebx, -60(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	16(%ebp), %ecx
	movl	4(%ecx), %ecx
	pushl	 %ecx
	movl	12(%ebp), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L27
	addl	$12, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-60(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-64(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-64(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
L33:
	movl	-24(%ebp), %ebx
	movl	-76(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-76(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -36(%ebp)
L36:
	movl	-36(%ebp), %ebx
	movl	-80(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-80(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -48(%ebp)
L39:
	movl	-48(%ebp), %eax
	jmp	L67
L40:
	movl	16(%ebp), %ebx
	movl	%ebx, -56(%ebp)
	movl	-56(%ebp), %ebx
	movl	%ebx, -48(%ebp)
	jmp	L39
L37:
	movl	12(%ebp), %ebx
	movl	%ebx, -44(%ebp)
	movl	-44(%ebp), %ebx
	movl	%ebx, -36(%ebp)
	jmp	L36
L34:
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -72(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$8, %ecx
	pushl	 %ecx
	call	allocRecord
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %edx
	movl	12(%ebp), %ebx
	movl	0(%ebx), %ebx
	movl	%ebx, 0(%edx)
	movl	%edx, %ebx
	addl	$4, %ebx
	movl	%ebx, -68(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	16(%ebp), %ecx
	pushl	 %ecx
	movl	12(%ebp), %ecx
	movl	4(%ecx), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L27
	addl	$12, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-68(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-72(%ebp), %ecx
	movl	%edx, (%ecx)
	movl	-72(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L33
L67:
	addl	$80, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	L42
L42:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$36, %esp
L70:
	movl	12(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	jg	L45
L46:
L44:
	movl	-24(%ebp), %eax
	jmp	L69
L45:
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -36(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	12(%ebp), %ecx
	movl	%ecx, %eax
	movl	$10, %ecx
	movl	%ecx, %ecx
	cltd
	idivl	%ecx
	pushl	 %eax
	movl	$2, %ecx
	pushl	 %ecx
	call	L42
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	12(%ebp), %ebx
	movl	 %ebx, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	12(%ebp), %ebx
	movl	%ebx, %eax
	movl	$10, %ebx
	movl	%ebx, %ebx
	cltd
	idivl	%ebx
	movl	 %eax, %ebx
	movl	 %ebx, %esi
	pushl	%esi
	movl	$10, %ebx
	movl	 %ebx, %ebx
	popl	%esi
	imull	 %ebx, %esi
	movl	 %esi, %ebx
	movl	 %ebx, %ebx
	popl	%esi
	subl	 %ebx, %esi
	movl	 %esi, %ebx
	movl	%ebx, -32(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L43, %ecx
	pushl	 %ecx
	movl	$2, %ecx
	pushl	 %ecx
	call	ord
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	movl	-32(%ebp), %ecx
	movl	 %ecx, %ecx
	movl	 %ecx, %esi
	pushl	%esi
	movl	 %eax, %ecx
	popl	%esi
	addl	 %ecx, %esi
	movl	 %esi, %ecx
	pushl	 %ecx
	movl	$2, %ecx
	pushl	 %ecx
	call	chr
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	pushl	 %eax
	movl	$2, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	-36(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-36(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L44
L69:
	addl	$36, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	L28
L28:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$60, %esp
L72:
	movl	12(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	jl	L53
L54:
	movl	%ebp, %ebx
	addl	$-40, %ebx
	movl	%ebx, -56(%ebp)
	movl	12(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	jg	L50
L51:
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -48(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L48, %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-48(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-48(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
L49:
	movl	-24(%ebp), %ebx
	movl	-56(%ebp), %ecx
	movl	%ebx, (%ecx)
	movl	-56(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -36(%ebp)
L52:
	movl	-36(%ebp), %eax
	jmp	L71
L53:
	movl	%ebp, %ebx
	addl	$-44, %ebx
	movl	%ebx, -60(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L47, %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	%ebp, %ecx
	addl	$12, %ecx
	movl	(%ecx), %ecx
	subl	$0, %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L42
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	-60(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-60(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -36(%ebp)
	jmp	L52
L50:
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -52(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	12(%ebp), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L42
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-52(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-52(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
	jmp	L49
L71:
	addl	$60, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret


.globl	L29
L29:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	subl	$40, %esp
L74:
	movl	12(%ebp), %ebx
	movl	$0, %ecx
	cmpl	%ecx, %ebx
	je	L58
L59:
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -36(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	12(%ebp), %ecx
	movl	0(%ecx), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L28
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	$L56, %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	print
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	pushl	%ecx
	pushl	%edx
	movl	12(%ebp), %ecx
	movl	4(%ecx), %ecx
	pushl	 %ecx
	movl	$1, %ecx
	pushl	 %ecx
	call	L29
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	movl	-36(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	-36(%ebp), %ebx
	movl	(%ebx), %ebx
	movl	%ebx, -24(%ebp)
L57:
	movl	-24(%ebp), %eax
	jmp	L73
L58:
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -40(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$L55, %ecx
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
	jmp	L57
L73:
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
	subl	$48, %esp
L76:
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	%ebx, -48(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	getchar
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-48(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	%ebp, %ebx
	addl	$-28, %ebx
	movl	%ebx, -44(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	L26
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-44(%ebp), %ecx
	movl	%eax, (%ecx)
	movl	%ebp, %ebx
	addl	$-32, %ebx
	movl	%ebx, -40(%ebp)
	movl	%ebp, %ebx
	addl	$-24, %ebx
	movl	%ebx, -36(%ebp)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	getchar
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	movl	-36(%ebp), %ecx
	movl	%eax, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	$0, %ecx
	pushl	 %ecx
	call	L26
	addl	$4, %esp
	popl	%edx
	popl	%ecx
	movl	-40(%ebp), %ecx
	movl	%eax, (%ecx)
	pushl	%ecx
	pushl	%edx
	movl	-32(%ebp), %ecx
	pushl	 %ecx
	movl	-28(%ebp), %ecx
	pushl	 %ecx
	movl	$0, %ecx
	pushl	 %ecx
	call	L27
	addl	$12, %esp
	popl	%edx
	popl	%ecx
	movl	%eax, %eax
	pushl	%ecx
	pushl	%edx
	pushl	 %eax
	movl	$0, %ecx
	pushl	 %ecx
	call	L29
	addl	$8, %esp
	popl	%edx
	popl	%ecx
	jmp	L75
L75:
	addl	$48, %esp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	leave
	ret

