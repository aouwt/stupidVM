#!/bin/bash

for i in {1..256}; do
	bc="o=(((s($i/(256/(4*a(1)))))+1) * 127); scale=0; o/1"
	if [ $i = "1" ]; then
		o="`bc -l <<< "$bc"`"
	else
		o="$o,`bc -l <<< "$bc"`"
	fi
done

echo " #d8 $o" > ~/git/stupidVM/asm/sin.asm
