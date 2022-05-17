#include <stdio.h>

#define TYPE_BOOL	0x00
#define TYPE_ui8	0x10
#define TYPE_ui16	0x11
#define TYPE_i8		0x20
#define TYPE_i16	0x21


typedef ptr unsigned long; // 24 bits actually but since there isnt a u_int24_t this'll have to do
typedef type char;

struct Item {
	char	name[];
	ptr	ptr;
	type	type;
};


char* cg_add (Item v[], char argl) {
	// check types
	for (unsigned char p = 1; p != argl; p++) {
		if (v[0].type != v[p].type)
			error ("Mismatching types!");
	}
	
	// codegen
	
}
