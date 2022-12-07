import os
from collections import defaultdict
from typing import Dict, Tuple, List


def dir_size(all_dirs: Dict[str, Tuple[List[str], int]], dir: str) -> int:
    subdirs, files = all_dirs[dir]
    return files + sum(dir_size(all_dirs, d) for d in subdirs)


def main():
    with open(os.environ["INPUT"], "r") as f:
        contents = f.read()

    # Split into commands
    commands = contents.split("$ ")

    # Directories seen so far
    dirs = defaultdict(lambda: [[], 0])

    # Where are we currently
    pwd = ["/"]

    for command in commands:
        # Ignore any blank strings
        if not command:
            continue

        # Split into command + response
        lines = command.splitlines()
        # Parse command
        c = lines[0]
        c_parts = c.split()
        if c_parts[0] == "cd":
            if c_parts[1] == "..":
                # Go up one
                pwd.pop()
            elif c_parts[1] == "/":
                # Reset to root
                pwd = ["/"]
            else:
                # Go down one
                pwd.append(c_parts[1])
        elif c_parts[0] == "ls":
            this_path = ";".join(pwd)
            for sub in lines[1:]:
                sub_parts = sub.split()
                if sub_parts[0] == "dir":
                    pwd.append(sub_parts[1])
                    sub_path = ";".join(pwd)
                    pwd.pop()
                    dirs[this_path][0].append(sub_path)
                else:
                    dirs[this_path][1] += int(sub_parts[0])

    print("Part 1: ", sum(s for d in dirs if (s := dir_size(dirs, d)) <= 100000))

    total_space = 70000000
    required_space = 30000000
    used_space = dir_size(dirs, "/")
    to_free = required_space - (total_space - used_space)
    print("Part 2: ", min(s for d in dirs if (s := dir_size(dirs, d)) >= to_free))


if __name__ == "__main__":
    main()
