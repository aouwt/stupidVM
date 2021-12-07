typedef uint_fast8_t reg8;
typedef uint_fast16_t reg16;
typedef bool reg1;

static reg8 A, B;
static reg16 M;
static reg1 C, Carry;

static uint16_t PC;
static uint8_t SP;


#define IMM  Bus_Get8 (PC++)
#define IMM2 Bus_Get16 (PC++)
#define ABS  Bus_Get8 (IMM2)
#define ABS2 Bus_Get16 (IMM2)
#define ADRM Bus_Get8 (M)
#define ADRM2 Bus_Get16 (M)


void EmuCPU (void) {
	#define GOP(ID) _ ## ID
	#define OP(ID) static void GOP (ID) (void)
	
	// LOAD.A
	OP (00) { A = IMM; }
	OP (01) { A = ABS; }
	OP (02) { A = ADRM; }
	// LOAD.B
	OP (04) { B = IMM; }
	OP (05) { B = ABS; }
	OP (06) { B = ADRM; }
	// LOAD.M
	OP (08) { M = IMM2; }
	OP (09) { M = ABS2; }
	
	// JUMP
	OP (0C) { PC += IMM; }
	OP (0D) { PC = IMM2; }
	OP (0E) { PC = M; }
	
	// ADD.A
	OP (10) { A = C8 (A + IMM); }
	OP (11) { A = C8 (A + ABS); }
	OP (12) { A = C8 (A + ADRM); }
	OP (13) { A = C8 (A + B); }
	// ADD.B
	OP (14) { B = C8 (B + IMM); }
	OP (15) { B = C8 (B + ABS); }
	OP (16) { B = C8 (B + ADRM); }
	OP (17) { B = C8 (B + A); }
	// ADD.M
	OP (18) { M = C16 (M + IMM2); }
	OP (19) { M = C16 (M + ABS2); }
	
	// SUBR
	OP (1D) { PUSH2 (PC + 2); PC = IMM2; }
	
	// SUB.A
	OP (20) { A = C8 (A - IMM); }
	OP (21) { A = C8 (A - ABS); }
	OP (22) { A = C8 (A - ADRM); }
	OP (23) { A = C8 (A - B); }
	// SUB.B
	OP (24) { B = C8 (B - IMM); }
	OP (25) { B = C8 (B - ABS); }
	OP (26) { B = C8 (B - ADRM); }
	OP (27) { B = C8 (B - A); }
	// SUB.M
	OP (28) { M = C16 (M - IMM2); }
	OP (29) { M = C16 (M - ABS2); }
	
	// COMP.A
	OP (30) { C = (C8 (A - IMM) == 0); }
	OP (31) { C = (C8 (A - ABS) == 0); }
	OP (32) { C = (C8 (A - ADRM) == 0); }
	OP (33) { C = (C8 (A - B) == 0); }
	// COMP.B
	OP (34) { C = (C8 (A - IMM) == 0); }
	OP (35) { C = (C8 (A - ABS) == 0); }
	OP (36) { C = (C8 (A - ADRM) == 0); }
	OP (37) { C = (C8 (B - A) == 0); }
	// COMP.M
	OP (38) { C = (C16 (M - IMM2) == 0); }
	OP (39) { C = (C16 (M - ABS2) == 0); }
	
	// STORE.A
	OP (41) { Bus_Write8 (IMM2, A); }
	OP (42) { Bus_Write8 (M, A); }
	// STORE.B
	OP (45) { Bus_Write8 (IMM2, B); }
	OP (46) { Bus_Write8 (M, B); }
	// STORE.M
	OP (49) { Bus_Write16 (IMM2, M); }
	
	// AND.A
	OP (50) { A &= IMM; }
	OP (51) { A &= ABS; }
	// XOR.A
	OP (52) { A ^= IMM; }
	OP (53) ( A ^= ABS; )
	// AND.B
	OP (54) { B &= IMM; }
	OP (55) { B &= ABS; }
	// XOR.B
	OP (56) { B ^= IMM; }
	OP (57) ( B ^= ABS; )
	
	// IFZ.A
	OP (60) { if (!A) PC += IMM; else PC += 1; }
	OP (61) { if (!A) PC = IMM2; else PC += 2; }
	// OR.A
	OP (62) { A |= IMM; }
	OP (63) { A |= ABS; }
	// IFZ.B
	OP (64) { if (!B) PC += IMM; else PC += 1; }
	OP (65) { if (!B) PC = IMM2; else PC += 2; }
	// OR.B
	OP (66) { B |= IMM; }
	OP (67) { B |= ABS; }
	
	// IF.C
	OP (68) { if (C) PC += IMM; else PC += 1; }
	OP (69) { if (C) PC = IMM2; else PC += 2; }
	// IF.CAR
	OP (6C) { if (Carry) PC += IMM; else PC += 1; }
	OP (6D) { if (Carry) PC = IMM2; else PC += 2; }
	
	// IF.A
	OP (70) { if (A) PC += IMM; else PC += 1; }
	OP (71) { if (A) PC = IMM2; else PC += 2; }
	// IF.B
	OP (74) { if (B) PC += IMM; else PC += 1; }
	OP (75) { if (B) PC = IMM2; else PC += 2; }
	
	// IFN.C
	OP (78) { if (!C) PC += IMM; else PC += 1; }
	OP (79) { if (!C) PC = IMM2; else PC += 2; }
	// IFN.CAR
	OP (7C) { if (!Carry) PC += IMM; else PC += 1; }
	OP (7D) { if (!Carry) PC = IMM2; else PC += 2; }

	/*
	// L/RSH.A
	OP (80) { A = C8 (A << 1); }
	OP (81) { Carry = (A & 1) || Carry; A >>= 1; }
	// L/RROT.A
	...
	*/
	
	// PUSH/PULL.A
	OP (90) { PUSH (A); }
	OP (91) { A = PULL; }
	// INC/DEC.A
	OP (92) { A = C8 (A + 1); }
	OP (93) { A = C8 (A - 1); }
	
	// PUSH/PULL.B
	OP (94) { PUSH (B); }
	OP (95) { B = PULL; }
	// INC/DEC.B
	OP (96) { B = C8 (B + 1); }
	OP (97) { B = C8 (B - 1); }
	
	// PUSH/PULL.M
	OP (98) { PUSH2 (M); }
	OP (99) { M = PULL2; }
	// INC/DEC.M
	OP (9A) { M = C16 (M + 1); }
	OP (9B) { M = C16 (M - 1); }
	
	// PUSH/PULL.PC
	OP (9C) { PUSH2 (PC); }
	OP (9D) { PC = PULL2; }
	
	//...
	
	#undef PUSH2
	#undef PUSH
	#undef PULL2
	#undef PULL
	#undef IMM2
	#undef IMM
	#undef ABS2
	#undef ABS
	#undef ADRM2
	#undef ADRM
	#undef C8
	#undef C16
	#undef OP
	
	void (*OpRef [256]) (void) = {
		&_00, &_01, &_02, &_03, &_04, &_05, &_06, &_07, &_08, &_09, &_0A, &_0B, &_0C, &_0D, &_0E, &_0F,
		&_10, &_11, &_12, &_13, &_14, &_15, &_16, &_17, &_18, &_19, &_1A, &_1B, &_1C, &_1D, &_1E, &_1F,
		&_20, &_21, &_22, &_23, &_24, &_25, &_26, &_27, &_28, &_29, &_2A, &_2B, &_2C, &_2D, &_2E, &_2F,
		&_30, &_31, &_32, &_33, &_34, &_35, &_36, &_37, &_38, &_39, &_3A, &_3B, &_3C, &_3D, &_3E, &_3F,
		&_40, &_41, &_42, &_43, &_44, &_45, &_46, &_47, &_48, &_49, &_4A, &_4B, &_4C, &_4D, &_4E, &_4F,
		&_50, &_51, &_52, &_53, &_54, &_55, &_56, &_57, &_58, &_59, &_5A, &_5B, &_5C, &_5D, &_5E, &_5F,
		&_60, &_61, &_62, &_63, &_64, &_65, &_66, &_67, &_68, &_69, &_6A, &_6B, &_6C, &_6D, &_6E, &_6F,
		&_70, &_71, &_72, &_73, &_74, &_75, &_76, &_77, &_78, &_79, &_7A, &_7B, &_7C, &_7D, &_7E, &_7F,
    &_80, &_81, &_82, &_83, &_84, &_85, &_86, &_87, &_88, &_89, &_8A, &_8B, &_8C, &_8D, &_8E, &_8F,
    &_90, &_91, &_92, &_93, &_94, &_95, &_96, &_97, &_98, &_99, &_9A, &_9B, &_9C, &_9D, &_9E, &_9F,
    &_A0, &_A1, &_A2, &_A3, &_A4, &_A5, &_A6, &_A7, &_A8, &_A9, &_AA, &_AB, &_AC, &_AD, &_AE, &_AF,
    &_B0, &_B1, &_B2, &_B3, &_B4, &_B5, &_B6, &_B7, &_B8, &_B9, &_BA, &_BB, &_BC, &_BD, &_BE, &_BF,
    &_C0, &_C1, &_C2, &_C3, &_C4, &_C5, &_C6, &_C7, &_C8, &_C9, &_CA, &_CB, &_CC, &_CD, &_CE, &_CF,
    &_D0, &_D1, &_D2, &_D3, &_D4, &_D5, &_D6, &_D7, &_D8, &_D9, &_DA, &_DB, &_DC, &_DD, &_DE, &_DF,
    &_E0, &_E1, &_E2, &_E3, &_E4, &_E5, &_E6, &_E7, &_E8, &_E9, &_EA, &_EB, &_EC, &_ED, &_EE, &_EF,
    &_F0, &_F1, &_F2, &_F3, &_F4, &_F5, &_F6, &_F7, &_F8, &_F9, &_FA, &_FB, &_FC, &_FD, &_FE, &_FF
	};

	(*OpRef [Bus_Get8 (PC++)]) ();
}
