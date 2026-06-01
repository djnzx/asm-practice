section .data
    prompt_n     db "Enter n (100..1000): ", 0
    msg_row      db ": ", 0
    char_hash    db "#", 0
    char_open    db " (", 0
    char_close   db ")", 0
    newline      db 10, 0

    ; Константи для LCG
    lcg_m        dd 2147483647 ; 2^31 - 1
    lcg_a        dd 1103515245
    lcg_c        dd 12345
    seed         dd 12345      ; Початкове значення

section .bss
    n        resd 1
    freq     resd 10    ; масив частот для цифр 0-9 (10 * 4 байта)
    in_buf   resb 16
    out_buf  resb 32

section .text
    global _start

_start:
    ; --- I/O ---
    mov ecx, prompt_n
    call print_string
    call read_int
    mov [n], eax

    ; Очищення масиву частот
    xor ecx, ecx
clear_freq:
    mov dword [freq + ecx*4], 0
    inc ecx
    cmp ecx, 10
    jl clear_freq

    ; --- loops ---
    ; Основний цикл генерації n чисел
    mov esi, [n]
generate_loop:
    test esi, esi
    jz print_histogram

    ; --- math ---
    ; LCG: x = (a * x + c) mod 2^31
    mov eax, [seed]
    mov edx, [lcg_a]
    mul edx             ; edx:eax = seed * a
    add eax, [lcg_c]
    and eax, 0x7FFFFFFF ; mod 2^31
    mov [seed], eax     ; зберігаємо новий seed

    ; --- logic ---
    ; Отримуємо цифру 0-9: x mod 10
    xor edx, edx
    mov ecx, 10
    div ecx             ; залишок у edx (це наша корзина 0-9)

    ; --- memory ---
    inc dword [freq + edx*4]

    dec esi
    jmp generate_loop

print_histogram:
    ; Цикл по 10 рядках гістограми
    xor ebx, ebx        ; поточна цифра (0..9)
row_loop:
    cmp ebx, 10
    je exit

    ; Вивід цифри рядка
    mov eax, ebx
    call print_int
    mov ecx, msg_row
    call print_string

    ; Внутрішній цикл для малювання '#'
    ; --- memory ---
    mov edi, [freq + ebx*4] ; беремо кількість значень у корзині

    ; Масштабування: якщо n=1000, 100 решіток - це забагато.
    ; Виведемо 1 решітку на кожні 2 елементи для компактності.
    shr edi, 1          ; edi = edi / 2 (масштабування 1:# на 2 елементи)

hash_loop:
    test edi, edi
    jz print_count

    push ebx            ; зберігаємо ebx, бо print_string його не міняє, але про всяк випадок
    mov ecx, char_hash
    call print_string
    pop ebx

    dec edi
    jmp hash_loop

print_count:
    ; Вивід фактичного числа в дужках
    mov ecx, char_open
    call print_string
    mov eax, [freq + ebx*4]
    call print_int
    mov ecx, char_close
    call print_string

    mov ecx, newline
    call print_string

    inc ebx
    jmp row_loop

exit:
    ; --- I/O ---
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

; =========================================
; Допоміжні функції (parse та I/O)
; =========================================

; --- parse ---
read_int:
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, in_buf
    mov edx, 16
    int 0x80

    xor eax, eax
    mov esi, in_buf
.next_digit:
    movzx ecx, byte [esi]
    cmp cl, 10          ; перевірка на newline
    je .done
    cmp cl, '0'
    jl .done
    cmp cl, '9'
    jg .done

    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .next_digit
.done:
    ret

; --- I/O ---
print_string:
    push eax
    push ebx
    push edx
    mov edi, ecx
    xor edx, edx
.len:
    cmp byte [edi+edx], 0
    je .write
    inc edx
    jmp .len
.write:
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    pop edx
    pop ebx
    pop eax
    ret

print_int:
    push eax
    push ebx
    push ecx
    push edx
    mov edi, out_buf + 31
    mov byte [edi], 0
    mov ebx, 10
.loop:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .loop
    mov ecx, edi
    call print_string
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret