#include "cpu.hpp"

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
		return (val << 1) | ((val & ((T) 1 << (sizeof (T) * 8 - 1))) != 0);
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
		return rotate_right <T> (val) | ((T) carry << (sizeof (T) * 8 - 1));
	}


OP (readnext) {
	_this -> Bus = {
		.RW = RW_READ,
		.addr = _this -> Reg.PC ++
	};
}

OP (store_next) {
	_this -> Reg.IStor = IStor_8;
	_this -> Bus = {
		.RW = RW_READ,
		.addr = _this -> Reg.PC ++
	};
}


OP (readval) {
	_this -> Bus = {
		.RW = RW_READ,
		.addr = IStor_16
	};
}

OP (readval2) {
	_this -> Reg.IStor = IStor_8;
	_this -> Bus.RW = RW_READ;
	_this -> Bus.addr ++;
}


OP (readm) {
	_this -> Bus = {
		.RW = RW_READ,
		.addr = _this -> Reg.M
	};
}


OP (writeval) {
	_this -> Bus = {
		.RW = RW_WRITE,
		.addr = IStor_16,
		.word = IStor2_8
	};
}

OP (writeval2) {
	_this -> Bus.RW = RW_WRITE;
	_this -> Bus.word = IStor3_8;
	_this -> Bus.addr ++;
}


OP (runopcode) { _this -> Operation = SMP100::OpFuncs [_this -> Bus.word] - 1; }


OP (inc_stk)	{ _this -> Reg.StackPtr ++; }
OP (dec_stk)	{ _this -> Reg.StackPtr --; }

OP (write_stk) {
	_this -> Bus = {
		.RW = RW_WRITE,
		.addr = _this -> Reg.StackPtr,
		.word = IStor2_8
	};
}

OP (write_stk2) {
	_this -> Bus = {
		.RW = RW_WRITE,
		.addr = _this -> Reg.StackPtr,
		.word = IStor3_8
	};
}


OP (read_stk) {
	_this -> Bus = {
		.RW = RW_READ,
		.addr = _this -> Reg.StackPtr
	};
}

OP (read_stk2) {
	IStor3_8 = IStor_8;
	_this -> Bus = {
		.RW = RW_READ,
		.addr = _this -> Reg.StackPtr
	};
}


OP (cond_rel) {
	if (IStor2_8)
		_this -> Reg.PC += IStor_8;
}
OP (cond_adr) {
	if (IStor2_8)
		_this -> Reg.PC = IStor_16;
}

OP (ncond_rel) {
	if (IStor2_8 == false)
		_this -> Reg.PC += IStor_8;
}
OP (ncond_adr) {
	if (IStor2_8 == false)
		_this -> Reg.PC = IStor_16;
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

OP (set_car)	{ _this -> Reg.Carry = true; }
OP (set_c)	{ _this -> Reg.C = true; }

OP (and_a)	{ _this -> Reg.A &= IStor_8; }
OP (and_b)	{ _this -> Reg.B &= IStor_8; }
OP (xor_a)	{ _this -> Reg.A ^= IStor_8; }
OP (xor_b)	{ _this -> Reg.B ^= IStor_8; }
OP (or_a)	{ _this -> Reg.A |= IStor_8; }
OP (or_b)	{ _this -> Reg.B |= IStor_8; }
OP (nor_a)	{ _this -> Reg.A |= ~ IStor_8; }
OP (nor_b)	{ _this -> Reg.B |= ~ IStor_8; }

OP (if0_a)	{ IStor2_8 = _this -> Reg.A == 0; }
OP (if0_b)	{ IStor2_8 = _this -> Reg.B == 0; }
OP (if_c)	{ IStor2_8 = _this -> Reg.C; }
OP (if_car)	{ IStor2_8 = _this -> Reg.Carry; }

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
OP (CompM_M,	M16, &comp_m);


OP (AndA_Imm,	IMM, &and_a);
OP (AndA_Abs,	ABS, &and_a);
OP (AndB_Imm,	IMM, &and_b);
OP (AndB_Abs,	ABS, &and_b);

OP (XOrA_Imm,	IMM, &xor_a);
OP (XOrA_Abs,	ABS, &xor_a);
OP (XOrB_Imm,	IMM, &xor_b);
OP (XOrB_Abs,	ABS, &xor_b);


OP (OrA_Imm,	IMM, &or_a);
OP (OrA_Abs,	ABS, &or_a);
OP (OrB_Imm,	IMM, &or_b);
OP (OrB_Abs,	ABS, &or_b);

OP (NOrA_Imm,	IMM, &nor_a);
OP (NOrA_Abs,	ABS, &nor_a);
OP (NOrB_Imm,	IMM, &nor_b);
OP (NOrB_Abs,	ABS, &nor_b);


OP (IfZA_Rel,	IMM, &if0_a, &cond_rel);
OP (IfZA_Adr,	IMM16, &if0_a, &cond_adr);
OP (IfZB_Rel,	IMM, &if0_b, &cond_rel);
OP (IfZB_Adr,	IMM16, &if0_b, &cond_adr);
OP (IfC_Rel,	IMM, &if_c, &cond_rel);
OP (IfC_Adr,	IMM16, &if_c, &cond_adr);
OP (IfCar_Rel,	IMM, &if_car, &cond_rel);
OP (IfCar_Adr,	IMM16, &if_car, &cond_adr);

OP (IfNZA_Rel,	IMM, &if0_a, &ncond_rel);
OP (IfNZA_Adr,	IMM16, &if0_a, &ncond_adr);
OP (IfNZB_Rel,	IMM, &if0_b, &ncond_rel);
OP (IfNZB_Adr,	IMM16, &if0_b, &ncond_adr);
OP (IfNC_Rel,	IMM, &if_c, &ncond_rel);
OP (IfNC_Adr,	IMM16, &if_c, &ncond_adr);
OP (IfNCar_Rel,	IMM, &if_car, &ncond_rel);
OP (IfNCar_Adr,	IMM16, &if_car, &ncond_adr);



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


OP (MoveA_A,	&nothing);
OP (MoveA_B,	&move_a_b);
OP (MoveA_MA,	&move_a_ma);
OP (MoveA_AM,	&move_a_am);

OP (MoveB_A,	&move_b_a);
OP (MoveB_B,	&nothing);
OP (MoveB_BM,	&move_b_bm);
OP (MoveB_MB,	&move_b_mb);

OP (MoveAB_M,	&move_ab_m);
OP (MoveBA_M,	&move_ba_m);
OP (MoveM_AB,	&move_m_ab);
OP (MoveM_BA,	&move_m_ba);


OP (SetC,	&set_c);
OP (SetCar,	&set_car);
OP (ClearC,	&clr_c);
OP (ClearCar,	&clr_car);


OP (RetI,	&reti);
OP (SetI,	IMM16, &seti); // reti, seti, spagheti
OP (Int,	IMM, &prep_int);

OP (NullOp,	&nothing);

// OPCODES!!!! FINALLY!!!!
#undef OP
#define OP(name)	OpFunc_ ## name
const SMP100::OpFunc *SMP100::OpFuncs [] = {
	// 0x00 - 0x0F
	OP (LoadA_Imm),	OP (LoadA_Abs),	OP (LoadA_M),	OP (NullOp),
	OP (LoadB_Imm),	OP (LoadB_Abs),	OP (LoadB_M),	OP (NullOp),
	OP (LoadM_Imm),	OP (LoadM_Abs),	OP (LoadM_M),	OP (NullOp),
	OP (Jump_Rel),	OP (Jump_Adr),	OP (Jump_M),	OP (NullOp),
	
	// 0x10 - 0x1F
	OP (AddA_Imm),	OP (AddA_Abs),	OP (AddA_M),	OP (AddA_B),
	OP (AddB_Imm),	OP (AddB_Abs),	OP (AddB_M),	OP (AddB_A),
	OP (AddM_Imm),	OP (AddM_Abs),	OP (AddM_M),	OP (NullOp),
	OP (NullOp),	OP (Subr_Adr),	OP (Subr_M),	OP (NullOp),
	
	// 0x20 - 0x2F
	OP (SubA_Imm),	OP (SubA_Abs),	OP (SubA_M),	OP (SubA_B),
	OP (SubB_Imm),	OP (SubB_Abs),	OP (SubB_M),	OP (SubB_A),
	OP (SubM_Imm),	OP (SubM_Abs),	OP (SubM_M),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	
	// 0x30 - 0x3F
	OP (CompA_Imm),	OP (CompA_Abs),	OP (CompA_M),	OP (CompA_B),
	OP (CompB_Imm),	OP (CompB_Abs),	OP (CompB_M),	OP (CompB_A),
	OP (CompM_Imm),	OP (CompM_Abs),	OP (CompM_M),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	
	// 0x40 - 0x4F
	OP (NullOp),	OP (StoreA_Adr),	OP (StoreA_M),	OP (NullOp),
	OP (NullOp),	OP (StoreB_Adr),	OP (StoreB_M),	OP (NullOp),
	OP (NullOp),	OP (StoreM_Adr),	OP (StoreM_M),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	
	// 0x50 - 0x5F
	OP (AndA_Imm),	OP (AndA_Abs),	OP (XOrA_Imm),	OP (XOrA_Abs),
	OP (AndB_Imm),	OP (AndB_Abs),	OP (XOrB_Imm),	OP (XOrB_Abs),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	
	// 0x60 - 0x6F
	OP (IfZA_Rel),	OP (IfZA_Adr),	OP (OrA_Imm),	OP (OrA_Abs),
	OP (IfZB_Rel),	OP (IfZB_Adr),	OP (OrB_Imm),	OP (OrB_Abs),
	OP (IfC_Rel),	OP (IfC_Adr),	OP (NullOp),	OP (NullOp),
	OP (IfCar_Rel),	OP (IfCar_Adr),	OP (NullOp),	OP (NullOp),
	
	// 0x70 - 0x7F
	OP (IfNZA_Rel),	OP (IfNZA_Adr),	OP (NOrA_Imm),	OP (NOrA_Abs),
	OP (IfNZB_Rel),	OP (IfNZB_Adr),	OP (NOrB_Imm),	OP (NOrB_Abs),
	OP (IfNC_Rel),	OP (IfNC_Adr),	OP (NullOp),	OP (NullOp),
	OP (IfNCar_Rel),	OP (IfNCar_Adr),	OP (NullOp),	OP (NullOp),
	
	// 0x80 - 0x8F
	OP (LShA),	OP (RShA),	OP (LRotA),	OP (RRotA),
	OP (LShB),	OP (RShB),	OP (LRotB),	OP (RRotB),
	OP (LShM),	OP (RShM),	OP (LRotM),	OP (RRotM),
	OP (LShPC),	OP (RShPC),	OP (LRotPC),	OP (RRotPC),
	
	// 0x90 - 0x9F
	OP (PushA),	OP (PullA),	OP (IncA),	OP (DecA),
	OP (PushB),	OP (PullB),	OP (IncB),	OP (DecB),
	OP (PushM),	OP (PullM),	OP (IncM),	OP (DecM),
	OP (PushPC),	OP (PullPC),	OP (IncPC),	OP (DecPC),
	
	// 0xA0 - 0xAF
	OP (MoveA_A),	OP (MoveA_B),	OP (MoveA_MA),	OP (MoveA_AM),
	OP (MoveB_A),	OP (MoveB_B),	OP (MoveB_BM),	OP (MoveB_MB),
	OP (MoveAB_M),	OP (MoveBA_M),	OP (MoveM_AB),	OP (MoveM_BA),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	
	// 0xB0 - 0xBF
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (SetC),	OP (SetC),	OP (NullOp),	OP (NullOp),
	OP (SetCar),	OP (SetCar),	OP (NullOp),	OP (NullOp),
	
	// 0xC0 - 0xCF
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (ClearC),	OP (ClearC),	OP (NullOp),	OP (NullOp),
	OP (ClearCar),	OP (ClearCar),	OP (NullOp),	OP (NullOp),
	
	// 0xD0 - 0xDF
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	
	// 0xE0 - 0xEF
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	
	// 0xF0 - 0xFF
	OP (NullOp),	OP (NullOp),	OP (RetI),	OP (SetI),
	OP (Int),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp),
	OP (NullOp),	OP (NullOp),	OP (NullOp),	OP (NullOp)
};
