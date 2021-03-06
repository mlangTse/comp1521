# board2.s ... Game of Life on a 15x15 grid

	.data

N:	.word 15  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0

newBoard: .space 225
# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by <<MINGLANG XIE>>, June 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state
	
	.data
msg1:	.asciiz "# Iterations: "
msg2:	.asciiz "=== After iteration "
msg3:	.asciiz " ==="
msg4:   .asciiz "."
msg5:   .asciiz "#"
eol:	.asciiz "\n"

## Provides:
	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow


########################################################################
# .TEXT <main>
	.text
main:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s7
# Uses:		$a0, $s0, $s1, $s2, $s7, $t0, $t1, $t2, $t5, $t6
# Clobbers:	$t6

# Locals:
#	- `nn' in $s0 
#	- `i' in $s1
#	- `j' in $s2
#	- `ret' in $s3

# Structure:
#	main
#	-> [prologue]
#   -> f_n_init
#   -> f_n_cond
#	    -> f_i_init
#	    -> f_i_cond
#	        -> f_j_init
#	        -> f_j_cond
#	            -> f_j_step
#	        => f_j_false
#	        -> f_i_step
#	    => f_i_false
#   -> f_n_step
#   => f_n_false
#	-> [epilogue]

# Code:
	
	# Your main program code goes here.  Good luck!
	
	# Set up stack frame.
	sw	$fp, -4($sp)	    # push $fp onto stack
	la	$fp, -4($sp)	    # set up $fp for this function
	sw	$ra, -4($fp)	    # save return address
	sw	$s0, -8($fp)	    # save $s0 to use as ... int nn
	sw	$s1, -12($fp)	    # save $s1 to use as ... int i
	sw	$s2, -16($fp)	    # save $s2 to use as ... int j
	sw	$s7, -20($fp)	    # save $s2 to use as ... char ret
	addi	$sp, $sp, -24	# move $sp to top of stack

	# code for main()
	    li	$t0, 0                  # maxiters = 0

	    la 	$a0, msg1	
	    li	$v0, 4
	    syscall                     # printf ("# Iterations: ")

	    li	$v0, 5
	    syscall                     # scanf ("%d", into $v0)
	
	    move 	$t0, $v0	        # maxiters = $v0
	    lw 	$t1, N                  # $t1 = N
	
f_n_init:
        li	$t2, 1		            # int n = 1
    
f_n_cond:
        bgt	$t2, $t0, f_n_false	    # if (n > maciters) jump to f_n_false
        
f_i_init:
		li	$s1, 0                  # int i = 0
	
f_i_cond:
	    bge $s1, $t1, f_i_false     # if (i > N) jump to f_i_false
    
f_j_init:
		li	$s2, 0				    # int j = 0
        
f_j_cond:
        bge $s2, $t1, f_j_false		# if (j > N) jump to f_j_false
        
        jal	neighbours				# jump to neighbours
		move	$s0, $v0
		
		jal	decideCell				# jump to decideCell
		move    $s7, $v0
		
		la  $t5, newBoard
		mul $t6, $s1, $t1           # offset = i * N           
		addu    $t6, $t6, $s2       # offset = i * N + j
		addu    $t6, $t6, $t5       # offset = i * N + j + newBoard
		sb    $s7, ($t6)
		
f_j_step:
        addi	$s2, $s2, 1		    # j++
        j   f_j_cond
        
f_j_false:
f_i_step:
		addi	$s1, $s1, 1			# i++
		j   f_i_cond
        
f_i_false:
f_n_step:
        la	$a0, msg2		
		li	$v0, 4
		syscall                     # printf ("=== After iteration ")

		move 	$a0, $t2
		li	$v0, 1
		syscall                     # printf ("%d", n);

		la	$a0, msg3
		li	$v0, 4
		syscall                     # printf (" ===");

		la	$a0, eol
		li	$v0, 4
		syscall                     # printf ("\n")
		
	    jal	copyBackAndShow
		
        addi	$t2, $t2, 1		    # n++
        j   f_n_cond
        
f_n_false:
    
	# clean up stack frame
	sw	$s7, -20($fp)	# restore $s7 value
	lw	$s2, -16($fp)	# restore $s2 value
	lw	$s1, -12($fp)	# restore $s1 value
	lw	$s0, -8($fp)	# restore $s0 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	    # restore $sp (remove stack frame)
	lw	$fp, ($fp)	    # restore $fp (remove stack frame)

	li	$v0, 0
	jr	$ra		        # return 0

main__post:
	jr	$ra

decideCell:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4
# Uses:		$s0, $s1, $s2, $s3, $s4, $t4, $t5
# Clobbers:	...

# Locals:	
#	- `nn' in $s0 
#	- `i' in $s1
#	- `j' in $s2
#	- `tmp' in $s3 
#	- `tmp2' in $s4

# Structure:
#	decideCell
#   -> f_old_eq_0
#       -> if_nn_lt_2
#       -> if_nn_eq_2_3
#       -> ret_eq_1
#           => if_nn_eq_2_3_false
#   -> ef_nn_eq_3
#   -> last_else
#   => end_ifs
#	-> [epilogue]

    # setup stack frame
	sw	$fp, -4($sp)	    # push $fp onto stack
	la	$fp, -4($sp)	    # set up $fp for this function
	sw	$ra, -4($fp)	    # save return address
	sw	$s0, -8($fp)	    # save $s0 to use as ... int nn
	sw	$s1, -12($fp)	    # save $s1 to use as ... int i
	sw	$s2, -16($fp)	    # save $s2 to use as ... int j
	sw	$s3, -20($fp)	    # save $s3 to use as ... int tmp;
	sw	$s4, -24($fp)	    # save $s4 to use as ... int tmp2;
	addi	$sp, $sp, -28	# reset $sp to last pushed item
    
    la  $t4, board
	mul	$s3, $s1, $t1		# $s3 = i * N
	add	$s3, $s3, $s2	    # $s3 = i * N + j
	add	$s3, $s3, $t4		# i * N + j + board
	
	lb	$s3, ($s3)
f_old_eq_0:
		bne	$s3, 1, ef_nn_eq_3			# if (tmp != 1) jump to ef_nn_eq_3

if_nn_lt_2:
		bge	$s0, 2, if_nn_eq_2_3		# if (nn >= 2) jump to if_nn_eq_2_3
		li	$t5, 0
		j	end_if
		
if_nn_eq_2_3:
		beq	$s0, 2, ret_eq_1			# if (nn == 2) jump to ret_eq_1 
		beq	$s0, 3, ret_eq_1			# if (nn == 3) jump to ret_eq_1
		j	if_nn_eq_2_3_false			# else, jump to if_nn_eq_2_3_false
		
ret_eq_1:
		li	$t5, 1						# ret = 1
		j	end_if

if_nn_eq_2_3_false:						
		li	$t5, 0						# ret = 0
		j	end_if

ef_nn_eq_3:
		bne	$s0, 3, last_else			# if (nn != 3) jump to last_else
		li	$t5, 1						# ret = 1						
		j	end_if
		
last_else:
		li	$t5, 0						# ret = 0

end_if:
		move	$v0, $t5				# return ret

	# clean up stack frame
	lw	$s4, -24($fp)	# restore $s4 value
	lw	$s3, -20($fp)	# restore $s3 value
	lw	$s2, -16($fp)	# restore $s2 value
	lw	$s1, -12($fp)	# restore $s1 value
	lw	$s0, -8($fp)	# restore $s0 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	    # restore $sp (remove stack frame)
	lw	$fp, ($fp)	    # restore $fp (remove stack frame)
	jr	$ra		        # return

neighbours:

# Frame:	$fp, $ra, $s1, $s2, $s3, $s4, $s5, $s6
# Uses:		$s1, $s2, $s3, $s4, $s5, $s6, $t3, $t4
# Clobbers:	$t3

# Locals:	
#	- `i' in $s1
#	- `j' in $s2
#	- `x' in $s3 
#	- `y' in $s4
#	- `tmp' in $s5 
#	- `tmp2' in $s6

# Structure:
#	neighbours
#	-> [prologue]
#	-> f_x_init
#	-> f_x_cond
#	   -> f_y_init
#	   -> f_y_cond
#	      -> f_y_step
#	   => f_y_false
#	   -> f_x_step
#	=> f_x_f
#	-> [epilogue]

	# setup stack frame
	sw	$fp, -4($sp)		# push $fp onto stack
	la	$fp, -4($sp)		# set up $fp for this function
	sw	$ra, -4($fp)		# save return address
	sw	$s1, -8($fp)		# save $s1 to use as ... int i
	sw	$s2, -12($fp)		# save $s2 to use as ... int j
	sw	$s3, -16($fp)		# save $s3 to use as ... int x;
	sw	$s4, -20($fp)		# save $s4 to use as ... int y;
	sw	$s5, -24($fp)   	# save $s5 to use as ... int tmp;
	sw	$s6, -28($fp)   	# save $s6 to use as ... int tmp2;
	addi	$sp, $sp, -32	# reset $sp to last pushed item

        li	$t3, 0		        # int nn = 0
    
f_x_init:
		# int x = -1;
		li	$s3, -1			    # $s3 = x

f_x_cond:
		bgt	$s3, 1, f_x_false 	# if (x > 1) jump to f_x_false

f_y_init:
		# int y = -1
		li	$s4, -1			    # $s4 = y

f_y_cond:
		bgt	$s4, 1, f_y_false 	# if (y > 1) jump to f_y_false

        # if (i + x < 0 || i + x > N - 1) continue;
		sub	$s5, $t1, 1		    # $s5 = N - 1 ($t1 = N)
		add	$s6, $s3, $s1		# $s6 = i + x
		bltz	$s6, f_y_step	
		bgt	$s6, $s5, f_y_step	
        
        # if (j + y < 0 || j + y > N - 1) continue;
		add	$s6, $s4, $s2		# $s6 = j + y
		bltz	$s6, f_y_step
		bgt	$s6, $s5, f_y_step
		
if:
	    # if (x == 0 && y == 0) continue;
		bnez	$s3, else        
		bnez	$s4, else
		j   f_y_step
		
else:
		la	$t4, board
		add	$s5, $s3, $s1		# $s5 = x + i
		add $s6, $s4, $s2		# $s6 = y + j

		mul	$s5, $s5, $t1		# $s5 = (x + i) * N
		add	$s5, $s5, $s6	    # $s5 = (x + i) * N + y + j
		add	$s5, $s5, $t4		# (x + i) * N + y + j + board

		# if (board[i + x][j + y] == 1)	
		lb	$s5, ($s5)	
		bne	$s5, 1, f_y_step
		addi	$t3, $t3, 1		# nn++
		
f_y_step:
		addi	$s4, $s4, 1     # y++
		j	f_y_cond

f_y_false:
f_x_step:
		addi	$s3, $s3, 1     # x++
		j	f_x_cond

f_x_false:
        move $v0, $t3			# return nn
        
	# clean up stack frame
	lw  $s6, -28($fp)   # restore $s6 value
	lw  $s5, -24($fp)   # restore $s5 value
	lw	$s4, -20($fp)	# restore $s4 value
	lw	$s3, -16($fp)	# restore $s3 value
	lw	$s2, -12($fp)	# restore $s2 value
	lw	$s1, -8($fp)	# restore $s1 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	    # restore $sp (remove stack frame)
	lw	$fp, ($fp)	    # restore $fp (remove stack frame)
	jr	$ra		        # return

copyBackAndShow:

# Frame:	$fp, $ra, $s3, $s4, $s5, $s6
# Uses:		$a0, $s3, $s4, $s5, $s6, $t1, $t4
# Clobbers:	$t5

# Locals:	
#	- `i' in $s3 
#	- `j' in $s4
#	- `tmp' in $s5 
#	- `tmp2' in $s6

# Structure:
#	copyBackAndShow
#	-> [prologue]
#	-> f_row_init
#	-> f_row_cond
#	   -> f_col_init
#	   -> f_col_cond
#         -> if_board_eqz
#         -> then
#	      -> f_col_step
#	   => f_col_false
#	   -> f_row_step
#	=> f_row_f
#	-> [epilogue]

	# setup stack frame
	sw	$fp, -4($sp)	    # push $fp onto stack
	la	$fp, -4($sp)	    # set up $fp for this function
	sw	$ra, -4($fp)	    # save return address
	sw	$s3, -8($fp)	    # save $s3 to use as ... int i;
	sw	$s4, -12($fp)	    # save $s4 to use as ... int j;
	sw	$s5, -16($fp)       # save $s5 to use as ... int tmp;
	sw	$s6, -20($fp)       # save $s6 to use as ... int tmp2;
	addi	$sp, $sp, -24	# reset $sp to last pushed item
	
f_row_init:
    	li  $s3, 0    	        # int i = 0;
        
f_row_cond:
 		# if (i > N) jump to f_row_false ($t1 = N)
    	bge $s3, $t1, f_row_false
    
f_col_init:
    	li  $s4, 0    	        # int j = 0;
        
f_col_cond:
 		# if (j > N) jump to f_col_false ($t1 = N)
        bge $s4, $t1, f_col_false

		la	$t4, board
		mul	$s5, $s3, $t1		# $s5 = i * N
		add	$s5, $s5, $s4	   	# $s5 = i * N + j
		add	$s5, $s5, $t4		# i * N + j + board

        la  $t5, newBoard
		mul	$s6, $s3, $t1		# $s5 = i * N
		add	$s6, $s6, $s4	   	# $s5 = i * N + j
		add	$s6, $s6, $t5		# $s6 = i * N + j + newboard

		lb	$s6, ($s6)		
		sb	$s6, ($s5)
		lb  $s6, ($s5)
        
if_board_eqz:
	    bnez	$s6, then		# if (board[i][j] != 0) jump to then
    	la  $a0, msg4
    	li  $v0, 4
    	syscall                 # printf(".")
    
    	j   f_col_step
    
then:
    	la  $a0, msg5
    	li  $v0, 4
    	syscall                 # printf("#")

f_col_step:
	    addi    $s4, $s4, 1     # j++
	    j   f_col_cond

f_col_false:
f_row_step:
    	la	$a0, eol
	    li	$v0, 4
	    syscall                 # printf ("\n") 
	
	    addi    $s3, $s3, 1     # i++
	    j   f_row_cond
    
f_row_false:

	# clean up stack frame
	lw  $s6, -20($fp)   # restore $s6 value
	lw  $s5, -16($fp)   # restore $s5 value
	lw	$s4, -12($fp)	# restore $s4 value
	lw	$s3, -8($fp)	# restore $s3 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	    # restore $sp (remove stack frame)
	lw	$fp, ($fp)	    # restore $fp (remove stack frame)
	jr	$ra		        # return
