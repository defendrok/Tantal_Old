;============================================
;	ProtectedMode routines
;============================================

%define		VideoMemory 0xB8000			; video memory
%define		Columns 80			; width and height of screen
%define		Lines 25
%define		CharacterAttribute 14			; character attribute (White text on light blue background) 63

CurrentX db 0					; current x/y location
CurrentY db 0

;**************************************************;
;	Putch32 ()
;		- Prints a character to screen
;	BL => Character to print
;**************************************************;
[bits 32]
PrintChar32:

	pusha				; save registers
	mov	edi, VideoMemory		; get pointer to video memory
	;-------------------------------;
	;   Get current position	;
	;-------------------------------;
	xor	eax, eax		; clear eax
		;--------------------------------
		; Remember: currentPos = x + y * COLS! x and y are in _CurX and _CurY.
		; Because there are two bytes per character, COLS=number of characters in a line.
		; We have to multiply this by 2 to get number of bytes per line. This is the screen width,
		; so multiply screen with * _CurY to get current line
		;--------------------------------

		mov	ecx, Columns*2		; Mode 7 has 2 bytes per char, so its COLS*2 bytes per line
		mov	al, byte [CurrentY]	; get y pos
		mul	ecx			; multiply y*COLS
		push eax			; save eax--the multiplication

		;--------------------------------
		; Now y * screen width is in eax. Now, just add _CurX. But, again remember that _CurX is relative
		; to the current character count, not byte count. Because there are two bytes per character, we
		; have to multiply _CurX by 2 first, then add it to our screen width * y.
		;--------------------------------

		mov	al, byte [CurrentX]	; multiply _CurX by 2 because it is 2 bytes per char
		mov	cl, 2
		mul	cl
		pop	ecx			; pop y*COLS result
		add	eax, ecx

		;-------------------------------
		; Now eax contains the offset address to draw the character at, so just add it to the base address
		; of video memory (Stored in edi)
		;-------------------------------

		xor	ecx, ecx
		add	edi, eax		; add it to the base address

	;-------------------------------;
	;   Watch for new line          ;
	;-------------------------------;

	cmp	bl, 0x0A		; is it a newline character?
	je	.Row			; yep--go to next row

	;-------------------------------;
	;   Print a character           ;
	;-------------------------------;

	mov	dl, bl			; Get character
	mov	dh, CharacterAttribute		; the character attribute
	mov	word [edi], dx		; write to video display

	;-------------------------------;
	;   Update next position        ;
	;-------------------------------;

	inc	byte [CurrentX]		; go to next character
	cmp	byte [CurrentX], Columns		; are we at the end of the line?
	je .Row			; yep-go to next row
	jmp .done			; nope, bail out

	;-------------------------------;
	;   Go to next row              ;
	;-------------------------------;

.Row:
	mov	byte [CurrentX], 0		; go back to col 0
	inc	byte [CurrentY]		; go to next row

	;-------------------------------;
	;   Restore registers & return  ;
	;-------------------------------;

.done:
	popa				; restore registers and return
	ret

;**************************************************;
;	Puts32 ()
;		- Prints a null terminated string
;	parm\ EBX = address of string to print
;**************************************************;

PrintString32:

	;-------------------------------;
	;   Store registers             ;
	;-------------------------------;

	pusha				; save registers.
	push ebx			; copy the string address
	pop	edi

.loop:

	;-------------------------------;
	;   Get character               ;
	;-------------------------------;

	mov	bl, byte [edi]		; get next character
	cmp	bl, 0			; is it 0 (Null terminator)?
	je	.done			; yep-bail out

	;-------------------------------;
	;   Print the character         ;
	;-------------------------------;

	call	PrintChar32			; Nope-print it out

	;-------------------------------;
	;   Go to next character        ;
	;-------------------------------;

	inc	edi			; go to next character
	jmp	.loop

.done:

	;-------------------------------;
	;   Update hardware cursor      ;
	;-------------------------------;

	; Its more efficiant to update the cursor after displaying
	; the complete string because direct VGA is slow

	mov	bh, byte [CurrentY]	; get current position
	mov	bl, byte [CurrentX]
	call	MoveCursor			; update cursor

	popa				; restore registers, and return
	ret

;**************************************************;
;	MoveCur ()
;		- Update hardware cursor
;	parm/ bh = Y pos
;	parm/ bl = x pos
;**************************************************;

[bits 32]

MoveCursor:

	pusha				; save registers (aren't you getting tired of this comment?)

	;-------------------------------;
	;   Get current position        ;
	;-------------------------------;

	; Here, _CurX and _CurY are relitave to the current position on screen, not in memory.
	; That is, we don't need to worry about the byte alignment we do when displaying characters,
	; so just follow the forumla: location = _CurX + _CurY * COLS

	xor	eax, eax
	mov	ecx, Columns
	mov	al, bh			; get y pos
	mul	ecx			; multiply y*COLS
	add	al, bl			; Now add x
	mov	ebx, eax

	;--------------------------------------;
	;   Set low byte index to VGA register ;
	;--------------------------------------;

	mov	al, 0x0f
	mov	dx, 0x03D4
	out	dx, al

	mov	al, bl
	mov	dx, 0x03D5
	out	dx, al			; low byte

	;---------------------------------------;
	;   Set high byte index to VGA register ;
	;---------------------------------------;

	xor	eax, eax

	mov	al, 0x0e
	mov	dx, 0x03D4
	out	dx, al

	mov	al, bh
	mov	dx, 0x03D5
	out	dx, al			; high byte

	popa
	ret

;**************************************************;
;	ClrScr32 ()
;		- Clears screen
;**************************************************;

[bits 32]
ClearScreen32:

	pusha
	cld
	mov	edi, VideoMemory                                             		   ; �������������� pusha
	mov	cx, 2000                                                                      ; � popa, �.�. �������� 
	mov	ah, CharacterAttribute                                              ; ������
	mov	al, ' '	
	rep	stosw

	mov	byte [CurrentX], 0
	mov	byte [CurrentY], 0
	popa
	ret

;**************************************************;
;	GotoXY ()
;		- Set current X/Y location
;	parm\	AL=X position
;	parm\	AH=Y position
;**************************************************;

[bits 32]

GotoXY:
	pusha
	mov	[CurrentX], al		; just set the current position
	mov	[CurrentY], ah
	popa
	ret