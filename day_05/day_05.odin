package main

import "core:fmt"
import "core:log"
import "core:testing"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:container/queue"
import aoc ".."

@(test) day_05a_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_05a_process(aoc.load_file_or_fail(t, "day_05/day_05a_input_01.txt")), 35)
    testing.expect_value(t, day_05a_process(aoc.load_file_or_fail(t, "day_05/day_05a_input_02.txt")), 318728750)
}

// @(test) day_05b_test :: proc(t: ^testing.T) {
//     context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
//     testing.expect_value(t, day_05b_process(aoc.load_file_or_fail(t, "day_05/day_05a_input_01.txt")), 30)
//     testing.expect_value(t, day_05b_process(aoc.load_file_or_fail(t, "day_05/day_05a_input_02.txt")), 9997537)
// }

day_05a_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    parts := strings.split(input_string, "\n\n")

    seeds_string := strings.split_multi(parts[0], { ": ", " " })[1:]
    seeds := make([]int, len(seeds_string))
    for _, i in seeds_string {
        seed, parse_ok := strconv.parse_int(seeds_string[i])
        assert(parse_ok)
        seeds[i] = seed
    }
    
    maps = make([][dynamic]Mapping, len(parts) - 1)
    for i := 1; i < len(parts); i += 1 {
        maps[i-1] = part_to_map(parts[i])
    }

    result = max(int)
    for seed in seeds {
        value := seed
        for i := 0; i < len(maps); i += 1 {
            prev := value
            value = calculate_next_value(i, value)
            // log.debugf("[%v] %v -> %v", NAMES[i], prev, value)
        }
        
        if value < result {
            result = value
        }
    }

    return
}

Mapping :: struct {
    destination: int,
    source: int,
    range: int,
}

maps: [][dynamic]Mapping
calculate_next_value :: proc(i: int, value: int) -> int {
    for item in maps[i] {
        if value >= item.source && value <= item.source + item.range {
            return value + item.destination - item.source
        }
    }
    return value
}

part_to_map :: proc(part: string) -> (result: [dynamic]Mapping) {
    lines := strings.split_lines(part)
    for i := 1; i < len(lines); i += 1 {
        append(&result, transmute(Mapping) line_to_numbers(lines[i]))
    }
    return
}

line_to_numbers :: proc(line: string) -> (result: [3]int) {
    numbers_string := strings.split(line, " ")
    for _, i in numbers_string {
        number, parse_ok := strconv.parse_int(numbers_string[i])
        assert(parse_ok)
        result[i] = number
    }
    return
}

NAMES := []string {
    "seed-to-soil",
    "soil-to-fertilizer",
    "fertilizer-to-water",
    "water-to-light",
    "light-to-temperature",
    "temperature-to-humidity",
    "humidity-to-location",
}