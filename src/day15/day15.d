module day15d.day15;

import std.algorithm;
import std.conv;
import std.file;
import std.math;
import std.process;
import std.stdio;
import std.typecons;
import std.range;
import std.regex;

// Any number after an =
auto numRegex = ctRegex!`(?<==)-?\d+`;

struct Point {
    int x, y;

    int opCmp(R)(const R other) const
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
}

Point toPoint(int[] arr) {
    return Point(arr[0], arr[1]);
}

int manhattanDistance(Point a, Point b) {
    return (a.x - b.x).abs + (a.y - b.y).abs;
}

struct Range {
    Point lower, upper;

    int opCmp(R)(const R other) const
    {
        int c;
        if ((c = lower.opCmp(other.lower)) != 0) {
            return c;
        } else {
            return upper.opCmp(other.upper);
        }
    }
}

Nullable!Range toRange(Point[] arr, int targetY) {
    // Calculate manhattan distance, vertical distance, and width of this section
    int md = arr[0].manhattanDistance(arr[1]),
        vd = (targetY - arr[0].y).abs,
        width = md - vd;

    // If the width is negative there are no coordinates ruled out by this pair of points
    if (width >= 0) {
        // Starts at sensor - width, ends at sensor + width
        // y is constant target y
        return Range(Point(arr[0].x - width, targetY), Point(arr[0].x + width, targetY)).nullable;
    } else {
        return Nullable!Range.init;
    }
}

int size(Range r) {
    return r.upper.x - r.lower.x + 1;
}

void main() {
    auto targetY = environment.get("TARGET_Y", "2000000").to!int;
    auto input = environment.get("INPUT").readText;

    // Parse points
    auto points = input
        .matchAll(numRegex)
        .map!"a.hit.to!int"
        .chunks(2)
        .map!(a => a.array.toPoint)
        .chunks(2)
        .map!(a => a.array)
        .array;

    // Extract beacons
    auto beacons = points
        .map!(a => a[1])
        .array;

    // Find number of beacons on target y
    beacons.sort;
    auto nBeacons = beacons.uniq.count!(a => a.y == targetY);

    // Convert points to ranges
    auto ranges = points
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

    // Don't forget to subtract number of beacons on this y level
    (ranges.fold!(folder)(new Range[0]).map!size.sum - nBeacons).writeln;
}
