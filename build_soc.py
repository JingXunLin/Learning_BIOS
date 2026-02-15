#!/usr/bin/env python3

from litex_boards.targets import microphase_a7_lite
from litex.soc.integration.soc import SoCRegion
from litex.soc.integration.builder import Builder

import argparse
import sys

# Override the build/load arguments to just do what we want
# We use a custom BIOS (our bare metal code)
# integrated_rom_size=32768 (32KB is plenty for hand-written assembly)

def main():
    parser = argparse.ArgumentParser(description="Bare Metal Learning SoC")
    parser.add_argument("--build", action="store_true", help="Build bitstream")
    parser.add_argument("--load", action="store_true", help="Load bitstream")
    parser.add_argument("--flash", action="store_true", help="Flash bitstream")
    
    # Standard LiteX arguments
    args = parser.parse_args()

    # Create the SoC
    # We insist on 'vexriscv'
    # We specify 'integrated_rom_size' which will be our code space
    # We set 'bios_flash_offset' to None to prevent it looking for flash boot
    # CRITICAL: We pass compile_software=False so LiteX doesn't build its own BIOS
    
    # Init ROM with our firmware.bin
    firmware_data = []
    try:
        with open("firmware.bin", "rb") as f:
            while True:
                w = f.read(4)
                if not w: break
                # Little Endian 轉換
                W = int.from_bytes(w, byteorder='little')
                firmware_data.append(W)
        print(f"[*] Loaded {len(firmware_data)*4} bytes from firmware.bin")
    except:
        print("[!] firmware.bin not found! generating empty ROM")
        firmware_data = []

    soc = microphase_a7_lite.BaseSoC(
        sys_clk_freq=50e6,
        cpu_type="vexriscv",
        cpu_variant="standard", # Simple variant
        integrated_rom_size=0x8000, # 32KB for our code
        integrated_sram_size=0x2000, # 8KB scratchpad
        integrated_rom_init=firmware_data, # Load our binary
        with_led_chaser = False, # Disable default LED chaser
    )
    
    # Manually add GPIO LEDs if Chaser is disabled
    # Check if leds are already present (some SoCs add them differently)
    if not hasattr(soc, "leds"):
        from litex.soc.cores.gpio import GPIOOut
        print("[*] Adding GPIO LEDs manually")
        soc.submodules.leds = GPIOOut(soc.platform.request_all("user_led"))
        soc.add_csr("leds")

    # We will manually specify the BIOS binary file to bake into the ROM
    # This file must exist when we run --build
    soc.add_constant("ROM_BOOT_ADDRESS", 0x00000000)
    
    # This tells LiteX to use our binary as the init content for the ROM block
    soc.mem_regions["rom"].init = [] # Clear default if any
    
    # To use a custom file, we often rely on the builder to handle "bios" argument
    # But since we want "No BIOS logic" from LiteX, we want it to just burn our hex file.
    
    builder = Builder(soc, output_dir="build", compile_software=False, compile_gateware=True)
    
    # If we are building, we expect 'firmware.bin' to be ready
    if args.build:
        print("[*] Configuring ROM to load 'firmware.mem'")
        # LiteX allows passing initial contents for memory regions
        # We will do a trick: we will let the builder run, but we will patch the memory init if needed
        # Actually, simpler: Use 'bios' argument in Builder? 
        # No, Builder(bios=...) expects a full BIOS structure.
        
        # Simplest way: The 'cpu_reset_address' is 0x00000000 (ROM).
        # We will modify the generated Verilog or .init file? 
        # No, LiteX supports 'kwargs["integrated_rom_init"]' in SoC init.
        pass

    # Re-instantiate with init file if available
    # For now, let's just build the standard hardware. 
    # We will use 'litex_term --kernel' to upload code to RAM for testing phase 1
    # OR we can update the BRAM.
    
    builder.build(run=args.build)

    if args.load:
        prog = soc.platform.create_programmer()
        prog.load_bitstream("build/gateware/microphase_a7_lite.bit")

if __name__ == "__main__":
    main()
