.PHONY: day01 day01c day01rs day02 day03 day03fs day03c day03sh day04 day04agda
.PHONY: day05 day06 day07py day08 day09 day10 day10cs day10ex day11 day12 day13
.PHONY: day14 day15 day21

day01:
	$(MAKE) -C src/day01 run

day01c:
	$(MAKE) -C src/day01c clean run

day01rs:
	$(MAKE) -C src/day01rs run

day02:
	$(MAKE) -C src/day02 run

day03:
	$(MAKE) -C src/day03 run

day03fs:
	$(MAKE) -C src/day03fs run

day03c:
	$(MAKE) -C src/day03c clean run

day03sh:
	$(MAKE) -C src/day03sh clean run

day04:
	$(MAKE) -C src/day04 run

day04agda:
	$(MAKE) -C src/day04agda clean run

day05:
	$(MAKE) -C src/day05 run

day06:
	$(MAKE) -C src/day06 run

day07py:
	$(MAKE) -C src/day07py run

day08:
	$(MAKE) -C src/day08 run

day09:
	$(MAKE) -C src/day09 run

day10:
	$(MAKE) -C src/day10 run

day10cs:
	$(MAKE) -C src/day10cs run-fancy

day10ex:
	$(MAKE) -C src/day10ex run

day11:
	$(MAKE) -C src/day11 run

day12:
	$(MAKE) -C src/day12 run

day13:
	$(MAKE) -C src/day13 run

day14:
	$(MAKE) -C src/day14 run

day15:
	$(MAKE) -C src/day15 clean run

day21:
	CFLAGS=-O3 $(MAKE) -C src/day21 clean run

