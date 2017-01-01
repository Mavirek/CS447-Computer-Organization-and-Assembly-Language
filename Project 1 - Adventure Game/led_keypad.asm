# THIS FILE IS MEANT TO BE VIEWED WITH 8-CHARACTER TABS.

# Little interface file for accessing the "hardware" of the Keypad and LED Display MMIO Simulator tool.
# You can do .include "led_keypad.asm" in your code to use it.

# Display size
.eqv DISPLAY_BASE_ADDR 0xFFFF0008
.eqv DISPLAY_W         64
.eqv DISPLAY_H         64
.eqv DISPLAY_W_MASK    63
.eqv DISPLAY_H_MASK    63
.eqv DISPLAY_W_SHIFT   6

# LED Colors
.eqv COLOR_BLACK   0
.eqv COLOR_RED     1
.eqv COLOR_ORANGE  2
.eqv COLOR_YELLOW  3
.eqv COLOR_GREEN   4
.eqv COLOR_BLUE    5
.eqv COLOR_MAGENTA 6
.eqv COLOR_WHITE   7

# Input key codes
.eqv KEY_NONE 0
.eqv KEY_U 0xE0
.eqv KEY_D 0xE1
.eqv KEY_L 0xE2
.eqv KEY_R 0xE3
.eqv KEY_B 0x42

.text

# ======================================================================================================================
# int:v0 Input_GetKeypress()
# Returns the last key pressed in $v0, or 0 if no key was pressed. See the KEY constants above.
.globl Input_GetKeypress
Input_GetKeypress:
	li	$t0, 0xFFFF0000
	lw	$t1, 0($t0)
	beqz	$t1, _no_key

	sw	$zero, 0($t0)
	lw	$v0, 4($t0)
	jr	$ra

_no_key:
	li	$v0, 0
	jr	$ra

# ======================================================================================================================
# void Display_FillRect(int x:a0, int y:a1, int w:a2, int h:a3, int color:v0)
# Fills a rectangle of LEDs with the given color. See the COLOR constants above.
# Kinda abusing v0 as a "fifth" argument register here... OH WELL better than forcing
# you to push an argument onto the stack and pop it off after.
.globl Display_FillRect
Display_FillRect:
	# turn w/h into x2/y2
	add	$a2, $a2, $a0
	add	$a3, $a3, $a1

	# turn y1/y2 into addresses
	li	$t0, DISPLAY_BASE_ADDR
	sll	$a1, $a1, DISPLAY_W_SHIFT
	add	$a1, $a1, $t0
	add	$a1, $a1, $a0
	sll	$a3, $a3, DISPLAY_W_SHIFT
	add	$a3, $a3, $t0

	move	$t0, $a1
_fill_loop_y:
	move	$t1, $t0
	move	$t2, $a0
_fill_loop_x:
	sb	$v0, 0($t1)
	addi	$t1, $t1, 1
	addi	$t2, $t2, 1
	blt	$t2, $a2, _fill_loop_x

	addi	$t0, $t0, DISPLAY_W
	blt	$t0, $a3, _fill_loop_y

	jr	$ra

# ======================================================================================================================
# void Display_SetLED(int x:a0, int y:a1, int color:a2)
# Sets a single LED to the given color. See the COLOR constants above.
.globl Display_SetLED
Display_SetLED:
	sll	$t0, $a1, DISPLAY_W_SHIFT
	add	$t0, $t0, $a0
	li	$t1, DISPLAY_BASE_ADDR
	add	$t1, $t1, $t0
	sb	$a2, 0($t1)
	jr	$ra
