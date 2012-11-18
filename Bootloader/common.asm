; where the kernel is to be loaded to in protected mode
%define PModeBase 0x100000

; where the kernel is to be loaded to in real mode
%define RModeBase 0x3000

; kernel name (Must be 11 bytes)
; file name is FAT directory
ImageName     db "KERNEL  BIN"

; size of kernel image in bytes
ImageSize     dd 0