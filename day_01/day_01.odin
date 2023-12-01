package main

import "core:fmt"
import "core:log"
import "core:testing"
import "core:strings"
import "core:strconv"

DIGIT_NAMES: [10]string = {
    "one",
    "two",
    "six",
    "zero",
    "four",
    "five",
    "nine",
    "three",
    "seven",
    "eight",
}
DIGIT_NUMBERS: [10]int = {
    1,
    2,
    6,
    0,
    4,
    5,
    9,
    3,
    7,
    8,
}

@(test)
day_01a_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })

    {
        input := load_file_or_fail(t, "day_01/day_01a_input_01.txt")
        testing.expect_value(t, day_01a_process(input), 142)
    }
    {
        input := load_file_or_fail(t, "day_01/day_01a_input_02.txt")
        testing.expect_value(t, day_01a_process(input), 55607)
    }
}

// I did not manage to make the part B of this work by myself so i ended up reusing the one by https://github.com/flysand7/advent-of-code/blob/main/day1/main.odin
// I managed to learn things from it so this day wasn't totally lost ^^
@(test)
day_01b_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })

    {
        input := load_file_or_fail(t, "day_01/day_01b_input_01.txt")
        testing.expect_value(t, day_01b_process(input), 281)
    }
    {
        input := load_file_or_fail(t, "day_01/day_01b_input_02.txt")
        testing.expect_value(t, day_01b_process(input), 55291)
    }
}

day_01a_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    for line in strings.split_lines(input_string) {
        first := -1
        last := -1
        for char in line {
            if '0' <= char && char <= '9' {
                digit := int(char - '0')
                if first == -1 {
                    first = digit
                }
                last = digit
            }
        }
        
        line_result := concatenate_int(first, last)
        result += line_result
        // log.debugf("line: %v -> %v -> (%v + %v) -> %v", line, first, last, line_result)
    }
    
    return
}

day_01b_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)
    
    for line in strings.split_lines(input_string) {
        line_result := concatenate_int(first_digit(line), last_digit(line))
        result += line_result
        // log.debugf("line: %v -> %v", line, line_result)
    }
    
    return
}

has_prefix_fast :: proc(s, prefix: string) -> (result: bool) #no_bounds_check {
    return s[0:len(prefix)] == prefix
}

first_digit :: proc(data: string) -> (result: int) {
    main: for line in strings.split_lines(data) {
        for i := 0; i < len(line); i += 1 {
            if '0' <= line[i] && line[i] <= '9' {
                result += int(line[i] - '0')
                continue main
            } else {
                str := line[i:]
                max_index := 10
                if len(str) < 3 {
                    continue
                } else if len(str) == 3 {
                    max_index = 3
                } else if len(str) < 4 {
                    max_index = 7
                }
                for name, index in DIGIT_NAMES[:max_index] {
                    if has_prefix_fast(str, name) {
                        result += DIGIT_NUMBERS[index]
                        continue main
                    }
                }
            }
        }
    }
    return
}

last_digit :: proc(data: string) -> (result: int) {
    main: for line in strings.split_lines(data) {
        for i := len(line) - 1; i >= 0; i -= 1 {
            if '0' <= line[i] && line[i] <= '9' {
                result += int(line[i] - '0')
                continue main
            } else {
                str := line[i:]
                max_index := 10
                if len(str) < 3 {
                    continue
                } else if len(str) == 3 {
                    max_index = 3
                } else if len(str) < 4 {
                    max_index = 7
                }
                for name, index in DIGIT_NAMES[:max_index] {
                    if has_prefix_fast(str, name) {
                        result += DIGIT_NUMBERS[index]
                        continue main
                    }
                }
            }
        }
    }
    return
}

concatenate_int :: proc(x, y: int) -> int {
    pow := 10
    for y >= pow {
        pow *= 10
    }
    return x * pow + y
}