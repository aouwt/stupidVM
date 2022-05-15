#define OP(name) \
	static void name (SMP100 *_this)
#define IStor_8 \
	_this -> Bus.word
#define IStor_16 \
	((IStor_8 << 8) | IStor3_8)

#define IStor2_8 \
	_this -> Reg.IStor2
#define IStor2_16 \
	((IStor2_8 << 8) | IStor3_8)
#define IStor3_8 \
	_this -> Reg.IStor

OP (readnext) {
	_this -> Bus = {
		.RW = READ,
		.addr = _this -> PC ++
	};
}

OP (store_next) {
	_this -> Reg.IStor = IStor_8;
	_this -> Bus = {
		.RW = READ,
		.addr = _this -> PC ++
	};
}


OP (readval) {
	_this -> Bus = {
		.RW = READ,
		.addr = IStor_16
	};
}

OP (readval2) {
	_this -> Reg.IStor = IStor_8;
	_this -> Bus.RW = READ;
	_this -> Bus.addr ++;
}


OP (readm) {
	_this -> Bus = {
		.RW = READ,
		.addr = _this -> Reg.M
	};
}


OP (writeval) {
	_this -> Bus = {
		.RW = WRITE,
		.addr = IStor_16,
		.word = IStor2_8
	};
}

OP (writeval2) {
	_this -> Bus.RW = WRITE;
	_this -> Bus.word = IStor3_8;
	_this -> Bus.addr ++;
}


OP (runopcode) { _this -> Operation = OpFuncs [_this -> Bus.Word] - 1; }


OP (inc_stk)	{ _this -> Reg.StkCounter ++; }
OP (dec_stk)	{ _this -> Reg.StkCounter --; }

OP (write_stk) {
	_this -> Bus = {
		.RW = WRITE,
		.addr = _this -> Reg.StkCounter,
		.word = IStor2_8
	};
}

OP (write_stk2) {
	_this -> Bus = {
		.RW = WRITE,
		.addr = _this -> Reg.StkCounter,
		.word = IStor3_8
	};
}


OP (read_stk) {
	_this -> Bus = {
		.RW = READ,
		.addr = _this -> Reg.StkCounter
	};
}

OP (read_stk2) {
	IStor3_8 = IStor_8
	_this -> Bus = {
		.RW = READ,
		.addr = _this -> Reg.StkCounter
	};
}

OP (nothing) {}

OP (load_a)	{ _this -> Reg.A = IStor_8; }
OP (load_b)	{ _this -> Reg.B = IStor_8; }
OP (load_m)	{ _this -> Reg.M = IStor_16; }

OP (jump_rel)	{ _this -> Reg.PC += IStor_8; }
OP (jump_adr)	{ _this -> Reg.PC = IStor_16; }

OP (write_a)	{ IStor2_8 = _this -> Reg.A; }
OP (write_b)	{ IStor2_8 = _this -> Reg.B; }
OP (write_m)	{ IStor2_8 = _this -> Reg.M & 0xFF00; IStor3_8 = _this -> Reg.M & 0x00FF; }

OP (add_a)	{ _this -> Reg.A += IStor_8; }
OP (add_b)	{ _this -> Reg.B += IStor_8; }
OP (add_a_b)	{ _this -> Reg.A += _this -> Reg.B; }
OP (add_b_a)	{ _this -> Reg.B += _this -> Reg.A; }
OP (add_m)	{ _this -> Reg.M += IStor_16; }

OP (subr)	{ IStor2_8 = (_this -> Reg.PC + 2) && 0xFF00; IStor3_8 = (_this -> Reg.PC + 2) & 0x00FF; }

OP (comp_a)	{ _this -> Reg.C = (_this -> Reg.A == IStor_8); _this -> Reg.Carry = (_this -> Reg.A < IStor_8); }
OP (comp_b)	{ _this -> Reg.C = (_this -> Reg.B == IStor_8); _this -> Reg.Carry = (_this -> Reg.B < IStor_8); }
OP (comp_a_b)	{ _this -> Reg.C = (_this -> Reg.A == _this -> Reg.B); _this -> Reg.Carry = (_this -> Reg.A < _this -> Reg.B); }
OP (comp_b_a)	{ _this -> Reg.C = (_this -> Reg.B == _this -> Reg.A); _this -> Reg.Carry = (_this -> Reg.B < _this -> Reg.A); }
OP (comp_m)	{ _this -> Reg.C = (_this -> Reg.M == IStor_16); _this -> Reg.Carry = (_this -> Reg.M < IStor_16); }

#undef OP
#define OP(name, ...) \
	const OpFunc_ ## name [] = { __VA_ARGS__, NULL };

#define IMM	&readnext
#define ABS	&readnext, &store_next, &readval
#define MAD	&readm

#define IMM16	&readnext, &store_next
#define ABS16	&readnext, &store_next, &readval, &readval2
#define M16	&readm, &readval2

#define PUSH	&inc_stk, &write_stk
#define PULL	&read_stk, &dec_stk

#define PUSH16	&inc_stk, &write_stk, &inc_stk, &write_stk2
#define PULL16	&read_stk, &dec_stk, &read_stk2, &dec_stk

#define WRITE	&writeval
#define WRITE16	&writeval, &writeval2

OP (BeginCycle,	IMM, &runopcode);

OP (LoadA_Imm,	IMM, &load_a);
OP (LoadA_Abs,	ABS, &load_a);
OP (LoadA_M,	MAD, &load_a);

OP (LoadB_Imm,	IMM, &load_b);
OP (LoadB_Abs,	ABS, &load_b);
OP (LoadB_M,	MAD, &load_b);

OP (LoadM_Imm,	IMM16, &load_m);
OP (LoadM_Abs,	ABS16, &load_m);
OP (LoadM_M,	M16, &load_m);


OP (Jump_Rel,	IMM, &jump_rel);
OP (Jump_Adr,	IMM16, &jump_adr);
OP (Jump_M,	M16, &jump_adr);


OP (StoreA_Adr,	IMM16, &write_a, WRITE);
OP (StoreA_M,	M16, &write_a, WRITE);

OP (StoreB_Adr,	IMM16, &write_b, WRITE);
OP (StoreB_M,	M16, &write_b, WRITE);

OP (StoreM_Adr,	IMM16, &write_m, WRITE16);
OP (StoreM_M,	M16, &write_m, WRITE16); // invalid opcode :D


OP (AddA_Imm,	IMM, &add_a);
OP (AddA_Abs,	ABS, &add_a);
OP (AddA_M,	MAD, &add_a);
OP (AddA_B,	&add_a_b);

OP (AddB_Imm,	IMM, &add_b);
OP (AddB_Abs,	ABS, &add_b);
OP (AddB_M,	MAD, &add_b);
OP (AddB_A,	&add_b_a);

OP (AddM_Imm,	IMM16, &add_m);
OP (AddM_Abs,	ABS16, &add_m);
OP (AddM_M,	M16, &add_m);


//OP (SubA_Imm,	IMM, 


OP (CompA_Imm,	IMM, &comp_a);
OP (CompA_Abs,	ABS, &comp_a);
OP (CompA_M,	MAD, &comp_a);
OP (CompA_B,	&comp_a_b);

OP (CompB_Imm,	IMM, &comp_b);
OP (CompB_Abs,	ABS, &comp_b);
OP (CompB_M,	MAD, &comp_b);
OP (CompB_A,	&comp_b_a);

OP (CompM_Imm,	IMM16, &comp_m);
OP (CompM_Abs,	ABS16, &comp_m);

// NOTE: really stupid
OP (Subr_Adr,	&subr, PUSH16, IMM16, &jump_adr);
OP (Subr_M,	&subr, PUSH16, M16, &jump_adr);



