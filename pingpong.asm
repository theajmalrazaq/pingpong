org 100h
jmp start
;==============================================================================
;Game Variables and Constants
;==============================================================================
;messages to print
welcome_message db 'Developed By Ajmal Razaq', '$'
game_over_msg db 'Game Over! Press ESC to exit or SPACE to play again', '$'
pattern_no db 'Press SPACE to start the game without Moving Patterns', '$'
pattern_star db 'Press 1 for Star Background' ,'$'
pattern_line db 'Press 2 for Line Background' ,'$'
pattern_arrow db 'Press 3 for Arrow Background' ,'$'
player_1_name db 'Player One: ','$'
player_2_name db 'Player Two: ','$'
player_1_win_msg db 'Player one has won!', '$'
player_2_win_msg db 'Player two has won!', '$'


;pattern_configs
pattern_x db 2    ;column
pattern_y db 5   ;row
pattern_dir db 0  
pattern dw 0


;paddles_positions
paddle_1_x db 2   ;column
paddle_1_y db 12  ;row
paddle_2_x db 77  ;column
paddle_2_y db 12  ;rowB

;ball_config
ball_pos db 40, 12  ; Ball starting position
ball_dir db 1, 1    ; Ball direction (X, Y)
ball_char db 'O'    ; Ball character
ball_color db 0x0F  ; Ball color (white on black)


;scores
player_1_score db 0 
player_2_score db 0
max_score db 5      ; max score to win

;game_configs
game_speed dw 1     ; Increase this number to slow down the ball
pause_msg db 'GAME PAUSED - Press P to Resume', '$'
is_paused db 0    ; 0 = running, 1 = paused

;==============================================================================
; Sound Effect Functions
;==============================================================================
play_paddle_hit:
    push ax
    push bx
    push cx
    
    mov al, 182         ; make speaker ready
    out 43h, al         
    mov ax, 2000        ; Frequency of sound
    out 42h, al         ; Output low byte
    mov al, ah          ; Output high byte
    out 42h, al 
    
    in al, 61h         ; speaker on
    or al, 00000011b
    out 61h, al
    
    mov cx, 1 
    call sound_delay

    in al, 61h         ; speaker off
    and al, 11111100b
    out 61h, al
    pop cx
    pop bx
    pop ax
    ret

play_crash:
    push ax
    push bx
    push cx
    
    mov al, 182
    out 43h, al
    mov ax, 800        
    out 42h, al
    mov al, ah
    out 42h, al
    
    in al, 61h
    or al, 00000011b
    out 61h, al
    
    mov cx, 5
    call sound_delay
    
    in al, 61h
    and al, 11111100b
    out 61h, al
    
    pop cx
    pop bx
    pop ax
    ret


    play_wall_bounce:
    push ax
    push bx
    push cx
    
    mov al, 182
    out 43h, al
    mov ax, 2500        
    out 42h, al
    mov al, ah
    out 42h, al
    
    in al, 61h
    or al, 00000011b
    out 61h, al
    
    mov cx, 1
    call sound_delay
    
    in al, 61h
    and al, 11111100b
    out 61h, al
    
    pop cx
    pop bx
    pop ax
    ret

play_game_over:
    push ax
    push bx
    push cx
    
    mov al, 182
    out 43h, al
    mov ax, 4000         
    out 42h, al
    mov al, ah
    out 42h, al
    
    in al, 61h
    or al, 00000011b
    out 61h, al
    
    mov cx, 20          
    call sound_delay
    
    in al, 61h
    and al, 11111100b
    out 61h, al
    
    pop cx
    pop bx
    pop ax
    ret



    play_move_paddle:
    push ax
    push bx
    push cx
    
    mov al, 182
    out 43h, al
    mov ax, 200         ; Very low frequency for game over
    out 42h, al
    mov al, ah
    out 42h, al
    
    in al, 61h
    or al, 00000011b
    out 61h, al
    
    mov cx, 5          ; Longest duration for game over
    call sound_delay
    
    in al, 61h
    and al, 11111100b
    out 61h, al
    
    pop cx
    pop bx
    pop ax
    ret

sound_delay:
    push ax
    push cx 
    push dx
    mov ah, 86h       
    mov cx, 0          
    mov dx, 200       
    int 15h      
    pop dx
    pop cx 
    pop ax      
    ret


;==============================================================================
; Clear Screen Using BIOS Interrupt
;==============================================================================
clear_screen:
    push ax
    mov ah, 00h        
    mov al, 03h    
    int 10h
    pop ax
    ret

;==============================================================================
; Print moving pattern
;==============================================================================
print_pattern:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0xB800
    mov es, ax
    
    mov al, [pattern_y]
    mov bl, 160
    mul bl
    mov di, ax
    mov al, [pattern_x]
    mov bl, 2
    mul bl
    add di, ax
    mov dx, 20 
row_loop:
    mov cx, 5
    push di
column_loop:
    mov si,[pattern]
    mov word [es:di],si
    add di,2
    loop column_loop
    
    pop di
    add di, 160
    dec dx
    jnz row_loop

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;=============================================================================
; Update pattern
;=============================================================================
update_pattern:
    push ax
    
    ; Always move right
    inc byte [pattern_x]
    
    ; Check if pattern reached right edge
    cmp byte [pattern_x], 78
    jl pattern_done
    
    ; Reset to left side when reaching right edge
    mov byte [pattern_x], 0    ; Reset to starting X position
    
pattern_done:
    pop ax
    ret




;==============================================================================
; Print string at specified position
;==============================================================================
print_string:
    push bp
    mov bp, sp         
    push ax
    push bx
    push cx
    push dx
    push es
    
    mov ah, 13h        
    mov al, 00h        
    mov bh, 00h        
    mov bl, [bp+4]     
    mov dx, [bp+6]     
    mov cx, [bp+8]     
    mov bp, [bp+10]    
    
    push cs
    pop es             
    int 10h
    
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8             

;==============================================================================
; Print Walls
;==============================================================================
print_walls:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xB800
    mov es, ax
    
    mov ax, welcome_message
    push ax               
    mov ax, 24              ; Message length
    push ax
    mov ax, 0x031C         
    push ax
    mov al, 0x0F          
    push ax
    call print_string

    ; Top wall_1
    mov di, 0          
    mov cx, 78         
    mov ax, 0x073D     
    rep stosw

    ;top wall_2
    mov di, 640          
    mov cx, 78         
    mov ax, 0x073D     
    rep stosw
    
    ; Bottom wall
    mov di, 3840       
    mov cx, 80         
    rep stosw



    ; Left wall 1
    mov di, 0        
    mov cx, 25         
wall_left_1:
    mov word [es:di], 0x077C
    add di, 160        
    loop wall_left_1
    ; Left wall 2
    mov di, 2       
    mov cx, 25         
wall_left_2:
    mov word [es:di], 0x077C
    add di, 160        
    loop wall_left_2




    ;Right wall 1
    mov di, 156       
    mov cx, 25         
wall_right_1:
    mov word [es:di], 0x077C
    add di, 160        
    loop wall_right_1
    ;Right wall 2
    mov di, 158      
    mov cx, 25         
wall_right_2:
    mov word [es:di], 0x077C
    add di, 160        
    loop wall_right_2




    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;==============================================================================
; Print Ball
;==============================================================================
print_ball:
    push ax
    push bx
    push dx
    push es

    mov ax, 0xB800
    mov es, ax

    ; Calculate ball position in video memory
    xor ax, ax
    mov al, [ball_pos+1]   ; Y position
    mov bx, 160
    mul bx
    xor bx, bx
    mov bl, [ball_pos]     ; X position
    shl bx, 1
    add ax, bx
    mov di, ax

    ; Print ball character
    mov ah, [ball_color]
    mov al, [ball_char]
    mov word [es:di], ax

    pop es
    pop dx
    pop bx
    pop ax
    ret

;==============================================================================
; Update Ball Position
;==============================================================================
update_ball:
    push ax
    push bx
    
    ; Update X position
    mov al, [ball_dir]
    add [ball_pos], al
    
    ; Update Y position
    mov al, [ball_dir+1]
    add [ball_pos+1], al
    
    ; Check walls hits
    cmp byte [ball_pos+1], 5    ; Top wall
    jle reverse_y
    cmp byte [ball_pos+1], 23   ; Bottom wall
    jge reverse_y
    
    ; Check paddle hit
    mov al, [ball_pos]
    cmp al, 3                   ; Left paddle area
    je check_left_paddle
    cmp al, 76                  ; Right paddle area
    je check_right_paddle
    
    ; Check crash
    cmp al, 0                   ; Ball passed left side
    jle right_scores
    cmp al, 78                  ; Ball passed right side
    jge left_scores
    
    jmp update_ball_done

reverse_y:
    neg byte [ball_dir+1]
    call play_wall_bounce 
    jmp update_ball_done

check_left_paddle:
    mov al, [ball_pos+1]
    mov bl, [paddle_1_y]
    cmp al, bl
    jl no_paddle_hit
    add bl, 3
    cmp al, bl
    jg no_paddle_hit
    neg byte [ball_dir]
    call play_paddle_hit    
    jmp update_ball_done

check_right_paddle:
    mov al, [ball_pos+1]
    mov bl, [paddle_2_y]
    cmp al, bl
    jl no_paddle_hit
    add bl, 3
    cmp al, bl
    jg no_paddle_hit
    neg byte [ball_dir]
     call play_paddle_hit   
    jmp update_ball_done

left_scores:
    inc byte [player_1_score]
    call play_crash
    call reset_ball
    jmp update_ball_done

right_scores:
    inc byte [player_2_score]
    call play_crash
    call reset_ball

no_paddle_hit:
update_ball_done:
    pop bx
    pop ax
    ret

;==============================================================================
; Reset Ball Position
;==============================================================================
reset_ball:
    mov byte [ball_pos], 40     ; Center X
    mov byte [ball_pos+1], 12   ; Center Y
    mov byte [ball_dir], 1      ; Reset direction
    mov byte [ball_dir+1], 1
    ret

;==============================================================================
; Print Scores
;==============================================================================
print_scores:
    push ax
    push bx
    push cx
    push dx
 

    ;Print Player 1 name
    mov ax, player_1_name
    push ax                 
    mov ax, 11             
    push ax
    mov ax, 0x0114        
    push ax
    mov al, 0x0F           
    push ax
    call print_string

    ;Player 1 score
    mov dh, 1              
    mov dl, 32              
    mov bh, 0             
    mov ah, 02h            
    int 10h

    mov al, [player_1_score]
    add al, '0'           
    mov bl, 0x0F           
    mov cx, 1              
    mov ah, 09h            
    int 10h

    ; Print Player 2 name
    mov ax, player_2_name
    push ax                
    mov ax, 11            
    push ax
    mov ax, 0x0132        
    push ax
    mov al, 0x0F         
    push ax
    call print_string

    ; Player 2 score
    mov dh, 1            
    mov dl, 62           
    mov bh, 0           
    mov ah, 02h         
    int 10h

    mov al, [player_2_score]
    add al, '0'         
    mov bl, 0x0F       
    mov cx, 1            
    mov ah, 09h          
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret


;==============================================================================
; Delay subroutine 
;==============================================================================
delay:
    push cx
    push dx
    push ax
    mov cx, [game_speed]  
    
delay_loop:
    mov ah, 86h           
    xor dx, dx            
    int 15h              
    loop delay_loop      
    
    pop ax
    pop dx
    pop cx
    ret

;==============================================================================
; Print Paddles
;==============================================================================
print_paddle_1:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xB800
    mov es, ax
    
    mov al, [paddle_1_y]
    mov bl, 160
    mul bl
    mov di, ax
    mov al, [paddle_1_x]
    mov bl, 2
    mul bl
    add di, ax
    
    mov dx, 3           ; Paddle height
paddle1_row:
    mov word [es:di], 0x0CDB
    add di, 160
    dec dx
    jnz paddle1_row
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_paddle_2:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xB800
    mov es, ax
    
    mov al, [paddle_2_y]
    mov bl, 160
    mul bl
    mov di, ax
    mov al, [paddle_2_x]
    mov bl, 2
    mul bl
    add di, ax
    
    mov dx, 3           ; Paddle height
paddle2_row:
    mov word [es:di], 0x0CDB
    add di, 160
    dec dx
    jnz paddle2_row
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;==============================================================================
; set pattern according to player choice
;==============================================================================
set_pattern_star:
    mov ax, 0x082A          ; 2A = ASCII for '*'
    mov [pattern], ax
    jmp game_loop

set_pattern_line:
    mov ax, 0x082D          ;  2D = ASCII for '-'
    mov [pattern], ax
    jmp game_loop

set_pattern_arrow:
    mov ax, 0x083E          ; 3E = ASCII for '>'
    mov [pattern], ax
    jmp game_loop


;==============================================================================
; Print Pause Message
;==============================================================================
print_pause_message:
    push ax
    push bx
    push cx
    push dx
    
    mov ax, pause_msg
    push ax
    mov ax, 31              
    push ax
    mov ax, 0x0C1A         
    push ax
    mov al, 0x0F        
    push ax
    call print_string
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;================================================================
;on keypress subroutines
;=================================================================
no_key_pressed:
    call delay
    jmp game_loop

move_left_up:
    cmp byte [paddle_1_y], 5
    jle no_key_pressed
    dec byte [paddle_1_y]
    call play_move_paddle
    jmp no_key_pressed

move_left_down:
    cmp byte [paddle_1_y], 21
    jge no_key_pressed
    inc byte [paddle_1_y]
    call play_move_paddle
    jmp no_key_pressed

move_right_up:
    cmp byte [paddle_2_y], 5
    jle no_key_pressed
    dec byte [paddle_2_y]
    call play_move_paddle
    jmp no_key_pressed

move_right_down:
    cmp byte [paddle_2_y], 21
    jge no_key_pressed
    inc byte [paddle_2_y]
    call play_move_paddle
    jmp no_key_pressed

;==============================================================================
; Handle Pause/Resume
;==============================================================================
check_pause:
    push ax
    
    cmp al, 'p'
    je toggle_pause
    cmp al, 'P'
    je toggle_pause
    jmp check_pause_done
    
toggle_pause:
    xor byte [is_paused], 1    ; Toggle pause state
    
    cmp byte [is_paused], 1
    je show_pause
    
    ; Clear keyboard buffer when unpausing
    mov ah, 0Ch
    mov al, 0
    int 21h
    
    jmp check_pause_done
    
show_pause:
    call print_pause_message
    
pause_loop:
    ; Wait for key press
    mov ah, 00h  
    int 16h
    
    ; Check if P pressed again
    cmp al, 'p'
    je unpause
    cmp al, 'P'
    je unpause
    jmp pause_loop
    
unpause:
    xor byte [is_paused], 1    ; Toggle pause state off
    
    ; Clear keyboard buffer
    mov ah, 0Ch
    mov al, 0
    int 21h
    
    ; Clear the pause message by refreshing screen
    call clear_screen
    
check_pause_done:
    pop ax
    ret


show_welcome_screen:
    call clear_screen
    ; Show welcome message
    mov ax, welcome_message
    push ax               
    mov ax, 24              ; Message length
    push ax
    mov ax, 0x041C         
    push ax
    mov al, 0x0F          
    push ax
    call print_string

    ; Show pattern selection
    mov ax, pattern_no
    push ax                 
    mov ax, 53              ; Message length 
    push ax
    mov ax, 0x0806          ; Position
    push ax
    mov al, 0x0F
    push ax
    call print_string

    ; Show star pattern option
    mov ax, pattern_star  
    push ax                
    mov ax, 27              ; Message length 
    push ax
    mov ax, 0x0906          ; Position
    push ax
    mov al, 0x0F         
    push ax
    call print_string

    ; Show line pattern option
    mov ax, pattern_line  
    push ax                 
    mov ax, 27              ; Message length
    push ax
    mov ax, 0x0A06          ; Position
    push ax
    mov al, 0x0F
    push ax
    call print_string

    ; Show arrow pattern option
    mov ax, pattern_arrow  
    push ax                  
    mov ax, 28              ; Message length 
    push ax
    mov ax, 0x0B06          ; Position
    push ax
    mov al, 0x0F
    push ax
    call print_string
    ret

;==============================================================================
; Handle welcome screen input
;==============================================================================
handle_welcome_input:
    mov ah, 00h
    int 16h
    
    ; Check for valid keys only
    cmp al, '1'
    je set_pattern_star
    cmp al, '2'
    je set_pattern_line
    cmp al, '3' 
    je set_pattern_arrow
    cmp al, 32      ;space
    je no_key_pressed
    
    ; If any other key is pressed, keep waiting
    jmp handle_welcome_input

;==============================================================================
; Start of the game
;==============================================================================
start:
    call clear_screen
    call show_welcome_screen
    call handle_welcome_input
  
game_loop:
    call clear_screen
    call print_pattern
    call update_pattern
    call print_walls
    call print_ball
    call print_paddle_1
    call print_paddle_2
    call print_scores
    
    ; Only update ball if game is not paused
    cmp byte [is_paused], 0
    jne skip_ball_update
    call update_ball
skip_ball_update:
    
    ; Check for game over
    call check_game_over
    jc show_game_over
    
    mov ah, 01h
    int 16h
    jz no_key_pressed
    
    mov ah, 00h
    int 16h
    
    push ax          ; Save key for later
    call check_pause
    pop ax          ; Restore key
    
    cmp byte [is_paused], 1
    je game_loop
    
    cmp ah, 0x11    ; w
    je move_left_up
    cmp ah, 0x1F    ; s
    je move_left_down
    cmp ah, 0x48    ; Up arrow
    je move_right_up
    cmp ah, 0x50    ; Down arrow
    je move_right_down
    cmp al, 27   
    je exit_1
    
    jmp no_key_pressed
    
;==============================================================================
; Game Over and Win Conditions
;==============================================================================
check_game_over:
    push ax
    
    mov al, [max_score]
    cmp [player_1_score], al
    jge game_is_over
    cmp [player_2_score], al
    jge game_is_over
    
    pop ax
    clc                     ; Clear carry flag - game not over
    ret

exit_1:
    jmp exit_game

game_is_over:
 call play_game_over    
    pop ax
    stc                     ; Set carry flag - game is over
    ret

show_game_over:
    call clear_screen

    mov al, [player_1_score]
    cmp al, [player_2_score]
    jg player_1_wins        
    jl player_2_wins       
    je show_final_message  

player_1_wins:
    mov ax, player_1_win_msg
    push ax
    mov ax, 19             
    push ax
    mov ax, 0x0A1C         
    push ax
    mov al, 0x0F          
    push ax
    call print_string
    jmp show_final_message

player_2_wins:
    mov ax, player_2_win_msg
    push ax
    mov ax, 19              
    push ax
    mov ax, 0x0A1C        
    push ax
    mov al, 0x0F
    push ax
    call print_string
    
show_final_message:
    mov ax, game_over_msg
    push ax
    mov ax, 45              
    push ax
    mov ax, 0x0C10        
    push ax
    mov al, 0x0F           
    push ax
    call print_string
    jmp wait_key          

wait_key:
    mov ah, 00h
    int 16h
    cmp al, 27           
    je exit_game
    cmp al, 32            
    je restart_game
    jmp wait_key

restart_game:
    mov byte [player_1_score], 0
    mov byte [player_2_score], 0
    call reset_ball
    jmp start

exit_game:
    call clear_screen
    mov ax, 4C00h
    int 21h
