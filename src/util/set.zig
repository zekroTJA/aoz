const std = @import("std");
const mem = std.mem;

pub fn HashSet(comptime T: type) type {
    return struct {
        const Self = @This();

        m: std.AutoHashMap(T, void),

        pub fn init(alloc: mem.Allocator) Self {
            return .{
                .m = std.AutoHashMap(T, void).init(alloc),
            };
        }

        pub fn deinit(self: *Self) void {
            self.m.deinit();
        }

        pub fn insert(self: *Self, v: T) !bool {
            if (self.m.contains(v)) return false;
            try self.m.put(v, {});
            return true;
        }
    };
}
