section .data
    msg_text db "Enter text: ", 0
    len_msg_text equ $ - msg_text
    msg_pat db "Enter pattern: ", 0
    len_msg_pat equ $ - msg_pat
    msg_pos db "First position: ", 0
    len_msg_pos equ $ - msg_pos
    msg_cnt db ", Count: ", 0
    len_msg_cnt equ $ - msg_cnt
    newline db 10

section .bss
    text resb 201
    pattern resb 51
    pos_str resb 12
    cnt_str resb 12
    text_len resd 1
    pat_len resd 1
    first_pos resd 1
    count resd 1

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_text
    mov edx, len_msg_text
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, text
    mov edx, 200
    int 0x80
    
    call remove_newline
    mov [text_len], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pat
    mov edx, len_msg_pat
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, pattern
    mov edx, 50
    int 0x80
    
    call remove_newline
    mov [pat_len], eax

    mov dword [first_pos], -1
    mov dword [count], 0

    cmp dword [pat_len], 0
    je print_results

    mov esi, 0
search_loop:
    mov eax, [text_len]
    sub eax, [pat_len]
    cmp esi, eax
    jg print_results

    mov edi, 0
compare_loop:
    cmp edi, [pat_len]
    je match_found

    mov al, [text + esi + edi]
    mov bl, [pattern + edi]
    cmp al, bl
    jne next_char

    inc edi
    jmp compare_loop

match_found:
    inc dword [count]
    cmp dword [first_pos], -1
    jne update_index
    mov [first_pos], esi

update_index:
    mov eax, [pat_len]
    add esi, eax
    jmp search_loop

next_char:
    inc esi
    jmp search_loop

print_results:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pos
    mov edx, len_msg_pos
    int 0x80

    mov eax, [first_pos]
    mov edi, pos_str
    call int_to_str
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    mov ecx, pos_str
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_cnt
    mov edx, len_msg_cnt
    int 0x80

    mov eax, [count]
    mov edi, cnt_str
    call int_to_str
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    mov ecx, cnt_str
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

remove_newline:
    xor eax, eax
.loop:
    cmp byte [ecx + eax], 10
    je .found
    cmp byte [ecx + eax], 0
    je .found
    inc eax
    jmp .loop
.found:
    mov byte [ecx + eax], 0
    ret

int_to_str:
    push ebx
    push ecx
    push edx
    push esi
    mov esi, edi
    cmp eax, -1
    jne .positive
    mov byte [edi], '-'
    inc edi
    mov byte [edi], '1'
    inc edi
    mov byte [edi], 0
    mov eax, 2
    jmp .done_func

.positive:
    mov ecx, 10
    mov ebx, edi
    add ebx, 10
    mov byte [ebx], 0
    dec ebx
.loop2:
    xor edx, edx
    div ecx
    add dl, '0'
    mov [ebx], dl
    dec ebx
    test eax, eax
    jnz .loop2
    inc ebx
    mov eax, edi
.copy:
    mov dl, [ebx]
    mov [eax], dl
    test dl, dl
    jz .done_len
    inc eax
    inc ebx
    jmp .copy
.done_len:
    sub eax, edi
.done_func:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
