void uart_putchar(char c) {
    volatile int *uart_txfull = (volatile int *)0xf0004804;
    while(*uart_txfull);        // 檢查發送緩衝區（FIFO）滿了沒，1是滿，要等到變成0
    volatile int *uart_rxtx = (volatile int *)0xf0004800;

    // 如果輸入是換行符號，先自動送出一個「回車」
    if (c == '\n') {
        while(*uart_txfull);
        *uart_rxtx = '\r';
    }
    *uart_rxtx = c;             // 把字元寫給UART
}
void uart_puts(const char *s) {
    while (*s) {
        uart_putchar(*s++);
    }
}
void uart_put_digit(int n) {
    if (n >= 0 && n <= 9) {
        uart_putchar(n + '0'); // '0' 的 ASCII 是 48，所以 0+48=48('0'), 1+48=49('1')...
    }
}
void uart_put_hex(unsigned int n) {
    const char *hex_chars = "0123456789ABCDEF";
    uart_puts("0x");
    // 從高位元往低位元處理 (32-bit 為例，每 4 bits 是一格 hex)
    for (int i = 28; i >= 0; i -= 4) {
        uart_putchar(hex_chars[(n >> i) & 0xF]);
    }
}
unsigned int test_bss;
void main(void) {
    const char *s = "Hello World\n";
    uart_puts(s);
    uart_put_hex(test_bss);
}