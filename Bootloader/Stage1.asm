[bits 16]						; we are in 16 bit real mode
[org 0]					; we will set regisers later

Start:	
	jmp	Main				; jump to start of bootloader

;*********************************************
;	BIOS Parameter Block
;*********************************************
;  Begins 3 bytes from start. We do a far jump, which is 3 bytes in size.
; If you use a short jump, add a "nop" after it to offset the 3rd byte.

OEM			db "Tantal  "
BytesPerSector:  	DW 512
SectorsPerCluster: 	DB 1
ReservedSectors: 	DW 1
NumberOfFATs: 		DB 2
RootEntries: 		DW 224
TotalSectors: 		DW 2880
Media: 				DB 0xf0  ;; 0xF1
SectorsPerFAT: 		DW 9
SectorsPerTrack: 	DW 18
HeadsPerCylinder: 	DW 2
HiddenSectors: 		DD 0
TotalSectorsBig:	DD 0
DriveNumber:		DB 0
Unused: 			DB 0
ExtBootSignature: 	DB 0x29
SerialNumber:	    DD 0x0
VolumeLabel: 	    DB "MOS FLOPPY "
FileSystem: 	    DB "FAT12   "

;************************************************;
;	Prints a string
;	DS=>SI: 0 terminated string
;************************************************;
Print:
	lodsb				; load next byte from string from SI to AL
	or	al, al			; Does AL=0?
	jz	PrintDone		; Yep, null terminator found-bail out
	mov	ah, 0eh			; Nope-Print the character
	int	10h
	jmp	Print			; Repeat until null terminator found
PrintDone:
	ret				; we are done, so return

;***********************************************;
;	Small data area
;	cells for storing translations of 
; disk arithmetics
;***********************************************;
AbsoluteSector db 0x00
AbsoluteHead   db 0x00
AbsoluteTrack  db 0x00

;************************************************;
; Convert CHS to LBA
; LBA = (cluster - 2) * sectors per cluster
;************************************************;
ClusterLBA:
	sub	ax, 0x0002                          ; zero base cluster number
	xor cx, cx
	mov cl, BYTE [SectorsPerCluster]     ; convert byte to word
	mul cx
	add ax, WORD [datasector]               ; base data sector
	ret

;************************************************;
; Convert LBA to CHS
; AX=>LBA Address to convert
;
; Absolute sector = (logical sector / sectors per track) + 1
; Absolute head   = (logical sector / sectors per track) MOD number of heads
; Absolute track  = logical sector / (sectors per track * number of heads)
;
;************************************************;
LBACHS:
	xor dx, dx                              ; prepare dx:ax for operation
	div WORD [SectorsPerTrack]           ; calculate
	inc dl                                  ; adjust for sector 0
	mov BYTE [AbsoluteSector], dl
	xor dx, dx                              ; prepare dx:ax for operation
	div WORD [HeadsPerCylinder]          ; calculate
	mov BYTE [AbsoluteHead], dl
	mov BYTE [AbsoluteTrack], al
	ret


;************************************************;
; Reads a series of sectors
; CX=>Number of sectors to read
; AX=>Starting sector
; ES:BX=>Buffer to read to
;************************************************;
ReadSectors:
.MAIN:
	mov di, 0x0005                          ; five retries for error
.SECTORLOOP:
	push ax
	push bx
	push cx
	call LBACHS                              ; convert starting sector to CHS
	mov ah, 0x02                            ; BIOS read sector
	mov al, 0x01                            ; read one sector
	mov ch, BYTE [AbsoluteTrack]            ; track
	mov cl, BYTE [AbsoluteSector]           ; sector
	mov dh, BYTE [AbsoluteHead]             ; head
	mov dl, BYTE [DriveNumber]            ; drive
	int 0x13                                ; invoke BIOS
	jnc .SUCCESS                            ; test for read error
	xor ax, ax                              ; BIOS reset disk
	int 0x13                                ; invoke BIOS
	dec di                                  ; decrement error counter
	pop cx
	pop bx
	pop ax
	jnz .SECTORLOOP                         ; attempt to read again
	int 0x18
.SUCCESS:
	mov si, msgProgress
	call Print
	pop cx
	pop bx
	pop ax
	add bx, WORD [BytesPerSector]        ; queue next buffer
	inc ax                                  ; queue next sector
	loop .MAIN                               ; read next sector
	ret


;*********************************************
;	Bootloader Entry Point					  *	********************************* Code Section
;*********************************************

Main:
     ;----------------------------------------------------
     ; code located at 0000:7C00, adjust segment registers
     ;----------------------------------------------------
          cli						; disable interrupts
          mov     ax, 0x07C0				; setup registers to point to our segment
          mov     ds, ax
          mov     es, ax
          mov     fs, ax
          mov     gs, ax

     ;----------------------------------------------------
     ; create stack
     ;----------------------------------------------------
     
          mov     ax, 0x0000				; set the stack
          mov     ss, ax
          mov     sp, 0xFFFF
          sti						; restore interrupts

     ;----------------------------------------------------
     ; Display loading message
     ;----------------------------------------------------
     
          mov     si, msgLoading
          call    Print
          
     ;----------------------------------------------------
     ; Load root directory table
     ;----------------------------------------------------

     LOAD_ROOT:
     
     ; compute size of root directory and store in "cx"
     
          xor     cx, cx
          xor     dx, dx
          mov     ax, 0x0020                           ; 32 byte directory entry
          mul     WORD [RootEntries]                ; total size of directory
          div     WORD [BytesPerSector]             ; sectors used by directory
          xchg    ax, cx
          
     ; compute location of root directory and store in "ax"
     
          mov     al, BYTE [NumberOfFATs]            ; number of FATs
          mul     WORD [SectorsPerFAT]               ; sectors used by FATs
          add     ax, WORD [ReservedSectors]         ; adjust for bootsector
          mov     WORD [datasector], ax                 ; base of root directory
          add     WORD [datasector], cx
          
     ; read root directory into memory (7C00:0200)
     
          mov     bx, 0x0200                            ; copy root dir above bootcode
          call    ReadSectors

     ;----------------------------------------------------
     ; Find stage 2
     ;----------------------------------------------------

     ; browse root directory for binary image
          mov     cx, WORD [RootEntries]             ; load loop counter
          mov     di, 0x0200                            ; locate first root entry
     .LOOP:
          push    cx
          mov     cx, 0x000B                            ; eleven character name
          mov     si, ImageName                         ; image name to find
          push    di
     rep  cmpsb                                         ; test for entry match
          pop     di
          je      LOAD_FAT
          pop     cx
          add     di, 0x0020                            ; queue next directory entry
          loop    .LOOP
          jmp     FAILURE

     ;----------------------------------------------------
     ; Load FAT
     ;----------------------------------------------------

     LOAD_FAT:
     
     ; save starting cluster of boot image
     
          mov     dx, WORD [di + 0x001A]
          mov     WORD [cluster], dx                  ; file's first cluster
          
     ; compute size of FAT and store in "cx"
     
          xor     ax, ax
          mov     al, BYTE [NumberOfFATs]          ; number of FATs
          mul     WORD [SectorsPerFAT]             ; sectors used by FATs
          mov     cx, ax

     ; compute location of FAT and store in "ax"

          mov     ax, WORD [ReservedSectors]       ; adjust for bootsector
          
     ; read FAT into memory (7C00:0200)

          mov     bx, 0x0200                          ; copy FAT above bootcode
          call    ReadSectors

     ; read image file into memory (0050:0000)
     
          mov     ax, 0x0050
          mov     es, ax                              ; destination for image
          mov     bx, 0x0000                          ; destination for image
          push    bx

     ;----------------------------------------------------
     ; Load Stage 2
     ;----------------------------------------------------

     LOAD_IMAGE:
     
          mov     ax, WORD [cluster]                  ; cluster to read
          pop     bx                                  ; buffer to read into
          call    ClusterLBA                          ; convert cluster to LBA
          xor     cx, cx
          mov     cl, BYTE [SectorsPerCluster]     ; sectors to read
          call    ReadSectors
          push    bx
          
     ; compute next cluster
     
          mov     ax, WORD [cluster]                  ; identify current cluster
          mov     cx, ax                              ; copy current cluster
          mov     dx, ax                              ; copy current cluster
          shr     dx, 0x0001                          ; divide by two
          add     cx, dx                              ; sum for (3/2)
          mov     bx, 0x0200                          ; location of FAT in memory
          add     bx, cx                              ; index into FAT
          mov     dx, WORD [bx]                       ; read two bytes from FAT
          test    ax, 0x0001
          jnz     .ODD_CLUSTER
          
     .EVEN_CLUSTER:
     
          and     dx, 0000111111111111b               ; take low twelve bits
         jmp     .DONE
         
     .ODD_CLUSTER:
     
          shr     dx, 0x0004                          ; take high twelve bits
          
     .DONE:
     
          mov     WORD [cluster], dx                  ; store new cluster
          cmp     dx, 0x0FF0                          ; test for end of file
          jb      LOAD_IMAGE
          
     DONE:
     
          mov     si, msgCRLF
          call    Print
          push    WORD 0x0050
          push    WORD 0x0000
          retf
          
     FAILURE:
     
          mov     si, msgFailure
          call    Print
          mov     ah, 0x00
          int     0x16                                ; await keypress
          int     0x19                                ; warm boot computer


datasector  dw 0x0000
cluster     dw 0x0000
ImageName   db "STAGE2  BIN"
msgLoading  db 0x0D, 0x0A, "Loading Boot Image ", 0x00
msgCRLF     db 0x0D, 0x0A, 0x00
msgProgress db ".", 0x00
msgFailure  db 0x0D, 0x0A, "Stage2 was not. Press Any Key to Reboot", 0x0D, 0x0A, 0x00

	TIMES 510-($-$$) DB 0
	DW 0xAA55
