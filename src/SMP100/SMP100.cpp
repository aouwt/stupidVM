#include "SMP100.hpp"
void SMP100::Cycle (void) {
	if (*(++ Operation) == NULL)
		Operation = Op_BeginCycle;
	
	(*Operation) (this);
	
	if (Reg.A > 0xFF) {
		Reg.A &= 0xFF;
		Reg.Carry |= true;
	}
	if (Reg.B > 0xFF) {
		Reg.B &= 0xFF;
		Reg.Carry |= true;
	}
	if (Reg.M > 0xFFFF) {
		Reg.M &= 0xFFFF;
		Reg.Carry |= true;
	}
	if (Reg.PC > 0xFFFF) {
		Reg.PC &= 0xFFFF;
		Reg.Carry |= true;
	}
}

void SMP100::SignalInt (short ID) {
	NextInt = ID;
}

void SMP100::SignalReset (void) {
	//Operation = Op_Reset;
}
