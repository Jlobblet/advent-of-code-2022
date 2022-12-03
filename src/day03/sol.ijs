NB. The letters a-z and A-Z in that order
letters =: , a. {~ (i.26) +/~ a.i. 'aA'
intersect =: e. # [

NB. Index of each letter in the letters array, plus one
parse =: ([: >: letters i. ])&.>

NB. Intersection between first half and second half
NB.
NB. For each parsed line (of numbers):
NB. # is the number of items in this bag, and -: halves it
NB. {. is take and }. is drop, giving us the first and second halves
NB. Then, find the unique values in each half with ~. and intersect the
NB. resulting arrays
aLine =: (({. intersect&:~. }.)~ -:@:#)&.>

NB. Intersection between windows of three rucksacks
NB.
NB. _3 u\ ] divides the input into non-overlapping windows of length 3
NB. Then, find the intersection of all three with / insert
bLine =: _3 (intersect&:(~.@:>))/\ ]
NB. Sum of raze of solution
general =: {{ +/ ; u y }}
a =: aLine general
b =: bLine general
