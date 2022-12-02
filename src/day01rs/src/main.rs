use std::env::var;
use std::fs::File;
use std::io::{BufRead, BufReader};

/// This is a streaming approach to both parts in day one. It is designed so
/// that it does not need to keep the whole input file in memory at once.
fn aoc1<I: BufRead>(mut input: I, n: usize) -> (usize, usize) {
    // top_n will store the highest elves we've seen so far. The capacity is
    // n + 1 because each step will add the fourth elf and then remove the
    // smallest
    let mut top_n = Vec::with_capacity(n + 1);

    // The sum of calories for the current elf
    let mut current = 0;

    // Buffer for each individual line of text
    let mut buffer = String::new();
    while let Ok(k) = input.read_line(&mut buffer) {
        if k == 0 {
            // End of input
            break;
        } else if k == 1 {
            // Newline character only: add this elf to the top_n vec and remove
            // the smallest elf.
            top_n.push(current);
            // We can now reset the running total to 0
            current = 0;
            // Sort unstable here (numbers are indistinguishable so order does
            // not matter) and in reverse (descendig) order
            top_n.sort_unstable_by_key(|&k| std::cmp::Reverse(k));
            // Remove all but the top n elements
            top_n.truncate(n);
        } else {
            // Add the value of this line to the current elf
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
