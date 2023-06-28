const std = @import("std");
const util = @import("util");
const mem = std.mem;
const debug = std.debug;
const testing = std.testing;

const Sequence = struct {
    start: u32,
    end: u32,

    const Self = @This();

    fn new(start: u32, end: u32) Self {
        return .{
            .start = start,
            .end = end,
        };
    }

    fn from(s: []const u8) !Self {
        var split = mem.splitSequence(u8, s, "-");
        return Self.new(
            try std.fmt.parseInt(u8, split.next().?, 10),
            try std.fmt.parseInt(u8, split.next().?, 10),
        );
    }

    fn fully_contains(self: *const Self, other: *const Self) bool {
        return self.start <= other.start and self.end >= other.end;
    }

    fn overlaps_full(self: *const Self, other: *const Self) bool {
        return self.fully_contains(other) or other.fully_contains(self);
    }

    fn overlaps_partial(self: *const Self, other: *const Self) bool {
        return self.end >= other.start and self.end <= other.end or other.end >= self.start and other.end <= self.end;
    }
};

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const alloc = gp.allocator();

    const input = @embedFile("./input.txt");
    var inputSplit = mem.splitSequence(u8, input, "\n");

    var sequences = std.ArrayList([2]Sequence).init(alloc);
    defer sequences.deinit();

    while (inputSplit.next()) |line| {
        if (line.len == 0) continue;

        var split = mem.splitSequence(u8, line, ",");
        const first = try Sequence.from(split.next().?);
        const second = try Sequence.from(split.next().?);

        try sequences.append(.{ first, second });
    }

    debug.print("part1: {d}\n", .{sum(sequences.items, Sequence.overlaps_full)});
    debug.print("part2: {d}\n", .{sum(sequences.items, Sequence.overlaps_partial)});
}

fn sum(sequencePairs: [][2]Sequence, comptime f: fn (*const Sequence, *const Sequence) bool) u32 {
    var s: u32 = 0;

    for (sequencePairs) |pair| {
        if (f(&pair[0], &pair[1])) s += 1;
    }

    return s;
}

test "fully contains" {
    try testing.expect((&Sequence.new(2, 5)).fully_contains(&Sequence.new(3, 5)));

    try testing.expect(!(&Sequence.new(4, 5)).fully_contains(&Sequence.new(3, 5)));
}

test "overlaps with" {
    try testing.expect((&Sequence.new(1, 5)).overlaps_partial(&Sequence.new(3, 7)));
    try testing.expect((&Sequence.new(4, 6)).overlaps_partial(&Sequence.new(2, 4)));

    // fully containing must also match
    try testing.expect((&Sequence.new(2, 5)).overlaps_partial(&Sequence.new(3, 5)));

    try testing.expect(!(&Sequence.new(1, 3)).overlaps_partial(&Sequence.new(4, 6)));
    try testing.expect(!(&Sequence.new(7, 9)).overlaps_partial(&Sequence.new(1, 2)));
}
