; practice13.asm
; I/O: int 80h
; blocks: I/O, parse, math/logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
prompt db "practice13: see README.md", 10
prompt_len equ $-prompt

SECTION .bss
buf resb 256

SECTION .text
_start:
    ; I/O: write prompt
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; I/O: read line (optional in skeleton)
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buf
    mov edx, 255
    int 0x80

    ; logic: TODO implement task logic according to README.md

    ; exit
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80
