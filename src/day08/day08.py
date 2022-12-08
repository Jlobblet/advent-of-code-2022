import numpy as np
import os
from functools import partial


def n_viewed(this, sub_arr):
    # Find first tree bigger than or equal to this tree
    aw = np.argwhere(this <= sub_arr)
    if aw.size:
        # We found something
        return np.min(aw) + 1
    else:
        # We hit the edge
        return sub_arr.size


def main():
    with open(os.environ["INPUT"], "r") as f:
        contents = f.read().strip().split("\n")

    heights = np.array([[int(c) for c in el.strip()] for el in contents])

    # Find the number of trees visible from outside the grid
    # A tree is visible if all the trees before it in a given direction are shorter than it
    # Need to count all four directions

    # 30373
    # 25512
    # 65332
    # 33549
    # 35390

    visible = np.zeros_like(heights, dtype=bool)

    for _ in range(4):
        heights = np.rot90(heights)
        visible = np.rot90(visible)
        for i in range(heights.shape[0]):
            row = np.all(heights[i] > heights[:i], axis=0)
            visible[i] |= row

    print("Part 1: ", np.sum(visible))

    # Part 2

    # For each tree calculate how far it can see in each direction
    max_score = 0

    # Brute force iteration over coordinates
    for i in range(heights.shape[0]):
        for j in range(heights.shape[1]):
            # Height of the treehouse
            this = heights[i, j]
            nv = partial(n_viewed, this)

            score = np.product(
                [
                    nv(s)
                    for s in [
                        # Slices of views from this tree to each edge
                        np.flip(heights[:i, j]),
                        heights[i + 1 :, j],
                        np.flip(heights[i, :j]),
                        heights[i, j + 1 :],
                    ]
                ]
            )

            max_score = max(score, max_score)

    print("Part 2: ", max_score)


if __name__ == "__main__":
    main()
