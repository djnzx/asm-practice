section .bss
    ; [memory]: резервуємо місце для рядка (6 цифр + символ нового рядка)
    buffer resb 7

section .text
    global _start

_start:
    ; [I/O]: імітуємо вхідні дані. За завданням число в EAX (0..999999)
    mov eax, 123456          ; Тестове число

    ; [parse]: підготовка до конвертації
    lea edi, [buffer + 6]    ; Вказуємо на кінець буфера
    mov byte [edi], 0xA      ; Додаємо символ нового рядка (Line Feed)
    mov ebx, 10              ; Дільник для отримання цифр

convert_loop:
    ; [math]: ділимо число на 10
    dec edi                  ; Зсуваємо покажчик вліво
    xor edx, edx             ; Очищаємо залишок
    div ebx                  ; EAX = частка, EDX = залишок (цифра)

    ; [logic]: перетворюємо цифру в ASCII-символ
    add dl, '0'              ; Додаємо 48, щоб отримати код символу
    mov [edi], dl            ; Записуємо символ у пам'ять

    ; [loops]: повторюємо, поки число не стане нулем
    test eax, eax
    jnz convert_loop

    ; [I/O]: вивід результату на консоль (sys_write)
    mov eax, 4               ; Номер системного виклику sys_write
    mov ebx, 1               ;stdout
    mov ecx, edi             ; Початок нашого сформованого рядка

    ; Розрахунок довжини виводу
    mov edx, buffer + 7
    sub edx, edi             ; Різниця між кінцем буфера і початком числа

    int 0x80                 ; Виклик ОС

    ; [I/O]: коректне завершення програми (sys_exit)
    mov eax, 1
    xor ebx, ebx
    int 0x80