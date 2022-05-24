#include "SMP100.hpp"
#include "peripheral.hpp"
#include "stupidVM_SDL.hpp"
#include <stdio.h>

static PeripheralFunc_IO Peripherals [16];

static SMP100 *CPU;

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
		U8 p = ((addr & 0x00F0) >> 4);
		if (Peripherals [p] != NULL) {
			PeripheralBus bus = {
				.RW = CPU -> Bus.RW,
				.addr = (U8) (CPU -> Bus.addr & 0x000F),
				.word = CPU -> Bus.word
			};
			(Peripherals [p]) (&bus); // call func
			CPU -> Bus.word = bus.word;
		}
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
	
	CPU -> SignalReset ();
	Timer timer (8000); // in KHz
	
	while (true) {
		timer.Wait ();
		for (U16 i = 0; i != 1000; i ++)
			cycle ();
	}
	
	delete CPU;
}
