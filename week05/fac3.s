### COMP1521 19t2 ... week 05 lab
### Compute factorials -- recursive function version

## Global data
	.data
msg1:	.asciiz "n  = "
msg2:	.asciiz "n! = "
eol:	.asciiz "\n"

### main() function
	.text
	.globl	main
main:
	# Set up stack frame
	sw	$fp, -4($sp)	# push $fp onto stack
	la	$fp, -4($sp)	# set up $fp for this function
	sw	$ra, -4($fp)	# save return address
	sw	$s0, -8($fp)	# save $s0 to use as ... int n
	addi	$sp, $sp, -12	# reset $sp to last pushed item

	# code for main()
	li	$s0, 0

	la	$a0, msg1
	li	$v0, 4
	syscall			# printf("n  = ")

	li	$v0, 5
	syscall			# scanf("%d", into $v0)
	move	$s0, $v0

	move	$a0, $s0	#         + from $s0
	jal	fac		# % = fac(n)
	nop	#[branch delay] # |
	move	$s0, $v0	# + into $s0; don't need n now

	la	$a0, msg2
	li	$v0, 4
	syscall			# printf("n! = ")

	move	$a0, $s0	# assume $s0 holds n!
	li	$v0, 1
	syscall			# printf ("%d", tmp)

	la	$a0, eol
	li	$v0, 4
	syscall			# printf("\n")

	# clean up stack frame
	lw	$s0, -8($fp)	# restore $s0 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	# restore $sp (remove stack frame)
	lw	$fp, ($fp)	# restore $fp (remove stack frame)

	li	$v0, 0
	jr	$ra		# return 0


### fac() function
	.text
	.globl	fac
fac:
	## TODO: set up stack frame
	# Set up stack frame
	sw	$fp, -4($sp)	# push $fp onto stack
	la	$fp, -4($sp)	# set up $fp for this function
	sw	$ra, -4($fp)	# save return address
	sw	$s1, -8($fp)	# save $s1 to use as ... int n
	sw  $s2, -12($fp)   # save $s2 to use as ... int tmp
	addi	$sp, $sp, -16	# reset $sp to last pushed item

	## TODO: code for recursive fac()
	move $s1, $a0
	move $s2, $s1
	
if_eq_n:
    bne $s0, $s1, if
    li $t0, 1
    move $v0, $t0
    ble $s0, 0, end_if
    move $v0, $a0
    
if:
    ble $s1, 1, end_if    

else:
    sub $s2, $s2, 1
    mul $v0, $v0, $s2
    sub $s1, $s1, 1
    move $a0, $s1
    jal fac

end_if:
	## TODO: clean up stack frame
	lw	$s1, -12($fp)	# restore $s2 value
	lw	$s1, -8($fp)	# restore $s1 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	# restore $sp (remove stack frame)
	lw	$fp, ($fp)	# restore $fp (remove stack frame)
	jr	$ra		# ... and return
