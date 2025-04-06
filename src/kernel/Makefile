BUILD_DIR?=build/
ASM?=nasm
CC16?=/usr/bin/watcom/bin1/wcc
LD16?=/usr/bin/watcom/bin1/wlink
.PHONY: all kernel clean

all: kernel

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin:
	$(ASM) main.asm -f bin -o $(BUILD_DIR)/kernel.bin

clean:
	rm -rf $(BUILD_DIR)/kernel.bin