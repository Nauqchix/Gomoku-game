.data
    board:          .space 225      # 15x15 board (each cell is 1 byte)
    welcome:        .asciiz "Welcome to Five in a Row (Caro) Game!\n"
    board_row:      .asciiz "   | "
    board_header:   .asciiz "       0   1   2   3   4   5   6   7   8   9  10  11  12  13  14\n   +-----------------------------------------------------------------+\n"
    board_footer:   .asciiz "   +-----------------------------------------------------------------+\n"
    row_separator:  .asciiz " | "
    space_str:      .asciiz " "
    newline:        .asciiz "\n"
    prompt1:        .asciiz "Player 1, please input your coordinates: "
    prompt2:        .asciiz "Player 2, please input your coordinates: "
    error_format:   .asciiz "Error: Invalid format. Please enter coordinates as 'x,y'.\n"
    error_range:    .asciiz "Error: Coordinates out of range. Must be between 0 and 14.\n"
    error_occupied: .asciiz "Error: That position is occupied. Try again.\n"
    player1_wins:   .asciiz "Player 1 wins!\n"
    player2_wins:   .asciiz "Player 2 wins!\n"
    tie_message:    .asciiz "Tie!\n"
    play_again:     .asciiz "Play again? (1 for yes, 0 for no): "
    restart_warning:.asciiz "Only enter 0 or 1 for contiue to play.\n "
    player_char:    .byte 'X', 'O'  
    comma:          .byte ','       
    result_file:    .asciiz "result.txt" 
    buffer:         .space 3000     

.text
main:
	li $s1, 0
	jal new_game
	li $v0, 10
	syscall

new_game:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 4
	la $a0, welcome
	syscall
	li $s0 , 0
	jal board_initialization
	jal display_board
	
game_play:
	li $v0, 4
   	beq $s0, $0, prompt_player1
   	la $a0, prompt2
    	j display_prompt
    	
prompt_player1:
	la $a0, prompt1
	
display_prompt:
	syscall
	
	jal get_player_input
	move $t0, $v0                 
    	move $t1, $v1
    	
    	mul $t2, $t0, 15
    	add $t2, $t2, $t1
    	
    	la $t3, board
    	add $t3, $t3, $t2
    	lb $t4, player_char($s0)       
    	sb $t4, 0($t3)
    	
    	addi $s1, $s1, 1
    	
    	jal display_board
    	
    	move $s5, $t0                  
    	move $s6, $t1                  
    	lb $a2, player_char($s0)   
    	jal check_win
    	beq $v0, $0, continue_game
    	j check_winner
    	
continue_game:
	li $t5, 225
    	beq $s1, $t5, print_tie
    	xori $s0, $s0, 1
   	j game_play
   	
print_tie:
	li $v0, 4
	la $a0, tie_message
	syscall
	jal write_into_file
	j ask_play_again	
	
ask_play_again:
    	li $v0, 4
    	la $a0, play_again
    	syscall
    	
    	la $a0, buffer   
    	li $a1, 10
    	li $v0, 8
    	syscall
    	
    	la $t5, buffer
    	lb $t0, buffer
    	lb $t3, 1($t5)
    	bne $t3, 10, warning
    	li $t1, '0'
    	li $t2, '1'
    
    	beq $t0, $t2, reset_game
    	beq $t0, $t1, end_game
warning:
    	li $v0, 4
    	la $a0, restart_warning
    	syscall
    	
    	j ask_play_again
end_game:    	
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra

reset_game:
    	li $s1, 0
    	li $s0, 0
    	jal board_initialization
    	jal display_board
    	j game_play
	
   	
    	     
board_initialization:
	la $t0, board
	li $t1, 0
	li $t2, 225
	li $t3, ' '
init_loop:
	beq $t1, $t2, init_done
	sb $t3, 0($t0)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j init_loop
	
init_done: 
jr $ra

display_board:
	addi $sp, $sp, -12
	sw $t1, 8($sp)
	sw $t0, 4($sp)
	sw $ra, 0($sp)
	li $v0, 4
    	la $a0, board_header
    	syscall
    	li $t0, 0
    	
display_row:
	li $t1, 15
	beq $t0, $t1, display_board_done
	blt $t0, 10, print_row_with_space
	li $v0, 1
    	move $a0, $t0
    	syscall
    	j after_print_row_number
    	
print_row_with_space:
    	li $v0, 4
    	la $a0, space_str
   	syscall
    	li $v0, 1
    	move $a0, $t0
    	syscall
after_print_row_number:
    	li $v0, 4
   	la $a0, board_row
    	syscall
    	li $t1, 0
    	
display_value:
	li $t2, 15
	beq $t1, $t2, display_value_done
	
	mul $t3, $t0, 15
	add $t3, $t3, $t1
	
	la $t4, board
	add $t4, $t4, $t3
	lb $a0, 0($t4)
	li $v0, 11
	syscall
	
	li $v0, 4
    	la $a0, row_separator
    	syscall
    	
    	addi $t1, $t1, 1
    	j display_value
    	
display_value_done:
	li $v0, 4
	la, $a0, newline
	syscall
	
	addi $t0, $t0, 1
	j display_row
	
display_board_done:
	li $v0, 4
    	la $a0, board_footer
    	syscall
    	
    	lw $ra, 0($sp)
    	lw $t0, 4($sp)
    	lw $t1, 8($sp)
    	addi $sp, $sp, 12
    	jr $ra
    	
get_player_input:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
get_pi_loop:
	li $v0, 8
    	la $a0, buffer                 
    	li $a1, 10                      
    	syscall

	la $t0, buffer     
    	li $t1, 0          
parse_x:
    	lb $t2, 0($t0)
    	lb $t3, comma
    	beq $t2, $t3, parse_y_start

    	li $t4, '0'
    	blt $t2, $t4, input_error
    	li $t4, '9'
    	bgt $t2, $t4, input_error

    	mul $t1, $t1, 10
    	li $t4, '0'
    	sub $t2, $t2, $t4
    	add $t1, $t1, $t2

    	addi $t0, $t0, 1
    	j parse_x

parse_y_start:
    	addi $t0, $t0, 1     
    	li $t5, 0            
parse_y:
    	lb $t2, 0($t0)
    	beq $t2, 10, parse_done    

    	li $t4, '0'
    	blt $t2, $t4, input_error
    	li $t4, '9'
    	bgt $t2, $t4, input_error

    	mul $t5, $t5, 10
    	li $t4, '0'
    	sub $t2, $t2, $t4
    	add $t5, $t5, $t2

    	addi $t0, $t0, 1
    	j parse_y

parse_done:
    	li $t6, 15
    	bltz $t1, out_of_range
    	bge $t1, $t6, out_of_range
    	bltz $t5, out_of_range
    	bge $t5, $t6, out_of_range

    	mul $t7, $t1, 15    
    	add $t7, $t7, $t5
    	la $t8, board
    	add $t8, $t8, $t7
    	lb $t9, 0($t8)
    	li $t4, ' '
    	bne $t9, $t4, occupied
    	move $v0, $t1
	move $v1, $t5

    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra

input_error:
    	li $v0, 4
    	la $a0, error_format
    	syscall
    	
    	beq $s0, $0, player1_fill
    	
    	li $v0, 4
	la $a0,  prompt2
	syscall
	j get_pi_loop

out_of_range:
    	li $v0, 4
    	la $a0, error_range
    	syscall
    	beq $s0, $0, player1_fill
    	
    	li $v0, 4
	la $a0,  prompt2
	syscall
	j get_pi_loop

occupied:
    	li $v0, 4
    	la $a0, error_occupied
    	syscall
    	beq $s0, $0, player1_fill
    	
    	li $v0, 4
	la $a0,  prompt2
	syscall
	j get_pi_loop

player1_fill:
	li $v0, 4
	la $a0,  prompt1
	syscall
	j get_pi_loop
	
check_win:
	addi $sp, $sp, -8
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	li $v0, 0     
	
	# Check horizontal
	li $t7, 0      
	li $t8, 0      
	li $t9, 1      
	jal check_direction
	beq $v0, 1, win_found
	
	# Check vertical
	li $t7, 0    
	li $t8, 1      
	li $t9, 0     
	jal check_direction
	beq $v0, 1, win_found
	
	# Check right diagonal 
	li $t7, 0     
	li $t8, -1     
	li $t9, 1
	jal check_direction
	beq $v0, 1, win_found
	
	# Check left diagonal 
	li $t7, 0     
	li $t8, -1     
	li $t9, -1     
	jal check_direction
	beq $v0, 1, win_found
	
	j check_win_exit
	
win_found:
	li $v0, 1
	
check_win_exit:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra

check_direction:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $t7, $t7, 1
	# Forward direction
	move $t3, $s5
	move $t4, $s6
	
forward_loop:
	# Move to next position
	add $t3, $t3, $t8
	add $t4, $t4, $t9
	
	bltz $t3, backward_check 
	bge $t3, 15, backward_check
	bltz $t4, backward_check
	bge $t4, 15, backward_check
	
	mul $t5, $t3, 15
	add $t5, $t5, $t4
	
	la $t6, board
	add $t6, $t6, $t5
	lb $s7, 0($t6)
	bne $s7, $a2, backward_check
	addi $t7, $t7, 1
	addi $s7, $0, 5
	beq $t7, $s7, win_flag
	
	j forward_loop
	
backward_check:
	
	move $t3, $s5
	move $t4, $s6
	
	# Reverse direction
	mul $t8, $t8, -1
	mul $t9, $t9, -1
	
backward_loop:
	add $t3, $t3, $t8
	add $t4, $t4, $t9
	
	# Check boundaries
	bltz $t3, no_win
	bge $t3, 15, no_win
	bltz $t4, no_win
	bge $t4, 15, no_win
	
	mul $t5, $t3, 15
	add $t5, $t5, $t4
	
	la $t6, board
	add $t6, $t6, $t5
	lb $s7, 0($t6)
	bne $s7, $a2, no_win
	
	# Increment counter
	addi $t7, $t7, 1
	
	# Check if 5 in a row
	li $s7, 5
	beq $t7, $s7, win_flag
	
	j backward_loop
	
win_flag:
	li $v0, 1
	j direction_exit
	
no_win:
	li $v0, 0 
	
direction_exit:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

check_winner:
	addi $t9, $0, 1
	beq $s0, $t9, player2_win
	
	li $v0, 4
	la $a0, player1_wins
	j print_result
player2_win:
	li $v0, 4
	la $a0, player2_wins
print_result:
	syscall
	jal write_into_file
	j ask_play_again
	
write_into_file:
    	addi $sp, $sp, -4
   	sw $ra, 0($sp)
   
    	li $v0, 13
    	la $a0, result_file
   	li $a1, 1          
    	li $a2, 0          
    	syscall
    
    	move $s4, $v0     
    	la $t0, buffer     
    	la $t1, board_header
    	
header_loop:
    	lb $t2, 0($t1)
    	beqz $t2, write_board_rows
    	sb $t2, 0($t0)
    	addi $t0, $t0, 1
    	addi $t1, $t1, 1
    	j header_loop

write_board_rows:
    	li $t1, 0          
row_loop:
    	li $t2, 15
    	beq $t1, $t2, write_footer
    
    	blt $t1, 10, write_space_num
    	j write_row_num
    
write_space_num:
    	li $t3, ' '
    	sb $t3, 0($t0)
    	addi $t0, $t0, 1
    
write_row_num:
    	li $t3, '0'
    	bge $t1, 10, write_row_num2
    	add $t3, $t3, $t1
    	sb $t3, 0($t0)
    	addi $t0, $t0, 1
    	la $t3, board_row
    	j copy_row_sep
write_row_num2:
	move $t4, $t1
	div $t4, $t4, 10
	mflo $t5            
    	mfhi $t6
    	add $t5, $t5, $t3
    	sb $t5, 0($t0)
    	addi $t0, $t0, 1
    	add $t6, $t6, $t3
    	sb $t6, 0($t0)
    	addi $t0, $t0, 1
    	la $t3, board_row
copy_row_sep:
    	lb $t4, 0($t3)
    	beqz $t4, write_row_content
    	sb $t4, 0($t0)
    	addi $t0, $t0, 1
    	addi $t3, $t3, 1
    	j copy_row_sep
    
write_row_content:
    	li $t2, 0         
    
col_loop:
    	li $t3, 15
    	beq $t2, $t3, end_row
   
    	mul $t4, $t1, 15
    	add $t4, $t4, $t2
    	la $t5, board
    	add $t5, $t5, $t4
    	lb $t6, 0($t5)     
    
    	sb $t6, 0($t0)
    	addi $t0, $t0, 1
    	la $t5, row_separator
copy_sep:
    	lb $t6, 0($t5)
    	beqz $t6, next_col
    	sb $t6, 0($t0)
    	addi $t0, $t0, 1
    	addi $t5, $t5, 1
    	j copy_sep
    
next_col:
    	addi $t2, $t2, 1
    	j col_loop
    
end_row:
    	li $t3, '\n'
    	sb $t3, 0($t0)
    	addi $t0, $t0, 1
    
    	addi $t1, $t1, 1
    	j row_loop   
    
write_footer:
    	la $t1, board_footer
footer_loop:
    	lb $t2, 0($t1)
    	beqz $t2, write_winner
    	sb $t2, 0($t0)
   	 addi $t0, $t0, 1
    	addi $t1, $t1, 1
    	j footer_loop
    
write_winner:
	lw $t3, 0($sp)
	la $t4, print_tie
	addi $t4, $t4, 20
	beq $t3, $t4, write_tie
    	addi $t1, $0, 1
    	beq $s0, $t1, write_player2_win   
    	la $t1, player1_wins
    	j copy_result_msg
    
write_player2_win:
    	la $t1, player2_wins
    	j copy_result_msg
    
write_tie:
    	la $t1, tie_message
    
copy_result_msg:
    	lb $t2, 0($t1)
    	beqz $t2, finish_buffer
    	sb $t2, 0($t0)
    	addi $t0, $t0, 1
    	addi $t1, $t1, 1
    	j copy_result_msg
    
finish_buffer:
    	li $t2, 0
    	sb $t2, 0($t0)
    
    	la $t1, buffer
    	sub $t2, $t0, $t1   
    
    	li $v0, 15
    	move $a0, $s4      
    	la $a1, buffer     
    	move $a2, $t2      
    	syscall
    
   	li $v0, 16
    	move $a0, $s4
    	syscall
    
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
    	
	
	
		
	
	
	
	
	
