INPUT=../../data/11.txt

GRADLE=gradle

.PHONY: wrapper clean build run

wrapper:
	$(GRADLE) wrapper --gradle-version 7.6

clean:
	$(GRADLE) clean

build: wrapper
	$(GRADLE) build

run: build
	INPUT=$(INPUT) $(GRADLE) run
