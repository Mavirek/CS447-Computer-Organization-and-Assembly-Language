#Allen Poon
#CS 447 Project 1
#Tues/Thurs 9:30am - 10:45am


.include "led_keypad.asm"
.include "enter_and_leave.asm"
.data
	last_tick_time: .word 0
	map: .byte 0:4096
	player: .byte 0:5
	.eqv playerX 0
	.eqv playerY 1
	.eqv playerKeyR 2 #0 if player doesn't have red key, 1 if they do
	.eqv playerKeyG 3
	.eqv playerKeyB 4
	key: .byte 0:10
	.eqv keyOn 0 #used to flash key LEDs
	.eqv keyRCollected 1 #responsible for making key appear/disappear
	.eqv keyRX 2
	.eqv keyRY 3
	.eqv keyGCollected 4
	.eqv keyGX 5
	.eqv keyGY 6
	.eqv keyBCollected 7
	.eqv keyBX 8
	.eqv keyBY 9
	door: .byte 0:9
	.eqv doorRLocked 0 #0 if locked, 1 if unlocked
	.eqv doorRX 1 #'C' on ascii board = red door, appears as '7' in memory map
	.eqv doorRY 2
	.eqv doorGLocked 3
	.eqv doorGX 4 #'D' on ascii board = green door, appears as '8' in memory map
	.eqv doorGY 5
	.eqv doorBLocked 6
	.eqv doorBX 7 #'E' on ascii board = blue door, appears as '9' on memory map
	.eqv doorBY 8
	treasure: .byte 0:3
	.eqv treasureCollected 0
	.eqv treasureX 1
	.eqv treasureY 2
	dragon: .byte 0:2
	.eqv dragonX 0
	.eqv dragonY 1
	
	board: .ascii 
		"################################################################"
		"#                                                              #"
		"#                                                              #"
		"#        P                                                     #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"################                                               #"
		"#              #                                               #"
		"#      T       #                                               #"
		"#              #                                               #"
		"#              #                                               #"
		"################                   #############################"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                               R              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"################################                               #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                  X                                           #"
		"#                                                              #"
		"#                                                              #"
		"#                                          #####################"
		"#                                          #                   #"
		"#                                          #                   #"
		"#                                          #                   #"
		"#                                          #                   #"
		"#                                          #        B          #"
		"#                                          #                   #"
		"#                                          #                   #"
		"#                                          #####################"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                                              #"
		"#                                ###############################"
		"#                                #                             #"
		"#                                #                             #"
		"#                                #                             #"
		"#                                #                             #"
		"#                                #             G               #"
		"#                                #                             #"
		"#                                #                             #"
		"#                                #                             #"
		"#                                #                             #"
		"#                                #                             #"
		"#                                #                             #"
		"################################################################"
	


.text
.globl main
main:
	li $s1, 0 #s1 = y
	la $s0, board #s0 = address of first byte of ascii board
	la $s4, map #s4 = address of first byte of board memory map
	
loopY:
	li $s2, 0 #s2 = x
loopX:
	lb $t0, 0($s0)
	
	beq $t0, '#', wall
	beq $t0, 'P', loadPlayer
	beq $t0, ' ', emptySpace #store a 0 in memory map for empty space
	beq $t0, 'R', redKey
	beq $t0, 'G', greenKey
	beq $t0, 'B', blueKey
	j end
emptySpace:
	li $t6, 0
	sb $t6, 0($s4) #store a 0 in memory map for an empty space
	j end
wall:
	move $a0, $s2
	move $a1, $s1
	li $a2, COLOR_WHITE
	
	li $t6, 1
	sb $t6, 0($s4) #store a 1 in memory map for a wall
	jal Display_SetLED
	j end
	
redKey:
	la $s6, key
	sb $s2, keyRX($s6)
	sb $s1, keyRY($s6)
	li $t6, 1
	sb $t6, keyOn($s6) #indicates if key LEDs are on
	#turn on key LED
	lb $a0, keyRX($s6)
	lb $a1, keyRY($s6)
	li $a2, 2
	li $a3, 1
	li $v0, COLOR_RED
	jal Display_FillRect
	#mark positions on memory map
	li $t6, 2 #red key will appear in memory map as a '2'
	sb $t6, 0($s4) #label the first LED position on memory map
	addi $s4, $s4, 1 
	sb $t6, 0($s4) #label the second LED position on memory map
	addi $s0, $s0, 1 #increment by 1 byte to next char on ascii board
	addi $s2, $s2, 1 #increment by 1 in X loop to accomodate for the key's second LED position
	j end
greenKey:
	la $s6, key
	sb $s2, keyGX($s6)
	sb $s1, keyGY($s6)
	li $t6, 1
	sb $t6, keyOn($s6) #indicates key LEDs are on
	#turn on key LED
	lb $a0, keyGX($s6)
	lb $a1, keyGY($s6)
	li $a2, 2
	li $a3, 1
	li $v0, COLOR_GREEN
	jal Display_FillRect
	#mark positions on memory map
	li $t6, 3 #green key will appear in memory map as a '3'
	sb $t6, 0($s4) #label the first LED position on memory map
	addi $s4, $s4, 1 
	sb $t6, 0($s4) #label the second LED position on memory map
	addi $s0, $s0, 1 #increment by 1 byte to next char on ascii board
	addi $s2, $s2, 1 #increment by 1 in X loop to accomodate for the key's second LED position
	j end

blueKey:
	la $s6, key
	sb $s2, keyBX($s6) #store the blue key's X position for later use in flashing its LEDs
	sb $s1, keyBY($s6) #store the blue key's Y position for later use in flashing its LEDs
	li $t6, 1
	sb $t6, keyOn($s6) #indicates key LEDs are on
	#turn on key LED
	lb $a0, keyBX($s6)
	lb $a1, keyBY($s6)
	li $a2, 2
	li $a3, 1
	li $v0, COLOR_BLUE
	jal Display_FillRect
	#mark positions on memory map
	li $t6, 4 #blue key will appear in memory map as a '4'
	sb $t6, 0($s4) #label the first LED position on memory map
	addi $s4, $s4, 1 
	sb $t6, 0($s4) #label the second LED position on memory map
	addi $s0, $s0, 1 #increment by 1 byte to next char on ascii board
	addi $s2, $s2, 1 #increment by 1 in X loop to accomodate for the key's second LED position
	j end

loadPlayer:
	la $s7, player
	sb $s2, playerX($s7)
	sb $s1, playerY($s7)
	li $a2, COLOR_MAGENTA
	lb $a0, playerX($s7)
	lb $a1, playerY($s7)
	jal Display_SetLED
	j emptySpace #include a 0 in memory map on the starting position of player
	
end:
	addi $s0, $s0, 1 #next byte for ascii map
	addi $s4, $s4, 1 #next byte for memory map
	addi $s2, $s2, 1 #increment x
	blt $s2, 64, loopX
	addi $s1, $s1, 1 #increment y
	blt $s1, 64, loopY
#insert doors and treasure chest onto board and memory map	
redDoor:
	la $s5, door
	li $a0, 44 #red door's coordinates: (6,12)
	li $a1, 51
	sb $a0, doorRX($s5)
	sb $a1, doorRY($s5)
	li $a2, 3
	li $a3, 1
	li $v0, COLOR_RED
	jal Display_FillRect
	#mark positions on memory map
	lb $a0, doorRX($s5)
	lb $a1, doorRY($s5)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 5 #red door will appear in memory map as a '5'
	sb $t6, 0($s4) #label the first LED position on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label the second LED position on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #third LED positon on memory map

greenDoor:
	la $s5, door
	li $a0, 43 #green door's coordinates: (43,36)
	li $a1, 36
	sb $a0, doorGX($s5)
	sb $a1, doorGY($s5)
	li $a2, 1
	li $a3, 3
	li $v0, COLOR_GREEN
	jal Display_FillRect
	#mark positions on memory map
	lb $a0, doorGX($s5)
	lb $a1, doorGY($s5)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 6 #green door will appear in memory map as a '6'
	sb $t6, 0($s4) #label the first LED position on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label the second LED position on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #third LED position on memory map

blueDoor:
	la $s5, door
	li $a0, 6 #blue door's coordinates (44,51)
	li $a1, 12
	sb $a0, doorBX($s5)
	sb $a1, doorBY($s5)
	li $a2, 3
	li $a3, 1
	li $v0, COLOR_BLUE
	jal Display_FillRect
	#mark positions on memory map
	lb $a0, doorBX($s5)
	lb $a1, doorBY($s5)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 7 #blue door will appear in memory map as a '7'
	sb $t6, 0($s4) #label the first LED position on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label the second LED position on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #third LED positon on memory map

treasureChest:
	la $s3, treasure
	li $a0, 7
	li $a1, 9
	sb $a0, treasureX($s3)
	sb $a1, treasureY($s3)
	li $a2, 3
	li $a3, 2
	li $v0, COLOR_ORANGE
	jal Display_FillRect
	
	#mark positions on memory map
	lb $a0, treasureX($s3)
	lb $a1, treasureY($s3)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 8
	sb $t6, 0($s4) #label first LED position on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label second LED position on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label third LED position on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label fourth LED position
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label fifth LED position
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label sixth LED position

loadDragon:
	la $s2, dragon
	li $a0, 10
	li $a1, 30
	sb $a0, dragonX($s2)
	sb $a1, dragonY($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	#mark position on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 9
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	j startGame
	
getPos:
	sll $a1, $a1, 6
	add $v0, $a1, $a0
	jr $ra
	

startGame:
	li $v0, 30
	syscall
	la $t0, last_tick_time
	sw $a0, 0($t0)
	
# s7 stores player object data
# s6 stores key object data
# s5 stores door object data
# s4 stores memory map data for collision purposes
# s3 stores treasure chest object data
# s2 stores dragon object data
	
gameLoop:
	jal Input_GetKeypress
	move $t4, $v0
	jal flashKeys
	jal moveDragon
movement:	
	beq $t4, KEY_R, moveRight
	beq $t4, KEY_D, moveDown
	beq $t4, KEY_U, moveUp
	beq $t4, KEY_L, moveLeft
	beq $t4, KEY_B, stop
checkMove:
	lb $a0, playerX($s7)
	lb $a1, playerY($s7)
	jal checkDragon #checks for dragon collision even when stopped moving
	beq $t5, 0, wait #if there is initially no movement direction
	move $t4, $t5 #revert back to the original movement direction
	j movement
moveRight:
	lb $a0, playerX($s7) #load in player X coordinate
	lb $a1, playerY($s7) #load in player Y coordinate
	move $t3, $a0 #backup original position incase no collision
	addi $a0, $a0, 1 #add 1 to the player X coordinate to test for collision
	move $t8, $a0 #backup playerX+1 argument for later use in other collision types
	jal map_get_wall #test for collision and return the result in v0
	beq $v0, 1, stop #v0 = 1 means player will hit a wall
	lb $a1, playerY($s7) #reload player Y coordinate
	move $a0, $t8 #load in playerX+1 argument to test for collision
	jal checkDoorCollide #test for door collision
	lb $a1, playerY($s7) #reload player Y coord
	move $a0, $t8 #load in playerX+1 argument
	jal checkKeyCollide #test for key collision
	lb $a1, playerY($s7) #reload player Y coord
	move $a0, $t8 #load in playerX+1 argument
	jal checkTreasure #check for treasure collision
	lb $a1, playerY($s7)
	move $a0, $t8
	jal checkDragon
	#no collision, so retrieve a0 back to original position
	
	#turn off previous LED position
	move $a0, $t3 
	lb $a1, playerY($s7)
	li $a2, COLOR_BLACK
	jal Display_SetLED
	
	#turn on new LED position
	move $a0, $t8 #load in playerX+! argument
	sb $a0, playerX($s7)
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	move $t5, $t4 #save original movement direction
	j wait
moveDown:
	#similar to moveRight
	lb $a0, playerX($s7)
	lb $a1, playerY($s7)
	move $t3, $a1 #back up original position in case no collision
	addi $a1, $a1, 1
	move $t8, $a1
	jal map_get_wall
	beq $v0, 1, stop
	lb $a0, playerX($s7)
	move $a1, $t8
	jal checkDoorCollide
	lb $a0, playerX($s7)
	move $a1, $t8
	jal checkKeyCollide
	lb $a0, playerX($s7)
	move $a1, $t8
	jal checkTreasure
	lb $a0, playerX($s7)
	move $a1, $t8
	jal checkDragon
	#no collision, so retrieve a1 back to original position
	
	#turn off previous LED position
	move $a1, $t3 
	li $a2, COLOR_BLACK
	jal Display_SetLED
	
	#turn on new LED position
	move $a1, $t8
	sb $a1, playerY($s7)
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	move $t5, $t4 #save original movement direction
	j wait
moveUp:
	#similar to moveRight
	lb $a0, playerX($s7)
	lb $a1, playerY($s7)
	move $t3, $a1 #back up original position in case no collision
	addi $a1, $a1, -1
	move $t8, $a1
	jal map_get_wall
	beq $v0, 1, stop
	lb $a0, playerX($s7)
	move $a1, $t8
	jal checkDoorCollide
	lb $a0, playerX($s7)
	move $a1, $t8
	jal checkKeyCollide
	lb $a0, playerX($s7)
	move $a1, $t8
	jal checkTreasure
	lb $a0, playerX($s7)
	move $a1, $t8
	jal checkDragon
	move $a1, $t3 #no collision, so retrieve a1 back to original position

	li $a2, COLOR_BLACK
	jal Display_SetLED
	move $a1, $t8
	sb $a1, playerY($s7)
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	move $t5, $t4
	j wait
moveLeft:
	#similar to moveRight
	lb $a0, playerX($s7)
	lb $a1, playerY($s7)
	move $t3, $a0
	addi $a0, $a0, -1
	move $t8, $a0
	jal map_get_wall
	beq $v0, 1, stop #if v0=1, there is a collision
	lb $a1, playerY($s7)
	move $a0, $t8
	jal checkDoorCollide
	lb $a1, playerY($s7)
	move $a0, $t8
	jal checkKeyCollide
	lb $a1, playerY($s7)
	move $a0, $t8
	jal checkTreasure
	lb $a1, playerY($s7)
	move $a0, $t8
	jal checkDragon
	move $a0, $t3 #no collision, so retrieve a0 back to original position

	lb $a1, playerY($s7)
	li $a2, COLOR_BLACK
	jal Display_SetLED
	move $a0, $t8
	sb $a0, playerX($s7)
	li $a2, COLOR_MAGENTA
	jal Display_SetLED
	move $t5, $t4
	j wait
wait:
	li $v0, 30
	syscall
	#current time is in a0
	la $t0, last_tick_time
	lw $t0, 0($t0)
	#last time is in t0
	sub $t1, $a0, $t0
	#t1 = current_time - last_time
	blt $t1, 100, wait
	#if the amount of time <100 ms, go back to "wait"
	#last_tick_time = current_time
	la $t0, last_tick_time
	sw $a0, 0($t0)
	j gameLoop
#main function for collision testing
#a0 = X parameter, a1 = Y parameter
map_get_wall: 
	enter
	sll $a1, $a1, 6 #a1 = y*64
	add $a1, $a1, $a0 #a1 = (y*64)+x
	la $s4, map #pointer to first byte of memory map
	add $s4, $s4, $a1
	lb $v0, 0($s4) #new position on memory map based on a0 and a1 arguments
	leave
checkDragon:
	enter
	jal map_get_wall
	beq $v0, 9, endGame
	leave
#check for collision with treasure chest
checkTreasure:
	enter
	jal map_get_wall
	beq $v0, 8, endGame
	leave
#check for collision with keys
checkKeyCollide:
	enter
	jal map_get_wall #used to obtain a value from the memory map for v0
	beq $v0, 2, keyRCollide
	beq $v0, 3, keyGCollide
	beq $v0, 4, keyBCollide
doneKeyCheck:
	leave
keyRCollide:
	li $t6, 1
	sb $t6, keyRCollected($s6) #red key collected --> turn off display indicator
	sb $t6, playerKeyR($s7) #player picked up red key --> update inventory
	sb $t6, doorRLocked($s5) #unlocks red door
	#add $s4, $s4, $v0 #get to the collision location in memory map
	li $t6, 0
	sb $t6, 0($s4) #set key position in memory map to 0, or empty space
	j doneKeyCheck
keyGCollide:
	li $t6, 1
	sb $t6, keyGCollected($s6)
	sb $t6, playerKeyG($s7)
	sb $t6, doorGLocked($s5)
	#add $s4, $s4, $v0
	li $t6, 0
	sb $t6, 0($s4)
	j doneKeyCheck
keyBCollide:
	li $t6, 1
	sb $t6, keyBCollected($s6)
	sb $t6, playerKeyB($s7)
	sb $t6, doorBLocked($s5)
	#add $s4, $s4, $v0
	li $t6, 0
	sb $t6, 0($s4)
	j doneKeyCheck
#check for collision with doors
checkDoorCollide:
	enter
	jal map_get_wall #used to obtain a value from the memory map for v0
	beq $v0, 5, doorRCollide
	beq $v0, 6, doorGCollide
	beq $v0, 7, doorBCollide
doneDoorCheck:
	leave	
	
doorRCollide:
	lb $t9, doorRLocked($s5) #load in door's lock status --> 0 if locked, 1 if unlocked
	beq $t9, 0, stop #if player doesn't have red key, treat door collision as a wall and stop movement
	#else, move through door and delete door
	lb $a0, doorRX($s5)
	lb $a1, doorRY($s5)
	li $a2, 3
	li $a3, 1
	li $v0, COLOR_BLACK
	jal Display_FillRect
	j doneDoorCheck
doorGCollide:
	lb $t9, doorGLocked($s5)
	beq $t9, 0, stop
	lb $a0, doorGX($s5)
	lb $a1, doorGY($s5)
	li $a2, 1
	li $a3, 3
	li $v0, COLOR_BLACK
	jal Display_FillRect
	j doneDoorCheck
doorBCollide:
	lb $t9, doorBLocked($s5)
	beq $t9, 0, stop #stop player movement if key isn't collected
	lb $a0, doorBX($s5)
	lb $a1, doorBY($s5)
	li $a2, 3
	li $a3, 1
	li $v0, COLOR_BLACK
	jal Display_FillRect
	j doneDoorCheck
#stops player movement
stop:
	li $t4, 0 #sets the movement direction to 0, or null
	li $t5, 0 #sets the previous movement direction to 0, or null
	j gameLoop

flashKeys:
	enter
	lb $t6, keyOn($s6) #checks whether to turn on or off the keys' LEDs
	xor $t6, 1 #alternate between 1 and 0
	sb $t6, keyOn($s6)
	#t6 = 0 --> turn off keys' LEDs
	#t6 = 1 --> turn on keys' LEDs
	beq $t6, 0, turnOffKeys

	lb $a0, keyRCollected($s6) #check if each key is collected. 1 = collected, 0 = not collected
	#if red key is collected, then skip red key display code and check green key
	beq $a0, 1, checkKeyG 
	#key isn't collected yet, so display key
	lb $a0, keyRX($s6)
	lb $a1, keyRY($s6)
	li $a2, 2
	li $a3, 1
	li $v0, COLOR_RED
	jal Display_FillRect
checkKeyG: #similar process to checking red key
	lb $a0, keyGCollected($s6)
	beq $a0, 1, checkKeyB
	#key isn't collected yet, so display key
	lb $a0, keyGX($s6)
	lb $a1, keyGY($s6)
	li $a2, 2
	li $a3, 1
	li $v0, COLOR_GREEN
	jal Display_FillRect
checkKeyB:
	lb $a0, keyBCollected($s6)
	beq $a0, 1, stopFlash #key is collected, stop key checking --> stopFlash
	#key isn't collected yet, so display key
	lb $a0, keyBX($s6)
	lb $a1, keyBY($s6)
	li $a2, 2
	li $a3, 1
	li $v0, COLOR_BLUE
	jal Display_FillRect
stopFlash: #exit function and go back to gameLoop
	leave
#turns off keys' LEDs simultaneously
turnOffKeys:
	enter
	lb $a0, keyRX($s6)
	lb $a1, keyRY($s6)
	li $a2, 2
	li $a3, 1
	li $v0, COLOR_BLACK
	jal Display_FillRect
	
	lb $a0, keyGX($s6)
	lb $a1, keyGY($s6)
	li $a2, 2
	li $a3, 1
	jal Display_FillRect
	
	lb $a0, keyBX($s6)
	lb $a1, keyBY($s6)
	li $a2, 2
	li $a3, 1
	jal Display_FillRect
	leave

moveDragon:
	enter
chase:
	#determine whether dragon should chase or roam
	lb $a2, playerY($s7)
	lb $a3, dragonY($s2)
	sub $a2, $a2, $a3 #a2 = playerY - dragonY
	abs $a2, $a2
	mul $a2, $a2, $a2 #a2 = (a2)^2
	
	lb $a0, playerX($s7)
	lb $a1, dragonX($s2)
	sub $a0, $a0, $a1 #a0 = playerX - dragonX
	abs $a0, $a0
	mul $a0, $a0, $a0 #a0 = (a0)^2
	
	add $a3, $a0, $a2 #distance equation without sqrt = (playerX-dragonX)^2 + (playerY-dragonY)^2
	bgt $a3, 64, roam

compare:
#dragon should chase, so compare player X and Y values with dragon X and Y values to determine dragon's optimized path
	lb $a0, playerX($s7)
	lb $a1, playerY($s7)
	jal getPos
	move $t8, $v0 #player position
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	move $t9, $v0 #dragon position
	
	lb $a0, playerX($s7)
	lb $a1, dragonX($s2)
	sub $a0, $a0, $a1 #playerX - dragonX
	add $t7, $t9, $a0 #predicted dragonX movement = dragon position + (playerX - dragonY)
	
	lb $a2, playerY($s7)
	lb $a3, dragonY($s2)
	sub $a2, $a2, $a3 #playerY - dragonY
	add $t9, $t9, $a2 #predicted dragonY movement = dragon position + (playerY - dragonY)
	
	#pick the closest path to the player
	sub $t6, $t8, $t7
	beq $t6, 0, dragonChaseX #if the difference between playerX position and predicted dragonX movement is 0, then chase on horizontal axis
	#else, chase on vertical axis
	bgt $a2, 0, dragonChaseDown #if playerY - dragonY > 0, player is below the dragon
	li $t7, 0 #else if playerY - dragonY <= 0, player is above the dragon
	j dragonMovement
dragonChaseDown:
	li $t7, 1
	j dragonMovement
dragonChaseX: #dragon chases player in X direction
	bgt $a0, 0, dragonChaseRight #if playerX - dragonX > 0, player is to the right of the dragon
	li $t7, 3 #else if playerX - dragonX <= 0, player is to the left of the dragon
	j dragonMovement
dragonChaseRight:
	li $t7, 2
	j dragonMovement
	
roam:
	#randomly pick a direction to roam:
	# 0 = up
	# 1 = down
	# 2 = right
	# 3 = left
	# 4 = no movement
	li $a1, 4
	li $v0, 42
	syscall
	#sb $a0, dragonDir($s2)
	move $t7, $a0
dragonMovement:
	beq $t7, 0, dragonUp
	beq $t7, 1, dragonDown
	beq $t7, 2, dragonRight
	beq $t7, 3, dragonLeft
	beq $t7, 4, stopDragon
dragonUp:
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	move $t3, $a1 #back up original position in case no collision
	addi $a1, $a1, -1
	move $t8, $a1
	jal map_get_wall #wall collision testing with dragonY-1
	beq $v0, 1, stopDragon
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	addi $a0, $a0, 1
	jal map_get_wall #diagonal-of-dragon wall collision testing  --> lower right becomes dragonX+1 when moving up
	beq $v0, 1, stopDragon
	
	#no collision
	move $a1, $t3
	lb $a0, dragonX($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_BLACK
	jal Display_FillRect
	#update dragon on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 0
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	
	move $a1, $t8
	sb $a1, dragonY($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	#update dragon on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 9
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	j stopDragon
dragonDown:
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	move $t3, $a1 #back up original position in case no collision
	addi $a1, $a1, 1
	move $t8, $a1
	jal map_get_wall #wall collision testing with dragonY+1
	beq $v0, 1, stopDragon
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	addi $a0, $a0, 1
	addi $a1, $a1, 2
	jal map_get_wall #diagonal-of-dragon wall collision testing  --> lower right becomes dragonX+1 and dragonY+2 when moving down
	beq $v0, 1, stopDragon
	
	#no collision
	move $a1, $t3
	lb $a0, dragonX($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_BLACK
	jal Display_FillRect
	#update dragon on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 0
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	
	move $a1, $t8
	sb $a1, dragonY($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	#update dragon on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 9
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	j stopDragon
dragonRight:
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	move $t3, $a0 #back up original position in case no collision
	addi $a0, $a0, 1
	move $t8, $a0
	jal map_get_wall #wall collision testing with dragonX+1
	beq $v0, 1, stopDragon
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	addi $a0, $a0, 2
	addi $a1, $a1, 1
	jal map_get_wall #diagonal-of-dragon wall collision testing  --> lower right becomes dragonX+2 and dragonY+1 when moving right
	beq $v0, 1, stopDragon
	
	#no collision
	move $a0, $t3
	lb $a1, dragonY($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_BLACK
	jal Display_FillRect
	#update dragon on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 0
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	
	move $a0, $t8
	sb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	#update dragon on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 9
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	j stopDragon
dragonLeft:
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	move $t3, $a0 #back up original position in case no collision
	addi $a0, $a0, -1
	move $t8, $a0
	jal map_get_wall #wall collision testing with dragonX-1
	beq $v0, 1, stopDragon
	lb $a1, dragonY($s2)
	lb $a0, dragonX($s2)
	addi $a1, $a1, 1
	jal map_get_wall #diagonal-of-dragon wall collision testing  --> lower right becomes dragonY+1 when moving left
	beq $v0, 1, stopDragon
	
	#no collision
	move $a0, $t3
	lb $a1, dragonY($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_BLACK
	jal Display_FillRect
	#update dragon on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 0
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	
	move $a0, $t8
	sb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	li $a2, 2
	li $a3, 2
	li $v0, COLOR_YELLOW
	jal Display_FillRect
	#update dragon on memory map
	lb $a0, dragonX($s2)
	lb $a1, dragonY($s2)
	jal getPos
	la $s4, map
	add $s4, $s4, $v0
	li $t6, 9
	sb $t6, 0($s4) #label upper left LED position of dragon on memory map
	addi $s4, $s4, 1
	sb $t6, 0($s4) #label upper right LED position of dragon on memory map
	addi $s4, $s4, 64
	sb $t6, 0($s4) #label lower right LED position of dragon on memory map
	addi $s4, $s4, -1
	sb $t6, 0($s4) #label lower left LED position of dragon on memory map
	j stopDragon
stopDragon:
	leave
#ends game via treasure chest or dragon
endGame:
	li $v0, 10
	syscall

