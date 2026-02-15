.section .data     # 已初始化資料
    count:   .long 10;   # 初始化一個32-bit integer
.section .bss      # 未初始化資料，需清0
    .lcomm buffer, 16;  # 宣告一個16 byte的buffer
.section .text     # 程式碼
.globl _start

_start:
    li zero, 0x0
    li t1, 0x1                      # 設定要亮的LED
    li t0, 0xf0000000               # leds_out的地址

    li sp, 0x10002000               # 設定stack top 為 SRAM的頂端
    jal ra, main                    # 跳入C語言
_guard_loop:
    jal ra, _guard_loop             # 避免main函數return回來，雖然不應該

