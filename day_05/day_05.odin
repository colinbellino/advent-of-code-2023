package main

import "core:container/queue"
import "core:fmt"
import "core:log"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:thread"
import "core:time"
import aoc ".."

// @(test) day_05a_test :: proc(t: ^testing.T) {
//     context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
//     testing.expect_value(t, day_05a_process(aoc.load_file_or_fail(t, "day_05/day_05a_input_01.txt")), 35)
//     testing.expect_value(t, day_05a_process(aoc.load_file_or_fail(t, "day_05/day_05a_input_02.txt")), 318728750)
// }

@(test) day_05b_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_05b_process(aoc.load_file_or_fail(t, "day_05/day_05a_input_01.txt")), 46)
    testing.expect_value(t, day_05b_process(aoc.load_file_or_fail(t, "day_05/day_05a_input_02.txt")), 37384986)
}

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
    
    mappings = make([][dynamic]Mapping, len(parts) - 1)
    for i := 1; i < len(parts); i += 1 {
        mappings[i-1] = part_to_map(parts[i])
    }

    result = max(int)
    for seed in seeds {
        value := seed
        for i := 0; i < len(mappings); i += 1 {
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

threads_result: [dynamic]int
// This is extremely slow because it's brute forcing every seed, i'll have to rework it to be less dumb...
day_05b_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    parts := strings.split(input_string, "\n\n")

    seeds_string := strings.split_multi(parts[0], { ": ", " " })[1:]
    seeds := make([]int, len(seeds_string))
    for _, i in seeds_string {
        seed, parse_ok := strconv.parse_int(seeds_string[i])
        assert(parse_ok)
        seeds[i] = seed
    }
    assert(len(seeds) % 2 == 0, "seeds count must be even.")

    mappings = make([][dynamic]Mapping, len(parts) - 1)
    for i := 1; i < len(parts); i += 1 {
        mappings[i-1] = part_to_map(parts[i])
    }

    worker_proc :: proc(t: ^thread.Thread) {
        seeds := cast(^[]int) t.data
        seed_i := t.user_index * 2
        seed_base := seeds[seed_i]
        seed_range := seeds[seed_i + 1]
        log.debugf("[%v] -> %v | %v", t.user_index, seed_base, seed_range)

        result := max(int)
        for range_i := 0; range_i < seed_range; range_i += 1 {
            value := seed_base + range_i
            for map_i := 0; map_i < len(mappings); map_i += 1 {
                value = calculate_next_value(map_i, value)
            }
            if value < result {
                result = value
            }
        }
        threads_result[t.user_index] = result
    }

    threads := make([dynamic]^thread.Thread, 0, len(seeds) / 2)
    // defer delete(threads)

    for seed, i in seeds {
        if i % 2 == 0 {
            if t := thread.create(worker_proc); t != nil {
                t.init_context = context
                t.user_index = len(threads)
                append(&threads, t)
                append(&threads_result, t.user_index)
                t.data = &seeds
                thread.start(t)
            }
        }
    }

    result = max(int)
    for len(threads) > 0 {
        for i := 0; i < len(threads); /**/ {
            if t := threads[i]; thread.is_done(t) {
                if threads_result[t.user_index] < result {
                    result = threads_result[t.user_index]
                }
                thread.destroy(t)
                ordered_remove(&threads, i)
            } else {
                i += 1
            }
        }
    }

    return
}

Mapping :: struct {
    destination: int,
    source: int,
    range: int,
}

mappings: [][dynamic]Mapping
calculate_next_value :: proc(i: int, value: int) -> int {
    for item in mappings[i] {
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