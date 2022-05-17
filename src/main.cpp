#include "SMP100.hpp"
#include <stdio.h>

int main (void) {
	SMP100 CPU (0x0000, 0x0100);
	Word mem [0xFFFF] = { 0x92 };
	CPU.SignalReset ();
	
	while (true) {
		CPU.Cycle ();
		if (CPU.Bus.RW == RW_READ)
			CPU.Bus.word = mem [CPU.Bus.addr];
		else
			mem [CPU.Bus.addr] = CPU.Bus.word;
	}
}
