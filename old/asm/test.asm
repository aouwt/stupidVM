	#include	"stupidVM.asm"
step	=	0x00

#bank srom
.start:
	load.m	#440
	store.m	SND_CH0_PITCH
	
	load.a	#255
	store.a	SND_CH0_VOL
	
	load.b	#127
	store.b	SND_CH0_WAVE
	
	load.a	#6
	store.a	GPU_VMODE
	
.reset:
	load.m	#0
	store.m	GPU_WRITEADDR
	load.m	#sine
	load.a	step
.reset2:
	add.a	#1
	ifz.a	.reset2
	store.a	step
.loop:
	load.a	M
	store.a	SND_CH0_VOL
	store.a	GPU_WRITEBYTE
	add.m	step
	comp.m	#sine_end-1
	ifn.car	.reset
	jump	.loop

sine:
	#include	"sin.asm"
sine_end:
