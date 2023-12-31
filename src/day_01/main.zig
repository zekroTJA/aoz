const std = @import("std");
const debug = std.debug;

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const alloc = gp.allocator();

    const input = @embedFile("./input.txt");

    var elfs = std.mem.split(u8, input, "\n\n");

    var elfCalories = std.ArrayList(std.BoundedArray(u32, 500)).init(alloc);
    defer elfCalories.deinit();

    while (elfs.next()) |elf| {
        var calories = std.BoundedArray(u32, 500).init(0) catch unreachable;

        var elfSplit = std.mem.split(u8, elf, "\n");
        while (elfSplit.next()) |line| {
            if (line.len == 0) {
                continue;
            }
            const cal = try std.fmt.parseInt(u32, line, 10);
            try calories.append(cal);
        }

        try elfCalories.append(calories);
    }

    part1(elfCalories.items);

    try part2(alloc, elfCalories.items);
}

fn part1(elfs: []const std.BoundedArray(u32, 500)) void {
    var max: u32 = 0;

    for (elfs) |cals| {
        var sum: u32 = 0;
        for (cals.slice()) |c| {
            sum += c;
        }
        if (sum > max) {
            max = sum;
        }
    }

    debug.print("part1: {d}\n", .{max});
}

fn part2(alloc: std.mem.Allocator, elfs: []const std.BoundedArray(u32, 500)) !void {
    var totalSum: u32 = 0;

    var sums = std.ArrayList(u32).init(alloc);
    defer sums.deinit();

    for (elfs) |cals| {
        var sum: u32 = 0;
        for (cals.slice()) |c| {
            sum += c;
        }
        try sums.append(sum);
    }

    std.sort.block(u32, sums.items, {}, comptime std.sort.desc(u32));

    for (sums.items[0..3]) |i| {
        totalSum += i;
    }

    debug.print("part2: {d}\n", .{totalSum});
}
