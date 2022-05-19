MAKE_O=-r -no-pie -I./include
COPTS=-Ofast -std=c++20 -x c++ -Wall -Wextra -Wpedantic


./src/main.o:
	cc ${COPTS} ${MAKE_O} ./src/main.cpp -o ./src/main.o

./src/SMP100.o: ./src/SMP100/SMP100.o ./src/SMP100/ops.o
	cc ${COPTS} ${MAKE_O} ./src/SMP100/SMP100.o ./src/SMP100/ops.o -o ./src/SMP100.o

./src/SMP100/SMP100.o:
	cc ${COPTS} ${MAKE_O} ./src/SMP100/SMP100.cpp -o ./src/SMP100/SMP100.o

./src/SMP100/ops.o:
	cc ${COPTS} ${MAKE_O} ./src/SMP100/ops.cpp -o ./src/SMP100/ops.o
