TYPE Nemonic
    N AS STRING
    Mode AS STRING
    Illegal AS _BYTE
END TYPE

TYPE Symbol
    Val AS SINGLE
    Name AS STRING
END TYPE

TYPE PrgLine
    Op AS STRING
    Arg AS STRING
    PC AS _UNSIGNED INTEGER
END TYPE

DIM Nemonic(255) AS Nemonic
REDIM Symbols(0) AS Symbol
REDIM Prg(0) AS PrgLine

RESTORE Nemonics
FOR i~%% = 0 TO 255
    READ Nemonic(i~%%).N, Nemonic(i~%%).Mode
    IF ASC(Nemonic(i~%%).Mode) = 33 THEN
        Nemonic(i~%%).Mode = MID$(Nemonic(i~%%).Mode, 2)
        Nemonic(i~%%).Illegal = true
    END IF
NEXT


OPEN "test.asm" FOR INPUT AS #1

DO
    LINE INPUT #1, ln$



    tmp~% = INSTR(ln$, ";")
    IF tmp~% THEN ln$ = LEFT$(ln$, tmp~%)
    ln$ = LTRIM$(RTRIM$(ln$))

    'IF RIGHT$(ln$, 1) = ":" THEN

LOOP


SUB Split

    DO
        i% = i% + 1
        SELECT CASE MID$(COMMAND$, i%, 1)

            'CASE "-"
            '  Args$(NextArg%) = MID$(COMMAND$, i%, 2)
            '  i% = i% + 1

            CASE CHR$(34)
                a% = INSTR(i% + 1, COMMAND$, CHR$(34))
                Args$(NextArg%) = MID$(COMMAND$, i% + 1, a% - i% - 1)
                i% = a%

            CASE " "
                IF Args$(NextArg%) <> "" THEN NextArg% = NextArg% + 1

            CASE "": EXIT DO

            CASE ELSE
                Args$(NextArg%) = Args$(NextArg%) + MID$(COMMAND$, i%, 1)

        END SELECT
    LOOP
    ArgCount = NextArg%

END SUB
