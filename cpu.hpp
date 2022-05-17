#include <stdint.h>
#include <stdlib.h>
#define RW_READ 1
#define RW_WRITE 0
typedef uint_fast16_t Address;
typedef uint_fast8_t Word;
class SMP100 {
	
	public:
		struct Pair {
			bool RW;
			Address addr;
			Word word;
		};
		
		struct Pair Bus;
		
		void SignalInt (short ID);
		void SignalReset (Address PrgStart);
		
		void Cycle (void);
		
		// "private" (needed public for the callbacks and stuff)
		struct {
			uint_fast16_t A;
			uint_fast16_t B;
			bool C;
			uint_fast32_t M;
			
			bool Carry;
			uint_fast32_t PC;
			uint_fast8_t StackPtr;
			
			uint_fast8_t IStor;
			uint_fast16_t IStor2;
			
			uint_fast16_t Ints [16];
			uint_fast16_t IntRet;
		} Reg;
		
		struct {
			uint_fast16_t Reset;
			uint_fast16_t StackBegin;
		} HWReg;
		
		int_fast8_t NextInt = -1;
		typedef void (* OpFunc) (SMP100 *);
		const OpFunc *Operation = NULL;
		
		static const OpFunc *Opcodes [];
		static const OpFunc Op_Reset [];
		static const OpFunc Op_BeginCycle [];
};
