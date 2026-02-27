RISCV_PREFIX = riscv64-unknown-elf-
CC = $(RISCV_PREFIX)gcc
OBJCOPY = $(RISCV_PREFIX)objcopy
OBJDUMP = $(RISCV_PREFIX)objdump

# No Standard Libs, No Startup files, pure code
CFLAGS = -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding

all: firmware.bin firmware.mem

firmware.elf: src/start.S src/main.c
	$(CC) $(CFLAGS) -T linker.ld src/start.S src/main.c -o firmware.elf

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary firmware.elf firmware.bin

firmware.mem: firmware.bin
	# Convert binary to hex/mem format for Verilog init (simple version)
	python3 -c "import sys; print('\n'.join(['{:02x}'.format(b) for b in open('firmware.bin', 'rb').read()]))" > firmware.mem

clean:
	rm -f firmware.elf firmware.bin firmware.mem
