'$DEBUG
$RESIZE:ON
$CONSOLE
CONST True = -1, False = 0

$LET GPU = BITMAP
$LET SOUND = ARB

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
    PageOffset AS _UNSIGNED INTEGER
END TYPE

TYPE BankRegisters
    Bank AS _UNSIGNED _BYTE
    IsInRAM AS _UNSIGNED _BYTE
    CPMapped AS _UNSIGNED _BYTE
END TYPE

TYPE SoundRegisters
    BufferLen AS _UNSIGNED INTEGER
END TYPE

TYPE CPRegisters
    M AS _UNSIGNED LONG
    PC AS _UNSIGNED INTEGER
    Carry AS _UNSIGNED _BYTE
    Reg AS _UNSIGNED _BYTE
    R AS _UNSIGNED INTEGER
    Halted AS _BYTE
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
CONST __MAP_DEVICE_GPU = __MAP_DEVICEREGS_BEGIN + &H10
CONST __MAP_DEVICE_SND = __MAP_DEVICEREGS_BEGIN + &H20
CONST __MAP_DEVICE_CP = __MAP_DEVICEREGS_BEGIN + &H30


CONST __SYS_BANKNO = __MAP_DEVICE_SYS + &H0 '1 byte
CONST __SYS_IO_MOUSE = __MAP_DEVICE_SYS + &H1 '1 byte
CONST __SYS_IO_KEYBOARD = __MAP_DEVICE_SYS + &H2 '2 bytes
CONST __SYS_TIMER = __MAP_DEVICE_SYS + &H4 '1 byte


CONST __GPU_REG_WRITE_BYTE = __MAP_DEVICE_GPU + &H0 '1 byte
CONST __GPU_REG_READ_BYTE = __MAP_DEVICE_GPU + &H1 '1 byte
CONST __GPU_REG_WRITE_ADDR = __MAP_DEVICE_GPU + &H2 '2 bytes
CONST __GPU_REG_PAGEOFFSET = __MAP_DEVICE_GPU + &H4 '2 bytes
CONST __GPU_REG_VMODE = __MAP_DEVICE_GPU + &H6 '1 byte
CONST __GPU_REG_WRITE = __GPU_REG_WRITE_BYTE
CONST __GPU_REG_READ = __GPU_REG_READ_BYTE

'video modes
CONST __GPU_MODE_TEXT_1 = 0
CONST __GPU_MODE_TEXT_1_COLS = 64, __GPU_MODE_TEXT_1_ROWS = 64

CONST __GPU_MODE_TEXT_2 = 1
CONST __GPU_MODE_TEXT_2_COLS = 128, __GPU_MODE_TEXT_2_ROWS = 64

CONST __GPU_MODE_HIRES_1 = 2
CONST __GPU_MODE_HIRES_1_WIDTH = 512, __GPU_MODE_HIRES_1_HEIGHT = 256

CONST __GPU_MODE_HIRES_2 = 3
CONST __GPU_MODE_HIRES_2_WIDTH = 512, __GPU_MODE_HIRES_2_HEIGHT = 512

CONST __GPU_MODE_COLOR_1 = 4
CONST __GPU_MODE_COLOR_1_WIDTH = 256, __GPU_MODE_COLOR_1_HEIGHT = 128

CONST __GPU_MODE_COLOR_2 = 5
CONST __GPU_MODE_COLOR_2_WIDTH = 256, __GPU_MODE_COLOR_2_HEIGHT = 256

CONST __GPU_MODE_HICOLOR_1 = 6
CONST __GPU_MODE_HICOLOR_1_WIDTH = 256, __GPU_MODE_HICOLOR_1_HEIGHT = 128

CONST __GPU_MODE_HICOLOR_2 = 7
CONST __GPU_MODE_HICOLOR_2_WIDTH = 256, __GPU_MODE_HICOLOR_2_HEIGHT = 256




CONST __GPU_VRAMSIZE = &HFFFF&



'CONST __SND_REG_WAVEFORMS = __MAP_DEVICE_SND + &H0 '1 byte
'CONST __SND_REG_VOLS = __MAP_DEVICE_SND + &H1 '2 bytes
'CONST __SND_REG_DUTIES = __MAP_DEVICE_SND + &H3 '2 bytes
'CONST __SND_REG_NOTES = __MAP_DEVICE_SND + &H5 '8 bytes
'CONST __SND_REG_WRITE_ADDR = __MAP_DEVICE_SND + &HD '1 byte
'CONST __SND_REG_WRITE_BYTE = __MAP_DEVICE_SND + &HE '1 byte
'CONST __SND_REG_WRITE = __SND_REG_WRITE_BYTE '1 byte

CONST __SND_REG_PITCH = __MAP_DEVICE_SND + &H0
CONST __SND_REG_VOL = __MAP_DEVICE_SND + &H2
CONST __SND_REG_WAVEFORM = __MAP_DEVICE_SND + &H3

CONST __SND_BUFFERLEN = 1 / 30



CONST __CP_REG_WRITE_BYTE = __MAP_DEVICE_CP + &H0 '1 byte
CONST __CP_REG_READ_BYTE = __MAP_DEVICE_CP + &H1 '1 byte
CONST __CP_REG_WRITE_ADDR = __MAP_DEVICE_CP + &H2 '2 bytes
CONST __CP_REG_HALTED = __MAP_DEVICE_CP + &H4 '1 byte

CONST __CP_RAM_SIZE = &HFFFF~%



CONST __BANK_RAMBANKS = 10
CONST __BANK_ROMBANKS = 1
CONST __ROM_TOTALSIZE = 1

CONST UPDATEINTERVAL = 1 / 60


DIM SHARED StaticRAM(__MAP_STATICRAM_BEGIN TO __MAP_STATICRAM_END) AS _UNSIGNED _BYTE
DIM SHARED StaticROM(__MAP_STATICROM_BEGIN TO __MAP_STATICROM_END) AS _UNSIGNED _BYTE
DIM SHARED BankedRAM(__MAP_BANK_BEGIN TO __MAP_BANK_END, __BANK_RAMBANKS) AS _UNSIGNED _BYTE
DIM SHARED BankedROM(__MAP_BANK_BEGIN TO __MAP_BANK_END, __BANK_ROMBANKS) AS _UNSIGNED _BYTE
DIM SHARED DeviceRAM(__MAP_DEVICEREGS_BEGIN TO __MAP_DEVICEREGS_END) AS _UNSIGNED _BYTE
DIM SHARED VRAM(__GPU_VRAMSIZE) AS _UNSIGNED _BYTE
DIM SHARED CP_RAM(__CP_RAM_SIZE) AS _UNSIGNED _BYTE


DIM SHARED GPUImage&, TextModeFont&
DIM Pallete_4BPP(15) AS _UNSIGNED LONG
DIM Pallete_8BPP(255) AS _UNSIGNED LONG

DIM SHARED Waveforms(255, 255) AS SINGLE

DIM SHARED CPU AS CPURegisters, GPU AS GPURegisters, CP AS CPRegisters


LoadROM "test.rom"
CPU.PC = __MAP_STATICROM_BEGIN
GPU.VMode = 100

_ECHO "Generating palletes..."
System_GPU_GeneratePalletes
System_Sound_GenWaveforms
_ECHO "done"

TextModeFont& = 8 ' _LOADFONT("/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf", 8, "MONOSPACE,DONTBLEND")
GPUImage& = _NEWIMAGE(8, 8, 32)
Bus_DeviceActions __GPU_REG_VMODE

screenimage& = _NEWIMAGE(640, 480, 32)
SCREEN screenimage&
DO
    System_CPU
    'System_CP
    System_Sound
    t! = TIMER(0.0001)
    IF NextUpdate! < t! THEN
        System_GPU

        IF _RESIZE THEN
            tmp& = _COPYIMAGE(screenimage&, 32)
            SCREEN tmp&
            _FREEIMAGE screenimage&
            screenimage& = _NEWIMAGE(_RESIZEWIDTH, _RESIZEHEIGHT, 32)
            SCREEN screenimage&
            _FREEIMAGE tmp&
        END IF

        _PUTIMAGE , GPUImage&, 0, , _SMOOTH
        _DISPLAY
        NextUpdate! = t! + UPDATEINTERVAL
    END IF
LOOP

SUB System_CPU
    SHARED CPU AS CPURegisters
    STATIC IRQ(&HF) AS _UNSIGNED INTEGER, MRegs(7) AS _UNSIGNED INTEGER

    STATIC B AS _UNSIGNED _BYTE, I AS _UNSIGNED INTEGER, A AS _UNSIGNED INTEGER 'use STATIC *only* because I think its faster


    '_ECHO HEX$(CPU.PC)
    'SLEEP
    '_LIMIT 200
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
                    GOSUB Addr_Imm_2B
                    CPU.M = CPU.M OR I

                CASE &HB 'OR.M <addr>
                    GOSUB Addr_Abs_2B
                    CPU.M = CPU.M OR I

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
                    GOSUB Addr_Imm_2B
                    CPU.M = ((NOT CPU.M) AND &H0000FFFF) OR I

                CASE &HB 'NOR.M <addr>
                    GOSUB Addr_Abs_2B
                    CPU.M = ((NOT CPU.M) AND &H0000FFFF) OR I
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
                    GOSUB Addr_Imm_2B
                    CPU.M = CPU.M + I

                CASE &H9 'ADD.M <addr>
                    GOSUB Addr_Abs_2B
                    CPU.M = CPU.M + I



                CASE &HD 'SUBR <addr>
                    I = CPU.PC + 2
                    GOSUB Push_2B
                    GOSUB Addr_Imm_2B
                    CPU.PC = I



                    'invalid ops
                CASE &HA 'ADD.M M
                    CPU.M = (CPU.M + CPU.M) AND (RND * &HFFFF)

                CASE &HB 'ADD.M A, ADD.M B
                    CPU.M = CPU.M + (_SHR(CPU.M AND &HFF00, 8) AND (RND * &HFFFF))


                CASE &HC 'SUBR <rel>
                    I = CPU.PC + 2
                    GOSUB Push_2B
                    GOSUB Addr_Imm
                    CPU.PC = CPU.PC + B

                CASE &HF 'SUBR M
                    I = CPU.PC + 2
                    GOSUB Push_2B
                    CPU.PC = CPU.PC + CPU.M

                CASE ELSE: GOTO InvalidOp
            END SELECT




        CASE &H30: SELECT CASE op2~%% 'COMP
                CASE &H0 'COMP.A <val>
                    GOSUB Addr_Imm
                    CPU.C = (CPU.A = B)
                    CPU.Carry = (CPU.A < B)

                CASE &H1 'COMP.A <addr>
                    GOSUB Addr_Abs
                    CPU.C = (CPU.A = B)
                    CPU.Carry = (CPU.A < B)

                CASE &H2 'COMP.A M
                    GOSUB Addr_M
                    CPU.C = (CPU.A = B)
                    CPU.Carry = (CPU.A < B)

                CASE &H3 'COMP.A B
                    CPU.C = (CPU.A = CPU.B)
                    CPU.Carry = (CPU.A < CPU.B)



                CASE &H4 'COMP.B <val>
                    GOSUB Addr_Imm
                    CPU.C = (CPU.B = B)
                    CPU.Carry = (CPU.B < B)

                CASE &H5 'COMP.B <addr>
                    GOSUB Addr_Abs
                    CPU.C = (CPU.B = B)
                    CPU.Carry = (CPU.B < B)

                CASE &H6 'COMP.B M
                    GOSUB Addr_M
                    CPU.C = (CPU.B = B)
                    CPU.Carry = (CPU.B < B)

                CASE &H7 'COMP.B A
                    CPU.C = (CPU.B = CPU.A)
                    CPU.Carry = (CPU.B < CPU.A)



                CASE &H8 'COMP.M <val>
                    GOSUB Addr_Imm_2B
                    CPU.C = (CPU.M = I)
                    CPU.Carry = (CPU.M < I)

                CASE &H9 'COMP.M <addr>
                    GOSUB Addr_Abs_2B
                    CPU.C = (CPU.M = I)
                    CPU.Carry = (CPU.M < I)


                    'invalid ops
                CASE &HA 'COMP.M M
                    CPU.C = True

                CASE &HB 'COMP.M A, COMP.M B
                    CPU.C = ((CPU.M AND &H00FF) = 0) 'essentially (CPU.M = _SHR(CPU.M AND &HFF00, 8))

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
                    GOSUB Addr_Imm_2B
                    CPU.M = CPU.M - I

                CASE &H9 'SUB.M <addr>
                    GOSUB Addr_Abs_2B
                    CPU.M = CPU.M - I


                    'invalid ops
                CASE &HA 'SUB.M M
                    GOSUB addr_m_2b
                    CPU.M = (CPU.M - I)

                CASE &HB 'SUB.M A, SUB.M B
                    CPU.M = CPU.M - _SHR(CPU.M AND &HFF00, 8)

                CASE ELSE: GOTO InvalidOp
            END SELECT


        CASE &HD0: SELECT CASE op2~%% 'MOVE.Mn-M/MOVE.M-Mn
                CASE &H0 TO &H7: CPU.M = MRegs(op2~%%)

                CASE ELSE: MRegs(op2~%% - 7) = CPU.M
            END SELECT



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
                    GOSUB push

                CASE &H1 'PULL.A
                    GOSUB Pull
                    CPU.A = B


                CASE &H2 'INC.A
                    CPU.A = CPU.A + 1

                CASE &H3 'DEC.A
                    CPU.A = CPU.A - 1



                CASE &H4 'PUSH.B
                    B = CPU.B
                    GOSUB push

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



                CASE &HC 'PUSH.PC
                    I = CPU.PC
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
                    GOSUB Addr_Imm_2B
                    CPU.M = (CPU.M AND I) OR (CPU.M AND &HFF00)

                CASE &H9 'AND.M <addr>
                    GOSUB Addr_Abs_2B
                    CPU.M = (CPU.M AND I) OR (CPU.M AND &HFF00)

                CASE &HA 'XOR.M <val>
                    GOSUB Addr_Imm_2B
                    CPU.M = CPU.M XOR I

                CASE &HB 'XOR.M <addr>
                    GOSUB Addr_Abs_2B
                    CPU.M = CPU.M XOR I

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
                    _ECHO "BREAK at " + HEX$(CPU.PC)

                    'invalid ops
                CASE ELSE: GOTO InvalidOp
            END SELECT

    END SELECT

    CPU.Carry = (CPU.A > 255) OR _
                (CPU.B > 255) OR _
                (CPU.M > 65535) OR _
                (CPU.Carry)


    CPU.Carry = (CPU.Carry <> 0) ' AND &B1

    CPU.A = CPU.A AND &HFF
    CPU.B = CPU.B AND &HFF
    CPU.M = CPU.M AND &HFFFF

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
    B = Bus_Get(CPU.M)
    RETURN

    addr_m_2b:
    I = B2I(Bus_Get(CPU.M), Bus_Get(CPU.M + 1))
    RETURN

    push:
    Bus_Write __MEM_STACK_BEGIN + CPU.StackPtr, B
    CPU.StackPtr = CPU.StackPtr + 1
    RETURN

    Push_2B:
    Bus_Write __MEM_STACK_BEGIN + CPU.StackPtr, I AND &H00FF
    Bus_Write __MEM_STACK_BEGIN + CPU.StackPtr + 1, _SHR(I AND &HFF00, 8)
    CPU.StackPtr = CPU.StackPtr + 2
    RETURN

    Pull:
    CPU.StackPtr = CPU.StackPtr - 1
    B = Bus_Get(__MEM_STACK_BEGIN + CPU.StackPtr)
    RETURN

    Pull_2B:
    CPU.StackPtr = CPU.StackPtr - 2
    I = B2I(Bus_Get(__MEM_STACK_BEGIN + CPU.StackPtr), Bus_Get(__MEM_STACK_BEGIN + CPU.StackPtr + 1))
    RETURN

    Interrupt:

    InvalidOp:
END SUB

'op~% = CP_PRGRAM(CP.pc)
''opcode~%% = _SHR(op~% And &HFF00, 8)
'Select Case op~%
'    Case Is <= &B0011111111111111~%
'    Case Is <= &B0111111111111111~%
'    Case Is <= &B1000111111111111~%
'    Case Is <= &B1001111111111111~%
'    Case Is <= &B1010111111111111~%
'    Case Is <= &B1011111111111111~%
'    Case Is <= &B1100001111111111~%
'    Case Is <= &B1101001111111111~%
'    Case Is <= &B1101011111111111~%
'    Case Is <= &B1101101111111111~%
'    Case Is <= &B1101111111111111~%
'    Case Is <= &B1110000011111111~%
'    Case Is <= &B1110001011111111~%
'    Case Is <= &B1110001111111111~%
'    Case Is <= &B1110010011111111~%
'    Case Is <= &B1110010111111111~%
'    Case &HFFFF
'End Select

SUB System_CP

    DIM B AS _UNSIGNED _BYTE, I AS _UNSIGNED INTEGER
    STATIC Reg(3) AS _UNSIGNED _BYTE

    IF CP.Halted THEN EXIT SUB

    GOSUB Addr_Imm
    SELECT CASE B AND &B11111000
        CASE &B00000000 'LDR v
            GOSUB Addr_Imm
            CP.R = B

        CASE &B00001000 'LDM v
            GOSUB addr_imm_2b
            CP.M = I

        CASE &B00010000 'LDR a
            GOSUB Addr_Abs
            CP.R = B

        CASE &B00011000 'LDM a
            GOSUB Addr_Abs_2B
            CP.M = I

            'Case &B00100000 'invalid

        CASE &B00101000 'LDR M
            CP.R = CP_RAM(CP.M)

        CASE &B00110000 'STR a
            GOSUB addr_imm_2b
            CP_RAM(I) = CP.R

        CASE &B00111000 'STR M
            CP_RAM(CP.M) = CP.R

        CASE &B01000000 'CME v
            GOSUB addr_imm_2b
            CP.Carry = (CP.M = I)

        CASE &B01001000 'CML v
            GOSUB addr_imm_2b
            CP.Carry = (CP.M < I)

        CASE &B01010000 'CMG v
            GOSUB addr_imm_2b
            CP.Carry = (CP.M > I)

        CASE &B01011000 'CMN v
            GOSUB addr_imm_2b
            CP.Carry = (CP.M <> I)

        CASE &B01100000 'CRE v
            GOSUB Addr_Imm
            CP.Carry = (CP.R = B)

        CASE &B01101000 'CRL v
            GOSUB Addr_Imm
            CP.Carry = (CP.R < B)

        CASE &B01110000 'CRG v
            GOSUB Addr_Imm
            CP.Carry = (CP.R > B)

        CASE &B01111000 'CRN v
            GOSUB Addr_Imm
            CP.Carry = (CP.R <> B)

        CASE &B10000000 'INC
            CP.R = CP.R + 1

        CASE &B10001000 'INM
            CP.M = CP.M + 1

        CASE &B10010000 'DEC
            CP.R = CP.R - 1

        CASE &B10011000 'DEM
            CP.M = CP.M - 1

        CASE &B10100000 'JCS a
            GOSUB addr_imm_2b
            IF CP.Carry THEN CP.PC = I

        CASE &B10101000 'JCC a
            GOSUB addr_imm_2b
            IF CP.Carry = 0 THEN CP.PC = I

        CASE &B10110000 'SCS
            CP.Carry = 1

        CASE &B10111000 'SCC
            CP.Carry = 0

        CASE &B11000000 'ADD v
            GOSUB Addr_Imm
            CP.R = CP.R + B

        CASE &B11001000 'ADM v
            GOSUB addr_imm_2b
            CP.M = CP.M + I

        CASE &B11010000 'SUB v
            GOSUB Addr_Imm
            CP.R = CP.R - B

        CASE &B11011000 'SBM v
            GOSUB addr_imm_2b
            CP.M = CP.M - I

        CASE &B11100000 'REG 0-3
            B = B AND &B11
            Reg(CP.Reg) = CP.R
            CP.Reg = B
            CP.R = Reg(B)

        CASE &B11101000 'JMP a
            GOSUB addr_imm_2b
            CP.PC = I

            'Case &B11110000 'invalid
        CASE &B11111000 'HLT
            CP.Halted = 1
    END SELECT

    CP.Carry = CP.Carry OR (CP.M > &HFFFF~%) OR (CP.R > &HFF~%%)
    EXIT SUB

    Addr_Imm:
    CP.PC = CP.PC + 1
    B = CP_RAM(CP.PC)
    RETURN

    addr_imm_2b:
    CP.PC = CP.PC + 2
    I = B2I(CP_RAM(CP.PC - 1), CP_RAM(CP.PC))
    RETURN

    Addr_Abs:
    CP.PC = CP.PC + 2
    B = CP_RAM(B2I(CP_RAM(CP.PC - 1), CP_RAM(CP.PC)))
    RETURN

    Addr_Abs_2B:
    CP.PC = CP.PC + 2
    I = B2I(CP_RAM(CP.PC - 1), CP_RAM(CP.PC))
    I = B2I(CP_RAM(I), CP_RAM(I + 1))
    RETURN
END SUB


FUNCTION B2I~% (b1~%%, b2~%%)
    B2I~% = b1~%% OR _SHL(b2~%%, 8)
    'B2I = b2~%% OR _SHL(b2~%%, 8)
END FUNCTION

SUB Bus_Write (a~%, b~%%)
    '_ECHO HEX$(a~%) + " " + HEX$(b~%%)
    'SLEEP
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


        CASE __SYS_IO_MOUSE
            STATIC mousedata~%%, mousex~%, mouse~%
            'ok so this is a little confusing
            'DeviceRAM(__SYS_IO_MOUSE) = 255
            IF _MOUSEINPUT THEN
                WHILE _MOUSEINPUT: WEND

                mousedata~%% =                      (_MOUSEX > mousex~%     )    _
                                            AND _SHL(_MOUSEX < mousex~%  , 1)
                mousedata~%% = mousedata~%% AND _SHL(_MOUSEY > mousey~%  , 2) _
                                            AND _SHL(_MOUSEY < mousey~%  , 3) _
                                            AND _SHL(_MOUSEWHEEL = -1    , 4) _
                                            AND _SHL(_MOUSEWHEEL = 1     , 5) _
                                            AND _SHL(_MOUSEBUTTON(1) = -1, 6) _
                                            AND _SHL(_MOUSEBUTTON(2) = -1, 7)
            END IF
            DeviceRAM(__SYS_IO_MOUSE) = mousedata~%%
            mousex~% = mousex~% + SGN(mousex~% - _MOUSEX)
            mousey~% = mousey~% + SGN(mousex~% - _MOUSEY)



        CASE __SYS_IO_KEYBOARD
            tmp~& = _KEYHIT
            IF tmp~& < 256 THEN DeviceRAM(__SYS_IO_KEYBOARD) = tmp~& ELSE DeviceRAM(__SYS_IO_KEYBOARD) = 0


        CASE __SYS_TIMER
            DeviceRAM(__SYS_TIMER) = (TIMER * 16)


        CASE __GPU_REG_WRITE
            SHARED VRAM() AS _UNSIGNED _BYTE
            VRAM(B2I(DeviceRAM(__GPU_REG_WRITE_ADDR), DeviceRAM(__GPU_REG_WRITE_ADDR + 1))) = DeviceRAM(__GPU_REG_WRITE_BYTE)

            i~%% = DeviceRAM(__GPU_REG_WRITE_ADDR) 'incrememnt it
            DeviceRAM(__GPU_REG_WRITE_ADDR + 1) = DeviceRAM(__GPU_REG_WRITE_ADDR + 1) - (i~%% = 255)
            DeviceRAM(__GPU_REG_WRITE_ADDR) = i~%% + 1

        CASE __GPU_REG_READ
            SHARED VRAM() AS _UNSIGNED _BYTE
            DeviceRAM(__GPU_REG_READ_BYTE) = VRAM(B2I(DeviceRAM(__GPU_REG_WRITE_ADDR), DeviceRAM(__GPU_REG_WRITE_ADDR + 1)))

            i~%% = DeviceRAM(__GPU_REG_WRITE_ADDR) 'incrememnt it
            DeviceRAM(__GPU_REG_WRITE_ADDR + 1) = DeviceRAM(__GPU_REG_WRITE_ADDR + 1) - (i~%% = 255)
            DeviceRAM(__GPU_REG_WRITE_ADDR) = i~%% + 1




        CASE __CP_REG_WRITE
            SHARED CP_RAM() AS _UNSIGNED _BYTE
            CP_RAM(B2I(DeviceRAM(__CP_REG_WRITE_ADDR), DeviceRAM(__CP_REG_WRITE_ADDR + 1))) = DeviceRAM(__CP_REG_WRITE_BYTE)

            i~%% = DeviceRAM(__CP_REG_WRITE_ADDR) 'incrememnt it
            DeviceRAM(__CP_REG_WRITE_ADDR + 1) = DeviceRAM(__CP_REG_WRITE_ADDR + 1) - (i~%% = 255)
            DeviceRAM(__CP_REG_WRITE_ADDR) = i~%% + 1


        CASE __CP_REG_READ
            SHARED CP_RAM() AS _UNSIGNED _BYTE
            DeviceRAM(__CP_REG_READ_BYTE) = CP_RAM(B2I(DeviceRAM(__CP_REG_WRITE_ADDR), DeviceRAM(__CP_REG_WRITE_ADDR + 1)))

            i~%% = DeviceRAM(__CP_REG_WRITE_ADDR) 'incrememnt it
            DeviceRAM(__CP_REG_WRITE_ADDR + 1) = DeviceRAM(__CP_REG_WRITE_ADDR + 1) - (i~%% = 255)
            DeviceRAM(__CP_REG_WRITE_ADDR) = i~%% + 1


        CASE __CP_REG_HALTED
            SHARED CP AS CPRegisters
            DeviceRAM(__CP_REG_HALTED) = CP.Halted



        CASE __GPU_REG_VMODE
            SHARED GPUImage&, GPU AS GPURegisters, TextModeFont&
            tmp~%% = DeviceRAM(__GPU_REG_VMODE)
            IF tmp~%% = GPU.VMode THEN EXIT SUB
            SELECT CASE tmp~%%

                CASE __GPU_MODE_TEXT_1
                    _FREEIMAGE GPUImage&
                    GPUImage& = _NEWIMAGE(__GPU_MODE_TEXT_1_COLS * _FONTWIDTH(TextModeFont&), __GPU_MODE_TEXT_1_ROWS * _FONTHEIGHT(TextModeFont&), 32)
                    _FONT TextModeFont&, GPUImage&
                CASE __GPU_MODE_TEXT_2
                    _FREEIMAGE GPUImage&
                    GPUImage& = _NEWIMAGE(__GPU_MODE_TEXT_2_COLS * _FONTWIDTH(TextModeFont&), __GPU_MODE_TEXT_2_ROWS * _FONTHEIGHT(TextModeFont&), 32)
                    _FONT TextModeFont&, GPUImage&

                CASE __GPU_MODE_HIRES_1
                    _FREEIMAGE GPUImage&
                    GPUImage& = _NEWIMAGE(__GPU_MODE_HIRES_1_WIDTH, __GPU_MODE_HIRES_1_HEIGHT, 32)
                CASE __GPU_MODE_HIRES_2
                    _FREEIMAGE GPUImage&
                    GPUImage& = _NEWIMAGE(__GPU_MODE_HIRES_2_WIDTH, __GPU_MODE_HIRES_2_HEIGHT, 32)

                CASE __GPU_MODE_COLOR_1
                    _FREEIMAGE GPUImage&
                    GPUImage& = _NEWIMAGE(__GPU_MODE_COLOR_1_WIDTH, __GPU_MODE_COLOR_1_HEIGHT, 32)
                CASE __GPU_MODE_COLOR_2
                    _FREEIMAGE GPUImage&
                    GPUImage& = _NEWIMAGE(__GPU_MODE_COLOR_2_WIDTH, __GPU_MODE_COLOR_2_HEIGHT, 32)

                CASE __GPU_MODE_HICOLOR_1
                    _FREEIMAGE GPUImage&
                    GPUImage& = _NEWIMAGE(__GPU_MODE_HICOLOR_1_WIDTH, __GPU_MODE_HICOLOR_1_HEIGHT, 32)
                CASE __GPU_MODE_HICOLOR_2
                    _FREEIMAGE GPUImage&
                    GPUImage& = _NEWIMAGE(__GPU_MODE_HICOLOR_2_WIDTH, __GPU_MODE_HICOLOR_2_HEIGHT, 32)

                CASE ELSE: _ECHO "ERROR: Invalid video mode!": EXIT SUB
            END SELECT
            GPU.VMode = tmp~%%



        CASE __GPU_REG_PAGEOFFSET, __GPU_REG_PAGEOFFSET + 1
            SHARED GPU AS GPURegisters
            GPU.PageOffset = B2I(DeviceRAM(__GPU_REG_PAGEOFFSET + 1), DeviceRAM(__GPU_REG_PAGEOFFSET))

            'CASE __SND_REG_WRITE
            '    SHARED Waveforms() AS SINGLE
            '    tmp~%% = DeviceRAM(__SND_REG_WRITE_ADDR) * 4
            '    tmp! = DeviceRAM(__SND_REG_WRITE_BYTE) / 255
            '    Waveforms(3, tmp~%%) = tmp!
            '    Waveforms(3, tmp~%% + 1) = tmp!
            '    Waveforms(3, tmp~%% + 2) = tmp!
            '    Waveforms(3, tmp~%% + 3) = tmp!
    END SELECT
END SUB




FUNCTION Bus_Get~%% (a~%)
    '_ECHO HEX$(a~%)
    'DO: LOOP UNTIL LEN(INKEY$)

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


'SUB System_Sound

'    CONST PwrOf2 = 2 ^ (1 / 12)

'    TYPE Channel
'        Wave AS _UNSIGNED _BYTE
'        'Freq AS _UNSIGNED INTEGER
'        Frac AS _UNSIGNED INTEGER
'        Duty AS _UNSIGNED _BYTE
'        Vol AS SINGLE
'    END TYPE

'    STATIC Time AS _BYTE
'    STATIC Ch(3) AS Channel
'    SHARED Waveforms() AS SINGLE
'    STATIC Wave(3, 255) AS SINGLE




'    'Waveform byte (numbers represent channels): 00112233
'    Ch(0).Wave = _SHR(DeviceRAM(__SND_REG_WAVEFORMS) AND &B11000000, 6)
'    Ch(1).Wave = _SHR(DeviceRAM(__SND_REG_WAVEFORMS) AND &B00110000, 4)
'    Ch(2).Wave = _SHR(DeviceRAM(__SND_REG_WAVEFORMS) AND &B00001100, 2)
'    Ch(3).Wave = DeviceRAM(__SND_REG_WAVEFORMS) AND &B00000011

'    'vol bytes (numbers represent channels): 00001111 22223333      'we need to get a SINGLE value
'    Ch(0).Vol = _SHR(DeviceRAM(__SND_REG_VOLS) AND &B11110000, 4) / 16
'    Ch(1).Vol = (DeviceRAM(__SND_REG_VOLS) AND &B00001111) / 16
'    Ch(2).Vol = _SHR(DeviceRAM(__SND_REG_VOLS + 1) AND &B11110000, 4) / 16
'    Ch(3).Vol = (DeviceRAM(__SND_REG_VOLS + 1) AND &B00001111) / 16

'    'duty bytes (numbers represent channels): 00001111 22223333      'note: we need to amplify the duty to improve speed later on, so we "invert" this one
'    'also because reasons we need to dec by one so we do that here
'    Ch(0).Duty = _SHR(DeviceRAM(__SND_REG_DUTIES) AND &B11110000, 1) OR &B10000000
'    Ch(1).Duty = _SHL(DeviceRAM(__SND_REG_DUTIES) AND &B00001111, 3) OR &B10000000
'    Ch(2).Duty = _SHR(DeviceRAM(__SND_REG_DUTIES + 1) AND &B11110000, 1) OR &B10000000
'    Ch(3).Duty = _SHL(DeviceRAM(__SND_REG_DUTIES + 1) AND &B00001111, 3) OR &B10000000

'    ch~%% = 0: DO
'        i~%% = _SHL(ch~%%, 1) 'fastest way to do *2
'        note~%% = DeviceRAM(__SND_REG_NOTES + i~%%)
'        shift%% = DeviceRAM(__SND_REG_NOTES + i~%% + 1)


'        'REM f(n) = 2^((n-29)/12) * 440 'where n is semitones and f is frequency
'        'REM N = note + (s / 127)       'where N is final semitones, n is semitones in reg, and s is shift
'        ''therefore:
'        'REM f(n,s) = 2^(((n+(s/127))/12) * 440  'where f is frequency, n is semitones in reg, and s is shift
'        '        freq! = (2 ^ (((note~%% + (shift%% / 127)) - 49) / 12)) * 440

'        freq! = (PwrOf2 ^ (note~%% - 49)) * 440
'        'IF freq! = 0 THEN freq! = 1
'        Ch(ch~%%).Frac = _SNDRATE / freq!


'        IF Ch(ch~%%).Frac THEN
'            i~%% = 0: DO
'                Wave(ch~%%, i~%%) = Waveforms(Ch(ch~%%).Wave, i~%% MOD Ch(ch~%%).Duty) * Ch(ch~%%).Vol
'            i~%% = i~%% + 1: LOOP WHILE i~%%
'        ELSE Ch(ch~%%).Frac = 1
'        END IF

'    ch~%% = ch~%% + 1: LOOP UNTIL ch~%% = 4


'    DO
'        _SNDRAW (Wave(0, (Time MOD Ch(0).Frac) AND &HFF) + Wave(1, (Time MOD Ch(1).Frac) AND &HFF) + Wave(2, (Time MOD Ch(2).Frac) AND &HFF) + Wave(3, (Time MOD Ch(3).Frac) AND &HFF)) / 4
'    Time = Time + 1: LOOP UNTIL _SNDRAWLEN >= __SND_BUFFERLEN
'END SUB





'SUB System_Sound_GenWaveforms
'    SHARED Waveforms() AS SINGLE
'    FOR i~%% = 0 TO 255
'        Waveforms(0, i~%%) = INT(i~%% / 127)
'        Waveforms(1, i~%%) = ABS(i~%% - 127) / 127
'        Waveforms(2, i~%%) = RND
'    NEXT
'END SUB

SUB System_Sound_GenWaveforms
    SHARED Waveforms() AS SINGLE
    FOR i~%% = 0 TO 255
        FOR t~%% = 0 TO 255
            IF i~%% >= 127 THEN
                Waveforms(i~%%, t~%%) = (t~%% >= (i~%% - 127) / 2)
            ELSE
                SELECT CASE i~%% AND &B11
                    CASE 0: Waveforms(i~%%, t~%%) = t~%% / 255
                    CASE 1: Waveforms(i~%%, t~%%) = ABS(t~%% - 127) / 255
                    CASE 2: Waveforms(i~%%, t~%%) = INT(RND * 16) / 16
                    CASE 3: Waveforms(i~%%, t~%%) = _ROUND(RND)
                END SELECT
            END IF
        NEXT
    NEXT
END SUB


SUB System_Sound
    STATIC Time AS _BYTE
    SHARED Waveforms() AS SINGLE
    STATIC Wave(0 TO 3, 255) AS SINGLE
    STATIC Frac(0 TO 3) AS _UNSIGNED LONG



    ch~%% = 0: DO
        i~%% = _SHL(ch~%%, 2) 'fastest way to do *4
        'DIM CurCh AS channel
        Frac(ch~%%) = _SNDRATE / B2I(DeviceRAM(__SND_REG_PITCH + i~%%), DeviceRAM(__SND_REG_PITCH + i~%% + 1))
        vol! = DeviceRAM(__SND_REG_VOL + i~%%) / 255
        IF Frac(ch~%%) = 0 THEN Frac(ch~%%) = 1
        wform~%% = DeviceRAM(__SND_REG_WAVEFORM + i~%%)

        DO: t~%% = t~%% + 1
            Wave(ch~%%, t~%%) = Waveforms(wform~%%, t~%%) * vol!
        LOOP WHILE t~%%
    ch~%% = ch~%% + 1: LOOP UNTIL ch~%% = 4


    DO
        _SNDRAW (Wave(0, (Time MOD Frac(0)) AND &HFF) + Wave(1, (Time MOD Frac(1)) AND &HFF) + Wave(2, (Time MOD Frac(2)) AND &HFF) + Wave(3, (Time MOD Frac(3)) AND &HFF)) / 4
    Time = Time + 1: LOOP UNTIL _SNDRAWLEN >= __SND_BUFFERLEN

END SUB


SUB System_GPU
    'System_Sound
    'System_Sound
    SHARED GPUImage&, TextModeFont&, GPU AS GPURegisters
    SHARED VRAM() AS _UNSIGNED _BYTE

    SHARED Pallete_4BPP() AS _UNSIGNED LONG
    SHARED Pallete_8BPP() AS _UNSIGNED LONG

    STATIC w AS _UNSIGNED INTEGER, h AS _UNSIGNED INTEGER
    STATIC fw AS _UNSIGNED _BYTE, fh AS _UNSIGNED _BYTE

    i~% = GPU.PageOffset

    'emulate
    _DEST GPUImage&
    CLS
    SELECT CASE GPU.VMode 'draw the screen
        CASE __GPU_MODE_TEXT_1, __GPU_MODE_TEXT_2
            w = _WIDTH
            h = _HEIGHT
            fw = _FONTWIDTH
            fh = _FONTHEIGHT
            y~% = 0: DO 'according to ChiaPet#1361 (ID 404676474126336011 for archival purposes) on QB64 Discord, using this instead of FOR is faster
                x~% = 0: DO
                    tmp~%% = VRAM(i~% + 32768)
                    COLOR Pallete_4BPP((NOT tmp~%%) AND &H0F), Pallete_4BPP(_SHR(tmp~%% AND &HF0, 4))
                    _PRINTSTRING (x~%, y~%), CHR$(VRAM(i~%))

                    i~% = i~% + 1
                x~% = x~% + fw: LOOP UNTIL x~% = w
            y~% = y~% + fh: LOOP UNTIL y~% = h



        CASE __GPU_MODE_HIRES_1
            y~% = 0: DO
                x~% = 0: DO

                    b~%% = VRAM(i~%) 'fastest way to do this ig
                    IF b~%% AND &B00000001 THEN PSET (x~% + 7, y~%)
                    IF b~%% AND &B00000010 THEN PSET (x~% + 6, y~%)
                    IF b~%% AND &B00000100 THEN PSET (x~% + 5, y~%)
                    IF b~%% AND &B00001000 THEN PSET (x~% + 4, y~%)
                    IF b~%% AND &B00010000 THEN PSET (x~% + 3, y~%)
                    IF b~%% AND &B00100000 THEN PSET (x~% + 2, y~%)
                    IF b~%% AND &B01000000 THEN PSET (x~% + 1, y~%)
                    IF b~%% AND &B10000000 THEN PSET (x~%, y~%)
                    i~% = i~% + 1

                x~% = x~% + 8: LOOP UNTIL x~% = __GPU_MODE_HIRES_1_WIDTH
            y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_HIRES_1_HEIGHT

        CASE __GPU_MODE_HIRES_2
            y~% = 0: DO
                x~% = 0: DO

                    b~%% = VRAM(i~%) 'fastest way to do this ig
                    IF b~%% AND &B00000001 THEN PSET (x~% + 7, y~%)
                    IF b~%% AND &B00000010 THEN PSET (x~% + 6, y~%)
                    IF b~%% AND &B00000100 THEN PSET (x~% + 5, y~%)
                    IF b~%% AND &B00001000 THEN PSET (x~% + 4, y~%)
                    IF b~%% AND &B00010000 THEN PSET (x~% + 3, y~%)
                    IF b~%% AND &B00100000 THEN PSET (x~% + 2, y~%)
                    IF b~%% AND &B01000000 THEN PSET (x~% + 1, y~%)
                    IF b~%% AND &B10000000 THEN PSET (x~%, y~%)
                    i~% = i~% + 1

                x~% = x~% + 8: LOOP UNTIL x~% = __GPU_MODE_HIRES_2_WIDTH
            y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_HIRES_2_HEIGHT



        CASE __GPU_MODE_COLOR_1
            y~% = 0: DO
                x~% = 0: DO

                    b~%% = VRAM(i~%)
                    PSET (x~%, y~%), Pallete_4BPP(b~%% AND &H0F)
                    PSET (x~% + 1, y~%), Pallete_4BPP(_SHR(b~%% AND &HF0, 4))

                    i~% = i~% + 1

                x~% = x~% + 2: LOOP UNTIL x~% = __GPU_MODE_COLOR_1_WIDTH
            y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_COLOR_1_HEIGHT

        CASE __GPU_MODE_COLOR_2
            y~% = 0: DO
                x~% = 0: DO

                    b~%% = VRAM(i~%)
                    PSET (x~%, y~%), Pallete_4BPP(b~%% AND &H0F)
                    PSET (x~% + 1, y~%), Pallete_4BPP(_SHR(b~%% AND &HF0, 4))

                    i~% = i~% + 1

                x~% = x~% + 2: LOOP UNTIL x~% = __GPU_MODE_COLOR_2_WIDTH
            y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_COLOR_2_HEIGHT



        CASE __GPU_MODE_HICOLOR_1
            y~% = 0: DO
                x~% = 0: DO
                    PSET (x~%, y~%), Pallete_8BPP(VRAM(i~%))
                    i~% = i~% + 1
                x~% = x~% + 1: LOOP UNTIL x~% = __GPU_MODE_HICOLOR_1_WIDTH
            y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_HICOLOR_1_HEIGHT

        CASE __GPU_MODE_HICOLOR_2
            y~% = 0: DO
                x~% = 0: DO
                    PSET (x~%, y~%), Pallete_8BPP(VRAM(i~%))
                    i~% = i~% + 1
                x~% = x~% + 1: LOOP UNTIL x~% = __GPU_MODE_HICOLOR_2_WIDTH
            y~% = y~% + 1: LOOP UNTIL y~% = __GPU_MODE_HICOLOR_2_HEIGHT

    END SELECT
END SUB

SUB System_GPU_GeneratePalletes
    SHARED Pallete_4BPP() AS _UNSIGNED LONG
    SHARED Pallete_8BPP() AS _UNSIGNED LONG

    'Color pallete
    FOR i~%% = 0 TO 15
        IF i~%% AND &B0001 THEN R~%% = 255
        IF i~%% AND &B0010 THEN G~%% = 255
        IF i~%% AND &B0100 THEN B~%% = 255
        IF (i~%% AND &B1000) = 0 THEN
            R~%% = R~%% / 2
            G~%% = G~%% / 2
            B~%% = B~%% / 2
        END IF
        Pallete_4BPP(i~%%) = _RGB32(R~%%, G~%%, B~%%)
    NEXT

    'HiColor pallete
    FOR i~%% = 0 TO 255
        A~%% = _SHR(i~%% AND &B11000000, 2)
        R~%% = _SHL(i~%% AND &B00000011, 6) OR A~%%
        G~%% = _SHL(i~%% AND &B00001100, 4) OR A~%%
        B~%% = _SHL(i~%% AND &B00110000, 2) OR A~%%
        Pallete_8BPP(i~%%) = _RGB32(R~%%, G~%%, B~%%)
    NEXT
END SUB


FUNCTION fps!
    STATIC last AS SINGLE
    fps = 1 / (TIMER(0.00001) - last)
    last = TIMER(0.00001)
END FUNCTION

SUB System_IO
    WHILE _MOUSEINPUT: WEND

END SUB


'SUB System_GPU_Test (timg&)
'    _SOURCE timg&

'    SELECT CASE __GPU_MODE_HIRES
'        CASE __GPU_MODE_HIRES
'            w~% = _WIDTH(timg&): h~% = _HEIGHT(timg&)
'            y~% = 0: DO
'                x~% = 0: DO

'                    Bus_Write __GSU_GREG_WRITE_ADDR, (i~% AND &H00FF&)
'                    Bus_Write __GSU_GREG_WRITE_ADDR + 1, _SHR(i~% AND &HFF00&, 8)


'    Bus_Write __GSU_GREG_WRITE_BYTE, (_RED32(POINT(x~%    , y~%)) AND 1)    OR _
'    _SHL(_RED32(POINT(x~% + 1, y~%)) AND 1, 1) OR _
'    _SHL(_RED32(POINT(x~% + 2, y~%)) AND 1, 2) OR _
'    _SHL(_RED32(POINT(x~% + 3, y~%)) AND 1, 3) OR _
'    _SHL(_RED32(POINT(x~% + 4, y~%)) AND 1, 4) OR _
'    _SHL(_RED32(POINT(x~% + 5, y~%)) AND 1, 5) OR _
'    _SHL(_RED32(POINT(x~% + 6, y~%)) AND 1, 6) OR _
'    _SHL(_RED32(POINT(x~% + 7, y~%)) AND 1, 7)
'                    i~% = i~% + 1

'                x~% = x~% + 8: LOOP UNTIL x~% = w~%
'            y~% = y~% + 1: LOOP UNTIL y~% = h~%
'    END SELECT
'END SUB
