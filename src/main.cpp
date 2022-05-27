#include "SMP100.hpp"
#include "Peripherals.hpp"
#include "stupidVM_Supp.hpp"
#include "SAC120.h"
#include <stdio.h>


static SMP100 *CPU;
static Peripherals *Perip;

namespace Memories {
	Word ASpace [0xFFFF];
	Word Banks [0xFF] [0x8000];
	U8 CurBank;
};


void cycle (void) {
	#define WRITE(to)	to [addr] = CPU -> Bus.word
	#define READ(from)	CPU -> Bus.word = from [addr]
	
	Address addr = CPU -> Bus.addr;
	CPU -> Cycle ();
	
	if ((addr >= 0x2000) && (addr < 0xA000)) {
		if (CPU -> Bus.RW == RW_READ)
			READ (Memories::Banks [Memories::CurBank]);
		else {
			if (Memories::CurBank < 127)
				WRITE (Memories::Banks [Memories::CurBank]);
		}
		
	} else
	if ((addr >= 0xA000) && (addr < 0xFF00)) { // SROM
		if (CPU -> Bus.RW == RW_READ)
			READ (Memories::ASpace);
	} else
	if (addr >= 0xFF00) {	// Peripheral
		Perip -> BusAction (&CPU -> Bus);
	} else {	// SRAM
		if (CPU -> Bus.RW == RW_READ)
			READ (Memories::ASpace);
		else
			WRITE (Memories::ASpace);
	}
	#undef WRITE
	#undef READ
}


int main (void) {
	CPU = new SMP100 (0xA000, 0x1F00);
	Perip = new Peripherals;
	Perip -> New (&SAC120);
	
	CPU -> SignalReset ();
	Timer timer (8000); // in KHz
	
	while (true) {
		timer.Wait ();
		for (U16 i = 0; i != 1000; i ++)
			cycle ();
	}
	
	delete CPU;
}
