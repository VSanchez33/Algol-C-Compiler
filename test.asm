# Compilers MIPS code Fall 2025


.data 

_L0:	.asciiz	"Array val: "
_L1:	.asciiz	"\n"
_L2:	.asciiz	"Enter array val: "

.align 2 

x:	.space	20

.text 

.globl main 

func:			# Start of Function
	subu $a0, $sp, 28		# adjust the stack for function
	sw $sp, ($a0)		# remember old stack pointer
	sw $ra, 4($a0)		# remember current Return address
	move $sp, $a0		# adjust the stack pointer

	sw $t0, 8($sp)		# load temp variable into formal parameter
	sw $t1, 12($sp)		# load temp variable into formal parameter
_L3:			# WHILE top target
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	sw $a0, 16($sp)		# expression store LHS temporarily
	li $a0, 0		# expression is constant
	move $a1, $a0		# RHS needs to be a1
	lw $a0, 16($sp)		# expression restore LHS from memory
	add $a0, $a0, 1		# expr GE add one to compare
	slt $a0, $a1, $a0		# expr greater than or equal
	beq $a0, $0, _L4		# WHILE branch out
	li $v0, 4		# print a string
	la $a0, _L0		# print fetch string location
	syscall		# perform a write string

	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	move $a1, $a0		# var copy index array in a1
	sll $a1 $a1 2		# multply the index by wordsize via SLL
	la $a0, x		# emit var global variable
	add $a0 $a0 $a1		# var array add internal offset
	lw $a0 ($a0)		# expression is a var, get value
	li $v0, 1		# print the number
	syscall		# system call for print number

	li $v0, 4		# print a string
	la $a0, _L1		# print fetch string location
	syscall		# perform a write string

	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	sw $a0, 20($sp)		# expression store LHS temporarily
	li $a0, 1		# expression is constant
	move $a1, $a0		# RHS needs to be a1
	lw $a0, 20($sp)		# expression restore LHS from memory
	sub $a0, $a0, $a1		# expr minus
	sw $a0, 24($sp)		# store RHS temporarily
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a1, 24($sp)		# load RHS from stack
	sw $a1, ($a0)		# store RHS into memory

	j _L3		# WHILE jump back
_L4:			# End of WHILE
	li $a0, 1		# expression is constant
	move $a1, $a0		# var copy index array in a1
	sll $a1 $a1 2		# multply the index by wordsize via SLL
	la $a0, x		# emit var global variable
	add $a0 $a0 $a1		# var array add internal offset
	lw $a0 ($a0)		# expression is a var, get value
	sw $a0, 20($sp)		# expression store LHS temporarily
	li $a0, 5		# expression is constant
	move $a1, $a0		# RHS needs to be a1
	lw $a0, 20($sp)		# expression restore LHS from memory
	slt $t2, $a0, $a1		# expr equal
	slt $t3, $a1, $a0		# expr equal
	nor $a0, $t2, $t3		# expr equal
	andi $a0, 1		# expr equal
	beq $a0, $0, _L5		# IF branch to else part

			# the positive portion of IF
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	sw $a0, 24($sp)		# expression store LHS temporarily
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 12		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	move $a1, $a0		# RHS needs to be a1
	lw $a0, 24($sp)		# expression restore LHS from memory
	or $a0, $a0, $a1		# expr or
	lw $ra 4($sp)		# restore ra
	lw $sp ($sp)		# restore sp
	jr $ra		# return to the caller

	j _L6		# if STMT1 end
_L5:			# ELSE target
			# the negative portion of IF, if there is an else
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	sw $a0, 24($sp)		# expression store LHS temporarily
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 12		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	move $a1, $a0		# RHS needs to be a1
	lw $a0, 24($sp)		# expression restore LHS from memory
	and $a0, $a0, $a1		# expr and
	lw $ra 4($sp)		# restore ra
	lw $sp ($sp)		# restore sp
	jr $ra		# return to the caller

_L6:			# End of IF
	li $a0, 0		# return has no specified value, set to 0
	lw $ra, 4($sp)		# restore ra
	lw $sp, ($sp)		# restore sp

	jr $ra		# return to the caller
main:			# Start of Function
	subu $a0, $sp, 32		# adjust the stack for function
	sw $sp, ($a0)		# remember old stack pointer
	sw $ra, 4($a0)		# remember current Return address
	move $sp, $a0		# adjust the stack pointer

	li $a0, 0		# expression is constant
	sw $a0, 12($sp)		# store RHS temporarily
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a1, 12($sp)		# load RHS from stack
	sw $a1, ($a0)		# store RHS into memory

_L7:			# WHILE top target
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	sw $a0, 16($sp)		# expression store LHS temporarily
	li $a0, 5		# expression is constant
	move $a1, $a0		# RHS needs to be a1
	lw $a0, 16($sp)		# expression restore LHS from memory
	slt $a0, $a0, $a1		# expr less than
	beq $a0, $0, _L8		# WHILE branch out
	li $v0, 4		# print a string
	la $a0, _L2		# print fetch string location
	syscall		# perform a write string

	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	move $a1, $a0		# var copy index array in a1
	sll $a1 $a1 2		# multply the index by wordsize via SLL
	la $a0, x		# emit var global variable
	add $a0 $a0 $a1		# var array add internal offset
	li $v0, 5		# read a number from input
	syscall		# reading a number
	sw $v0, ($a0)		# store the read into a memory location

	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	sw $a0, 20($sp)		# expression store LHS temporarily
	li $a0, 1		# expression is constant
	move $a1, $a0		# RHS needs to be a1
	lw $a0, 20($sp)		# expression restore LHS from memory
	add $a0, $a0, $a1		# expr add
	sw $a0, 24($sp)		# store RHS temporarily
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a1, 24($sp)		# load RHS from stack
	sw $a1, ($a0)		# store RHS into memory

	j _L7		# WHILE jump back
_L8:			# End of WHILE
			# setting up function call
			# evaluate funtion parameters
	move $a0, $sp		# VAR local make a copy of stackpointer
	addi $a0, $a0, 8		# VAR local stack pointer plus offset
	lw $a0 ($a0)		# expression is a var, get value
	sw $a0, 20($sp)		# expression store LHS temporarily
	li $a0, 1		# expression is constant
	move $a1, $a0		# RHS needs to be a1
	lw $a0, 20($sp)		# expression restore LHS from memory
	sub $a0, $a0, $a1		# expr minus
	sw $a0, 28($sp)		# store call arg temporarily

	li $a0, 1000		# expression is constant
	sw $a0, 24($sp)		# store call arg temporarily

			# place parameters into T registers
	lw $a0, 28($sp)		# pull out stored arg
	move $t0, $a0		# move arg into temp
	lw $a0, 24($sp)		# pull out stored arg
	move $t1, $a0		# move arg into temp

	jal func		# call the function

	li $v0, 1		# print the number
	syscall		# system call for print number

	li $a0, 0		# return has no specified value, set to 0
	lw $ra, 4($sp)		# restore ra
	lw $sp, ($sp)		# restore sp

	li $v0, 10		# leave main program
	syscall		# leave everything
