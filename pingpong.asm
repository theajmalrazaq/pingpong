org 100h
jmp start

;==============================================================================
; Data Segment - Game Variables and Constants
;==============================================================================
welcome_message db 'Welcome to Ping Pong Game Developed By Ajmal Razaq & Ahmad Rohan', '$'
game_over_msg db 'Game Over! Press ESC to exit or SPACE to play again', '$'
pattern_x db 2    
pattern_y db 2    
pattern_dir db 0  
pattern dw 0

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
max_score db 5      ; Game ends when a player reaches this score
game_speed dw 10     ; Increase this number to slow down the ball

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
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    ; Set up video memory segment
    mov ax, 0xB800
    mov es, ax
    
    ; Calculate starting position based on pattern_x and pattern_y
    mov al, [pattern_y]        ; Load Y position
    mov bl, 160               ; Bytes per row
    mul bl                    ; AX = Y * 160
    mov di, ax               ; DI = Y * 160
    mov al, [pattern_x]       ; Load X position
    mov bl, 2                ; 2 bytes per character
    mul bl                   ; AX = X * 2
    add di, ax              ; Add X offset to DI
    
    mov dx, 22               ; Height of pattern (reduced for faster movement)
row_loop:
    mov cx, 5              ; Width of pattern (reduced for faster movement)
    push di               ; Save start position of current row
    
column_loop:
    mov si,[pattern]
    mov word [es:di],si  ; Light gray hyphen character
    add di, 2                   ; Move to next column
    loop column_loop
    
    pop di             ; Restore row start position
    add di, 160        ; Move to next row
    dec dx
    jnz row_loop       ; Continue until all rows are done

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;=============================================================================
; Update pattren
;=============================================================================
update_pattern:
    push ax
    
    mov al, [pattern_dir]
    cmp al, 0          ; Moving right
    je pattern_right
    cmp al, 2          ; Moving left  
    je pattern_left
    jmp pattern_done

pattern_right:
    inc byte [pattern_x]
    cmp byte [pattern_x], 74  
    jl pattern_done
    mov byte [pattern_dir], 2   
    jmp pattern_done

pattern_left:
    dec byte [pattern_x]
    cmp byte [pattern_x], 3    
    jg pattern_done
    mov byte [pattern_dir], 0   

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
    jmp update_ball_done

left_scores:
    inc byte [player_1_score]
    call reset_ball
    jmp update_ball_done

right_scores:
    inc byte [player_2_score]
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

    ; Player 1 score
    mov dh, 1          ; Row
    mov dl, 20         ; Column
    mov bh, 0          ; Page
    mov ah, 02h        ; Set cursor position
    int 10h

    mov al, [player_1_score]
    add al, '0'        ; Convert to ASCII
    mov bl, 0x07       ; Color attribute
    mov cx, 1          ; Character count
    mov ah, 09h        ; Write character
    int 10h

    ; Player 2 score
    mov dl, 60         ; Column for player 2
    mov ah, 02h
    int 10h

    mov al, [player_2_score]
    add al, '0'
    mov ah, 09h
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret

;==============================================================================
; Check Game Over
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
    pop ax
    stc                     ; Set carry flag - game is over
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

set_pattern_star:
    mov ax, 0x072A          ; 07 = attribute, 2A = ASCII for '*'
    mov [pattern], ax
    jmp game_loop

set_pattern_line:
    mov ax, 0x072D          ; 07 = attribute, 2D = ASCII for '-'
    mov [pattern], ax
    jmp game_loop

set_pattern_arrow:
    mov ax, 0x073E          ; 07 = attribute, 3E = ASCII for '>'
    mov [pattern], ax      ; Fixed spelling of 'pattern'
    jmp game_loop

;==============================================================================
; Start of the game
;==============================================================================
start:
    ; Show welcome message
    call clear_screen
    
    ; Print welcome message
    mov ax, welcome_message
    push ax                  ; String offset
    mov ax, 64              ; String length
    push ax
    mov ax, 0x0408         ; Row 12, Column 16
    push ax
    mov al, 0x0A            ; Color attribute
    push ax
    call print_string


    mov ax, pattren_star
    push ax                  ; String offset
    mov ax, 27              ; String length
    push ax
    mov ax, 0x0808         ; Row 12, Column 16
    push ax
    mov al, 0x0A            ; Color attribute
    push ax
    call print_string

   mov ax, pattren_line
    push ax                  ; String offset
    mov ax, 27              ; String length
    push ax
    mov ax, 0x0A08         ; Row 12, Column 16
    push ax
    mov al, 0x0A            ; Color attribute
    push ax
    call print_string


    mov ax, pattren_arrow
    push ax                  ; String offset
    mov ax, 28              ; String length
    push ax
    mov ax, 0x0B08        ; Row 12, Column 16
    push ax
    mov al, 0x0A            ; Color attribute
    push ax
    call print_string

    mov ah, 00h
    int 16h
    cmp al,'1'
    je set_pattern_star
    cmp al,'2'
    je set_pattern_line
    cmp al,'3'
    je set_pattern_arrow
    jmp no_key_pressed

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
    cmp al, 'w'
    je move_left_up
    cmp al, 's'
    je move_left_down
    cmp ah, 48h             ; Up arrow
    je move_right_up
    cmp ah, 50h             ; Down arrow
    je move_right_down
    cmp al, 27              ; ESC
    je exit_game
    
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

show_game_over:
    ; Display game over message
    call clear_screen
    mov ax, game_over_msg
    push ax
    mov ax, 45              ; Length of game over message
    push ax
    mov ax, 0x0C10         ; Row 12, Column 16
    push ax
    mov al, 0x0F           ; White color
    push ax
    call print_string
    
    ; Wait for ESC or SPACE
wait_key:
    mov ah, 00h
    int 16h
    cmp al, 27             ; ESC
    je exit_game
    cmp al, 32             ; SPACE
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
