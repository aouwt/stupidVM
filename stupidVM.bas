$RESIZE:STRETCH
$CONSOLE
CONST True = -1, False = 0

$LET GSU = BITMAP

TYPE CPURegisters
    A AS _UNSIGNED _BYTE
    B AS _UNSIGNED _BYTE
    C AS _BYTE
    M AS _UNSIGNED INTEGER
    Carry AS _UNSIGNED _BYTE
    PC AS _UNSIGNED INTEGER
    IRQRet AS _UNSIGNED INTEGER
    StackPtr AS _UNSIGNED _BYTE
END TYPE

TYPE GPURegisters
    VMode AS _UNSIGNED _BYTE
    Halt AS _UNSIGNED _BYTE
    Page AS _UNSIGNED _BYTE
END TYPE

TYPE BankRegisters
    Bank AS _UNSIGNED _BYTE
    IsInRAM AS _UNSIGNED _BYTE
    CPMapped AS _UNSIGNED _BYTE
END TYPE

TYPE SoundRegisters
    Ch1 AS LONG
    Ch2 AS LONG
    Ch3 AS LONG
END TYPE

CONST _
__MAP_STATICRAM_BEGIN = &H0000& ,_
__MAP_STACK_BEGIN     = &H1F00& ,_
__MAP_STACK_END       = &H1FFF& ,_
__MAP_STATICRAM_END   = &H1FFF& ,_
_
__MAP_BANK_BEGIN      = &H2000& ,_
__MAP_BANK_END        = &H9FFF& ,_
_
__MAP_STATICROM_BEGIN = &HA000& ,_
__MAP_STATICROM_END   = &HFEFF& ,_
_
__MAP_DEVICEREGS_BEGIN= &HFF00& ,_
__MAP_DEVICEREGS_END  = &HFFFF&


CONST _
__MAP_STATICRAM_SIZE  = __MAP_STATICRAM_BEGIN  - __MAP_STATICRAM_END ,_
__MAP_STACK_SIZE      = __MAP_STACK_BEGIN      - __MAP_STACK_END ,_
__MAP_BANK_SIZE       = __MAP_BANK_BEGIN       - __MAP_BANK_END ,_
__MAP_STATICROM_SIZE  = __MAP_STATICROM_BEGIN  - __MAP_STATICROM_END ,_
__MAP_DEVICEREGS_SIZE = __MAP_DEVICEREGS_BEGIN - __MAP_DEVICEREGS_END


CONST __MAP_DEVICE_SYS = __MAP_DEVICEREGS_BEGIN + &H00
CONST __MAP_DEVICE_GSU = __MAP_DEVICEREGS_BEGIN + &H10


CONST __SYS_BANKNO = __MAP_DEVICE_SYS + &H00


$IF GSU = BITMAP THEN
    $LET SOUND = WAVE
    $LET GPU = BITMAP
    CONST __GSU_GREG_WRITE_BYTE = __MAP_DEVICE_GSU + &H0 '1 byte
    CONST __GSU_GREG_WRITE_ADDR = __MAP_DEVICE_GSU + &H1 '2 bytes
    CONST __GSU_GREG_PAGEOFFSET = __MAP_DEVICE_GSU + &H2 '2 bytes
    CONST __GSU_GREG_WRITE = __GSU_GREG_WRITE_BYTE

    CONST __GSU_SREG_CH1_WAVE = __MAP_DEVICE_GSU + &H4 '4 bytes
    CONST __GSU_SREG_CH2_WAVE = __MAP_DEVICE_GSU + &H8 '4 bytes
    CONST __GSU_SREG_CH1_PITCH = __MAP_DEVICE_GSU + &HB '2 bytes
    CONST __GSU_SREG_CH2_PITCH = __MAP_DEVICE_GSU + &HD '2 bytes
    CONST __GSU_SREG_CH1_VOL = __MAP_DEVICE_GSU + &HE '1 byte
    CONST __GSU_SREG_CH2_VOL = __MAP_DEVICE_GSU + &HF '1 byte


    CONST __GPU_MODE_TEXT = 0
    CONST __GPU_MODE_HIRES = 1
    CONST __GPU_MODE_COLOR = 2
    CONST __GPU_MODE_HICOLOR = 3

    CONST __GPU_MODE_TEXT_COLS = 80, __GPU_MODE_TEXT_ROWS = 40
    CONST __GPU_MODE_HIRES_WIDTH = 512, __GPU_MODE_HIRES_HEIGHT = 512
    CONST __GPU_MODE_COLOR_WIDTH = 256, __GPU_MODE_COLOR_HEIGHT = 256
    CONST __GPU_MODE_HICOLOR_WIDTH = 128, __GPU_MODE_HICOLOR_HEIGHT = 128

    CONST __GPU_VRAMSIZE = &HFFFF&

    DIM VRAM(__GPU_VRAMSIZE) AS _UNSIGNED _BYTE
$END IF
$IF GSU = SPRITE THEN
    $LET SOUND = BEEP
    $LET GPU = SPRITE
    CONST __GSU_SREG_PITCH = __MAP_DEVICE_GSU + &H0 '2 bytes

    CONST __GSU_GREG_WRITE_BYTE = __MAP_DEVICE_GSU + &H2 '1 byte
    CONST __GSU_GREG_WRITE_ADDR = __MAP_DEVICE_GSU + &H3 '2 bytes

    CONST __GSU_GREG_WRITE = __GSU_GREG_WRITE_BYTE
$END IF

CONST __BANK_RAMBANKS = 10
CONST __BANK_ROMBANKS = 1
CONST __ROM_TOTALSIZE = 1

CONST UPDATEINTERVAL = 1 / 60


DIM SHARED StaticRAM(__MAP_STATICRAM_BEGIN TO __MAP_STATICRAM_END) AS _UNSIGNED _BYTE
DIM SHARED StaticROM(__MAP_STATICROM_BEGIN TO __MAP_STATICROM_END) AS _UNSIGNED _BYTE
DIM SHARED BankedRAM(__MAP_BANK_BEGIN TO __MAP_BANK_END, __BANK_RAMBANKS) AS _UNSIGNED _BYTE
DIM SHARED BankedROM(__MAP_BANK_BEGIN TO __MAP_BANK_END, __BANK_ROMBANKS) AS _UNSIGNED _BYTE
DIM SHARED DeviceRAM(__MAP_DEVICEREGS_BEGIN TO __MAP_DEVICEREGS_END) AS _UNSIGNED _BYTE
DIM SHARED GPUImage&

DIM CPU AS CPURegisters

LoadROM "test.rom"
CPU.PC = __MAP_STATICROM_BEGIN

SCREEN _NEWIMAGE(__GPU_MODE_HIRES_WIDTH, __GPU_MODE_HIRES_HEIGHT, 32)
GPUImage& = _NEWIMAGE(__GPU_MODE_HIRES_WIDTH, __GPU_MODE_HIRES_HEIGHT, 32)

ON TIMER(UPDATEINTERVAL) UpdateScreen
TIMER ON

DO
    System_CPU
LOOP


SUB UpdateScreen
    System_GPU
    _PUTIMAGE , GPUImage&, 0
    _DISPLAY
END SUB



SUB System_CPU
    SHARED CPU AS CPURegisters
    STATIC IRQ(&HF) AS _UNSIGNED INTEGER

    STATIC B AS _UNSIGNED _BYTE, I AS _UNSIGNED INTEGER, A AS _UNSIGNED INTEGER 'use STATIC *only* because I think its faster


    GOSUB Addr_Imm
    op1~%% = B AND &HF0
    op2~%% = B AND &H0F
    SELECT CASE op1~%%
        CASE &H00: SELECT CASE op2~%% 'LOAD
                CASE &H0 'LOAD.A <val>
                    GOSUB Addr_Imm
                    CPU.A = B

                CASE &H1 'LOAD.A <addr>
                    GOSUB Addr_Abs
                    CPU.A = B

                CASE &H2 'LOAD.A M
                    GOSUB Addr_M
                    CPU.A = B


                CASE &H4 'LOAD.B <val>
                    GOSUB Addr_Imm
                    CPU.B = B

                CASE &H5 'LOAD.B <addr>
                    GOSUB Addr_Abs
                    CPU.B = B

                CASE &H6 'LOAD.B M
                    GOSUB Addr_M
                    CPU.B = B


                CASE &H8 'LOAD.M <val>
                    GOSUB Addr_Imm_2B
                    CPU.M = I

                CASE &H9 'LOAD.M <addr>
                    GOSUB Addr_Abs_2B
                    CPU.M = I




                CASE &HC 'JUMP <rel>
                    GOSUB Addr_Imm
                    CPU.PC = CPU.PC + B

                CASE &HD 'JUMP <addr>
                    GOSUB Addr_Imm_2B
                    CPU.PC = I

                CASE &HE 'JUMP M
                    CPU.PC = CPU.M


                    'invalid ops
                CASE &H3 'LOAD.A B
                    CPU.A = Bus_Get((CPU.M AND &HFF00) AND CPU.B)

                CASE &H7 'LOAD.B A
                    CPU.B = Bus_Get((CPU.M AND &HFF00) AND CPU.A)

                CASE &HA 'LOAD.M M
                    CPU.M = Bus_Get(CPU.M AND (RND * 255))

                CASE &HB 'LOAD.M A, LOAD.M B
                    CPU.M = Bus_Get(CPU.M AND &HFF00)

                CASE &HF 'JUMP A, JUMP B
                    CPU.PC = Bus_Get(CPU.M AND &HFF00)

                CASE ELSE: GOTO InvalidOp
            END SELECT




        CASE &H40: SELECT CASE op2~%% 'STORE
                CASE &H1 'STORE.A <addr>
                    GOSUB Addr_Imm_2B
                    Bus_Write I, CPU.A

                CASE &H2 'STORE.A M
                    Bus_Write CPU.M, CPU.A



                CASE &H5 'STORE.B <addr>
                    GOSUB Addr_Imm_2B
                    Bus_Write I, CPU.B

                CASE &H6 'STORE.B M
                    Bus_Write CPU.M, CPU.B


                CASE &H9 'STORE.M <addr>
                    GOSUB Addr_Imm_2B
                    Bus_Write I, CPU.M AND &H00FF
                    Bus_Write I + 1, _SHR(CPU.M AND &HFF00, 8)



                    'invalid ops
                CASE &H0 'STORE.A <val>
                    GOSUB Addr_Imm
                    Bus_Write B, CPU.A

                CASE &H3 'STORE.A B
                    Bus_Write (CPU.M AND &HFF00) AND CPU.B, CPU.A

                CASE &H4 'STORE.B <val>
                    GOSUB Addr_Imm
                    Bus_Write B, CPU.B

                CASE &H7 'STORE.B A
                    Bus_Write (CPU.M AND &HFF00) AND CPU.A, CPU.B

                CASE &H8 'STORE.M <val>
                    GOSUB Addr_Imm
                    Bus_Write B, CPU.M AND &H00FF
                    Bus_Write B + 1, _SHR(CPU.M AND &HFF00, 8)

                CASE &HA 'STORE.M M
                    Bus_Write CPU.M, CPU.M
                    CPU.M = CPU.M + 1
                    Bus_Write CPU.M, _SHR(CPU.M AND &HFF00, 8)

                CASE &HB 'STORE.M B, STORE.M A
                    Bus_Write CPU.M AND &HFF00, CPU.M
                    CPU.M = CPU.M + 1
                    Bus_Write CPU.M AND &HFF00, _SHR(CPU.M AND &HFF00, 8)


                CASE ELSE: GOTO InvalidOp
            END SELECT



        CASE &H60: SELECT CASE op2~%% 'IFZ, OR, IF
                CASE &H0 'IFZ.A <rel>
                    GOSUB Addr_Imm
                    IF CPU.A = 0 THEN CPU.PC = CPU.PC + B

                CASE &H1 'IFZ.A <addr>
                    GOSUB Addr_Imm_2B
                    IF CPU.A = 0 THEN CPU.PC = I

                CASE &H2 'OR.A <val>
                    GOSUB Addr_Imm
                    CPU.A = CPU.A OR B

                CASE &H3 'OR.A <addr>
                    GOSUB Addr_Abs
                    CPU.A = CPU.A OR B


                CASE &H4 'IFZ.B <rel>
                    GOSUB Addr_Imm
                    IF CPU.B = 0 THEN CPU.PC = CPU.PC + B

                CASE &H5 'IFZ.B <addr>
                    GOSUB Addr_Imm_2B
                    IF CPU.B = 0 THEN CPU.PC = I

                CASE &H6 'OR.B <val>
                    GOSUB Addr_Imm
                    CPU.B = CPU.B OR B

                CASE &H7 'OR.B <addr>
                    GOSUB Addr_Abs
                    CPU.B = CPU.B OR B


                CASE &H8 'IF.C <rel>
                    GOSUB Addr_Imm
                    IF CPU.C THEN CPU.PC = CPU.PC + B

                CASE &H9 'IF.C <addr>
                    GOSUB Addr_Imm_2B
                    IF CPU.C THEN CPU.PC = I


                CASE &HC 'IF.CAR <rel>
                    GOSUB Addr_Imm
                    IF CPU.Carry THEN CPU.PC = CPU.PC + B

                CASE &HD 'IF.CAR <addr>
                    GOSUB Addr_Imm_2B
                    IF CPU.Carry THEN CPU.PC = I



                    'invalid ops
                CASE &HA 'OR.M <val>
                    GOSUB Addr_Imm
                    CPU.M = CPU.M OR B

                CASE &HB 'OR.M <addr>
                    GOSUB Addr_Abs
                    CPU.M = CPU.M OR B

            END SELECT



        CASE &H70: SELECT CASE op2~%% 'IFNZ, IFN
                CASE &H0 'IF.A <rel>
                    GOSUB Addr_Imm
                    IF CPU.A THEN CPU.PC = CPU.PC + B

                CASE &H1 'IF.A <addr>
                    GOSUB Addr_Imm_2B
                    IF CPU.A THEN CPU.PC = I


                CASE &H4 'IF.B <rel>
                    GOSUB Addr_Imm
                    IF CPU.B THEN CPU.PC = CPU.PC + B

                CASE &H5 'IF.B <addr>
                    GOSUB Addr_Imm_2B
                    IF CPU.B THEN CPU.PC = I


                CASE &H8 'IFN.C <rel>
                    GOSUB Addr_Imm
                    IF CPU.C = 0 THEN CPU.PC = CPU.PC + B

                CASE &H9 'IFN.C <addr>
                    GOSUB Addr_Imm_2B
                    IF CPU.C = 0 THEN CPU.PC = I


                CASE &HC 'IFN.CAR <rel>
                    GOSUB Addr_Imm
                    IF CPU.Carry = 0 THEN CPU.PC = CPU.PC + B

                CASE &HD 'IFN.CAR <addr>
                    GOSUB Addr_Imm_2B
                    IF CPU.Carry = 0 THEN CPU.PC = I



                    'invalid ops
                CASE &H2 'NOR.A <val>
                    GOSUB Addr_Imm
                    CPU.A = ((NOT CPU.A) AND &H00FF) OR B

                CASE &H3 'NOR.A <addr>
                    GOSUB Addr_Abs
                    CPU.A = ((NOT CPU.A) AND &H00FF) OR B


                CASE &H6 'NOR.B <val>
                    GOSUB Addr_Imm
                    CPU.B = ((NOT CPU.B) AND &H00FF) OR B

                CASE &H7 'NOR.B <addr>
                    GOSUB Addr_Abs
                    CPU.B = ((NOT CPU.B) AND &H00FF) OR B


                CASE &HA 'NOR.M <val>
                    GOSUB Addr_Imm
                    CPU.M = ((NOT CPU.M) AND &H0000FFFF) OR B

                CASE &HB 'NOR.M <addr>
                    GOSUB Addr_Abs
                    CPU.M = ((NOT CPU.M) AND &H0000FFFF) OR B
            END SELECT



        CASE &H10: SELECT CASE op2~%% 'ADD
                CASE &H0 'ADD.A <val>
                    GOSUB Addr_Imm
                    CPU.A = CPU.A + B

                CASE &H1 'ADD.A <addr>
                    GOSUB Addr_Abs
                    CPU.A = CPU.A + B

                CASE &H2 'ADD.A M
                    GOSUB Addr_M
                    CPU.A = CPU.A + B

                CASE &H3 'ADD.A B
                    CPU.A = CPU.A + CPU.B



                CASE &H4 'ADD.B <val>
                    GOSUB Addr_Imm
                    CPU.B = CPU.B + B

                CASE &H5 'ADD.B <addr>
                    GOSUB Addr_Abs
                    CPU.B = CPU.B + B

                CASE &H6 'ADD.B M
                    GOSUB Addr_M
                    CPU.B = CPU.B + B

                CASE &H7 'ADD.B A
                    CPU.B = CPU.B + CPU.A



                CASE &H8 'ADD.M <val>
                    GOSUB Addr_Imm
                    CPU.M = CPU.M + B

                CASE &H9 'ADD.M <addr>
                    GOSUB Addr_Abs
                    CPU.M = CPU.M + B


                    'invalid ops
                CASE &HA 'ADD.M M
                    CPU.M = (CPU.M + CPU.M) AND (RND * &HFFFF)

                CASE &HB 'ADD.M A, ADD.M B
                    CPU.M = CPU.M + (_SHR(CPU.M AND &HFF00, 8) AND (RND * &HFFFF))

                CASE ELSE: GOTO InvalidOp
            END SELECT





        CASE &H20: SELECT CASE op2~%% 'SUB
                CASE &H0 'SUB.A <val>
                    GOSUB Addr_Imm
                    CPU.A = CPU.A - B

                CASE &H1 'SUB.A <addr>
                    GOSUB Addr_Abs
                    CPU.A = CPU.A - B

                CASE &H2 'SUB.A M
                    GOSUB Addr_M
                    CPU.A = CPU.A - B

                CASE &H3 'SUB.A B
                    CPU.A = CPU.A - CPU.B



                CASE &H4 'SUB.B <val>
                    GOSUB Addr_Imm
                    CPU.B = CPU.B - B

                CASE &H5 'SUB.B <addr>
                    GOSUB Addr_Abs
                    CPU.B = CPU.B - B

                CASE &H6 'SUB.B M
                    GOSUB Addr_M
                    CPU.B = CPU.B - B

                CASE &H7 'SUB.B A
                    CPU.B = CPU.B - CPU.A



                CASE &H8 'SUB.M <val>
                    GOSUB Addr_Imm
                    CPU.M = CPU.M - B

                CASE &H9 'SUB.M <addr>
                    GOSUB Addr_Abs
                    CPU.M = CPU.M - B


                    'invalid ops
                CASE &HA 'SUB.M M
                    CPU.M = (CPU.M - CPU.M) AND (RND * &HFFFF&)

                CASE &HB 'SUB.M A, SUB.M B
                    CPU.M = CPU.M - (_SHR(CPU.M AND &HFF00, 8) AND (RND * &HFFFF&))

                CASE ELSE: GOTO InvalidOp
            END SELECT


            '.....



        CASE &H80: SELECT CASE op2~%% 'SH/ROT
                CASE &H0 'LSH.A
                    CPU.A = _SHL(CPU.A, 1)

                CASE &H1 'RSH.A
                    CPU.A = _SHR(CPU.A, 1)


                CASE &H2 'LROT.A
                    CPU.A = _SHL(CPU.A, 1) OR CPU.Carry

                CASE &H3 'RROT.A
                    temp~%% = CPU.A AND &B1
                    CPU.A = _SHR(CPU.A, 1) OR _SHL(CPU.Carry, 7)
                    CPU.Carry = temp~%%



                CASE &H4 'LSH.B
                    CPU.B = _SHL(CPU.B, 1)

                CASE &H5 'RSH.B
                    CPU.B = _SHR(CPU.B, 1)


                CASE &H6 'LROT.B
                    CPU.B = _SHL(CPU.B, 1) OR CPU.Carry

                CASE &H7 'RROT.B
                    temp~%% = CPU.B AND &B1
                    CPU.B = _SHR(CPU.B, 1) OR _SHL(CPU.Carry, 7)
                    CPU.Carry = temp~%%



                CASE &H8 'LSH.M
                    CPU.M = _SHL(CPU.M, 1)

                CASE &H9 'RSH.M
                    CPU.M = _SHR(CPU.M, 1)


                CASE &HA 'LROT.M
                    CPU.M = _SHL(CPU.M, 1) OR CPU.Carry

                CASE &HB 'RROT.M
                    temp~%% = CPU.M AND &B1
                    CPU.M = _SHR(CPU.M, 1) OR _SHL(CPU.Carry, 15)
                    CPU.Carry = temp~%%


                    'invalid ops
                CASE &HC 'LSH.PC
                    CPU.Carry = _SHR(CPU.PC AND &B1000000000000000, 15) 'PC doesnt check for overflow so we need to do that manually
                    CPU.PC = _SHL(CPU.PC, 1)

                CASE &HD 'RSH.PC
                    CPU.Carry = CPU.PC AND &B0000000000000001
                    CPU.PC = _SHR(CPU.PC, 1)

                CASE &HE 'LROT.PC
                    CPU.Carry = _SHR(CPU.PC AND &B1000000000000000, 15)
                    CPU.PC = _SHL(CPU.PC, 1) OR CPU.Carry

                CASE &HF 'RROT.PC
                    CPU.Carry = CPU.PC AND &B0000000000000001
                    CPU.PC = _SHR(CPU.PC, 1) OR _SHL(CPU.Carry, 15)

                CASE ELSE: GOTO InvalidOp
            END SELECT




        CASE &H90: SELECT CASE op2~%% 'PUSH/PULL/INC/DEC
                CASE &H0 'PUSH.A
                    B = CPU.A
                    GOSUB Push

                CASE &H1 'PULL.A
                    GOSUB Pull
                    CPU.A = B


                CASE &H2 'INC.A
                    CPU.A = CPU.A + 1

                CASE &H3 'DEC.A
                    CPU.A = CPU.A - 1



                CASE &H4 'PUSH.B
                    B = CPU.B
                    GOSUB Push

                CASE &H5 'PULL.B
                    GOSUB Pull
                    CPU.B = B


                CASE &H6 'INC.B
                    CPU.B = CPU.B + 1

                CASE &H7 'DEC.B
                    CPU.B = CPU.B - 1



                CASE &H8 'PUSH.M
                    I = CPU.M
                    GOSUB Push_2B

                CASE &H9 'PULL.M
                    GOSUB Pull_2B
                    CPU.M = I


                CASE &HA 'INC.M
                    CPU.M = CPU.M + 1

                CASE &HB 'DEC.M
                    CPU.M = CPU.M - 1



                CASE &HC 'PUSH.PC  (+2)
                    I = CPU.PC + 2
                    GOSUB Push_2B

                CASE &HD 'PULL.PC
                    GOSUB Pull_2B
                    CPU.PC = I


                    'invalid ops
                CASE &HE 'INC.PC
                    CPU.Carry = (CPU.PC = &HFFFE&)
                    CPU.PC = CPU.PC + 1

                CASE &HF 'DEC.PC
                    CPU.Carry = (CPU.PC = 0)
                    CPU.PC = CPU.PC - 1
            END SELECT



        CASE &HA0: SELECT CASE op2~%% 'MOVE
                CASE &H1 'MOVE.A-B
                    CPU.B = CPU.A
                CASE &H2 'MOVE.A-MA
                    CPU.M = (CPU.M AND &HFF00) OR CPU.A
                CASE &H3 'MOVE.A-AM
                    CPU.M = B2I(CPU.A, CPU.M AND &H00FF)
                CASE &H4 'MOVE.B-A
                    CPU.A = CPU.B
                CASE &H6 'MOVE.B-BM
                    CPU.M = B2I(CPU.B, CPU.M AND &H00FF)
                CASE &H7 'MOVE.B-MB
                    CPU.M = (CPU.M AND &HFF00) OR CPU.B
                CASE &H8 'MOVE.AB-M
                    CPU.M = _SHL(CPU.A, 8) OR CPU.B
                CASE &H9 'MOVE.BA-M
                    CPU.M = _SHL(CPU.B, 8) OR CPU.A
                CASE &HA 'MOVE.M-AB
                    CPU.A = _SHR(CPU.M AND &HFF00, 8)
                    CPU.B = CPU.M AND &H00FF
                CASE &HB 'MOVE.M-BA
                    CPU.B = _SHR(CPU.M AND &HFF00, 8)
                    CPU.A = CPU.M AND &H00FF

                    'invalid ops
                CASE &H0, &H5 'MOVE.A-A, MOVE.B-B
                CASE ELSE: GOTO InvalidOp
            END SELECT




        CASE &H50: SELECT CASE op2~%% 'AND, XOR
                CASE &H0 'AND.A <val>
                    GOSUB Addr_Imm
                    CPU.A = CPU.A AND B

                CASE &H1 'AND.A <addr>
                    GOSUB Addr_Abs
                    CPU.A = CPU.A AND B


                CASE &H2 'XOR.A <val>
                    GOSUB Addr_Imm
                    CPU.A = CPU.A XOR B

                CASE &H3 'XOR.A <addr>
                    GOSUB Addr_Abs
                    CPU.A = CPU.A XOR B


                CASE &H4 'AND.B <val>
                    GOSUB Addr_Imm
                    CPU.B = CPU.B AND B

                CASE &H5 'AND.B <addr>
                    GOSUB Addr_Abs
                    CPU.B = CPU.B AND B


                CASE &H6 'XOR.B <val>
                    GOSUB Addr_Imm
                    CPU.B = CPU.B XOR B

                CASE &H7 'XOR.B <addr>
                    GOSUB Addr_Abs
                    CPU.B = CPU.B XOR B



                    'invalid ops
                CASE &H8 'AND.M <val>
                    GOSUB Addr_Imm
                    CPU.M = (CPU.M AND B) OR (CPU.M AND &HFF00)

                CASE &H9 'AND.M <addr>
                    GOSUB Addr_Abs
                    CPU.M = (CPU.M AND B) OR (CPU.M AND &HFF00)

                CASE &HA 'XOR.M <val>
                    GOSUB Addr_Imm
                    CPU.M = CPU.M XOR B

                CASE &HB 'AND.M <addr>
                    GOSUB Addr_Abs
                    CPU.M = CPU.M XOR B

            END SELECT



        CASE &HF0: SELECT CASE op2~%% 'Others
                CASE &H0 'INC <addr>
                    GOSUB Addr_Imm_2B
                    tmp~%% = Bus_Get(I)
                    CPU.Carry = (tmp~%% = 255) 'we cant do auto carry with the bus so we do it here
                    Bus_Write I, tmp~% + 1


                CASE &H61 'DEC <addr>
                    GOSUB Addr_Imm_2B
                    tmp~%% = Bus_Get(I)
                    CPU.Carry = (tmp~%% = 0)
                    Bus_Write I, tmp~%% - 1

                CASE &H2 'RETI
                    CPU.PC = CPU.IRQRet

                CASE &H3 'SETINT <num>
                    GOSUB Addr_Imm
                    IRQ(B AND &H0F) = CPU.M

                CASE &H4 'INT <num>
                    GOSUB Addr_Imm
                    GOSUB Interrupt

                CASE &HF 'BREAK
                    END

                    'invalid ops
                CASE ELSE: GOTO InvalidOp
            END SELECT

    END SELECT

CPU.Carry = (CPU.A > 255) OR _
(CPU.B > 255) OR _
(CPU.M > 65535) OR _
(CPU.Carry)

    CPU.A = CPU.A AND &HFF
    CPU.B = CPU.B AND &HFF
    CPU.M = CPU.M AND &HFFFF
    CPU.Carry = (CPU.Carry <> 1) AND &B1

    EXIT SUB


    Addr_Imm:
    B = Bus_Get(CPU.PC)
    CPU.PC = CPU.PC + 1
    RETURN

    Addr_Imm_2B:
    I = B2I(Bus_Get(CPU.PC), Bus_Get(CPU.PC + 1))
    CPU.PC = CPU.PC + 2
    RETURN

    Addr_Abs:
    tmp~% = B2I(Bus_Get(CPU.PC), Bus_Get(CPU.PC + 1))
    CPU.PC = CPU.PC + 2
    B = Bus_Get(tmp~%)
    RETURN

    Addr_Abs_2B:
    tmp~% = B2I(Bus_Get(CPU.PC), Bus_Get(CPU.PC + 1))
    CPU.PC = CPU.PC + 2
    I = B2I(Bus_Get(tmp~%), Bus_Get(tmp~% + 1))
    RETURN

    Addr_M:
    B = Bus(CPU.M)
    RETURN

    Addr_M_2B:
    I = B2I(Bus_Get(CPU.M), Bus_Get(CPU.M + 1))
    RETURN

    Push:
    Bus_Write __MEM_STACK_begin + CPU.StackPtr, B
    CPU.StackPtr = CPU.StackPtr + 1
    RETURN

    Push_2B:
    Bus_Write __MEM_STACK_begin + CPU.StackPtr, _SHR(I AND &HFF00, 8)
    Bus_Write __MEM_STACK_begin + CPU.StackPtr + 1, I AND &H00FF
    CPU.StackPtr = CPU.StackPtr + 2
    RETURN

    Pull:
    B = Bus_Get(__MEM_STACK_begin + CPU.StackPtr)
    CPU.StackPtr = CPU.StackPtr - 1
    RETURN

    Pull_2B:
    I = B2I(Bus_Get(__MEM_STACK_begin + CPU.StackPtr), Bus_Get(__MEM_STACK_begin + CPU.StackPtr + 1))
    CPU.StackPtr = CPU.StackPtr - 2
    RETURN

    Interrupt:

    InvalidOp:
END SUB

FUNCTION B2I~% (b1~%%, b2~%%)
    B2I~% = b1~%% OR _SHL(b2~%%, 8)
    'B2I = b2~%% OR _SHL(b2~%%, 8)
END FUNCTION

SUB Bus_Write (a~%, b~%%)
    '_ECHO HEX$(a~%) + " " + HEX$(b~%%)
    SHARED Bank AS BankRegisters
    SELECT CASE a~%

        CASE IS < __MAP_STATICRAM_END
            StaticRAM(a~%) = b~%%


        CASE IS < __MAP_BANK_END
            IF Bank.IsInRAM THEN
                BankedRAM(a~%, Bank.Bank) = b~%%
            ELSE
                'BankedROM(a~%, Bank.Bank) = b~%%  ' NO ROM WRITES!!!!11!!1!11
            END IF


        CASE IS < __MAP_STATICROM_END
            'StaticROM(a~%) = b~%%    ' NO ROM WRITES!!!111!111!!

        CASE ELSE
            DeviceRAM(a~%) = b~%%
            Bus_DeviceActions a~%
    END SELECT
END SUB

SUB Bus_DeviceActions (a~%)
    SELECT CASE a~% 'devices sometimes do stuff when read/written to
        CASE __SYS_BANKNO
            SHARED Bank AS BankRegisters
            Bank.Bank = DeviceRAM(__SYS_BANKNO)
            Bank.IsInRAM = (Bank.Bank AND &H10000000)

            '$IF GSU = BITMAP THEN
        CASE __GSU_GREG_WRITE
            SHARED VRAM() AS _UNSIGNED _BYTE
            VRAM(B2I(DeviceRAM(__GSU_GREG_WRITE_ADDR), DeviceRAM(__GSU_GREG_WRITE_ADDR + 1))) = DeviceRAM(__GSU_GREG_WRITE_BYTE)

            i~%% = DeviceRAM(__GSU_GREG_WRITE_ADDR) 'incrememnt it
            DeviceRAM(__GSU_GREG_WRITE_ADDR + 1) = DeviceRAM(__GSU_GREG_WRITE_ADDR + 1) - (i~%% = 255)
            DeviceRAM(__GSU_GREG_WRITE_ADDR) = i~%% + 1
            '$END IF


    END SELECT
END SUB

FUNCTION Bus_Get~%% (a~%)
    SHARED Bank AS BankRegisters
    SELECT CASE a~%
        CASE IS <= __MAP_STATICRAM_END
            Bus_Get = StaticRAM(a~%)

        CASE IS <= __MAP_BANK_END
            IF Bank.IsInRAM THEN
                Bus_Get = BankedRAM(a~%, Bank.Bank)
            ELSE
                Bus_Get = BankedROM(a~%, Bank.Bank)
            END IF

        CASE IS <= __MAP_STATICROM_END
            Bus_Get = StaticROM(a~%)

        CASE ELSE
            Bus_DeviceActions a~%
            Bus_Get = DeviceRAM(a~%)
    END SELECT
END FUNCTION


SUB LoadROM (f$)
    f% = FREEFILE
    OPEN f$ FOR BINARY AS #f%

    'currently only static rom is supported
    GET #f%, , StaticROM()

    CLOSE f%
END SUB

$IF SOUND = WAVE THEN
    SUB System_Sound
        STATIC Snd AS SoundRegisters

        STATIC Buffer(_SNDRATE * (1 / 60), 0 TO 1) AS SINGLE

        STATIC Waveform(16) AS SINGLE '16 samples


        'Channel 1
        'make the waveform
        p~%% = 0
        i~%% = 0: DO
            b~%% = DeviceRAM(__GSU_SREG_CH1_WAVE + p~%%)
            Waveform(i~%%) = _SHR(b~%% AND &B11000000, 6) * __GSU_SREG_CH1_VOL / 1024
            Waveform(i~%% + 1) = _SHR(b~%% AND &B00110000, 4) * __GSU_SREG_CH1_VOL / 1024
            Waveform(i~%% + 2) = _SHR(b~%% AND &B00001100, 2) * __GSU_SREG_CH1_VOL / 1024
            Waveform(i~%% + 3) = (b~%% AND &B00000011) * __GSU_SREG_CH1_VOL / 1024
            p~%% = p~%% + 1
        i~%% = i~%% + 4: LOOP UNTIL i~%% = 16

        'play it here
        frac! = 1 / _SNDRATE
        freq~% = B2I(DeviceRAM(__GSU_SREG_CH1_PITCH), DeviceRAM(__GSU_SREG_CH1_PITCH + 1))

        'Channel 2
        'make the waveform
        p~%% = 0
        i~%% = 0: DO
            b~%% = DeviceRAM(__GSU_SREG_CH2_WAVE + p~%%)
            Waveform(i~%%) = _SHR(b~%% AND &B11000000, 6) * __GSU_SREG_CH2_VOL / 1024
            Waveform(i~%% + 1) = _SHR(b~%% AND &B00110000, 4) * __GSU_SREG_CH2_VOL / 1024
            Waveform(i~%% + 2) = _SHR(b~%% AND &B00001100, 2) * __GSU_SREG_CH2_VOL / 1024
            Waveform(i~%% + 3) = (b~%% AND &B00000011) * __GSU_SREG_CH2_VOL / 1024
            p~%% = p~%% + 1
        i~%% = i~%% + 4: LOOP UNTIL i~%% = 16

        'play it here
        'todo
    END SUB
$END IF
$IF SOUND = BEEP THEN
    SUB System_Sound
    END SUB
$END IF

$IF GPU = BITMAP THEN
    SUB System_GPU
        SHARED GPUImage&, GPU AS GPURegisters
        SHARED VRAM() AS _UNSIGNED _BYTE

        STATIC Pallete_Color(15) AS _UNSIGNED LONG
        STATIC Pallete_HiColor(255) AS _UNSIGNED LONG

        STATIC w AS _UNSIGNED INTEGER, h AS _UNSIGNED INTEGER
        STATIC fw AS _UNSIGNED _BYTE, fh AS _UNSIGNED _BYTE

        'emulate
        _DEST GPUImage&
        CLS
        SELECT CASE __GPU_MODE_HIRES 'GPU.VMode 'draw the screen
            CASE __GPU_MODE_TEXT
                y~% = 0: DO 'according to ChiaPet#1361 (ID 404676474126336011 for archival purposes) on QB64 Discord, using this instead of FOR is faster
                    x~% = 0: DO
                        _PRINTSTRING (x~%, y~%), CHR$(VRAM(i~%))

                        i~% = i~% + 1
                    x~% = x~% + fw: LOOP UNTIL x~% = w
                y~% = y~% + fh: LOOP UNTIL y~% = h


            CASE __GPU_MODE_HIRES
                y~% = 0: DO
                    x~% = 0: DO

                        b~%% = VRAM(i~%) 'fastest way to do this ig
                        IF b~%% AND &B00000001 THEN PSET (x~%, y~%)
                        IF b~%% AND &B00000010 THEN PSET (x~% + 1, y~%)
                        IF b~%% AND &B00000100 THEN PSET (x~% + 2, y~%)
                        IF b~%% AND &B00001000 THEN PSET (x~% + 3, y~%)
                        IF b~%% AND &B00010000 THEN PSET (x~% + 4, y~%)
                        IF b~%% AND &B00100000 THEN PSET (x~% + 5, y~%)
                        IF b~%% AND &B01000000 THEN PSET (x~% + 6, y~%)
                        IF b~%% AND &B10000000 THEN PSET (x~% + 7, y~%)
                        i~% = i~% + 1

                    x~% = x~% + 8: LOOP UNTIL x~% = __GPU_MODE_HIRES_WIDTH
                y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_HIRES_HEIGHT


            CASE __GPU_MODE_COLOR
                y~% = 0: DO
                    x~% = 0: DO

                        b~%% = VRAM(i~%)
                        PSET (x~%, y~%), Pallete_Color(b~%% AND &H0F)
                        PSET (x~% + 1, y~%), Pallete_Color(_SHR(b~%% AND &HF0, 4))

                        i~% = i~% + 1

                    x~% = x~% + 2: LOOP UNTIL x~% = __GPU_MODE_COLOR_WIDTH
                y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_COLOR_HEIGHT


            CASE __GPU_MODE_HICOLOR
                y~% = 0: DO
                    x~% = 0: DO
                        PSET (x~%, y~%), Pallete_HiColor(VRAM(i~%))
                        i~% = i~% + 1
                    x~% = x~% + 2: LOOP UNTIL x~% = __GPU_MODE_HICOLOR_WIDTH
                y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_HICOLOR_HEIGHT

        END SELECT

    END SUB
$END IF
$IF GPU = SPRITE THEN
    SUB System_GPU
    END SUB
$END IF


FUNCTION fps!
    STATIC last AS SINGLE
    fps = 1 / (TIMER(0.00001) - last)
    last = TIMER(0.00001)
END FUNCTION

SUB System_IO
END SUB


SUB System_GPU_Test (timg&)
    _SOURCE timg&

    SELECT CASE __GPU_MODE_HIRES
        CASE __GPU_MODE_HIRES
            w~% = _WIDTH(timg&): h~% = _HEIGHT(timg&)
            y~% = 0: DO
                x~% = 0: DO

                    Bus_Write __GSU_GREG_WRITE_ADDR, (i~% AND &H00FF&)
                    Bus_Write __GSU_GREG_WRITE_ADDR + 1, _SHR(i~% AND &HFF00&, 8)


    Bus_Write __GSU_GREG_WRITE_BYTE, (_RED32(POINT(x~%    , y~%)) AND 1)    OR _
    _SHL(_RED32(POINT(x~% + 1, y~%)) AND 1, 1) OR _
    _SHL(_RED32(POINT(x~% + 2, y~%)) AND 1, 2) OR _
    _SHL(_RED32(POINT(x~% + 3, y~%)) AND 1, 3) OR _
    _SHL(_RED32(POINT(x~% + 4, y~%)) AND 1, 4) OR _
    _SHL(_RED32(POINT(x~% + 5, y~%)) AND 1, 5) OR _
    _SHL(_RED32(POINT(x~% + 6, y~%)) AND 1, 6) OR _
    _SHL(_RED32(POINT(x~% + 7, y~%)) AND 1, 7)
                    i~% = i~% + 1

                x~% = x~% + 8: LOOP UNTIL x~% = w~%
            y~% = y~% + 1: LOOP UNTIL y~% = h~%
    END SELECT
END SUB
