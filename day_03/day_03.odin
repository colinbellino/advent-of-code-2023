package main

import "core:fmt"
import "core:log"
import "core:testing"
import "core:strings"
import "core:strconv"
import "core:slice"
import aoc ".."

@(test)
day_03a_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_03a_process(aoc.load_file_or_fail(t, "day_03/day_03a_input_01.txt")), 4361)
    testing.expect_value(t, day_03a_process(aoc.load_file_or_fail(t, "day_03/day_03a_input_02.txt")), 551094)
}

Vector2i32 :: distinct [2]i32

EIGHT_DIRECTIONS :: []Vector2i32 {
    { -1, -1 }, { +0, -1 }, { +1, -1 },
    { -1, +0 }, /*       */ { +1, +0 },
    { -1, +1 }, { +0, +1 }, { +1, +1 },
}

day_03a_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    grid_size: Vector2i32
    {
        // This code is assuming our grid is always a square
        for char in strings.split_lines(input_string)[0] {
            grid_size.x += 1
        }
        grid_size.y = grid_size.x
    }

    input_flat, was_alloc := strings.replace_all(input_string, "\n", "")

    x, y: i32
    part_number := 0
    part_is_valid := false
    for char, i in input_flat {
        if is_digit(char) {
            part_number = concatenate_int(part_number, int(char - '0'))
            if is_valid({ x, y }, input_flat, grid_size) {
                part_is_valid = true
            }
        } else {
            if part_is_valid {
                result += part_number
                // log.debugf("part: %v -> \"%v\"", Vector2i32 { x, y }, part_number)
            }
            
            part_is_valid = false
            part_number = 0
        }

        x += 1
        if x >= grid_size.x {
            y += 1
            x = 0
        }
    }

    return 
}

is_valid :: proc(position: Vector2i32, data: string, grid_size: Vector2i32) -> bool {
    for direction in EIGHT_DIRECTIONS {
        neighbour_position := position + direction
        if grid_position_is_in_bounds(neighbour_position, grid_size) == false {
            continue
        }

        neighbour_index := grid_position_to_index(neighbour_position, grid_size.x)
        neighbour := rune(data[neighbour_index])
        // log.debugf("neighbour: %v %v \"%v\"", neighbour_position, neighbour_index, rune(neighbour))
        if slice.contains(symbols, neighbour) {
            return true
        }
    }
    return false
}

symbols := []rune { '-', '@', '*', '/', '&', '#', '%', '+', '=', '$' }

grid_position_is_in_bounds :: proc(grid_position: Vector2i32, grid_size: Vector2i32) -> bool {
    return grid_position.x >= 0 && grid_position.x < grid_size.x && grid_position.y >= 0 && grid_position.y < grid_size.y
}

grid_position_to_index :: proc(grid_position: Vector2i32, grid_width: i32) -> int {
    return int((grid_position.y * grid_width) + grid_position.x)
}

concatenate_int :: proc(x, y: int) -> int {
    pow := 10
    for y >= pow {
        pow *= 10
    }
    return x * pow + y
}

is_digit :: proc(char: rune) -> bool {
    return '0' <= char && char <= '9'
}
@(test)
is_digit_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, is_digit('0'), true)
    testing.expect_value(t, is_digit('9'), true)
    testing.expect_value(t, is_digit('a'), false)
    testing.expect_value(t, is_digit('😢'), false)
}