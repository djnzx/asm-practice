section .text
    global _start

_start:

    ; write prompt
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, msg
    mov edx, msg_len
    int 0x80

    ; read input
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buffer
    mov edx, 100
    int 0x80

    ; write input back
    mov edx, eax        ; number of bytes read
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, buffer
    int 0x80

    ; exit
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

section .data
    msg db "Enter text: ", 10
    msg_len equ $ - msg

section .bss
    buffer resb 100

