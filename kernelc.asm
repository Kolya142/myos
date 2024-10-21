; kernel.asm
bits 16
org 0x8000
start:
    cli
    mov ax, cs
    mov ds, ax
    mov word[0x80], interrupt
    mov word[0x82], cs
    sti    
    jmp main

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
    popa
    iret
interrupt_print_char:
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
interrupt_print_string:
    call printf
    popa
    iret
interrupt_get_key:
    popa
    in al, 0x60
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
    jmp hang

test_msg db 'Hello, from my os', 0

scancode_to_key:
    push bx
    movzx bx, al
    mov al, [scan_code_table + bx]
    pop bx
    ret

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
	.file	"test.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC0:
	.ascii "Hello, World!\12\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$40, %rsp
	.seh_stackalloc	40
	.seh_endprologue
	call	__main
	leaq	.LC0(%rip), %rcx
	call	printf
	xorl	%eax, %eax
	addq	$40, %rsp
	ret
	.seh_endproc
	.ident	"GCC: (tdm64-1) 10.3.0"
	.def	printf;	.scl	2;	.type	32;	.endef
