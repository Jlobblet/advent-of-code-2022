INPUT=../../data/03.txt

CC=gcc-9
CFLAGS=-O3 -std=c2x

.PHONY: run clean

day03:
	$(CC) src.c $(CFLAGS) -o day03

build: day03

run: build
	./day03 $(INPUT)

clean:
	rm -rf day03
