package main

import "core:fmt"
import "core:log"
import "core:testing"
import "core:strings"
import "core:strconv"
import "core:slice"
import aoc ".."

@(test) day_04a_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_04a_process(aoc.load_file_or_fail(t, "day_04/day_04a_input_01.txt")), 13)
    testing.expect_value(t, day_04a_process(aoc.load_file_or_fail(t, "day_04/day_04a_input_02.txt")), 26218)
}

// @(test) day_04b_test :: proc(t: ^testing.T) {
//     context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
//     testing.expect_value(t, day_04b_process(aoc.load_file_or_fail(t, "day_04/day_04b_input_01.txt")), 467835)
//     testing.expect_value(t, day_04b_process(aoc.load_file_or_fail(t, "day_04/day_04a_input_02.txt")), 80179647)
// }

day_04a_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    for line in strings.split_lines(input_string) {
        line_result := 0

        card_parts := strings.split_multi(line, { ":", "|" })
        winning_numbers := [dynamic]int {}
        for winning_number in strings.split(card_parts[1], " ") {
            winning_number_int, parse_ok := strconv.parse_int(winning_number)
            if parse_ok {
                append(&winning_numbers, winning_number_int)
            }
        }

        elf_numbers := [dynamic]int {}
        for elf_number in strings.split(card_parts[2], " ") {
            elf_number_int, parse_ok := strconv.parse_int(elf_number)
            if parse_ok {
                if slice.contains(winning_numbers[:], elf_number_int) {
                    if line_result == 0 {
                        line_result = 1
                    } else {
                        line_result *= 2
                    }
                }
            }
        }

        result += line_result
    }

    return 
}

day_04b_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    return 
}