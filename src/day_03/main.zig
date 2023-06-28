const std = @import("std");
const util = @import("util");
const mem = std.mem;
const debug = std.debug;
const testing = std.testing;

pub fn priority(v: u8) !u32 {
    return switch (v) {
        'a'...'z' => v - 96,
        'A'...'Z' => v - 38,
        else => error.InvalidCharacter,
    };
}

pub fn getPriosOfDupes(alloc: mem.Allocator, comp1: []const u8, comp2: []const u8) !u32 {
    var sum: u32 = 0;

    var set = util.hashset.HashSet(u8).init(alloc);
    defer set.deinit();

    for (comp1) |v1| {
        for (comp2) |v2| {
            if (v1 == v2 and try set.insert(v1)) {
                sum += try priority(v1);
            }
        }
    }

    return sum;
}

pub fn inAllBackpacks(bp1: []const u8, bp2: []const u8, bp3: []const u8) ?u8 {
    for (bp1) |b1| {
        if (!util.contains(u8, b1, bp2)) continue;
        if (!util.contains(u8, b1, bp3)) continue;
        return b1;
    }
    return null;
}

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const alloc = gp.allocator();

    const input = @embedFile("./input.txt");
    var inputSplit = mem.splitSequence(u8, input, "\n");

    var rucksacks = std.ArrayList([]const u8).init(alloc);
    defer rucksacks.deinit();

    while (inputSplit.next()) |line| {
        if (line.len == 0) continue;
        try rucksacks.append(line);
    }

    try part1(alloc, rucksacks.items);
    try part2(rucksacks.items);
}

fn part1(alloc: mem.Allocator, rucksacks: [][]const u8) !void {
    var sum: u32 = 0;
    for (rucksacks) |rucksack| {
        const comp1 = rucksack[0 .. rucksack.len / 2];
        const comp2 = rucksack[rucksack.len / 2 ..];
        sum += try getPriosOfDupes(alloc, comp1, comp2);
    }

    debug.print("part1: {d}\n", .{sum});
}

fn part2(rucksacks: [][]const u8) !void {
    var sum: u32 = 0;

    var i: u32 = 0;
    var last: [3][]const u8 = undefined;
    for (rucksacks) |rucksack| {
        last[i % 3] = rucksack;
        i += 1;
        if (i % 3 == 0) {
            const item = inAllBackpacks(last[0], last[1], last[2]).?;
            sum += try priority(item);
        }
    }

    debug.print("part2: {d}\n", .{sum});
}

test "priority" {
    try testing.expectEqual(@as(u32, 1), try priority('a'));
    try testing.expectEqual(@as(u32, 4), try priority('d'));
    try testing.expectEqual(@as(u32, 27), try priority('A'));
    try testing.expectEqual(@as(u32, 37), try priority('K'));
}
