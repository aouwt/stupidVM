	#include "./stupidVM.asm"

MOUSEX	=	0x0000	;2b
MOUSEY	=	0x0002	;2b

#bank srom

	load.a	#1
	store.a	GPU_VMODE
	
	load.m	#Text_1
	subr	FANCYPRINT
	jump	end
	
b:
.loop:
	load.a	GPU_WRITEBYTE
	inc.a
	store.a	GPU_WRITEBYTE
	
	load.m	GPU_WRITEADDR
	comp.m	#32768
	if.c	end
	
	jump	.loop
	
	jump	end
a:
.loop:
	subr	UPDATEMOUSE
	
	load.a	MOUSEX+1
	load.b	MOUSEY+1
	subr	getvramaddr
	
	store.m	GPU_WRITEADDR
	
	load.a	IO_MOUSE
	
	store.m	GPU_WRITEADDR
	store.a	GPU_WRITEBYTE
	
	jump	.loop
	
	;jump	end	;speen :D
	
	


getvramaddr:
;	;and.a	#0b01111111
;	;and.b	#0b01111111
;	;load.m	#0
;	;move.a-ma
;.loop:
;	add.m	#255
;	dec.b
;	ifnz.b	.loop
;	
;	return
	
	move.ab-m
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
	and.a	#0b10000000	; nearest multiple of 64
	add.a	#0b10000000
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
	#d	"hello hello hello\n\0"
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
