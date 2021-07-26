Nemonics:
DATA load.a,imm
DATA load.a,abs
DATA load.a,m
DATA load.a,!b

DATA load.b,imm
DATA load.b,abs
DATA load.b,m
DATA load.b,!a

DATA load.m,imm2
DATA load.m,abs
DATA load.m,!m
DATA load.m,!ab

DATA jump,rel
DATA jump,abs
DATA jump,m
DATA jump,!ab


DATA add.a,imm
DATA add.a,abs
DATA add.a,m
DATA add.a,b

DATA add.b,imm
DATA add.b,abs
DATA add.b,m
DATA add.b,a

DATA add.m,imm
DATA add.m,abs
DATA add.m,!m
DATA add.m,!ab

DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?


DATA sub.a,imm
DATA sub.a,abs
DATA sub.a,m
DATA sub.a,b

DATA sub.b,imm
DATA sub.b,abs
DATA sub.b,m
DATA sub.b,a

DATA sub.m,imm
DATA sub.m,abs
DATA sub.m,!m
DATA sub.m,!ab

DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?


DATA comp.a,imm
DATA comp.a,abs
DATA comp.a,m
DATA comp.a,b

DATA comp.b,imm
DATA comp.b,abs
DATA comp.b,m
DATA comp.b,a

DATA comp.m,imm
DATA comp.m,abs
DATA comp.m,!m
DATA comp.m,!ab

DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?


DATA save.a,!imm
DATA save.a,abs
DATA save.a,m
DATA save.a,!a

DATA save.b,!imm
DATA save.b,abs
DATA save.b,m
DATA save.b,!b

DATA save.m,!imm
DATA save.m,abs
DATA save.m,!m
DATA save.m,!ab

DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?


DATA and.a,imm
DATA and.a,abs
DATA xor.a,imm
DATA xor.a,abs

DATA and.b,imm
DATA and.b,abs
DATA xor.b,imm
DATA xor.b,abs

DATA and.m,!imm
DATA and.m,!abs
DATA xor.m,!imm
DATA xor.m,!abs

DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?


DATA ifz.a,rel
DATA ifz.a,abs
DATA or.a,imm
DATA or.a,abs

DATA ifz.b,rel
DATA ifz.b,abs
DATA or.b,imm
DATA or.b,abs

DATA if.c,rel
DATA if.c,abs
DATA or.m,!imm
DATA or.m,!abs

DATA if.car,rel
DATA if.car,abs

DATA ?,?
DATA ?,?


DATA ifnz.a,rel
DATA ifnz.a,abs

DATA ?,?
DATA ?,?

DATA ifnz.b,rel
DATA ifnz.b,abs

DATA ?,?
DATA ?,?

DATA ifn.c,rel
DATA ifn.c,abs

DATA ?,?
DATA ?,?

DATA ifn.car,rel
DATA ifn.car,abs

DATA ?,?
DATA ?,?



DATA lsh.a,none
DATA rsh.a,none
DATA lrot.a,none
DATA rrot.a,none

DATA lsh.b,none
DATA rsh.b,none
DATA lrot.b,none
DATA rrot.b,none

DATA lsh.m,none
DATA rsh.m,none
DATA lrot.m,none
DATA rrot.m,none

DATA lsh.pc,!none
DATA rsh.pc,!none
DATA lrot.pc,!none
DATA rrot.pc,!none


DATA push.a,none
DATA pull.a,none
DATA inc.a,none
DATA dec.a,none

DATA push.b,none
DATA pull.b,none
DATA inc.b,none
DATA dec.b,none

DATA push.m,none
DATA pull.m,none
DATA inc.m,none
DATA dec.m,none

DATA push.pc,none
DATA pull.pc,none
DATA inc.pc,!none
DATA dec.pc,!none


DATA move.a-a,!none
DATA move.a-b,none
DATA move.a-ma,none
DATA move.a-am,none

DATA move.b-a,none
DATA move.b-b,!none
DATA move.b-mb,none
DATA move.b-bm,none

DATA move.ab-m,none
DATA move.ba-m,none

DATA move.m-ab,none
DATA move.m-ba,none

DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?


DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?

DATA set.c,none
DATA set.c,!none

DATA ?,?
DATA ?,?

DATA set.car,none
DATA set.car,!none

DATA ?,?
DATA ?,?


DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?

DATA clear.c,none
DATA clear.c,!none

DATA ?,?
DATA ?,?

DATA clear.car,none
DATA clear.car,!none

DATA ?,?
DATA ?,?


DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?



DATA inc,abs
DATA dec,abs
DATA reti,none
DATA setint,imm
DATA int,imm

DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?
DATA ?,?

DATA break,none
