package aoc

import "core:testing"
import "core:fmt"
import "core:os"

load_file_or_fail :: proc(t: ^testing.T, path: string) -> []byte {
    input, ok := os.read_entire_file_from_filename(path);
    if ok == false {
        testing.fail_now(t, fmt.tprintf("Couldn't load file: %v", path))
        os.exit(1)
    }
    return input
}