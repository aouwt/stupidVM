#include "./stupidVM.asm"

#bank srom

	load.a #VMODE_HICOLOR
	store.a GPU_VMODE
	load.a #0
	load.b #0
	
.loop:
	store.b GPU_WRITEBYTE
	inc.b
	ifnz.b .loop

	inc.a
	move.a-b
	jump .loop
