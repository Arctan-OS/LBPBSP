/*
    Arctan-LimineBSP - Limine Bootstrapper for Arctan Kernel
    Copyright (C) 2023  awewsomegamer

    This file is part of Arctan-LimineBSP

    Arctan is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; version 2

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

ENTRY(_entry)

PHDRS {
      text PT_LOAD FLAGS((1 << 0) | (1 << 2));
      rodata PT_LOAD FLAGS((1 << 2));
      data PT_LOAD FLAGS((1 << 1) | (1 << 2));
      dynamic PT_DYNAMIC FLAGS((1 << 1) | (1 << 2));
}

SECTIONS {
    . = 0xFFFFFFFF80000000;

    .text : {
        *(.text .text.*)
    } :text

    . += CONSTANT(MAXPAGESIZE);

    .rodata : {
        *(.rodata .rodata.*)
    } :rodata

    . += CONSTANT(MAXPAGESIZE);

    .data : {
        *(.data .data.*)
    } :data

    .dynamic : {
         *(.dynamic)
    } :data :dynamic

    .bss : {
        *(COMMON)
        *(.bss .bss.*)
    } :data

    . += CONSTANT(MAXPAGESIZE);

    /DISCARD/ : {
        *(.eh_frame)
        *(.note .note.*)
    }
}
