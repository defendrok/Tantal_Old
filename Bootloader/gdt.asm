[bits 16]
SetGDT:
	cli
	pusha
	lgdt [table]
	sti
	popa
	ret 
	
;Bits 0-15: Bits 0-15 of the Segment Limit
;Bits 16-39: Bits 0-23 of the Base Address
;Bit 40: Access bit (Used with Virtual Memory)
;Bit 41: Readable and Writable
;  0: Read only (Data Segments); Execute only (Code Segments)
;  1: Read and write (Data Segments); Read and Execute (Code Segments)
;Bit 42: Expansion direction (Data segments), conforming (Code Segments)
;Bits 41-43: Descriptor Type
;Bit 43: Executable segment
;  0: Data Segment
;  1: Code Segment
;Bit 44: Descriptor Bit
;  0: System Descriptor
;  1: Code or Data Descriptor
;Bits 45-46: Descriptor Privilege Level
;  0: (Ring 0) Highest
;  3: (Ring 3) Lowest
;Bit 47 Segment is in memory (Used with Virtual Memory)
;Bits 48-51: Bits 16-19 of the segment limit
;Bits 52: Reserved for OS use
;Bit 53: Reserved-Should be zero
;Bit 54: Segment type
;  0: 16 bit
;  1: 32 bit
;Bit 55: Granularity
;  0: None
;  1: Limit gets multiplied by 4K
;Bits 56-63: Bits 24-32 of the base address

;======================================================================

; This is the beginning of the GDT. Because of this, its offset is 0.
 
 GDT:
; null descriptor 
	dd 0 				; null descriptor--just fill 8 bytes with zero
	dd 0 
 
; Notice that each descriptor is exactally 8 bytes in size. THIS IS IMPORTANT.
; Because of this, the code descriptor has offset 0x8.
; code descriptor:			; code descriptor. Right after null descriptor
	dw 0FFFFh 			; limit low
	dw 0 				; base low
	db 0 				; base middle
	db 10011010b 			; access
	db 11001111b 			; granularity
	db 0 				; base high
 
; Because each descriptor is 8 bytes in size, the Data descritpor is at offset 0x10 from
; the beginning of the GDT, or 16 (decimal) bytes from start.
; data descriptor:			; data descriptor
	dw 0FFFFh 			; limit low (Same as code)
	dw 0 				; base low
	db 0 				; base middle
	db 10010010b 			; access
	db 11001111b 			; granularity
	db 0				; base high	
	
; User  CODE (Offset: 24 (0x18) bytes)
	dw 0FFFFh 			; limit low
	dw 0 				; base low
	db 0 				; base middle
	db 11111010b 			; access - Notice that bits 5 and 6 (privilege level) are 11b for Ring 3
	db 11001111b 			; granularity
	db 0 				; base high
 
; User  DATA (Offset: 32 (0x20) bytes
	dw 0FFFFh 			; limit low (Same as code)10:56 AM 7/8/2007
	dw 0 				; base low
	db 0 				; base middle
	db 11110010b 			; access - Notice that bits 5 and 6 (privilege level) are 11b for Ring 3
	db 11001111b 			; granularity
	db 0				; base high
GDT_End:
	
table:
  dw GDT_End - GDT - 1
  dd GDT
  
; give the descriptor offsets names
%define NullDescriptor 0
%define CodeDescriptor 0x8
%define DataDescriptor 0x10
%define CodeUserDescriptor 0x18
%define DataUserDescriptor 0x20