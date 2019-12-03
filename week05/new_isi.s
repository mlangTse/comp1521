# COMP1521 18s1 Exam Q1
# Matrix data

   .data
N:
   .word   3
m:
   .word   1, 0, 0
   .word   0, 1, 0
   .word   0, 0, 1

   .align  2

### COMP1521 19t2 ... week 05 lab
### Identity matrix checker.
### (... from a past practice prac exam.)

	.data
msg1:	.asciiz "The matrix\n"
msg2:	.asciiz "is an identity matrix\n"
msg3:	.asciiz "is not an identity matrix\n"

## Requires (from `matrixX.s'):
# - N (word): matrix dimensions
# - m (word[N][N]): matrix

## Provides:
	.globl	main
	.globl	showMatrix
	.globl	isIdent

# .TEXT <main> #########################################################
	.text
main:

# Frame:	$fp, $ra
# Uses:		$a0, $v0
# Clobbers:	$a0
#
# Locals:	[none]
#
# Structure:
#	main
#	-> [prologue]
#	-> main_isi
#	   -> main_isi_t
#	   -> main_isi_f
#	=> main_isi_phi
#	-> [epilogue]
#
# Code:
	# set up stack frame
	addi	$sp, $sp, -4
	sw	$fp, ($sp)	# push $fp
	la	$fp, ($sp)	# load new $fp
	addi	$sp, $sp, -4
	sw	$ra, ($sp)	# push $ra

	la	$a0, msg1
	li	$v0, 4
	syscall			# printf("The matrix\n")

	la	$a0, m		#            + from &m[0][0]
	lw	$a1, N		#            | + from *N
	jal	showMatrix	# showMatrix(m,N)
	nop	#[branch delay]

	la	$a0, m		#         + from &m[0][0]
	lw	$a1, N		#         | + from *N
	jal	isIdent		# isIdent(m,N)

	beqz	$v0, main_isi_f
	nop	#[branch delay]
main_isi_t:
	la	$a0, msg2
	li	$v0, 4
	syscall			# printf("is an identity matrix\n")

	j	main_isi_phi
main_isi_f:
	la	$a0, msg3
	li	$v0, 4
	syscall			# printf("is not an identity matrix\n")

main_isi_phi:

main__epi:
	# tear down stack frame
	lw	$ra, ($sp)	# pop $ra
	addi	$sp, $sp, 4
	lw	$fp, ($sp)	# pop $fp
	addi	$sp, $sp, 4

	li	$v0, 0
	jr	$ra		# return 0


# .TEXT <showMatrix> ###################################################
	.text
showMatrix:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3
# Uses:		$a0, $a1, $a1, $s0, $s1, $s2, $s3, $t0, $t1
# Clobbers:	$a0, $t0, $t1
#
# Locals:
#	- `m' in $s0 (from $a0)
#	- `N' in $s1 (from $a1)
#	- `row' in $s2
#	- `col' in $s3
#
# Structure:
#	showMatrix
#	-> [prologue]
#	-> showM_row_init
#	-> showM_row_cond
#	   -> showM_col_init
#	   -> showM_col_cond
#	      -> showM_col_step
#	   => showM_col_f
#	   -> showM_row_step
#	=> showM_row_f
#	-> [epilogue]
#
# Code:
	# set up stack frame
	addi	$sp, $sp, -4
	sw	$fp, ($sp)	# push $fp
	la	$fp, ($sp)
	addi	$sp, $sp, -4
	sw	$ra, ($sp)	# push $ra
	addi	$sp, $sp, -4
	sw	$s0, ($sp)	# push $s0
	addi	$sp, $sp, -4
	sw	$s1, ($sp)	# push $s1
	addi	$sp, $sp, -4
	sw	$s2, ($sp)	# push $s2
	addi	$sp, $sp, -4
	sw	$s3, ($sp)	# push $s3

	move	$s0, $a0
	move	$s1, $a1

showM_row_init:
	li	$s2, 0		# row = 0
showM_row_cond:
	bge	$s2, $s1, showM_row_f	# row < n  ||  row >= n
	nop	#[branch delay]

showM_col_init:
	li	$s3, 0		# col = 0
showM_col_cond:
	bge	$s3, $s1, showM_col_f	# col < n  ||  col >= n
	nop	#[branch delay]

	li	$a0, ' '
	li	$v0, 11
	syscall			# putchar(' ')

	# printf ("%d", m[row][col]):
	# m[row][col] = *(&m[0][0] + (row * N) + col)
	mul	$t0, $s2, $s1	# % <- row * N
	add	$t0, $t0, $s3	#    + col
	li	$t1, 4
	mul	$t0, $t0, $t1	#    * sizeof(word)
	addu	$t0, $s0, $t0	#    + &m[0][0]
	lw	$a0, ($t0)
	li	$v0, 1
	syscall			# printf("%d", *%)

showM_col_step:
	addi	$s3, $s3, 1	# col++
	j	showM_col_cond
	nop	#[branch delay]
showM_col_f:

	li	$a0, '\n'
	li	$v0, 11
	syscall			# putchar('\n')

showM_row_step:
	addi	$s2, $s2, 1	# row++
	j	showM_row_cond
	nop	#[branch delay]
showM_row_f:

showM__epi:
	# tear down stack frame
	lw	$s3, ($sp)	# pop $s3
	addi	$sp, $sp, 4
	lw	$s2, ($sp)	# pop $s2
	addi	$sp, $sp, 4
	lw	$s1, ($sp)	# pop $s1
	addi	$sp, $sp, 4
	lw	$s0, ($sp)	# pop $s0
	addi	$sp, $sp, 4
	lw	$ra, ($sp)	# pop $ra
	addi	$sp, $sp, 4
	lw	$fp, ($sp)	# pop $fp
	addi	$sp, $sp, 4
	jr	$ra

# .TEXT <isIdent> ######################################################
	.text
isIdent:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, [... frame ...]
# Uses:		[... registers used ...]
# Clobbers:	[... registers clobbered ...]
#
# Locals:
#	- `m' in [reg] (from $a0)
#	- `n' in [reg] (from $a1)
#	- [`var' in reg]
#
# Structure:
#	isIdent
#	-> [prologue]
#	-> ...
#	-> [epilogue]
#
# Code:
	# set up stack frame
	addi	$sp, $sp, -4
	sw	$fp, ($sp)	# push $fp
	la	$fp, ($sp)
	addi	$sp, $sp, -4
	sw	$ra, ($sp)	# push $ra
	addi	$sp, $sp, -4
	sw	$s0, ($sp)	# push $s0
	addi	$sp, $sp, -4
	sw	$s1, ($sp)	# push $s1
	addi	$sp, $sp, -4
	sw	$s2, ($sp)	# push $s2
	addi	$sp, $sp, -4
	sw	$s3, ($sp)	# push $s3

	# If you need to save more than four $s? registers,
	# add extra code here to save them on the stack.


	## TODO: your code for the body of isIdent(m,N) goes here.
	li  $t1, 1
	move  $v0, $t1
	move  $t0, $a1
f_row_init:
    li  $s0, 0
    
f_row_cond:
    bge $s0, $t0, f_row_false
    
f_col_init:
    li  $s1, 0
    
f_col_cond:
    bge $s1, $t0, f_col_false
    move  $s2, $a0
    mul $s3, $s0, $t0
    addu    $s3, $s3, $s1
    mul $s3, $s3, 4
    addu    $s3, $s3, $s2
    lw  $s3, ($s3)

if_r_eq_c:
    bne $s0, $s1, if_r_ne_c
    beq $s3, 1, if_r_ne_c
    j   return_0
    
if_r_ne_c:
    beq $s0, $s1, f_col_step
    beqz    $s3, f_col_step
    j   return_0

f_col_step:
    addi    $s1, $s1, 1
    j   f_col_cond
    
f_col_false:
f_row_step:
    addi    $s0, $s0, 1
    j   f_row_cond
    
return_0:
    li $t0, 0
    move  $v0, $t0
    
f_row_false:
    
	# tear down stack frame
	# If you saved more than four $s? registers,
	# add extra code here to restore them.
	lw	$s3, ($sp)	# pop $s3
	addi	$sp, $sp, 4
	lw	$s2, ($sp)	# pop $s2
	addi	$sp, $sp, 4
	lw	$s1, ($sp)	# pop $s1
	addi	$sp, $sp, 4
	lw	$s0, ($sp)	# pop $s0
	addi	$sp, $sp, 4
	lw	$ra, ($sp)	# pop $ra
	addi	$sp, $sp, 4
	lw	$fp, ($sp)	# pop $fp
	addi	$sp, $sp, 4
	jr	$ra
