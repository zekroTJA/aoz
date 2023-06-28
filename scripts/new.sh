source $PWD/.env || { echo "No .env file found in the current directory!"; exit 1; }

[ -z $SESSION_TOKEN ] && { echo "SESSION_TOKEN is not set in .env file!"; exit 1; }

current_day=$(ls -r1 src | grep "day_" | head -1)
current_day="${current_day/*_}"
next_day=$(expr $current_day + 1)
next_day_padded=$(printf "%02d" $next_day)

mkdir "src/day_$next_day_padded"

cat > "src/day_$next_day_padded/main.zig" << EOF
const std = @import("std");
const util = @import("util");
const mem = std.mem;
const debug = std.debug;
const testing = std.testing;

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const alloc = gp.allocator();
    _ = alloc;

    const input = @embedFile("./input.txt");
    var inputSplit = mem.splitSequence(u8, input, "\n");

    while (inputSplit.next()) |line| {
        if (line.len == 0) continue;

    }
}
EOF

curl -sL -H "Cookie: session=$SESSION_TOKEN" \
    -o "src/day_$next_day_padded/input.txt" \
    "https://adventofcode.com/2022/day/${next_day}/input"