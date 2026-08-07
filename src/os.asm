[BITS 64]
default rel

global _e

;================ defines =================

; System Table offsets
%define ST_CONIN_OFFSET        0x30
%define ST_BS                  0x60

; UEFI Boot Services offsets (x86_64)
%define BS_GET_MEMORY_MAP      0x38
%define BS_ALLOCATE_POOL       0x40
%define BS_FREE_POOL           0x48

%define BS_CREATE_EVENT        0x50
%define BS_SET_TIMER           0x58
%define BS_WAIT_FOR_EVENT      0x60
%define BS_SIGNAL_EVENT        0x68
%define BS_CLOSE_EVENT         0x70
%define BS_CHECK_EVENT         0x78

%define BS_STALL               0xF8
%define BS_SET_WATCHDOG_TIMER  0x100
%define BS_LOCATE_PROTOCOL     0x140
%define BS_EXIT_BOOT_SERVICES  0xE8

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

; UEFI event/timer
%define EVT_TIMER              0x80000000
%define TIMER_PERIODIC         1

; Cursor
%define CURSOR_BLINK_100NS     5000000
%define CURSOR_BLINK_MS        500
%define CURSOR_COLOR           0x00CCCCCC

;================ memory defines =================

%define PAGE_SHIFT             12
%define PAGE_SIZE              4096

%define EFI_SUCCESS            0
%define EFI_BUFFER_TOO_SMALL   0x8000000000000005

%define EFI_LOADER_DATA        2

%define MEM_TYPE_BS_CODE       3
%define MEM_TYPE_BS_DATA       4
%define MEM_TYPE_CONVENTIONAL  7

%define PMM_MAX_PAGES          0x200000
%define PMM_BITMAP_SIZE        (PMM_MAX_PAGES / 8)

;================ vmm defines =================

%define PAGE_PRESENT             (1 << 0)
%define PAGE_WRITABLE            (1 << 1)
%define PAGE_USER                (1 << 2)
%define PAGE_WRITETHROUGH        (1 << 3)
%define PAGE_CACHE_DISABLE       (1 << 4)
%define PAGE_ACCESSED            (1 << 5)
%define PAGE_DIRTY               (1 << 6)
%define PAGE_SIZE_FLAG           (1 << 7)
%define PAGE_GLOBAL              (1 << 8)

%define PT_INDEX_BITS            0x1FF
%define VMM_2MB_PAGE_SIZE        (2 * 1024 * 1024)

%macro MASK_FRAME 1
    shl %1, 12
    shr %1, 12
    and %1, -4096
%endmacro

%define CMD_MAX 64

%macro FAIL_CODE 1
    mov al, %1
    jmp fail_code
%endmacro

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

struc BootInfo
    .fb:                resq 1
    .width:             resq 1
    .height:            resq 1
    .stride:            resq 1

    .mem_map:           resq 1
    .mem_size:          resq 1
    .mem_map_key:       resq 1
    .mem_desc_size:     resq 1
    .mem_desc_version:  resq 1

    .pmm_bitmap:        resq 1
    .pmm_total_pages:   resq 1
    .pmm_free_pages:    resq 1
endstruc

section .text

;================ entry =================

_e:
    cld
    and rsp, -16
    sub rsp, 32

    mov [image_handle], rcx
    mov r12, rdx

    mov rax, [r12 + ST_CONIN_OFFSET]
    mov [conin], rax

    mov rbx, [r12 + ST_BS]
    test rbx, rbx
    jz fail
    mov [bs], rbx

    ; Disable UEFI watchdog timer.
    mov rax, [rbx + BS_SET_WATCHDOG_TIMER]
    test rax, rax
    jz .watchdog_ok

    xor ecx, ecx
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call rax

.watchdog_ok:
    mov rbx, [bs]
    mov rax, [rbx + BS_LOCATE_PROTOCOL]
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

    ; Sanitize margin early.
    mov rax, [video + Video.w]
    cmp rax, START_X + CHAR_W
    jae .margin_ok
    mov qword [margin_x], 0
.margin_ok:

    ;================ boot info =================

    mov rax, [video + Video.fb]
    mov [boot_info + BootInfo.fb], rax

    mov rax, [video + Video.w]
    mov [boot_info + BootInfo.width], rax

    mov rax, [video + Video.h]
    mov [boot_info + BootInfo.height], rax

    mov rax, [video + Video.sl]
    mov [boot_info + BootInfo.stride], rax

    ;================ early console =================

    mov qword [video + Video.fg], 0x00FFFFFF
    mov qword [video + Video.bg], 0x00000000

    call console_clear

    mov rax, [margin_x]
    mov [video + Video.cx], rax
    mov qword [video + Video.cy], START_Y

    call ensure_y

    lea r9, [msg]
    call draw_text

    ;================ init =================

    call mem_init

    ;================ vmm build =================

    lea r9, [msg_vmm_build]
    call draw_text

    call vmm_build

    lea r9, [msg_vmm_ok]
    call draw_text

    ;================ keyboard =================

    call keyboard_init

    ;================ cursor init =================

    call cursor_draw

    ;================ events =================

    call key_event_init
    call timer_event_init

    ;================ vmm activate =================

    lea r9, [msg_vmm_activate]
    call draw_text

    call vmm_activate
    mov byte [vmm_active], 1

    lea r9, [msg_vmm_active]
    call draw_text

    ;================ minimal IDT =================

    call idt_init_minimal

    lea r9, [msg_idt_ok]
    call draw_text

    lea r9, [msg_shell_hint]
    call draw_text

    lea r9, [prompt_str]
    call draw_text

    call cursor_draw
    mov dword [blink_counter], 0

    ;================ start key loop =================

    cmp byte [events_ready], 1
    jne .busy_loop

    cmp byte [timer_ready], 1
    je .event_loop

    jmp .busy_loop

;================ fallback busy loop =================

.busy_loop:
    call keyboard_get
    test al, al
    jz .busy_tick

    call process_key
    call cursor_draw

    mov dword [blink_counter], 0
    jmp .busy_loop

.busy_tick:
    call stall_1ms

    inc dword [blink_counter]
    cmp dword [blink_counter], CURSOR_BLINK_MS
    jb .busy_loop

    mov dword [blink_counter], 0
    call cursor_toggle
    jmp .busy_loop

;================ event-based key/timer loop =================

.event_loop:
    call wait_event

    cmp eax, 0
    je .event_key

    cmp eax, 1
    je .event_timer

    jmp .busy_loop

.event_key:
    call keyboard_get
    test al, al
    jz .event_loop

    call process_key
    call cursor_draw

    call timer_restart
    jmp .event_loop

.event_timer:
    call cursor_toggle
    jmp .event_loop

;================ key processing / mini shell input =================

process_key:
    sub rsp, 8

    cmp al, KEY_BACKSPACE
    je .backspace

    cmp al, KEY_ENTER
    je .enter

    cmp al, CHAR_TAB
    je .ignore

    call cmd_append_char

    add rsp, 8
    ret

.backspace:
    call cmd_backspace
    add rsp, 8
    ret

.enter:
    call cmd_enter
    add rsp, 8
    ret

.ignore:
    add rsp, 8
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

    mov byte [cursor_shown], 0

    pop rax
    pop rcx
    pop rdi
    ret

console_scroll:
    call cursor_erase

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
    sub rsp, 8

    movzx r12d, r9b

    ; Erase current cursor before moving/printing.
    call cursor_erase

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
    add rsp, 8
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
    sub rsp, 8

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

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rbx
    ret

draw_text:
    push rsi
    sub rsp, 8
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
    add rsp, 8
    pop rsi
    ret

;================ edit =================

backspace:
    sub rsp, 8

    mov rax, [margin_x]
    cmp qword [video + Video.cx], rax
    jle .done

    call cursor_erase

    sub qword [video + Video.cx], CHAR_W

    mov rcx, [video + Video.cx]
    mov rdx, [video + Video.cy]
    mov r8, CHAR_W
    mov r9, CHAR_H
    call fill_rect_bg

.done:
    add rsp, 8
    ret

newline:
    sub rsp, 8

    call cursor_erase
    mov rax, [margin_x]
    mov [video + Video.cx], rax
    add qword [video + Video.cy], CHAR_H
    call ensure_y

    add rsp, 8
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
    push r12

    cld

    ; width/height = 0
    test r8, r8
    jz .done
    test r9, r9
    jz .done

    ; clip X
    mov rax, [video + Video.w]
    cmp rcx, rax
    jae .done

    mov r12, rcx
    add r12, r8
    cmp r12, rax
    jbe .x_ok

    sub rax, rcx
    mov r8, rax

.x_ok:
    ; clip Y
    mov rax, [video + Video.h]
    cmp rdx, rax
    jae .done

    mov r12, rdx
    add r12, r9
    cmp r12, rax
    jbe .y_ok

    sub rax, rdx
    mov r9, rax

.y_ok:
    test r8, r8
    jz .done
    test r9, r9
    jz .done

    ; framebuffer base
    mov rdi, [video + Video.fb]

    ; offset = (y*stride+x)*4
    mov rax, [video + Video.sl]
    imul rax, rdx
    add rax, rcx
    shl rax, 2
    add rdi, rax

    ; bytes after each line
    mov rbx, [video + Video.sl]
    sub rbx, r8
    shl rbx, 2

.row:
    mov eax, r10d
    mov rcx, r8
    rep stosd

    add rdi, rbx

    dec r9
    jnz .row

.done:
    pop r12
    pop rdi
    pop rbx
    ret

fill_rect_bg:
    mov r10d, [video + Video.bg]
    call fill_rect
    ret

;================ cursor =================

cursor_draw:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov rax, [video + Video.cx]
    mov [cursor_x], rax

    mov rax, [video + Video.cy]
    mov [cursor_y], rax

    mov rcx, [cursor_x]
    mov rdx, [cursor_y]
    mov r8, CHAR_W
    mov r9, CHAR_H
    mov r10d, CURSOR_COLOR

    call fill_rect

    mov byte [cursor_shown], 1

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

cursor_erase:
    cmp byte [cursor_shown], 0
    je .done

    push rcx
    push rdx
    push r8
    push r9

    mov rcx, [cursor_x]
    mov rdx, [cursor_y]
    mov r8, CHAR_W
    mov r9, CHAR_H
    call fill_rect_bg

    pop r9
    pop r8
    pop rdx
    pop rcx

    mov byte [cursor_shown], 0

.done:
    ret

cursor_toggle:
    cmp byte [cursor_shown], 0
    je cursor_draw
    jmp cursor_erase

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

    mov rax, [rcx]
    test rax, rax
    jz .done

    xor edx, edx
    call rax

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

    mov rax, [rcx + 8]
    test rax, rax
    jz .nokey

    lea rdx, [rsp + 32]
    call rax

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

timer_event_init:
    push rbx
    push r12

    mov r12, rsp
    and rsp, -16
    sub rsp, 48

    mov byte [timer_ready], 0

    mov rbx, [bs]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + BS_CREATE_EVENT]
    test rax, rax
    jz .fail

    mov ecx, EVT_TIMER
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d

    lea r10, [timer_event]
    mov [rsp + 32], r10

    call rax
    test rax, rax
    jnz .fail

    mov rbx, [bs]
    mov rax, [rbx + BS_SET_TIMER]
    test rax, rax
    jz .fail

    mov rcx, [timer_event]
    test rcx, rcx
    jz .fail

    mov edx, TIMER_PERIODIC
    mov r8, CURSOR_BLINK_100NS

    call rax
    test rax, rax
    jnz .fail

    mov rax, [timer_event]
    mov [event_array + 8], rax
    mov byte [timer_ready], 1

.fail:
    mov rsp, r12
    pop r12
    pop rbx
    ret

wait_event:
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rax, [bs]
    test rax, rax
    jz .error

    cmp byte [events_ready], 1
    jne .error

    lea rdx, [event_array]
    lea r8, [event_index]

    cmp byte [timer_ready], 1
    jne .one_event

    mov rcx, 2
    call qword [rax + BS_WAIT_FOR_EVENT]
    test rax, rax
    jnz .error

    mov rax, [event_index]

    cmp rax, 1
    je .timer

    test rax, rax
    jz .key

    jmp .error

.one_event:
    mov rcx, 1
    call qword [rax + BS_WAIT_FOR_EVENT]
    test rax, rax
    jnz .error

.key:
    xor eax, eax
    jmp .done

.timer:
    mov eax, 1
    jmp .done

.error:
    mov eax, 2

.done:
    mov rsp, r12
    pop r12
    ret

timer_restart:
    cmp byte [timer_ready], 1
    jne .done

    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rax, [bs]
    test rax, rax
    jz .pop

    mov rax, [rax + BS_SET_TIMER]
    test rax, rax
    jz .pop

    mov rcx, [timer_event]
    xor edx, edx
    xor r8d, r8d
    call rax

    mov rax, [bs]
    mov rax, [rax + BS_SET_TIMER]
    test rax, rax
    jz .pop

    mov rcx, [timer_event]
    mov edx, TIMER_PERIODIC
    mov r8, CURSOR_BLINK_100NS
    call rax

.pop:
    mov rsp, r12
    pop r12

.done:
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

    mov rax, [rax + BS_STALL]
    test rax, rax
    jz .done

    call rax

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
    push rbp

    mov r12, rcx        ; x
    mov r13, rdx        ; y
    mov r14d, r8d       ; color
    movzx ebp, r9b

    cmp ebp, KEY_SPACE
    jb .done

    cmp ebp, KEY_DELETE
    ja .done

    ; Simple clipping.
    mov rax, r12
    add rax, GLYPH_W
    cmp rax, [video + Video.w]
    ja .done

    mov rax, r13
    add rax, GLYPH_H
    cmp rax, [video + Video.h]
    ja .done

    mov eax, ebp
    sub eax, KEY_SPACE
    shl eax, 3

    lea rsi, [font_table]
    add rsi, rax

    mov rdi, [video + Video.fb]
    mov r15, [video + Video.sl]

    ; byte pitch
    shl r15, 2

    ; start pixel offset
    mov rax, r13
    mov rdx, r15
    imul rax, rdx

    mov rdx, r12
    shl rdx, 2

    add rax, rdx
    add rdi, rax

    xor r10d, r10d

.row:
    cmp r10d, GLYPH_H
    jae .done

    mov bl, [rsi + r10]

    xor r11d, r11d

.col:
    cmp r11d, GLYPH_W
    jae .next_row

    test bl, 80h
    jz .skip

    mov eax, r14d
    mov [rdi + r11*4], eax

.skip:
    shl bl, 1

    inc r11d
    jmp .col

.next_row:
    add rdi, r15

    inc r10d
    jmp .row

.done:
    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

;================ memory =================

mem_init:
    cmp qword [boot_info + BootInfo.mem_map], 0
    jne .have_map

    call get_memory_map

.have_map:
    call pmm_init
    ret

get_memory_map:
    push rbx
    push r12
    push r13
    push r14

    mov r12, rsp
    and rsp, -16
    sub rsp, 48

    mov rbx, [bs]
    test rbx, rbx
    jz .err_bs

    mov r13, [rbx + BS_GET_MEMORY_MAP]
    test r13, r13
    jz .err_gmm_ptr

    xor r14, r14

.retry:
    mov qword [mm_tmp_size], 0
    mov qword [mm_tmp_buffer], 0

    lea rcx, [mm_tmp_size]
    xor edx, edx
    lea r8, [mm_tmp_key]
    lea r9, [mm_tmp_desc_size]
    lea r10, [mm_tmp_desc_version]
    mov [rsp + 32], r10
    call r13

    cmp rax, 5
    je .allocate

    mov r10, EFI_BUFFER_TOO_SMALL
    cmp rax, r10
    je .allocate

    test rax, rax
    jnz .err_first

    cmp qword [mm_tmp_size], 0
    je .err_size

.allocate:
    mov rdx, [mm_tmp_desc_size]
    test rdx, rdx
    jnz .desc_ok
    mov rdx, 48

.desc_ok:
    shl rdx, 4
    add rdx, 4096
    add rdx, [mm_tmp_size]
    mov [mm_tmp_size], rdx

    mov ecx, EFI_LOADER_DATA
    mov rdx, [mm_tmp_size]
    lea r8, [mm_tmp_buffer]

    mov rax, [rbx + BS_ALLOCATE_POOL]
    test rax, rax
    jz .err_alloc
    call rax

    test rax, rax
    jnz .err_alloc

    mov rdx, [mm_tmp_buffer]
    test rdx, rdx
    jz .err_buf

    mov r13, [rbx + BS_GET_MEMORY_MAP]
    test r13, r13
    jz .err_gmm_ptr2

    lea rcx, [mm_tmp_size]
    mov rdx, [mm_tmp_buffer]
    lea r8, [mm_tmp_key]
    lea r9, [mm_tmp_desc_size]
    lea r10, [mm_tmp_desc_version]
    mov [rsp + 32], r10
    call r13

    test rax, rax
    jz .success

    cmp rax, 5
    je .retry_path

    mov r10, EFI_BUFFER_TOO_SMALL
    cmp rax, r10
    jne .err_second

.retry_path:
    mov rcx, [mm_tmp_buffer]
    test rcx, rcx
    jz .retry_no_free

    mov rax, [rbx + BS_FREE_POOL]
    test rax, rax
    jz .retry_no_free
    call rax

.retry_no_free:
    inc r14
    cmp r14, 3
    jb .retry

    FAIL_CODE '9'

.success:
    mov rax, [mm_tmp_buffer]
    mov [boot_info + BootInfo.mem_map], rax

    mov rax, [mm_tmp_size]
    mov [boot_info + BootInfo.mem_size], rax

    mov rax, [mm_tmp_key]
    mov [boot_info + BootInfo.mem_map_key], rax

    mov rax, [mm_tmp_desc_size]
    mov [boot_info + BootInfo.mem_desc_size], rax

    mov eax, [mm_tmp_desc_version]
    mov [boot_info + BootInfo.mem_desc_version], rax

    mov rsp, r12
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.err_bs:
    FAIL_CODE '1'

.err_gmm_ptr:
    FAIL_CODE '2'

.err_first:
    FAIL_CODE '3'

.err_size:
    FAIL_CODE '4'

.err_alloc:
    FAIL_CODE '5'

.err_buf:
    FAIL_CODE '6'

.err_gmm_ptr2:
    FAIL_CODE '7'

.err_second:
    FAIL_CODE '8'

pmm_init:
    push rbx
    push r12
    push r13
    push r14
    push r15
    push rdi
    sub rsp, 8

    lea rdi, [pmm_bitmap]
    mov [boot_info + BootInfo.pmm_bitmap], rdi

    mov qword [boot_info + BootInfo.pmm_total_pages], 0
    mov qword [boot_info + BootInfo.pmm_free_pages], 0
    mov qword [pmm_next_word], 0

    mov r14, [boot_info + BootInfo.mem_map]
    test r14, r14
    jz .err_map

    mov r15, [boot_info + BootInfo.mem_size]
    test r15, r15
    jz .err_size

    mov rbx, [boot_info + BootInfo.mem_desc_size]
    test rbx, rbx
    jz .err_desc

    cmp rbx, 40
    jb .err_desc_small

    cld
    mov eax, 0xFF
    mov rcx, PMM_BITMAP_SIZE
    rep stosb

    xor r12, r12
    xor r13, r13

.loop:
    cmp r15, rbx
    jb .finish

    mov eax, [r14]
    cmp eax, MEM_TYPE_CONVENTIONAL
    je .usable

    jmp .next

.usable:
    mov rax, [r14 + 8]
    mov r8, [r14 + 24]

    test r8, r8
    jz .next

    mov r9, rax
    shr r9, PAGE_SHIFT

    cmp r9, PMM_MAX_PAGES
    jae .next

    mov r10, r9
    add r10, r8
    jc .cap_max

    cmp r10, PMM_MAX_PAGES
    jbe .cap_ok

.cap_max:
    mov r10, PMM_MAX_PAGES

.cap_ok:
    cmp r9, 1
    jae .start_ok
    mov r9, 1

.start_ok:
    cmp r9, r10
    jae .next

    cmp r10, r12
    jbe .top_ok
    mov r12, r10

.top_ok:
    mov rax, r10
    sub rax, r9
    add r13, rax

    mov rcx, r9
    mov rdx, r10
    call pmm_clear_range

.next:
    add r14, rbx
    sub r15, rbx
    jmp .loop

.finish:
    test r12, r12
    jz .err_top

    test r13, r13
    jz .err_free

    mov [boot_info + BootInfo.pmm_total_pages], r12
    mov [boot_info + BootInfo.pmm_free_pages], r13
    mov qword [pmm_next_word], 0

    add rsp, 8
    pop rdi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.err_map:
    FAIL_CODE 'A'

.err_size:
    FAIL_CODE 'B'

.err_desc:
    FAIL_CODE 'C'

.err_desc_small:
    FAIL_CODE 'D'

.err_top:
    FAIL_CODE 'E'

.err_free:
    FAIL_CODE 'G'

pmm_clear_range:
    cmp rcx, rdx
    jae .done

    mov r10, [boot_info + BootInfo.pmm_bitmap]
    test r10, r10
    jz .done

.head:
    mov rax, rcx
    and eax, 63
    jz .full

.head_bit:
    mov r11, rcx
    shr r11, 6

    mov r8, rcx
    and r8, 63

    btr qword [r10 + r11*8], r8

    inc rcx
    cmp rcx, rdx
    jae .done
    jmp .head

.full:
    mov r9, rdx
    sub r9, rcx
    cmp r9, 64
    jb .tail

    mov r11, rcx
    shr r11, 6
    mov qword [r10 + r11*8], 0

    add rcx, 64
    jmp .full

.tail:
    cmp rcx, rdx
    jae .done

.tail_bit:
    mov r11, rcx
    shr r11, 6

    mov r8, rcx
    and r8, 63

    btr qword [r10 + r11*8], r8

    inc rcx
    cmp rcx, rdx
    jb .tail_bit

.done:
    ret

pmm_alloc_page:
    xor eax, eax

    cmp qword [boot_info + BootInfo.pmm_free_pages], 0
    je .done

    mov r10, [boot_info + BootInfo.pmm_bitmap]
    test r10, r10
    je .done

    mov r8, [boot_info + BootInfo.pmm_total_pages]
    test r8, r8
    je .done

    lea r9, [r8 + 63]
    shr r9, 6

    mov rcx, [pmm_next_word]
    cmp rcx, r9
    jb .start_ok
    xor rcx, rcx

.start_ok:
    mov rdx, rcx

.scan_first:
    cmp rdx, r9
    jae .wrap

    mov rax, [r10 + rdx*8]
    not rax
    jnz .found

    inc rdx
    jmp .scan_first

.wrap:
    test rcx, rcx
    jz .none

    xor rdx, rdx

.scan_second:
    cmp rdx, rcx
    jae .none

    mov rax, [r10 + rdx*8]
    not rax
    jnz .found

    inc rdx
    jmp .scan_second

.found:
    bsf rax, rax

    mov r11, rdx
    shl r11, 6
    add r11, rax

    cmp r11, r8
    jae .none

    mov rcx, r11
    shr rcx, 6

    mov rax, r11
    and eax, 63
    bts qword [r10 + rcx*8], rax

    dec qword [boot_info + BootInfo.pmm_free_pages]

    mov rax, [r10 + rcx*8]
    cmp rax, -1
    jne .next_ok
    inc rcx

.next_ok:
    mov [pmm_next_word], rcx

    mov rax, r11
    shl rax, PAGE_SHIFT
    ret

.none:
    xor eax, eax

.done:
    ret

pmm_free_page:
    test rcx, rcx
    jz .done

    test rcx, 0xFFF
    jnz .done

    mov rdx, rcx
    shr rdx, PAGE_SHIFT

    cmp rdx, [boot_info + BootInfo.pmm_total_pages]
    jae .done

    mov r10, [boot_info + BootInfo.pmm_bitmap]
    test r10, r10
    jz .done

    mov r11, rdx
    shr r11, 6

    mov r8, rdx
    and r8, 63

    bt qword [r10 + r11*8], r8
    jnc .done

    btr qword [r10 + r11*8], r8
    inc qword [boot_info + BootInfo.pmm_free_pages]

    cmp r11, [pmm_next_word]
    jae .done
    mov [pmm_next_word], r11

.done:
    ret

mem_alloc:
    test rcx, rcx
    jz .fail

    cmp rcx, PAGE_SIZE
    ja .fail

    jmp pmm_alloc_page

.fail:
    xor eax, eax
    ret

mem_free:
    jmp pmm_free_page

;================ vmm =================

zero_page:
    push rdi
    push rcx
    push rax

    cld
    mov rdi, rcx
    xor eax, eax
    mov rcx, PAGE_SIZE / 8
    rep stosq

    pop rax
    pop rcx
    pop rdi
    ret

vmm_map_2mb:
    push rbx
    push r12
    push r13
    push r14

    mov r12, rcx
    mov r13, rdx

    mov rbx, [pml4_ptr]
    test rbx, rbx
    jz .oom

    ; PML4 -> PDPT
    mov rax, r12
    shr rax, 39
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov rax, [rbx + r14 * 8]
    test al, PAGE_PRESENT
    jnz .pdpt_ready

    call pmm_alloc_page
    test rax, rax
    jz .oom

    mov rcx, rax
    call zero_page

    or rax, PAGE_PRESENT | PAGE_WRITABLE
    mov [rbx + r14 * 8], rax

.pdpt_ready:
    mov rax, [rbx + r14 * 8]
    MASK_FRAME rax
    mov rbx, rax

    ; PDPT -> PD
    mov rax, r12
    shr rax, 30
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov rax, [rbx + r14 * 8]
    test al, PAGE_PRESENT
    jnz .pd_ready

    call pmm_alloc_page
    test rax, rax
    jz .oom

    mov rcx, rax
    call zero_page

    or rax, PAGE_PRESENT | PAGE_WRITABLE
    mov [rbx + r14 * 8], rax

.pd_ready:
    mov rax, [rbx + r14 * 8]
    MASK_FRAME rax
    mov rbx, rax

    ; install 2MB page
    mov rax, r12
    shr rax, 21
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov rax, [rbx + r14 * 8]
    test al, PAGE_PRESENT
    jz .install

    test al, PAGE_SIZE_FLAG
    jz .conflict

.install:
    mov rax, r12
    or rax, r13
    or rax, PAGE_PRESENT | PAGE_SIZE_FLAG
    mov [rbx + r14 * 8], rax

    xor eax, eax
    jmp .done

.conflict:
    mov eax, 1
    jmp .done

.oom:
    mov eax, 2

.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

vmm_build:
    push rbx
    push r12
    push r13

    call pmm_alloc_page
    test rax, rax
    jz .oom

    mov [pml4_ptr], rax
    mov rcx, rax
    call zero_page

    mov rax, PMM_MAX_PAGES
    shl rax, PAGE_SHIFT
    mov r12, rax

    mov rax, [video + Video.sl]
    mov rdx, [video + Video.h]
    imul rax, rdx
    shl rax, 2
    add rax, [video + Video.fb]

    add rax, VMM_2MB_PAGE_SIZE - 1
    and rax, -VMM_2MB_PAGE_SIZE

    cmp rax, r12
    jbe .ceiling_ok
    mov r12, rax
.ceiling_ok:

    xor r13, r13

.map_loop:
    cmp r13, r12
    jae .map_done

    mov rcx, r13
    mov rdx, PAGE_WRITABLE
    call vmm_map_2mb

    test eax, eax
    jz .map_next

    cmp eax, 1
    je .conflict

    jmp .oom

.map_next:
    add r13, VMM_2MB_PAGE_SIZE
    jmp .map_loop

.map_done:
    xor eax, eax
    pop r13
    pop r12
    pop rbx
    ret

.conflict:
    FAIL_CODE 'H'

.oom:
    FAIL_CODE 'I'

vmm_activate:
    mov rax, [pml4_ptr]
    test rax, rax
    jz .done

    mov cr3, rax

.done:
    ret

;================ minimal idt / exceptions =================

%macro ISR_NOERR 1
isr_stub_%1:
    push qword 0
    push qword %1
    jmp isr_common
%endmacro

%macro ISR_ERR 1
isr_stub_%1:
    push qword %1
    jmp isr_common
%endmacro

ISR_NOERR 0
ISR_NOERR 1
ISR_NOERR 2
ISR_NOERR 3
ISR_NOERR 4
ISR_NOERR 5
ISR_NOERR 6
ISR_NOERR 7
ISR_ERR   8
ISR_NOERR 9
ISR_ERR   10
ISR_ERR   11
ISR_ERR   12
ISR_ERR   13
ISR_ERR   14
ISR_NOERR 15
ISR_NOERR 16
ISR_ERR   17
ISR_NOERR 18
ISR_NOERR 19
ISR_NOERR 20
ISR_ERR   21
ISR_NOERR 22
ISR_NOERR 23
ISR_NOERR 24
ISR_NOERR 25
ISR_NOERR 26
ISR_NOERR 27
ISR_NOERR 28
ISR_NOERR 29
ISR_ERR   30
ISR_NOERR 31

align 8
isr_stub_table:
    dd isr_stub_0 - isr_stub_table
    dd isr_stub_1 - isr_stub_table
    dd isr_stub_2 - isr_stub_table
    dd isr_stub_3 - isr_stub_table
    dd isr_stub_4 - isr_stub_table
    dd isr_stub_5 - isr_stub_table
    dd isr_stub_6 - isr_stub_table
    dd isr_stub_7 - isr_stub_table
    dd isr_stub_8 - isr_stub_table
    dd isr_stub_9 - isr_stub_table
    dd isr_stub_10 - isr_stub_table
    dd isr_stub_11 - isr_stub_table
    dd isr_stub_12 - isr_stub_table
    dd isr_stub_13 - isr_stub_table
    dd isr_stub_14 - isr_stub_table
    dd isr_stub_15 - isr_stub_table
    dd isr_stub_16 - isr_stub_table
    dd isr_stub_17 - isr_stub_table
    dd isr_stub_18 - isr_stub_table
    dd isr_stub_19 - isr_stub_table
    dd isr_stub_20 - isr_stub_table
    dd isr_stub_21 - isr_stub_table
    dd isr_stub_22 - isr_stub_table
    dd isr_stub_23 - isr_stub_table
    dd isr_stub_24 - isr_stub_table
    dd isr_stub_25 - isr_stub_table
    dd isr_stub_26 - isr_stub_table
    dd isr_stub_27 - isr_stub_table
    dd isr_stub_28 - isr_stub_table
    dd isr_stub_29 - isr_stub_table
    dd isr_stub_30 - isr_stub_table
    dd isr_stub_31 - isr_stub_table

%if ($ - isr_stub_table) != 32 * 4
    %error "isr_stub_table does not have exactly 32 entries"
%endif

isr_common:
    cli

    mov rcx, [rsp]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 16]

    mov rax, rsp
    and rsp, -16
    sub rsp, 32

    call panic_exception

panic_exception:
    cli

    push r15
    push r14
    push r13

    mov r15, rcx        ; vector
    mov r14, rdx        ; error code
    mov r13, r8         ; rip

    mov qword [video + Video.fg], 0x00FF5A5A
    mov qword [video + Video.bg], 0x00140000
    mov byte [cursor_shown], 0

    call console_clear

    mov rax, [margin_x]
    mov [video + Video.cx], rax
    mov qword [video + Video.cy], START_Y

    call ensure_y

    lea r9, [str_panic_banner]
    call draw_text

    lea r9, [str_vector]
    call draw_text
    mov rcx, r15
    call print_hex64

    lea r9, [str_error]
    call draw_text
    mov rcx, r14
    call print_hex64

    lea r9, [str_rip]
    call draw_text
    mov rcx, r13
    call print_hex64

    lea r9, [str_halted]
    call draw_text

.halt:
    cli
    hlt
    jmp .halt

print_hex64:
    push rbx
    push r13
    push r14

    mov r13, rcx
    lea rbx, [hex_digits]
    mov r14, 64

.digit_loop:
    sub r14, 4

    mov rax, r13
    mov ecx, r14d
    shr rax, cl
    and eax, 0x0F

    movzx r9d, byte [rbx + rax]
    call console_putc

    test r14, r14
    jnz .digit_loop

    pop r14
    pop r13
    pop rbx
    ret

idt_init_minimal:
    push rbx
    push r12
    push r13
    push rsi
    push rdi

    cld

    sidt [old_idtr_limit]

    lea rdi, [idt]
    xor eax, eax
    mov rcx, (256 * 16) / 8
    rep stosq

    movzx ecx, word [old_idtr_limit]
    inc rcx

    cmp rcx, 256 * 16
    jbe .copy_ok

    mov rcx, 256 * 16

.copy_ok:
    mov rsi, [old_idtr_base]
    test rsi, rsi
    jz .no_copy

    lea rdi, [idt]
    rep movsb

.no_copy:
    mov ax, cs
    movzx r12, ax

    xor r13, r13

.fill_loop:
    lea rbx, [isr_stub_table]
    movsxd rax, dword [rbx + r13 * 4]
    lea rax, [rbx + rax]

    lea rdi, [idt]
    mov rcx, r13
    imul rcx, 16
    add rdi, rcx

    mov word [rdi + 0], ax
    mov word [rdi + 2], r12w
    mov byte [rdi + 4], 0
    mov byte [rdi + 5], 0x8E

    shr rax, 16
    mov word [rdi + 6], ax

    shr rax, 16
    mov dword [rdi + 8], eax
    mov dword [rdi + 12], 0

    inc r13
    cmp r13, 32
    jb .fill_loop

    lea rax, [idt]
    mov [new_idtr_base], rax

    lidt [new_idtr_limit]

    pop rdi
    pop rsi
    pop r13
    pop r12
    pop rbx
    ret

;================ mini shell =================

cmd_append_char:
    push rdi
    push rcx

    mov rcx, [cmd_len]
    cmp rcx, CMD_MAX - 1
    jae .done

    lea rdi, [cmd_buf]
    mov [rdi + rcx], al
    inc qword [cmd_len]

    mov r9b, al
    call console_putc

.done:
    pop rcx
    pop rdi
    ret

cmd_backspace:
    cmp qword [cmd_len], 0
    je .done

    dec qword [cmd_len]

    mov rcx, [cmd_len]
    lea rdi, [cmd_buf]
    mov byte [rdi + rcx], 0

    call backspace

.done:
    ret

cmd_enter:
    push rdi
    push rcx

    mov rcx, [cmd_len]
    lea rdi, [cmd_buf]
    mov byte [rdi + rcx], 0

    call cmd_execute

    mov qword [cmd_len], 0

    pop rcx
    pop rdi

    call newline

    lea r9, [prompt_str]
    call draw_text

    ret

cmd_is:
    ; input: rsi = command string
    ; output: eax = 1 if equal, else 0

    push rsi
    push rdi

    lea rdi, [cmd_buf]

.loop:
    mov al, [rsi]
    mov dl, [rdi]

    cmp al, dl
    jne .no

    test al, al
    jz .yes

    inc rsi
    inc rdi
    jmp .loop

.yes:
    pop rdi
    pop rsi
    mov eax, 1
    ret

.no:
    pop rdi
    pop rsi
    xor eax, eax
    ret

cmd_execute:
    cmp qword [cmd_len], 0
    je .done

    lea rsi, [str_cmd_help]
    call cmd_is
    test eax, eax
    jnz .help

    lea rsi, [str_cmd_clear]
    call cmd_is
    test eax, eax
    jnz .clear

    lea rsi, [str_cmd_mem]
    call cmd_is
    test eax, eax
    jnz .mem

    lea rsi, [str_cmd_vmm]
    call cmd_is
    test eax, eax
    jnz .vmm

    lea rsi, [str_cmd_exit]
    call cmd_is
    test eax, eax
    jnz .exit

    lea r9, [msg_unknown_cmd]
    call draw_text
    ret

.help:
    lea r9, [msg_help]
    call draw_text
    ret

.clear:
    call console_clear

    mov rax, [margin_x]
    mov [video + Video.cx], rax
    mov qword [video + Video.cy], START_Y

    call ensure_y
    ret

.mem:
    lea r9, [str_mem_total]
    call draw_text

    mov rcx, [boot_info + BootInfo.pmm_total_pages]
    call print_hex64

    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_mem_free]
    call draw_text

    mov rcx, [boot_info + BootInfo.pmm_free_pages]
    call print_hex64

    mov r9b, CHAR_LF
    call console_putc
    ret

.vmm:
    cmp byte [vmm_active], 1
    jne .vmm_inactive

    lea r9, [str_vmm_active]
    call draw_text
    ret

.vmm_inactive:
    lea r9, [str_vmm_inactive]
    call draw_text
    ret

.exit:
    jmp exit_boot_services_sequence

.done:
    ret

;================ exit boot services =================

exit_boot_services_sequence:
    call cursor_erase

    lea r9, [msg_exitbs]
    call draw_text

    call exit_boot_services

    lea r9, [msg_exitbs_ok]
    call draw_text

.halt:
    cli
    hlt
    jmp .halt

exit_boot_services:
    push rbx
    push r12
    push r13
    push r14

    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rbx, [bs]
    test rbx, rbx
    jz .err_bs

    mov r13, [rbx + BS_EXIT_BOOT_SERVICES]
    test r13, r13
    jz .err_ptr

    xor r14, r14

.retry:
    call get_memory_map

    mov rcx, [image_handle]
    mov rdx, [boot_info + BootInfo.mem_map_key]

    call r13

    test rax, rax
    jz .success

    inc r14
    cmp r14, 3
    jb .retry

    FAIL_CODE 'X'

.err_bs:
    FAIL_CODE 'Y'

.err_ptr:
    FAIL_CODE 'Z'

.success:
    cli

    mov rsp, r12
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

;================ fail =================

fail:
    mov al, '0'

fail_code:
    cli

    mov dx, 0xE9
    out dx, al

    mov al, 'F'
    out dx, al

.fail_halt:
    hlt
    jmp .fail_halt

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

image_handle:
    dq 0

key_event:
    dq 0

event_array:
    dq 0, 0

event_index:
    dq 0

events_ready:
    db 0

align 8
margin_x:
    dq START_X

timer_event:
    dq 0

timer_ready:
    db 0

cursor_shown:
    db 0

align 4
blink_counter:
    dd 0

vmm_active:
    db 0

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

align 8
boot_info:
istruc BootInfo
    at BootInfo.fb,                dq 0
    at BootInfo.width,             dq 0
    at BootInfo.height,            dq 0
    at BootInfo.stride,            dq 0

    at BootInfo.mem_map,           dq 0
    at BootInfo.mem_size,          dq 0
    at BootInfo.mem_map_key,       dq 0
    at BootInfo.mem_desc_size,     dq 0
    at BootInfo.mem_desc_version,  dq 0

    at BootInfo.pmm_bitmap,        dq 0
    at BootInfo.pmm_total_pages,   dq 0
    at BootInfo.pmm_free_pages,    dq 0
iend

cursor_x:
    dq 0

cursor_y:
    dq 0

msg:
    db "0xDEAD OS",10
    db "Framebuffer Text System",10
    db ">",0

msg_vmm_build:
    db "VMM: building tables...",10,0

msg_vmm_ok:
    db "VMM: tables built",10,0

msg_vmm_activate:
    db "VMM: activating CR3...",10,0

msg_vmm_active:
    db "VMM: CR3 active",10,0

msg_idt_ok:
    db "IDT: installed",10,0

msg_shell_hint:
    db "Type 'help' for commands.",10,0

msg_exitbs:
    db "Exiting Boot Services...",10,0

msg_exitbs_ok:
    db "Boot services exited. System halted.",10,0

prompt_str:
    db ">",0

cmd_buf:
    times CMD_MAX db 0

cmd_len:
    dq 0

str_cmd_help:
    db "help",0

str_cmd_clear:
    db "clear",0

str_cmd_mem:
    db "mem",0

str_cmd_vmm:
    db "vmm",0

str_cmd_exit:
    db "exit",0

msg_help:
    db "Commands:",10
    db "  help  - show this help",10
    db "  clear - clear screen",10
    db "  mem   - memory info",10
    db "  vmm   - vmm status",10
    db "  exit  - exit boot services",10
    db 0

msg_unknown_cmd:
    db "Unknown command. Type 'help'.",10,0

str_mem_total:
    db "PMM total pages: 0x",0

str_mem_free:
    db "PMM free pages : 0x",0

str_vmm_active:
    db "VMM: active",10,0

str_vmm_inactive:
    db "VMM: inactive",10,0

hex_digits:
    db "0123456789ABCDEF"

str_panic_banner:
    db "!!! EXCEPTION !!!",10,0

str_vector:
    db "Vector: 0x",0

str_error:
    db 10,"Error : 0x",0

str_rip:
    db 10,"RIP   : 0x",0

str_halted:
    db 10,"System halted.",0

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

%if ($ - font_table) != 96 * 8
    %error "font_table must contain exactly 96 8-byte glyphs"
%endif

;================ memory variables =================

align 8
mm_tmp_size:          dq 0
mm_tmp_key:           dq 0
mm_tmp_desc_size:     dq 0
mm_tmp_buffer:        dq 0
mm_tmp_desc_version:  dd 0

align 8
pmm_next_word:        dq 0

align 8
pml4_ptr:             dq 0

;================ idt data =================

align 16
idt:
    times 256 * 16 db 0

align 16
new_idtr_limit:
    dw (256 * 16) - 1
new_idtr_base:
    dq 0

old_idtr_limit:
    dw 0
old_idtr_base:
    dq 0

align 4096
pmm_bitmap:
    times PMM_BITMAP_SIZE db 0
