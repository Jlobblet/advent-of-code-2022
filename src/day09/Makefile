INPUT=../../data/09.txt

AGDA=agda

.PHONY: clean full-clean build run

clean:
	rm -rf day09

full-clean: clean
	rm -rf MAlonzo *.agdai

day09:
	$(AGDA) --compile day09.agda

build: day09

run: build
	./day09 $(INPUT)
