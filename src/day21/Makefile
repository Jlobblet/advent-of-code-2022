INPUT=../../data/21.txt

CC=gcc-9
CFLAGS=-g

.PHONY: run clean

all: run

day21:
	$(CC) src.c $(CFLAGS) -o day21

run: day21
	./day21 $(INPUT)

debug: day21
	gdb day21 $(INPUT)

clean:
	rm day21
