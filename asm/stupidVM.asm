#cpudef {
	#bits 8
	
	dontuseme	=>	0x00	;it wont assemble without this?
	
	load.a #{value}	=>	0x00 @ value[7:0]
	load.a {addr}	=>	0x01 @ addr[7:0] @ addr[15:8]
	load.a m	=>	0x02
	
	load.b #{value}	=>	0x04 @ value[7:0]
	load.b {addr}	=>	0x05 @ addr[7:0] @ addr[15:8]
	load.b m	=>	0x06
	
	load.m #{value}	=>	0x08 @ value[7:0] @ value[15:8]
	load.m {addr}	=>	0x09 @ addr[7:0] @ addr[15:8]
	
	
	jump {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x0C @ (addr-pc-2)[7:0]		}
	jump {addr}	=>	0x0D @ addr[7:0] @ addr[15:8]
	jump m 		=>	0x0E
	
	
	add.a #{value}	=>	0x10 @ value[7:0]
	add.a {addr}	=>	0x11 @ addr[7:0] @ addr[15:8]
	add.a m		=>	0x12
	add.a b		=>	0x13
	
	add.b #{value}	=>	0x14 @ value[7:0]
	add.b {addr}	=>	0x15 @ addr[7:0] @ addr[15:8]
	add.b m		=>	0x16
	add.b a		=>	0x17
	
	add.m #{value}	=>	0x18 @ value[7:0]
	add.m {addr}	=>	0x19 @ addr[7:0] @ addr[15:8]
	
	
	;subr {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
	;				assert((addr-pc-2) >= 0x00)
	;				0x1C @ (addr-pc-2)[7:0]		}
	subr {addr}	=>	0x1D @ addr[7:0] @ addr[15:8]
	;subr m 	=>	0x1E
	
	
	
	
	sub.a #{value}	=>	0x20 @ value[7:0]
	sub.a {addr}	=>	0x21 @ addr[7:0] @ addr[15:8]
	sub.a m		=>	0x22
	sub.a b		=>	0x23
	
	sub.b #{value}	=>	0x24 @ value[7:0]
	sub.b {addr}	=>	0x25 @ addr[7:0] @ addr[15:8]
	sub.b m		=>	0x26
	sub.b a		=>	0x27
	
	sub.m #{value}	=>	0x28 @ value[7:0]
	sub.m {addr}	=>	0x29 @ addr[7:0] @ addr[15:8]
	
	
	comp.a #{value}	=>	0x30 @ value[7:0]
	comp.a {addr}	=>	0x31 @ addr[7:0] @ addr[15:8]
	comp.a m	=>	0x32
	comp.a b	=>	0x33
	
	comp.b #{value}	=>	0x34 @ value[7:0]
	comp.b {addr}	=>	0x35 @ addr[7:0] @ addr[15:8]
	comp.b m	=>	0x36
	comp.b a	=>	0x37
	
	comp.m #{value}	=>	0x38 @ value[7:0]
	comp.m {addr}	=>	0x39 @ addr[7:0] @ addr[15:8]
	
	
	store.a {addr}	=>	0x41 @ addr[7:0] @ addr[15:8]
	store.a m	=>	0x42
	
	store.b {addr}	=>	0x45 @ addr[7:0] @ addr[15:8]
	store.b m	=>	0x46
	
	store.m {addr}	=>	0x49 @ addr[7:0] @ addr[15:8]
	
	
	and.a #{value}	=>	0x50 @ value[7:0]
	and.a {addr}	=>	0x51 @ addr[7:0] @ addr[15:8]
	
	xor.a #{value}	=>	0x52 @ value[7:0]
	xor.a {addr}	=>	0x53 @ addr[7:0] @ addr[15:8]
	
	
	and.b #{value}	=>	0x54 @ value[7:0]
	and.b {addr}	=>	0x55 @ addr[7:0] @ addr[15:8]
	
	xor.b #{value}	=>	0x56 @ value[7:0]
	xor.b {addr}	=>	0x57 @ addr[7:0] @ addr[15:8]
	
	
	ifz.a {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x60 @ (addr-pc-2)[7:0]		}
	ifz.a {addr}	=>	0x61 @ addr[7:0] @ addr[15:8]
	
	or.a #{value}	=>	0x62 @ value[7:0]
	or.a {addr}	=>	0x63 @ addr[7:0] @ addr[15:8]
	
	
	ifz.b {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x64 @ (addr-pc-2)[7:0]		}
	ifz.b {addr}	=>	0x65 @ addr[7:0] @ addr[15:8]
	
	or.b #{value}	=>	0x66 @ value[7:0]
	or.b {addr}	=>	0x67 @ addr[7:0] @ addr[15:8]
	
	
	if.c {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x68 @ (addr-pc-2)[7:0]		}
	if.c {addr}	=>	0x69 @ addr[7:0] @ addr[15:8]		;noice
	
	if.car {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x6C @ (addr-pc-2)[7:0]		}
	if.car {addr}	=>	0x6D @ addr[7:0] @ addr[15:8]
	
	
	ifnz.a {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x70 @ (addr-pc-2)[7:0]		}
	ifnz.a {addr}	=>	0x71 @ addr[7:0] @ addr[15:8]
	
	ifnz.b {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x74 @ (addr-pc-2)[7:0]		}
	ifnz.b {addr}	=>	0x75 @ addr[7:0] @ addr[15:8]
	
	
	ifn.c {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x78 @ (addr-pc-2)[7:0]		}
	ifn.c {addr}	=>	0x79 @ addr[7:0] @ addr[15:8]
	
	ifn.car {addr}	=>	{	assert((addr-pc-2) <= 0xFF)
					assert((addr-pc-2) >= 0x00)
					0x7C @ (addr-pc-2)[7:0]		}
	ifn.car {addr}	=>	0x7D @ addr[7:0] @ addr[15:8]
	
	
	
	
	lsh.a	=>	0x80
	rsh.a	=>	0x81
	
	lrot.a	=>	0x82
	rrot.a	=>	0x83
	
	
	lsh.b	=>	0x84
	rsh.b	=>	0x85
	
	lrot.b	=>	0x86
	rrot.b	=>	0x87
	
	
	lsh.m	=>	0x88
	rsh.m	=>	0x89
	
	lrot.m	=>	0x8A
	rrot.m	=>	0x8B
	
	
	
	push.a	=>	0x90
	pull.a	=>	0x91
	
	inc.a	=>	0x92
	dec.a	=>	0x93	
	
	
	push.b	=>	0x94
	pull.b	=>	0x95
	
	inc.b	=>	0x96
	dec.b	=>	0x97
		
	
	push.m	=>	0x98
	pull.m	=>	0x99
	
	inc.m	=>	0x9A
	dec.m	=>	0x9B
	
	
	push.pc	=>	0x9C
	pull.pc	=>	0x9D
	return	=>	0x9D	; alias
	
	
	move.a-b	=>	0xA1
	move.a-ma	=>	0xA2
	move.a-am	=>	0xA3
	
	move.b-a	=>	0xA4
	move.b-bm	=>	0xA6
	move.b-mb	=>	0xA7
	
	move.ab-m	=>	0xA8
	move.ba-m	=>	0xA9
	
	move.m-ab	=>	0xAA	;me when writing this
	move.m-ba	=>	0xAB
	
	
	set.c		=>	0xB8
	set.car		=>	0xBC
	
	clear.c		=>	0xC8
	clear.car	=>	0xCC
	
	
	break		=>	0xFF
}

#bankdef srom	{
	#addr	0xA000
	#size	0x5EFF
	#outp	0x0000
}

;#bankdef brom	{
;	#addr	0x2000
;	#size	0x7FFF
;	#outp	0x5F00
;}

SRAM_BEGIN	=	0x0000
SRAM_END	=	0x1F00

BANK_BEGIN	=	0x2000
BANK_END	=	0x9FFF

SROM_BEGIN	=	0xA000
SROM_END	=	0xFEFF

DEVICEREGS_BEGIN=	0xFF00
DEVICEREGS_END	=	0xFFFF

SRAM_SIZE	=	(SRAM_END - SRAM_BEGIN)
BANK_SIZE	=	(BANK_END - BANK_BEGIN)
SROM_SIZE	=	(SROM_END - SROM_BEGIN)
DEVICEREGS_SIZE	=	(DEVICEREGS_END - DEVICEREGS_BEGIN)

DEVICE_SYS	=	(DEVICEREGS_BEGIN + 0x00)	; 16 bytes
DEVICE_GSU	=	(DEVICEREGS_BEGIN + 0x10)	; 16 bytes


GPU_WRITEBYTE	=	(DEVICE_GSU + 0x0)	; 1 byte
GPU_WRITEADDR	=	(DEVICE_GSU + 0x1)	; 2 bytes
GPU_OFFSET	=	(DEVICE_GSU + 0x2)	; 1 byte
GPU_VMODE	=	(DEVICE_GSU + 0x3)	; 1 byte

SPU_CH1_WAVE	=	(DEVICE_GSU + 0x4)	; 4 bytes
SPU_CH2_WAVE	=	(DEVICE_GSU + 0x8)	; 4 bytes
SPU_CH1_PITCH	=	(DEVICE_GSU + 0xB)	; 2 bytes
SPU_CH2_PITCH	=	(DEVICE_GSU + 0xD)	; 2 bytes
SPU_CH1_VOL	=	(DEVICE_GSU + 0xE)	; 1 byte
SPU_CH2_VOL	=	(DEVICE_GSU + 0xF)	; 1 byte

BANKNO		=	(DEVICE_SYS + 0x00)	; 1 byte

VMODE_TEXT	=	0
VMODE_HIRES	=	1
VMODE_COLOR	=	2
VMODE_HICOLOR	=	3
