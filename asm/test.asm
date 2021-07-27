#include "./stupidVM.asm"

#bank srom

	load.a #VMODE_HIRES
	store.a GPU_VMODE
	load.a #0
	load.b #1
	
.loop:
	store.b GPU_WRITEBYTE
	lsh.b
	ifnz.b .loop

	inc.a
	move.a-b
	jump .loop
