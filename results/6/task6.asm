section .data
    ; memory: рядки для виводу
    msg_s db "SIGNED: ", 0
    msg_u db "UNSIGNED: ", 0
    msg_lt db "a < b", 0xA, 0
    msg_gt db "a > b", 0xA, 0
    msg_eq db "a = b", 0xA, 0
    msg_max_s db "max_signed: ", 0
    msg_max_u db "max_unsigned: ", 0

section .bss
    ; memory: буфери
    buf_a resb 16
    buf_b resb 16
    val_a resd 1
    val_b resd 1
    out_buf resb 16

section .text
    global _start

_start:
    ; I/O: читаємо a
    mov eax, 3
    mov ebx, 0
    mov ecx, buf_a
    mov edx, 16
    int 0x80
    mov esi, buf_a
    call atoi
    mov [val_a], eax

    ; I/O: читаємо b
    mov eax, 3
    mov ebx, 0
    mov ecx, buf_b
    mov edx, 16
    int 0x80
    mov esi, buf_b
    call atoi
    mov [val_b], eax

    ; logic: Signed порівняння
    mov edx, msg_s
    call print_str
    mov eax, [val_a]
    mov ebx, [val_b]
    call cmp_signed

    ; logic: Unsigned порівняння
    mov edx, msg_u
    call print_str
    mov eax, [val_a]
    mov ebx, [val_b]
    call cmp_unsigned

    ; logic: max_signed
    mov edx, msg_max_s
    call print_str
    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    jg .print_a_s
    mov eax, ebx
.print_a_s:
    call itoa_signed

    ; logic: max_unsigned
    mov edx, msg_max_u
    call print_str
    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    ja .print_a_u
    mov eax, ebx
.print_a_u:
    call itoa_unsigned

    ; I/O: вихід
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Підпрограми ---

cmp_signed:
    ; logic: використання jl/jg для знакового порівняння
    cmp eax, ebx
    je .eq
    jl .lt
    mov edx, msg_gt
    jmp .out
.lt: mov edx, msg_lt
    jmp .out
.eq: mov edx, msg_eq
.out: call print_str
    ret

cmp_unsigned:
    ; logic: використання jb/ja для беззнакового порівняння
    cmp eax, ebx
    je .eq
    jb .lt
    mov edx, msg_gt
    jmp .out
.lt: mov edx, msg_lt
    jmp .out
.eq: mov edx, msg_eq
.out: call print_str
    ret

atoi:
    ; parse: рядок -> число з підтримкою '-'
    xor eax, eax
    xor ecx, ecx
    movzx edx, byte [esi]
    cmp dl, '-'
    jne .loop
    inc esi
    push 1      ; прапорець від'ємного числа
    jmp .loop_start
.loop:
    push 0
.loop_start:
    movzx edx, byte [esi]
    cmp dl, 10
    je .done
    cmp dl, '0'
    jb .done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .loop_start
.done:
    pop ecx
    test ecx, ecx
    jz .exit
    neg eax
.exit: ret

itoa_signed:
    ; itoa: з підтримкою від'ємних чисел
    test eax, eax
    jns itoa_unsigned
    push eax
    mov al, '-'
    mov [out_buf], al
    mov eax, 4
    mov ebx, 1
    mov ecx, out_buf
    mov edx, 1
    int 0x80
    pop eax
    neg eax
    ; далі як unsigned

itoa_unsigned:
    mov edi, out_buf + 15
    mov byte [edi], 0xA
    mov ebx, 10
.loop:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .loop
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, out_buf + 16
    sub edx, edi
    int 0x80
    ret

print_str:
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, edx
    xor edx, edx
.len:
    cmp byte [ecx+edx], 0
    je .write
    inc edx
    jmp .len
.write:
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
