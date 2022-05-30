#include <stdio.h>

#include "Peripheral.h"

void prt (void *unused, PeripheralBus *bus) {
	putchar (bus -> word);
}
