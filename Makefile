MAKE_O=-r -no-pie -I./include
COPTS=-Ofast -std=c++20 -Wall -Wextra -Wpedantic
CPP=-x c++

SDL2_OPTS=$(shell sdl2-config --cflags)
SDL2_AUDIO_OPTS=${SDL2_OPTS}

./stupidVM: ./src/main.o ./src/SMP100.o
	cc ${COPTS} ./src/main.o ./src/SMP100.o -o ./stupidVM

./src/main.o:
	cc ${COPTS} ${MAKE_O} ./src/main.cpp -o ./src/main.o

./src/SMP100.o: ./src/SMP100/SMP100.o ./src/SMP100/ops.o
	cc ${COPTS} ${MAKE_O} ./src/SMP100/SMP100.o ./src/SMP100/ops.o -o ./src/SMP100.o

./src/SMP100/SMP100.o:
	cc ${COPTS} ${MAKE_O} ${CPP} ./src/SMP100/SMP100.cpp -o ./src/SMP100/SMP100.o

./src/SMP100/ops.o:
	cc ${COPTS} ${MAKE_O} ${CPP} ./src/SMP100/ops.cpp -o ./src/SMP100/ops.o

./src/SAC110/SAC110.o:
	cc ${COPTS} ${SDL2_AUDIO_OPTS} ${MAKE_O} ${CPP} ./src/SAC110/SAC110.cpp -o ./src/SAC110/SAC110.o

./src/SAC110.o: ./src/SAC110/SAC110.o
	cc ${COPTS} ${SDL2_AUDIO_OPTS} ${MAKE_O} ./src/SAC110/SAC110.o -o ./src/SAC110.o
