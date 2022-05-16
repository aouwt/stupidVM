	

void SMP100::Cycle (void) {
	if (++ Operation == NULL)
		Operation = &Op_BeginCycle;
	
	Operation (this);
	
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
	if (Reg.StackPtr > 0xFF) {
		Reg.StackPtr &= 0xFF;
		Reg.Carry |= true;
	}
}
