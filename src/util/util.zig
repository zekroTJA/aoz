pub const hashset = @import("./set.zig");

pub fn contains(comptime T: type, v: T, in: []const T) bool {
    for (in) |i| {
        if (v == i) return true;
    }

    return false;
}
