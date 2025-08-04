section .data
    hello db 'Hello, World!', 0x0A  ; The string to print, followed by a newline

section .text
    global _start                     ; Entry point for the program

_start:
    ; Write the string to stdout
    mov rax, 1                        ; syscall: write
    mov rdi, 1                        ; file descriptor: stdout
    mov rsi, hello                    ; pointer to the string
    mov rdx, 14                       ; length of the string
    syscall                           ; invoke the kernel

    ; Exit the program
    mov rax, 60                       ; syscall: exit
    xor rdi, rdi                      ; exit code: 0
    syscall                           ; invoke the kernel
