[bits 16]

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
HiddenSectors: 		dd 0
TotalSectorsBig:    dd 0
DriveNumber: 	    DB 0
Unused: 			DB 0
ExtBootSignature: 	DB 0x29
SerialNumber:	    DD 0xa0a1a2a3
VolumeLabel: 	    DB "MOS FLOPPY "
FileSystem: 	    DB "FAT12   "

datasector  dw 0x0000
cluster     dw 0x0000

absoluteSector db 0x00
absoluteHead   db 0x00
absoluteTrack  db 0x00

;************************************************;
; Convert CHS to LBA
; LBA = (cluster - 2) * sectors per cluster
;************************************************;

ClusterLBA:
          sub     ax, 0x0002                          ; zero base cluster number
          xor     cx, cx
          mov     cl, BYTE [SectorsPerCluster]     ; convert byte to word
          mul     cx
          add     ax, WORD [datasector]               ; base data sector
          ret

;************************************************;
; Convert LBA to CHS
; AX=>LBA Address to convert
;
; absolute sector = (logical sector / sectors per track) + 1
; absolute head   = (logical sector / sectors per track) MOD number of heads
; absolute track  = logical sector / (sectors per track * number of heads)
;
;************************************************;

LBACHS:
          xor     dx, dx                              ; prepare dx:ax for operation
          div     WORD [SectorsPerTrack]           ; calculate
          inc     dl                                  ; adjust for sector 0
          mov     BYTE [absoluteSector], dl
          xor     dx, dx                              ; prepare dx:ax for operation
          div     WORD [HeadsPerCylinder]          ; calculate
          mov     BYTE [absoluteHead], dl
          mov     BYTE [absoluteTrack], al
          ret


;************************************************;
; Reads a series of sectors
; CX=>Number of sectors to read
; AX=>Starting sector
; ES:EBX=>Buffer to read to
;************************************************;

ReadSectors:
     .MAIN:
          mov     di, 0x0005                          ; five retries for error
     .SECTORLOOP:
          push    ax
          push    bx
          push    cx
          call    LBACHS                              ; convert starting sector to CHS
          mov     ah, 0x02                            ; BIOS read sector
          mov     al, 0x01                            ; read one sector
          mov     ch, BYTE [absoluteTrack]            ; track
          mov     cl, BYTE [absoluteSector]           ; sector
          mov     dh, BYTE [absoluteHead]             ; head
          mov     dl, BYTE [DriveNumber]            ; drive
          int     0x13                                ; invoke BIOS
          jnc     .SUCCESS                            ; test for read error
          xor     ax, ax                              ; BIOS reset disk
          int     0x13                                ; invoke BIOS
          dec     di                                  ; decrement error counter
          pop     cx
          pop     bx
          pop     ax
          jnz     .SECTORLOOP                         ; attempt to read again
          int     0x18
     .SUCCESS:
          pop     cx
          pop     bx
          pop     ax
          add     bx, WORD [BytesPerSector]        ; queue next buffer
          inc     ax                                  ; queue next sector
          loop    .MAIN                               ; read next sector
          ret

