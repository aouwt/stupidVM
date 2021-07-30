	#include "./stupidVM.asm"

#bank srom

	load.a	#VMODE_TEXT
	store.a	GPU_VMODE
	
	
	load.m	#Text_1
	subr	PRINT
	subr	NEWLINE
	inc.m
	subr	PRINT
	subr	NEWLINE
	
	jump	pc	;speen :D
	
PRINT:
	load.a	M
	ifz.a	.ret		;if byte=0 then return
	store.a	GPU_WRITEBYTE
	inc.m			;set to read next byte
	jump	PRINT
.ret:
	return

NEWLINE:
	load.a	GPU_WRITEADDR
	and.a	#0b11000000	; nearest multiple of 64
	store.a	GPU_WRITEADDR
	
	comp.a	#0b11000000	; if addr > 192...
	if.c	.incnext	; ...then inc next
	return

.incnext:
	load.a	GPU_WRITEADDR + 1
	inc.a
	store.a	GPU_WRITEADDR + 1
	return




Text_1:
	#d	"Hello world!\0"
Text_2:
	#d	"This is using two lines!\0"
