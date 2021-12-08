typedef uint_fast8_t reg8;
typedef uint_fast16_t reg16;
typedef bool reg1;

typedef reg16 addr;

namespace Bus {
	extern reg8 R8 (addr);
	extern reg16 R16 (addr);
	extern void W8 (addr, reg8);
	extern void W16 (addr, reg16);
	extern void Dummy (addr);
}

namespace CPU {
	extern void Cycle (void);
}