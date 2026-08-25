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

;================ LOCAL APIC / TIMER =================
%define MSR_APIC_BASE          0x1B
%define APIC_BASE_ENABLE       (1 << 11)
%define APIC_BASE_X2APIC       (1 << 10)
%define APIC_BASE_MASK         0xFFFFF000

%define LAPIC_ID                0x020
%define LAPIC_TPR               0x080
%define LAPIC_EOI               0x0B0
%define LAPIC_SVR               0x0F0
%define LAPIC_ESR               0x280
%define LAPIC_LVT_TIMER         0x320
%define LAPIC_TIMER_INIT        0x380
%define LAPIC_TIMER_CUR         0x390
%define LAPIC_TIMER_DIV         0x3E0

%define LAPIC_TIMER_VECTOR      32
%define LAPIC_SVR_ENABLE        (1 << 8)
%define LAPIC_LVT_MASKED        (1 << 16)
%define LAPIC_LVT_PERIODIC      (1 << 17)
%define LAPIC_TIMER_DIV_16      0x3

%define LAPIC_VIRT_BASE          0xFFFF920000000000
%define LAPIC_CALIBRATION_MS     50
%define PIT_INPUT_HZ             1193182
%define PIT_CALIBRATION_DIV     59659
%define APIC_TIMER_HZ_DEFAULT   1000
%define APIC_TIMER_PERIOD_MS     1

%define PAGE_SHIFT             12
%define PAGE_SIZE              4096

%define EFI_SUCCESS            0
%define EFI_BUFFER_TOO_SMALL   0x8000000000000005

%define EFI_LOADER_DATA        2

%define MEM_TYPE_BS_CODE       3
%define MEM_TYPE_BS_DATA       4
%define MEM_TYPE_CONVENTIONAL  7

%define PMM_MAX_PAGES          0x400000
%define PMM_BITMAP_SIZE        (PMM_MAX_PAGES / 8)
%define PMM_ORDER_MAX          11
%define PMM_CACHE_MAX          256

%define MM_REGION_MAX          64
%define MM_REGION_FREE         0
%define MM_REGION_RESERVED     1
%define MM_REGION_KERNEL       2
%define MM_REGION_FRAMEBUFFER  3
%define MM_REGION_PAGETABLE    4
%define MM_REGION_PMM          5
%define MM_REGION_RUNTIME      6

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
%define KMEM_FLAG_ZERO 1

%define MM_FLAG_ZERO   1
%define MM_FLAG_DMA    2
%define MM_FLAG_DMA32  4

%define PMM_ORDER_CACHE_MAX 16
%define BUDDY_ARENA_ORDER_MAX 9
%define BUDDY_ARENA_ORDER_MIN 2

%define BUDDY_STATIC_ORDER 7
%define BUDDY_STATIC_BLOCK_SIZE (1 << (PAGE_SHIFT + BUDDY_STATIC_ORDER))
%define BUDDY_PMM_ORDER 9
%define BUDDY_PMM_BLOCK_SIZE (1 << (PAGE_SHIFT + BUDDY_PMM_ORDER))
%define ZONE_DMA_LIMIT    0x1000000      ; 16 MiB
%define ZONE_DMA32_LIMIT  0x100000000    ; 4 GiB
%define SLAB_CACHE_COUNT 8
%define SLAB_TEST_COUNT 300
%define MEM_TYPE_LOADER_CODE 1
%define MEM_TYPE_LOADER_DATA 2

%define PHYS_MAP_BASE          0xFFFF910000000000
%define HH_DIRECT_MAP_LIMIT    0x1000000000  ; 64 GiB maximum HHDM RAM window
%define HH_MAP_FLAGS           (PAGE_WRITABLE | PAGE_GLOBAL)

%macro MASK_FRAME 1
    shl %1, 12
    shr %1, 12
    and %1, -4096
%endmacro

%define CMD_MAX 64

;================ CONTEXT SWITCH / THREAD FOUNDATION =================
%define CTX_RSP      0
%define CTX_RBX      8
%define CTX_RBP      16
%define CTX_R12      24
%define CTX_R13      32
%define CTX_R14      40
%define CTX_R15      48
%define CTX_RFLAGS   56
%define CTX_SIZE     64
%define THREAD_STACK_SIZE 4096
%define THREAD_STATE_FREE     0
%define THREAD_STATE_READY    1
%define THREAD_STATE_RUNNING  2
%define THREAD_STATE_DEAD     3
%define THREAD_STATE_BLOCKED  4
%define THREAD_FLAG_STATIC   (1 << 0)
%define THREAD_MAGIC          0x5448524454485244
%define THREAD_CANARY         0xC0FFEEDEADBEEF42
%define TH_ID                 0
%define TH_STATE              8
%define TH_FLAGS              16
%define TH_STACK_BASE         24
%define TH_STACK_TOP          32
%define TH_ENTRY              40
%define TH_ARG                48
%define TH_CTX                56
%define TH_CANARY             120
%define TH_MAGIC              128
%define TH_NEXT               144
%define TH_PREV               152
%define TH_ALL_NEXT           160
%define TH_ALL_PREV           168
%define TH_SIZE               176
%define SCHED_MAX_TEST_THREADS 3
%define SCHED_TEST_ROUNDS 3
%define PMM_STRESS_COUNT 32
%define VMM_STRESS_COUNT 16
%define VMM_STRESS_BASE 0xFFFFB00000000000

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

    .mem_map_copy:      resq 1
    .mem_map_copy_size: resq 1

    .pmm_bitmap:        resq 1
    .pmm_total_pages:   resq 1
    .pmm_free_pages:    resq 1
endstruc

struc MemRegion
    .start: resq 1
    .end:   resq 1
    .type:  resq 1
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

    mov rdx, r12
    call boot_prepare
    test eax, eax
    jnz .boot_prepare_fail

    ; UEFI HAL has completed its firmware-side initialization.
    mov byte [hal_uefi_ready], 1

    call console_clear

    mov rax, [margin_x]
    mov [video + Video.cx], rax
    mov qword [video + Video.cy], START_Y

    call ensure_y

    lea r9, [msg]
    call draw_text

    call mem_init
    call detect_memory_top

    ; Unified memory layer is now backed by the firmware memory map.
    cmp qword [boot_info + BootInfo.pmm_bitmap], 0
    je .memory_manager_not_ready
    cmp qword [boot_info + BootInfo.pmm_total_pages], 0
    je .memory_manager_not_ready
    mov byte [memory_manager_ready], 1
.memory_manager_not_ready:

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

    call idt_init_minimal

    jmp .after_idt

.vmm_no_activate:

    call idt_init_minimal

.after_idt:

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

.boot_prepare_fail:
    mov al, 'B'
    jmp fail_code

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

    ; Clearing the framebuffer must also reset the console cursor.
    ; Otherwise the kernel banner starts where the bootloader left off.
    mov rax, [margin_x]
    mov [video + Video.cx], rax
    mov qword [video + Video.cy], START_Y

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

;================ DRAW_TEXT =================

draw_text:
    push r12
    sub rsp, 8

    mov r12, r9

.next:
    mov al, [r12]
    test al, al
    jz .done

    mov r9b, al
    call console_putc

    inc r12
    jmp .next

.done:
    add rsp, 8
    pop r12
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

; Cursor overlay: XOR the cursor into the framebuffer.
; Drawing and erasing use the exact same XOR operation, so erasing
; restores every pixel exactly without saving/restoring framebuffer data.
; This avoids corrupting characters when the cursor blinks.
cursor_xor_rect:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    cld

    mov r12, rcx                 ; x
    mov r13, rdx                 ; y
    mov r14, r8                  ; width
    mov r15, r9                  ; height

    mov rax, [video + Video.fb]
    mov rdx, [video + Video.sl]
    imul rdx, r13
    add rdx, r12
    shl rdx, 2
    add rax, rdx
    mov rdi, rax                 ; framebuffer pointer

    mov ebx, CURSOR_COLOR

.y_loop:
    test r15, r15
    jz .done

    mov rsi, r14
.x_loop:
    test rsi, rsi
    jz .next_row

    xor dword [rdi], ebx
    add rdi, 4
    dec rsi
    jmp .x_loop

.next_row:
    mov rax, [video + Video.sl]
    sub rax, r14
    shl rax, 2
    add rdi, rax
    dec r15
    jmp .y_loop

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

cursor_draw:
    cmp byte [cursor_shown], 1
    je .done

    push r12
    push r13
    sub rsp, 8

    mov rax, [video + Video.cx]
    mov [cursor_x], rax
    mov r12, rax

    mov rax, [video + Video.cy]
    mov [cursor_y], rax
    mov r13, rax

    mov rcx, r12
    mov rdx, r13
    mov r8, CHAR_W
    mov r9, CHAR_H
    call cursor_xor_rect

    mov byte [cursor_shown], 1

    add rsp, 8
    pop r13
    pop r12
.done:
    ret

cursor_erase:
    cmp byte [cursor_shown], 0
    je .done

    push r12
    push r13
    sub rsp, 8

    mov r12, [cursor_x]
    mov r13, [cursor_y]

    mov rcx, r12
    mov rdx, r13
    mov r8, CHAR_W
    mov r9, CHAR_H
    call cursor_xor_rect

    mov byte [cursor_shown], 0

    add rsp, 8
    pop r13
    pop r12
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
    jmp input_poll

keyboard_poll:
    jmp input_poll

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
    sub rsp, 8

    mov byte [timer_ready], 0

    lea rcx, [timer_event]
    call boot_create_timer_event
    test eax, eax
    jnz .fail

    mov rcx, [timer_event]
    mov edx, TIMER_PERIODIC
    mov r8, CURSOR_BLINK_100NS
    call boot_set_timer
    test eax, eax
    jnz .fail

    mov rax, [timer_event]
    mov [event_array + 8], rax
    mov byte [timer_ready], 1

.fail:
    add rsp, 8
    ret
    
wait_event:
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    cmp byte [events_ready], 1
    jne .error

    lea rdx, [event_array]
    lea r8, [event_index]

    cmp byte [timer_ready], 1
    jne .one_event

    mov rcx, 2
    call boot_wait_events
    test eax, eax
    jnz .error

    mov rax, [event_index]

    cmp rax, 1
    je .timer

    test rax, rax
    jz .key

    jmp .error

.one_event:
    mov rcx, 1
    call boot_wait_events
    test eax, eax
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
    sub rsp, 8

    cmp byte [timer_ready], 1
    jne .done

    mov rcx, [timer_event]
    xor edx, edx
    xor r8d, r8d
    call boot_set_timer

    mov rcx, [timer_event]
    mov edx, TIMER_PERIODIC
    mov r8, CURSOR_BLINK_100NS
    call boot_set_timer

.done:
    add rsp, 8
    ret

stall_1ms:
    mov rcx, 1000
    jmp boot_stall

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

;================ EARLY KERNEL DEBUG =================
; Uses QEMU/ISA debug port 0xE9. This path does not depend on framebuffer,
; UEFI console services, IDT, or the kernel heap.
debug_stage:
    push rdx
    mov dx, 0x00E9
    out dx, al
    pop rdx
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

    call boot_get_memory_map

.have_map:
    call pmm_init

    call copy_memory_map

    call pmm_reserve_boot

    ret

get_memory_map:
    jmp boot_get_memory_map

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

pmm_range_used:
    push rbx
    push r10
    push r11
    push r12
    push rcx
    push rdx

    mov r10, [boot_info + BootInfo.pmm_bitmap]
    test r10, r10
    jz .fail

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
    jnc .fail

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

.fail:
    xor eax, eax
    pop rdx
    pop rcx
    pop r12
    pop r11
    pop r10
    pop rbx
    ret

pmm_order_cache_push:
    xor eax, eax

    cmp rcx, PMM_ORDER_MAX
    ja .ret

    test rcx, rcx
    jz .ret

    mov r8, [pmm_order_counts + rcx*8]

    xor r9, r9

.dup_loop:
    cmp r9, r8
    jae .dup_done

    mov r10, rcx
    imul r10, PMM_ORDER_CACHE_MAX
    add r10, r9

    mov r11, [pmm_order_cache + r10*8]
    cmp r11, rdx
    je .duplicate

    inc r9
    jmp .dup_loop

.duplicate:
    mov eax, 2
    jmp .ret

.dup_done:
    cmp r8, PMM_ORDER_CACHE_MAX
    jae .ret

    mov r10, rcx
    imul r10, PMM_ORDER_CACHE_MAX
    add r10, r8

    mov [pmm_order_cache + r10*8], rdx

    inc qword [pmm_order_counts + rcx*8]

    mov eax, 1

.ret:
    ret

pmm_order_cache_pop:
    xor eax, eax

    cmp rcx, PMM_ORDER_MAX
    ja .done

    test rcx, rcx
    jz .done

    mov rdx, [pmm_order_counts + rcx*8]
    test rdx, rdx
    jz .done

    dec rdx
    mov [pmm_order_counts + rcx*8], rdx

    mov rax, rcx
    imul rax, PMM_ORDER_CACHE_MAX
    add rax, rdx

    mov rax, [pmm_order_cache + rax*8]

.done:
    ret

;================ PMM_ALLOC_ORDER =================

pmm_alloc_order:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, rcx

    cmp r12, PMM_ORDER_MAX
    ja .fail

    test r12, r12
    jnz .order_cache_try

    call pmm_alloc_page
    jmp .done

.order_cache_try:
    mov rcx, r12
    call pmm_order_cache_pop

    test rax, rax
    jnz .done

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
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

;================ PMM_FREE_ORDER =================

pmm_free_order:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

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
    mov r14, rax

    mov rax, r14
    shl rax, PAGE_SHIFT
    dec rax
    test r12, rax
    jnz .done

    mov r15, r12
    shr r15, PAGE_SHIFT

    mov rax, r15
    add rax, r14
    cmp rax, [boot_info + BootInfo.pmm_total_pages]
    ja .done

    mov rcx, r15
    mov rdx, r14
    call pmm_range_used
    test eax, eax
    jz .done

    mov rcx, r13
    mov rdx, r12
    call pmm_order_cache_push

    test eax, eax
    jnz .done

    mov rcx, r15
    mov rdx, r15
    add rdx, r14
    call pmm_clear_range

    add qword [boot_info + BootInfo.pmm_free_pages], r14

    mov rax, r15
    shr rax, 6
    cmp rax, [pmm_next_word]
    jae .done
    mov [pmm_next_word], rax

.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.order0:
    mov rcx, r12
    call pmm_free_page
    jmp .done

;================ MM_REGION =================

mm_region_add:
    push r12
    push r13

    mov r12, [mm_region_count]
    cmp r12, MM_REGION_MAX
    jae .done

    mov r13, MM_REGION_MAX
    cmp r12, r13
    jae .done

    imul r12, 24

    mov [mm_regions + r12 + MemRegion.start], rcx
    mov [mm_regions + r12 + MemRegion.end], rdx
    mov qword [mm_regions + r12 + MemRegion.type], r8

    inc qword [mm_region_count]

.done:
    pop r13
    pop r12
    ret

mm_region_reserve_range:
    push rbx
    push r10
    push r12
    push r13
    push r14
    push r15

    mov r12, rcx
    mov r13, rdx

    shr r12, PAGE_SHIFT
    shr r13, PAGE_SHIFT

    add r13, 1

    mov r10, [boot_info + BootInfo.pmm_bitmap]
    test r10, r10
    jz .skip_count

    mov r14, r12
    xor r15d, r15d

.count_loop:
    cmp r14, r13
    jae .do_set

    mov rcx, r14
    shr rcx, 6
    mov rdx, r14
    and edx, 63
    bt qword [r10 + rcx*8], rdx
    jc .page_used
    inc r15d

.page_used:
    inc r14
    jmp .count_loop

.skip_count:
    xor r15d, r15d

.do_set:
    mov rcx, r12
    mov rdx, r13
    call pmm_set_range

    mov eax, r15d
    sub qword [boot_info + BootInfo.pmm_free_pages], rax

    pop r15
    pop r14
    pop r13
    pop r12
    pop r10
    pop rbx
    ret

;================ COPY_MEMORY_MAP =================

copy_memory_map:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, [boot_info + BootInfo.mem_size]
    test r12, r12
    jz .done

    mov rcx, r12
    add rcx, 4095
    and rcx, -4096
    call pmm_alloc_page_order

    test rax, rax
    jz .done

    mov r13, rax

    mov r14, [boot_info + BootInfo.mem_map]
    mov r15, r12

    cld
    mov rdi, r13
    mov rsi, r14
    mov rcx, r15
    add rcx, 7
    shr rcx, 3
    rep movsq

    mov [boot_info + BootInfo.mem_map_copy], r13
    mov [boot_info + BootInfo.mem_map_copy_size], r15

.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

pmm_alloc_page_order:
    push r12
    push r13

    mov r12, rcx
    add r12, PAGE_SIZE - 1
    shr r12, PAGE_SHIFT

    mov r13, 0
.find_order:
    mov rax, 1
    mov ecx, r13d
    shl rax, cl
    cmp rax, r12
    jae .found
    inc r13
    cmp r13, PMM_ORDER_MAX
    jbe .find_order
    jmp .fail

.found:
    mov rcx, r13
    call pmm_alloc_order
    test rax, rax
    jz .fail

    pop r13
    pop r12
    ret

.fail:
    xor eax, eax
    pop r13
    pop r12
    ret

;================ PMM_RESERVE_BOOT =================

pmm_reserve_boot:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r14, [boot_info + BootInfo.mem_map_copy]
    test r14, r14
    jnz .have_copy

    mov r14, [boot_info + BootInfo.mem_map]
    test r14, r14
    jz .done

.have_copy:
    mov r15, [boot_info + BootInfo.mem_size]
    mov rbx, [boot_info + BootInfo.mem_desc_size]

    test r15, r15
    jz .done
    test rbx, rbx
    jz .done

.loop:
    cmp r15, rbx
    jb .finish

    mov eax, [r14]

    cmp eax, MEM_TYPE_BS_CODE
    je .reserve

    cmp eax, MEM_TYPE_BS_DATA
    je .reserve

    cmp eax, MEM_TYPE_LOADER_CODE
    je .reserve

    cmp eax, MEM_TYPE_LOADER_DATA
    je .reserve

    cmp eax, 5
    je .reserve

    cmp eax, 6
    je .reserve

    cmp eax, 9
    je .reserve

    cmp eax, 10
    je .reserve

    cmp eax, 11
    je .reserve

    jmp .next

.reserve:
    mov r12, [r14 + 8]
    mov r13, [r14 + 24]
    shl r13, PAGE_SHIFT
    add r13, r12

    mov rcx, r12
    mov rdx, r13
    mov r8, MM_REGION_RESERVED
    call mm_region_add

    mov rcx, r12
    mov rdx, r13
    call mm_region_reserve_range

.next:
    add r14, rbx
    sub r15, rbx
    jmp .loop

.finish:
    mov rcx, [video + Video.fb]
    mov rax, [video + Video.sl]
    mov rdx, [video + Video.h]
    imul rax, rdx
    shl rax, 2
    add rax, rcx
    mov rdx, rax
    mov r8, MM_REGION_FRAMEBUFFER
    call mm_region_add

    mov rcx, [video + Video.fb]
    mov rdx, rax
    call mm_region_reserve_range

    lea rcx, [pmm_bitmap]
    lea rdx, [pmm_bitmap + PMM_BITMAP_SIZE]
    mov r8, MM_REGION_PMM
    call mm_region_add

    lea rcx, [pmm_bitmap]
    lea rdx, [pmm_bitmap + PMM_BITMAP_SIZE]
    call mm_region_reserve_range

    mov rax, [boot_info + BootInfo.mem_map_copy]
    test rax, rax
    jz .done

    mov rcx, rax
    mov rdx, [boot_info + BootInfo.mem_map_copy_size]
    add rdx, rcx
    mov r8, MM_REGION_PMM
    call mm_region_add

    mov rcx, rax
    mov rdx, [boot_info + BootInfo.mem_map_copy_size]
    add rdx, rcx
    call mm_region_reserve_range

.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

;================ MM_API =================

mm_alloc_pages:
    push r12
    push r13
    push r14

    mov r12, rcx
    mov r13, rdx

    test r12, r12
    jz .fail

    add r12, PAGE_SIZE - 1
    shr r12, PAGE_SHIFT

    mov r14, 0
.find_order:
    mov rax, 1
    mov ecx, r14d
    shl rax, cl
    cmp rax, r12
    jae .found
    inc r14
    cmp r14, PMM_ORDER_MAX
    jbe .find_order
    jmp .fail

.found:
    mov rcx, r14
    mov rdx, r13
    call mm_alloc_order_flags
    test rax, rax
    jz .fail

    pop r14
    pop r13
    pop r12
    ret

.fail:
    xor eax, eax
    pop r14
    pop r13
    pop r12
    ret

mm_free_pages:
    push r12
    push r13
    push r14

    mov r14, rcx
    mov r12, rdx

    test r14, r14
    jz .done

    add r12, PAGE_SIZE - 1
    shr r12, PAGE_SHIFT

    xor ecx, ecx
.find_order:
    mov rax, 1
    shl rax, cl
    cmp rax, r12
    jae .found
    inc rcx
    cmp rcx, PMM_ORDER_MAX
    jbe .find_order
    jmp .done

.found:
    mov rdx, rcx
    mov rcx, r14
    call pmm_free_order_flags

.done:
    pop r14
    pop r13
    pop r12
    ret

mm_kmem_alloc:
    push r12
    push r13

    mov r12, rcx
    mov r13, rdx

    test r12, r12
    jz .fail

    call kheap_init
    test eax, eax
    jnz .fail

    mov rcx, r12
    call kmalloc
    test rax, rax
    jz .fail

    test r13, MM_FLAG_ZERO
    jz .done

    push rax
    push r12

    mov r12, rax
    mov rdx, [r12 - KHEAP_HEADER_SIZE]
    sub rdx, KHEAP_HEADER_SIZE
    mov rcx, r12
    xor r8d, r8d
    call kmemset

    pop r12
    pop rax

.done:
    pop r13
    pop r12
    ret

.fail:
    xor eax, eax
    pop r13
    pop r12
    ret

mm_kmem_free:
    jmp kfree

mm_phys_to_virt:
    mov rax, [phys_map_base_val]
    add rax, rcx
    ret

mm_virt_to_phys:
    mov rax, rcx
    sub rax, [phys_map_base_val]
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

;================ VMM_MAP_2MB =================

vmm_map_2mb:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, rcx
    mov r13, rdx
    mov r15, r8

    mov rbx, [pml4_ptr]
    test rbx, rbx
    jz .oom

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
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

;================ VMM_BUILD =================

vmm_build:
    push rbx
    push r12
    push r13
    sub rsp, 8

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
    add rsp, 8
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

    push rax

    call pmm_alloc_page
    test rax, rax
    jz .split_oom

    mov r11, rax
    mov rcx, rax
    call zero_page

    pop r9

    mov r8, PAGE_PRESENT

    test r9b, PAGE_WRITABLE
    jz .split_no_w
    or r8, PAGE_WRITABLE

.split_no_w:
    test r9b, PAGE_USER
    jz .split_no_u
    or r8, PAGE_USER

.split_no_u:

    mov rax, r9
    shl rax, 12
    shr rax, 12
    and rax, -VMM_2MB_PAGE_SIZE
    mov r10, rax

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

; Local APIC timer IRQ.  Vector 32 is installed explicitly by idt_init_full.
isr_timer:
    push qword 0
    push qword LAPIC_TIMER_VECTOR
    jmp isr_common

; Local APIC spurious vector. No EOI is required for a spurious interrupt.
isr_spurious:
    push qword 0
    push qword 0xFF
    jmp isr_common

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

;================ minimal IDT / panic =================

isr_common:
    cli

    mov rcx, [rsp]
    cmp rcx, LAPIC_TIMER_VECTOR
    je .timer_irq
    cmp rcx, 0xFF
    je .spurious_irq

    mov rdx, [rsp + 8]
    mov r8, [rsp + 16]

    mov rax, rsp
    and rsp, -16
    sub rsp, 32

    call panic_exception

.timer_irq:
    ; Interrupt entry already cleared IF. Preserve all GPRs before touching
    ; the timer state, then return through the original hardware frame.
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    call lapic_timer_irq

    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    add rsp, 16                 ; discard vector + synthetic error code
    iretq

.spurious_irq:
    inc qword [lapic_spurious_count]
    add rsp, 16
    iretq

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

    cmp r15, 14
    jne .no_cr2
    lea r9, [str_cr2]
    call draw_text
    mov rcx, cr2
    call print_hex64

.no_cr2:
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

gdt_init:
    cli

    ; Enable CR4.PGE so kernel mappings marked GLOBAL survive CR3 switches.
    mov rax, cr4
    or rax, (1 << 7)
    mov cr4, rax

    lgdt [gdt_ptr]

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    xor eax, eax
    mov fs, ax
    mov gs, ax

    push qword 0x08
    lea rax, [.cs_set]
    push rax
    retfq

.cs_set:
    ret

tss_init:
    push rbx
    push r12

    lea r12, [tss]

    lea rax, [kernel_stack_top]
    mov [r12 + 4], rax

    lea rax, [ist_stack_top]
    mov [r12 + 36], rax

    lea rbx, [gdt]
    add rbx, 0x28

    ; Build a valid 64-bit available TSS descriptor (16 bytes).
    ; descriptor = limit[0:15] | base[0:23]<<16 | type<<40 |
    ;              limit[16:19]<<48 | base[24:31]<<56
    lea rax, [tss]
    mov rdx, rax
    mov rcx, tss_end - tss - 1

    mov rbx, rcx
    and ebx, 0xFFFF

    mov r8, rdx
    and r8d, 0xFFFFFF
    shl r8, 16
    or rbx, r8

    mov r8, 0x89
    shl r8, 40
    or rbx, r8

    mov r8, rcx
    shr r8, 16
    and r8d, 0x0F
    shl r8, 48
    or rbx, r8

    mov r8, rdx
    shr r8, 24
    and r8d, 0xFF
    shl r8, 56
    or rbx, r8

    mov [gdt + 0x28], rbx
    mov r8, rdx
    shr r8, 32
    mov [gdt + 0x30], r8

    ; No I/O bitmap is present yet. Point the I/O-map base at the end of the
    ; TSS so all port I/O remains denied/controlled until a later driver layer.
    mov word [r12 + 102], tss_end - tss

    mov ax, 0x28
    ltr ax

    pop r12
    pop rbx
    ret

idt_init_full:
    push rbx
    push r12
    push r13
    push r14
    push rdi
    sub rsp, 8

    cld

    lea rdi, [idt]
    xor eax, eax
    mov rcx, 256 * 16 / 8
    rep stosq

    lea r12, [isr_stub_table]
    xor r13, r13

.fill_specific:
    cmp r13, 32
    jae .fill_default

    movsxd rax, dword [r12 + r13 * 4]
    lea rax, [r12 + rax]

    lea r14, [idt]
    mov rcx, r13
    imul rcx, 16
    add r14, rcx

    mov ecx, eax
    mov word [r14 + 0], cx
    mov word [r14 + 2], 0x08
    ; IST1 is reserved for catastrophic paths: NMI(2), Double Fault(8),
    ; and Machine Check(18). Ordinary faults stay on the current kernel stack.
    xor edx, edx
    cmp r13, 2
    je .set_ist
    cmp r13, 8
    je .set_ist
    cmp r13, 18
    jne .ist_done
.set_ist:
    mov dl, 1
.ist_done:
    mov byte [r14 + 4], dl
    mov byte [r14 + 5], 0x8E
    shr eax, 16
    mov word [r14 + 6], ax
    shr eax, 16
    mov dword [r14 + 8], eax
    mov dword [r14 + 12], 0

    inc r13
    jmp .fill_specific

.fill_default:
    cmp r13, 256
    jae .load_idt

    lea rax, [isr_default]

    lea r14, [idt]
    mov rcx, r13
    imul rcx, 16
    add r14, rcx

    mov ecx, eax
    mov word [r14 + 0], cx
    mov word [r14 + 2], 0x08
    mov byte [r14 + 4], 1
    mov byte [r14 + 5], 0x8E
    shr eax, 16
    mov word [r14 + 6], ax
    shr eax, 16
    mov dword [r14 + 8], eax
    mov dword [r14 + 12], 0

    inc r13
    jmp .fill_default

.load_idt:
    ; Override IDT vector 32 with the Local APIC timer ISR.
    ; This must execute after the default-fill loop and before LIDT.
    lea rax, [isr_timer]
    lea r14, [idt + LAPIC_TIMER_VECTOR * 16]
    mov ecx, eax
    mov word [r14 + 0], cx
    mov word [r14 + 2], 0x08
    mov byte [r14 + 4], 0
    mov byte [r14 + 5], 0x8E
    shr eax, 16
    mov word [r14 + 6], ax
    shr eax, 16
    mov dword [r14 + 8], eax
    mov dword [r14 + 12], 0

    ; Vector 0xFF is the LAPIC spurious vector. It must not use isr_default,
    ; because isr_default is reserved for the pre-kernel firmware handoff.
    lea rax, [isr_spurious]
    lea r14, [idt + 0xFF * 16]
    mov ecx, eax
    mov word [r14 + 0], cx
    mov word [r14 + 2], 0x08
    mov byte [r14 + 4], 0
    mov byte [r14 + 5], 0x8E
    shr eax, 16
    mov word [r14 + 6], ax
    shr eax, 16
    mov dword [r14 + 8], eax
    mov dword [r14 + 12], 0

    lea rax, [idt]
    mov [new_idtr_base], rax
    lidt [new_idtr_limit]

    add rsp, 8
    pop rdi
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

isr_default:
    push qword 0
    push qword 0xFF
    jmp isr_common
;================ KHEAP_INIT =================

kheap_init:
    push rbx
    push r12
    push r13
    sub rsp, 8

    cmp byte [vmm_active], 1
    jne .fail

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
    add rsp, 8
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
    add rsp, 8
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
    
;================ HEAP_TEST =================

heap_test:
    push r12
    push r13
    push r14
    sub rsp, 8

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

    add rsp, 8
    pop r14
    pop r13
    pop r12

    lea r9, [msg_heaptest_ok]
    call draw_text
    ret

.fail:
    add rsp, 8
    pop r14
    pop r13
    pop r12

    lea r9, [msg_heaptest_fail]
    call draw_text
    ret

mm_alloc_page:
    jmp pmm_alloc_page

mm_free_page:
    jmp pmm_free_page

mm_alloc_order:
    jmp pmm_alloc_order

pmm_free_order_flags:
    push rax
    push r10
    push rdx

    mov rax, [buddy_pmm_pool_phys]
    test rax, rax
    jz .normal_pmm

    cmp rcx, rax
    jb .normal_pmm

    mov r10, rax
    add r10, BUDDY_PMM_BLOCK_SIZE

    cmp rcx, r10
    jae .normal_pmm

    call buddy_pmm_free

    pop rdx
    pop r10
    pop rax
    ret

.normal_pmm:
    pop rdx
    call pmm_free_order

    pop r10
    pop rax
    ret

mm_free_order:
    jmp pmm_free_order_flags

kmem_alloc:
    jmp kmalloc

kmem_free:
    jmp kfree

kmemset:
    push rdi
    push rcx
    push rdx
    push rax

    mov rdi, rcx
    mov rax, r8
    mov rcx, rdx

    cld
    rep stosb

    pop rax
    pop rdx
    pop rcx
    pop rdi
    ret

;================ KMEM_ZALLOC =================

kmem_zalloc:
    push rbx
    push r12
    push r13
    sub rsp, 8

    mov r12, rcx

    call kmalloc
    test rax, rax
    jz .done

    mov r13, rax

    mov rdx, [r13 - KHEAP_HEADER_SIZE]
    sub rdx, KHEAP_HEADER_SIZE

    mov rcx, r13
    xor r8d, r8d
    call kmemset

    mov rax, r13

.done:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    ret

kmem_alloc_flags:
    test dl, KMEM_FLAG_ZERO
    jz .no_zero

    jmp kmem_zalloc

.no_zero:
    jmp kmalloc

;================ KMEM_TEST =================

kmem_test:
    push r12
    sub rsp, 8

    call kheap_init
    test eax, eax
    jnz .fail

    mov rcx, 128
    mov rdx, KMEM_FLAG_ZERO
    call kmem_alloc_flags

    test rax, rax
    jz .fail

    mov r12, rax

    cmp byte [r12], 0
    jne .fail_free

    cmp byte [r12 + 127], 0
    jne .fail_free

    mov byte [r12], 0xAA

    mov rcx, r12
    call kmem_free

    add rsp, 8
    pop r12

    lea r9, [msg_kmemtest_ok]
    call draw_text
    ret

.fail_free:
    mov rcx, r12
    call kmem_free

.fail:
    add rsp, 8
    pop r12

    lea r9, [msg_kmemtest_fail]
    call draw_text
    ret

;================ PMM_ALLOC_ORDER_FLAGS =================

pmm_alloc_order_flags:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, rcx
    mov r13, rdx

    cmp r12, PMM_ORDER_MAX
    ja .fail

    mov r14, [boot_info + BootInfo.pmm_total_pages]

    test r13, MM_FLAG_DMA
    jz .not_dma

    mov r14, (ZONE_DMA_LIMIT >> PAGE_SHIFT)
    jmp .limit_done

.not_dma:
    test r13, MM_FLAG_DMA32
    jz .limit_done

    mov r14, (ZONE_DMA32_LIMIT >> PAGE_SHIFT)

.limit_done:
    cmp r14, [boot_info + BootInfo.pmm_total_pages]
    jbe .limit_ok

    mov r14, [boot_info + BootInfo.pmm_total_pages]

.limit_ok:

    cmp byte [buddy_pmm_active], 1
    jne .bitmap

    cmp r12, BUDDY_PMM_ORDER
    ja .bitmap

    mov r15, 1
    mov ecx, BUDDY_PMM_ORDER
    shl r15, cl

    mov rax, [buddy_pmm_pool_phys]
    shr rax, PAGE_SHIFT
    add rax, r15
    cmp rax, r14
    ja .bitmap

    mov rcx, r12
    call buddy_pmm_alloc
    test rax, rax
    jnz .done

.bitmap:
    mov r13, 1
    mov ecx, r12d
    shl r13, cl

    cmp r13, r14
    ja .fail

    cmp qword [boot_info + BootInfo.pmm_free_pages], 0
    je .fail

    cmp r13, [boot_info + BootInfo.pmm_free_pages]
    ja .fail

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

.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    xor eax, eax
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

mm_alloc_order_flags:
    push r12
    push r13
    push r14
    push r15

    mov r12, rcx
    mov r13, rdx

    call pmm_alloc_order_flags
    test rax, rax
    jz .done

    test r13, MM_FLAG_ZERO
    jz .done

    mov r15, rax
    mov r14, rax

    mov rax, 1
    mov ecx, r12d
    shl rax, cl
    mov rcx, rax

.zero_loop:
    test rcx, rcx
    jz .zero_done

    push rcx
    push r14

    mov rcx, r14
    call zero_page

    pop r14
    pop rcx

    add r14, PAGE_SIZE
    dec rcx
    jmp .zero_loop

.zero_done:
    mov rax, r15

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    ret

mm_alloc_page_flags:
    mov rdx, rcx
    xor ecx, ecx
    jmp mm_alloc_order_flags

;================ MM_FLAGS_TEST =================

mm_flags_test:
    push r12
    sub rsp, 8

    mov rcx, 1
    mov rdx, MM_FLAG_ZERO
    call mm_alloc_order_flags

    test rax, rax
    jz .fail

    mov r12, rax

    cmp byte [r12], 0
    jne .fail_free

    lea rax, [r12 + (2 * PAGE_SIZE) - 1]
    cmp byte [rax], 0
    jne .fail_free

    mov rcx, r12
    mov rdx, 1
    call mm_free_order

    add rsp, 8
    pop r12

    lea r9, [msg_mmflags_ok]
    call draw_text
    ret

.fail_free:
    mov rcx, r12
    mov rdx, 1
    call mm_free_order

.fail:
    add rsp, 8
    pop r12

    lea r9, [msg_mmflags_fail]
    call draw_text
    ret

buddy_test:
    push r12
    push r13

    mov rcx, 1
    call pmm_alloc_order
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 2
    call pmm_alloc_order
    test rax, rax
    jz .fail_free_order1
    mov r13, rax

    cmp r12, r13
    je .fail_free_order2

    mov qword [r12], 0x1234
    mov qword [r13], 0x5678

    cmp qword [r12], 0x1234
    jne .fail_free_order2

    cmp qword [r13], 0x5678
    jne .fail_free_order2

    mov rcx, r13
    mov rdx, 2
    call pmm_free_order

    mov rcx, 2
    call pmm_alloc_order
    test rax, rax
    jz .fail_free_order1

    mov rcx, rax
    mov rdx, 2
    call pmm_free_order

    mov rcx, r12
    mov rdx, 1
    call pmm_free_order

    mov rcx, r12
    mov rdx, 1
    call pmm_free_order

    pop r13
    pop r12

    lea r9, [msg_buddytest_ok]
    call draw_text
    ret

.fail_free_order2:
    mov rcx, r13
    mov rdx, 2
    call pmm_free_order

.fail_free_order1:
    mov rcx, r12
    mov rdx, 1
    call pmm_free_order

.fail:
    pop r13
    pop r12

    lea r9, [msg_buddytest_fail]
    call draw_text
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
    test rcx, rcx
    jz .empty

    lea rdi, [cmd_buf]
    mov byte [rdi + rcx], 0

    call cmd_execute

    mov qword [cmd_len], 0
    jmp .finish

.empty:
    ; Empty Enter is not a command. Do not enter the command dispatcher.
    xor eax, eax
    mov qword [cmd_len], 0

.finish:

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

buddy_push:
    lea r8, [buddy_free_heads]
    mov r9, [r8 + rcx*8]

    mov [rdx], r9
    mov [r8 + rcx*8], rdx

    ret

buddy_pop:
    lea rdx, [buddy_free_heads]
    mov rax, [rdx + rcx*8]

    test rax, rax
    jz .done

    mov r9, [rax]
    mov [rdx + rcx*8], r9

.done:
    ret

buddy_contains:
    push r9

    lea r9, [buddy_free_heads]
    mov rax, [r9 + rcx*8]

.loop:
    test rax, rax
    jz .no

    cmp rax, rdx
    je .yes

    mov rax, [rax]
    jmp .loop

.yes:
    mov eax, 1
    pop r9
    ret

.no:
    xor eax, eax
    pop r9
    ret

buddy_remove:
    push r9
    push r10

    lea r9, [buddy_free_heads]
    lea r10, [r9 + rcx*8]

.loop:
    mov rax, [r10]

    test rax, rax
    jz .no

    cmp rax, rdx
    je .found

    mov r10, rax
    jmp .loop

.found:
    mov rax, [rax]
    mov [r10], rax

    mov eax, 1
    pop r10
    pop r9
    ret

.no:
    xor eax, eax
    pop r10
    pop r9
    ret

buddy_pool_fallback:
    push r12

    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rbx, [bs]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + BS_ALLOCATE_POOL]
    test rax, rax
    jz .fail

    mov ecx, EFI_LOADER_DATA
    mov rdx, 0x8000
    lea r8, [buddy_fallback_alloc]

    call rax

    test rax, rax
    jnz .fail

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    mov rsp, r12
    pop r12
    ret

buddy_reset:
    push rdi
    push rcx
    push rax

    cmp byte [buddy_arena_active], 1
    jne .clear_only

    cmp byte [buddy_arena_from_pmm], 1
    jne .clear_only

    mov rcx, [buddy_arena_base]
    mov rdx, [buddy_arena_order]
    call pmm_free_order

.clear_only:
    cld
    lea rdi, [buddy_free_heads]
    xor eax, eax
    mov ecx, BUDDY_ARENA_ORDER_MAX + 1
    rep stosq

    mov byte [buddy_arena_active], 0
    mov byte [buddy_arena_from_pmm], 0
    mov qword [buddy_arena_order], 0
    mov qword [buddy_arena_base], 0

    pop rax
    pop rcx
    pop rdi
    ret

buddy_init:
    push rbx
    push r12
    push r13
    push rdi
    push rcx
    push rax

    cmp byte [buddy_arena_active], 1
    je .ok

    cld
    lea rdi, [buddy_free_heads]
    xor eax, eax
    mov ecx, BUDDY_ARENA_ORDER_MAX + 1
    rep stosq

    lea rax, [buddy_static_pool]
    add rax, 0x3FFF
    and rax, -0x4000

    mov r13, rax

    mov r12, 2

    mov [buddy_arena_order], r12
    mov byte [buddy_arena_from_pmm], 0

    mov rcx, r12
    mov rdx, r13
    call buddy_push

    mov [buddy_arena_base], r13
    mov byte [buddy_arena_active], 1

.ok:
    xor eax, eax
    pop rax
    pop rcx
    pop rdi
    pop r13
    pop r12
    pop rbx
    ret
    
;================ BUDDY_ALLOC =================

buddy_alloc:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, rcx

    mov r13, [buddy_arena_order]
    test r13, r13
    jz .fail

    cmp r12, r13
    ja .fail

    mov r14, r12

.find:
    cmp r14, r13
    ja .fail

    mov rcx, r14
    call buddy_pop

    test rax, rax
    jnz .got

    inc r14
    jmp .find

.got:
    mov r15, rax
    mov rbx, r14

.split:
    cmp rbx, r12
    je .done

    dec rbx

    mov rdx, 1
    mov ecx, ebx
    add ecx, PAGE_SHIFT
    shl rdx, cl

    lea rdx, [r15 + rdx]

    mov rcx, rbx
    call buddy_push

    jmp .split

.done:
    mov qword [r15], 0
    mov rax, r15

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    xor eax, eax
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

buddy_free:
    push r12
    push r13
    push r14
    push r15

    mov r14, rcx
    mov r15, rdx

    mov r13, [buddy_arena_order]
    test r13, r13
    jz .done

    cmp r15, r13
    ja .done

.merge_loop:
    cmp r15, r13
    jae .add

    mov rax, 1
    mov ecx, r15d
    add ecx, PAGE_SHIFT
    shl rax, cl

    mov r12, r14
    xor r12, rax

    mov rcx, r15
    mov rdx, r12
    call buddy_contains

    test eax, eax
    jz .add

    mov rcx, r15
    mov rdx, r12
    call buddy_remove

    cmp r14, r12
    jb .keep_addr

    mov r14, r12

.keep_addr:
    inc r15
    jmp .merge_loop

.add:
    mov rcx, r15
    mov rdx, r14
    call buddy_push

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    ret

buddy_arena_test:
    push r12
    push r13

    lea r9, [msg_buddyarena_v3]
    call draw_text

    call buddy_reset

    cld
    lea rdi, [buddy_free_heads]
    xor eax, eax
    mov ecx, BUDDY_ARENA_ORDER_MAX + 1
    rep stosq

    mov r12, BUDDY_ARENA_ORDER_MAX

.try_pmm:
    cmp r12, BUDDY_ARENA_ORDER_MIN
    jb .static_fallback

    mov rcx, r12
    call pmm_alloc_order
    test rax, rax
    jnz .got_pmm

    dec r12
    jmp .try_pmm

.got_pmm:
    mov r13, rax

    mov [buddy_arena_order], r12
    mov byte [buddy_arena_from_pmm], 1

    mov rcx, r12
    mov rdx, r13
    call buddy_push

    mov [buddy_arena_base], r13
    mov byte [buddy_arena_active], 1

    lea r9, [msg_buddy_pmm]
    call draw_text

    mov rcx, r12
    call print_hex64

    mov r9b, CHAR_LF
    call console_putc

    jmp .run_tests

.static_fallback:
    lea rax, [buddy_static_pool]

    mov rdx, BUDDY_STATIC_BLOCK_SIZE - 1
    add rax, rdx
    not rdx
    and rax, rdx

    mov r13, rax

    mov qword [buddy_arena_order], BUDDY_STATIC_ORDER
    mov byte [buddy_arena_from_pmm], 0

    mov rcx, BUDDY_STATIC_ORDER
    mov rdx, r13
    call buddy_push

    mov [buddy_arena_base], r13
    mov byte [buddy_arena_active], 1

    lea r9, [msg_buddy_static]
    call draw_text

.run_tests:
    mov rcx, 1
    call buddy_alloc
    test rax, rax
    jz .fail_alloc1
    mov r12, rax

    mov rcx, 1
    call buddy_alloc
    test rax, rax
    jz .fail_alloc2
    mov r13, rax

    cmp r12, r13
    je .fail_alloc2

    mov qword [r12], 0x1111
    mov qword [r13], 0x2222

    cmp qword [r12], 0x1111
    jne .fail_write

    cmp qword [r13], 0x2222
    jne .fail_write

    mov rcx, r12
    mov rdx, 1
    call buddy_free

    mov rcx, r13
    mov rdx, 1
    call buddy_free

    mov rcx, 2
    call buddy_alloc
    test rax, rax
    jz .fail_merge_alloc

    mov rcx, rax
    mov rdx, 2
    call buddy_free

    pop r13
    pop r12

    lea r9, [msg_buddyarena_ok]
    call draw_text
    ret

.fail_merge_alloc:
    lea r9, [msg_buddyarena_fail_merge_alloc]
    jmp .print_fail

.fail_write:
    mov rcx, r13
    mov rdx, 1
    call buddy_free

    mov rcx, r12
    mov rdx, 1
    call buddy_free

    lea r9, [msg_buddyarena_fail_write]
    jmp .print_fail

.fail_alloc2:
    mov rcx, r12
    mov rdx, 1
    call buddy_free

    lea r9, [msg_buddyarena_fail_alloc2]
    jmp .print_fail

.fail_alloc1:
    lea r9, [msg_buddyarena_fail_alloc1]
    jmp .print_fail

.print_fail:
    call draw_text

    pop r13
    pop r12
    ret

buddy_stress_test:
    push r12
    push r13
    push r14
    push r15

    lea r9, [msg_buddystress_v1]
    call draw_text

    call buddy_reset

    cld
    lea rdi, [buddy_free_heads]
    xor eax, eax
    mov ecx, BUDDY_ARENA_ORDER_MAX + 1
    rep stosq

    mov r12, BUDDY_ARENA_ORDER_MAX

.try_pmm:
    cmp r12, BUDDY_ARENA_ORDER_MIN
    jb .static_fallback

    mov rcx, r12
    call pmm_alloc_order
    test rax, rax
    jnz .got_pmm

    dec r12
    jmp .try_pmm

.got_pmm:
    mov r13, rax

    mov [buddy_arena_order], r12
    mov byte [buddy_arena_from_pmm], 1

    mov rcx, r12
    mov rdx, r13
    call buddy_push

    mov [buddy_arena_base], r13
    mov byte [buddy_arena_active], 1

    jmp .stress

.static_fallback:
    lea rax, [buddy_static_pool]

    mov rdx, BUDDY_STATIC_BLOCK_SIZE - 1
    add rax, rdx
    not rdx
    and rax, rdx

    mov r13, rax

    mov qword [buddy_arena_order], BUDDY_STATIC_ORDER
    mov byte [buddy_arena_from_pmm], 0

    mov rcx, BUDDY_STATIC_ORDER
    mov rdx, r13
    call buddy_push

    mov [buddy_arena_base], r13
    mov byte [buddy_arena_active], 1

.stress:
    ; Alloc 4 x order-0
    mov rcx, 0
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 0
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r13, rax

    mov rcx, 0
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r14, rax

    mov rcx, 0
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r15, rax

    cmp r12, r13
    je .fail
    cmp r12, r14
    je .fail
    cmp r12, r15
    je .fail
    cmp r13, r14
    je .fail
    cmp r13, r15
    je .fail
    cmp r14, r15
    je .fail

    mov qword [r12], 0xA0
    mov qword [r13], 0xA1
    mov qword [r14], 0xA2
    mov qword [r15], 0xA3

    cmp qword [r12], 0xA0
    jne .fail
    cmp qword [r13], 0xA1
    jne .fail
    cmp qword [r14], 0xA2
    jne .fail
    cmp qword [r15], 0xA3
    jne .fail

    mov rcx, r13
    mov rdx, 0
    call buddy_free

    mov rcx, r12
    mov rdx, 0
    call buddy_free

    mov rcx, r15
    mov rdx, 0
    call buddy_free

    mov rcx, r14
    mov rdx, 0
    call buddy_free

    ; Alloc 2 x order-1
    mov rcx, 1
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 1
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r13, rax

    cmp r12, r13
    je .fail

    mov qword [r12], 0xB0
    mov qword [r13], 0xB1

    cmp qword [r12], 0xB0
    jne .fail
    cmp qword [r13], 0xB1
    jne .fail

    mov rcx, r13
    mov rdx, 1
    call buddy_free

    mov rcx, r12
    mov rdx, 1
    call buddy_free

    ; Alloc 1 x order-2
    mov rcx, 2
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov qword [r12], 0xC0
    cmp qword [r12], 0xC0
    jne .fail

    mov rcx, r12
    mov rdx, 2
    call buddy_free

    ; Higher-order tests, if arena is large enough
    mov rax, [buddy_arena_order]
    cmp rax, 4
    jb .ok

    ; Alloc 1 x order-4
    mov rcx, 4
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov qword [r12], 0xD4
    cmp qword [r12], 0xD4
    jne .fail

    mov rcx, r12
    mov rdx, 4
    call buddy_free

    ; Alloc 2 x order-3
    mov rcx, 3
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 3
    call buddy_alloc
    test rax, rax
    jz .fail
    mov r13, rax

    cmp r12, r13
    je .fail

    mov qword [r12], 0xD3
    mov qword [r13], 0xE3

    cmp qword [r12], 0xD3
    jne .fail
    cmp qword [r13], 0xE3
    jne .fail

    mov rcx, r13
    mov rdx, 3
    call buddy_free

    mov rcx, r12
    mov rdx, 3
    call buddy_free

.ok:
    lea r9, [msg_buddystress_ok]
    call draw_text

    pop r15
    pop r14
    pop r13
    pop r12
    ret

.fail:
    lea r9, [msg_buddystress_fail]
    call draw_text

    pop r15
    pop r14
    pop r13
    pop r12
    ret

;================ Buddy PMM =================

buddy_pmm_push:
    lea r8, [buddy_pmm_heads]
    mov r9, [r8 + rcx*8]

    mov [rdx], r9
    mov [r8 + rcx*8], rdx

    ret

buddy_pmm_pop:
    lea rdx, [buddy_pmm_heads]
    mov rax, [rdx + rcx*8]

    test rax, rax
    jz .done

    mov r9, [rax]
    mov [rdx + rcx*8], r9

.done:
    ret

buddy_pmm_contains:
    push r9

    lea r9, [buddy_pmm_heads]
    mov rax, [r9 + rcx*8]

.loop:
    test rax, rax
    jz .no

    cmp rax, rdx
    je .yes

    mov rax, [rax]
    jmp .loop

.yes:
    mov eax, 1
    pop r9
    ret

.no:
    xor eax, eax
    pop r9
    ret

buddy_pmm_remove:
    push r9
    push r10

    lea r9, [buddy_pmm_heads]
    lea r10, [r9 + rcx*8]

.loop:
    mov rax, [r10]

    test rax, rax
    jz .no

    cmp rax, rdx
    je .found

    mov r10, rax
    jmp .loop

.found:
    mov rax, [rax]
    mov [r10], rax

    mov eax, 1
    pop r10
    pop r9
    ret

.no:
    xor eax, eax
    pop r10
    pop r9
    ret

;================ BUDDY_PMM_ALLOC =================

buddy_pmm_alloc:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, rcx

    cmp r12, BUDDY_PMM_ORDER
    ja .fail

    mov r14, r12

.find:
    cmp r14, BUDDY_PMM_ORDER
    ja .fail

    mov rcx, r14
    call buddy_pmm_pop
    test rax, rax
    jnz .got

    inc r14
    jmp .find

.got:
    mov r15, rax
    mov rbx, r14

.split:
    cmp rbx, r12
    je .done

    dec rbx

    mov rdx, 1
    mov ecx, ebx
    add ecx, PAGE_SHIFT
    shl rdx, cl

    lea rdx, [r15 + rdx]

    mov rcx, rbx
    call buddy_pmm_push

    jmp .split

.done:
    mov rax, r15

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    xor eax, eax
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret


buddy_pmm_free:
    push r12
    push r13
    push r14
    push r15

    mov r14, rcx
    mov r15, rdx

    cmp r15, BUDDY_PMM_ORDER
    ja .done

.merge_loop:
    cmp r15, BUDDY_PMM_ORDER
    jae .add

    mov rax, 1
    mov ecx, r15d
    add ecx, PAGE_SHIFT
    shl rax, cl

    mov r12, r14
    xor r12, rax

    mov rcx, r15
    mov rdx, r12
    call buddy_pmm_contains

    test eax, eax
    jz .add

    mov rcx, r15
    mov rdx, r12
    call buddy_pmm_remove

    cmp r14, r12
    jb .keep_addr

    mov r14, r12

.keep_addr:
    inc r15
    jmp .merge_loop

.add:
    mov rcx, r15
    mov rdx, r14
    call buddy_pmm_push

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    ret

buddy_pmm_init:
    push rdi
    push rcx
    push rax
    push rdx

    cmp byte [buddy_pmm_active], 1
    je .ok

    cld
    lea rdi, [buddy_pmm_heads]
    xor eax, eax
    mov ecx, BUDDY_PMM_ORDER + 1
    rep stosq

    lea rax, [buddy_pmm_pool_raw]

    mov rdx, BUDDY_PMM_BLOCK_SIZE - 1
    add rax, rdx
    not rdx
    and rax, rdx

    mov [buddy_pmm_pool_phys], rax

    mov rcx, BUDDY_PMM_ORDER
    mov rdx, rax
    call buddy_pmm_push

    mov byte [buddy_pmm_active], 1

.ok:
    xor eax, eax

    pop rdx
    pop rax
    pop rcx
    pop rdi
    ret

buddy_pmm_reset:
    push rdi
    push rcx
    push rax
    push rdx

    cld
    lea rdi, [buddy_pmm_heads]
    xor eax, eax
    mov ecx, BUDDY_PMM_ORDER + 1
    rep stosq

    mov rax, [buddy_pmm_pool_phys]
    test rax, rax
    jz .done

    mov rcx, BUDDY_PMM_ORDER
    mov rdx, rax
    call buddy_pmm_push

    mov byte [buddy_pmm_active], 1

.done:
    xor eax, eax

    pop rdx
    pop rax
    pop rcx
    pop rdi
    ret

buddy_pmm_test:
    push r12
    push r13
    push r14
    push r15

    lea r9, [msg_bpmm_v1]
    call draw_text

    call buddy_pmm_init
    test eax, eax
    jnz .fail

    call buddy_pmm_reset
    test eax, eax
    jnz .fail

    ; 4 x order-0
    mov rcx, 0
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 0
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r13, rax

    mov rcx, 0
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r14, rax

    mov rcx, 0
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r15, rax

    cmp r12, r13
    je .fail
    cmp r12, r14
    je .fail
    cmp r12, r15
    je .fail
    cmp r13, r14
    je .fail
    cmp r13, r15
    je .fail
    cmp r14, r15
    je .fail

    mov qword [r12], 0x10
    mov qword [r13], 0x11
    mov qword [r14], 0x12
    mov qword [r15], 0x13

    cmp qword [r12], 0x10
    jne .fail
    cmp qword [r13], 0x11
    jne .fail
    cmp qword [r14], 0x12
    jne .fail
    cmp qword [r15], 0x13
    jne .fail

    mov rcx, r13
    mov rdx, 0
    call buddy_pmm_free

    mov rcx, r12
    mov rdx, 0
    call buddy_pmm_free

    mov rcx, r15
    mov rdx, 0
    call buddy_pmm_free

    mov rcx, r14
    mov rdx, 0
    call buddy_pmm_free

    ; 2 x order-1
    mov rcx, 1
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 1
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r13, rax

    cmp r12, r13
    je .fail

    mov qword [r12], 0x20
    mov qword [r13], 0x21

    cmp qword [r12], 0x20
    jne .fail
    cmp qword [r13], 0x21
    jne .fail

    mov rcx, r13
    mov rdx, 1
    call buddy_pmm_free

    mov rcx, r12
    mov rdx, 1
    call buddy_pmm_free

    ; 1 x order-2
    mov rcx, 2
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov qword [r12], 0x30
    cmp qword [r12], 0x30
    jne .fail

    mov rcx, r12
    mov rdx, 2
    call buddy_pmm_free

    ; 1 x order-4
    mov rcx, 4
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov qword [r12], 0x40
    cmp qword [r12], 0x40
    jne .fail

    mov rcx, r12
    mov rdx, 4
    call buddy_pmm_free

    ; 2 x order-3
    mov rcx, 3
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 3
    call buddy_pmm_alloc
    test rax, rax
    jz .fail
    mov r13, rax

    cmp r12, r13
    je .fail

    mov qword [r12], 0x50
    mov qword [r13], 0x51

    cmp qword [r12], 0x50
    jne .fail
    cmp qword [r13], 0x51
    jne .fail

    mov rcx, r13
    mov rdx, 3
    call buddy_pmm_free

    mov rcx, r12
    mov rdx, 3
    call buddy_pmm_free

    lea r9, [msg_bpmm_ok]
    call draw_text

    pop r15
    pop r14
    pop r13
    pop r12
    ret

.fail:
    lea r9, [msg_bpmm_fail]
    call draw_text

    pop r15
    pop r14
    pop r13
    pop r12
    ret

zonetest:
    push r12
    push r13
    push r14

    lea r9, [msg_zonetest_v1]
    call draw_text

    call buddy_pmm_init
    test eax, eax
    jnz .fail

    ; Normal allocation, order 2
    mov rcx, 2
    xor rdx, rdx
    call pmm_alloc_order_flags
    test rax, rax
    jz .fail
    mov r12, rax

    mov qword [r12], 0x1000
    cmp qword [r12], 0x1000
    jne .fail

    mov rcx, r12
    mov rdx, 2
    call pmm_free_order_flags

    ; DMA32 allocation, order 2
    mov rcx, 2
    mov rdx, MM_FLAG_DMA32
    call pmm_alloc_order_flags
    test rax, rax
    jz .fail
    mov r12, rax

    mov r13, [zone_dma32_limit_val]
    cmp r12, r13
    jae .fail

    mov qword [r12], 0x2000
    cmp qword [r12], 0x2000
    jne .fail

    mov rcx, r12
    mov rdx, 2
    call pmm_free_order_flags

    ; DMA allocation, order 0
    mov rcx, 0
    mov rdx, MM_FLAG_DMA
    call pmm_alloc_order_flags
    test rax, rax
    jz .fail
    mov r12, rax

	mov r13, [zone_dma_limit_val]
    cmp r12, r13
    jae .fail

    mov qword [r12], 0x3000
    cmp qword [r12], 0x3000
    jne .fail

    mov rcx, r12
    mov rdx, 0
    call pmm_free_order_flags

    lea r9, [msg_zonetest_ok]
    call draw_text

    pop r14
    pop r13
    pop r12
    ret

.fail:
    lea r9, [msg_zonetest_fail]
    call draw_text

    pop r14
    pop r13
    pop r12
    ret

;================ Slab Allocator =================

slab_cache_index:
    ; input:
    ; rcx = size
    ;
    ; output:
    ; rax = cache index, or SLAB_CACHE_COUNT if too large

    xor eax, eax

.loop:
    cmp rax, SLAB_CACHE_COUNT
    jae .done

    cmp rcx, [slab_sizes + rax*8]
    jbe .done

    inc rax
    jmp .loop

.done:
    ret

slab_refill:
    push rbx
    push r12
    push r13
    push r14

    mov r12, rcx        ; cache index

    ; Allocate one page for this slab
    mov rcx, 0
    xor rdx, rdx
    call pmm_alloc_order_flags
    test rax, rax
    jz .fail

    mov r14, rax        ; page address
    mov r13, [slab_sizes + r12*8]

    ; object count = PAGE_SIZE / object_size
    mov rax, PAGE_SIZE
    xor edx, edx
    div r13

    mov rcx, rax        ; count
    mov rdx, r14        ; current object

.push_loop:
    test rcx, rcx
    jz .ok

    mov rax, [slab_free_heads + r12*8]
    mov [rdx], rax
    mov [slab_free_heads + r12*8], rdx

    add rdx, r13
    dec rcx
    jmp .push_loop

.ok:
    xor eax, eax
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    mov eax, 1
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

;================ SLAB_ALLOC =================

slab_alloc:
    push rbx
    push r12
    push r13
    sub rsp, 8

    mov r12, rcx

    call slab_cache_index
    cmp rax, SLAB_CACHE_COUNT
    jae .fail

    mov r12, rax

.retry:
    mov rax, [slab_free_heads + r12 * 8]
    test rax, rax
    jnz .got

    mov rcx, r12
    call slab_refill
    test eax, eax
    jnz .fail

    mov rax, [slab_free_heads + r12 * 8]
    test rax, rax
    jnz .got
    jmp .fail

.got:
    mov rbx, [rax]
    mov [slab_free_heads + r12 * 8], rbx

    add rsp, 8
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    xor eax, eax
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    ret

;================ SLAB_FREE =================

slab_free:
    push rax
    push r12
    push r13
    sub rsp, 8

    mov r12, rcx
    mov r13, rdx

    test r13, r13
    jz .done

    mov rcx, r12
    call slab_cache_index
    cmp rax, SLAB_CACHE_COUNT
    jae .done

    mov rcx, [slab_free_heads + rax * 8]
    mov [r13], rcx
    mov [slab_free_heads + rax * 8], r13

.done:
    add rsp, 8
    pop r13
    pop r12
    pop rax
    ret

slabtest:
    push rbx
    push r12
    push r13
    push r14
    push r15

    lea r9, [msg_slabtest_v1]
    call draw_text

    lea rbx, [slab_test_ptrs]

    xor r15, r15

.alloc16:
    mov rcx, 16
    call slab_alloc
    test rax, rax
    jz .fail

    mov [rbx + r15*8], rax
    mov byte [rax], 0x5A

    inc r15
    cmp r15, SLAB_TEST_COUNT
    jb .alloc16

    xor r15, r15

.free16:
    mov r12, [rbx + r15*8]

    cmp byte [r12], 0x5A
    jne .fail

    mov rcx, 16
    mov rdx, r12
    call slab_free

    inc r15
    cmp r15, SLAB_TEST_COUNT
    jb .free16

    ; Bigger size classes
    mov rcx, 32
    call slab_alloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rcx, 64
    call slab_alloc
    test rax, rax
    jz .fail
    mov r13, rax

    mov rcx, 128
    call slab_alloc
    test rax, rax
    jz .fail
    mov r14, rax

    mov rcx, 256
    call slab_alloc
    test rax, rax
    jz .fail
    mov r15, rax

    cmp r12, r13
    je .fail
    cmp r12, r14
    je .fail
    cmp r12, r15
    je .fail
    cmp r13, r14
    je .fail
    cmp r13, r15
    je .fail
    cmp r14, r15
    je .fail

    mov qword [r12], 0x1111
    mov qword [r13], 0x2222
    mov qword [r14], 0x3333
    mov qword [r15], 0x4444

    cmp qword [r12], 0x1111
    jne .fail
    cmp qword [r13], 0x2222
    jne .fail
    cmp qword [r14], 0x3333
    jne .fail
    cmp qword [r15], 0x4444
    jne .fail

    mov rcx, 256
    mov rdx, r15
    call slab_free

    mov rcx, 128
    mov rdx, r14
    call slab_free

    mov rcx, 64
    mov rdx, r13
    call slab_free

    mov rcx, 32
    mov rdx, r12
    call slab_free

    lea r9, [msg_slabtest_ok]
    call draw_text

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    lea r9, [msg_slabtest_fail]
    call draw_text

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

;================ Higher-Half VMM =================

vmm_map_2mb_pml4:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov rbx, rcx        ; pml4 physical
    mov r12, rdx        ; virtual address
    mov r13, r8         ; physical address
    mov r15, r9         ; flags

    ; PML4
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

    ; PDPT
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

    ; PD
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

phys_to_virt:
    ; Translate only physical addresses inside the active HHDM window.
    ; Carry/limit checks prevent silent wraparound into a non-canonical VA.
    mov rax, [hh_direct_map_limit_val]
    test rax, rax
    jz .fail
    cmp rcx, rax
    jae .fail
    mov rax, [phys_map_base_val]
    add rax, rcx
    jc .fail
    ret
.fail:
    xor eax, eax
    ret

virt_to_phys:
    mov rax, [phys_map_base_val]
    cmp rcx, rax
    jb .fail
    sub rcx, rax
    cmp rcx, [hh_direct_map_limit_val]
    jae .fail
    mov rax, rcx
    ret
.fail:
    xor eax, eax
    ret

; 4 KiB mapper operating on an explicit PML4. Used while constructing a
; second address space before it becomes active.
vmm_map_4k_pml4:
    push rbx
    push r11
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    mov r11, rcx                ; PML4 (saved on stack; allocator may clobber r11)
    mov [rsp], r11
    mov r12, rdx                ; virtual
    mov r13, r8                 ; physical
    mov r15, r9                 ; flags

    mov rbx, r11

    mov rax, r12
    shr rax, 39
    and eax, PT_INDEX_BITS
    mov r14, rax
    mov rax, [rbx + r14*8]
    test al, PAGE_PRESENT
    jnz .pdpt
    call pmm_alloc_page
    test rax, rax
    jz .oom
    mov rcx, rax
    call zero_page
    mov rbx, [rsp]
    or rax, PAGE_PRESENT | PAGE_WRITABLE
    mov [rbx + r14*8], rax
.pdpt:
    mov rax, [rbx + r14*8]
    test al, PAGE_SIZE_FLAG
    jnz .conflict
    MASK_FRAME rax
    mov rbx, rax

    mov rax, r12
    shr rax, 30
    and eax, PT_INDEX_BITS
    mov r14, rax
    mov rax, [rbx + r14*8]
    test al, PAGE_PRESENT
    jnz .pd
    mov [rsp + 8], rbx
    call pmm_alloc_page
    test rax, rax
    jz .oom
    mov rcx, rax
    call zero_page
    mov rbx, [rsp + 8]
    or rax, PAGE_PRESENT | PAGE_WRITABLE
    mov [rbx + r14*8], rax
.pd:
    mov rax, [rbx + r14*8]
    test al, PAGE_SIZE_FLAG
    jnz .conflict
    MASK_FRAME rax
    mov rbx, rax

    mov rax, r12
    shr rax, 21
    and eax, PT_INDEX_BITS
    mov r14, rax
    mov rax, [rbx + r14*8]
    test al, PAGE_PRESENT
    jnz .pt
    mov [rsp + 8], rbx
    call pmm_alloc_page
    test rax, rax
    jz .oom
    mov rcx, rax
    call zero_page
    mov rbx, [rsp + 8]
    or rax, PAGE_PRESENT | PAGE_WRITABLE
    mov [rbx + r14*8], rax
.pt:
    mov rax, [rbx + r14*8]
    test al, PAGE_SIZE_FLAG
    jnz .split_needed
    MASK_FRAME rax
    mov rbx, rax
    jmp .install

.split_needed:
    ; HHDM virtual space should never collide with the identity 2 MiB map.
    ; Refuse the conflict rather than silently splitting a foreign mapping.
    jmp .conflict

.install:
    mov rax, r12
    shr rax, 12
    and eax, PT_INDEX_BITS
    mov r14, rax
    mov rax, r13
    and rax, -PAGE_SIZE
    or rax, r15
    or rax, PAGE_PRESENT
    mov [rbx + r14*8], rax
    invlpg [r12]
    xor eax, eax
    jmp .done
.conflict:
    mov eax, 1
    jmp .done
.oom:
    mov eax, 2
.done:
    add rsp, 24
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop rbx
    ret

; Map an exact EFI memory descriptor into the HHDM.  Large-page mappings
; are used only for the fully aligned interior of the descriptor.  The
; leading/trailing fragments stay 4 KiB mapped, so reserved physical pages
; immediately adjacent to RAM are never accidentally exposed by rounding.
hh_map_region:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rcx                ; PML4 physical
    mov r13, rdx                ; physical start
    mov r14, r8                 ; physical end (exclusive)
    mov r15, r9                 ; flags

    cmp r13, r14
    jae .ok

    ; Leading partial 2 MiB region.
    mov rax, r13
    mov rdx, r13
    add rdx, VMM_2MB_PAGE_SIZE - 1
    and rdx, -VMM_2MB_PAGE_SIZE
    cmp rdx, r14
    ja .small_region
    cmp r13, rdx
    jae .interior

.leading:
    cmp r13, rdx
    jae .interior
    mov rcx, [phys_map_base_val]
    add rcx, r13
    mov r8, r13
    mov r9, r15
    call vmm_map_4k_pml4
    test eax, eax
    jnz .fail
    add r13, PAGE_SIZE
    jmp .leading

.interior:
    ; Fully aligned 2 MiB interior.
    mov rax, r14
    and rax, -VMM_2MB_PAGE_SIZE
    mov rbx, rax

.huge_loop:
    cmp r13, rbx
    jae .trailing
    mov rcx, r12
    mov rdx, [phys_map_base_val]
    add rdx, r13
    mov r8, r13
    mov r9, r15
    call vmm_map_2mb_pml4
    test eax, eax
    jnz .fail
    add r13, VMM_2MB_PAGE_SIZE
    jmp .huge_loop

.trailing:
    cmp r13, r14
    jae .ok

.trailing_loop:
    mov rcx, [phys_map_base_val]
    add rcx, r13
    mov r8, r13
    mov r9, r15
    call vmm_map_4k_pml4
    test eax, eax
    jnz .fail
    add r13, PAGE_SIZE
    cmp r13, r14
    jb .trailing_loop
    jmp .ok

.small_region:
    mov r13, rax
.small_loop:
    cmp r13, r14
    jae .ok
    mov rcx, [phys_map_base_val]
    add rcx, r13
    mov r8, r13
    mov r9, r15
    call vmm_map_4k_pml4
    test eax, eax
    jnz .fail
    add r13, PAGE_SIZE
    jmp .small_loop

.ok:
    xor eax, eax
    jmp .done
.fail:
    mov eax, 1
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

hh_init:
    ; Build the HHDM in a bounded, deterministic way.
    ; The old implementation walked every EFI descriptor and mixed 4 KiB
    ; edge mappings with the 2 MiB mapper. That made the firmware->kernel
    ; transition fragile. The kernel only needs a valid direct-map window
    ; at this stage; the complete EFI-region policy can be layered on later.
    push rbx
    push r12
    push r13
    push r14
    push r15

    cmp byte [hh_active], 1
    je .ok

    ; 1 GiB initial HHDM window.
    mov rax, 0x40000000
    mov [hh_direct_map_limit_val], rax

    ; Allocate a fresh PML4.
    call pmm_alloc_page
    test rax, rax
    jz .fail

    mov r12, rax
    mov rcx, r12
    call zero_page

    ; Preserve the currently working kernel mappings.
    mov rsi, [pml4_ptr]
    test rsi, rsi
    jnz .copy_pml4

    mov rsi, cr3
    and rsi, -4096

.copy_pml4:
    mov rdi, r12
    mov rcx, 512
    rep movsq

    mov [hh_pml4_phys], r12

    ; Map physical 0..1 GiB at PHYS_MAP_BASE using 2 MiB pages.
    ; All addresses are aligned, so no 4 KiB fragment path is involved.
    xor r13, r13

.map_loop:
    cmp r13, 0x40000000
    jae .validate

    mov rcx, r12
    mov rdx, [phys_map_base_val]
    add rdx, r13
    mov r8, r13
    mov r9, HH_MAP_FLAGS

    call vmm_map_2mb_pml4
    test eax, eax
    jnz .fail

    add r13, VMM_2MB_PAGE_SIZE
    jmp .map_loop

.validate:
    ; Do not mark HHDM active here. CR3 activation is responsible for that.
    xor eax, eax
    jmp .done

.ok:
    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

hh_activate:
    mov rax, [hh_pml4_phys]
    test rax, rax
    jz .done

    and rax, -4096
    mov cr3, rax

.done:
    ret

hhvmm_test:
    push r12
    push r13
    push r14

    lea r9, [msg_hhvmm_v1]
    call draw_text

    call hh_init
    test eax, eax
    jnz .fail

    call hh_activate

    ; Allocate a page below 4GiB
    mov rcx, 0
    mov rdx, MM_FLAG_DMA32
    call pmm_alloc_order_flags
    test rax, rax
    jz .fail

    mov r12, rax

    mov r13, [phys_map_base_val]
    add r13, r12

    mov qword [r13], 0x0BADF00D
    cmp qword [r13], 0x0BADF00D
    jne .fail

    mov rcx, r12
    call phys_to_virt
    cmp rax, r13
    jne .fail

    mov rcx, r12
    mov rdx, 0
    call pmm_free_order_flags

    lea r9, [msg_hhvmm_ok]
    call draw_text

    pop r14
    pop r13
    pop r12
    ret

.fail:
    lea r9, [msg_hhvmm_fail]
    call draw_text

    pop r14
    pop r13
    pop r12
    ret

;================ HAL_UEFI =================

boot_allocate:
    push rbx
    push r12
    push r13
    push r14
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov r13, rcx
    mov r14, rdx

    mov rbx, [bs]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + BS_ALLOCATE_POOL]
    test rax, rax
    jz .fail

    mov ecx, EFI_LOADER_DATA
    mov rdx, r13
    mov r8, r14
    call rax

    test rax, rax
    jnz .fail

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    mov rsp, r12
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

boot_free:
    push rbx
    push r12
    push r13
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov r13, rcx

    mov rbx, [bs]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + BS_FREE_POOL]
    test rax, rax
    jz .fail

    mov rcx, r13
    call rax

    test rax, rax
    jnz .fail

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    mov rsp, r12
    pop r13
    pop r12
    pop rbx
    ret

boot_stall:
    push rbx
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rbx, [bs]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + BS_STALL]
    test rax, rax
    jz .fail

    call rax

    test rax, rax
    jnz .fail

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    mov rsp, r12
    pop r12
    pop rbx
    ret

boot_disable_watchdog:
    push rbx
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rbx, [bs]
    test rbx, rbx
    jz .done

    mov rax, [rbx + BS_SET_WATCHDOG_TIMER]
    test rax, rax
    jz .done

    xor ecx, ecx
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call rax

.done:
    xor eax, eax
    mov rsp, r12
    pop r12
    pop rbx
    ret

boot_video_init:
    push rbx
    push r12
    push r13
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rbx, [bs]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + BS_LOCATE_PROTOCOL]
    test rax, rax
    jz .fail

    lea rcx, [guid]
    xor edx, edx
    lea r8, [gop]
    call rax

    test rax, rax
    jnz .fail

    mov rbx, [gop]
    test rbx, rbx
    jz .fail

    mov rbx, [rbx + GOP_MODE]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + M_FB]
    test rax, rax
    jz .fail
    mov [video + Video.fb], rax

    mov r13, [rbx + M_INF]
    test r13, r13
    jz .fail

    mov eax, [r13 + I_HRES]
    test eax, eax
    jnz .hres_ok
    mov eax, 1
.hres_ok:
    mov [video + Video.w], rax

    mov eax, [r13 + I_VRES]
    test eax, eax
    jnz .vres_ok
    mov eax, 1
.vres_ok:
    mov [video + Video.h], rax

    mov eax, [r13 + I_SL]
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

    xor eax, eax

.done:
    mov rsp, r12
    pop r13
    pop r12
    pop rbx
    ret

.fail:
    mov eax, 1
    jmp .done

boot_prepare:
    push rbx
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rbx, rdx

    mov rax, [rbx + ST_CONIN_OFFSET]
    mov [conin], rax

    mov rax, [rbx + ST_BS]
    test rax, rax
    jz .fail
    mov [bs], rax

    call boot_disable_watchdog
    call boot_video_init

    test eax, eax
    jnz .fail

    xor eax, eax

.done:
    mov rsp, r12
    pop r12
    pop rbx
    ret

.fail:
    mov eax, 1
    jmp .done

boot_create_timer_event:
    push rbx
    push r12
    push r13
    mov r12, rsp
    and rsp, -16
    sub rsp, 48

    mov r13, rcx

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
    mov qword [rsp + 32], r13
    call rax

    test rax, rax
    jnz .fail

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    mov rsp, r12
    pop r13
    pop r12
    pop rbx
    ret

boot_set_timer:
    push rbx
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rbx, [bs]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + BS_SET_TIMER]
    test rax, rax
    jz .fail

    call rax

    test rax, rax
    jnz .fail

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    mov rsp, r12
    pop r12
    pop rbx
    ret

boot_wait_events:
    push rbx
    push r12
    mov r12, rsp
    and rsp, -16
    sub rsp, 32

    mov rbx, [bs]
    test rbx, rbx
    jz .fail

    mov rax, [rbx + BS_WAIT_FOR_EVENT]
    test rax, rax
    jz .fail

    call rax

    test rax, rax
    jnz .fail

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    mov rsp, r12
    pop r12
    pop rbx
    ret


boot_get_memory_map:
    push rbx
    push r12
    push r13
    push r14
    push r15
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
    mov rdx, [mm_tmp_size]
    add rdx, 16384
    mov [mm_tmp_size], rdx

    mov rcx, rdx
    lea rdx, [mm_tmp_buffer]
    call boot_allocate

    test rax, rax
    jnz .err_alloc

    mov rdx, [mm_tmp_buffer]
    test rdx, rdx
    jz .err_buf

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
    call boot_free

.retry_no_free:
    inc r14
    cmp r14, 8
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
    mov [boot_info + BootInfo.mem_desc_version], eax

    mov rsp, r12
    pop r15
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

.err_second:
    FAIL_CODE '8'

boot_exit:
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
    call boot_get_memory_map

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
    ; From this point onward the kernel must never call UEFI Boot Services.
    mov byte [exit_boot_services_done], 1
    cli

    mov rsp, r12
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

input_poll:
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

mmapi_test:
    push r12
    push r13

    lea r9, [msg_mmapi_v1]
    call draw_text

    mov rcx, PAGE_SIZE
    mov rdx, MM_FLAG_ZERO
    call mm_alloc_pages
    test rax, rax
    jz .fail
    mov r12, rax

    cmp byte [r12], 0
    jne .fail_free

    cmp byte [r12 + PAGE_SIZE - 1], 0
    jne .fail_free

    mov dword [r12], 0xDEADBEEF
    cmp dword [r12], 0xDEADBEEF
    jne .fail_free

    mov rcx, r12
    mov rdx, PAGE_SIZE
    call mm_free_pages

    mov rcx, 128
    mov rdx, MM_FLAG_ZERO
    call mm_kmem_alloc
    test rax, rax
    jz .fail
    mov r13, rax

    cmp byte [r13], 0
    jne .fail_kfree

    mov rcx, r13
    call mm_kmem_free

    mov rcx, 0x1000
    call mm_phys_to_virt
    mov r12, rax

    mov rcx, r12
    call mm_virt_to_phys
    cmp rax, 0x1000
    jne .fail

    pop r13
    pop r12

    lea r9, [msg_mmapi_ok]
    call draw_text
    ret

.fail_kfree:
    mov rcx, r13
    call mm_kmem_free

.fail_free:
    mov rcx, r12
    mov rdx, PAGE_SIZE
    call mm_free_pages

.fail:
    pop r13
    pop r12

    lea r9, [msg_mmapi_fail]
    call draw_text
    ret

test_all:
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    lea r9, [msg_testall_start]
    call draw_text

    mov r15, 0

    lea r9, [msg_test_pmm]
    call draw_text
    call pmm_alloc_page
    test rax, rax
    jz .fail
    mov r12, rax
    mov rcx, rax
    call pmm_free_page
    inc r15

    lea r9, [msg_test_vmm]
    call draw_text
    cmp byte [vmm_active], 1
    jne .skip_vmm
    mov rcx, 0x1000
    call vmm_translate
    test rax, rax
    jz .fail
    inc r15
.skip_vmm:

    lea r9, [msg_test_heap]
    call draw_text
    call kheap_init
    test eax, eax
    jnz .skip_heap
    mov rcx, 64
    call kmalloc
    test rax, rax
    jz .skip_heap
    mov r12, rax
    mov qword [r12], 0xCAFE
    cmp qword [r12], 0xCAFE
    jne .fail
    mov rcx, r12
    call kfree
    inc r15
.skip_heap:

    lea r9, [msg_test_mmapi]
    call draw_text
    mov rcx, PAGE_SIZE
    mov rdx, MM_FLAG_ZERO
    call mm_alloc_pages
    test rax, rax
    jz .fail
    mov r12, rax
    cmp byte [r12], 0
    jne .fail
    mov qword [r12], 0xBEEF
    cmp qword [r12], 0xBEEF
    jne .fail
    mov rcx, r12
    mov rdx, PAGE_SIZE
    call mm_free_pages
    inc r15

    lea r9, [msg_test_buddy]
    call draw_text
    mov rcx, 1
    call pmm_alloc_order
    test rax, rax
    jz .fail
    mov r12, rax
    mov qword [r12], 0x1234
    cmp qword [r12], 0x1234
    jne .fail
    mov rcx, r12
    mov rdx, 1
    call pmm_free_order
    inc r15

    lea r9, [msg_test_slab]
    call draw_text
    mov rcx, 64
    call slab_alloc
    test rax, rax
    jz .fail
    mov r12, rax
    mov byte [r12], 0xAA
    cmp byte [r12], 0xAA
    jne .fail
    mov rcx, 64
    mov rdx, r12
    call slab_free
    inc r15

    lea r9, [msg_test_phys]
    call draw_text
    mov rcx, 0x2000
    call mm_phys_to_virt
    mov r12, rax
    mov rcx, r12
    call mm_virt_to_phys
    cmp rax, 0x2000
    jne .fail
    inc r15

    lea r9, [msg_testall_done]
    call draw_text

    mov rcx, r15
    call print_hex64

    lea r9, [msg_testall_pass]
    call draw_text

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    ret

.fail:
    lea r9, [msg_testall_fail]
    call draw_text

    mov rcx, r15
    call print_hex64

    lea r9, [msg_testall_pass]
    call draw_text

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    ret

;================ CONTEXT SWITCH FOUNDATION =================

; void context_switch(Context *old, Context *next)
; rdi = old context, rsi = next context
; The current RET address stays on the old stack. Loading the new RSP and
; executing RET therefore resumes the destination context naturally.
context_switch:
    pushfq
    pop rax
    mov [rdi + CTX_RFLAGS], rax

    cli

    mov [rdi + CTX_RSP], rsp
    mov [rdi + CTX_RBX], rbx
    mov [rdi + CTX_RBP], rbp
    mov [rdi + CTX_R12], r12
    mov [rdi + CTX_R13], r13
    mov [rdi + CTX_R14], r14
    mov [rdi + CTX_R15], r15

    mov rsp, [rsi + CTX_RSP]
    mov rbx, [rsi + CTX_RBX]
    mov rbp, [rsi + CTX_RBP]
    mov r12, [rsi + CTX_R12]
    mov r13, [rsi + CTX_R13]
    mov r14, [rsi + CTX_R14]
    mov r15, [rsi + CTX_R15]

    mov rax, [rsi + CTX_RFLAGS]
    push rax
    popfq
    ret

; rdi = Context *, rsi = stack_top, rdx = entry
context_init:
    pushfq
    pop rax
    mov [rdi + CTX_RFLAGS], rax

    xor eax, eax
    mov [rdi + CTX_RBX], rax
    mov [rdi + CTX_RBP], rax
    mov [rdi + CTX_R12], rax
    mov [rdi + CTX_R13], rax
    mov [rdi + CTX_R14], rax
    mov [rdi + CTX_R15], rax

    mov rax, rsi
    and rax, -16
    sub rax, 8
    mov [rax], rdx
    mov [rdi + CTX_RSP], rax
    ret

context_switch_test:
    push r12
    push r13

    mov qword [ctx_test_entered], 0
    mov qword [ctx_test_resumed], 0
    mov qword [ctx_test_returned], 0

    lea rdi, [ctx_test]
    lea rsi, [ctx_test_stack_top]
    lea rdx, [context_test_thread]
    call context_init

    ; main -> fresh test context
    lea rdi, [ctx_main]
    lea rsi, [ctx_test]
    call context_switch

    cmp qword [ctx_test_entered], 1
    jne .fail
    cmp qword [ctx_test_returned], 1
    jne .fail

    ; main -> suspended test context
    lea rdi, [ctx_main]
    lea rsi, [ctx_test]
    call context_switch

    cmp qword [ctx_test_resumed], 1
    jne .fail
    cmp qword [ctx_test_returned], 2
    jne .fail

    lea r9, [msg_ctxtest_ok]
    call draw_text
    pop r13
    pop r12
    ret

.fail:
    lea r9, [msg_ctxtest_fail]
    call draw_text
    pop r13
    pop r12
    ret

context_test_thread:
    mov qword [ctx_test_entered], 1
    mov qword [ctx_test_returned], 1

    lea rdi, [ctx_test]
    lea rsi, [ctx_main]
    call context_switch

    ; Resume point: immediately after the first context_switch call.
    mov qword [ctx_test_resumed], 1
    mov qword [ctx_test_returned], 2

    lea rdi, [ctx_test]
    lea rsi, [ctx_main]
    call context_switch

.halt:
    cli
    hlt
    jmp .halt


;================ THREAD / SCHEDULER =================
; Thread descriptor layout:
;   0   id
;   8   state
;   16  flags
;   24  stack base
;   32  stack top
;   40  entry
;   48  argument
;   56  Context (64 bytes)
;   120 descriptor canary
;   128 magic
;   144 ready-queue next
;   152 ready-queue prev
;   160 all-thread next
;   168 all-thread prev
;
; Scheduler policy in this stage:
;   - intrusive doubly-linked ready queue
;   - intrusive all-thread list
;   - cooperative round-robin
;   - the current thread is RUNNING and normally not in ready queue
;   - scheduler_yield() requeues a live current thread
;   - scheduler_thread_exit() never returns and switches to the next ready
;     thread, or to scheduler_return_thread when the queue becomes empty.

;---------------- Ready queue primitives ----------------
; void ready_enqueue(Thread *t) ; rdi=t, returns eax=0 success / 1 reject
ready_enqueue:
    test rdi, rdi
    jz .fail
    cmp qword [rdi + TH_MAGIC], THREAD_MAGIC
    jne .fail
    cmp qword [rdi + TH_STATE], THREAD_STATE_READY
    jne .fail
    cmp qword [rdi + TH_NEXT], 0
    jne .fail
    cmp qword [rdi + TH_PREV], 0
    jne .fail

    mov rax, [ready_tail]
    test rax, rax
    jz .empty
    mov [rax + TH_NEXT], rdi
    mov [rdi + TH_PREV], rax
    mov qword [rdi + TH_NEXT], 0
    mov [ready_tail], rdi
    inc qword [ready_count]
    xor eax, eax
    ret
.empty:
    mov qword [rdi + TH_PREV], 0
    mov qword [rdi + TH_NEXT], 0
    mov [ready_head], rdi
    mov [ready_tail], rdi
    inc qword [ready_count]
    xor eax, eax
    ret
.fail:
    mov eax, 1
    ret

; Thread *ready_dequeue(void)
ready_dequeue:
    mov rax, [ready_head]
    test rax, rax
    jz .empty
    mov rdx, [rax + TH_NEXT]
    test rdx, rdx
    jz .last
    mov qword [rdx + TH_PREV], 0
    mov [ready_head], rdx
    mov qword [rax + TH_NEXT], 0
    mov qword [rax + TH_PREV], 0
    dec qword [ready_count]
    ret
.last:
    mov qword [ready_head], 0
    mov qword [ready_tail], 0
    mov qword [rax + TH_NEXT], 0
    mov qword [rax + TH_PREV], 0
    dec qword [ready_count]
    ret
.empty:
    xor eax, eax
    ret

; int ready_remove(Thread *t) ; 0 removed, 1 not queued/error
ready_remove:
    test rdi, rdi
    jz .fail
    mov rax, [rdi + TH_NEXT]
    mov rdx, [rdi + TH_PREV]
    test rdx, rdx
    jnz .have_prev
    cmp qword [ready_head], rdi
    jne .fail
    mov [ready_head], rax
    jmp .next
.have_prev:
    mov [rdx + TH_NEXT], rax
.next:
    test rax, rax
    jnz .have_next
    mov [ready_tail], rdx
    jmp .clear
.have_next:
    mov [rax + TH_PREV], rdx
.clear:
    mov qword [rdi + TH_NEXT], 0
    mov qword [rdi + TH_PREV], 0
    dec qword [ready_count]
    xor eax, eax
    ret
.fail:
    mov eax, 1
    ret

;---------------- All-thread list ----------------
all_thread_add:
    test rdi, rdi
    jz .fail
    mov rax, [all_thread_tail]
    test rax, rax
    jz .empty
    mov [rax + TH_ALL_NEXT], rdi
    mov [rdi + TH_ALL_PREV], rax
    mov qword [rdi + TH_ALL_NEXT], 0
    mov [all_thread_tail], rdi
    inc qword [all_thread_count]
    xor eax, eax
    ret
.empty:
    mov qword [rdi + TH_ALL_PREV], 0
    mov qword [rdi + TH_ALL_NEXT], 0
    mov [all_thread_head], rdi
    mov [all_thread_tail], rdi
    inc qword [all_thread_count]
    xor eax, eax
    ret
.fail:
    mov eax, 1
    ret

all_thread_remove:
    test rdi, rdi
    jz .fail
    mov rax, [rdi + TH_ALL_NEXT]
    mov rdx, [rdi + TH_ALL_PREV]
    test rdx, rdx
    jnz .have_prev
    cmp qword [all_thread_head], rdi
    jne .fail
    mov [all_thread_head], rax
    jmp .next
.have_prev:
    mov [rdx + TH_ALL_NEXT], rax
.next:
    test rax, rax
    jnz .have_next
    mov [all_thread_tail], rdx
    jmp .clear
.have_next:
    mov [rax + TH_ALL_PREV], rdx
.clear:
    mov qword [rdi + TH_ALL_NEXT], 0
    mov qword [rdi + TH_ALL_PREV], 0
    dec qword [all_thread_count]
    xor eax, eax
    ret
.fail:
    mov eax, 1
    ret

;---------------- Thread creation/destruction ----------------
; Thread *thread_create(void (*entry)(void *), void *arg)
thread_create:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    test rdi, rdi
    jz .fail
    mov r13, rdi
    mov r14, rsi

    mov rcx, TH_SIZE
    call kmalloc
    test rax, rax
    jz .fail
    mov r12, rax

    mov rdi, r12
    xor eax, eax
    mov rcx, TH_SIZE / 8
    rep stosq

    mov rax, [thread_next_id]
    test rax, rax
    jnz .id_ok
    mov rax, 1
.id_ok:
    mov [r12 + TH_ID], rax
    inc rax
    mov [thread_next_id], rax
    mov qword [r12 + TH_STATE], THREAD_STATE_READY
    mov qword [r12 + TH_FLAGS], 0
    mov [r12 + TH_ENTRY], r13
    mov [r12 + TH_ARG], r14
    mov qword [r12 + TH_CANARY], THREAD_CANARY
    mov qword [r12 + TH_MAGIC], THREAD_MAGIC

    mov rcx, THREAD_STACK_SIZE
    call kmalloc
    test rax, rax
    jz .free_thread
    mov r15, rax
    mov [r12 + TH_STACK_BASE], r15
    lea rbx, [r15 + THREAD_STACK_SIZE]
    mov [r12 + TH_STACK_TOP], rbx
    mov qword [r15], THREAD_CANARY

    lea rdi, [r12 + TH_CTX]
    mov rsi, rbx
    lea rdx, [thread_bootstrap]
    call context_init
    mov [r12 + TH_CTX + CTX_R12], r12

    mov rdi, r12
    call all_thread_add
    test eax, eax
    jnz .free_stack

    mov rdi, r12
    call ready_enqueue
    test eax, eax
    jnz .remove_all

    mov rax, r12
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.remove_all:
    mov rdi, r12
    call all_thread_remove
.free_stack:
    mov rcx, [r12 + TH_STACK_BASE]
    call kfree
.free_thread:
    mov rcx, r12
    call kfree
.fail:
    xor eax, eax
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; int thread_destroy(Thread *t)
thread_destroy:
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r12, rdi
    test r12, r12
    jz .fail
    cmp qword [r12 + TH_MAGIC], THREAD_MAGIC
    jne .fail
    test qword [r12 + TH_FLAGS], THREAD_FLAG_STATIC
    jnz .fail
    cmp qword [current_thread], r12
    je .fail

    mov rax, [r12 + TH_STATE]
    cmp rax, THREAD_STATE_RUNNING
    je .fail
    cmp rax, THREAD_STATE_READY
    je .remove_ready
    cmp rax, THREAD_STATE_DEAD
    je .state_ok
    jmp .fail

.remove_ready:
    mov rdi, r12
    call ready_remove
    test eax, eax
    jnz .fail
.state_ok:
    mov r13, [r12 + TH_STACK_BASE]
    test r13, r13
    jz .fail
    cmp qword [r12 + TH_CANARY], THREAD_CANARY
    jne .fail
    cmp qword [r13], THREAD_CANARY
    jne .fail

    mov rdi, r12
    call all_thread_remove
    test eax, eax
    jnz .fail

    mov qword [r12 + TH_MAGIC], 0
    mov qword [r12 + TH_STATE], THREAD_STATE_FREE
    mov qword [r12 + TH_CANARY], 0
    mov rcx, r13
    call kfree
    mov rcx, r12
    call kfree
    xor eax, eax
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    ret
.fail:
    mov eax, 1
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    ret

;---------------- Scheduler core ----------------
; Thread *scheduler_pick_next(void)
; Returns a READY thread, or scheduler_return_thread when the queue is empty.
scheduler_pick_next:
    call ready_dequeue
    test rax, rax
    jnz .found
    mov rax, [scheduler_return_thread]
    test rax, rax
    jz .none
    cmp qword [rax + TH_MAGIC], THREAD_MAGIC
    jne .none
.found:
    ret
.none:
    xor eax, eax
    ret

; Cooperative yield. Returns in the same thread after another thread has run.
scheduler_yield:
    mov r12, [current_thread]
    test r12, r12
    jz .restore_if
    cmp qword [r12 + TH_MAGIC], THREAD_MAGIC
    jne .restore_if
    cmp qword [r12 + TH_STATE], THREAD_STATE_RUNNING
    jne .restore_if

    ; The scheduler's return/main thread is not part of the worker ready queue.
    cmp r12, [scheduler_return_thread]
    je .pick_only

    mov qword [r12 + TH_STATE], THREAD_STATE_READY
    mov rdi, r12
    call ready_enqueue
    test eax, eax
    jnz .fatal

.pick_only:
    call scheduler_pick_next
    test rax, rax
    jz .no_next
    cmp rax, r12
    je .same

    mov r13, rax
    mov qword [r13 + TH_STATE], THREAD_STATE_RUNNING
    mov [current_thread], r13
    lea rdi, [r12 + TH_CTX]
    lea rsi, [r13 + TH_CTX]
    call context_switch
    ret
.same:
    mov qword [r12 + TH_STATE], THREAD_STATE_RUNNING
    mov [current_thread], r12
.restore_if:
    pushfq
    pop rax
    or rax, 0x200
    push rax
    popfq
    ret
.no_next:
    mov qword [r12 + TH_STATE], THREAD_STATE_RUNNING
    mov [current_thread], r12
    jmp .restore_if
.fatal:
    cli
.halt:
    hlt
    jmp .halt

; Current thread has returned from its entry point. Never returns.
scheduler_thread_exit:
    mov r12, [current_thread]
    test r12, r12
    jz .halt
    mov qword [r12 + TH_STATE], THREAD_STATE_DEAD

    call scheduler_pick_next
    test rax, rax
    jz .halt
    mov r13, rax
    mov qword [r13 + TH_STATE], THREAD_STATE_RUNNING
    mov [current_thread], r13
    lea rdi, [r12 + TH_CTX]
    lea rsi, [r13 + TH_CTX]
    call context_switch
.halt:
    cli
    hlt
    jmp .halt

thread_bootstrap:
    mov r12, [current_thread]
    test r12, r12
    jz .fault
    cmp qword [r12 + TH_MAGIC], THREAD_MAGIC
    jne .fault
    mov qword [r12 + TH_STATE], THREAD_STATE_RUNNING
    mov rdi, [r12 + TH_ARG]
    call [r12 + TH_ENTRY]
    jmp scheduler_thread_exit
.fault:
    cli
    hlt
    jmp .fault

;---------------- Scheduler test ----------------
; Three workers each run SCHED_TEST_ROUNDS times. The main shell context is
; temporarily registered as scheduler_return_thread, but is never enqueued.
scheduler_test:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    lea rdi, [scheduler_test_main]
    call scheduler_main_init
    mov qword [scheduler_test_total], 0
    mov qword [scheduler_test_fail], 0
    mov qword [scheduler_test_counts + 0], 0
    mov qword [scheduler_test_counts + 8], 0
    mov qword [scheduler_test_counts + 16], 0

    lea rdi, [scheduler_test_worker]
    lea rsi, [scheduler_test_args + 0]
    call thread_create
    test rax, rax
    jz .fail
    mov [scheduler_test_threads + 0], rax

    lea rdi, [scheduler_test_worker]
    lea rsi, [scheduler_test_args + 8]
    call thread_create
    test rax, rax
    jz .cleanup1
    mov [scheduler_test_threads + 8], rax

    lea rdi, [scheduler_test_worker]
    lea rsi, [scheduler_test_args + 16]
    call thread_create
    test rax, rax
    jz .cleanup2
    mov [scheduler_test_threads + 16], rax

    ; Main -> first worker. Main is deliberately excluded from the queue.
    call scheduler_start

    cmp qword [scheduler_test_total], SCHED_MAX_TEST_THREADS * SCHED_TEST_ROUNDS
    jne .cleanup3
    cmp qword [scheduler_test_counts + 0], SCHED_TEST_ROUNDS
    jne .cleanup3
    cmp qword [scheduler_test_counts + 8], SCHED_TEST_ROUNDS
    jne .cleanup3
    cmp qword [scheduler_test_counts + 16], SCHED_TEST_ROUNDS
    jne .cleanup3
    cmp qword [ready_count], 0
    jne .cleanup3
    cmp qword [all_thread_count], SCHED_MAX_TEST_THREADS
    jne .cleanup3

    mov r12, [scheduler_test_threads + 0]
    mov rdi, r12
    call thread_destroy
    test eax, eax
    jnz .cleanup_fail
    mov r12, [scheduler_test_threads + 8]
    mov rdi, r12
    call thread_destroy
    test eax, eax
    jnz .cleanup_fail
    mov r12, [scheduler_test_threads + 16]
    mov rdi, r12
    call thread_destroy
    test eax, eax
    jnz .cleanup_fail
    cmp qword [all_thread_count], 0
    jne .cleanup_fail

    lea r9, [msg_schedtest_ok]
    call draw_text
    xor eax, eax
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.cleanup3:
    mov rdi, [scheduler_test_threads + 0]
    call thread_destroy
    mov rdi, [scheduler_test_threads + 8]
    call thread_destroy
    mov rdi, [scheduler_test_threads + 16]
    call thread_destroy
    jmp .fail
.cleanup2:
    mov rdi, [scheduler_test_threads + 0]
    call thread_destroy
    mov rdi, [scheduler_test_threads + 8]
    call thread_destroy
    jmp .fail
.cleanup1:
    mov rdi, [scheduler_test_threads + 0]
    call thread_destroy
.fail:
    lea r9, [msg_schedtest_fail]
    call draw_text
    mov eax, 1
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.cleanup_fail:
    jmp .fail

scheduler_main_init:
    ; rdi = static main-thread descriptor
    mov qword [rdi + TH_ID], 0
    mov qword [rdi + TH_STATE], THREAD_STATE_RUNNING
    mov qword [rdi + TH_FLAGS], THREAD_FLAG_STATIC
    mov qword [rdi + TH_STACK_BASE], 0
    mov qword [rdi + TH_STACK_TOP], 0
    mov qword [rdi + TH_ENTRY], 0
    mov qword [rdi + TH_ARG], 0
    mov qword [rdi + TH_CANARY], THREAD_CANARY
    mov qword [rdi + TH_MAGIC], THREAD_MAGIC
    mov qword [rdi + TH_NEXT], 0
    mov qword [rdi + TH_PREV], 0
    mov qword [rdi + TH_ALL_NEXT], 0
    mov qword [rdi + TH_ALL_PREV], 0
    mov [current_thread], rdi
    mov [scheduler_return_thread], rdi
    ret

scheduler_start:
    ; current_thread is the shell/main context. Pick a worker and switch to it.
    mov r12, [current_thread]
    call scheduler_pick_next
    test rax, rax
    jz .done
    mov r13, rax
    mov qword [r13 + TH_STATE], THREAD_STATE_RUNNING
    mov [current_thread], r13
    lea rdi, [r12 + TH_CTX]
    lea rsi, [r13 + TH_CTX]
    call context_switch
.done:
    ret

scheduler_test_worker:
    ; rdi points to a qword worker index: 0,1,2
    mov r12, rdi
    mov r13, [r12]
    lea r14, [scheduler_test_counts]
    lea r14, [r14 + r13 * 8]
.loop:
    inc qword [r14]
    inc qword [scheduler_test_total]
    call scheduler_yield
    cmp qword [r14], SCHED_TEST_ROUNDS
    jb .loop
    ret

;---------------- Compatibility lifecycle test ----------------
thread_lifecycle_test:
    push r12
    push r13
    sub rsp, 8
    mov qword [thread_test_entered], 0
    lea rdi, [thread_test_entry]
    xor esi, esi
    call thread_create
    test rax, rax
    jz .fail
    mov r12, rax
    cmp qword [r12 + TH_STATE], THREAD_STATE_READY
    jne .destroy_a_fail
    cmp qword [r12 + TH_MAGIC], THREAD_MAGIC
    jne .destroy_a_fail
    cmp qword [r12 + TH_CANARY], THREAD_CANARY
    jne .destroy_a_fail
    mov rdi, r12
    call thread_destroy
    test eax, eax
    jnz .fail
    lea r9, [msg_threadtest_ok]
    call draw_text
    xor eax, eax
    add rsp, 8
    pop r13
    pop r12
    ret
.destroy_a_fail:
    mov rdi, r12
    call thread_destroy
.fail:
    lea r9, [msg_threadtest_fail]
    call draw_text
    mov eax, 1
    add rsp, 8
    pop r13
    pop r12
    ret

thread_test_entry:
    mov qword [thread_test_entered], 1
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

    lea rsi, [str_cmd_pmmstress]
    call cmd_is
    test eax, eax
    jnz .pmmstress

    lea rsi, [str_cmd_vmmstress]
    call cmd_is
    test eax, eax
    jnz .vmmstress

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

    lea rsi, [str_cmd_kmemtest]
    call cmd_is
    test eax, eax
    jnz .kmemtest

    lea rsi, [str_cmd_mmflags]
    call cmd_is
    test eax, eax
    jnz .mmflags

    lea rsi, [str_cmd_buddytest]
    call cmd_is
    test eax, eax
    jnz .buddytest

    lea rsi, [str_cmd_buddyarena]
    call cmd_is
    test eax, eax
    jnz .buddyarena

    lea rsi, [str_cmd_buddystress]
    call cmd_is
    test eax, eax
    jnz .buddystress

    lea rsi, [str_cmd_bpmm]
    call cmd_is
    test eax, eax
    jnz .bpmm

    lea rsi, [str_cmd_zonetest]
    call cmd_is
    test eax, eax
    jnz .zonetest

    lea rsi, [str_cmd_slabtest]
    call cmd_is
    test eax, eax
    jnz .slabtest

    lea rsi, [str_cmd_hhvmm]
    call cmd_is
    test eax, eax
    jnz .hhvmm

    lea rsi, [str_cmd_mmapi]
    call cmd_is
    test eax, eax
    jnz .mmapi

    lea rsi, [str_cmd_ctxtest]
    call cmd_is
    test eax, eax
    jnz .ctxtest

    lea rsi, [str_cmd_threadtest]
    call cmd_is
    test eax, eax
    jnz .threadtest

    lea rsi, [str_cmd_schedtest]
    call cmd_is
    test eax, eax
    jnz .schedtest

    lea rsi, [str_cmd_timer]
    call cmd_is
    test eax, eax
    jnz .timer

    lea rsi, [str_cmd_testall]
    call cmd_is
    test eax, eax
    jnz .testall

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

.pmmstress:
    call pmm_stress_test
    ret

.vmmstress:
    call vmm_stress_test
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

.kmemtest:
    call kmem_test
    ret

.mmflags:
    call mm_flags_test
    ret

.buddytest:
    call buddy_test
    ret

.buddyarena:
    call buddy_arena_test
    ret

.buddystress:
    call buddy_stress_test
    ret

.bpmm:
    call buddy_pmm_test
    ret

.zonetest:
    call zonetest
    ret

.slabtest:
    call slabtest
    ret

.hhvmm:
    call hhvmm_test
    ret

.mmapi:
    call mmapi_test
    ret

.ctxtest:
    call context_switch_test
    ret

.threadtest:
    call thread_lifecycle_test
    ret

.schedtest:
    call scheduler_test
    ret

.timer:
    lea r9, [msg_timer_header]
    call draw_text
    lea r9, [str_timer_state]
    call draw_text
    cmp byte [lapic_timer_started], 1
    jne .timer_stopped
    lea r9, [str_timer_running]
    call draw_text
    jmp .timer_state_done
.timer_stopped:
    lea r9, [str_timer_stopped]
    call draw_text
.timer_state_done:
    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_timer_ticks]
    call draw_text
    mov rcx, [lapic_timer_ticks]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_timer_uptime]
    call draw_text
    mov rcx, [timer_uptime_ms]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_timer_ticks_ms]
    call draw_text
    mov rcx, [lapic_ticks_per_ms]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_timer_initial]
    call draw_text
    mov ecx, [lapic_initial_count]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc

    lea r9, [str_timer_spurious]
    call draw_text
    mov rcx, [lapic_spurious_count]
    call print_hex64
    mov r9b, CHAR_LF
    call console_putc
    ret

.testall:
    call test_all
    ret

.exit:
    cmp byte [kernel_mode], 1
    je .exit_kernel
    jmp exit_boot_services_sequence

.exit_kernel:
    lea r9, [msg_exit_unavailable]
    call draw_text
    ret

.done:
    ret

exit_boot_services_sequence:
    ; Everything that touches UEFI state is completed before the one-way
    ; transition.  In particular, do NOT call draw_text/console/UEFI after
    ; ExitBootServices succeeds.
    call cursor_erase

    lea r9, [msg_exitbs]
    call draw_text

    lea r9, [msg_exitbs_transfer]
    call draw_text

    lea rsi, [s_exitbs]
    call serial_puts

    call exit_boot_services

    ; ExitBootServices may reclaim the firmware-owned stack.  Do NOT execute
    ; any CALL/PUSH/POP on that stack after the successful transition.
    ; Switch to our kernel-owned stack immediately, before even emitting the
    ; first post-ExitBootServices debug marker.
    lea rsp, [kernel_stack_top]
    and rsp, -16

    ; From this instruction onward we are native kernel code.
    mov byte [kernel_mode], 1
    mov byte [kernel_stage], 1
    mov al, 'K'
    call debug_stage
    jmp kernel_entry

.kernel_transfer_unreachable:
    cli
    hlt
    jmp .kernel_transfer_unreachable

;================ LOCAL APIC / TIMER =================

; Mask the legacy 8259 PIC.  The kernel uses the Local APIC from this point
; onward, while the keyboard remains polled until a real input driver exists.
pic_mask_all:
    mov al, 0xFF
    out 0x21, al
    out 0xA1, al
    ret

; Read IA32_APIC_BASE and force legacy xAPIC mode.  x2APIC is deliberately
; disabled for this first APIC implementation because the timer is accessed
; through the LAPIC MMIO page.
apic_detect:
    push rbx

    mov eax, 1
    cpuid
    test edx, (1 << 9)          ; CPUID.01H:EDX.APIC
    jz .unsupported

    mov ecx, MSR_APIC_BASE
    rdmsr

    and eax, 0xFFFFF000
    mov ebx, eax

    ; Keep the APIC enabled and leave x2APIC mode disabled.
    mov ecx, MSR_APIC_BASE
    rdmsr
    and eax, ~(APIC_BASE_X2APIC)
    or eax, APIC_BASE_ENABLE
    wrmsr

    mov eax, ebx
    mov [lapic_phys_base], rax
    mov byte [lapic_supported], 1
    xor eax, eax
    pop rbx
    ret

.unsupported:
    mov byte [lapic_supported], 0
    mov eax, 1
    pop rbx
    ret

; Calibrate the Local APIC timer against PIT channel 2.
; PIT channel 2 is used only as a short reference clock. The LAPIC timer
; remains masked until lapic_timer_start so startup tests cannot lose ticks.
lapic_timer_calibrate:
    push rbx
    push r12
    push r13
    push r14

    ; Save speaker/PIT control state.
    in al, 0x61
    mov r14b, al

    mov rbx, [lapic_virt_base]
    test rbx, rbx
    jz .fail_restore

    ; LAPIC divide = 16, free-running countdown during calibration.
    mov dword [rbx + LAPIC_TIMER_DIV], LAPIC_TIMER_DIV_16
    mov dword [rbx + LAPIC_LVT_TIMER], LAPIC_LVT_MASKED
    mov dword [rbx + LAPIC_TIMER_INIT], 0xFFFFFFFF

    ; PIT channel 2, mode 0, lobyte/hibyte, binary.
    mov al, r14b
    and al, 0xFC
    or al, 0x01
    out 0x61, al

    mov al, 0xB0
    out 0x43, al
    mov ax, PIT_CALIBRATION_DIV       ; 59659 ~= 50 ms
    out 0x42, al
    mov al, ah
    out 0x42, al

    ; Timeout prevents a dead PIT from hanging the kernel forever.
    mov r12, 0x20000000
.wait_pit:
    in al, 0x61
    test al, 0x20
    jnz .pit_done
    dec r12
    jnz .wait_pit
    jmp .fail_restore

.pit_done:
    mov r13d, dword [rbx + LAPIC_TIMER_CUR]
    mov eax, 0xFFFFFFFF
    sub eax, r13d
    test eax, eax
    jz .fail_restore

    xor edx, edx
    mov ecx, LAPIC_CALIBRATION_MS
    div ecx                         ; LAPIC ticks per millisecond
    test eax, eax
    jz .fail_restore
    mov [lapic_ticks_per_ms], rax

    ; Compute the 1 ms periodic initial count.
    mov rdx, rax
    imul rdx, APIC_TIMER_PERIOD_MS
    test rdx, rdx
    jz .fail_restore
    mov rcx, 0x100000000
    cmp rdx, rcx
    jae .fail_restore
    mov [lapic_initial_count], edx

    mov dword [rbx + LAPIC_TIMER_INIT], 0
    mov al, r14b
    out 0x61, al

    xor eax, eax
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.fail_restore:
    mov rax, [lapic_virt_base]
    test rax, rax
    jz .restore_only
    mov dword [rax + LAPIC_TIMER_INIT], 0
.restore_only:
    mov al, r14b
    out 0x61, al
    pop r14
    pop r13
    pop r12
    pop rbx
    mov eax, 1
    ret

; Start the calibrated periodic timer. This is deliberately separate from
; initialization: IF stays clear until all kernel startup/self-tests finish.
lapic_timer_start:
    push rbx
    mov rbx, [lapic_virt_base]
    test rbx, rbx
    jz .fail
    mov eax, [lapic_initial_count]
    test eax, eax
    jz .fail

    mov dword [rbx + LAPIC_ESR], 0
    mov dword [rbx + LAPIC_EOI], 0
    mov dword [rbx + LAPIC_TPR], 0

    ; Vector 32, periodic, unmasked.
    mov eax, LAPIC_TIMER_VECTOR | LAPIC_LVT_PERIODIC
    mov dword [rbx + LAPIC_LVT_TIMER], eax
    mov eax, [lapic_initial_count]
    mov dword [rbx + LAPIC_TIMER_INIT], eax

    mov byte [lapic_timer_started], 1
    mov qword [lapic_timer_ticks], 0
    mov qword [timer_uptime_ms], 0
    mov qword [last_cursor_tick], 0
    mov al, 'S'
    call debug_stage

    pop rbx
    xor eax, eax
    ret
.fail:
    pop rbx
    mov eax, 1
    ret

lapic_timer_stop:
    push rbx
    mov rbx, [lapic_virt_base]
    test rbx, rbx
    jz .done
    mov dword [rbx + LAPIC_LVT_TIMER], LAPIC_LVT_MASKED
    mov dword [rbx + LAPIC_TIMER_INIT], 0
    mov byte [lapic_timer_started], 0
.done:
    pop rbx
    ret

; Timer IRQ hot path: keep it tiny for future scheduler use.
lapic_timer_irq:
    inc qword [lapic_timer_ticks]
    inc qword [timer_uptime_ms]
    mov rax, [lapic_virt_base]
    test rax, rax
    jz .done
    mov dword [rax + LAPIC_EOI], 0
.done:
    ret

; Complete Local APIC + timer initialization. Timer remains masked until
; lapic_timer_start is called immediately before STI.
apic_timer_init:
    push rbx
    push r12

    call apic_detect
    test eax, eax
    jnz .fail_detect
    mov al, 'D'
    call debug_stage

    ; Disable legacy 8259 delivery before any LAPIC IRQ can be exposed.
    call pic_mask_all

    ; Map LAPIC MMIO through the existing identity map, uncached.
    mov rdx, [lapic_phys_base]
    mov rcx, rdx
    mov r8, PAGE_WRITABLE | PAGE_CACHE_DISABLE | PAGE_GLOBAL
    call vmm_map_4k
    test eax, eax
    jnz .fail_map
    mov al, 'M'
    call debug_stage

    mov rax, [lapic_phys_base]
    mov [lapic_virt_base], rax
    mov rbx, rax

    mov dword [rbx + LAPIC_TPR], 0
    mov eax, LAPIC_SVR_ENABLE | 0xFF
    mov dword [rbx + LAPIC_SVR], eax
    mov dword [rbx + LAPIC_LVT_TIMER], LAPIC_LVT_MASKED
    mov dword [rbx + LAPIC_EOI], 0
    mov al, 'E'
    call debug_stage

    mov eax, dword [rbx + LAPIC_ID]
    mov [lapic_id], rax

    call lapic_timer_calibrate
    test eax, eax
    jnz .fail_calibrate

    mov qword [lapic_timer_ticks], 0
    mov qword [timer_uptime_ms], 0
    mov qword [last_cursor_tick], 0
    mov byte [lapic_timer_ready], 1
    mov byte [lapic_timer_started], 0

    mov al, 'T'
    call debug_stage
    pop r12
    pop rbx
    xor eax, eax
    ret

.fail_detect:
    mov al, 'd'
    call debug_stage
    jmp .fail
.fail_map:
    mov al, 'm'
    call debug_stage
    jmp .fail
.fail_calibrate:
    mov al, 'c'
    call debug_stage
.fail:
    mov byte [lapic_timer_ready], 0
    mov byte [lapic_timer_started], 0
    pop r12
    pop rbx
    mov eax, 1
    ret

kernel_entry:
    cli

    ; Do not touch the firmware console here.  The first kernel instructions
    ; use only our own stack, serial/debug I/O and the already-built identity
    ; mappings.
    mov byte [kernel_stage], 2
    mov al, 'G'
    call debug_stage

    lea rsp, [kernel_stack_top]
    and rsp, -16

    lea rsi, [s_kern_gdt]
    call serial_puts
    call gdt_init

    mov byte [kernel_stage], 3
    mov al, 'T'
    call debug_stage
    lea rsi, [s_kern_tss]
    call serial_puts
    call tss_init

    mov byte [kernel_stage], 4
    mov al, 'I'
    call debug_stage
    lea rsi, [s_kern_idt]
    call serial_puts
    call idt_init_full

    mov byte [kernel_stage], 5
    mov al, 'V'
    call debug_stage
    lea rsi, [s_kern_vmm]
    call serial_puts
    call vmm_activate
    mov byte [vmm_active], 1

    ; Build a new kernel PML4 by copying the known-good identity map and
    ; adding the RAM direct map.  Never continue silently if construction
    ; fails.
    mov byte [kernel_stage], 6
    mov al, 'H'
    call debug_stage
    lea rsi, [s_kern_hh_init]
    call serial_puts
    call hh_init
    test eax, eax
    jnz .hh_fail

    lea rsi, [s_kern_hh_ready]
    call serial_puts

    mov byte [kernel_stage], 7
    mov al, 'C'
    call debug_stage
    lea rsi, [s_kern_hh_cr3]
    call serial_puts
    call hh_activate

    mov rax, [hh_pml4_phys]
    test rax, rax
    jz .hh_fail
    mov rcx, cr3
    and rcx, -4096
    cmp rcx, rax
    jne .hh_fail

    mov [pml4_ptr], rax
    mov byte [vmm_active], 1
    mov byte [hh_active], 1
    mov byte [kernel_stage], 8
    mov al, 'h'
    call debug_stage

    ; Stage 07: Local APIC + periodic timer.  Keep interrupts disabled until
    ; the complete LAPIC/IDT state is installed and validated.
    mov byte [kernel_stage], 9
    mov al, 'A'
    call debug_stage
    lea rsi, [s_kern_apic]
    call serial_puts
    call apic_timer_init
    test eax, eax
    jnz .apic_fail

    lea rsi, [s_kern_apic_ready]
    call serial_puts

    lea rsi, [s_kern_console]
    call serial_puts
    call console_clear

    jmp .kernel_console_ready

.apic_fail:
    mov al, 'A'
    call debug_stage
    lea rsi, [s_kern_apic_fail]
    call serial_puts
    cli
.apic_halt:
    hlt
    jmp .apic_halt

.hh_fail:
    mov al, '!'
    call debug_stage
    lea rsi, [s_kern_hh_fail]
    call serial_puts
    cli
.hh_halt:
    hlt
    jmp .hh_halt

.kernel_console_ready:

    ; Start the kernel shell with a clean command state.
    mov qword [cmd_len], 0
    lea rdi, [cmd_buf]
    xor eax, eax
    mov ecx, CMD_MAX
    rep stosb

    lea r9, [msg_kernel_banner]
    call draw_text

    ; The boot self-tests are intentionally shown BEFORE the READY line.
    ; This keeps the kernel startup screen in chronological order.
    lea r9, [msg_kernel_init]
    call draw_text

    mov byte [kernel_selftest_failures], 0

    call kernel_core_selftest
    call kernel_arch_selftest
    call pmm_stress_test
    call vmm_stress_test

    cmp byte [kernel_selftest_failures], 0
    jne .kernel_degraded
    lea r9, [msg_kernel_ready]
    call draw_text
    jmp .kernel_ready_done

.kernel_degraded:
    lea r9, [msg_kernel_degraded]
    call draw_text

.kernel_ready_done:

    call cursor_draw
    mov dword [blink_counter], 0

    ; Hardware interrupts are now safe: vector 32 is owned by the LAPIC timer
    ; and the legacy PIC is fully masked.
    cmp byte [lapic_timer_ready], 1
    jne .kernel_loop
    call lapic_timer_start
    test eax, eax
    jnz .apic_fail
    sti

.kernel_loop:
    call ps2_keyboard_read
    test al, al
    jz .no_key

    call process_key
    call cursor_draw

    mov dword [blink_counter], 0
    jmp .kernel_loop

.no_key:
    ; With IF=1, HLT is the real kernel idle primitive. LAPIC timer IRQs
    ; wake the CPU every millisecond, so PS/2 polling remains responsive.
    cmp byte [lapic_timer_started], 1
    jne .legacy_idle
    hlt

    ; Timer IRQ only updates lapic_timer_ticks. Blink is handled here,
    ; outside the interrupt handler, using the original solid cursor.
    mov rax, [lapic_timer_ticks]
    mov rcx, [last_cursor_tick]
    sub rax, rcx
    cmp rax, CURSOR_BLINK_MS
    jb .kernel_loop

    mov rax, [lapic_timer_ticks]
    mov [last_cursor_tick], rax
    call cursor_toggle
    jmp .kernel_loop

.legacy_idle:
    call stall_1ms_kernel
    jmp .kernel_loop

;================ CORE ARCHITECTURE SELFTEST =================

; Validate the five milestones that form the firmware -> native-kernel
; boundary. Every green line below is backed by a concrete runtime check.
kernel_core_selftest:
    push rbx
    push r12

    ; 1) UEFI HAL / BootInfo contract.
    cmp byte [hal_uefi_ready], 1
    jne .hal_fail
    cmp qword [boot_info + BootInfo.fb], 0
    je .hal_fail
    cmp qword [boot_info + BootInfo.mem_map], 0
    je .hal_fail
    lea r9, [msg_hal_ok]
    call draw_text
    jmp .memory_check
.hal_fail:
    inc byte [kernel_selftest_failures]
    lea r9, [msg_hal_fail]
    call draw_text

.memory_check:
    ; 2) Unified memory manager: PMM metadata must be live and VMM active.
    cmp byte [memory_manager_ready], 1
    jne .mm_fail
    cmp byte [vmm_active], 1
    jne .mm_fail
    cmp qword [boot_info + BootInfo.pmm_free_pages], 0
    je .mm_fail
    lea r9, [msg_mm_ok]
    call draw_text
    jmp .hhdm_check
.mm_fail:
    inc byte [kernel_selftest_failures]
    lea r9, [msg_mm_fail]
    call draw_text

.hhdm_check:
    ; 3) Higher-half direct map must have its own PML4 and active flag.
    cmp byte [hh_active], 1
    jne .hhdm_fail
    cmp qword [hh_pml4_phys], 0
    je .hhdm_fail
    cmp qword [phys_map_base_val], 0
    je .hhdm_fail

    ; Verify a real allocated RAM frame through the active direct map. This
    ; avoids treating an unmapped physical hole at address 0 as a failure.
    call pmm_alloc_page
    test rax, rax
    jz .hhdm_fail_free_none
    mov r12, rax

    mov rcx, r12
    call phys_to_virt
    mov rbx, rax

    mov rcx, rbx
    call vmm_translate
    test rax, rax
    jz .hhdm_fail_free
    cmp rax, r12
    jne .hhdm_fail_free

    mov rcx, r12
    call pmm_free_page

    mov byte [hh_verified], 1
    lea r9, [msg_hhdm_ok]
    call draw_text
    jmp .exitbs_check

.hhdm_fail_free:
    mov rcx, r12
    call pmm_free_page
.hhdm_fail_free_none:
.hhdm_fail:
    inc byte [kernel_selftest_failures]
    lea r9, [msg_hhdm_fail]
    call draw_text

.exitbs_check:
    ; 4) ExitBootServices is a one-way state transition. The flag is set
    ; only by the canonical exit_boot_services success path.
    cmp byte [exit_boot_services_done], 1
    jne .exitbs_fail
    lea r9, [msg_exitbs_state_ok]
    call draw_text
    jmp .done
.exitbs_fail:
    inc byte [kernel_selftest_failures]
    lea r9, [msg_exitbs_state_fail]
    call draw_text

.done:
    pop r12
    pop rbx
    ret

;================ KERNEL FOUNDATION SELFTEST =================

kernel_arch_selftest:
    push rbx
    push r12
    sub rsp, 8

    ; Check the GDT loaded by the CPU.
    sgdt [selftest_gdtr]
    movzx eax, word [selftest_gdtr]
    cmp eax, 0x2F
    jb .fail
    mov rax, [selftest_gdtr + 2]
    lea rbx, [gdt]
    cmp rax, rbx
    jne .fail

    ; Check current code segment.
    xor eax, eax
    mov ax, cs
    cmp ax, 0x08
    jne .fail

    ; Check TSS is loaded with our TSS selector.
    str ax
    cmp ax, 0x28
    jne .fail

    ; Verify the TSS descriptor resolves to our actual TSS object.
    mov rax, [gdt + 0x28]
    mov rdx, rax
    shr rdx, 16
    and edx, 0xFFFFFF
    mov rcx, rax
    shr rcx, 56
    shl rcx, 24
    or rdx, rcx
    mov rcx, [gdt + 0x30]
    and rcx, 0xFFFFFFFF
    shl rcx, 32
    or rdx, rcx
    lea rbx, [tss]
    cmp rdx, rbx
    jne .fail

    ; Check IDT is installed, points at our table, and has live handlers for
    ; the architecturally critical vectors.
    sidt [selftest_idtr]
    movzx eax, word [selftest_idtr]
    cmp eax, (256 * 16) - 1
    jne .fail
    mov rax, [selftest_idtr + 2]
    lea rbx, [idt]
    cmp rax, rbx
    jne .fail

    movzx eax, word [idt + 14*16]
    test eax, eax
    jz .fail
    movzx eax, word [idt + 8*16]
    test eax, eax
    jz .fail
    movzx eax, word [idt + 2*16]
    test eax, eax
    jz .fail

    ; Check CR3 and VMM state.
    mov rax, cr3
    and rax, -4096
    test rax, rax
    jz .fail
    cmp byte [vmm_active], 1
    jne .fail
    cmp qword [hh_pml4_phys], 0
    je .fail
    cmp rax, [hh_pml4_phys]
    jne .fail

    lea r9, [msg_arch_ok]
    call draw_text
    jmp .done

.fail:
    inc byte [kernel_selftest_failures]
    lea r9, [msg_arch_fail]
    call draw_text

.done:
    add rsp, 8
    pop r12
    pop rbx
    ret

;================ PMM STRESS TEST =================

pmm_stress_test:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    xor r12d, r12d                 ; allocated count
    xor r13d, r13d                 ; index

.alloc_loop:
    cmp r13d, PMM_STRESS_COUNT
    jae .verify

    call pmm_alloc_page
    test rax, rax
    jz .fail

    mov [pmm_stress_ptrs + r13*8], rax
    mov r14, rax
    mov r15, r13
    shl r15, 32
    mov eax, 0x54524553             ; low 32-bit deterministic marker
    or r15, rax
    mov [r14], r15

    inc r13
    inc r12
    jmp .alloc_loop

.verify:
    xor r13d, r13d

.verify_loop:
    cmp r13d, PMM_STRESS_COUNT
    jae .free_all

    mov r14, [pmm_stress_ptrs + r13*8]
    test r14, r14
    jz .fail

    mov r15, r13
    shl r15, 32
    mov eax, 0x54524553
    or r15, rax
    cmp [r14], r15
    jne .fail

    inc r13
    jmp .verify_loop

.free_all:
    xor r13d, r13d

.free_loop:
    cmp r13d, PMM_STRESS_COUNT
    jae .pass

    mov rcx, [pmm_stress_ptrs + r13*8]
    test rcx, rcx
    jz .next_free
    call pmm_free_page
    mov qword [pmm_stress_ptrs + r13*8], 0

.next_free:
    inc r13
    jmp .free_loop

.fail:
    ; Release everything allocated so far. This path is deliberately conservative.
    xor r13d, r13d
.cleanup_loop:
    cmp r13d, PMM_STRESS_COUNT
    jae .report_fail
    mov rcx, [pmm_stress_ptrs + r13*8]
    test rcx, rcx
    jz .cleanup_next
    call pmm_free_page
    mov qword [pmm_stress_ptrs + r13*8], 0
.cleanup_next:
    inc r13
    jmp .cleanup_loop

.report_fail:
    inc byte [kernel_selftest_failures]
    lea r9, [msg_pmm_stress_fail]
    call draw_text
    jmp .done

.pass:
    lea r9, [msg_pmm_stress_ok]
    call draw_text

.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

;================ VMM STRESS TEST =================

vmm_stress_test:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    cmp byte [vmm_active], 1
    jne .inactive

    xor r13d, r13d

.map_loop:
    cmp r13d, VMM_STRESS_COUNT
    jae .verify

    call pmm_alloc_page
    test rax, rax
    jz .fail_cleanup

    mov [vmm_stress_ptrs + r13*8], rax
    mov r14, rax
    mov rcx, rax
    call zero_page

    mov rcx, VMM_STRESS_BASE
    mov rax, r13
    shl rax, PAGE_SHIFT
    add rcx, rax
    mov rdx, r14
    mov r8, PAGE_WRITABLE
    call vmm_map_4k
    test eax, eax
    jnz .fail_cleanup

    mov rcx, VMM_STRESS_BASE
    mov rax, r13
    shl rax, PAGE_SHIFT
    add rcx, rax
    mov rax, r13
    shl rax, 32
    mov edx, 0x54524553
    or rax, rdx
    mov [rcx], rax

    inc r13
    jmp .map_loop

.verify:
    xor r13d, r13d

.verify_loop:
    cmp r13d, VMM_STRESS_COUNT
    jae .unmap

    mov rcx, VMM_STRESS_BASE
    mov rax, r13
    shl rax, PAGE_SHIFT
    add rcx, rax
    mov r14, r13
    shl r14, 32
    mov eax, 0x54524553
    or r14, rax
    cmp [rcx], r14
    jne .fail_cleanup

    mov rcx, VMM_STRESS_BASE
    mov rax, r13
    shl rax, PAGE_SHIFT
    add rcx, rax
    call vmm_translate
    test rax, rax
    jz .fail_cleanup

    inc r13
    jmp .verify_loop

.unmap:
    xor r13d, r13d

.unmap_loop:
    cmp r13d, VMM_STRESS_COUNT
    jae .pass

    mov rcx, VMM_STRESS_BASE
    mov rax, r13
    shl rax, PAGE_SHIFT
    add rcx, rax
    call vmm_unmap_4k

    mov rcx, [vmm_stress_ptrs + r13*8]
    call pmm_free_page
    mov qword [vmm_stress_ptrs + r13*8], 0

    inc r13
    jmp .unmap_loop

.fail_cleanup:
    xor r13d, r13d
.cleanup_loop:
    cmp r13d, VMM_STRESS_COUNT
    jae .report_fail

    mov rcx, VMM_STRESS_BASE
    mov rax, r13
    shl rax, PAGE_SHIFT
    add rcx, rax
    call vmm_unmap_4k

    mov rcx, [vmm_stress_ptrs + r13*8]
    test rcx, rcx
    jz .cleanup_next
    call pmm_free_page
    mov qword [vmm_stress_ptrs + r13*8], 0
.cleanup_next:
    inc r13
    jmp .cleanup_loop

.report_fail:
    inc byte [kernel_selftest_failures]
    lea r9, [msg_vmm_stress_fail]
    call draw_text
    jmp .done

.pass:
    lea r9, [msg_vmm_stress_ok]
    call draw_text
    jmp .done

.inactive:
    lea r9, [msg_vmm_stress_inactive]

.done:
    cmp byte [vmm_active], 1
    jne .print_inactive
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.print_inactive:
    call draw_text
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

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
    call boot_get_memory_map

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
    ; ExitBootServices succeeded. This is the canonical state transition.
    ; The kernel self-test consumes this flag after control reaches kernel_entry.
    mov byte [exit_boot_services_done], 1
    cli

    mov rsp, r12
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
    
stall_1ms_kernel:
    push rcx
    mov rcx, 0x10000
.delay:
    nop
    loop .delay
    pop rcx
    ret
 
ps2_keyboard_read:
    in al, 0x64
    test al, 1
    jz .nokey

    in al, 0x60

    cmp al, 0xE0
    je .nokey

    test al, 0x80
    jnz .nokey

    cmp al, 0x0E
    je .backspace

    cmp al, 0x1C
    je .enter

    cmp al, 0x39
    je .space

    cmp al, 0x0F
    je .tab

    cmp al, 0x02
    jb .nokey

    cmp al, 0x58
    ja .nokey

    ; AL contains the Set-1 scancode. Do NOT use RAX directly as the
    ; table index: IN AL only updates AL and leaves the upper RAX bits
    ; unchanged. A stale upper RAX would address the wrong memory.
    movzx edx, al
    movzx eax, byte [ps2_scancode_table + rdx]
    test al, al
    jz .nokey

    ret

.backspace:
    mov eax, KEY_BACKSPACE
    ret

.enter:
    mov eax, KEY_ENTER
    ret

.space:
    mov eax, KEY_SPACE
    ret

.tab:
    mov eax, CHAR_TAB
    ret

.nokey:
    xor eax, eax
    ret
       
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

; Native-kernel Local APIC state.
lapic_supported:
    db 0
lapic_timer_ready:
    db 0
lapic_timer_started:
    db 0

align 8
lapic_phys_base:
    dq 0
lapic_virt_base:
    dq 0
lapic_id:
    dq 0
lapic_ticks_per_ms:
    dq 0
lapic_initial_count:
    dd 0
align 8
lapic_timer_ticks:
    dq 0
timer_uptime_ms:
    dq 0
lapic_spurious_count:
    dq 0
last_cursor_tick:
    dq 0

cursor_shown:
    db 0

; Saved framebuffer pixels underneath the cursor.
; 9 * 10 pixels * 4 bytes = 360 bytes.
align 16
cursor_saved:
    times (CHAR_W * CHAR_H) dd 0

align 4
blink_counter:
    dd 0

vmm_active:
    db 0

kernel_selftest_failures:
    db 0

;================ CORE ARCHITECTURE STATE ===================
; These flags describe the hand-off from firmware to the native kernel.
hal_uefi_ready:
    db 0

memory_manager_ready:
    db 0

exit_boot_services_done:
    db 0

kernel_mode:
kernel_stage:
    db 0

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

    at BootInfo.mem_map_copy,      dq 0
    at BootInfo.mem_map_copy_size, dq 0

    at BootInfo.pmm_bitmap,        dq 0
    at BootInfo.pmm_total_pages,   dq 0
    at BootInfo.pmm_free_pages,    dq 0
iend

align 8
mm_region_count:
    dq 0

align 8
mm_regions:
    times (MM_REGION_MAX * 24) db 0

align 8
pmm_total_pages_actual:
    dq 0

align 8
pmm_reserved_count:
    dq 0

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

msg_hal_ok:
    db "  [ OK ] UEFI HAL / BootInfo",10,0

msg_hal_fail:
    db "  [FAIL] UEFI HAL / BootInfo",10,0

msg_mm_ok:
    db "  [ OK ] Unified Memory Manager",10,0

msg_mm_fail:
    db "  [FAIL] Unified Memory Manager",10,0

msg_hhdm_ok:
    db "  [ OK ] Higher-Half / Direct Map active",10,0

msg_hhdm_fail:
    db "  [FAIL] Higher-Half / Direct Map",10,0

msg_exitbs_state_ok:
    db "  [ OK ] ExitBootServices boundary",10,0

msg_exitbs_state_fail:
    db "  [FAIL] ExitBootServices boundary",10,0

msg_arch_ok:
    db "  [ OK ] GDT / IDT / TSS / CR3",10,0

msg_arch_fail:
    db "  [FAIL] GDT / IDT / TSS / CR3",10,0

msg_pmm_stress_ok:
    db "  [ OK ] PMM : 32-page allocation / verify / free",10,0

msg_pmm_stress_fail:
    db "  [FAIL] PMM : stress test",10,0

msg_vmm_stress_ok:
    db "  [ OK ] VMM : 16 mappings / verify / unmap",10,0

msg_vmm_stress_fail:
    db "  [FAIL] VMM : stress test",10,0

msg_vmm_stress_inactive:
    db "  [SKIP] VMM : inactive",10,0

msg_kernel_init:
    db 10,"---------------- KERNEL INITIALIZING ----------------",10,0

msg_kernel_ready:
    db 10,"---------------- KERNEL READY ----------------",10,0

msg_kernel_degraded:
    db 10,"------------ KERNEL READY (DEGRADED) ---------",10
    db "One or more boot self-tests failed.",10,0

msg_exit_unavailable:
    db "exit: unavailable after Boot Services termination",10,0

msg_shell_hint:
    db "Type 'help' for commands.",10,0

msg_exitbs:
    db "Exiting Boot Services...",10,0

msg_exitbs_ok:
    db "[ OK ] UEFI Boot Services terminated",10,0
msg_exitbs_transfer:
    db "[ OK ] Transferring control to kernel...",10,0

s_kern_gdt:
    db "[KERN] gdt_init",10,0
s_kern_tss:
    db "[KERN] tss_init",10,0
s_kern_idt:
    db "[KERN] idt_init",10,0
s_kern_vmm:
    db "[KERN] vmm_activate",10,0
s_kern_hh_init:
    db "[KERN] hh_init",10,0
s_kern_hh_cr3:
    db "[KERN] hh_activate/cr3",10,0
s_kern_hh_ready:
    db "[KERN] higher-half RAM map built",10,0
s_kern_hh_fail:
    db "[KERN PANIC] higher-half address-space activation failed",10,0
s_kern_console:
    db "[KERN] console",10,0
s_kern_apic:
    db "[KERN] apic_timer_init",10,0
s_kern_apic_ready:
    db "[KERN] Local APIC + timer ready",10,0
s_kern_apic_fail:
    db "[KERN PANIC] Local APIC / timer initialization failed",10,0

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

str_cmd_pmmstress:
    db "pmmstress",0

str_cmd_vmmstress:
    db "vmmstress",0

str_cmd_timer:
    db "timer",0

str_cmd_exit:
    db "exit",0

msg_help:
    db "Commands:",10
    db "  help        - show this help",10
    db "  clear       - clear screen",10
    db "  mem         - memory info",10
    db "  vmm         - vmm status",10
    db "  detect      - system info",10
    db "  serial      - serial test",10
    db "  test        - run all tests",10
    db "  pmmtest     - test PMM allocator",10
    db "  vmmtest     - test VMM mapping",10
    db "  pmmstress   - stress-test physical memory",10
    db "  vmmstress   - stress-test virtual memory",10
    db "  highmap     - map physical memory to higher-half",10
    db "  heap        - initialize/show kernel heap",10
    db "  heaptest    - test kernel heap",10
    db "  kmemtest    - test kmem API",10
    db "  mmflags     - test MM allocation flags",10
    db "  buddytest   - test buddy foundation",10
    db "  buddyarena  - test real buddy arena",10
    db "  buddystress - stress buddy allocator",10
    db "  bpmm        - test Buddy PMM",10
    db "  zonetest    - test Zones/DMA",10
    db "  slabtest    - test Slab allocator",10
    db "  hhvmm       - test Higher-Half VMM",10
    db "  mmapi       - test MM API",10
    db "  ctxtest     - test cooperative context switching",10
    db "  threadtest  - test Thread create/destroy/lifecycle",10
    db "  schedtest    - test cooperative round-robin scheduler",10
    db "  timer       - show Local APIC timer state",10
    db "  exit        - exit boot services",10
    db 0

msg_timer_header:
    db "Local APIC Timer:",10,0
str_timer_state:
    db "  state: ",0
str_timer_running:
    db "RUNNING",0
str_timer_stopped:
    db "STOPPED",0
str_timer_ticks:
    db "  ticks: 0x",0
str_timer_uptime:
    db "  uptime_ms: 0x",0
str_timer_ticks_ms:
    db "  lapic_ticks_per_ms: 0x",0
str_timer_initial:
    db "  initial_count: 0x",0
str_timer_spurious:
    db "  spurious_irqs: 0x",0

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

s_exitbs_ok:
    db "ExitBootServices: success",13,10,0

hex_digits:
    db "0123456789ABCDEF"

str_panic_banner:
    db "!!! EXCEPTION !!!",10,0

str_vector:
    db "Vector: 0x",0

str_error:
    db 10,"Error : 0x",0

str_cr2:
    db "CR2       : 0x",0

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

str_cmd_kmemtest:
    db "kmemtest",0

msg_kmemtest_ok:
    db "Kmem test: OK",10,0

msg_kmemtest_fail:
    db "Kmem test: FAIL",10,0

str_cmd_mmflags:
    db "mmflags",0

msg_mmflags_ok:
    db "MM flags: OK",10,0

msg_mmflags_fail:
    db "MM flags: FAIL",10,0

align 8
pmm_order_counts:
    times (PMM_ORDER_MAX + 1) dq 0

pmm_order_cache:
    times ((PMM_ORDER_MAX + 1) * PMM_ORDER_CACHE_MAX) dq 0

str_cmd_buddytest:
    db "buddytest",0

msg_buddytest_ok:
    db "Buddy test: OK",10,0

msg_buddytest_fail:
    db "Buddy test: FAIL",10,0

buddy_arena_active:
    db 0

buddy_arena_base:
    dq 0

buddy_arena_order:
    dq 0

buddy_arena_from_pmm:
    db 0

align 8
buddy_fallback_alloc:
    dq 0

align 8
buddy_fallback_base:
    dq 0

align 8
buddy_free_heads:
    times (BUDDY_ARENA_ORDER_MAX + 1) dq 0

str_cmd_buddyarena:
    db "buddyarena",0

msg_buddyarena_ok:
    db "Buddy arena: OK",10,0

msg_buddyarena_fail:
    db "Buddy arena: FAIL",10,0

msg_buddyarena_fail_init:
    db "Buddy arena fail: init",10,0

msg_buddyarena_fail_alloc1:
    db "Buddy arena fail: alloc1",10,0

msg_buddyarena_fail_alloc2:
    db "Buddy arena fail: alloc2",10,0

msg_buddyarena_fail_write:
    db "Buddy arena fail: write/read",10,0

msg_buddyarena_fail_merge_alloc:
    db "Buddy arena fail: merge alloc order2",10,0

msg_buddyarena_v2:
    db "Buddy arena test v2",10,0

msg_buddyarena_v3:
    db "Buddy arena test v3",10,0

msg_buddy_pmm:
    db "Buddy arena: PMM order 0x",0

msg_buddy_static:
    db "Buddy arena: static",10,0

str_cmd_buddystress:
    db "buddystress",0

msg_buddystress_v1:
    db "Buddy stress test",10,0

msg_buddystress_ok:
    db "Buddy stress: OK",10,0

msg_buddystress_fail:
    db "Buddy stress: FAIL",10,0

str_cmd_bpmm:
    db "bpmm",0

msg_bpmm_v1:
    db "Buddy PMM test",10,0

msg_bpmm_ok:
    db "Buddy PMM: OK",10,0

msg_bpmm_fail:
    db "Buddy PMM: FAIL",10,0

buddy_pmm_active:
    db 0

buddy_pmm_pool_phys:
    dq 0

align 8
buddy_pmm_heads:
    times (BUDDY_PMM_ORDER + 1) dq 0

align 16
buddy_pmm_pool_raw:
    times (2 * BUDDY_PMM_BLOCK_SIZE) db 0

str_cmd_zonetest:
    db "zonetest",0

msg_zonetest_v1:
    db "Zones/DMA test",10,0

msg_zonetest_ok:
    db "Zones/DMA: OK",10,0

msg_zonetest_fail:
    db "Zones/DMA: FAIL",10,0

slab_sizes:
    dq 16, 32, 64, 128, 256, 512, 1024, 2048

slab_free_heads:
    times SLAB_CACHE_COUNT dq 0

slab_test_ptrs:
    times SLAB_TEST_COUNT dq 0

str_cmd_slabtest:
    db "slabtest",0

msg_slabtest_v1:
    db "Slab allocator test",10,0

msg_slabtest_ok:
    db "Slab allocator: OK",10,0

msg_slabtest_fail:
    db "Slab allocator: FAIL",10,0

hh_active:
    db 0
hh_verified:
    db 0

hh_pml4_phys:
    dq 0

str_cmd_hhvmm:
    db "hhvmm",0

msg_hhvmm_v1:
    db "Higher-Half VMM test",10,0

msg_hhvmm_ok:
    db "Higher-Half VMM: OK",10,0

msg_hhvmm_fail:
    db "Higher-Half VMM: FAIL",10,0

align 8
phys_map_base_val:
    dq PHYS_MAP_BASE

hh_direct_map_limit_val:
    dq HH_DIRECT_MAP_LIMIT

zone_dma_limit_val:
    dq ZONE_DMA_LIMIT

zone_dma32_limit_val:
    dq ZONE_DMA32_LIMIT

str_cmd_mmapi:
    db "mmapi",0

str_cmd_ctxtest:
    db "ctxtest",0

str_cmd_threadtest:
    db "threadtest",0

str_cmd_schedtest:
    db "schedtest",0

msg_mmapi_v1:
    db "MM API test",10,0

msg_mmapi_ok:
    db "MM API: OK",10,0

msg_ctxtest_ok:
    db "Context switch: OK (fresh + resume)",10,0
msg_threadtest_ok:
    db "Thread test: CREATE/DESTROY/LIFECYCLE OK",10,0
msg_threadtest_fail:
    db "Thread test: FAIL",10,0
msg_schedtest_ok:
    db "Scheduler: ROUND-ROBIN OK",10,0
msg_schedtest_fail:
    db "Scheduler: FAIL",10,0
msg_ctxtest_fail:
    db "Context switch: FAIL",10,0

msg_mmapi_fail:
    db "MM API: FAIL",10,0

str_cmd_testall:
    db "test",0

msg_testall_start:
    db "Running all tests...",10,0

msg_test_pmm:
    db "  PMM alloc/free...",10,0

msg_test_vmm:
    db "  VMM translate...",10,0

msg_test_heap:
    db "  Heap alloc/free...",10,0

msg_test_mmapi:
    db "  MM API...",10,0

msg_test_buddy:
    db "  Buddy order...",10,0

msg_test_slab:
    db "  Slab alloc/free...",10,0

msg_test_phys:
    db "  Phys/Virt...",10,0

msg_testall_done:
    db "Tests done. Passed: 0x",0

msg_testall_pass:
    db " ",10,0

msg_testall_fail:
    db "FAILED at test 0x",0

ps2_scancode_table:
    db 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x08, 0x09
    db 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x0A, 0, 'a', 's'
    db 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 0x27, '`', 0, 0x5C, 'z', 'x', 'c', 'v'
    db 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, '7', '8', '9', '-', '4', '5', '6', '+', '1'
    db '2', '3', '0', '.', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

msg_kernel_banner:
    db "===============================================================",10
    db "                     0xDEAD OPERATING SYSTEM",10
    db "                         KERNEL MODE",10,10
    db "---------------------------------------------------------------",10,10
    db "                    KERNEL INITIALIZING",10,10,0

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
align 8
thread_next_id:
    dq 1
current_thread:
    dq 0
ready_head:
    dq 0
ready_tail:
    dq 0
ready_count:
    dq 0
all_thread_head:
    dq 0
all_thread_tail:
    dq 0
all_thread_count:
    dq 0
scheduler_return_thread:
    dq 0

thread_test_entered:
    dq 0

scheduler_test_main:
    times TH_SIZE db 0

scheduler_test_threads:
    times SCHED_MAX_TEST_THREADS dq 0
scheduler_test_args:
    dq 0, 1, 2
scheduler_test_counts:
    times SCHED_MAX_TEST_THREADS dq 0
scheduler_test_total:
    dq 0
scheduler_test_fail:
    dq 0

align 16
ctx_main:
    times CTX_SIZE db 0

align 16
ctx_test:
    times CTX_SIZE db 0

align 4096
ctx_test_stack_bottom:
    times THREAD_STACK_SIZE db 0
ctx_test_stack_top:

align 8
ctx_test_entered:
    dq 0
ctx_test_resumed:
    dq 0
ctx_test_returned:
    dq 0

align 16
gdt:
    dq 0x0000000000000000
    dq 0x00209A0000000000
    dq 0x0000920000000000
    dq 0x0020FA0000000000
    dq 0x0000F20000000000
    dq 0x0000000000000000
    dq 0x0000000000000000
gdt_end:

align 16
gdt_ptr:
    dw gdt_end - gdt - 1
    dq gdt

align 16
tss:
    dd 0
    dq kernel_stack_top
    dq 0
    dq 0
    dq 0
    dq ist_stack_top
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dd 0
    dw 0
    dw 104
tss_end:

align 4096
kernel_stack_bottom:
    times 4096 db 0
kernel_stack_top:

align 4096
ist_stack_bottom:
    times 4096 db 0
ist_stack_top:
align 16
idt:
    times 256 * 16 db 0

align 16
new_idtr_limit:
    dw (256 * 16) - 1
new_idtr_base:
    dq 0

align 16
selftest_idtr:
    dw 0
    dq 0

selftest_gdtr:
    dw 0
    dq 0

align 8
pmm_stress_ptrs:
    times PMM_STRESS_COUNT dq 0

align 8
vmm_stress_ptrs:
    times VMM_STRESS_COUNT dq 0

old_idtr_limit:
    dw 0
old_idtr_base:
    dq 0

align 4096
pmm_bitmap:
    times PMM_BITMAP_SIZE db 0

align 16
buddy_static_pool:
    times (2 * BUDDY_STATIC_BLOCK_SIZE) db 0

