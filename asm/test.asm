#include "./stupidVM.asm"

#bank srom

	load.b #0

.start:
	load.a #0b00000000
	
.loop:
	store.a GPU_WRITEBYTE
	inc.b
	ifnz.b .loop

.loop2:
	store.a GPU_WRITEBYTE
	inc.b
	ifnz.b .loop2
	
	load.a #0b10101010
	
.loop3:
	store.a GPU_WRITEBYTE
	inc.b
	ifnz.b .loop3
	
	load.a #0b11111111

.loop4:
	store.a GPU_WRITEBYTE
	inc.b
	ifnz.b .loop4
	
	load.a #0b01010101
	
.loop5:
	store.a GPU_WRITEBYTE
	inc.b
	ifnz.b .loop5
	
	jump .start
