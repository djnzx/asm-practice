; printf(String format, Any x1...)
;        "Hello, %s!", "Alex"
;        "Hello, Alex!"
;        "the price is %i USD", 13
;        "the price is 13 USD"
global main

extern printf

section .text

main:
    push ebp
    mov ebp, esp

    ; push parameters
    push 13
    push msg
    ; call C function
    call printf
    ; stack cleanup
    add esp,8

    mov esp, ebp
    pop ebp

    ; return to OS
    mov eax,0
    ret

section .data
    msg db "The price is %i USD", 0x0a, 0x0d
