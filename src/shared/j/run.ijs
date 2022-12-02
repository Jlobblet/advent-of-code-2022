require 'sol.ijs'

sol =. {{
    echo 'Parse:'
    echo 100 timespacex 'P =. parse y'
    ats =. 100 timespacex 'A =. a P'
    echo 'A:'
    echo A
    echo ats
    bts =. 100 timespacex 'B =. b P'
    echo 'B:'
    echo B
    echo bts
}}

input =. 'MODE' freads&:(2!:5) 'INPUT'
sol input

exit ''
