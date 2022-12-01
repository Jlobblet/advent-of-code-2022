INPUT=../../data/01.txt

CC=gcc-9
CFLAGS=-g

.PHONY: run clean

day01:
	$(CC) src.c $(CFLAGS) -o day01

run: day01
	./day01 < $(INPUT)

debug: day01
	gdb day01 < $(INPUT)

clean:
	rm -rf day01 elves

clean-run: clean run
