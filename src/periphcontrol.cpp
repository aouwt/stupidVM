#include "Peripherals.hpp"
#include "Peripheral.h"
#include "stupidVM.h"
#include "main.hpp"
#include "periphcontrol.hpp"

struct periphcontrol {
	U8 curperiph;
};

void io (void *_this, PeripheralBus *bus) {
	struct periphcontrol *_ = (struct periphcontrol *) _this;
	switch (bus -> addr) {
		case 0x0:
			if (bus -> RW == RW_READ)
				bus -> word = _->curperiph;
			else
				_->curperiph = bus -> word & 0xF;
		break;
		
		case 0x1: case 0x2: case 0x3: case 0x4:
			if (bus -> RW == RW_READ)
				bus -> word = Perip -> Perip [_->curperiph].info -> Name [bus -> addr - 1];
		break;
			
		case 0xF:
			if (bus -> RW == RW_READ)
				bus -> word = Memories::CurBank;
			else
				Memories::CurBank = bus -> word;
		break;
	}
}

const PeripheralInfo P_ThisInfo {
	.Constructor = NULL,
	.Destructor = NULL,
	.IO = &io,
	.Int = NULL,
	.Name = { 'p', 'i', 'n', 'f' },
	.Size = sizeof (struct periphcontrol),
};
