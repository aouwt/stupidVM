MAKE_O=cc ${COPTS} ${CPP} -r -no-pie -o $@

COPTS=-Ofast -std=c++20 -Wall -Wextra -Wpedantic -I./include
CPP=-x c++

SDL2=$(shell sdl2-config --cflags)
SDL2_AUDIO=${SDL2}
SDL2_THREAD=${SDL2}

./stupidVM: ./obj ./obj/main.o ./obj/SMP100.o
	cc ${COPTS} ./obj/*.o -o ./stupidVM


./obj:
	mkdir obj

./obj/main.o:	./obj; ${MAKE_O} ./src/*.cpp

./obj/SMP100.o:	./obj; ${MAKE_O} ${SDL2_THREAD} ./src/SMP100/*.cpp
./obj/SAC120.o:	./obj; ${MAKE_O} ${SDL2_AUDIO} ./src/SMP120/*.cpp
./obj/SGC100.o:	./obj; ${MAKE_O} ${SDL2} ./src/SGC100/*.cpp


clean:
	rm -rf ./obj

.PHONY: clean
