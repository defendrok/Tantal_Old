;**************************************************
;
;	Input/Output routines
;
;**************************************************
;============================================
;	RealMode routines
;============================================
[bits 16]
PrintString16:
	pusha
.Loop1:
	lodsb
	or al, al
	jz .Done16
	mov ah, 0x0e
	int 0x10
	jmp .Loop1
.Done16:
	popa
	ret
