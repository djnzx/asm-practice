
section .text

global _start

; 1. entry point
_start:
    ; 2. prepare parameters to function call
    mov     eax, 123456789
    mov     esi, buffer
    ; 3. call function `int2str`
    call    int2str

    ; 4. prepare parameters to function call
    mov     eax, 4      ; function number: 4-print
    mov     ebx, 1      ; device number:   1-stdout
    mov     ecx, esi    ; buffer to print
    mov     edx, 1      ; length
    ; 5. OS call, print to console
    int     0x80

    ; 6. prepare parameters to function call
    mov     eax, 1
    ; 7. OS call, exit
    int     0x80

; EAX - input parameter
; ESI - buffer for output string
int2str:
    ;
    ; remainder = eax % 10
    ; symbol = remainder + 48
    ; TODO: loop
    ; TODO: inc/dec ESI
    xor edx, edx
    mov ebx, 10
    div ebx

    add dl, 48

    mov byte [esi], dl
    ret

section .bss
    buffer  resb 11
