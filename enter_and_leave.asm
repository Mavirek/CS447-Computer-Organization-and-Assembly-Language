# Pushes $ra.
.macro enter
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
.end_macro

# Pops $ra and returns.
.macro leave
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
.end_macro

# Pushes $ra and whatever register you give it.
.macro enter %r1
	addi	$sp, $sp, -8
	sw	%r1, 4($sp)
	sw	$ra, 0($sp)
.end_macro

# Pops $ra and whatever register you give it, and returns.
.macro leave %r1
	lw	%r1, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
.end_macro

# some examples of use.
func:
	enter $s0
	# s0 has been saved so we can use it!
	li	$s0, 10
	leave $s0

func2:
	enter
	
	leave