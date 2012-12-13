[bits 32]
Kernel:
	mov byte [0xb8000], 'L'
	mov byte [0xb8001], 0x4a
	mov byte [0xb8002], 'O'
	mov byte [0xb8004], 'L'
	
	cli
	hlt
	