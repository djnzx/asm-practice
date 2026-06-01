section .text

global _start

_start:
    mov     eax, 4      ; parameter: function id: 4=print
    mov     ebx, 1      ; parameter: device: 1=stdout
    mov     ecx, msg    ; parameter: address to print
    mov     edx, len    ; parameter: number of bytes to print
    int     0x80        ; kernel call

    mov     eax, 1      ; parameter: function: 1=exit
    int     0x80        ; kernel call

section .data
    msg     db  "Hello from Assembly!", 0x0d, 0x0a
    len     equ $ - msg
