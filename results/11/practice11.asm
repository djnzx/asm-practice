section .data
    prompt_h     db "Enter height h (5..25): ", 0
    newline      db 10

section .bss
    h            resd 1
    in_buf       resb 16
    line_buf     resb 128    ; Буфер для формування одного рядка

section .text
    global _start

_start:
    ; --- I/O ---
    ; Вивід запиту на введення
    mov ecx, prompt_h
    call print_string

    ; Читання висоти h
    call read_int
    mov [h], eax

    ; --- logic ---
    ; esi - лічильник поточного рядка (від 0 до h-1)
    xor esi, esi

row_loop:
    mov eax, [h]
    cmp esi, eax
    jge exit_program

    ; --- memory ---
    ; Готуємо буфер рядка: встановлюємо вказівник на початок
    mov edi, line_buf

    ; --- math ---
    ; Розрахунок пробілів: spaces = h - esi - 1
    mov ecx, [h]
    sub ecx, esi
    dec ecx

    ; --- loops ---
    ; Цикл заповнення пробілами
space_loop:
    cmp ecx, 0
    jle stars_init
    mov byte [edi], ' '
    inc edi
    dec ecx
    jmp space_loop

stars_init:
    ; Розрахунок зірочок: stars = 2 * esi + 1
    mov eax, esi
    mov ebx, 2
    mul ebx
    inc eax
    mov ecx, eax

    ; Цикл заповнення зірочками
stars_loop:
    cmp ecx, 0
    jle finalize_line
    mov byte [edi], '*'
    inc edi
    dec ecx
    jmp stars_loop

finalize_line:
    ; Додаємо символ нового рядка в буфер
    mov byte [edi], 10
    inc edi

    ; --- logic ---
    ; Розрахунок довжини сформованого рядка для print_line
    mov edx, edi
    sub edx, line_buf ; довжина = поточний edi - початок буфера
    mov ecx, line_buf

    ; --- I/O ---
    call print_line

    inc esi
    jmp row_loop

exit_program:
    ; --- I/O ---
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

; =========================================
; Підпрограми
; =========================================

; --- logic ---
; Вивід рядка з буфера (sys_write)
; ecx = адреса буфера, edx = довжина
print_line:
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    ret

; --- parse ---
; Читання цілого числа з stdin
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
    cmp cl, 10          ; перевірка на Enter
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
; Друк рядка, що закінчується нулем
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
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop edx
    pop ebx
    pop eax
    ret