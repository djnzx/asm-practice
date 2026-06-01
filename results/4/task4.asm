section .bss
    ; memory: резервуємо місце для вводу та виводу
    input resb 12
    output resb 12

section .text
    global _start

_start:
    ; I/O: читаємо рядок з консолі (sys_read)
    mov eax, 3
    mov ebx, 0               ; stdin
    mov ecx, input
    mov edx, 12
    int 0x80

    ; parse: підготовка до конвертації String -> Int
    mov esi, input           ; покажчик на початок рядка
    xor eax, eax             ; тут буде наше число
    xor ebx, ebx             ; тимчасовий регістр

convert_to_int:
    mov bl, [esi]            ; беремо символ
    cmp bl, 10               ; перевіряємо на новий рядок (Enter)
    je start_printing        ; якщо Enter — закінчили
    cmp bl, 0                ; перевіряємо на кінець рядка
    je start_printing

    ; logic: перетворюємо ASCII в цифру
    sub bl, '0'

    ; math: множимо поточне число на 10 і додаємо нову цифру
    imul eax, 10
    add eax, ebx

    inc esi                  ; наступний символ
    jmp convert_to_int

start_printing:
    ; Тепер число в EAX. Починаємо конвертацію Int -> String для виводу
    mov edi, output
    add edi, 10              ; кінець буфера
    mov byte [edi], 0xA      ; символ переведення рядка
    mov ebx, 10              ; дільник

convert_to_string:
    ; math / loops: ділимо число на 10 для отримання цифр
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'              ; цифра в ASCII
    mov [edi], dl
    test eax, eax
    jnz convert_to_string

    ; I/O: вивід результату (sys_write)
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, output + 11
    sub edx, edi
    int 0x80

    ; I/O: завершення (sys_exit)
    mov eax, 1
    xor ebx, ebx
    int 0x80
