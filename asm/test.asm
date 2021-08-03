	#include "./stupidVM.asm"

MOUSEX	=	0x00	;2b
MOUSEY	=	0x02	;2b

#bank srom

	load.a	#VMODE_HICOLOR
	store.a	GPU_VMODE
	
.loop:
	subr	UPDATEMOUSE
	
	load.a	MOUSEX
	load.b	MOUSEY
	subr	getvramaddr
	store.m	GPU_WRITEADDR
	
	load.a	#255
	store.a	GPU_WRITEBYTE
	
	jump	.loop
	
	;jump	end	;speen :D
	
	


getvramaddr:
	and.a	#127
	and.b	#127
	move.a-ma
.loop:
	add.m	#128
	dec.b
	ifnz.b	.loop
	
	return
	
	
	
PRINT:
	load.a	M
	ifz.a	RETURN		; if byte=0 then return
	store.a	GPU_WRITEBYTE
	inc.m			; set to read next byte
	jump	PRINT



UPDATEMOUSE:
	load.a	IO_MOUSE
	
	move.a-b
	and.b	#0b00000001
	ifnz.b	.decx
.ret_decx:
	move.a-b
	and.b	#0b00000010
	ifnz.b	.incx
.ret_incx:
	move.a-b
	and.b	#0b00000100
	ifnz.b	.decy
.ret_decy:
	move.a-b
	and.b	#0b00001000
	ifnz.b	.incy
.ret_incy:
	return
	
	
.decx:	load.m	MOUSEX
	dec.m
	store.m	MOUSEX
	jump	.ret_decx
	
.incx:	load.m	MOUSEX
	inc.m
	store.m	MOUSEX
	jump	.ret_incx
	
.incy:	load.m	MOUSEY
	inc.m
	store.m	MOUSEY
	jump	.ret_decy
	
.decy:	load.m	MOUSEY
	dec.m
	store.m	MOUSEY
	jump	.ret_incy



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
