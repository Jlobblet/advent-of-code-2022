#define _GNU_SOURCE
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <ftw.h>
#include <libgen.h>

#define ERR_CHECK do { if (errno != 0) { printf("%s\n", strerror(errno)); abort(); } } while (false)

void
mkdir_safe(const char *filepath) {
    struct stat s = { 0 };
    if (-1 == stat(filepath, &s)) {
        if (-1 == mkdir(filepath, 0777)) {
            printf("Failed to create directory %s\n", filepath);
            abort();
        }
        errno = 0;
    }
}

static off_t sizes[UINT16_MAX] = {0};

int
compar(const void *a, const void *b) {
    off_t l = *(off_t *)a;
    off_t r = *(off_t *)b;

    if (l < r) {
        return 1;
    } else if (l > r) {
        return -1;
    } else {
        return 0;
    }
}

int
walk(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf) {
    if (typeflag == FTW_F) {
        // Find parent directory name
        const char *start = fpath, *current = fpath;
        for (; *current; current++);
        bool seen_slash = false;
        while (current > fpath) {
            if (*current == '/') {
                if (seen_slash) {
                    start = current + 1;
                    break;
                } else {
                    seen_slash = true;
                }
            }
            current--;
        }

        uint16_t n = (uint16_t)strtoul(start, NULL, 10);
        sizes[n] += sb->st_size;
    }
    return 0;
}

int
main(int argc, char *argv) {
    char *buf = NULL;
    size_t cap;
    ssize_t len;
    uintptr_t n = 0, k = 0;
    char filepath[128] = {0};
    sprintf(&filepath, "elves/%lu/", n);
    mkdir_safe("elves");
    mkdir_safe(filepath);

    while (true) {
        len = getline(&buf, &cap, stdin);
        if (-1 == len) {
            break;
        } else if (0 == len) {
            break;
        } else if (len == 1) {
            // We have a newline only
            n++;
            sprintf(&filepath, "elves/%lu/", n);
            mkdir_safe(filepath);
            ERR_CHECK;
            k = 0;
            continue;
        }

        unsigned long bytes = strtoul(buf, NULL, 10);
        ERR_CHECK;

        sprintf(&filepath, "elves/%lu/%lu", n, k);

        FILE *f = fopen(filepath, "w");
        ERR_CHECK;
        for (int i = 0; i < bytes; i++) {
            putc(0, f);
        }
        fclose(f);

        k++;
    }

    ftw("elves", &walk, 1);
    qsort(sizes, UINT16_MAX, sizeof(off_t), &compar);

    printf("%lu\n", sizes[0]);
    printf("%lu\n", sizes[0] + sizes[1] + sizes[2]);

    return EXIT_SUCCESS;
}
