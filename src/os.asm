[BITS 64]
default rel

global _e

%define ST_CONIN_OFFSET        0x30
%define ST_BS                  0x60

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

%define GOP_MODE               24
%define M_INF                  8
%define M_FB                   24

%define I_HRES                 4
%define I_VRES                 8
%define I_SL                   32

%define GLYPH_W                8
%define GLYPH_H                8
%define CHAR_W                 9
%define CHAR_H                 10
%define START_X                100
%define START_Y                100

%define KEY_BACKSPACE          8
%define KEY_ENTER              10
%define KEY_SPACE              32
%define KEY_DELETE             127
%define CHAR_CR                13
%define CHAR_LF                10
%define CHAR_TAB               9

%define EFI_SCAN_DELETE        8

%define EVT_TIMER              0x80000000
%define TIMER_PERIODIC         1

%define CURSOR_BLINK_100NS     5000000
%define CURSOR_BLINK_MS        500
%define CURSOR_COLOR           0x00CCCCCC

%define COM1                   0x3F8

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
%define PMM_ORDER_MAX          11
%define PMM_CACHE_MAX          256

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
%define VMM_1GB_PAGE_SIZE        (1024 * 1024 * 1024)

%define CR4_LA57                 (1 << 12)
%define VMM_MAX_MAP_SIZE         0x1000000000
%define VMM_TEST_VADDR           0xFFFF800000000000

%define VMM_HIGH_BASE 0xFFFF900000000000 
%define VMM_HIGH_MAP_SIZE 0x40000000

%define KHEAP_BASE          0xFFFFA00000000000
%define KHEAP_SIZE          0x200000
%define KHEAP_ORDER         9
%define KHEAP_HEADER_SIZE   16
%define KHEAP_MIN_SPLIT     32

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

_e:
    cld
    and rsp, -16
    sub rsp, 32

    mov [image_handle], rcx
    mov r12, rdx

    call serial_init

    lea rsi, [s_boot_serial]
    call serial_puts

    mov rax, [r12 + ST_CONIN_OFFSET]
    mov [conin], rax

    mov rbx, [r12 + ST_BS]
    test rbx, rbx
    jz fail
    mov [bs], rbx

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

    lea rcx, [guid]
    xor edx, edx
    lea r8, [gop]

    call rax
    add rsp, 32

    test rax, rax
    jnz fail

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

    mov rax, [video + Video.w]
    cmp rax, START_X + CHAR_W
    jae .margin_ok
    mov qword [margin_x], 0
.margin_ok:

    mov rax, [video + Video.fb]
    mov [boot_info + BootInfo.fb], rax

    mov rax, [video + Video.w]
    mov [boot_info + BootInfo.width], rax

    mov rax, [video + Video.h]
    mov [boot_info + BootInfo.height], rax

    mov rax, [video + Video.sl]
    mov [boot_info + BootInfo.stride], rax

    mov qword [video + Video.fg], 0x00FFFFFF
    mov qword [video + Video.bg], 0x00000000

    call console_clear

    mov rax, [margin_x]
    mov [video + Video.cx], rax
    mov qword [video + Video.cy], START_Y

    call ensure_y

    lea r9, [msg]
    call draw_text

    call mem_init
    call detect_memory_top

    lea rsi, [s_mem_init]
    call serial_puts

    call vmm_detect

    cmp byte [vmm_supported], 1
    jne .vmm_skip

    lea r9, [msg_vmm_build]
    call draw_text

    lea rsi, [s_vmm_build]
    call serial_puts

    call vmm_build

    lea r9, [msg_vmm_ok]
    call draw_text

    lea rsi, [s_vmm_ok]
    call serial_puts

    jmp .vmm_ready

.vmm_skip:
    lea r9, [msg_vmm_skip]
    call draw_text

    lea rsi, [s_vmm_skip]
    call serial_puts

.vmm_ready:

    call keyboard_init
    call cursor_draw

    call key_event_init
    call timer_event_init

    cmp byte [vmm_supported], 1
    jne .vmm_no_activate

    lea r9, [msg_vmm_activate]
    call draw_text

    call vmm_activate
    mov byte [vmm_active], 1

    lea r9, [msg_vmm_active]
    call draw_text

    lea rsi, [s_vmm_active]
    call serial_puts

.vmm_no_activate:

    call idt_init_minimal

    lea r9, [msg_idt_ok]
    call draw_text

    lea rsi, [s_idt_ok]
    call serial_puts

    lea r9, [msg_shell_hint]
    call draw_text

    lea r9, [prompt_str]
    call draw_text

    call cursor_draw
    mov dword [blink_counter], 0

    cmp byte [events_ready], 1
    jne .busy_loop

    cmp byte [timer_ready], 1
    je .event_loop

    jmp .busy_loop

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

    mov rcx, r12
    mov rdx, r13
    mov r8d, CHAR_W
    mov r9d, CHAR_H
    call fill_rect_bg

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

fill_rect:
    push rbx
    push rdi
    push r12

    cld

    test r8, r8
    jz .done
    test r9, r9
    jz .done

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

    mov rdi, [video + Video.fb]

    mov rax, [video + Video.sl]
    imul rax, rdx
    add rax, rcx
    shl rax, 2
    add rdi, rax

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

draw_char:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    push rbp

    mov r12, rcx
    mov r13, rdx
    mov r14d, r8d
    movzx ebp, r9b

    cmp ebp, KEY_SPACE
    jb .done

    cmp ebp, KEY_DELETE
    ja .done

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

    shl r15, 2

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

serial_init:
    push rdx
    push rax

    mov dx, COM1 + 1
    xor al, al
    out dx, al

    mov dx, COM1 + 3
    mov al, 0x80
    out dx, al

    mov dx, COM1 + 0
    mov al, 0x01
    out dx, al

    mov dx, COM1 + 1
    xor al, al
    out dx, al

    mov dx, COM1 + 3
    mov al, 0x03
    out dx, al

    mov dx, COM1 + 2
    mov al, 0xC7
    out dx, al

    pop rax
    pop rdx
    ret

serial_putc:
    push rdx
    push rax
    push rcx

    mov dx, COM1 + 5
    mov ecx, 10000

.wait:
    in al, dx
    test al, 0x20
    jnz .ready
    loop .wait
    jmp .done

.ready:
    mov dx, COM1
    mov rax, [rsp + 8]
    out dx, al

.done:
    pop rcx
    pop rax
    pop rdx
    ret

serial_puts:
    push rsi

.next:
    mov al, [rsi]
    test al, al
    jz .done

    call serial_putc

    inc rsi
    jmp .next

.done:
    pop rsi
    ret

vmm_detect:
    mov byte [vmm_supported], 1

    mov rax, cr4
    test eax, CR4_LA57
    jnz .unsupported

    ret

.unsupported:
    mov byte [vmm_supported], 0
    ret

detect_memory_top:
    push rbx
    push r12
    push r13
    push r14

    xor r12, r12

    mov r14, [boot_info + BootInfo.mem_map]
    test r14, r14
    jz .done

    mov r13, [boot_info + BootInfo.mem_size]
    test r13, r13
    jz .done

    mov rbx, [boot_info + BootInfo.mem_desc_size]
    test rbx, rbx
    jz .done

.loop:
    cmp r13, rbx
    jb .done

    mov rax, [r14 + 8]
    mov rcx, [r14 + 24]

    test rcx, rcx
    jz .next

    shl rcx, PAGE_SHIFT
    add rax, rcx
    jc .overflow

    cmp rax, r12
    jbe .next
    mov r12, rax

.next:
    add r14, rbx
    sub r13, rbx
    jmp .loop

.overflow:
    mov r12, -1

.done:
    mov [mem_top_address], r12

    pop r14
    pop r13
    pop r12
    pop rbx
    ret

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

    cmp qword [pmm_cache_count], 0
    je .bitmap_alloc

    dec qword [pmm_cache_count]
    mov rcx, [pmm_cache_count]
    mov rax, [pmm_cache + rcx*8]
    ret

.bitmap_alloc:
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

    cmp qword [pmm_cache_count], PMM_CACHE_MAX
    jae .actual_free

    mov rax, [pmm_cache_count]
    mov [pmm_cache + rax*8], rcx
    inc qword [pmm_cache_count]
    jmp .done

.actual_free:
    btr qword [r10 + r11*8], r8
    inc qword [boot_info + BootInfo.pmm_free_pages]

    cmp r11, [pmm_next_word]
    jae .done
    mov [pmm_next_word], r11

.done:
    ret

pmm_range_free:
    push rbx
    push r10
    push r11
    push r12
    push rcx
    push rdx

    mov r10, [boot_info + BootInfo.pmm_bitmap]
    mov r11, rcx
    mov r12, rdx

    mov eax, 1

    test r12, r12
    jz .done

.check:
    mov rcx, r11
    shr rcx, 6

    mov rdx, r11
    and edx, 63

    bt qword [r10 + rcx*8], rdx
    jc .busy

    inc r11
    dec r12
    jnz .check

.done:
    pop rdx
    pop rcx
    pop r12
    pop r11
    pop r10
    pop rbx
    ret

.busy:
    xor eax, eax
    pop rdx
    pop rcx
    pop r12
    pop r11
    pop r10
    pop rbx
    ret

pmm_set_range:
    push r10
    push r11
    push r12
    push rcx
    push rdx

    mov r10, [boot_info + BootInfo.pmm_bitmap]
    mov r11, rcx
    mov r12, rdx

    test r12, r12
    jz .done

.set:
    mov rcx, r11
    shr rcx, 6

    mov rdx, r11
    and edx, 63

    bts qword [r10 + rcx*8], rdx

    inc r11
    dec r12
    jnz .set

.done:
    pop rdx
    pop rcx
    pop r12
    pop r11
    pop r10
    ret

pmm_alloc_order:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rcx

    cmp r12, PMM_ORDER_MAX
    ja .fail

    test r12, r12
    jnz .order_scan

    call pmm_alloc_page
    jmp .done

.order_scan:
    cmp qword [boot_info + BootInfo.pmm_free_pages], 0
    je .fail

    mov r13, 1
    mov ecx, r12d
    shl r13, cl

    cmp r13, [boot_info + BootInfo.pmm_free_pages]
    ja .fail

    mov r14, [boot_info + BootInfo.pmm_total_pages]

    xor r15, r15

.next_start:
    mov rax, r15
    add rax, r13
    cmp rax, r14
    ja .fail

    mov rcx, r15
    mov rdx, r13
    call pmm_range_free

    test eax, eax
    jnz .found

    add r15, r13
    jmp .next_start

.found:
    mov rcx, r15
    mov rdx, r13
    call pmm_set_range

    sub qword [boot_info + BootInfo.pmm_free_pages], r13

    mov rax, r15
    shl rax, PAGE_SHIFT
    jmp .done

.fail:
    xor eax, eax

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

pmm_free_order:
    push rbx
    push r12
    push r13

    mov r12, rcx
    mov r13, rdx

    test r12, r12
    jz .done

    test r12, 0xFFF
    jnz .done

    cmp r13, PMM_ORDER_MAX
    ja .done

    test r13, r13
    jz .order0

    mov rax, 1
    mov ecx, r13d
    shl rax, cl
    mov rbx, rax

    mov rax, rbx
    shl rax, PAGE_SHIFT
    dec rax
    test r12, rax
    jnz .done

    mov rcx, r12
    shr rcx, PAGE_SHIFT

    mov rax, rcx
    add rax, rbx
    cmp rax, [boot_info + BootInfo.pmm_total_pages]
    ja .done

    mov rdx, rcx
    add rdx, rbx
    call pmm_clear_range

    add qword [boot_info + BootInfo.pmm_free_pages], rbx
    jmp .done

.order0:
    mov rcx, r12
    call pmm_free_page

.done:
    pop r13
    pop r12
    pop rbx
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
    push r15

    mov r12, rcx        ; virtual address
    mov r13, rdx        ; physical address
    mov r15, r8         ; flags

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
    mov rax, r13
    or rax, r15
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
    pop r15
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

    mov rax, [mem_top_address]
    cmp rax, -1
    je .mem_top_ok

    mov r10, VMM_MAX_MAP_SIZE
    cmp rax, r10
    ja .mem_top_ok

    add rax, VMM_2MB_PAGE_SIZE - 1
    and rax, -VMM_2MB_PAGE_SIZE

    cmp rax, r12
    jbe .mem_top_ok
    mov r12, rax

.mem_top_ok:

    xor r13, r13

.map_loop:
    cmp r13, r12
    jae .map_done

    mov rcx, r13
    mov rdx, r13
    mov r8, PAGE_WRITABLE
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

vmm_map_high:
    push rbx
    push r12
    push r13

    cmp byte [vmm_active], 1
    jne .fail

    cmp byte [vmm_high_active], 1
    je .already_ok

    mov r12, VMM_HIGH_BASE
    xor r13, r13

.loop:
    cmp r13, VMM_HIGH_MAP_SIZE
    jae .done

    mov rcx, r12
    add rcx, r13

    mov rdx, r13
    mov r8, PAGE_WRITABLE
    call vmm_map_2mb

    test eax, eax
    jnz .fail

    add r13, VMM_2MB_PAGE_SIZE
    jmp .loop

.done:
    mov byte [vmm_high_active], 1

.already_ok:
    xor eax, eax
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    mov eax, 1
    pop r13
    pop r12
    pop rbx
    ret

vmm_map_4k:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rcx
    mov r13, rdx
    mov r15, r8

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
    jnz .pdpt_table

    call pmm_alloc_page
    test rax, rax
    jz .oom

    mov rcx, rax
    call zero_page

    or rax, PAGE_PRESENT | PAGE_WRITABLE
    mov [rbx + r14 * 8], rax

.pdpt_table:
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
    jnz .pdpt_present

    call pmm_alloc_page
    test rax, rax
    jz .oom

    mov rcx, rax
    call zero_page

    or rax, PAGE_PRESENT | PAGE_WRITABLE
    mov [rbx + r14 * 8], rax
    jmp .pd_table

.pdpt_present:
    test al, PAGE_SIZE_FLAG
    jnz .conflict

.pd_table:
    mov rax, [rbx + r14 * 8]
    MASK_FRAME rax
    mov rbx, rax

    ; PD -> PT
    mov rax, r12
    shr rax, 21
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov rax, [rbx + r14 * 8]
    test al, PAGE_PRESENT
    jnz .pd_present

    call pmm_alloc_page
    test rax, rax
    jz .oom

    mov rcx, rax
    call zero_page

    or rax, PAGE_PRESENT | PAGE_WRITABLE
    mov [rbx + r14 * 8], rax
    jmp .pt_table

.pd_present:
    test al, PAGE_SIZE_FLAG
    jz .pt_table

    ;================ split 2MB page =================

    push rax

    call pmm_alloc_page
    test rax, rax
    jz .split_oom

    mov r11, rax
    mov rcx, rax
    call zero_page

    pop r9

    ; r9 = original 2MB PDE

    mov r8, PAGE_PRESENT

    test r9b, PAGE_WRITABLE
    jz .split_no_w
    or r8, PAGE_WRITABLE

.split_no_w:
    test r9b, PAGE_USER
    jz .split_no_u
    or r8, PAGE_USER

.split_no_u:

    ; physical base of original 2MB page
    mov rax, r9
    shl rax, 12
    shr rax, 12
    and rax, -VMM_2MB_PAGE_SIZE
    mov r10, rax

    ; fill 512 x 4KB entries
    xor ecx, ecx

.split_fill:
    mov rax, r10
    mov rdx, rcx
    shl rdx, PAGE_SHIFT
    add rax, rdx
    or rax, r8
    mov [r11 + rcx*8], rax

    inc ecx
    cmp ecx, 512
    jb .split_fill

    ; replace 2MB PDE with PT pointer
    mov rax, r11
    or rax, PAGE_PRESENT | PAGE_WRITABLE

    test r9b, PAGE_USER
    jz .split_pde_no_u
    or rax, PAGE_USER

.split_pde_no_u:
    mov [rbx + r14 * 8], rax

    invlpg [r12]

    mov rbx, r11
    jmp .pt_map

.split_oom:
    pop rax
    jmp .oom

.pt_table:
    mov rax, [rbx + r14 * 8]
    MASK_FRAME rax
    mov rbx, rax

.pt_map:
    mov rax, r12
    shr rax, 12
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov rax, r13
    or rax, r15
    or rax, PAGE_PRESENT
    mov [rbx + r14 * 8], rax

    invlpg [r12]

    xor eax, eax
    jmp .done

.conflict:
    mov eax, 1
    jmp .done

.oom:
    mov eax, 2

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

vmm_unmap_4k:
    push rbx
    push r12
    push r14

    mov r12, rcx

    mov rbx, [pml4_ptr]
    test rbx, rbx
    jz .done

    mov rax, r12
    shr rax, 39
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov rax, [rbx + r14 * 8]
    test al, PAGE_PRESENT
    jz .done

    MASK_FRAME rax
    mov rbx, rax

    mov rax, r12
    shr rax, 30
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov rax, [rbx + r14 * 8]
    test al, PAGE_PRESENT
    jz .done

    test al, PAGE_SIZE_FLAG
    jnz .done

    MASK_FRAME rax
    mov rbx, rax

    mov rax, r12
    shr rax, 21
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov rax, [rbx + r14 * 8]
    test al, PAGE_PRESENT
    jz .done

    test al, PAGE_SIZE_FLAG
    jnz .done

    MASK_FRAME rax
    mov rbx, rax

    mov rax, r12
    shr rax, 12
    and eax, PT_INDEX_BITS
    mov r14, rax

    mov qword [rbx + r14 * 8], 0
    invlpg [r12]

.done:
    pop r14
    pop r12
    pop rbx
    ret

vmm_translate:
    push rbx
    push r10
    push r11

    mov r11, rcx

    mov rbx, [pml4_ptr]
    test rbx, rbx
    jz .fail

    mov rax, r11
    shr rax, 39
    and eax, PT_INDEX_BITS
    mov rdx, rax

    mov rax, [rbx + rdx * 8]
    test al, PAGE_PRESENT
    jz .fail

    MASK_FRAME rax
    mov rbx, rax

    mov rax, r11
    shr rax, 30
    and eax, PT_INDEX_BITS
    mov rdx, rax

    mov rax, [rbx + rdx * 8]
    test al, PAGE_PRESENT
    jz .fail

    test al, PAGE_SIZE_FLAG
    jnz .pdpt_huge

    MASK_FRAME rax
    mov rbx, rax

    mov rax, r11
    shr rax, 21
    and eax, PT_INDEX_BITS
    mov rdx, rax

    mov rax, [rbx + rdx * 8]
    test al, PAGE_PRESENT
    jz .fail

    test al, PAGE_SIZE_FLAG
    jnz .pd_huge

    MASK_FRAME rax
    mov rbx, rax

    mov rax, r11
    shr rax, 12
    and eax, PT_INDEX_BITS
    mov rdx, rax

    mov rax, [rbx + rdx * 8]
    test al, PAGE_PRESENT
    jz .fail

    MASK_FRAME rax

    mov rdx, r11
    and edx, 0xFFF
    add rax, rdx

    jmp .done

.pd_huge:
    shl rax, 12
    shr rax, 12
    and rax, -VMM_2MB_PAGE_SIZE

    mov rdx, r11
    mov r10, VMM_2MB_PAGE_SIZE - 1
    and rdx, r10
    add rax, rdx

    jmp .done

.pdpt_huge:
    shl rax, 12
    shr rax, 12
    and rax, -VMM_1GB_PAGE_SIZE

    mov rdx, r11
    mov r10, VMM_1GB_PAGE_SIZE - 1
    and rdx, r10
    add rax, rdx

.done:
    pop r11
    pop r10
    pop rbx
    ret

.fail:
    xor eax, eax
    pop r11
    pop r10
    pop rbx
    ret

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

kheap_init:
    push rbx
    push r12
    push r13

    cmp byte [kheap_active], 1
    je .ok

    mov rcx, KHEAP_ORDER
    call pmm_alloc_order
    test rax, rax
    jz .fail

    mov r12, rax

    mov rcx, KHEAP_BASE
    mov rdx, r12
    mov r8, PAGE_WRITABLE
    call vmm_map_2mb
    test eax, eax
    jnz .fail_free

    mov rax, KHEAP_BASE
    mov qword [rax], KHEAP_SIZE
    mov qword [rax + 8], 0

    mov [kheap_free_head], rax
    mov [kheap_phys], r12
    mov byte [kheap_active], 1

.ok:
    xor eax, eax
    pop r13
    pop r12
    pop rbx
    ret

.fail_free:
    mov rcx, r12
    mov rdx, KHEAP_ORDER
    call pmm_free_order

.fail:
    mov eax, 1
    pop r13
    pop r12
    pop rbx
    ret

kmalloc:
    push rbx
    push r12
    push r13
    push r14
    push r15

    cmp byte [kheap_active], 1
    jne .fail

    mov r12, rcx
    test r12, r12
    jz .fail

    add r12, 15
    and r12, -16
    add r12, KHEAP_HEADER_SIZE

    mov r13, [kheap_free_head]
    xor r14, r14

.search:
    test r13, r13
    jz .fail

    mov rax, [r13]
    cmp rax, r12
    jae .found

    mov r14, r13
    mov r13, [r13 + 8]
    jmp .search

.found:
    mov rcx, rax
    sub rcx, r12
    cmp rcx, KHEAP_MIN_SPLIT
    jb .use_whole

    lea r15, [r13 + r12]

    mov [r15], rcx
    mov rax, [r13 + 8]
    mov [r15 + 8], rax

    test r14, r14
    jz .split_head

    mov [r14 + 8], r15
    jmp .split_done

.split_head:
    mov [kheap_free_head], r15

.split_done:
    mov [r13], r12
    mov qword [r13 + 8], 0

    lea rax, [r13 + KHEAP_HEADER_SIZE]
    jmp .done

.use_whole:
    test r14, r14
    jz .whole_head

    mov rax, [r13 + 8]
    mov [r14 + 8], rax
    jmp .whole_done

.whole_head:
    mov rax, [r13 + 8]
    mov [kheap_free_head], rax

.whole_done:
    mov qword [r13 + 8], 0

    lea rax, [r13 + KHEAP_HEADER_SIZE]

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    xor eax, eax
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
    
kfree:
    push rbx
    push r12
    push r13
    push r14
    push r15

    cmp byte [kheap_active], 1
    jne .done

    test rcx, rcx
    jz .done

    lea r12, [rcx - KHEAP_HEADER_SIZE]

    mov rax, KHEAP_BASE
    cmp r12, rax
    jb .done

    add rax, KHEAP_SIZE
    cmp r12, rax
    jae .done

    mov r13, [kheap_free_head]
    xor r14, r14

.find:
    test r13, r13
    jz .insert

    cmp r12, r13
    jb .insert

    mov r14, r13
    mov r13, [r13 + 8]
    jmp .find

.insert:
    mov [r12 + 8], r13

    test r14, r14
    jz .set_head

    mov [r14 + 8], r12
    jmp .coalesce

.set_head:
    mov [kheap_free_head], r12

.coalesce:
    test r13, r13
    jz .coalesce_prev

    mov rax, [r12]
    lea rdx, [r12 + rax]
    cmp rdx, r13
    jne .coalesce_prev

    mov rdx, [r13]
    add [r12], rdx

    mov rax, [r13 + 8]
    mov [r12 + 8], rax

.coalesce_prev:
    test r14, r14
    jz .done

    mov rax, [r14]
    lea rdx, [r14 + rax]
    cmp rdx, r12
    jne .done

    mov rdx, [r12]
    add [r14], rdx

    mov rax, [r12 + 8]
    mov [r14 + 8], rax

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
    
heap_test:
    push r12
    push r13
    push r14

    call kheap_init
    test eax, eax
    jnz .fail

    mov rcx, 64
    call kmalloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 256
    call kmalloc
    test rax, rax
    jz .fail
    mov r13, rax

    mov rcx, 128
    call kmalloc
    test rax, rax
    jz .fail
    mov r14, rax

    mov qword [r12], 0x1111
    mov qword [r13], 0x2222
    mov qword [r14], 0x3333

    mov rcx, r12
    call kfree

    mov rcx, r14
    call kfree

    mov rcx, r13
    call kfree

    mov rcx, 512
    call kmalloc
    test rax, rax
    jz .fail

    mov rcx, rax
    call kfree

    pop r14
    pop r13
    pop r12

    lea r9, [msg_heaptest_ok]
    call draw_text
    ret

.fail:
    pop r14
    pop r13
    pop r12

    lea r9, [msg_heaptest_fail]
    call draw_text
    ret    

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

    mov r15, rcx
    mov r14, rdx
    mov r13, r8

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

    lea rsi, [str_cmd_detect]
    call cmd_is
    test eax, eax
    jnz .detect

    lea rsi, [str_cmd_serial]
    call cmd_is
    test eax, eax
    jnz .serial

    lea rsi, [str_cmd_pmmtest]
    call cmd_is
    test eax, eax
    jnz .pmmtest

    lea rsi, [str_cmd_vmmtest]
    call cmd_is
    test eax, eax
    jnz .vmmtest

    lea rsi, [str_cmd_highmap]
    call cmd_is
    test eax, eax
    jnz .highmap

    lea rsi, [str_cmd_heap]
    call cmd_is
    test eax, eax
    jnz .heap

    lea rsi, [str_cmd_heaptest]
    call cmd_is
    test eax, eax
    jnz .heaptest

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

    lea r9, [str_pmm_cache]
    call draw_text

    mov rcx, [pmm_cache_count]
    call print_hex64

    mov r9b, CHAR_LF
    call console_putc
    ret

.vmm:
    cmp byte [vmm_active], 1
    je .vmm_active_msg

    cmp byte [vmm_supported], 1
    je .vmm_inactive_msg

    lea r9, [str_vmm_skipped]
    call draw_text
    ret

.vmm_active_msg:
    lea r9, [str_vmm_active]
    call draw_text
    ret

.vmm_inactive_msg:
    lea r9, [str_vmm_inactive]
    call draw_text
    ret

.detect:
    lea r9, [msg_detect_header]
    call draw_text

    lea r9, [str_paging]
    call draw_text

    cmp byte [vmm_supported], 1
    jne .paging_unsupported

    lea r9, [str_paging_4]
    jmp .paging_print

.paging_unsupported:
    lea r9, [str_paging_5]

.paging_print:
    call draw_text

    lea r9, [str_mem_top]
    call draw_text
    mov rcx, [mem_top_address]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_fb_width]
    call draw_text
    mov rcx, [video + Video.w]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_fb_height]
    call draw_text
    mov rcx, [video + Video.h]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_fb_stride]
    call draw_text
    mov rcx, [video + Video.sl]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc

    cmp byte [vmm_active], 1
    je .vmm_status_active

    cmp byte [vmm_supported], 1
    je .vmm_status_inactive

    lea r9, [str_vmm_skipped]
    call draw_text
    ret

.vmm_status_active:
    lea r9, [str_vmm_active]
    call draw_text
    ret

.vmm_status_inactive:
    lea r9, [str_vmm_inactive]
    call draw_text
    ret

.serial:
    lea rsi, [serial_test_msg]
    call serial_puts

    lea r9, [msg_serial_sent]
    call draw_text
    ret

.pmmtest:
    push r12

    call pmm_alloc_page
    test rax, rax
    jz .pmmtest_fail

    mov rcx, rax
    call pmm_free_page

    mov rcx, 2
    call pmm_alloc_order
    test rax, rax
    jz .pmmtest_fail

    mov r12, rax

    mov rcx, r12
    mov rdx, 2
    call pmm_free_order

    pop r12

    lea r9, [msg_pmmtest_ok]
    call draw_text
    ret

.pmmtest_fail:
    pop r12

    lea r9, [msg_pmmtest_fail]
    call draw_text
    ret

.vmmtest:
    cmp byte [vmm_active], 1
    jne .vmmtest_inactive

    push r12

    mov rcx, 0x1000
    call vmm_translate
    test rax, rax
    jz .vmmtest_fail_pop

    call pmm_alloc_page
    test rax, rax
    jz .vmmtest_fail_pop

    mov r12, rax

    mov rcx, rax
    call zero_page

    mov rcx, VMM_TEST_VADDR
    mov rdx, r12
    mov r8, PAGE_WRITABLE
    call vmm_map_4k
    test eax, eax
    jnz .vmmtest_free_fail

    mov rax, VMM_TEST_VADDR
    mov qword [rax], 0xDEAD
    cmp qword [rax], 0xDEAD
    jne .vmmtest_cleanup_fail

    mov rcx, VMM_TEST_VADDR
    call vmm_unmap_4k

    mov rcx, r12
    call pmm_free_page

    pop r12

    lea r9, [msg_vmmtest_ok]
    call draw_text
    ret

.vmmtest_cleanup_fail:
    mov rcx, VMM_TEST_VADDR
    call vmm_unmap_4k

.vmmtest_free_fail:
    mov rcx, r12
    call pmm_free_page

.vmmtest_fail_pop:
    pop r12

    lea r9, [msg_vmmtest_fail]
    call draw_text
    ret

.vmmtest_inactive:
    lea r9, [msg_vmmtest_inactive]
    call draw_text
    ret

.highmap:
    call vmm_map_high
    test eax, eax
    jnz .highmap_fail

    mov rcx, VMM_HIGH_BASE
    add rcx, 0x1000
    call vmm_translate

    mov rdx, 0x1000
    cmp rax, rdx
    jne .highmap_fail

    lea r9, [msg_highmap_ok]
    call draw_text
    ret

.highmap_fail:
    lea r9, [msg_highmap_fail]
    call draw_text
    ret

.heap:
    call kheap_init
    test eax, eax
    jnz .heap_fail

    lea r9, [str_heap_base]
    call draw_text

    mov rcx, KHEAP_BASE
    call print_hex64

    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_heap_size]
    call draw_text

    mov rcx, KHEAP_SIZE
    call print_hex64

    mov r9b, CHAR_LF
    call console_putc
    ret

.heap_fail:
    lea r9, [msg_heap_fail]
    call draw_text
    ret

.heaptest:
    call heap_test
    ret

.exit:
    jmp exit_boot_services_sequence

.done:
    ret

exit_boot_services_sequence:
    call cursor_erase

    lea r9, [msg_exitbs]
    call draw_text

    lea rsi, [s_exitbs]
    call serial_puts

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

fail:
    mov al, '0'

fail_code:
    cli

    mov bl, al

    mov al, 'F'
    call serial_putc

    mov al, bl
    call serial_putc

    mov dx, 0xE9
    mov al, bl
    out dx, al

    mov al, 'F'
    out dx, al

.fail_halt:
    hlt
    jmp .fail_halt

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

vmm_supported:
    db 1

mem_top_address:
    dq 0

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

msg_vmm_skip:
    db "VMM: skipped (unsupported paging mode)",10,0

msg_idt_ok:
    db "IDT: installed",10,0

msg_shell_hint:
    db "Type 'help' for commands.",10,0

msg_exitbs:
    db "Exiting Boot Services...",10,0

msg_exitbs_ok:
    db "Boot services exited. System halted.",10,0

msg_serial_sent:
    db "Serial: test message sent.",10,0

msg_detect_header:
    db "Detection:",10,0

msg_pmmtest_ok:
    db "PMM test: OK",10,0

msg_pmmtest_fail:
    db "PMM test: FAIL",10,0

msg_vmmtest_ok:
    db "VMM test: OK",10,0

msg_vmmtest_fail:
    db "VMM test: FAIL",10,0

msg_vmmtest_inactive:
    db "VMM test: inactive",10,0

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

str_cmd_detect:
    db "detect",0

str_cmd_serial:
    db "serial",0

str_cmd_pmmtest:
    db "pmmtest",0

str_cmd_vmmtest:
    db "vmmtest",0

str_cmd_exit:
    db "exit",0

msg_help:
    db "Commands:",10
    db "  help     - show this help",10
    db "  clear    - clear screen",10
    db "  mem      - memory info",10
    db "  vmm      - vmm status",10
    db "  detect   - system info",10
    db "  serial   - serial test",10
    db "  pmmtest  - test PMM allocator",10
    db "  vmmtest  - test VMM mapping",10
    db "  highmap  - map physical memory to higher-half",10
    db "  heap     - initialize/show kernel heap",10
    db "  heaptest - test kernel heap",10
    db "  exit     - exit boot services",10
    db 0

msg_unknown_cmd:
    db "Unknown command. Type 'help'.",10,0

str_mem_total:
    db "PMM total pages: 0x",0

str_mem_free:
    db "PMM free pages : 0x",0

str_pmm_cache:
    db "PMM cache pages : 0x",0

str_vmm_active:
    db "VMM: active",10,0

str_vmm_inactive:
    db "VMM: inactive",10,0

str_vmm_skipped:
    db "VMM: skipped",10,0

str_paging:
    db "Paging  : ",0

str_paging_4:
    db "4-level",10,0

str_paging_5:
    db "5-level (unsupported)",10,0

str_mem_top:
    db "Mem top : 0x",0

str_fb_width:
    db "FB width: 0x",0

str_fb_height:
    db "FB height: 0x",0

str_fb_stride:
    db "FB stride: 0x",0

serial_test_msg:
    db "0xDEAD OS: serial test",13,10,0

s_boot_serial:
    db "0xDEAD OS: serial online",13,10,0

s_mem_init:
    db "PMM: initialized",13,10,0

s_vmm_build:
    db "VMM: building",13,10,0

s_vmm_ok:
    db "VMM: built",13,10,0

s_vmm_skip:
    db "VMM: skipped",13,10,0

s_vmm_active:
    db "VMM: active",13,10,0

s_idt_ok:
    db "IDT: installed",13,10,0

s_exitbs:
    db "Exiting Boot Services",13,10,0

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
    
vmm_high_active:
    db 0

str_cmd_highmap:
    db "highmap",0

msg_highmap_ok:
    db "High map: OK",10,0

msg_highmap_fail:
    db "High map: FAIL",10,0
kheap_active:
    db 0

kheap_phys:
    dq 0

kheap_free_head:
    dq 0

str_cmd_heap:
    db "heap",0

str_cmd_heaptest:
    db "heaptest",0

msg_heap_ok:
    db "Heap: OK",10,0

msg_heap_fail:
    db "Heap: FAIL",10,0

msg_heaptest_ok:
    db "Heap test: OK",10,0

msg_heaptest_fail:
    db "Heap test: FAIL",10,0

str_heap_base:
    db "Heap base: 0x",0

str_heap_size:
    db "Heap size: 0x",0
    
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

align 8
mm_tmp_size:          dq 0
mm_tmp_key:           dq 0
mm_tmp_desc_size:     dq 0
mm_tmp_buffer:        dq 0
mm_tmp_desc_version:  dd 0

align 8
pmm_next_word:        dq 0

align 8
pmm_cache_count:      dq 0

pmm_cache:
    times PMM_CACHE_MAX dq 0

align 8
pml4_ptr:             dq 0

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
