#include "SMP100.hpp"
#include "periphial.hpp"
#include <stdio.h>

PeripheralFunc Peripherals [16];

SMP100 CPU (0xA000, 0x1F00);

namespace Memories {
	Word ASpace [0xFFFF];
	Word Banks [0xFF] [0x8000];
	U8 CurBank;
};

void cycle (void) {
	#define WRITE(to)	to [addr] = CPU.Bus.word
	#define READ(from)	CPU.Bus.word = from [addr]
	
	Address addr = CPU.Bus.addr;
	CPU.Cycle ();
	
	if ((addr >= 0x2000) && (addr < 0xA000)) {
		if (CPU.Bus.RW == RW_READ)
			READ (Memories::Banks [CurBank]);
		else {
			if (Memories::CurBank < 127)
				WRITE (Memories::Banks [CurBank]);
		}
		
	} else
	if ((addr >= 0xA000) && (addr < 0xFF00)) {
		if (CPU.Bus.RW == RW_READ)
			READ (Memories::ASpace);
	} else
	{
		if (CPU.Bus.RW == RW_READ)
			READ (Memories::ASpace);
		else
			WRITE (Memories::ASpace);
	}
	
	#undef WRITE
	#undef READ
}


int main (void) {
	CPU.SignalReset ();
	
	while (true) {
		CPU.Cycle ();
		//if (CPU.Bus.RW == RW_READ)
		//	CPU.Bus.word = mem [CPU.Bus.addr];
		//else
		//	mem [CPU.Bus.addr] = CPU.Bus.word;
	}
}
