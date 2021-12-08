#include <common.h>

reg8 RAM [65535];


reg8 *Access {
	return &RAM; // TODO
}

reg8 Bus::R8 (addr a) {
	return Access () [a];
}
reg16 Bus::R16 (addr a) {
	return (Access () [a+1] << 8) | Access () [a];
}

void Bus::W8 (addr a, reg8 val) {
	Access () [a] = val;
}
void Bus::W16 (addr a, reg16 val) {
	Access () [a] = val & 0x00FF;
	Access () [a+1] = (val & 0xFF00) >> 8;
}

void Bus::Dummy (addr a) {
	Access ();
}