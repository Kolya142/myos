; kernel.asm
bits 16
org 0x8000
start:
    call init_pic
    cli
    mov al, 0x20
    out 0x20, al
    mov ax, cs
    mov ds, ax
    mov word[0x80], interrupt
    mov word[0x82], cs
    sti    
    mov bl, 0x0D  ; go to line home
    mov al, 0x01     
    int 0x20

    mov si, test_msg ; print test message
    mov al, 0x03
    int 0x20

    ask_app_start:
        mov si, ask_app ; print ask app message
        mov al, 0x03
        int 0x20
        ask_app_loop:
            mov al, 0x04     ; get key
            int 0x20
            call scancode_to_key
            cmp al, '0'
            je echo_app
            cmp al, '1'
            je see_numbers
            jmp ask_app_loop

see_numbers:
    mov cl, 0
    see_numbers_loop:
        mov al, 0x04     ; get key
        int 0x20
        call scancode_to_key
        cmp al, '~'
        je ask_app_start
        mov al, cl
        call number_to_char
        mov bl, al
        mov al, 0x01
        int 0x20
        mov al, 0x05
        int 0x20
        add cl, 1
        cmp cl, 10
        je see_numbers_res
        jmp see_numbers_loop
    see_numbers_res:
        mov cl, 0
        jmp see_numbers_loop
        

echo_app:
    mov dl, 0x00
    key_test_loop:
        key_test_loop_wait:
        mov al, 0x04     ; get key
        int 0x20
        call scancode_to_key
        cmp al, 0     ; is there a key?
        je key_test_loop_wait1
        cmp al, dl
        je key_test_loop_wait
        mov dl, al

        cmp al, 0x0A
        je key_test_enter
        cmp al, 0x0E
        je key_test_backspace
        cmp al, '`'
        je ask_app_start
        mov bl, al  ; output key
        mov al, 0x01     
        int 0x20
        jmp key_test_loop

    mov al, 0x02 ; hang
    int 0x20
    key_test_loop_wait1:
        mov dl, al
        jmp key_test_loop_wait
    key_test_enter:
        mov al, 0x01
        mov bl, 0x0D
        int 0x20
        mov bl, 0x0A
        int 0x20
        jmp key_test_loop
    key_test_backspace:
        mov al, 0x05
        int 0x20
        jmp key_test_loop

init_pic:
    mov al, 0x11         
    out 0x20, al         
    out 0xA0, al         
    mov al, 0x20         
    out 0x21, al
    mov al, 0x28         
    out 0xA1, al
    mov al, 0x04         
    out 0x21, al
    mov al, 0x02         
    out 0xA1, al
    mov al, 0x01         
    out 0x21, al
    out 0xA1, al
    ret

interrupt:
    pusha
    cmp al, 0x01
    je interrupt_print_char
    cmp al, 0x02
    je hang
    cmp al, 0x03
    je interrupt_print_string
    cmp al, 0x04
    je interrupt_get_key
    cmp al, 0x05
    je interrupt_cursor_backspace
    cmp al, 0x06
    je interrupt_delay
    popa
    iret
interrupt_print_char: ; arg: bl
    mov ah, 0x0E
    mov al, bl
    int 0x10
    popa
    iret
interrupt_cursor_backspace:
    mov ah, 0x03  
    mov bh, 0x00  
    int 0x10      

    dec dl        
    cmp dl, 0     
    jge set_cursor
    mov dl, 79    
    dec dh        

    set_cursor:
    mov ah, 0x02  
    mov bh, 0x00  
    int 0x10      

    popa
    iret
interrupt_print_string: ; arg: si
    call printf
    popa
    iret
interrupt_get_key:
    popa
    in al, 0x60
    iret
interrupt_delay: ; arg: dx
    mov ah, 0x86        
    mov cx, 0x0000      
    int 0x15            
    popa            
    iret      

printf:
    lodsb
    or al, al
    jz printf_end
    mov ah, 0x0E
    int 0x10
    jmp printf
    mov bx, 0x8000

printf_end:
    ret

hang:
    mov si, halt_msg
    call printf
    halt:
        jmp halt

test_msg db 'Hello, from my os', 0
halt_msg db 'System halted', 0
hang_ask_msg db 'Do you want to hang? (Y/N)', 0
ask_app db 'Select app (0-echo, 1-see numbers)', 0

scancode_to_key:
    push bx
    movzx bx, al
    mov al, [scan_code_table + bx]
    pop bx
    ret
number_to_char:
    push bx
    movzx bx, al
    mov al, [digits + bx]
    pop bx
    ret

digits db '0123456789', 0

scan_code_table:
    db 0          ; 0x00 (no key)
    db 0x1B       ; 0x01 (Esc)
    db '1'        ; 0x02
    db '2'        ; 0x03
    db '3'        ; 0x04
    db '4'        ; 0x05
    db '5'        ; 0x06
    db '6'        ; 0x07
    db '7'        ; 0x08
    db '8'        ; 0x09
    db '9'        ; 0x0A
    db '0'        ; 0x0B
    db '-'        ; 0x0C
    db '='        ; 0x0D
    db 0x0E       ; 0x0E (Backspace)
    db 0x0F       ; 0x0F (Tab)
    db 'Q'        ; 0x10
    db 'W'        ; 0x11
    db 'E'        ; 0x12
    db 'R'        ; 0x13
    db 'T'        ; 0x14
    db 'Y'        ; 0x15
    db 'U'        ; 0x16
    db 'I'        ; 0x17
    db 'O'        ; 0x18
    db 'P'        ; 0x19
    db '['        ; 0x1A
    db ']'        ; 0x1B
    db 0x0A       ; 0x1C (Enter)
    db 0x1D       ; 0x1D (Ctrl)
    db 'A'        ; 0x1E
    db 'S'        ; 0x1F
    db 'D'        ; 0x20
    db 'F'        ; 0x21
    db 'G'        ; 0x22
    db 'H'        ; 0x23
    db 'J'        ; 0x24
    db 'K'        ; 0x25
    db 'L'        ; 0x26
    db ';'        ; 0x27
    db '\''       ; 0x28
    db '`'        ; 0x29
    db 0          ; 0x2A (Left Shift)
    db '\'        ; 0x2B
    db 'Z'        ; 0x2C
    db 'X'        ; 0x2D
    db 'C'        ; 0x2E
    db 'V'        ; 0x2F
    db 'B'        ; 0x30
    db 'N'        ; 0x31
    db 'M'        ; 0x32
    db ','        ; 0x33
    db '.'        ; 0x34
    db '/'        ; 0x35
    db 0          ; 0x36 (Right Shift)
    db '*'        ; 0x37
    db 0          ; 0x38 (Alt)
    db ' '        ; 0x39 (Space)