# Компиляторы и инструменты
CC      = i686-elf-gcc
AS      = nasm
LD      = i686-elf-ld
MKDIR   = mkdir -p
CP      = cp
RM      = rm -rf
GRUBMKRESCUE = grub-mkrescue

# Флаги компиляции C
CFLAGS  = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -g \
          -Iinclude -Ikernel -Ikernel/fs -Ikernel/api \
          -fno-builtin

# Флаги для NASM
ASFLAGS = -f elf32 -g

# Флаги линковки
LDFLAGS = -T linker.ld -nostdlib

# Каталоги
KERNEL_DIR    = kernel
BUILD_DIR     = build
ISO_DIR       = iso
BOOT_GRUB_DIR = $(ISO_DIR)/boot/grub
GRUB_CFG      = boot/grub/grub.cfg
KERNEL_BIN    = kernel.bin
ISO_FILE      = uturu.iso

# Автоматический поиск исходников
C_SOURCES   = $(shell find $(KERNEL_DIR) -name '*.c')
ASM_SOURCES = $(shell find $(KERNEL_DIR) -name '*.asm')

# Преобразование путей в объектные файлы внутри build/
C_OBJECTS   = $(patsubst $(KERNEL_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))
ASM_OBJECTS = $(patsubst $(KERNEL_DIR)/%.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
OBJECTS     = $(C_OBJECTS) $(ASM_OBJECTS)

# Цель по умолчанию
all: $(ISO_FILE)

# Правило для C-файлов
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Правило для ASM-файлов
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.asm
	@$(MKDIR) $(dir $@)
	$(AS) $(ASFLAGS) $< -o $@

# Линковка ядра
$(KERNEL_BIN): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

# Создание ISO-образа
$(ISO_FILE): $(KERNEL_BIN) $(GRUB_CFG)
	@$(MKDIR) $(BOOT_GRUB_DIR)
	$(CP) $(KERNEL_BIN) $(ISO_DIR)/boot/
	$(CP) $(GRUB_CFG) $(BOOT_GRUB_DIR)/
	$(GRUBMKRESCUE) -o $(ISO_FILE) $(ISO_DIR)

# Запуск в QEMU
run: $(ISO_FILE)
	qemu-system-i386 -cdrom $(ISO_FILE)

# Запуск с отладкой (ожидание подключения GDB)
debug: $(ISO_FILE)
	qemu-system-i386 -cdrom $(ISO_FILE) -s -S

# Очистка всех артефактов сборки
clean:
	$(RM) $(BUILD_DIR) $(ISO_DIR) $(KERNEL_BIN) $(ISO_FILE)

.PHONY: all run debug clean