	#include "./stupidVM.asm"

#bank srom

	load.a #VMODE_TEXT
	store.a GPU_VMODE
.start:
	load.m #.text
	
.print:
	load.b M
	store.b GPU_WRITEBYTE
	inc.m
	ifz.b .end
	jump .print

.text:
	#d "Hello, world!",0x00

.end:
	jump .end
