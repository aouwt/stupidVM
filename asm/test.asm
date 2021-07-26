#include "./asm/stupidVM.asm"

#bank srom
	load.m #0
	load.a #0b10101010
	
.loop:
	store.m GPU_WRITEADDR
	store.a GPU_WRITEBYTE
	inc.m
	jump .loop
	break
