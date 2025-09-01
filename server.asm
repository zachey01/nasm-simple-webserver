section .data
resp:
    db 'HTTP/1.1 200 OK', 13,10
    db 'Content-Length: 14', 13,10
    db 'Content-Type: text/plain', 13,10
    db 13,10
    db 'Hello, world!', 10
resp_end:

sockaddr:
    dw 2
    dw 0x901F
    dd 0
    dq 0

section .bss
    align 16
    req_buf: resb 4096

section .text
    global _start

_start:
    mov rax, 41
    mov rdi, 2
    mov rsi, 1
    xor rdx, rdx
    syscall
    cmp rax, 0
    js .exit_err
    mov r12, rax

    mov rdi, r12
    lea rsi, [rel sockaddr]
    mov rdx, 16
    mov rax, 49
    syscall
    cmp rax, 0
    js .close_listen_and_exit

    mov rdi, r12
    mov rsi, 128
    mov rax, 50
    syscall
    cmp rax, 0
    js .close_listen_and_exit

.accept_loop:
    mov rdi, r12
    xor rsi, rsi
    xor rdx, rdx
    mov rax, 43
    syscall
    cmp rax, 0
    js .accept_failed
    mov r13, rax

    mov rdi, r13
    lea rsi, [rel req_buf]
    mov rdx, 4096
    mov rax, 0
    syscall

    mov rdi, r13
    lea rsi, [rel resp]
    mov rdx, resp_end - resp
    mov rax, 1
    syscall

    mov rdi, r13
    mov rax, 3
    syscall

    jmp .accept_loop

.accept_failed:
    xor rdi, rdi
    xor rsi, rsi
    mov rdx, 100
    mov rax, 7
    syscall
    jmp .accept_loop

.close_listen_and_exit:
    mov rdi, r12
    mov rax, 3
    syscall

.exit_err:
    mov rdi, 1
    mov rax, 60
    syscall
