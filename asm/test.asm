	#include "./stupidVM.asm"

#bank srom

	load.a	#VMODE_TEXT
	store.a	GPU_VMODE
	
	
	load.m	#Text_1
	subr	FANCYPRINT
	
	load.m	#440
	store.m	SPU_CH1_PITCH
	
	load.m	#400
	store.m	SPU_CH2_PITCH
	
	load.a	#255
	store.a	SPU_CH1_VOL
	store.a	SPU_CH2_VOL	
	
	load.m	#1
.loop:
	;store.m	SPU_CH1_WAVE
	store.m	SPU_CH2_WAVE
	lsh.m
	inc.m
	subr	WAIT
	subr	WAIT
	subr	WAIT
	jump	.loop
	
	jump	end	;speen :D
	
PRINT:
	load.a	M
	ifz.a	RETURN		; if byte=0 then return
	store.a	GPU_WRITEBYTE
	inc.m			; set to read next byte
	jump	PRINT




FANCYPRINT:
	load.a	M
	inc.m
	
	ifz.a	RETURN	;null terminated
	
	comp.a	#"\n"	;newline
	if.c	.nl
	
	store.a	GPU_WRITEBYTE	;otherwise, print
	
	jump	FANCYPRINT
	
	
.nl:	subr	NEWLINE
	jump	FANCYPRINT


NEWLINE:
	load.a	GPU_WRITEADDR
	inc.a
	and.a	#0b11000000	; nearest multiple of 64
	add.a	#0b01000000
	store.a	GPU_WRITEADDR
	
	ifz.a	.incnext
	return

.incnext:
	load.a	GPU_WRITEADDR + 1
	inc.a
	store.a	GPU_WRITEADDR + 1
	return




Text_1:
	#d	"Hello world!\n"
	#d	"This is a testing program\n"
	#d	"Playing 440Hz...\n\0"
Text_2:
	#d	"Playing 880hz...\n\0"

end:	jump	end


WAIT:
	load.a	#0
	
.loop1:	load.b	#0
	
.loop2:	inc.b
	ifnz.b	.loop2
	
	inc.a
	ifnz.a	.loop1
	
RETURN:	return
