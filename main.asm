; Type output - 32 elf
format ELF executable
entry _start

; Code segment 
segment readable executable

_start:
    mov eax, [esp]
    cmp eax, 2
    je .next
    jmp .usage

.next:
    mov [size_file_name], 0 ; count of bytes of argument
    mov esi, [esp+8]        ; start of argument 2 (after exec file name)
    mov [file_name], esi    ; copy pointer for start to variable

.readinloop:
    inc esi
    inc [size_file_name]
    
    cmp byte[esi], 0x00 ; zero byte is separator between arguments. If end of argument found
    je .open

    jmp .readinloop
.open:
    mov eax, 5           ; sys_open
    mov ebx, [file_name] ; file to open
    mov ecx, 0           ; read only
    int 80h

    mov [file_descriptor], eax ; save desctiptor to memory
    
    cmp [file_descriptor], -1  ; if negative then error
    jl .not_opened

    mov eax, 3                 ; sys_read
    mov ebx, [file_descriptor] ; file descriptor
    mov ecx, buf               ; buffer
    mov edx, 255               ; buffer size
    int 80h

    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, buf
    mov edx, 255
    int 0x80

    mov eax, 6 ; sys_close 
    mov ebx, [file_descriptor]
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, new_line
    mov edx, size_new_line
    int 0x80
.finish:
    xor ebx, ebx ; error_code=0
    mov eax, 1   ; sys_exit
    int 0x80     ; interrupt
.usage:
    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, usage_str
    mov edx, size_usage_str
    int 0x80

    jmp .finish
.not_opened:
    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, cant_open_str
    mov edx, size_cant_open_str
    int 0x80

    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, [file_name]
    mov edx, [size_file_name]
    int 0x80

    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, new_line
    mov edx, size_new_line
    int 0x80

    jmp .finish
; Data segment

segment readable writeable
    usage_str db 'Enter a file name. Example usage: ./head file_name.txt', 0x0a
    size_usage_str=$ - usage_str
    
    cant_open_str db 'Can not open file: ', 0x00
    size_cant_open_str=$ - cant_open_str

    new_line db 0x0a
    size_new_line=$ - new_line

segment readable writeable
    file_name       rd 4
    size_file_name  rd 1
    file_descriptor rd 1
    buf             rb 4