#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

int
main(int argc, char **argv) {
    if (argc < 2) {
        fputs("No file name to read", stderr);
        goto err;
    }

    // Generate value of letters
    int values[255] = {0};
    int i;
    for (i = 'a'; i <= 'z'; i++) {
        values[i] = i - 'a' + 1;
    }
    for (i = 'A'; i <= 'Z'; i++) {
        values[i] = i - 'A' + 1 + 26;
    }

    // Open file
    FILE *f = NULL;
    f = fopen(argv[1], "r");

    // Sum for part a and b so far
    int a_sum = 0, b_sum = 0;
    // Counts of letters in a and b
    int a_counts_1[255] = {0}, a_counts_2[255] = {0}, b_flags[255] = {0};
    // To keep track of windows
    int k = 0;

    // Read in each line
    char *line = NULL;
    size_t len = 0;
    ssize_t read;

    while (-1 != (read = getline(&line, &len, f))) {
        // Reset a counts to 0
        memset(a_counts_1, 0, 255 * sizeof(int));
        memset(a_counts_2, 0, 255 * sizeof(int));
        if (!k) {
            memset(b_flags, 0, 255 * sizeof(int));
        }

        // Count letters in first half
        for (i = 0; i < read / 2; i++) {
            a_counts_1[line[i]]++;
            b_flags[line[i]] |= 1 << k;
        }
        // Count letters in second half
        for (; i < read - 1; i++) {
            a_counts_2[line[i]]++;
            b_flags[line[i]] |= 1 << k;
        }

        // If a letter is in both, add its value to a_sum
        for (i = 0; i < 255; i++) {
            if (a_counts_1[i] && a_counts_2[i]) {
                a_sum += values[i];
            }
        }

        // Increment k, mod 3
        k = (k + 1) % 3;
        if (k) continue;
        // If a letter is in all three rucksacks, add its value to b_sum
        for (i = 0; i < 255; i++) {
            if (b_flags[i] == 0b111) {
                b_sum += values[i];
            }
        }
    }

    printf("%i %i\n", a_sum, b_sum);

    fclose(f);
    free(line);

    return EXIT_SUCCESS;

    err:
    fclose(f);
    free(line);
    return EXIT_FAILURE;
}