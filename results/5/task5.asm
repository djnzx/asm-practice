section .bss
    ; memory: буфери для вводу та результатів
    input resb 12
    output resb 12

section .text
    global _start

_start:
    ; I/O: читаємо число з консолі
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 12
    int 0x80

    ; parse: рядок -> число (atoi)
    mov esi, input
    xor eax, eax
    xor ebx, ebx
atoi_loop:
    mov bl, [esi]
    cmp bl, 10
    je start_math
    cmp bl, 0
    je start_math
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp atoi_loop

start_math:
    ; math: обчислення суми та кількості цифр
    xor ecx, ecx            ; тут сума (sumDigits)
    xor esi, esi            ; тут кількість (len)
    mov ebx, 10             ; дільник

math_loop:
    test eax, eax
    jz print_results
    xor edx, edx            ; обнуляємо EDX перед div
    div ebx                 ; ділимо на 10
    add ecx, edx            ; додаємо залишок до суми
    inc esi                 ; +1 до довжини
    jmp math_loop

print_results:
    push esi                ; зберігаємо довжину в стеку
    mov eax, ecx            ; виводимо суму
    call print_number
    pop eax                 ; виводимо довжину
    call print_number

    mov eax, 1              ; sys_exit
    xor ebx, ebx
    int 0x80

print_number:
    mov edi, output
    add edi, 10
    mov byte [edi], 0xA     ; новий рядок
    mov ebx, 10
    mov ecx, edi
itoa_loop:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz itoa_loop
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    inc edx
    sub edx, edi
    mov ecx, edi
    int 0x80
    ret
    