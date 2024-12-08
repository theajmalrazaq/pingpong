org 100h
jmp start
;==============================================================================
; Data Segment - Game Variables and Constants
;==============================================================================
welcome_message db 'Welcome to Ping Pong Game Developed By Ajmal Razaq & Ahmad Rohan', '$'
game_over_msg db 'Game Over! Press ESC to exit or SPACE to play again', '$'
player_1_name db 'Player One: ','$'
player_2_name db 'Player Two: ','$'
pattern_x db 2    
pattern_y db 2    
pattern_dir db 0  
pattern dw 0

pattern_no db 'Press SPACE to start the game without Moving Patterns', '$'
pattren_star db 'Press 1 for Star Background' ,'$'
pattren_line db 'Press 2 for Line Background' ,'$'
pattren_arrow db 'Press 3 for Arrow Background' ,'$'


paddle_1_x db 2   
paddle_1_y db 12  
paddle_2_x db 77
paddle_2_y db 12 
ball_pos db 40, 12  ; Ball starting position (center)
ball_dir db 1, 1    ; Ball direction (X, Y)
ball_char db 'O'    ; Ball character
ball_color db 0x0F  ; Ball color (white on black)
player_1_score db 0 
player_2_score db 0
player_1_win_msg db 'Player one has won!', '$'
player_2_win_msg db 'Player two has won!', '$'
max_score db 5      ; Game ends when a player reaches this score
game_speed dw 8     ; Increase this number to slow down the ball


pause_msg db 'GAME PAUSED - Press P to Resume', '$'
is_paused db 0    ; 0 = running, 1 = paused

;==============================================================================
; Sound Effect Functions
;==============================================================================
play_paddle_hit:
    push ax
    push bx
    push cx
    
    mov al, 182         ; Prepare the speaker for the note
    out 43h, al         
    mov ax, 2000        ; Frequency for paddle hit (higher pitch)
    out 42h, al         ; Output low byte
    mov al, ah          ; Output high byte
    out 42h, al 
    
    in al, 61h         ; Turn speaker on
    or al, 00000011b
    out 61h, al
    
    mov cx, 1          ; Short duration
    call sound_delay
    
    in al, 61h         ; Turn speaker off
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
    mov ax, 2500        ; Different frequency for wall bounce
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

play_score:
    push ax
    push bx
    push cx
    
    mov al, 182
    out 43h, al
    mov ax, 1500        ; Lower frequency for scoring
    out 42h, al
    mov al, ah
    out 42h, al
    
    in al, 61h
    or al, 00000011b
    out 61h, al
    
    mov cx, 4          ; Longer duration for score sound
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
    mov ax, 500         ; Very low frequency for game over
    out 42h, al
    mov al, ah
    out 42h, al
    
    in al, 61h
    or al, 00000011b
    out 61h, al
    
    mov cx, 8          ; Longest duration for game over
    call sound_delay
    
    in al, 61h
    and al, 11111100b
    out 61h, al
    
    pop cx
    pop bx
    pop ax
    ret

sound_delay:
    push dx
    push ax
sound_delay_loop:
    mov dx, 8000
delay_inner:
    dec dx
    jnz delay_inner
    loop sound_delay_loop
    pop ax
    pop dx
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
; Print Pattern - Fills entire playable area with pattern
;==============================================================================
print_pattern:
    ; [Previous code remains the same until the pattern printing logic]
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
    
    mov dx, 22
row_loop:
    mov cx, 5
    push di
    
column_loop:
    mov si,[pattern]
    mov word [es:di],si
    add di, 2
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
; Update pattern - Modified for left-to-right movement with reset
;=============================================================================
update_pattern:
    push ax
    
    ; Always move right
    inc byte [pattern_x]
    
    ; Check if pattern reached right edge
    cmp byte [pattern_x], 74
    jl pattern_done
    
    ; Reset to left side when reaching right edge
    mov byte [pattern_x], 3    ; Reset to starting X position
    
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
    
    ; Top wall
    mov di, 2          
    mov cx, 78         
    mov ax, 0x073D     
    rep stosw


    mov di, 322          
    mov cx, 78         
    mov ax, 0x073D     
    rep stosw
    
    ; Bottom wall
    mov di, 3840       
    mov cx, 80         
    rep stosw
    
    ; Left wall
    mov di, 0        
    mov cx, 25         
wall_left_1:
    mov word [es:di], 0x077C
    add di, 160        
    loop wall_left_1
        ; Left wall
    mov di, 2       
    mov cx, 25         
wall_left_2:
    mov word [es:di], 0x077C
    add di, 160        
    loop wall_left_2

    ; Right wall
    mov di, 156       
    mov cx, 25         
wall_right_1:
    mov word [es:di], 0x077C
    add di, 160        
    loop wall_right_1
        ; Right wall
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

    ; Print ball character with attribute
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
    
    ; Check wall collisions
    cmp byte [ball_pos+1], 3    ; Top wall
    jle reverse_y
    cmp byte [ball_pos+1], 23   ; Bottom wall
    jge reverse_y
    
    ; Check paddle collisions
    mov al, [ball_pos]
    cmp al, 3                   ; Left paddle area
    je check_left_paddle
    cmp al, 76                  ; Right paddle area
    je check_right_paddle
    
    ; Check for scoring
    cmp al, 0                   ; Ball passed left side
    jle right_scores
    cmp al, 78                  ; Ball passed right side
    jge left_scores
    
    jmp update_ball_done

reverse_y:
    neg byte [ball_dir+1]
     call play_wall_bounce   ; Add this line
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
    call play_paddle_hit    ; Add this line
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
     call play_paddle_hit    ; Add this line
    jmp update_ball_done

left_scores:
    inc byte [player_1_score]
      call play_score         ; Add this line
    call reset_ball
    jmp update_ball_done

right_scores:
    inc byte [player_2_score]
    call play_score         ; Add this line
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
 
    ; Print Player 1 name
    mov ax, player_1_name
    push ax                  ; String offset
    mov ax, 11              ; String length
    push ax
    mov ax, 0x0114         ; Row 1, Column 20
    push ax
    mov al, 0x07            ; Color attribute (light gray)
    push ax
    call print_string

    ; Player 1 score
    mov dh, 1               ; Row
    mov dl, 32              ; Column (after name)
    mov bh, 0              ; Page
    mov ah, 02h            ; Set cursor position
    int 10h

    mov al, [player_1_score]
    add al, '0'            ; Convert to ASCII
    mov bl, 0x07           ; Color attribute (light gray)
    mov cx, 1              ; Character count
    mov ah, 09h            ; Write character
    int 10h

    ; Print Player 2 name
    mov ax, player_2_name
    push ax                ; String offset
    mov ax, 11            ; String length
    push ax
    mov ax, 0x0132        ; Row 1, Column 50
    push ax
    mov al, 0x07          ; Color attribute (light gray)
    push ax
    call print_string

    ; Player 2 score
    mov dh, 1             ; Row
    mov dl, 62            ; Column (after name)
    mov bh, 0            ; Page
    mov ah, 02h          ; Set cursor position
    int 10h

    mov al, [player_2_score]
    add al, '0'          ; Convert to ASCII
    mov bl, 0x07         ; Color attribute (light gray)
    mov cx, 1            ; Character count
    mov ah, 09h          ; Write character
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret


;==============================================================================
; Delay function
;==============================================================================
delay:
    push cx
    push dx
    push ax
    mov cx, [game_speed]  
ball_delay_loop:
    push cx
    mov cx, 0FFFFh        ; Adjust this value to fine-tune the delay
inner_delay:
    loop inner_delay
    pop cx
    loop ball_delay_loop
    
    pop ax
    pop dx
    pop cx
    ret
;==============================================================================
; Print Paddle Functions
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
; Pattern setup functions - Modified with charcoal color
;==============================================================================
set_pattern_star:
    mov ax, 0x082A          ; 08 = charcoal attribute, 2A = ASCII for '*'
    mov [pattern], ax
    jmp game_loop

set_pattern_line:
    mov ax, 0x082D          ; 08 = charcoal attribute, 2D = ASCII for '-'
    mov [pattern], ax
    jmp game_loop

set_pattern_arrow:
    mov ax, 0x083E          ; 08 = charcoal attribute, 3E = ASCII for '>'
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
    mov ax, 31              ; Length of pause message
    push ax
    mov ax, 0x0C1A         ; Row 12, Column 28 (centered)
    push ax
    mov al, 0x0E           ; Yellow color
    push ax
    call print_string
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;==============================================================================
; Handle Pause/Resume
;==============================================================================
check_pause:
    push ax
    
    ; Check if P key was pressed
    cmp al, 'p'
    je toggle_pause
    cmp al, 'P'
    je toggle_pause
    jmp check_pause_done
    
toggle_pause:
    ; Toggle pause state
    xor byte [is_paused], 1
    
    ; If now paused, show pause message
    cmp byte [is_paused], 1
    je show_pause
    
    ; If unpaused, just return to game
    jmp check_pause_done
    
show_pause:
    call print_pause_message
    
pause_loop:
    ; Wait for key press while paused
    mov ah, 00h
    int 16h
    
    ; Check if P pressed again
    cmp al, 'p'
    je unpause
    cmp al, 'P'
    je unpause
    jmp pause_loop
    
unpause:
    ; Clear pause message by redrawing screen
    xor byte [is_paused], 1
    
check_pause_done:
    pop ax
    ret


show_welcome_screen:
    ; Clear the screen before showing messages
    call clear_screen
    
    ; Show main welcome message
    mov ax, welcome_message
    push ax                  ; String offset
    mov ax, 64              ; Message length (64 characters)
    push ax
    mov ax, 0x0408          ; Position: Row 4, Column 8
    push ax
    mov al, 0x0A            ; Color: Bright green
    push ax
    call print_string

    ; Show pattern selection message
    mov ax, pattern_no
    push ax                  ; String offset
    mov ax, 53              ; Message length (53 characters)
    push ax
    mov ax, 0x0808          ; Position: Row 8, Column 8
    push ax
    mov al, 0x0A            ; Color: Bright green
    push ax
    call print_string

    ; Show star pattern option
    mov ax, pattren_star    ; Note: "pattern" is misspelled in variable name
    push ax                  ; String offset
    mov ax, 27              ; Message length (27 characters)
    push ax
    mov ax, 0x091A          ; Position: Row 9, Column 26
    push ax
    mov al, 0x0A            ; Color: Bright green
    push ax
    call print_string

    ; Show line pattern option
    mov ax, pattren_line    ; Note: "pattern" is misspelled in variable name
    push ax                  ; String offset
    mov ax, 27              ; Message length (27 characters)
    push ax
    mov ax, 0x0A1A          ; Position: Row 10, Column 26
    push ax
    mov al, 0x0A            ; Color: Bright green
    push ax
    call print_string

    ; Show arrow pattern option
    mov ax, pattren_arrow   ; Note: "pattern" is misspelled in variable name
    push ax                  ; String offset
    mov ax, 28              ; Message length (28 characters)
    push ax
    mov ax, 0x0B1A          ; Position: Row 11, Column 26
    push ax
    mov al, 0x0A            ; Color: Bright green
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
    cmp al, 32             ; Space key
    je no_key_pressed
    
    ; If any other key is pressed, keep waiting
    jmp handle_welcome_input
;==============================================================================
; Start of the game
;==============================================================================
start:
     ; Show welcome message
    call clear_screen
    call show_welcome_screen

    ; Wait for valid input only
    call handle_welcome_input

    mov ah, 00h
    int 16h
    cmp al,'1'
    je set_pattern_star
    cmp al,'2'
    je set_pattern_line
    cmp al,'3'
    je set_pattern_arrow
    cmp al,32
    je no_key_pressed
    in al, 21h
    or al, 2 
    out 21h, al 

game_loop:
    call clear_screen
    call print_pattern
    call update_pattern
    call print_walls
    call print_ball
    call print_paddle_1
    call print_paddle_2
    call print_scores
    call update_ball
    
    ; Check for game over
    call check_game_over
    jc show_game_over
    
    ; Check for keyboard input
    mov ah, 01h
    int 16h
    jz no_key_pressed
    
    mov ah, 00h
    int 16h
    
    ; First check for pause
    call check_pause
    cmp byte [is_paused], 1
    je game_loop    ; If paused, keep looping without updates
    
    ; Then check other controls
    cmp ah, 0x11
    je move_left_up
    cmp ah,0x1F
    je move_left_down
    cmp ah, 0x48            ; Up arrow
    je move_right_up
    cmp ah, 0x50             ; Down arrow
    je move_right_down
    

    
no_key_pressed:
    call delay
    jmp game_loop

move_left_up:
    cmp byte [paddle_1_y], 3
    jle no_key_pressed
    dec byte [paddle_1_y]
    jmp no_key_pressed

move_left_down:
    cmp byte [paddle_1_y], 20
    jge no_key_pressed
    inc byte [paddle_1_y]
    jmp no_key_pressed

move_right_up:
    cmp byte [paddle_2_y], 3
    jle no_key_pressed
    dec byte [paddle_2_y]
    jmp no_key_pressed

move_right_down:
    cmp byte [paddle_2_y], 20
    jge no_key_pressed
    inc byte [paddle_2_y]
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

game_is_over:
 call play_game_over     ; Add this line
    pop ax
    stc                     ; Set carry flag - game is over
    ret

show_game_over:
    call clear_screen

    mov al, [player_1_score]
    cmp al, [player_2_score]
    jg player_1_wins        ; Jump if player 1 has higher score
    jl player_2_wins        ; Jump if player 2 has higher score
    je show_final_message   ; Jump if scores are equal

player_1_wins:
    mov ax, player_1_win_msg
    push ax
    mov ax, 19              ; Length of win message
    push ax
    mov ax, 0x0A1C         ; Row 12, Column 16
    push ax
    mov al, 0x0F           ; White color
    push ax
    call print_string
    jmp show_final_message

player_2_wins:
    mov ax, player_2_win_msg
    push ax
    mov ax, 19              ; Length of win message
    push ax
    mov ax, 0x0A1C        ; Row 12, Column 16
    push ax
    mov al, 0x0F           ; White color
    push ax
    call print_string
    
show_final_message:
    mov ax, game_over_msg
    push ax
    mov ax, 45              ; Length of game over message
    push ax
    mov ax, 0x0C10         ; Row 12, Column 16
    push ax
    mov al, 0x0F           ; White color
    push ax
    call print_string
    jmp wait_key           ; Jump to key wait routine

wait_key:
    mov ah, 00h
    int 16h
    cmp al, 27           
    je exit_game
    cmp al, 32            
    je restart_game
    jmp wait_key

restart_game:
    ; Reset scores and ball position
    mov byte [player_1_score], 0
    mov byte [player_2_score], 0
    call reset_ball
    jmp game_loop

exit_game:
    mov ax, 4C00h
    int 21h
