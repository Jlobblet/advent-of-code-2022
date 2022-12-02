NB. Parsing is made of three sections: splitting the input into each elf, then
NB. splitting each elf into their list of calories, and then recombining.

NB. LF2 splitnostring toJ handles the first part, returning an array of boxed
NB. strings for each elf.
NB. u&.> enters each box and performs the verb u on its contents, then re-boxes
NB. the results. Here, the verb is [: +/ @: ; @: (".&.>) LF cut ], which does
NB. the following things in turn:
NB. - splits on newlines (again returning a boxed array of strings) (LF cut ])
NB. - parses each boxed string as an integer (".&.>)
NB. - removes the boxes (;)
NB. - adds up the total (+/)
NB. Then, ; removes the boxing from the final array
parse =: [: ; [: ([: +/ @: ; @: (".&.>) LF cut ])&.> LF2 splitnostring toJ

NB. The largest value is the solution to part a.
NB. >. finds the maximum value of two elements, and / inserts it between each
NB. element of the array, performing a reduction
a =: >./

NB. Part b wants the sum of the top 3, so we sort the array in descending order
NB. with \:~, pick the first 3 with 3 {., and then sum with +/
b =: [: +/ 3 {. \:~
