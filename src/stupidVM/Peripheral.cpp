#include "Peripheral.hpp"

template <class device> Peripheral::PeripheralID Peripheral::New (void) {
	PeripheralID id = Add <device> ();
	PowerOn (id);
	return id;
}

void Peripheral::Delete (Peripheral::PeripheralID ID) {
	PowerOff (ID);
	Remove (ID);
}


template <class device> Peripheral::PeripheralID Peripheral::Add (void) {
	PeripheralID id;
	
	// find next available peripheral slot
	for (id = 0; id != 16; id ++) {
		if (perip [id].obj == NULL)
			break;
	}
	
	if (id == 16)
		return -1; // signify error
			
	
	perip [id].obj = new device;
	perip [id].info = &((device *) perip [id].obj) -> PeripheralInfo;
	return id;
}

void Peripheral::Remove (Peripheral::PeripheralID ID) {
	if (perip [ID].obj != NULL)
		delete perip [ID].obj;
}


void Peripheral::PowerOn (Peripheral::PeripheralID ID) {
	perip [ID].info -> Constructor (perip [ID].obj);
}

void Peripheral::PowerOff (Peripheral::PeripheralID ID) {
	perip [ID].info -> Destructor (perip [ID].obj);
}


Peripheral::~Peripheral (void) {
	for (PeripheralID id = 0; id != 16; id ++)
		Delete (id);
}
