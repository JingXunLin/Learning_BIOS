void main(void) {
    volatile int *leds = (volatile int *)0xf0000000;
    int write_bit = 1;
    while(1) {
        volatile int i;
        for(i=0; i<5000000; i++);   // delay 5000000 cycles
        *leds = write_bit;                   // write into LED
        write_bit ^= 3;             // 1、2交換
    }
}