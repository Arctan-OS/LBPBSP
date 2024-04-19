#/**
# * @file Makefile
# *
# * @author awewsomegamer <awewsomegamer@gmail.com>
# *
# * @LICENSE
# * Arctan-LimineBSP - Limine Bootstrapper for Arctan Kernel
# * Copyright (C) 2023-2024 awewsomegamer
# *
# * This file is part of Arctan-LimineBSP
# *
# * Arctan is free software; you can redistribute it and/or
# * modify it under the terms of the GNU General Public License
# * as published by the Free Software Foundation; version 2
# *
# * This program is distributed in the hope that it will be useful,
# * but WITHOUT ANY WARRANTY; without even the implied warranty of
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# * GNU General Public License for more details.
# *
# * You should have received a copy of the GNU General Public License
# * along with this program; if not, write to the Free Software
# * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# *
# * @DESCRIPTION
#*/
CC ?= gcc
LD ?= ld

CPP_DEBUG_FLAG := -DARC_DEBUG_ENABLE
CPP_E9HACK_FLAG := -DARC_E9HACK_ENABLE

ifeq (,$(wildcard ./e9hack.enable))
# Disable E9HACK
	CPP_SERIAL_FLAG :=
endif

ifeq (,$(wildcard ./debug.enable))
# Disable debugging
	CPP_DEBUG_FLAG :=
else
# Must set serial flag if debugging
	CPP_E9HACK_FLAG := -DARC_E9HACK_ENABLE
endif

PRODUCT := bootstrap.elf

CFILES := $(shell find ./src/c/ -type f -name "*.c")
ASFILES := $(shell find ./src/asm/ -type f -name "*.asm")

OFILES := $(CFILES:.c=.o) $(ASFILES:.asm=.o)

CPPFLAGS := $(CPPFLAG_DEBUG) $(CPPFLAG_E9HACK) -I src/c/include -I $(ARC_ROOT)/initramfs/include $(CPP_DEBUG_FLAG) $(CPP_E9HACK_FLAG)
CFLAGS := -c -fno-stack-protector -mno-sse -mno-sse2 -masm=intel -nostdlib -nodefaultlibs -fno-builtin

LDFLAGS := -Tlinker.ld -melf_x86_64 -z max-page-size=0x1000 -o $(PRODUCT)

NASMFLAGS := -f elf32

.PHONY: all
all: $(OFILES)
	$(LD) $(LDFLAGS) $(OFILES)

# Make the ISO
	git clone https://github.com/limine-bootloader/limine.git --branch=v7.x-binary --depth=1

	make -C limine

	mkdir -p iso/boot/limine

	cp -v $(PRODUCT) iso/boot/
	cp -v $(BASE_DIR)/build-support/limine.cfg limine/limine-bios.sys limine/limine-bios-cd.bin \
			limine/limine-uefi-cd.bin iso/boot/limine
	mkdir -p iso/EFI/BOOT
	cp -v limine/BOOTX64.EFI iso/EFI/BOOT
	cp -v limine/BOOTIA32.EFI iso/EFI/BOOT

	xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        --efi-boot boot/limine/limine-uefi-cd.bin \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        iso -o Arctan.iso

#	limine/limine bios-install Arctan.iso

	cp Arctan.iso $(BASE_DIR)/

src/c/%.o: src/c/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $< -o $@

src/asm/%.o: src/asm/%.asm
	nasm $(NASMFLAGS) $< -o $@


.PHONY: clean
clean:
	rm -f $(PRODUCT)
	find . -type f -name "*.o" -delete
