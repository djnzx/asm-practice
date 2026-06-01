section .data
    prompt_x     db "Enter x: ", 0
    msg_bin      db "Binary: ", 0
    msg_pop      db 10, "Popcount: ", 0
    msg_mod      db 10, "Modified (set 0,31, clear 15): ", 0
    space        db " ", 0
    newline      db 10, 0

section .bss
    x         resd 1
    modified  resd 1
    count     resd 1
    in_buf    resb 16
    out_buf   resb 32

section .text
    global _start

_start:
    ; --- I/O ---
    mov ecx, prompt_x
    call print_string
    call read_int
    mov [x], eax

    ; --- logic ---
    ; 1) Вивід у двійковому вигляді (32 біти, групи по 4)
    mov ecx, msg_bin
    call print_string

    mov ebx, [x]        ; число для зсуву
    mov esi, 0          ; лічильник бітів (0..31)
binary_loop:
    cmp esi, 32
    je print_popcount

    ; Перевірка на групування (кожні 4 біти, крім першого)
    test esi, esi
    jz .no_space
    mov eax, esi
    and eax, 3          ; esi % 4
    jnz .no_space
    push esi
    mov ecx, space
    call print_string
    pop esi

.no_space:
    ; Перевірка старшого біта через зсув
    rol ebx, 1          ; циклічний зсув вліво, біт іде в CF та в нульовий біт
    test ebx, 1         ; перевіряємо, що прийшло в нульовий біт
    jnz .print1
    mov byte [out_buf], '0'
    jmp .do_print
.print1:
    mov byte [out_buf], '1'

.do_print:
    mov byte [out_buf + 1], 0
    mov ecx, out_buf
    push esi
    call print_string
    pop esi

    inc esi
    jmp binary_loop

print_popcount:
    ; --- math ---
    ; 2) Підрахунок одиничних бітів (popcount)
    mov ebx, [x]
    xor eax, eax        ; тут буде сума
    mov ecx, 32
popcount_loop:
    mov edx, ebx
    and edx, 1          ; виділяємо останній біт
    add eax, edx        ; додаємо до лічильника
    shr ebx, 1          ; зсуваємо праворуч
    loop popcount_loop
    mov [count], eax

    mov ecx, msg_pop
    call print_string
    mov eax, [count]
    call print_int

modify_x:
    ; --- logic ---
    ; 3) Модифікація: set p=0, q=31 та clear r=15
    ; Формула: x' = (x | (1 << 0) | (1 << 31)) & ~(1 << 15)
    mov eax, [x]

    ; Set біти 0 та 31
    or eax, (1 << 0)
    or eax, (1 << 31)

    ; Clear біт 15
    and eax, ~(1 << 15)
    mov [modified], eax

    mov ecx, msg_mod
    call print_string
    mov eax, [modified]
    call print_int

exit:
    mov ecx, newline
    call print_string
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

; =========================================
; Допоміжні функції
; =========================================

; --- parse ---
read_int:
    mov eax, 3          ; sys_read
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 16
    int 0x80
    xor eax, eax
    mov esi, in_buf
.next:
    movzx ecx, byte [esi]
    cmp cl, 10
    je .done
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .next
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
    mov eax, 4
    mov ebx, 1
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