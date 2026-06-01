section .data
    prompt_n db "Enter n (5..50): ", 0
    msg_arr  db "Array: ", 0
    msg_min  db 10, "Min: ", 0
    msg_max  db 10, "Max: ", 0
    msg_idx  db ", index: ", 0
    newline  db 10, 0
    space    db " ", 0

section .bss
    ; memory: резервуємо масив (50 елементів по 4 байти = 200 байт)
    array resd 50
    in_buf resb 16
    out_buf resb 16

    n resd 1
    min_val resd 1
    min_idx resd 1
    max_val resd 1
    max_idx resd 1

section .text
    global _start

_start:
    ; --- I/O ---
    ; Виводимо запит на введення n
    mov ecx, prompt_n
    call print_string

    ; Зчитуємо введене значення
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, in_buf
    mov edx, 16
    int 0x80

    ; --- parse ---
    ; Перетворюємо рядок на число
    mov esi, in_buf
    call str_to_int
    mov [n], eax

    ; --- loops ---
    ; Ініціалізуємо цикл заповнення
    mov ecx, 0          ; index i = 0
fill_loop:
    cmp ecx, [n]
    jge end_fill

    ; --- math ---
    ; Формула: A[i] = (i * 17) % 53 + 10
    mov eax, ecx
    imul eax, 17
    mov edx, 0
    mov edi, 53
    div edi             ; остача в edx
    add edx, 10

    ; --- memory ---
    ; Збереження в масив: [base + idx*4]
    mov [array + ecx*4], edx

    inc ecx
    jmp fill_loop
end_fill:

    ; --- I/O ---
    mov ecx, msg_arr
    call print_string

    ; Встановлюємо початкові значення для мін/макс (перший елемент)
    mov eax, [array + 0]
    mov [min_val], eax
    mov [max_val], eax
    mov dword [min_idx], 0
    mov dword [max_idx], 0

    ; --- loops ---
    mov ecx, 0          ; index i = 0
process_loop:
    cmp ecx, [n]
    jge end_process

    ; Зберігаємо лічильник перед I/O
    push ecx

    ; Виводимо поточний елемент масиву
    mov eax, [array + ecx*4]
    call print_int
    mov ecx, space
    call print_string

    ; Відновлюємо лічильник
    pop ecx

    ; --- logic ---
    mov eax, [array + ecx*4]

    ; Перевірка на мінімум
    cmp eax, [min_val]
    jge check_max
    mov [min_val], eax
    mov [min_idx], ecx

check_max:
    ; Перевірка на максимум
    cmp eax, [max_val]
    jle next_iter
    mov [max_val], eax
    mov [max_idx], ecx

next_iter:
    inc ecx
    jmp process_loop
end_process:

    ; --- I/O ---
    ; Вивід мінімуму та його індексу
    mov ecx, msg_min
    call print_string
    mov eax, [min_val]
    call print_int

    mov ecx, msg_idx
    call print_string
    mov eax, [min_idx]
    call print_int

    ; Вивід максимуму та його індексу
    mov ecx, msg_max
    call print_string
    mov eax, [max_val]
    call print_int

    mov ecx, msg_idx
    call print_string
    mov eax, [max_idx]
    call print_int

    ; Вивід нового рядка перед завершенням
    mov ecx, newline
    call print_string

    ; --- I/O ---
    ; Коректне завершення програми
    mov eax, 1          ; sys_exit
    mov ebx, 0          ; код повернення 0
    int 0x80

; =========================================
; Допоміжні підпрограми
; =========================================

; --- parse ---
str_to_int:
    xor eax, eax
    xor ecx, ecx
.loop:
    mov cl, [esi]
    cmp cl, 10          ; перевірка на newline (\n)
    je .done
    cmp cl, 0
    je .done
    sub cl, '0'         ; ASCII в число
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .loop
.done:
    ret

print_int:
    mov edi, out_buf + 15
    mov byte [edi], 0
    dec edi
    mov ebx, 10
    test eax, eax
    jnz .loop
    ; Якщо число 0
    mov byte [edi], '0'
    dec edi
    jmp .done
.loop:
    xor edx, edx
    div ebx             ; ділення eax на 10, остача в edx
    add dl, '0'         ; число в ASCII
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .loop
.done:
    inc edi
    mov ecx, edi
    call print_string
    ret

print_string:
    push eax
    push ebx
    push ecx
    push edx
    ; Знаходимо довжину рядка
    mov edx, 0
.len_loop:
    cmp byte [ecx+edx], 0
    je .print
    inc edx
    jmp .len_loop
.print:
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret