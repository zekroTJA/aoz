const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const optimize = b.standardOptimizeOption(.{});

    const dirs = try std.fs.cwd().openIterableDir("./src", .{});
    var dirs_iter = dirs.iterate();

    while (try dirs_iter.next()) |path| {
        if (path.kind != .directory) {
            continue;
        }
        if (!std.mem.startsWith(u8, path.name, "day_")) {
            continue;
        }

        var name_split = std.mem.splitBackwards(u8, path.name, "_");
        var day_number = name_split.next().?;

        const exe = b.addExecutable(.{
            .name = b.fmt("day_{s}", .{day_number}),
            .root_source_file = .{ .path = b.fmt("src/{s}/main.zig", .{path.name}) },
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);

        const run_step_playground = b.step(b.fmt("run-{s}", .{day_number}), b.fmt("Run day {s}", .{day_number}));
        run_step_playground.dependOn(&run_cmd.step);
    }

    {
        const exe = b.addExecutable(.{
            .name = "playground",
            .root_source_file = .{ .path = "src/playground.zig" },
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);

        const run_step_playground = b.step("playground", "Run playground");
        run_step_playground.dependOn(&run_cmd.step);
    }
}
