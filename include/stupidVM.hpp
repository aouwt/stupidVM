#ifndef STUPIDVM_HPP
	#define STUPIDVM_HPP
	
	#include <stdint.h>
	#include <stdlib.h>
	
	#define RW_READ 1
	#define RW_WRITE 0
	
	typedef uint_fast16_t Address;
	typedef uint_fast8_t Word;
	
	struct Pair {
		bool RW;
		Address addr;
		Word word;
	};
#endif
