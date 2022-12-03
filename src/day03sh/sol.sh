#!/usr/bin/bash

declare -A values=( [a]=1  [b]=2  [c]=3  [d]=4  [e]=5  [f]=6  [g]=7  [h]=8
                    [i]=9  [j]=10 [k]=11 [l]=12 [m]=13 [n]=14 [o]=15 [p]=16
                    [q]=17 [r]=18 [s]=19 [t]=20 [u]=21 [v]=22 [w]=23 [x]=24
                    [y]=25 [z]=26
                    [A]=27 [B]=28 [C]=29 [D]=30 [E]=31 [F]=32 [G]=33 [H]=34
                    [I]=35 [J]=36 [K]=37 [L]=38 [M]=39 [N]=40 [O]=41 [P]=42
                    [Q]=43 [R]=44 [S]=45 [T]=46 [U]=47 [V]=48 [W]=49 [X]=50
                    [Y]=51 [Z]=52 )

a=0
while read -r line
do
    mkdir -p 'sol/1/1' 'sol/1/2'
    # Difference l - r and r - l
    for c in $(echo "${line:0:${#line}/2}" | fold -w1)
    do
        touch "sol/1/1/$c"
    done
    for c in $(echo "${line:${#line}/2}" | fold -w1)
    do
        rm -f "sol/1/1/$c"
        touch "sol/1/2/$c"
    done
    for c in $(echo "${line:0:${#line}/2}" | fold -w1)
    do
        rm -f "sol/1/2/$c"
    done
    # Union
    for c in $(echo "$line" | fold -w 1)
    do
        touch "sol/1/$c"
    done
    # Union - differences
    for c in sol/1/1/*
    do
        rm -f "sol/1/$(basename "$c")"
    done
    for c in sol/1/2/*
    do
        rm -f "sol/1/$(basename "$c")"
    done
    rm -rf 'sol/1/1' 'sol/1/2'
    # Add priorities
    for c in sol/1/*
    do
        a=$((a+values[$(basename "$c")]))
    done
    rm -rf "sol/1"
done < "$INPUT"

echo "$a"

b=0
k=0
while read -r line
do
    mkdir -p "sol/2/$k"

    for c in $(echo "$line" | fold -w 1)
    do
        touch "sol/2/$c"
        touch "sol/2/$k/$c"
    done

    if [ $k -eq 2 ]
    then
        cp -r 'sol/2/0' 'sol/2/3'
        cp -r 'sol/2/1' 'sol/2/4'
        cp -r 'sol/2/1' 'sol/2/5'
        cp -r 'sol/2/2' 'sol/2/6'
        # Differences
        for c in sol/2/1/*
        do
            rm -f "sol/2/3/$(basename "$c")"
        done
        for c in sol/2/0/*
        do
            rm -f "sol/2/4/$(basename "$c")"
        done
        for c in sol/2/2/*
        do
            rm -f "sol/2/5/$(basename "$c")"
        done
        for c in sol/2/1/*
        do
            rm -f "sol/2/6/$(basename "$c")"
        done
        rm -rf 'sol/2/0' 'sol/2/1' 'sol/2/2'
        for c in sol/2/*/*
        do
            rm -f "sol/2/$(basename "$c")"
        done
        rm -rf 'sol/2/3' 'sol/2/4' 'sol/2/5' 'sol/2/6'
        # Add priorities
        for c in sol/2/*
        do
            b=$((b+values[$(basename "$c")]))
        done
        rm -rf 'sol/2'
    fi

    k=$((k+1))
    if [ $k -eq 3 ]
    then
        k=0
    fi
done <"$INPUT"

echo "$b"
