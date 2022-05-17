	#include	"./stupidVM.asm"

MOUSEX	=	0
MOUSEY	=	0
#bank srom


.Img_2_Init:
	subr	WAIT
	subr	WAIT
	subr	WAIT
	subr	CLEAR_VRAM
	
	load.m	#0
	store.m	GPU_WRITEADDR
	store.m	GPU_OFFSET
	
	load.a	#2
	store.a	GPU_VMODE
	load.m	#(Img_2 - 1)
	load.b	#Img_2_W

.Img_2_Loop:
	inc.m
	dec.b
	
	load.a	M
	store.a	GPU_WRITEBYTE
	
	; is end of line?
	ifz.b	.Img_2_NL
	
	
	; is end of image?
	comp.m	#Img_2_End
	ifn.car	.Img_4_Init
	
	jump	.Img_2_Loop

	
.Img_2_NL:
	push.m	;temporarily store image pointer
	
	load.m	GPU_WRITEADDR
	
	add.m	#((VMODE_2_WIDTH / 8) - Img_2_W)
	store.m	GPU_WRITEADDR
	
	load.b	#Img_2_W
	pull.m
	
	jump .Img_2_Loop





.Img_4_Init:
	;jump	.Img_6_Init
	
	subr	WAIT
	subr	WAIT
	subr	WAIT
	subr	CLEAR_VRAM
	
	load.m	#0
	store.m	GPU_WRITEADDR
	store.m	GPU_OFFSET
	
	load.a	#4
	store.a	GPU_VMODE
	load.m	#(Img_4 - 1)
	load.b	#Img_4_W

.Img_4_Loop:
	inc.m
	dec.b
	
	load.a	M
	store.a	GPU_WRITEBYTE
	
	; is end of line?
	ifz.b	.Img_4_NL
	
	
	; is end of image?
	comp.m	#Img_4_End
	ifn.car	.Img_6_Init
	
	jump	.Img_4_Loop

	
.Img_4_NL:
	push.m	;temporarily store image pointer
	
	load.m	GPU_WRITEADDR
	
	add.m	#((VMODE_4_WIDTH / 2) - Img_4_W)
	store.m	GPU_WRITEADDR
	
	load.b	#Img_4_W
	pull.m
	
	jump .Img_4_Loop




.Img_6_Init:
	subr	WAIT
	subr	WAIT
	subr	WAIT
	subr	CLEAR_VRAM
	
	load.m	#0
	store.m	GPU_WRITEADDR
	store.m	GPU_OFFSET
	
	load.a	#6
	store.a	GPU_VMODE
	load.m	#(Img_6 - 1)
	load.b	#Img_6_W

.Img_6_Loop:
	inc.m
	dec.b
	
	load.a	M
	store.a	GPU_WRITEBYTE
	
	; is end of line?
	ifz.b	.Img_6_NL
	
	
	; is end of image?
	comp.m	#Img_6_End
	ifn.car	.Img_2_Init
	
	jump	.Img_6_Loop

	
.Img_6_NL:
	push.m	;temporarily store image pointer
	
	load.m	GPU_WRITEADDR
	
	add.m	#((VMODE_6_WIDTH) - Img_6_W) + 1
	store.m	GPU_WRITEADDR
	
	load.b	#Img_6_W - 1
	pull.m
	
	jump .Img_6_Loop




CLEAR_VRAM:
	load.m	#0
	store.m	GPU_WRITEADDR
	load.a	#0
.loop:
	store.a	GPU_WRITEBYTE
	inc.m
	comp.m	#0
	ifn.c	.loop
	
	return





Img_W	=	61

Img_2:
	#include	"images/img_2.asm"
Img_2_End	=	pc
Img_2_W	=	Img_W / 8



Img_4:
	#include	"images/img_4.asm"
Img_4_End	=	pc
Img_4_W	=	Img_W / 2



Img_6:
	#include	"images/img_6.asm"
Img_6_End	=	pc
Img_6_W	=	Img_W
	

END:
	jump	END


WAIT:
	load.a	#255
	
.loop1:	load.b	#200
	
.loop2:	load.m	#0

.loop3:	inc.m
	comp.m	#0
	ifn.c	.loop3
	
	inc.b
	ifnz.b	.loop2
	
	inc.a
	ifnz.a	.loop1
	
RETURN:	return
