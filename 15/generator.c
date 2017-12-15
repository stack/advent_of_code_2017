#include <inttypes.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define SHORT_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c"
#define SHORT_TO_BINARY(byte)   \
    (byte & 0x8000 ? '1' : '0'), \
    (byte & 0x4000 ? '1' : '0'), \
    (byte & 0x2000 ? '1' : '0'), \
    (byte & 0x1000 ? '1' : '0'), \
    (byte & 0x0800 ? '1' : '0'), \
    (byte & 0x0400 ? '1' : '0'), \
    (byte & 0x0200 ? '1' : '0'), \
    (byte & 0x0100 ? '1' : '0'), \
    (byte & 0x0080 ? '1' : '0'), \
    (byte & 0x0040 ? '1' : '0'), \
    (byte & 0x0020 ? '1' : '0'), \
    (byte & 0x0010 ? '1' : '0'), \
    (byte & 0x0008 ? '1' : '0'), \
    (byte & 0x0004 ? '1' : '0'), \
    (byte & 0x0002 ? '1' : '0'), \
    (byte & 0x0001 ? '1' : '0')

#define GENERATOR_A_FACTOR 16807
#define GENERATOR_A_START_VALUE_EXAMPLE 65
#define GENERATOR_A_START_VALUE_INPUT 634

#define GENERATOR_B_FACTOR 48271
#define GENERATOR_B_START_VALUE_EXAMPLE 8921
#define GENERATOR_B_START_VALUE_INPUT 301

#define PART_1_RUNS 40000000
#define PART_2_RUNS 5000000

#define MAGIC_DIVISOR 2147483647

typedef struct _Generator {
    uint64_t startValue;
    uint64_t previousValue;
    uint64_t factor;
    uint64_t multiple;
} Generator;

typedef struct _Generator * GeneratorRef;

typedef struct _Judge {
    GeneratorRef *generators;
    size_t numberOfGenerators;
} Judge;

typedef struct _Judge * JudgeRef;

static GeneratorRef GeneratorCreate(uint64_t startValue, uint64_t factor, uint64_t multiple);
static void GeneratorDestroy(GeneratorRef self);
static uint64_t GeneratorNextValue(GeneratorRef self);
static void GeneratorReset(GeneratorRef self);

static JudgeRef JudgeCreate(size_t numberOfGenerators, ...);
static void JudgeDestroy(JudgeRef self);
static void JudgeReset(JudgeRef self);
static uint64_t JudgeRun(JudgeRef self, uint64_t times);


int main(int argc, char **argv) {
    // Example mode or input mode
    bool exampleMode = false;
    if (argc > 1) {
        // Who cares, just take anything to mean example mode
        exampleMode = true;
    }

    uint64_t startValueA;
    uint64_t startValueB;

    if (exampleMode) {
        printf("Running in example mode\n\n");

        startValueA = GENERATOR_A_START_VALUE_EXAMPLE;
        startValueB = GENERATOR_B_START_VALUE_EXAMPLE;
    } else {
        printf("Running in input mode\n\n");

        startValueA = GENERATOR_A_START_VALUE_INPUT;
        startValueB = GENERATOR_B_START_VALUE_INPUT;
    }

    /*** Part 1 ***/

    // Build the generators
    GeneratorRef generatorA = GeneratorCreate(startValueA, GENERATOR_A_FACTOR, 1);
    GeneratorRef generatorB = GeneratorCreate(startValueB, GENERATOR_B_FACTOR, 1);

    // Test the generators
    printf("--Gen. A--  --Gen. B--\n");
    for (int idx = 0; idx < 5; idx++) {
        uint64_t valueA = GeneratorNextValue(generatorA);
        uint64_t valueB = GeneratorNextValue(generatorB);

        printf("%10" PRIu64 "  %10" PRIu64 "\n", valueA, valueB);
    }

    printf("\n");

    // Run the judge
    JudgeRef judge = JudgeCreate(2, generatorA, generatorB);
    uint64_t count = JudgeRun(judge, PART_1_RUNS);

    printf("Count: %" PRIu64 "\n\n", count);

    // Clean up
    JudgeDestroy(judge);
    GeneratorDestroy(generatorA);
    GeneratorDestroy(generatorB);

    // Build the generators
    generatorA = GeneratorCreate(startValueA, GENERATOR_A_FACTOR, 4);
    generatorB = GeneratorCreate(startValueB, GENERATOR_B_FACTOR, 8);

    // Test the generators
    printf("--Gen. A--  --Gen. B--\n");
    for (int idx = 0; idx < 5; idx++) {
        uint64_t valueA = GeneratorNextValue(generatorA);
        uint64_t valueB = GeneratorNextValue(generatorB);

        printf("%10" PRIu64 "  %10" PRIu64 "\n", valueA, valueB);
    }

    printf("\n");

    // Run the judge
    judge = JudgeCreate(2, generatorA, generatorB);
    count = JudgeRun(judge, PART_2_RUNS);

    printf("Count: %" PRIu64 "\n", count);

    // Clean up
    JudgeDestroy(judge);
    GeneratorDestroy(generatorA);
    GeneratorDestroy(generatorB);

    /*** Part 2 ***/

    return EXIT_SUCCESS;
}

static GeneratorRef GeneratorCreate(uint64_t startValue, uint64_t factor, uint64_t multiple) {
    GeneratorRef self = (GeneratorRef)calloc(1, sizeof(Generator));

    self->startValue = startValue;
    self->factor = factor;
    self->multiple = multiple;

    GeneratorReset(self);

    return self;
}

static void GeneratorDestroy(GeneratorRef self) {
    free(self);
}

static uint64_t GeneratorNextValue(GeneratorRef self) {
    uint64_t value = 0;

    do {
        value = (self->previousValue * self->factor) % 2147483647;
        self->previousValue = value;
    } while (value % self->multiple != 0);

    return value;
}

static void GeneratorReset(GeneratorRef self) {
    self->previousValue = self->startValue;
}

static JudgeRef JudgeCreate(size_t numberOfGenerators, ...) {
    JudgeRef self = (JudgeRef)calloc(1, sizeof(Judge));

    self->numberOfGenerators = numberOfGenerators;
    self->generators = (GeneratorRef *)calloc(self->numberOfGenerators, sizeof(GeneratorRef));

    va_list args;
    va_start(args, numberOfGenerators);

    for (int idx = 0; idx < numberOfGenerators; idx++) {
        self->generators[idx] = va_arg(args, GeneratorRef);
    }

    va_end(args);

    JudgeReset(self);

    return self;
}

static void JudgeDestroy(JudgeRef self) {
    if (self->generators != NULL) {
        GeneratorRef *temp = self->generators;
        self->generators = NULL;

        free(temp);
    }

    free(self);
}

static void JudgeReset(JudgeRef self) {
    for (int idx = 0; idx < self->numberOfGenerators; idx++) {
        GeneratorReset(self->generators[idx]);
    }
}

static uint64_t JudgeRun(JudgeRef self, uint64_t times) {
    uint64_t count = 0;
    uint16_t *values = (uint16_t *)calloc(self->numberOfGenerators, sizeof(uint16_t));

    for (uint64_t t = 0; t < times; t++) {
        // Generate the values for this iteration
        for (int idx = 0; idx < self->numberOfGenerators; idx++) {
            values[idx] = 0x0000ffff & GeneratorNextValue(self->generators[idx]);
        }

        // Dump for debug
        // for (int idx = 0; idx < self->numberOfGenerators; idx++) {
        //     printf(SHORT_TO_BINARY_PATTERN "\n", SHORT_TO_BINARY(values[idx]));
        // }

        // printf("\n");

        // Check for complete equality
        bool equals = true;
        for (int idx = 1; idx < self->numberOfGenerators; idx++) {
            if (values[idx - 1] != values[idx]) {
                equals = false;
                break;
            }
        }

        // Increment on a match
        if (equals) {
            count += 1;
        }
    }

    return count;
}