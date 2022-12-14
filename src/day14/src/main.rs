use anyhow::{anyhow, Context, Error, Result};
use itertools::Itertools;
use num::signum;
use std::collections::hash_map;
use std::env::var;
use std::fs::File;
use std::io::{BufRead, BufReader};

type Map<K, V> = hash_map::HashMap<K, V>;
type Entry<'a, K, V> = hash_map::Entry<'a, K, V>;

#[derive(Debug, Copy, Clone, Hash, Eq, PartialEq, Ord, PartialOrd)]
struct Point {
    x: isize,
    y: isize,
}

impl Point {
    #[inline]
    pub fn new(x: isize, y: isize) -> Self {
        Self { x, y }
    }

    #[inline]
    pub fn down(self) -> Self {
        Self::new(self.x, self.y + 1)
    }

    #[inline]
    pub fn down_left(self) -> Self {
        Self::new(self.x - 1, self.y + 1)
    }

    #[inline]
    pub fn down_right(self) -> Self {
        Self::new(self.x + 1, self.y + 1)
    }

    pub fn to(mut self, other: Point) -> Vec<Point> {
        let dx = signum(other.x - self.x);
        let dy = signum(other.y - self.y);
        if dx != 0 && dy != 0 {
            panic!()
        }
        let mut result = vec![self];
        while self != other {
            self.x += dx;
            self.y += dy;
            result.push(self);
        }
        result
    }
}

impl std::str::FromStr for Point {
    type Err = Error;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (l, r) = s
            .split_once(',')
            .with_context(|| anyhow!("Should have a comma-delimited pair; got {}", s))?;
        let l = l
            .parse()
            .with_context(|| anyhow!("Could not parse {} as isize", l))?;
        let r = r
            .parse()
            .with_context(|| anyhow!("Could not parse {} as isize", r))?;
        Ok(Self::new(l, r))
    }
}

#[derive(Debug, Copy, Clone, Hash, Eq, PartialEq)]
enum Tile {
    Rock,
    Sand,
}

fn parse_line<S: AsRef<str>>(line: S) -> Result<Vec<Point>> {
    let points: Vec<Point> = line
        .as_ref()
        .split(" -> ")
        .map(|p| p.parse())
        .collect::<Result<_>>()?;
    Ok(points
        .into_iter()
        .tuple_windows()
        .flat_map(|(a, b)| a.to(b))
        .collect())
}

fn drop_sand(points: &mut Map<Point, Tile>, max_y: isize) -> bool {
    let mut current = Point::new(500, 0);
    while current.y < max_y {
        if !points.contains_key(&current.down()) {
            current = current.down();
        } else if !points.contains_key(&current.down_left()) {
            current = current.down_left();
        } else if !points.contains_key(&current.down_right()) {
            current = current.down_right();
        } else if let Entry::Vacant(e) = points.entry(current) {
            e.insert(Tile::Sand);
            return true;
        } else {
            return false;
        }
    }
    false
}

fn main() {
    let file = BufReader::new(
        File::open(var("INPUT").expect("Missing INPUT environment variable"))
            .expect("Should be able to open input file"),
    );
    // Construct points
    let mut ps: Map<Point, Tile> = file
        .lines()
        .map(|l| l.unwrap())
        .filter(|s| !s.is_empty())
        .flat_map(|l| parse_line(l).unwrap())
        .map(|p| (p, Tile::Rock))
        .collect();

    // Find termination point
    let max_y = ps.keys().map(|p| p.y).max().unwrap();

    // Fill until sand falls out the bottom
    loop {
        if !drop_sand(&mut ps, max_y) {
            break;
        }
    }

    println!("{}", ps.iter().filter(|(_, t)| **t == Tile::Sand).count());

    // Purge sand
    // ps.retain(|_, &mut t| t != Tile::Sand);

    // Add floor
    let (min_x, max_x) = ps
        .keys()
        .map(|p| (p.x, p.x))
        .reduce(|(min_acc, max_acc), (x1, x2)| (min_acc.min(x1), max_acc.max(x2)))
        .unwrap();

    let (min_x, max_x) = (min_x - max_y, max_x + max_y);
    let max_y = max_y + 2;
    for p in Point::new(min_x, max_y).to(Point::new(max_x, max_y)) {
        ps.insert(p, Tile::Rock);
    }

    // Fill until sand falls out the bottom
    loop {
        if !drop_sand(&mut ps, max_y) {
            break;
        }
    }

    // for y in 0..=max_y {
    //     for x in min_x..=max_x {
    //         let c = ps
    //             .get(&Point::new(x, y))
    //             .map(|&t| if t == Tile::Rock { '#' } else { 'o' })
    //             .unwrap_or('.');
    //         print!("{}", c);
    //     }
    //     println!();
    // }

    println!("{}", ps.iter().filter(|(_, t)| **t == Tile::Sand).count());
}
