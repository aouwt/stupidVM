

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
