INPUT=../../data/04.txt

.PHONY: clean full-clean build run

clean:
	rm -rf day04

full-clean: clean
	rm -rf MAlonzo *.agdai

day04:
	agda --compile day04.agda

build: day04

run: build
	./day04 $(INPUT)
