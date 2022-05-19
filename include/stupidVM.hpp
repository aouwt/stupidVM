#ifndef STUPIDVM_HPP
	#define STUPIDVM_HPP
	
	#include <stdint.h>
	#include <stdlib.h>
	
	#define RW_READ 1
	#define RW_WRITE 0
	
	typedef uint_fast8_t U8;
	typedef uint_fast16_t U16;
	typedef uint_fast32_t U32;
	typedef uint_fast64_t U64;
	typedef int_fast8_t S8;
	typedef int_fast16_t S16;
	typedef int_fast32_t S32;
	typedef int_fast64_t S64;
	
	
	typedef U16 Address;
	typedef U8 Word;
	
	struct Pair {
		bool RW;
		Address addr;
		Word word;
	};
#endif
