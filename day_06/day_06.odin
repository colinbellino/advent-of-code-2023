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

@(test) day_06a_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_06a_process(aoc.load_file_or_fail(t, "day_06/day_06a_input_01.txt")), 288)
    testing.expect_value(t, day_06a_process(aoc.load_file_or_fail(t, "day_06/day_06a_input_02.txt")), 608902)
}

@(test) day_06b_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_06b_process(aoc.load_file_or_fail(t, "day_06/day_06a_input_01.txt")), 71503)
    testing.expect_value(t, day_06b_process(aoc.load_file_or_fail(t, "day_06/day_06a_input_02.txt")), 46173809)
}

day_06a_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    lines := strings.split_lines(input_string)
    times := parse_line(lines[0])
    distances := parse_line(lines[1])
    assert(len(times) == len(distances))

    result = 1
    for race_i := 0; race_i < len(times); race_i += 1 {
        race_result := 0
        charge_time := 0
        for time_i := 1; time_i < times[race_i]; time_i += 1 {
            charge_time += 1
            distance := charge_time * (times[race_i] - time_i)
            if distance > distances[race_i] {
                race_result += 1
            }
        }
        result *= race_result
        log.debugf("Race 1 | time: %v, distance: %v, race_result: %v", times[race_i], distances[race_i], race_result)
    }
    
    return
}

day_06b_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    lines := strings.split_lines(input_string)
    race_time := parse_line_b(lines[0])
    race_distance := parse_line_b(lines[1])

    result = 1
    {
        race_result := 0
        charge_time := 0
        for time_i := 1; time_i < race_time; time_i += 1 {
            charge_time += 1
            distance := charge_time * (race_time - time_i)
            if distance > race_distance {
                race_result += 1
            }
        }
        result *= race_result
        log.debugf("Race 1 | time: %v, distance: %v, race_result: %v", race_time, race_distance, race_result)
    }
    
    return
}

parse_line :: proc(line: string) -> [dynamic]int {
    result := [dynamic]int {}
    for part in strings.split_multi(line, { " " }) {
        part_int, parse_ok := strconv.parse_int(part)
        if parse_ok {
            append(&result, part_int)
        }
    }
    return result
}

parse_line_b :: proc(line: string) -> int {
    result := 0
    for part in strings.split_multi(line, { " " }) {
        part_int, parse_ok := strconv.parse_int(part)
        if parse_ok {
            result = concatenate_int(result, part_int)
        }
    }
    return result
}

concatenate_int :: proc(x, y: int) -> int {
    pow := 10
    for y >= pow {
        pow *= 10
    }
    return x * pow + y
}