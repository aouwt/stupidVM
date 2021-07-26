	include "regs.asm"
	
.loop:
	load.a	REG_MOUSE_X
	
	ifz.a	.skipx			; x = 0 then skip
	
	comp.a	#REG_MOUSE_X_LEFT	; x = LEFT then dec x
	if.c	.decx
	
	inc	mousex			; x = RIGHT then inc x
	jump	.skipx
	
.decx:	dec	mousex			; x = LEFT

	
.skipx:
	load.a	REG_MOUSE_Y
	
	ifz.a	.skipy			; y = 0 then skip
	
	comp.a	#REG_MOUSE_Y_UP		; y = UP then dec y
	if.c	.decy
	
	inc	mousey			; y = DOWN then inc y
	jump	.skipy
	
.decy:	dec	mousey			; y = UP

.skipy:
	load.m	REG_MOUSE_X
	
	load.a	REG_MOUSE_Y
	
	.findy:
		add.m	#255
		dec.a
		ifnz.a	.findy
	
	save.m	REG_GPU_WRITE_ADDR
	
	load.a	#255
	save.a	REG_GPU_WRITE_BYTE
	
	
	
	load.a	REG_MOUSE_BUTTON
	and.a	#%REG_MOUSE_BUTTON_LEFT	;isolate left button
	ifnz.a	.loop
