use std::env::var;
use std::fs::File;
use std::io::{BufRead, BufReader};

fn aoc1<I: BufRead>(mut input: I, n: usize) -> (usize, usize) {
    let mut top_n = Vec::with_capacity(n + 1);
    let mut current = 0;
    let mut buffer = String::new();
    while let Ok(k) = input.read_line(&mut buffer) {
        if k == 0 {
            break;
        } else if k == 1 {
            top_n.push(current);
            current = 0;
            top_n.sort_unstable_by_key(|&k| std::cmp::Reverse(k));
            top_n.truncate(n);
        } else {
            current += buffer.trim().parse::<usize>().unwrap();
        }
        buffer.clear();
    }

    (top_n[0], top_n.iter().sum())
}

fn main() {
    let file = File::open(var("INPUT").expect("Missing INPUT environment variable"))
        .expect("Should be able to open input file");
    let (a, b) = aoc1(BufReader::new(file), 3);
    println!("A: {a}\nB: {b}");
}
