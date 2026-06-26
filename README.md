# Uturu OS

A minimalist 16-bit x86 operating system written in assembly.
## 🚀 Overview

Uturu OS is a completely from-scratch 16-bit operating system written entirely in x86 assembly language. Born from curiosity and passion for low-level programming, this project demonstrates how operating systems work at the most fundamental level.

> **Educational Focus**: Built for learning and experimentation with real-mode x86 architecture

## ✨ Features

### Core System
- 🖥️ **Custom Bootloader** - 512-byte master boot record
- ⚙️ **Monolithic Kernel** - Complete memory management and process control  
- ⌨️ **Interactive Shell** - Command-line interface with argument parsing
- 🛡️ **Safe Input Handling** - Protected against buffer overflow attacks

### System Utilities
- 🕐 **Real-time Clock** - Time display and configuration
- 💾 **Memory Management** - System memory detection and reporting
- 🎮 **Basic Graphics** - VGA mode demonstrations and games
- 🔧 **System Control** - Reboot and shutdown capabilities
- Building from Linux

Requirements:

    NASM assembler

    GNU coreutils (dd)

    QEMU for emulation

Compilation:
bash

nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin

Create disk image:
bash

dd if=/dev/zero of=os.img bs=512 count=2880
dd if=boot.bin of=os.img conv=notrunc
dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc

Run in QEMU:
bash

qemu-system-x86_64 -fda os.img

Compilation on Microsoft Windows is not supported

### Fun Extras
- 🎯 **Minesweeper Game** - Classic puzzle game implementation
- 🔍 **Easter Eggs** - Hidden features waiting to be discovered!
- 📟 **Retro Aesthetic** - Authentic 16-bit computing experience

## 🎮 Available Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `ver` | Display OS version | `ver` |
| `time` | Show current time | `time` |
| `time update` | Set system time | `time update` |
| `echo` | Print text to screen | `echo <message>` |
| `fetch` | System information | `fetch` |
| `cube` | 2D cube demo | `cube` |
| `minesweeper` | Play minesweeper | `minesweeper` |
| `reboot` | Restart system | `reboot` |
| `shutdown` | Power off | `shutdown` |
| `kernel` | Kernel information | `kernel` |
| `author` | Developer credits | `author` |
| `browser` | Placeholder feature | `browser` |
| `crash` | Trigger kernel panic | `crash` |
| `help` | Command reference | `help` |

*💡 Hint: Try the `32-bit` command for a special surprise!*

## 🛠️ System Requirements

### Minimum Hardware
- **Processor**: 8086 compatible CPU or later
- **Memory**: 512KB RAM minimum
- **Storage**: 1.44MB floppy disk
- **Display**: VGA-compatible graphics

### Emulation (Recommended)
- **QEMU** x86 system emulator
- **VirtualBox** with floppy support
- **Bochs** x86 PC emulator
## 📁 Project Structure

```
uturu-os/
├── boot.asm          # Master boot record (512 bytes)
├── kernel.asm        # Main kernel implementation  
├── compile.sh        # Build automation script
├── run.sh           # QEMU launch script
├── README.md        # This file
└── LICENSE          # GPLv3 License
```

## 🎯 Technical Highlights

### Boot Process
1. **BIOS** loads 512-byte bootloader at 0x7C00
2. **Bootloader** loads kernel from disk sectors 2-41
3. **Kernel** initializes at 0x7E00 with system setup
4. **Shell** starts interactive command processing

### Memory Layout
- `0x0000-0x7BFF` - BIOS and system data
- `0x7C00-0x7DFF` - Bootloader (512 bytes)
- `0x7E00-0xFFFF` - Kernel and system memory

### Key Features
- **Real-mode operation** - Direct hardware access
- **Protected input** - Bounds-checked string handling  
- **Modular commands** - Easy to extend functionality
- **BIOS integration** - Leverages firmware services

## 🐛 Current Status: Beta 6

**What works:**
- ✅ Stable boot process
- ✅ Complete shell environment  
- ✅ Basic system utilities
- ✅ Memory detection
- ✅ Real-time clock
- ✅ Graphics demonstrations

**Known limitations:**
- 🔄 Single-tasking only
- 📚 Limited application support  
- 💾 No file system yet
- 🔒 No memory protection

## 👨‍💻 Author

**Semyon5700** - Creator and Maintainer

> *"This project represents my journey into understanding how computers really work at the lowest level. Every line of assembly taught me something new about the magic happening between hardware and software."*

## 📄 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

**You are free to:**
- Use, study, and share the code
- Modify and create derivatives  
- Distribute your modifications

**Under these terms:**
- Disclose source code changes
- License derivatives under GPLv3
- Preserve copyright notices

## 🌟 Why Uturu OS?

Unlike modern operating systems with millions of lines of code, Uturu OS demonstrates that powerful concepts can be implemented with elegant simplicity. It's the perfect codebase for:

- **Students** learning operating system fundamentals
- **Developers** curious about x86 architecture
- **Hobbyists** interested in retro computing
- **Educators** teaching low-level programming
