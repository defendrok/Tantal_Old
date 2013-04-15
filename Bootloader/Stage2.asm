; Remember the memory map-- 0x500 through 0x7bff is unused above the BIOS data area.
; We are loaded at 0x500 (0x50:0)
[bits 16]
[org 0x500]
jmp	Main				; go to start
;*******************************************************
;	Preprocessor directives
;*******************************************************
%include "a20.asm"		;a20 line
%include "gdt.asm"			; Gdt routines
%include "Fat12.asm"
%include "common.asm"
%include "StandartIO16.asm"		; basic i/o routines
;*******************************************************
;	Data Section
;*******************************************************
LoadingMessage db "Preparing to load operating system", 0x0D, 0x0A, 0x00
FailureMessage db "Error occured, reboot!", 13, 10, 0
;*******************************************************
;	STAGE 2 ENTRY POINT
;
;		-Store BIOS information
;		-Load Kernel
;		-Install GDT; go into protected mode (pmode)
;		-Jump to Stage 3
;*******************************************************
Main:
	;-------------------------------;
	;   Setup segments and stack	;
	;-------------------------------;
	cli				; clear interrupts
	xor	ax, ax			; null segments
	mov	ds, ax
	mov	es, ax
	mov	ax, 0x9000		; stack begins at 0x90000 (576kb)
	mov	ss, ax
	mov	sp, 0xFFFF		;stack ends there
	sti				; enable interrupts
	;-------------------------------;
	;   Install our GDT		;
	;-------------------------------;
	call SetGDT	; install our GDT
	;-------------------------------;
	;	Set a20 line			;
	;-------------------------------;
	call EnableA20_KKbrd ; Open the doors, give us SPACE
	;-------------------------------;
	;   Print loading message	;
	;-------------------------------;
	mov	si, LoadingMessage
	call PrintString16

	;-------------------------------;
    ; Initialize filesystem		;
    ;-------------------------------;
	call	LoadRoot		; Load root directory table
    ;-------------------------------;
    ; Load Kernel			;
    ;-------------------------------;
	mov	ebx, 0			; BX:BP points to buffer to load to
   	mov	ebp, RModeBase
	mov	esi, ImageName		; our file to load
	call	LoadFile		; load our file
	mov	dword [ImageSize], ecx	; save size of kernel
	cmp	ax, 0			; Test for success
	je	EnterStage3		; yep--onto Stage 3!
	mov	si, FailureMessage		; Nope--print error
	call	PrintString16
	mov	ah, 0
	int     0x16                    ; await keypress
	int     0x19                    ; warm boot computer
	;-------------------------------;
	;   Go into pmode		;
	;-------------------------------;
EnterStage3:
	cli				; clear interrupts
	mov	eax, cr0		; set bit 0 in cr0--enter pmode
	or	eax, 1
	mov	cr0, eax
	jmp	CodeDescriptor:Stage3	; far jump to fix CS. Remember that the code selector is 0x8!
	; Note: Do NOT re-enable interrupts! Doing so will triple fault!
	; We will fix this in Stage 3.
;******************************************************
;	ENTRY POINT FOR STAGE 3
;******************************************************
[bits 32]					; Welcome to the 32 bit world!
Stage3:
	;-------------------------------;
	;   Set registers		;
	;-------------------------------;
	mov		ax, DataDescriptor		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h
	;-------------------------------;
	; Copy kernel to 1MB		;
	;-------------------------------;

CopyImage:	;дешево(может быть и не очень) и сердито(но очень сердито)
  	mov	eax, dword [ImageSize]
  	movzx	ebx, word [BytesPerSector]
  	mul	ebx
  	mov	ebx, 4
  	div	ebx
   	cld
   	mov esi, RModeBase
   	mov	edi, PModeBase
   	mov	ecx, eax
   	rep	movsd                   ; copy image to its protected mode address

	;---------------------------------------;
	;   Execute Kernel			;
	;---------------------------------------;
	cli
	jmp	CodeDescriptor:PModeBase; jump to our kernel! Note: This assumes Kernel's entry point is at 1 MB

	;---------------------------------------;
	;   Stop execution			;
	;---------------------------------------;

	cli
	hlt