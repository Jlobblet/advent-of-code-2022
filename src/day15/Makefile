INPUT=../../data/15.txt
TARGET_Y=2000000

DC=dmd

.PHONY: clean build run

clean:
	rm -rf day15 day15.o

day15:
	$(DC) -O day15.d

build: day15

run: day15
	INPUT=$(INPUT) TARGET_Y=$(TARGET_Y) ./day15
