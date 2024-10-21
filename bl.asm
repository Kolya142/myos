; bl.asm
bits 16
org 0x7C00

start:
    mov [boot_disk], dl
    mov si, msg
    call printf

run_program:    
    mov ah, 0x02        ; BIOS function to read sectors
    mov al, 0x01        ; Number of sectors: 1
    mov ch, 0x00        ; Cylinder: 0
    mov cl, 0x02        ; Sector: 2 (start of the kernel)
    mov dh, 0x00        ; Head: 0
    mov dl, [boot_disk]        ; Hard Drive
    mov bx, 0x8000      ; Memory address to load the sector (0x8000)
    int 0x13            ; BIOS interrupt call
    jc disk_error       ; If there's an error, jump to error handling
    mov al, [0x8000]
    cmp al, 0
    jz disk_error  
    mov si, success
    call printf
    jmp 0x8000     

disk_error:
    mov si, errdsk
    call printf
output_memory:
    add bx, 1
    mov al, [bx]
    mov ah, 0x0E
    int 0x10
     
    mov dx, 300       
    call delay     

    jmp output_memory
delay:
    pusha            
    mov ah, 0x86        
    mov cx, 0x0000      
    int 0x15            
    popa            
    ret                 

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


msg db 'Simple Bootloader', 0x0d, 0x0a, 0
success db 'kernel loaded', 0x0d, 0x0a, 0
errdsk db 'kernel loaded', 0x0d, 0x0a, 0

boot_disk db 0

times 510-($-$$) db 0
dw 0xAA55
