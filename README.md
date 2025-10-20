; Uturu OS - 16-bit Operating System
; Copyright (C) 2025 Semyon5700
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
# Uturu OS

16-bit x86 Operating System

## Description

Uturu OS is a from-scratch 16-bit operating system written entirely in x86 assembly language. This project represents a complete operating system implementation including custom bootloader, kernel, and basic system utilities.

## Features

- Custom 512-byte bootloader
- Monolithic kernel architecture
- Command-line interface
- Real-time clock support
- Basic graphics capabilities
- System utilities and games

## System Requirements

- x86-compatible processor
- 1.44MB floppy disk drive
- Minimum 512KB RAM

## Building

### Prerequisites
- NASM (Netwide Assembler)
- QEMU (for emulation)

### Compilation Instructions

```bash
# Assemble bootloader
nasm -f bin bootloader.asm -o bootloader.bin

# Assemble kernel  
nasm -f bin kernel.asm -o kernel.bin

# Create disk image
dd if=/dev/zero of=uturu.img bs=512 count=2880
dd if=bootloader.bin of=uturu.img conv=notrunc
dd if=kernel.bin of=uturu.img bs=512 seek=1 conv=notrunc
```

## Installation

### Floppy Disk
```bash
dd if=uturu.img of=/dev/fd0 bs=512 count=2880
```

### Emulation
```bash
qemu-system-i386 -fda uturu.img
```

## Usage

After boot, the system presents a command-line interface. Available commands include:

- `ver` - Display system version
- `time` - Show current time
- `reboot` - Restart system
- `shutdown` - Power off
- `help` - Display command list

## Project Structure

```
uturu-os/
├── src/
│   ├── bootloader.asm
│   └── kernel.asm
├── docs/
│   └── technical.md
├── LICENSE
└── README.md
```

## Development Status

This project is currently in active development. Version Beta 5 represents a stable release with basic functionality implemented.

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.

## Author

- **Semyon5700** - Initial work and maintenance

## Contributing

This is primarily a personal educational project. While contributions are welcome, please note the irregular update schedule.

## Disclaimer

This operating system is intended for educational purposes only. Use on production systems is not recommended.
