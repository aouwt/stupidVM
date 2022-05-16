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

template <typename T>
	T rotate_left (T val) {
		return (val << 1) | ((val & (1 << (sizeof (T) * 8 - 1))) != 0);
	}

template <typename T>
	T rotate_right (T val) {
		return (val >> 1) | ((val & 1) << (sizeof (T) * 8 - 1));
	}

template <typename T>
	T rotate_left (T val, bool carry) {
		return rotate_left <T> (val) | carry;
	}

template <typename T>
	T rotate_right (T val, bool carry) {
		return rotate_right <T> (val) | (carry << (sizeof (T) * 8 - 1));
	}


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
OP (write_pc)	{ IStor2_8 = _this -> Reg.PC & 0xFF00; IStor3_8 = _this -> Reg.PC & 0x00FF; }

OP (add_a)	{ _this -> Reg.A += IStor_8; }
OP (add_b)	{ _this -> Reg.B += IStor_8; }
OP (add_a_b)	{ _this -> Reg.A += _this -> Reg.B; }
OP (add_b_a)	{ _this -> Reg.B += _this -> Reg.A; }
OP (add_m)	{ _this -> Reg.M += IStor_16; }

OP (sub_a)	{ _this -> Reg.A -= IStor_8; }
OP (sub_b)	{ _this -> Reg.B -= IStor_8; }
OP (sub_a_b)	{ _this -> Reg.A -= _this -> Reg.B; }
OP (sub_b_a)	{ _this -> Reg.B -= _this -> Reg.A; }
OP (sub_m)	{ _this -> Reg.M -= IStor_16; }

OP (comp_a)	{ _this -> Reg.C = (_this -> Reg.A == IStor_8); _this -> Reg.Carry = (_this -> Reg.A < IStor_8); }
OP (comp_b)	{ _this -> Reg.C = (_this -> Reg.B == IStor_8); _this -> Reg.Carry = (_this -> Reg.B < IStor_8); }
OP (comp_a_b)	{ _this -> Reg.C = (_this -> Reg.A == _this -> Reg.B); _this -> Reg.Carry = (_this -> Reg.A < _this -> Reg.B); }
OP (comp_b_a)	{ _this -> Reg.C = (_this -> Reg.B == _this -> Reg.A); _this -> Reg.Carry = (_this -> Reg.B < _this -> Reg.A); }
OP (comp_m)	{ _this -> Reg.C = (_this -> Reg.M == IStor_16); _this -> Reg.Carry = (_this -> Reg.M < IStor_16); }

OP (lsh_a)	{ _this -> Reg.A = rotate_left (_this -> Reg.A, _this -> Reg.Carry); } // let auto carry functions handle carry
OP (rsh_a)	{ _this -> Reg.A = rotate_right (_this -> Reg.A, _this -> Reg.Carry); }
OP (lsh_b)	{ _this -> Reg.B = rotate_left (_this -> Reg.B, _this -> Reg.Carry); }
OP (rsh_b)	{ _this -> Reg.B = rotate_right (_this -> Reg.B, _this -> Reg.Carry); }
OP (lsh_m)	{ _this -> Reg.M = rotate_left (_this -> Reg.M, _this -> Reg.Carry); }
OP (rsh_m)	{ _this -> Reg.M = rotate_right (_this -> Reg.M, _this -> Reg.Carry); }
OP (lsh_pc)	{ _this -> Reg.PC = rotate_left (_this -> Reg.PC, _this -> Reg.Carry); }
OP (rsh_pc)	{ _this -> Reg.PC = rotate_right (_this -> Reg.PC, _this -> Reg.Carry); }

OP (lrot_a)	{ _this -> Reg.A = rotate_left <uint8_t> (_this -> Reg.A); } // we dont want carry to trigger so we must tell it to only rotate the last byte
OP (rrot_a)	{ _this -> Reg.A = rotate_right <uint8_t> (_this -> Reg.A); }
OP (lrot_b)	{ _this -> Reg.B = rotate_left <uint8_t> (_this -> Reg.B); }
OP (rrot_b)	{ _this -> Reg.B = rotate_right <uint8_t> (_this -> Reg.B); }
OP (lrot_m)	{ _this -> Reg.M = rotate_left <uint16_t> (_this -> Reg.M); }
OP (rrot_m)	{ _this -> Reg.M = rotate_right <uint16_t> (_this -> Reg.M); }
OP (lrot_pc)	{ _this -> Reg.PC = rotate_left <uint16_t> (_this -> Reg.PC); }
OP (rrot_pc)	{ _this -> Reg.PC = rotate_right <uint16_t> (_this -> Reg.PC); }

OP (inc_a)	{ _this -> Reg.A ++; }
OP (dec_a)	{ _this -> Reg.A --; }
OP (inc_b)	{ _this -> Reg.B ++; }
OP (dec_b)	{ _this -> Reg.B --; }
OP (inc_m)	{ _this -> Reg.M ++; }
OP (dec_m)	{ _this -> Reg.M --; }
OP (inc_pc)	{ _this -> Reg.PC ++; }
OP (dec_pc)	{ _this -> Reg.PC --; }

OP (clr_car)	{ _this -> Reg.Carry = false; }
OP (clr_c)	{ _this -> Reg.C = false; }


OP (subr)	{ IStor2_8 = (_this -> Reg.PC + 2) && 0xFF00; IStor3_8 = (_this -> Reg.PC + 2) & 0x00FF; }
#undef OP
#define OP(name, ...) \
	const SMP100::OpFunc OpFunc_ ## name [] = { __VA_ARGS__, NULL };

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


OP (SubA_Imm,	IMM, &sub_a);
OP (SubA_Abs,	ABS, &sub_a);
OP (SubA_M,	MAD, &sub_a);
OP (SubA_B,	&sub_a_b);

OP (SubB_Imm,	IMM, &sub_b);
OP (SubB_Abs,	ABS, &sub_b);
OP (SubB_M,	MAD, &sub_b);
OP (SubB_A,	&sub_b_a);

OP (SubM_Imm,	IMM16, &sub_m);
OP (SubM_Abs,	ABS16, &sub_m);
OP (SubM_M,	M16, &sub_m);


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


OP (LShA,	&lsh_a);
OP (RShA,	&rsh_a);
OP (LShB,	&lsh_b);
OP (RShB,	&rsh_b);
OP (LShM,	&lsh_m, &nothing);
OP (RShM,	&rsh_m, &nothing);
OP (LShPC,	&lsh_pc, &nothing);
OP (RShPC,	&rsh_pc, &nothing);

OP (LRotA,	&clr_car, &lrot_a);
OP (RRotA,	&clr_car, &rrot_a);
OP (LRotB,	&clr_car, &lrot_b);
OP (RRotB,	&clr_car, &rrot_b);
OP (LRotM,	&clr_car, &lrot_m, &nothing);
OP (RRotM,	&clr_car, &rrot_m, &nothing);
OP (LRotPC,	&clr_car, &lrot_pc, &nothing);
OP (RRotPC,	&clr_car, &rrot_pc, &nothing);


OP (PushA,	&write_a, PUSH);
OP (PullA,	PULL, &load_a);
OP (IncA,	&inc_a);
OP (DecA,	&dec_a);

OP (PushB,	&write_b, PUSH);
OP (PullB,	PULL, &load_b);
OP (IncB,	&inc_b);
OP (DecB,	&dec_b);

OP (PushM,	&write_m, PUSH16);
OP (PullM,	PULL, &load_m);
OP (IncM,	&inc_m);
OP (DecM,	&dec_m);

OP (PushPC,	&write_pc, PUSH16);
OP (PullPC,	PULL16, &jump_adr);
OP (IncPC,	&inc_pc);
OP (DecPC,	&dec_pc);

OP (Subr_Adr,	&subr, &nothing, PUSH16, IMM16, &jump_adr);
OP (Subr_M,	&subr, &nothing, PUSH16, M16, &jump_adr);

OP (NullOp,	&nothing);

// OPCODES!!!! FINALLY!!!!
#undef OP
#define OP(name)	&OpFunc_ ## name
const SMP100::OpFunc SMP100::OpFuncs [] = {
	// 0x00 - 0x0F
	OP (LoadA_Imm),	OP (LoadA_Abs),	OP (LoadA_M),	OP (NullOp),
	OP (LoadB_Imm),	OP (LoadB_Abs),	OP (LoadB_M),	OP (NullOp),
	OP (LoadM_Imm),	OP (LoadM_Abs),	OP (LoadM_M),	OP (NullOp),
	OP (Jump_Rel),	OP (Jump_Abs),	OP (Jump_M),	OP (NullOp),
	
	// 0x10 - 0x1F
	OP (AddA_Imm),	OP (AddA_Abs),	OP (AddA_M),	OP (AddA_B),
	OP (AddB_Imm),	OP (AddB_Abs),	OP (AddB_M),	OP (AddB_A),
	OP (AddM_Imm),	OP (AddM_Abs),	OP (AddM_M),	OP (AddM_AB),
	OP (NullOp),	OP (Subr_Adr),	OP (Subr_M),	OP (NullOp),
	
	// 0x20 - 0x2F
	OP (SubA_Imm),	OP (SubA_Abs),	OP (SubA_M),	OP (SubA_B),
	OP (SubB_Imm),	OP (SubB_Abs),	OP (SubB_M),	OP (SubB_A),
	OP (SubM_Imm),	OP (SubM_Abs),	OP (SubM_M),	OP (SubM_AB),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	
	// 0x30 - 0x3F
};
