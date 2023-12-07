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

@(test) day_07a_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_07a_process(aoc.load_file_or_fail(t, "day_07/day_07a_input_01.txt")), 6440)
    testing.expect_value(t, day_07a_process(aoc.load_file_or_fail(t, "day_07/day_07a_input_02.txt")), 252295678)
}

@(test) day_07b_test :: proc(t: ^testing.T) {
    context.logger = log.create_console_logger(.Debug, { .Level, .Terminal_Color })
    testing.expect_value(t, day_07b_process(aoc.load_file_or_fail(t, "day_07/day_07a_input_01.txt")), 5905)
    testing.expect_value(t, day_07b_process(aoc.load_file_or_fail(t, "day_07/day_07a_input_02.txt")), -1)
}

day_07a_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    lines := strings.split_lines(input_string)
    hands := make([]Hand, len(lines))
    for line, line_i in strings.split_lines(input_string) {
        parts := strings.split(line, " ")

        cards := make([]rune, len(parts[0]))
        hand_map := make(map[rune]int, 5)
        for char, i in parts[0] {
            cards[i] = char
            hand_map[char] += 1
        }

        type := Hand_Types.High_Card
        for key in hand_map {
            if hand_map[key] == 5 {
                type = .Five_Of_A_Kind
                break
            }
            if hand_map[key] == 4 {
                type = .Four_Of_A_Kind
                break
            }
            if hand_map[key] == 3 {
                if type == .One_Pair {
                    type = .Full_House
                    break
                }
                type = .Three_Of_A_Kind
                continue
            }
            if hand_map[key] == 2 {
                if type == .Three_Of_A_Kind {
                    type = .Full_House
                    break
                }
                if type == .One_Pair {
                    type = .Two_Pair
                    break
                }
                type = .One_Pair
            }
        }

        bid, parse_ok := strconv.parse_int(parts[1])
        assert(parse_ok)

        cost := 0 | uint(type) << 20 | CARD_POWER[cards[0]] << 16 | CARD_POWER[cards[1]] << 12 | CARD_POWER[cards[2]] << 8 | CARD_POWER[cards[3]] << 4 | CARD_POWER[cards[4]] << 0
        hands[line_i] = Hand { cards, type, bid, cost }
    }

    slice.sort_by_key(hands, proc(hand: Hand) -> uint {
        return hand.cost
    })
    for hand, i in hands {
        rank := i + 1
        result += rank * hand.bid
        // log.debugf("[%i] hand: %v bid: %v | %v | cost: %v", rank, hand.cards, hand.bid, hand.type, hand.cost)
    }

    return
}

day_07b_process :: proc(input: []byte) -> (result: int) {
    input_string := strings.clone_from_bytes(input)

    lines := strings.split_lines(input_string)
    hands := make([]Hand, len(lines))
    for line, line_i in strings.split_lines(input_string) {
        parts := strings.split(line, " ")

        cards := make([]rune, len(parts[0]))
        hand_map := make(map[rune]int, 5)
        largest_index := 'J'
        largest_value := 0
        for char, i in parts[0] {
            cards[i] = char
            hand_map[char] += 1
            if char != 'J' && hand_map[char] > largest_value {
                largest_index = char
                largest_value = hand_map[char]
            }
        }
        if largest_index != 'J' {
            hand_map[largest_index] += hand_map['J']
        }

        type := Hand_Types.High_Card
        has_5_same := false
        has_4_same := false
        has_3_same := false
        pairs := 0
        for key in hand_map {
            assert(hand_map[key] >= 0, fmt.tprintf("%v -> %v", key, hand_map[key]))
            assert(hand_map[key] <= 5, fmt.tprintf("%v -> %v", key, hand_map[key]))
            if hand_map[key] == 5 {
                has_5_same = true
            }
            if hand_map[key] == 4 {
                has_4_same = true
            }
            if hand_map[key] == 3 {
                has_3_same = true
            }
            if hand_map[key] == 2 {
                pairs += 1
            }
        }

        if has_5_same {
            type = .Five_Of_A_Kind
        } else if has_4_same {
            type = .Four_Of_A_Kind
        } else if has_3_same && pairs > 0 {
            type = .Full_House
        } else if has_3_same {
            type = .Three_Of_A_Kind
        } else if pairs == 2 {
            type = .Two_Pair
        } else if pairs == 1 {
            type = .One_Pair
        }

        bid, parse_ok := strconv.parse_int(parts[1])
        assert(parse_ok)

        cost := 0 | uint(type) << 20 | CARD_POWER_B[cards[0]] << 16 | CARD_POWER_B[cards[1]] << 12 | CARD_POWER_B[cards[2]] << 8 | CARD_POWER_B[cards[3]] << 4 | CARD_POWER_B[cards[4]] << 0
        hands[line_i] = Hand { cards, type, bid, cost }
    }

    slice.sort_by_key(hands, proc(hand: Hand) -> uint {
        return hand.cost
    })
    for hand, i in hands {
        rank := i + 1
        result += rank * hand.bid
        // log.debugf("[%i] hand: %v bid: %v | %v | cost: %v", rank, hand.cards, hand.bid, hand.type, hand.cost)
    }

    return
}

Hand :: struct {
    cards: []rune,
    type:  Hand_Types,
    bid:   int,
    cost:  uint,
}

Hand_Types :: enum {
    High_Card = 0,
    One_Pair = 1,
    Two_Pair = 2,
    Three_Of_A_Kind = 3,
    Full_House = 4,
    Four_Of_A_Kind = 5,
    Five_Of_A_Kind = 6,
}

CARD_POWER := map[rune]uint {
    '2' = 0,
    '3' = 1,
    '4' = 2,
    '5' = 3,
    '6' = 4,
    '7' = 5,
    '8' = 6,
    '9' = 7,
    'T' = 8,
    'J' = 9,
    'Q' = 10,
    'K' = 11,
    'A' = 12,
}

CARD_POWER_B := map[rune]uint {
    'J' = 0,
    '2' = 1,
    '3' = 2,
    '4' = 3,
    '5' = 4,
    '6' = 5,
    '7' = 6,
    '8' = 7,
    '9' = 8,
    'T' = 9,
    'Q' = 10,
    'K' = 11,
    'A' = 12,
}