package main

import "core:time"
import "core:thread"
import "core:testing"
import "core:strings"
import "core:strconv"
import "core:sort"
import "core:slice"
import "core:log"
import "core:fmt"
import "core:container/queue"
import aoc ".."

@(test) day_08a_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_08a_process(aoc.load_file_or_fail(t, "day_08/day_08a_input_01.txt")), 2)
    testing.expect_value(t, day_08a_process(aoc.load_file_or_fail(t, "day_08/day_08a_input_02.txt")), 20777)
}

// @(test) day_08b_test :: proc(t: ^testing.T) {
//     context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
//     testing.expect_value(t, day_08b_process(aoc.load_file_or_fail(t, "day_08/day_08a_input_01.txt")), -1)
//     testing.expect_value(t, day_08b_process(aoc.load_file_or_fail(t, "day_08/day_08a_input_02.txt")), -1)
// }

day_08a_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    lines := strings.split_lines(input_string)

    path := strings.split(lines[0], "")
    // log.debugf("path: %v", path)

    current_node: ^Node
    nodes := make(map[string]Node, len(lines[2:]))
    for line, i in lines[2:] {
        parts := strings.split_multi(line, { " = (", ", ", ")" })
        node := Node { id = parts[0], left = parts[1], right = parts[2] }
        nodes[node.id] = node
        
        if current_node == nil && node.id == "AAA" {
            current_node = &nodes[node.id]
        }
    }

    path_queue := queue.Queue(string) {}
    queue.push_back_elems(&path_queue, ..path)
    for queue.len(path_queue) > 0 {
        direction := queue.pop_front(&path_queue)

        next_node: ^Node
        if direction == "L" {
            next_node = &nodes[current_node.left]
        } else {
            next_node = &nodes[current_node.right]
        }

        result += 1
        current_node = next_node


        if current_node.id == "ZZZ" {
            return
        }

        if queue.len(path_queue) == 0 {
            queue.push_back_elems(&path_queue, ..path)
        }
    }

    return
}

Node :: struct {
    id:    string,
    left:  string,
    right: string,
}