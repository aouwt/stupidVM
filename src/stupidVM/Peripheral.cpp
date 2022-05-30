#include "stupidVM.h"
#include "Peripherals.hpp"

#define CALL2(id, what, ...) { \
		if (perip [id].info -> what != NULL) \
			perip [id].info -> what (perip [id].obj, __VA_ARGS__); \
	}
#define CALL(id, what) { \
		if (perip [id].info -> what != NULL) \
			perip [id].info -> what (perip [id].obj); \
	}


Peripherals::PeripheralID Peripherals::New (const PeripheralInfo *Info) {
	PeripheralID id = Add (Info);
	PowerOn (id);
	return id;
}

void Peripherals::Delete (Peripherals::PeripheralID ID) {
	PowerOff (ID);
	Remove (ID);
}


Peripherals::PeripheralID Peripherals::Add (const PeripheralInfo *Info) {
	PeripheralID id;
	
	// find next available peripheral slot
	for (id = 0; id != 16; id ++) {
		if (perip [id].obj == NULL)
			break;
	}
	
	if (id == 16)
		return -1; // signify error
			
	
	perip [id].obj = malloc (Info -> Size);
	perip [id].info = Info;
	return id;
}

void Peripherals::Remove (Peripherals::PeripheralID ID) {
	if (perip [ID].obj != NULL)
		free (perip [ID].obj);
}


void Peripherals::PowerOn (Peripherals::PeripheralID ID) {
	CALL (ID, Constructor);
}

void Peripherals::PowerOff (Peripherals::PeripheralID ID) {
	CALL (ID, Destructor);
}

void Peripherals::BusAction (struct Pair *bus) {
	U8 ID = (bus -> addr & 0xF0) >> 4;
	
	PeripheralBus bus2;
	
	bus2.RW = bus -> RW;
	bus2.addr = bus -> addr & 0x0F;
	bus2.word = bus -> word;
	
	CALL2 (ID, IO, &bus2);
	
	bus -> word = bus2.word;
}


Peripherals::~Peripherals (void) {
	for (PeripheralID id = 0; id != 16; id ++)
		Delete (id);
}

Peripherals::Peripherals (void) {
	static const PeripheralInfo definfo = { NULL };
	
	for (PeripheralID id = 0; id != 16; id ++) {
		perip [id].info = &definfo;
		perip [id].obj = NULL;
	}
}
