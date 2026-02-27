.section .text.init     # 程式碼
.globl _start

_start:
    li zero, 0x0
    # 把.text段搬去RAM
    la t0, _stext_lma               
    la t1, _stext_vma
    la t2, _etext_lma
    jal ra, move_section
    # 把.data段搬去RAM
    la t0, _sdata_lma               
    la t1, _sdata_vma
    la t2, _edata_lma
    jal ra, move_section
    # 清空.bss段的vma
    la t0, _sbss_vma               
    la t1, _ebss_vma
_clear_bss_loop:
    bge t0, t1, _clear_bss_done
    sw zero, 0(t0)
    addi t0, t0, 4
    blt t0, t1, _clear_bss_loop
_clear_bss_done:

    li sp, 0x60000000               # 設定stack top 為 RAM的頂端
    la t0, main                     # 從ROM到RAM太遠，不能用jal
    jalr ra, t0                     # 跳入C語言
_guard_loop:
    jal ra, _guard_loop             # 避免main函數return回來，雖然不應該

move_section:
    # t0 = LMA, t1 = VMA, t2 = LMA_end
    bge t0, t2, move_done  # 如果 LMA >= LMA_end，直接結束，先檢查避免 LMA == LMA_end
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j move_section
move_done:
    ret