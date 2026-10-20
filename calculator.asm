section .data
    title       db "----------------------------------", 10
                db "             CALCULATOR", 10
                db "----------------------------------", 10
    title_len   equ $ - title

    menu        db "[A]dd", 10
                db "[S]ubtract", 10
                db "[M]ultiply", 10
                db "[D]ivide", 10
                db "----------------------------------", 10
    menu_len    equ $ - menu

    choice_msg  db "Enter your choice: "
    choice_len  equ $ - choice_msg

    first_msg   db "Enter first number: "
    first_len   equ $ - first_msg

    second_msg  db "Enter second number: "
    second_len  equ $ - second_msg

    sum_msg     db "The sum is "
    sum_len     equ $ - sum_msg

    diff_msg    db "The difference is "
    diff_len    equ $ - diff_msg

    product_msg db "The product is "
    product_len equ $ - product_msg

    quotient_msg db "The quotient is "
    quotient_len equ $ - quotient_msg

    zero_msg    db "Error: Division by zero is not allowed.", 10
    zero_len    equ $ - zero_msg

    invalid_msg db "Invalid choice. Please select A, S, M, or D.", 10
    invalid_len equ $ - invalid_msg

    again_msg   db 10, "Do you want to try again (Y/N)? "
    again_len   equ $ - again_msg

    goodbye_msg db "Program terminated. Goodbye!", 10
    goodbye_len equ $ - goodbye_msg

    newline     db 10
    newline_len equ $ - newline

    clear       db 27, "[2J", 27, "[H"
    clear_len   equ $ - clear

section .bss
    choice      resb 16
    input1      resb 32
    input2      resb 32
    again       resb 16
    num1        resd 1
    num2        resd 1
    result      resd 1
    numout      resb 16

section .text
    global _start

_start:

menu_loop:
    ; Clear the screen before displaying the menu
    mov eax, 4
    mov ebx, 1
    mov ecx, clear
    mov edx, clear_len
    int 0x80

    ; Display title and menu
    mov eax, 4
    mov ebx, 1
    mov ecx, title
    mov edx, title_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, menu
    mov edx, menu_len
    int 0x80

    ; Ask for operation
    mov eax, 4
    mov ebx, 1
    mov ecx, choice_msg
    mov edx, choice_len
    int 0x80

    mov ecx, choice
    mov edx, 16
    call read_input

    ; Read first character and convert lowercase to uppercase
    mov al, [choice]
    cmp al, 'a'
    jb check_choice
    cmp al, 'z'
    ja check_choice
    sub al, 32

check_choice:
    mov [choice], al

    cmp al, 'A'
    je get_numbers
    cmp al, 'S'
    je get_numbers
    cmp al, 'M'
    je get_numbers
    cmp al, 'D'
    je get_numbers

    mov eax, 4
    mov ebx, 1
    mov ecx, invalid_msg
    mov edx, invalid_len
    int 0x80

    jmp ask_again

get_numbers:
    mov eax, 4
    mov ebx, 1
    mov ecx, first_msg
    mov edx, first_len
    int 0x80

    mov ecx, input1
    mov edx, 32
    call read_input

    mov esi, input1
    call parse_number
    mov [num1], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, second_msg
    mov edx, second_len
    int 0x80

    mov ecx, input2
    mov edx, 32
    call read_input

    mov esi, input2
    call parse_number
    mov [num2], eax

    ; Select the appropriate operation
    mov al, [choice]

    cmp al, 'A'
    je addition

    cmp al, 'S'
    je subtraction

    cmp al, 'M'
    je multiplication

    cmp al, 'D'
    je division

addition:
    mov eax, [num1]
    add eax, [num2]
    mov [result], eax

    mov ecx, sum_msg
    mov edx, sum_len
    call print_string
    jmp show_result

subtraction:
    mov eax, [num1]
    sub eax, [num2]
    mov [result], eax

    mov ecx, diff_msg
    mov edx, diff_len
    call print_string
    jmp show_result

multiplication:
    mov eax, [num1]
    imul eax, dword [num2]
    mov [result], eax

    mov ecx, product_msg
    mov edx, product_len
    call print_string
    jmp show_result

division:
    cmp dword [num2], 0
    je division_error

    mov eax, [num1]
    cdq
    idiv dword [num2]
    mov [result], eax

    mov ecx, quotient_msg
    mov edx, quotient_len
    call print_string
    jmp show_result

division_error:
    mov ecx, zero_msg
    mov edx, zero_len
    call print_string
    jmp ask_again

show_result:
    mov eax, [result]
    call print_number

    mov ecx, newline
    mov edx, newline_len
    call print_string

ask_again:
    mov ecx, again_msg
    mov edx, again_len
    call print_string

    mov ecx, again
    mov edx, 16
    call read_input

    mov al, [again]
    cmp al, 'y'
    jne check_yes
    mov al, 'Y'

check_yes:
    cmp al, 'Y'
    je menu_loop

    cmp al, 'N'
    je exit_program

    cmp al, 'n'
    je exit_program

    jmp ask_again

exit_program:
    mov ecx, goodbye_msg
    mov edx, goodbye_len
    call print_string

    mov eax, 1
    xor ebx, ebx
    int 0x80


; -----------------------------------------
; Procedure: read_input
; Reads a line from keyboard input.
; ECX = buffer address
; EDX = maximum number of bytes
; -----------------------------------------
read_input:
    push eax
    push ebx

    mov eax, 3
    mov ebx, 0
    int 0x80

    pop ebx
    pop eax
    ret


; -----------------------------------------
; Procedure: parse_number
; Converts an ASCII integer into a number.
; ESI = input buffer
; EAX = converted integer
; Supports an optional minus sign.
; -----------------------------------------
parse_number:
    xor eax, eax
    xor ebx, ebx
    mov bl, 1

    cmp byte [esi], '-'
    jne parse_loop

    mov bl, -1
    inc esi

parse_loop:
    movzx edx, byte [esi]

    cmp dl, 10
    je parse_done

    cmp dl, 13
    je parse_done

    cmp dl, 0
    je parse_done

    cmp dl, '0'
    jb parse_done

    cmp dl, '9'
    ja parse_done

    imul eax, eax, 10
    sub edx, '0'
    add eax, edx

    inc esi
    jmp parse_loop

parse_done:
    cmp bl, -1
    jne parse_return

    neg eax

parse_return:
    ret


; -----------------------------------------
; Procedure: print_string
; ECX = string address
; EDX = string length
; -----------------------------------------
print_string:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret


; -----------------------------------------
; Procedure: print_number
; EAX = signed integer to display
; Converts the integer to ASCII.
; -----------------------------------------
print_number:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, numout
    add edi, 16
    mov byte [edi - 1], 10
    dec edi

    mov ebx, 10
    xor esi, esi

    test eax, eax
    jns number_convert

    neg eax
    mov esi, 1

number_convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz number_convert

    cmp esi, 0
    je number_output

    dec edi
    mov byte [edi], '-'

number_output:
    mov ecx, edi
    mov edx, numout
    add edx, 16
    sub edx, edi

    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
