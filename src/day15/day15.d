module day15d.day15;

import std.algorithm;
import std.conv;
import std.file;
import std.math;
import std.parallelism;
import std.process;
import std.stdio;
import std.typecons;
import std.range;
import std.regex;

// Any number after an =
auto numRegex = ctRegex!`(?<==)-?\d+`;

struct Polong {
    long x, y;

    long opCmp(R)(const R other) const
    {
        if (x < other.x) {
            return -1;
        } else if (x > other.x) {
            return 1;
        } else {
            if (y < other.y) {
                return -1;
            } else if (y > other.y) {
                return 1;
            } else {
                return 0;
            }
        }
    }

    auto opBinary(string op, R)(const R rhs) const
        if (op == "+")
    {
        return Polong(x + rhs.x, y + rhs.y);
    }
}

Polong toPolong(long[] arr) {
    return Polong(arr[0], arr[1]);
}

long manhattanDistance(Polong a, Polong b) {
    return (a.x - b.x).abs + (a.y - b.y).abs;
}

struct Range {
    Polong lower, upper;

    long opCmp(R)(const R other) const
    {
        long c;
        if ((c = lower.opCmp(other.lower)) != 0) {
            return c;
        } else {
            return upper.opCmp(other.upper);
        }
    }
}

Nullable!Range toRange(Polong[] arr, long targetY) {
    // Calculate manhattan distance, vertical distance, and width of this section
    long md = arr[0].manhattanDistance(arr[1]),
        vd = (targetY - arr[0].y).abs,
        width = md - vd;

    // If the width is negative there are no coordinates ruled out by this pair of polongs
    if (width >= 0) {
        // Starts at sensor - width, ends at sensor + width
        // y is constant target y
        return Range(Polong(arr[0].x - width, targetY), Polong(arr[0].x + width, targetY)).nullable;
    } else {
        return Nullable!Range.init;
    }
}

long size(Range r) {
    return r.upper.x - r.lower.x + 1;
}

Range[] ruledOutOnY(Polong[][] polongs, long targetY) {
    // Convert polongs to ranges
    auto ranges = polongs
        .map!(a => a.toRange(targetY))
        .filter!"!a.isNull"
        .map!"a.get"
        .array;

    // Sort, combine overlapping ranges, then count number of coordinates ruled out
    ranges.sort;

    Range[] folder(Range[] acc, Range elt) {
        if (acc.length && acc[$-1].upper >= elt.lower) {
            acc[$-1].upper.x = acc[$-1].upper.x.max(elt.upper.x);
        } else {
            acc ~= elt;
        }
        return acc;
    }

    return ranges.fold!(folder)(new Range[0]).array;
}

Range[] clamp(Range[] ranges, long lowerX, long upperX) {
    // Remove any out of bounds ranges
    auto ret = ranges.filter!(a => a.upper.x >= lowerX && a.lower.x <= upperX).array;
    // Clamp the first and last range
    ret[0].lower.x = ret[0].lower.x.max(lowerX);
    ret[$-1].upper.x = ret[$-1].upper.x.min(upperX);
    return ret;
}

void main() {
    auto targetY = environment.get("TARGET_Y", "2000000").to!long;
    auto input = environment.get("INPUT").readText;

    // Parse polongs
    auto polongs = input
        .matchAll(numRegex)
        .map!"a.hit.to!long"
        .chunks(2)
        .map!(a => a.array.toPolong)
        .chunks(2)
        .map!(a => a.array)
        .array;

    // Extract beacons
    auto beacons = polongs
        .map!(a => a[1])
        .array;

    // Find number of beacons on target y
    beacons.sort;
    auto nBeacons = beacons.uniq.count!(a => a.y == targetY);

    // Convert polongs to ranges
    auto ranges = polongs
        .map!(a => a.toRange(targetY))
        .filter!"!a.isNull"
        .map!"a.get"
        .array;

    // Sort, combine overlapping ranges, then count number of coordinates ruled out
    ranges.sort;

    // Don't forget to subtract number of beacons on this y level
    (polongs.ruledOutOnY(targetY).map!size.sum - nBeacons).writeln;

    long upperBound = targetY * 2;
    foreach (y; (upperBound + 1).iota.parallel) {
        auto rs    = polongs.ruledOutOnY(y).clamp(0, upperBound).array;
        auto total = rs.map!size.sum;
        // If the total is missing one, then we've found it
        if (total != upperBound) { continue; }
        long x;
        if (rs.length > 1) {
            // Enumerate ranges to find the missing element
            foreach (a, b; rs.zip(rs.dropOne)) {
                if (a.upper.x + 1 == b.lower.x) { continue; }
                x = a.upper.x + 1;
                break;
            }
        } else {
            // Figure out if it's the first or last missing
            x = rs[0].lower.x == 0 ? 0 : upperBound;
        }
        (x * 4_000_000 + y).writeln;
    }
}
