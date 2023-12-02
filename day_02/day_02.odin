package main

import "core:fmt"
import "core:log"
import "core:testing"
import "core:strings"
import "core:strconv"
import aoc ".."

// only 12 red cubes, 13 green cubes, and 14 blue cubes
CUBES_RED   :: 12
CUBES_GREEN :: 13
CUBES_BLUE  :: 14

CUBE_KEYS := [3]rune { 'r', 'g', 'b' }
CUBE_MAX  := [3]int  { 12,  13,  14 }

@(test)
day_02a_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })

    {
        input := aoc.load_file_or_fail(t, "day_02/day_02a_input_01.txt")
        testing.expect_value(t, day_02a_process(input), 8)
    }
    {
        input := aoc.load_file_or_fail(t, "day_02/day_02a_input_02.txt")
        testing.expect_value(t, day_02a_process(input), 2285)
    }
}

@(test)
day_02b_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })

    {
        input := aoc.load_file_or_fail(t, "day_02/day_02b_input_01.txt")
        testing.expect_value(t, day_02b_process(input), 2286)
    }
    {
        input := aoc.load_file_or_fail(t, "day_02/day_02a_input_02.txt")
        testing.expect_value(t, day_02b_process(input), 77021)
    }
}

day_02a_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    game: for line, i in strings.split_lines(input_string) {
        game_is_valid := true

        parts := strings.split(line, ":")
        for set_str, set_id in strings.split(parts[1], ";") {
            set_cubes := [3]int {}
            for score_str in strings.split(set_str, ",") {
                parts := strings.split(strings.trim(score_str, " "), " ")
                key := rune(parts[1][0])
                value := parts[0]
                for cube_key, cube_index in CUBE_KEYS {
                    if key == cube_key {
                        value, value_ok := strconv.parse_int(value)
                        set_cubes[cube_index] += value
                        if set_cubes[cube_index] > CUBE_MAX[cube_index] {
                            continue game
                        }
                        break
                    }
                }
            }
        }

        result += i + 1
    }
    return 
}

day_02b_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    game: for line, i in strings.split_lines(input_string) {
        game_is_valid := true

        parts := strings.split(line, ":")
        game_cubes := [3]int {}
        for set_str, set_id in strings.split(parts[1], ";") {
            set_cubes := [3]int {}
            for score_str in strings.split(set_str, ",") {
                parts := strings.split(strings.trim(score_str, " "), " ")
                key := rune(parts[1][0])
                value := parts[0]
                for cube_key, cube_index in CUBE_KEYS {
                    if key == cube_key {
                        value, value_ok := strconv.parse_int(value)
                        set_cubes[cube_index] += value
                        if set_cubes[cube_index] > game_cubes[cube_index] {
                            game_cubes[cube_index] = set_cubes[cube_index]
                        }
                        break
                    }
                }
            }
        }

        power := 1
        for value in game_cubes {
            power *= value
        }

        result += power
    }
    return 
}