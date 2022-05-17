	#include	"stupidVM.asm"
	
#bank srom
	load.m	#0
	store.m	GPU_OFFSET
	store.m	GPU_WRITEADDR
	


	

textmode:
	subr	init
	load.a	#1
	store.a	GPU_VMODE
	load.a	#176
.charloop:
	inc.b
	store.a	GPU_WRITEBYTE
	
	ifnz.b	.charloop
	
	inc.a
	comp.a	#179
	ifn.c	.charloop
	
	
	
	load.m	#32768
	store.m	GPU_WRITEADDR
	
	
	
	load.b	#0
.loop:
	store.b	GPU_WRITEBYTE
	store.b	GPU_WRITEBYTE
	store.b	GPU_WRITEBYTE
	inc.b
	
	ifnz.b	.loop






m4:
	subr	init
	load.a	#4
	store.a	GPU_VMODE
.loop:
	;move.b-a
	;lsh.a
	;lsh.a
	;lsh.a
	;lsh.a
	;add.a	B
	store.b	GPU_WRITEBYTE
	
	inc.b
	comp.b	#16
	ifn.c	.loop
	
	load.b	#0
	jump	.loop





m8:
	subr	init
	load.a	#7
	store.a	GPU_VMODE
.loop:
	store.b	GPU_WRITEBYTE
	inc.b
	ifnz.b	.loop
	
	jump	textmode








init:
	load.m	#0
	store.m	GPU_WRITEADDR
	load.a	#220
.loop:
	load.m	#0
.loop2:
	inc.m
	comp.m	#0
	ifn.c	.loop2
	
	inc.a
	ifnz.a	.loop
	
	load.m	#0
.clearvram:
	store.a	GPU_WRITEBYTE
	inc.m
	comp.m	#0
	ifn.c	.clearvram
	
	load.b	#0
	load.a	#0
	return
