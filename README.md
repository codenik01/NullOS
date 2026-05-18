<div align="center">

# NullOS

### Custom x86 Operating System Kernel built from scratch using Assembly & C

<img src="https://img.shields.io/badge/Architecture-x86-blue?style=for-the-badge">
<img src="https://img.shields.io/badge/Language-Assembly-orange?style=for-the-badge">
<img src="https://img.shields.io/badge/Language-C-green?style=for-the-badge">
<img src="https://img.shields.io/badge/Kernel-Protected%20Mode-red?style=for-the-badge">
<img src="https://img.shields.io/badge/Status-Active%20Development-success?style=for-the-badge">

<br><br>

> A low-level operating system project focused on understanding how computers work internally by building core OS components manually.

</div>

---

# About NullOS

NullOS is a custom operating system kernel written from scratch using x86 Assembly and C.

The project started as a low-level systems programming learning journey and gradually evolved into a working protected-mode kernel with its own shell, keyboard driver, VGA terminal system, scrolling support, and command handling.

Instead of relying on existing operating systems or frameworks, NullOS directly interacts with hardware components like VGA memory, BIOS interrupts, and keyboard controllers.

---

# Current Features

<ul>
  <li>Custom x86 Bootloader</li>
  <li>Real Mode → Protected Mode Switching</li>
  <li>Global Descriptor Table (GDT)</li>
  <li>VGA Text Mode Terminal</li>
  <li>Direct Video Memory Programming</li>
  <li>Keyboard Driver</li>
  <li>Working Shell / Command System</li>
  <li>Cursor Control</li>
  <li>Backspace Handling</li>
  <li>Screen Scrolling</li>
  <li>Command Buffer System</li>
  <li>Hybrid ASM + C Kernel Architecture</li>
  <li>Freestanding Kernel Environment</li>
  <li>QEMU Boot Support</li>
</ul>

---

# Working Commands

```bash
help
about
clear
```

---

# Tech Stack

<table>
<tr>
<td><b>Assembly</b></td>
<td>NASM x86 Assembly</td>
</tr>

<tr>
<td><b>Language</b></td>
<td>C (Freestanding)</td>
</tr>

<tr>
<td><b>Compiler</b></td>
<td>i686-elf-gcc</td>
</tr>

<tr>
<td><b>Linker</b></td>
<td>GNU LD + Linker Scripts</td>
</tr>

<tr>
<td><b>Emulator</b></td>
<td>QEMU</td>
</tr>

<tr>
<td><b>Architecture</b></td>
<td>x86 Protected Mode</td>
</tr>

<tr>
<td><b>Build System</b></td>
<td>Makefile</td>
</tr>
</table>

---

# Project Structure

```text
NullOS/
│
├── boot.asm
├── kernel_entry.asm
├── kernel.c
├── linker.ld
├── Makefile
│
├── boot.bin
├── kernel.bin
└── nullos.img
```

---

# Build Requirements

Install required tools:

```bash
brew install nasm qemu i686-elf-gcc i686-elf-binutils
```

---

# Build & Run

## Build

```bash
make
```

## Run

```bash
make run
```

## Manual Run

```bash
qemu-system-x86_64 \
-drive if=floppy,format=raw,file=nullos.img \
-display cocoa,zoom-to-fit=on
```

---

# Development Challenges

Some interesting low-level problems faced during development:

<ul>
  <li>Cursor rendering glitches</li>
  <li>Wrong cursor positioning in VGA text memory</li>
  <li>BIOS disk read failures</li>
  <li>Protected mode transition bugs</li>
  <li>Keyboard scan code handling issues</li>
  <li>Mixing Assembly and C safely</li>
  <li>QEMU floppy vs raw image boot conflicts</li>
</ul>

A large part of the project involved debugging behavior without logs, exceptions, or operating system support.

---

# Next Goals

* Interrupt Descriptor Table (IDT)
* Hardware Interrupts (IRQ)
* Memory Management
* Paging
* Filesystem
* Multitasking
* Mouse Support
* Basic GUI
* Drivers

---

# Screenshots

> Comming soon

---

# Author

### Nikhil Chavan

GitHub: <a href="https://github.com/codenik01">github.com/codenik01</a>

---

<div align="center">

### NullOS — Learning Operating Systems from the Lowest Level

</div>
