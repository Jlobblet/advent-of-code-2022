NB. This parser is made of two stages:
NB. First, removing the spaces from the input via 1 0 1 #"1 1
NB. Second, replacing A with 0, B with 1, C with 2, and similar for X, Y, Z
parse =: 0 1 2 0 1 2 {~ 'ABCXYZ' i. 1 0 1 #"1 1 ]

NB. For part a, notice that winning is denoted by one larger mod 3, a draw is
NB. when equal, and a loss is when smaller mod 3.
NB. Hence, we have -1 for loss, 0 for draw, 1 for win
NB. Add 1 and multiply by three to get 0, 3, 6, which is our desired value for
NB. the result. {: gets our play and adds it for the total, and then +/ sums.
a =: [: +/ [: >: ({: + 3 * 3 | [: >: -~/)"1

NB. For part b, we can rearrange to get our play as being result + theirs mod 3.
NB. then, add the result times 3 via 3 * {: to that and we have the answer. Sum
NB. with +/ as before.
b =: [: +/ ((3 * {:) + 3 | +/)"1
