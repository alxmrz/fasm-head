; Type output - 32 elf
format ELF executable
entry _start

; Code segment 
segment readable executable

_start:
    ;TODO change prompt with command line arguments
    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, prompt_str
    mov edx, size_prompt_str
    int 0x80

    ; Prompt block. Write file name to memory
    mov eax, 3
    mov ecx, file_name  
    mov edx, 255
    int 80h

    call rstrip ; Remove new line byte in file_name

    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, separator_line
    mov edx, size_separator_line
    int 0x80

    mov eax, 5 ; sys_open
    mov ebx, file_name ; file to open
    mov ecx, 0 ; read only
    int 80h

    mov [file_descriptor], eax ; save desctiptor to memory

    mov eax, 3 ; sys_read
    mov ebx, [file_descriptor] ; file descriptor
    mov ecx, buf ; buffer
    mov edx, 255 ; buffer size
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

    xor ebx, ebx ; error_code=0
    mov eax, 1   ; sys_exit
    int 0x80     ; interrupt

; TODO: Found in internet. Delete after migrating to argv
rstrip:
    dec     eax  ;convert 1-based length to 0-based pointer
.loop:
    cmp     byte [ecx + eax], 0xa
    je      .chop
    cmp     byte [ecx + eax], 0xc
    je      .chop
    cmp     byte [ecx + eax], 0xd
    je      .chop
.done:
    inc     eax  ;convert pointer back to length
    ret
.chop:
    mov     byte [ecx + eax], 0
    dec     eax
    jns     .loop
    jmp     .done

; Data segment
segment readable writeable
    usage_str db 'Type filename as parameter,i.e cat file.txt',0x0a
    usage_srt_len = $ - usage_str
    
    prompt_str db 'Write file name', 0x0a
    size_prompt_str=$ - prompt_str
    
    separator_line db '------------- HEAD OF FILE --------------------', 0x0a
    size_separator_line=$ - separator_line

    new_line db 0x0a
    size_new_line=$ - new_line

segment readable writeable
    file_name       rd 4
    file_descriptor rd 1
    buf             rb 4