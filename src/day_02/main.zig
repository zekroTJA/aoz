const std = @import("std");
const mem = std.mem;
const debug = std.debug;
const testing = std.testing;

// Rock     +1  A X
// Paper    +2  B Y
// Scissors +3  C Z
// Lose     +0
// Draw     +3
// Win      +6

const Shape = enum(u8) {
    Rock = 1,
    Paper = 2,
    Scissors = 3,

    fn from(c: u8) !Shape {
        return switch (c) {
            'A', 'X' => .Rock,
            'B', 'Y' => .Paper,
            'C', 'Z' => .Scissors,
            else => error.InvalidShape,
        };
    }

    fn match(self: Shape, other: Shape) Result {
        return switch (self) {
            .Rock => switch (other) {
                .Rock => .Draw,
                .Paper => .Lose,
                .Scissors => .Win,
            },
            .Paper => switch (other) {
                .Rock => .Win,
                .Paper => .Draw,
                .Scissors => .Lose,
            },
            .Scissors => switch (other) {
                .Rock => .Lose,
                .Paper => .Win,
                .Scissors => .Draw,
            },
        };
    }

    fn forResult(self: Shape, res: Result) Shape {
        return switch (self) {
            .Rock => switch (res) {
                .Win => .Paper,
                .Draw => .Rock,
                .Lose => .Scissors,
            },
            .Paper => switch (res) {
                .Win => .Scissors,
                .Draw => .Paper,
                .Lose => .Rock,
            },
            .Scissors => switch (res) {
                .Win => .Rock,
                .Draw => .Scissors,
                .Lose => .Paper,
            },
        };
    }
};

const Result = enum(u8) {
    Lose = 0,
    Draw = 3,
    Win = 6,

    fn from(c: u8) !Result {
        return switch (c) {
            'X' => .Lose,
            'Y' => .Draw,
            'Z' => .Win,
            else => error.InvalidResult,
        };
    }

    fn score(a: Shape, b: Shape) u32 {
        const res = a.match(b);
        return @intFromEnum(a) + @intFromEnum(res);
    }
};

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const alloc = gp.allocator();

    const input = @embedFile("./input.txt");

    var matches = std.ArrayList([2]Shape).init(alloc);
    defer matches.deinit();

    var outcomes = std.ArrayList(struct { Shape, Result }).init(alloc);
    defer outcomes.deinit();

    var linesSplit = mem.split(u8, input, "\n");
    while (linesSplit.next()) |line| {
        if (line.len == 0) continue;

        var pair_split = mem.split(u8, line, " ");

        const a = pair_split.next().?[0];
        const b = pair_split.next().?[0];

        const op = try Shape.from(a);
        const me = try Shape.from(b);
        try matches.append(.{ me, op });

        const res = try Result.from(b);
        try outcomes.append(.{ op, res });
    }

    part1(matches.items);
    part2(outcomes.items);
}

fn part1(matches: []const [2]Shape) void {
    var sum: u32 = 0;
    for (matches) |shapes| {
        sum += Result.score(shapes[0], shapes[1]);
    }

    debug.print("part1: {d}\n", .{sum});
}

fn part2(outcomes: []const struct { Shape, Result }) void {
    var sum: u32 = 0;
    for (outcomes) |outcome| {
        const r = outcome[1];
        const s = outcome[0].forResult(r);
        sum += @intFromEnum(s) + @intFromEnum(r);
    }

    debug.print("part2: {d}\n", .{sum});
}

test "shapes" {
    try testing.expectEqual(Shape.Rock, try Shape.from('X'));
    try testing.expectEqual(Shape.Paper, try Shape.from('B'));

    try testing.expectError(error.InvalidShape, Shape.from('U'));
}

test "match" {
    try testing.expectEqual(Result.Win, Shape.Rock.match(.Scissors));
    try testing.expectEqual(Result.Lose, Shape.Paper.match(.Scissors));
    try testing.expectEqual(Result.Draw, Shape.Scissors.match(.Scissors));
}
