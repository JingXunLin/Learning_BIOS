.section .data     # 已初始化資料
    count:   .long 10;   # 初始化一個32-bit integer
.section .bss      # 未初始化資料，需清0
    .lcomm buffer, 16;  # 宣告一個16 byte的buffer
.section .text     # 程式碼
.globl _start

_start:
    li zero, 0x0
    li t1, 0x1                      # 設定要亮的LED
    li t2, 0x0                      # counter
    li t3, 5000000                  # 延遲cycke數量
    li t0, 0xf0000000               # leds_out的地址

_main_loop:
    sw t1, 0(t0)                    # 寫入LED

_delay_loop:                        # 重複 t2 次，才往下走
    addi t2, t2, 0x1
    bne t2, t3, _delay_loop
    
    xori t1, t1, 0x3                # 1變2，2變1
    li t2, 0x0                      # 重置counter
    
    jal ra, _main_loop              # 重複主迴圈

