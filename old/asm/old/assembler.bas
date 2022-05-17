$CONSOLE:ONLY
TYPE Nemonic
    N AS STRING
    Mode AS STRING
    Illegal AS _BYTE
END TYPE

TYPE Symbol
    Val AS STRING
    Name AS STRING
    Scope AS _UNSIGNED INTEGER
END TYPE

TYPE PrgLine
    Op AS STRING
    Arg AS STRING
    PC AS _UNSIGNED INTEGER
END TYPE

CONST TRUE = -1, FALSE = 0



FOR i~% = 1 TO _COMMANDCOUNT
    IF ASC(COMMAND$(i~%)) = 45 THEN '-
        SELECT CASE COMMAND$(i~%)
            CASE "-i"
                i~% = i~% + 1
                InpFile$ = COMMAND$(i~%)

            CASE "-o"
                i~% = i~% + 1
                OutpFile$ = COMMAND$(i~%)

            CASE ELSE
                PRINT USING "Invalid option '&'"; COMMAND$(i~%)
        END SELECT

    ELSE
        IF LEN(InpFile$) THEN 'if we already specified input file...
            OutpFile$ = COMMAND$(i~%) '...then its (hopefully) the output file
        ELSE InpFile$ = COMMAND$(i~%) 'otherwise, its (hopefully) the input file
        END IF
    END IF
NEXT


DIM SHARED Nemonic(255) AS Nemonic
REDIM SHARED Symbols(0) AS Symbol
REDIM SHARED Prg(0) AS PrgLine
DIM SHARED AnotherPass`

RESTORE Nemonics
FOR i~%% = 0 TO 255
    READ Nemonic(i~%%).N, Nemonic(i~%%).Mode
    IF ASC(Nemonic(i~%%).Mode) = 33 THEN '!
        Nemonic(i~%%).Mode = MID$(Nemonic(i~%%).Mode, 2)
        Nemonic(i~%%).Illegal = TRUE
    END IF
NEXT


OPEN InpFile$ FOR INPUT AS #1

DO
    LINE INPUT #1, ln$

    tmp~% = INSTR(ln$, ";")
    IF tmp~% THEN ln$ = LEFT$(ln$, tmp~%)
    ln$ = LTRIM$(RTRIM$(ln$))


    FOR i~% = 1 TO LEN(ln$)
        SELECT CASE ASC(ln$, i~%)

            CASE 34 '"
                a~% = INSTR(i~% + 1, ln$, CHR$(34))
                args$(NextArg~%) = MID$(ln$, i~% + 1, a~% - i~% - 1)
                i~% = a~%

            CASE 61 '=
                NextArg~% = NextArg~% + 1
                args$(NextArg~%) = "="
                NextArg~% = NextArg~% + 1

            CASE 32 '
                IF args$(NextArg~%) <> "" THEN NextArg~% = NextArg~% + 1

            CASE ELSE
                args$(NextArg~%) = args$(NextArg~%) + CHR$(ASC(ln$, i~%))

        END SELECT
    NEXT

    IF args$(1) = "=" THEN 'if setting something
        NewSymbol args$(0), args$(2)
    END IF
LOOP

'$INCLUDE:'./nemonics.bas'


SUB NewSymbol (Sym$, Val$)

    IF ASC(Sym$) = 46 THEN '.
        'is local symbol

        SHARED curscope~%
        FOR i~% = 0 TO UBOUND(symbols)

            IF Symbols(i~%).Scope = curscope~% THEN: IF Symbols(i~%).Name = Sym$ THEN
                    Symbols(i~%).Val = Val$
                    EXIT SUB
            END IF: END IF

        NEXT

        i~% = i~% + 1
        REDIM _PRESERVE Symbols(i~%) AS Symbol

        Symbols(i~%).Name = Sym$
        Symbols(i~%).Val = Val$
        Symbols(i~%).Scope = curscope~%


    ELSE
        'is shared symbol
        FOR i~% = 0 TO UBOUND(symbols)

            IF Symbols(i~%).Name = Sym$ THEN
                Symbols(i~%).Val = Val$
                EXIT SUB
            END IF

        NEXT

        REDIM _PRESERVE Symbols(i~%) AS Symbol
        Symbols(i~%).Name = Sym$
        Symbols(i~%).Val = Val$
        Symbols(i~%).Scope = 0


    END IF
END SUB


FUNCTION GetSymbol$ (Sym$)
    IF ASC(Sym$) = 46 THEN '.
        'is local symbol

        SHARED curscope~%
        FOR i~% = 0 TO UBOUND(symbols)

            IF Symbols(i~%).Scope = curscope~% THEN: IF Symbols(i~%).Name = Sym$ THEN
                    GetSymbol = Symbols(i~%).Val
                    EXIT FUNCTION
            END IF: END IF

        NEXT
    ELSE
        'is shared symbol
        FOR i~% = 0 TO UBOUND(symbols)

            IF Symbols(i~%).Name = Sym$ THEN
                GetSymbol = Symbols(i~%).Val
                EXIT FUNCTION
            END IF

        NEXT
    END IF
    GetSymbol = ""
    AnotherPass` = TRUE
END FUNCTION



SUB Split (ln$, args$())

    DIM i AS _UNSIGNED INTEGER
    DIM NextArg AS _UNSIGNED _BYTE

    FOR i = 1 TO LEN(ln$)
        SELECT CASE ASC(ln$, i)

            CASE 34
                a~% = INSTR(i + 1, ln$, CHR$(34))
                args$(NextArg) = MID$(ln$, i + 1, a~% - i - 1)
                i = a~%

            CASE 32
                IF args$(NextArg) <> "" THEN NextArg = NextArg + 1

            CASE ELSE
                args$(NextArg) = args$(NextArg) + CHR$(ASC(ln$, i))

        END SELECT
    NEXT

    REDIM _PRESERVE args$(NextArg)
END SUB
