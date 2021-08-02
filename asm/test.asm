	#include "./stupidVM.asm"

#bank srom

	load.a	#VMODE_TEXT
	store.a	GPU_VMODE
	
	
	load.m	#Text_1
	subr	FANCYPRINT
	
	load.a	#0xFF
	store.a	SND_VOL
	
	load.a	#0x01010101
	store.a	SND_WAVE
	
	;load.a	#50
	;store.a	SND_CH1_NOTE
	
	load.a	#0b00000111
	store.a	SND_DUTY
	
	
	jump	end
	
	
.loop:
	load.a	SND_CH1_NOTE
	inc.a
	store.a	SND_CH1_NOTE
	;subr	WAIT
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
