#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <memory.h>

enum MonkeyType {
    CON,
    ADD,
    SUB,
    MUL,
    DIV,
};

struct Monkey {
    enum MonkeyType type;
    int64_t val1;
    int64_t val2;
};

// name + colon + space + name + space + op + space + name + lf + nul
//    4 +     1 +     1 +    4 +     1 +  1 +     1 +    4 +  1 +   1
static const uint64_t MAX_LINE_LENGTH = 19;
static const uint64_t MAX_MONKEYS = 456976;  // ⁿ4 26
static const uint64_t ROOT = 308639;  // /(+×26) -@a "root"
static const uint64_t HUMN = 136877;  // /(+×26) -@a "humn"

uint32_t read_name(char **input_stream) {
    uint32_t name = 0;
    name *= 26;
    name += **input_stream - 'a';
    (*input_stream)++;
    name *= 26;
    name += **input_stream - 'a';
    (*input_stream)++;
    name *= 26;
    name += **input_stream - 'a';
    (*input_stream)++;
    name *= 26;
    name += **input_stream - 'a';
    (*input_stream)++;
    return name;
}

void read_monkey(char *input_stream, struct Monkey *monkeys) {
    while (isspace(*input_stream)) input_stream++;
    if (input_stream[0] == '\0') {
        return;
    }

    struct Monkey monkey;

    // Read the monkey name (as a number)
    uint32_t name = read_name(&input_stream);
    // Skip the colon and space
    input_stream += 2;
    // Test the next character to see if it is a digit
    if (isdigit(*input_stream)) {
        monkey.type = CON;
    } else {
        char c = input_stream[5];
        if (c == '+') {
            monkey.type = ADD;
        } else if (c == '-') {
            monkey.type = SUB;
        } else if (c == '*') {
            monkey.type = MUL;
        } else if (c == '/') {
            monkey.type = DIV;
        } else {
            fputs("Unknown monkey type", stderr);
            abort();
        }
    }

    if (monkey.type == CON) {
        // If the monkey is a constant monkey, read in the number
        char *endptr;
        monkey.val1 = (uint32_t)strtoul(input_stream, &endptr, 10);
        monkey.val2 = -1;
        input_stream = endptr;
    } else {
        // Read in the two names - we already have the type
        monkey.val1 = read_name(&input_stream);
        input_stream += 3;
        monkey.val2 = read_name(&input_stream);
    }
    // Skip whitespace
    while (isspace(*input_stream)) input_stream++;

    // Insert monkey into the monkey state array
    monkeys[name] = monkey;
}

void evaluate(uint32_t name, struct Monkey *monkeys) {
    if (monkeys[name].type == CON) {
        return;
    }
    evaluate(monkeys[name].val1, monkeys);
    evaluate(monkeys[name].val2, monkeys);
    if (monkeys[name].type == ADD) {
        monkeys[name].val1 = monkeys[monkeys[name].val1].val1 + monkeys[monkeys[name].val2].val1;
    } else if (monkeys[name].type == SUB) {
        monkeys[name].val1 = monkeys[monkeys[name].val1].val1 - monkeys[monkeys[name].val2].val1;
    } else if (monkeys[name].type == MUL) {
        monkeys[name].val1 = monkeys[monkeys[name].val1].val1 * monkeys[monkeys[name].val2].val1;
    } else if (monkeys[name].type == DIV) {
        monkeys[name].val1 = monkeys[monkeys[name].val1].val1 / monkeys[monkeys[name].val2].val1;
    }
    monkeys[name].type = CON;
}

bool search(uint32_t current, uint32_t target, uint32_t depth, uint32_t *trace, struct Monkey *monkeys) {
    if (current == target) {
        trace[depth] = current;
        return true;
    }

    if (monkeys[current].type == CON) {
        return false;
    }

    if (search(monkeys[current].val1, target, depth + 1, trace, monkeys)) {
        trace[depth] = current;
        return true;
    }

    if (search(monkeys[current].val2, target, depth + 1, trace, monkeys)) {
        trace[depth] = current;
        return true;
    }

    return false;
}

int64_t solve(uint32_t current, int64_t target_value, uint32_t depth, uint32_t *trace, struct Monkey *monkeys) {
    // If we've reached the end of the trace, we're done
    if (monkeys[current].type == CON) {
        return target_value;
    }

    // Evaluate the other side of the tree
    int64_t other_half;
    bool is_val1 = monkeys[current].val1 == trace[depth];
    if (is_val1) {
        evaluate(monkeys[current].val2, monkeys);
        other_half = monkeys[monkeys[current].val2].val1;
    } else {
        evaluate(monkeys[current].val1, monkeys);
        other_half = monkeys[monkeys[current].val1].val1;
    }

    // Determine what this node's value should be
    // target_value = val1 op val2
    int64_t new_target_value;
    if (monkeys[current].type == ADD) {
        new_target_value = target_value - other_half;
    } else if (monkeys[current].type == SUB) {
        if (is_val1) {
            new_target_value = target_value + other_half;
        } else {
            new_target_value = other_half - target_value;
        }
    } else if (monkeys[current].type == MUL) {
        new_target_value = target_value / other_half;
    } else if (monkeys[current].type == DIV) {
        if (is_val1) {
            new_target_value = target_value * other_half;
        } else {
            new_target_value = other_half / target_value;
        }
    } else {
        abort();
    }

    // Recurse
    return solve(trace[depth], new_target_value, depth + 1, trace, monkeys);
}

int64_t solve_root(uint32_t *trace, struct Monkey *monkeys) {
    // Evaluate the other side of the tree
    int64_t target_value;
    if (monkeys[ROOT].val1 == trace[1]) {
        evaluate(monkeys[ROOT].val2, monkeys);
        target_value = monkeys[monkeys[ROOT].val2].val1;
    } else {
        evaluate(monkeys[ROOT].val1, monkeys);
        target_value = monkeys[monkeys[ROOT].val1].val1;
    }

    return solve(trace[1], target_value, 2, trace, monkeys);
}

int main(int argc, char **argv) {
    if (argc != 2) { return EXIT_FAILURE; }

    clock_t start = clock();

    struct Monkey *monkeys = calloc(sizeof(struct Monkey), MAX_MONKEYS);
    uint32_t n_monkeys = 0;
    FILE *fp = fopen(argv[1], "r");
    char line[MAX_LINE_LENGTH];
    while (fgets(line, MAX_LINE_LENGTH, fp) != NULL) {
        read_monkey(line, monkeys);
        memset(line, '\0', MAX_LINE_LENGTH);
        n_monkeys++;
    }
    fclose(fp);
    struct Monkey *monkeys2 = calloc(sizeof(struct Monkey), MAX_MONKEYS);
    memcpy(monkeys2, monkeys, sizeof(struct Monkey) * MAX_MONKEYS);

    evaluate(ROOT, monkeys);
    printf("%lu\n", monkeys[ROOT].val1);

    uint32_t max_depth = n_monkeys / 2 + 1;
    uint32_t *trace = calloc(sizeof(uint32_t), max_depth);
    for (uint32_t i = 0; i < max_depth; i++) {
        trace[i] = -1;
    }
    search(ROOT, HUMN, 0, trace, monkeys2);
    int64_t result = solve_root(trace, monkeys2);
    printf("%lu\n", result);
    clock_t end = clock();
    printf("Time: %f\n", (double)(end - start) / CLOCKS_PER_SEC);
    free(trace);
    free(monkeys);
    free(monkeys2);
    return EXIT_SUCCESS;
}
