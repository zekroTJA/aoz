const std = @import("std");

// Just a playgorund to test around with stuff.

pub fn main() !void {
    const a = [_]u8{ 1, 2, 3 };

    for (a) |v| {
        std.debug.print("{d}\n", .{v});
    }
}
