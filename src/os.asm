[BITS 64]
default rel

global _e

;================ defines =================

; System Table offsets
%define ST_CONIN_OFFSET        0x30
%define ST_BS                  96
%define BS_LP                  0x140

; Boot Services offsets
%define BS_WAIT_FOR_EVENT      96
%define BS_STALL               248

; GOP offsets
%define GOP_MODE               24
%define M_INF                  8
%define M_FB                   24
%define I_HRES                 4
%define I_VRES                 8
%define I_SL                   32

; Character dimensions
%define GLYPH_W                8
%define GLYPH_H                8
%define CHAR_W                 9
%define CHAR_H                 10

; Starting position
%define START_X                100
%define START_Y                100

; Special characters
%define KEY_BACKSPACE          8
%define KEY_ENTER              10
%define KEY_SPACE              32
%define KEY_DELETE             127
%define CHAR_CR                13
%define CHAR_LF                10
%define CHAR_TAB               9

; UEFI scan code compatibility
%define EFI_SCAN_DELETE        8

struc Video
    .fb:        resq 1
    .sl:        resq 1
    .w:         resq 1
    .h:         resq 1
    .fg:        resq 1
    .bg:        resq 1
    .cx:        resq 1
    .cy:        resq 1
endstruc

section .text

;================ entry =================

_e:
    cld
    and rsp, -16
    sub rsp, 32

    mov r12, rdx

    mov rax, [r12 + ST_CONIN_OFFSET]
    mov [conin], rax

    mov rbx, [r12 + ST_BS]
    test rbx, rbx
    jz fail
    mov [bs], rbx

    mov rax, [rbx + BS_LP]
    test rax, rax
    jz fail

    ;================ gop =================

    lea rcx, [guid]
    xor edx, edx
    lea r8, [gop]

    call rax
    add rsp, 32

    test rax, rax
    jnz fail

    ;================ mode =================

    mov rbx, [gop]
    test rbx, rbx
    jz fail

    mov rbx, [rbx + GOP_MODE]
    test rbx, rbx
    jz fail

    mov rax, [rbx + M_FB]
    test rax, rax
    jz fail
    mov [video + Video.fb], rax

    mov rsi, [rbx + M_INF]
    test rsi, rsi
    jz fail

    mov eax, [rsi + I_HRES]
    test eax, eax
    jnz .hres_ok
    mov eax, 1
.hres_ok:
    mov [video + Video.w], rax

    mov eax, [rsi + I_VRES]
    test eax, eax
    jnz .vres_ok
    mov eax, 1
.vres_ok:
    mov [video + Video.h], rax

    mov eax, [rsi + I_SL]
    test eax, eax
    jnz .stride_ok
    mov eax, [video + Video.w]
    test eax, eax
    jnz .stride_ok
    mov eax, 1
.stride_ok:
    mov [video + Video.sl], rax

    mov rax, [video + Video.sl]
    cmp qword [video + Video.w], rax
    jbe .width_ok
    mov [video + Video.w], rax
.width_ok:

    ;================ init =================

    mov qword [video + Video.fg], 0x00FFFFFF
    mov qword [video + Video.bg], 0x00000000

    call console_clear

    mov rax, [video + Video.w]
    cmp rax, START_X + CHAR_W
    jae .margin_ok
    mov qword [margin_x], 0
.margin_ok:

    mov rax, [margin_x]
    mov [video + Video.cx], rax
    mov qword [video + Video.cy], START_Y

    call ensure_y

    lea r9, [msg]
    call draw_text

    call keyboard_init

    ;================ start key loop =================

    call key_event_init
    cmp byte [events_ready], 1
    je .event_loop

;================ fallback busy loop =================

.busy_loop:
    call keyboard_get
    test al, al
    jz .busy_tick

    call process_key
    jmp .busy_loop

.busy_tick:
    call stall_1ms
    jmp .busy_loop

;================ event-based key loop =================

.event_loop:
    call wait_key_event
    test rax, rax
    jnz .busy_loop

    call keyboard_get
    test al, al
    jz .event_loop

    call process_key
    jmp .event_loop

;================ key processing =================

process_key:
    cmp al, KEY_BACKSPACE
    je .backspace

    cmp al, KEY_ENTER
    je .newline

    mov r9b, al
    call console_putc
    ret

.backspace:
    call backspace
    ret

.newline:
    call newline
    ret

;================ console API =================

console_clear:
    push rdi
    push rcx
    push rax

    cld
    mov rdi, [video + Video.fb]

    mov rax, [video + Video.sl]
    mov rcx, [video + Video.h]
    imul rax, rcx
    mov rcx, rax

    mov eax, [video + Video.bg]
    rep stosd

    pop rax
    pop rcx
    pop rdi
    ret

console_scroll:
    push rsi
    push rdi
    push rcx
    push rax
    push rdx

    cld

    mov rdi, [video + Video.fb]
    mov rax, [video + Video.h]
    cmp rax, CHAR_H
    jbe .done

    mov rax, [video + Video.sl]
    imul rax, CHAR_H
    lea rsi, [rdi + rax * 4]

    mov rax, [video + Video.sl]
    mov rcx, [video + Video.h]
    sub rcx, CHAR_H
    imul rax, rcx
    mov rcx, rax
    rep movsd

    ; Clear bottom line
    mov rdi, [video + Video.fb]
    mov rax, [video + Video.sl]
    mov rcx, [video + Video.h]
    sub rcx, CHAR_H
    imul rax, rcx
    lea rdi, [rdi + rax * 4]

    mov rax, [video + Video.sl]
    imul rax, CHAR_H
    mov rcx, rax
    mov eax, [video + Video.bg]
    rep stosd

.done:
    pop rdx
    pop rax
    pop rcx
    pop rdi
    pop rsi
    ret

console_putc:
    push rax
    push rcx
    push rdx
    push r8
    push r12

    movzx r12d, r9b

    cmp r12b, CHAR_CR
    je .do_cr
    cmp r12b, CHAR_LF
    je .do_lf
    cmp r12b, CHAR_TAB
    je .do_tab

    mov rax, [video + Video.cx]
    add rax, CHAR_W
    cmp rax, [video + Video.w]
    jbe .x_ok
    call newline
.x_ok:
    call ensure_y

    ; Draw character
    mov rcx, [video + Video.cx]
    mov rdx, [video + Video.cy]
    mov r9b, r12b
    call draw_char_with_bg

    add qword [video + Video.cx], CHAR_W

    mov rax, [video + Video.cx]
    cmp rax, [video + Video.w]
    jb .exit
    call newline
    jmp .exit

.do_cr:
    mov rax, [margin_x]
    mov [video + Video.cx], rax
    jmp .exit

.do_lf:
    call newline
    jmp .exit

.do_tab:
    add qword [video + Video.cx], CHAR_W * 4
    mov rax, [video + Video.cx]
    cmp rax, [video + Video.w]
    jb .exit
    call newline

.exit:
    pop r12
    pop r8
    pop rdx
    pop rcx
    pop rax
    ret

draw_char_with_bg:
    push rbx
    push rsi
    push r12
    push r13
    push r14
    push r15

    mov r12, rcx
    mov r13, rdx
    mov r14b, r9b

    ; Draw background
    mov rcx, r12
    mov rdx, r13
    mov r8d, CHAR_W
    mov r9d, CHAR_H
    call fill_rect_bg

    ; Draw glyph
    mov rcx, r12
    mov rdx, r13
    mov r8d, [video + Video.fg]
    mov r9b, r14b
    call draw_char

    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rbx
    ret

draw_text:
    push rsi
    mov rsi, r9

.next:
    mov al, [rsi]
    test al, al
    jz .done

    mov r9b, al
    call console_putc

    inc rsi
    jmp .next

.done:
    pop rsi
    ret

;================ edit =================

backspace:
    mov rax, [margin_x]
    cmp qword [video + Video.cx], rax
    jle .done

    sub qword [video + Video.cx], CHAR_W

    mov rcx, [video + Video.cx]
    mov rdx, [video + Video.cy]
    mov r8d, CHAR_W
    mov r9d, CHAR_H
    call fill_rect_bg

.done:
    ret

newline:
    mov rax, [margin_x]
    mov [video + Video.cx], rax
    add qword [video + Video.cy], CHAR_H
    call ensure_y
    ret

;================ view =================

ensure_y:
    mov rax, [video + Video.h]
    cmp rax, CHAR_H
    jbe .zero

    mov rax, [video + Video.cy]
    add rax, CHAR_H
    cmp rax, [video + Video.h]
    jbe .done

    call console_scroll

    mov rax, [video + Video.h]
    sub rax, CHAR_H
    mov [video + Video.cy], rax
    ret

.zero:
    mov qword [video + Video.cy], 0

.done:
    ret

;================ fill_rect =================

fill_rect:
    push rbx
    push rdi
    push rsi

    test r8, r8
    jz .done
    test r9, r9
    jz .done

    mov rax, [video + Video.w]
    cmp rcx, rax
    jae .done

    mov r11, rcx
    add r11, r8
    cmp r11, rax
    jbe .w_ok
    mov r8, rax
    sub r8, rcx
.w_ok:

    mov rax, [video + Video.h]
    cmp rdx, rax
    jae .done

    mov r11, rdx
    add r11, r9
    cmp r11, rax
    jbe .h_ok
    mov r9, rax
    sub r9, rdx
.h_ok:

    test r8, r8
    jz .done
    test r9, r9
    jz .done

    mov rdi, [video + Video.fb]
    mov rbx, [video + Video.sl]

    mov r11, rdx
    imul r11, rbx
    add r11, rcx
    shl r11, 2

.y:
    push r9
    mov rsi, r8

.x:
    mov dword [rdi + r11], r10d
    add r11, 4
    dec rsi
    jnz .x

    mov rax, [video + Video.sl]
    sub rax, r8
    shl rax, 2
    add r11, rax

    pop r9
    dec r9
    jnz .y

.done:
    pop rsi
    pop rdi
    pop rbx
    ret

fill_rect_bg:
    mov r10d, [video + Video.bg]
    call fill_rect
    ret

;================ keyboard =================

keyboard_init:
    call init_keyboard
    ret

init_keyboard:
    push rbx
    push r12

    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rcx, [conin]
    test rcx, rcx
    jz .done

    xor edx, edx
    call qword [rcx]

.done:
    mov rsp, r12
    pop r12
    pop rbx
    ret

keyboard_get:
    call keyboard_poll
    ret

keyboard_poll:
    push rbx
    push r12

    mov r12, rsp
    and rsp, -16
    sub rsp, 48

    mov rcx, [conin]
    test rcx, rcx
    jz .nokey

    lea rdx, [rsp + 32]
    call qword [rcx + 8]

    test rax, rax
    jnz .nokey


    movzx ecx, word [rsp + 32]
    movzx eax, word [rsp + 34]

    test eax, eax
    jnz .have_unicode

    cmp ecx, EFI_SCAN_DELETE
    je .scan_backspace
    jmp .nokey

.scan_backspace:
    mov eax, KEY_BACKSPACE
    jmp .key_ok

.have_unicode:
    cmp eax, CHAR_CR
    jne .not_cr
    mov eax, KEY_ENTER
.not_cr:

    cmp eax, KEY_DELETE
    jne .not_del
    mov eax, KEY_BACKSPACE
.not_del:

    cmp eax, KEY_BACKSPACE
    je .key_ok
    cmp eax, KEY_ENTER
    je .key_ok
    cmp eax, CHAR_TAB
    je .key_ok

    cmp eax, KEY_SPACE
    jb .nokey
    cmp eax, KEY_DELETE
    ja .nokey

.key_ok:
    mov rsp, r12
    pop r12
    pop rbx
    ret

.nokey:
    xor eax, eax
    mov rsp, r12
    pop r12
    pop rbx
    ret

;================ events =================

key_event_init:
    mov byte [events_ready], 0

    mov rcx, [conin]
    test rcx, rcx
    jz .fail

    mov rax, [rcx + 16]
    test rax, rax
    jz .fail

    mov [key_event], rax
    mov [event_array], rax
    mov byte [events_ready], 1

.fail:
    ret

wait_key_event:
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rcx, 1
    lea rdx, [event_array]
    lea r8, [event_index]

    mov rax, [bs]
    test rax, rax
    jz .error

    call qword [rax + BS_WAIT_FOR_EVENT]
    jmp .done

.error:
    mov eax, 1

.done:
    mov rsp, r12
    pop r12
    ret

stall_1ms:
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rcx, 1000        

    mov rax, [bs]
    test rax, rax
    jz .done

    call qword [rax + BS_STALL]

.done:
    mov rsp, r12
    pop r12
    ret

;================ char =================

draw_char:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    mov r12, rcx        
    mov r13, rdx        
    mov r14d, r8d
    movzx eax, r9b

    cmp eax, KEY_SPACE
    jb .done
    cmp eax, KEY_DELETE
    ja .done

    mov r15, [video + Video.w]
    cmp r12, r15
    jae .done

    mov r15, [video + Video.h]
    cmp r13, r15
    jae .done

    sub eax, KEY_SPACE
    shl eax, 3

    lea rsi, [font_table]
    add rsi, rax

    mov rdi, [video + Video.fb]
    mov r8, [video + Video.sl]

    mov r15, [video + Video.w]
    sub r15, r12
    cmp r15, GLYPH_W
    jbe .cols_ok
    mov r15, GLYPH_W
.cols_ok:

    mov r9, [video + Video.h]
    sub r9, r13
    cmp r9, GLYPH_H
    jbe .rows_ok
    mov r9, GLYPH_H
.rows_ok:

    xor r10d, r10d

.row:
    cmp r10, r9
    je .done

    mov bl, [rsi + r10]
    xor r11d, r11d      

.col:
    cmp r11, r15
    je .next_row

    test bl, 0x80
    jz .skip

    mov rdx, r13
    add rdx, r10
    imul rdx, r8

    mov rcx, r11
    add rcx, r12
    add rdx, rcx

    mov dword [rdi + rdx * 4], r14d

.skip:
    shl bl, 1
    inc r11d
    jmp .col

.next_row:
    inc r10d
    jmp .row

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

;================ fail =================

fail:
    mov dx, 0xE9
    mov al, 'F'
    out dx, al

.fail_loop:
    hlt
    jmp .fail_loop

;================ data =================

section .data

align 16
guid:
    dd 0x9042a9de
    dw 0x23dc
    dw 0x4a38
    db 0x96,0xfb,0x7a,0xde
    db 0xd0,0x80,0x51,0x6a

gop:
    dq 0

conin:
    dq 0

bs:
    dq 0

key_event:
    dq 0

event_array:
    dq 0

event_index:
    dq 0

events_ready:
    db 0

margin_x:
    dq START_X

align 8
video:
istruc Video
    at Video.fb,    dq 0
    at Video.sl,    dq 0
    at Video.w,     dq 0
    at Video.h,     dq 0
    at Video.fg,    dq 0x00FFFFFF
    at Video.bg,    dq 0x00000000
    at Video.cx,    dq START_X
    at Video.cy,    dq START_Y
iend

msg:
    db "Custom OS Kernel",10
    db "Framebuffer Text System",10
    db ">",0

;================ fonts =================

font_table:
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x18,0x18,0x18,0x18,0x18,0x00,0x18,0x00
    db 0x6C,0x6C,0x6C,0x00,0x00,0x00,0x00,0x00
    db 0x6C,0x6C,0xFE,0x6C,0xFE,0x6C,0x6C,0x00
    db 0x18,0x3E,0x60,0x3C,0x06,0x7C,0x18,0x00
    db 0x00,0xC6,0xCC,0x18,0x30,0x66,0xC6,0x00
    db 0x38,0x6C,0x38,0x76,0xDC,0xCC,0x76,0x00
    db 0x30,0x30,0x60,0x00,0x00,0x00,0x00,0x00
    db 0x0C,0x18,0x30,0x30,0x30,0x18,0x0C,0x00
    db 0x30,0x18,0x0C,0x0C,0x0C,0x18,0x30,0x00
    db 0x00,0x66,0x3C,0xFF,0x3C,0x66,0x00,0x00
    db 0x00,0x18,0x18,0x7E,0x18,0x18,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x30
    db 0x00,0x00,0x00,0x7E,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x00
    db 0x06,0x0C,0x18,0x30,0x60,0xC0,0x80,0x00
    db 0x7C,0xC6,0xCE,0xD6,0xE6,0xC6,0x7C,0x00
    db 0x18,0x38,0x78,0x18,0x18,0x18,0x7E,0x00
    db 0x7C,0xC6,0x06,0x1C,0x30,0x66,0xFE,0x00
    db 0x7C,0xC6,0x06,0x3C,0x06,0xC6,0x7C,0x00
    db 0x1C,0x3C,0x6C,0xCC,0xFE,0x0C,0x1E,0x00
    db 0xFE,0xC0,0xC0,0xFC,0x06,0xC6,0x7C,0x00
    db 0x38,0x60,0xC0,0xFC,0xC6,0xC6,0x7C,0x00
    db 0xFE,0xC6,0x0C,0x18,0x30,0x30,0x30,0x00
    db 0x7C,0xC6,0xC6,0x7C,0xC6,0xC6,0x7C,0x00
    db 0x7C,0xC6,0xC6,0x7E,0x06,0x0C,0x78,0x00
    db 0x00,0x00,0x18,0x18,0x00,0x18,0x18,0x00
    db 0x00,0x00,0x18,0x18,0x00,0x18,0x18,0x30
    db 0x0C,0x18,0x30,0x60,0x30,0x18,0x0C,0x00
    db 0x00,0x00,0x7E,0x00,0x7E,0x00,0x00,0x00
    db 0x30,0x18,0x0C,0x06,0x0C,0x18,0x30,0x00
    db 0x7C,0xC6,0x0C,0x18,0x18,0x00,0x18,0x00
    db 0x7C,0xC6,0xDE,0xDE,0xDC,0xC0,0x7C,0x00
    db 0x38,0x6C,0xC6,0xC6,0xFE,0xC6,0xC6,0x00
    db 0xFC,0xC6,0xC6,0xFC,0xC6,0xC6,0xFC,0x00
    db 0x3C,0x66,0xC0,0xC0,0xC0,0x66,0x3C,0x00
    db 0xF8,0xCC,0xC6,0xC6,0xC6,0xCC,0xF8,0x00
    db 0xFE,0xC0,0xC0,0xF8,0xC0,0xC0,0xFE,0x00
    db 0xFE,0xC0,0xC0,0xF8,0xC0,0xC0,0xC0,0x00
    db 0x3E,0x60,0xC0,0xDE,0xC6,0x66,0x3E,0x00
    db 0xC6,0xC6,0xC6,0xFE,0xC6,0xC6,0xC6,0x00
    db 0x7E,0x18,0x18,0x18,0x18,0x18,0x7E,0x00
    db 0x1E,0x0C,0x0C,0x0C,0xCC,0xCC,0x78,0x00
    db 0xC6,0xCC,0xD8,0xF0,0xD8,0xCC,0xC6,0x00
    db 0xC0,0xC0,0xC0,0xC0,0xC0,0xC0,0xFE,0x00
    db 0xC6,0xEE,0xFE,0xD6,0xC6,0xC6,0xC6,0x00
    db 0xC6,0xE6,0xF6,0xDE,0xCE,0xC6,0xC6,0x00
    db 0x7C,0xC6,0xC6,0xC6,0xC6,0xC6,0x7C,0x00
    db 0xFC,0xC6,0xC6,0xFC,0xC0,0xC0,0xC0,0x00
    db 0x7C,0xC6,0xC6,0xC6,0xD6,0xCC,0x76,0x00
    db 0xFC,0xC6,0xC6,0xFC,0xD8,0xCC,0xC6,0x00
    db 0x7C,0xC6,0xC0,0x7C,0x06,0xC6,0x7C,0x00
    db 0xFF,0x18,0x18,0x18,0x18,0x18,0x18,0x00
    db 0xC6,0xC6,0xC6,0xC6,0xC6,0xC6,0x7C,0x00
    db 0xC6,0xC6,0xC6,0xC6,0x6C,0x38,0x10,0x00
    db 0xC6,0xC6,0xC6,0xD6,0xFE,0xEE,0xC6,0x00
    db 0xC6,0xC6,0x6C,0x38,0x6C,0xC6,0xC6,0x00
    db 0xC3,0x66,0x3C,0x18,0x18,0x18,0x18,0x00
    db 0xFE,0x0C,0x18,0x30,0x60,0xC0,0xFE,0x00
    db 0x3C,0x30,0x30,0x30,0x30,0x30,0x3C,0x00
    db 0xC0,0x60,0x30,0x18,0x0C,0x06,0x02,0x00
    db 0x3C,0x0C,0x0C,0x0C,0x0C,0x0C,0x3C,0x00
    db 0x10,0x38,0x6C,0xC6,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF
    db 0x30,0x18,0x0C,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x78,0x0C,0x7C,0xCC,0x76,0x00
    db 0xC0,0xC0,0xFC,0xC6,0xC6,0xC6,0xFC,0x00
    db 0x00,0x00,0x7C,0xC6,0xC0,0xC6,0x7C,0x00
    db 0x06,0x06,0x7E,0xC6,0xC6,0xC6,0x7E,0x00
    db 0x00,0x00,0x7C,0xC6,0xFE,0xC0,0x7C,0x00
    db 0x1C,0x30,0x30,0xFC,0x30,0x30,0x30,0x00
    db 0x00,0x00,0x76,0xCC,0xCC,0x7C,0x0C,0x78
    db 0xC0,0xC0,0xFC,0xC6,0xC6,0xC6,0xC6,0x00
    db 0x18,0x00,0x38,0x18,0x18,0x18,0x3C,0x00
    db 0x0C,0x00,0x1C,0x0C,0x0C,0xCC,0xCC,0x78
    db 0xC0,0xC0,0xCC,0xD8,0xF0,0xD8,0xCC,0x00
    db 0x38,0x18,0x18,0x18,0x18,0x18,0x3C,0x00
    db 0x00,0x00,0xCC,0xFE,0xFE,0xD6,0xC6,0x00
    db 0x00,0x00,0xFC,0xC6,0xC6,0xC6,0xC6,0x00
    db 0x00,0x00,0x7C,0xC6,0xC6,0xC6,0x7C,0x00
    db 0x00,0x00,0xFC,0xC6,0xC6,0xFC,0xC0,0xC0
    db 0x00,0x00,0x7E,0xC6,0xC6,0x7E,0x06,0x06
    db 0x00,0x00,0xDC,0xE6,0xC0,0xC0,0xC0,0x00
    db 0x00,0x00,0x7C,0xC0,0x7C,0x06,0xFC,0x00
    db 0x30,0x30,0xFC,0x30,0x30,0x36,0x1C,0x00
    db 0x00,0x00,0xC6,0xC6,0xC6,0xC6,0x7E,0x00
    db 0x00,0x00,0xC6,0xC6,0xC6,0x6C,0x38,0x00
    db 0x00,0x00,0xC6,0xD6,0xFE,0xFE,0x6C,0x00
    db 0x00,0x00,0xC6,0x6C,0x38,0x6C,0xC6,0x00
    db 0x00,0x00,0xC6,0xC6,0xC6,0x7E,0x06,0x7C
    db 0x00,0x00,0xFE,0x0C,0x38,0x60,0xFE,0x00
    db 0x0E,0x18,0x18,0x70,0x18,0x18,0x0E,0x00
    db 0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x00
    db 0x70,0x18,0x18,0x0E,0x18,0x18,0x70,0x00
    db 0x76,0xDC,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
