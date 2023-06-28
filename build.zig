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
    var dirsIter = dirs.iterate();

    const utilModule = b.addModule("util", .{
        .source_file = .{ .path = "./src/util/util.zig" },
    });

    while (try dirsIter.next()) |path| {
        if (path.kind != .directory) {
            continue;
        }
        if (!std.mem.startsWith(u8, path.name, "day_")) {
            continue;
        }

        var nameSplit = std.mem.splitBackwards(u8, path.name, "_");
        var dayNumber = nameSplit.next().?;

        const exe = b.addExecutable(.{
            .name = b.fmt("day_{s}", .{dayNumber}),
            .root_source_file = .{ .path = b.fmt("src/{s}/main.zig", .{path.name}) },
            .target = target,
            .optimize = optimize,
        });

        exe.addModule("util", utilModule);

        b.installArtifact(exe);
        const runCmd = b.addRunArtifact(exe);

        const runStep = b.step(b.fmt("day-{s}", .{dayNumber}), b.fmt("Run day {s}", .{dayNumber}));
        runStep.dependOn(&runCmd.step);

        const unitTests = b.addTest(.{
            .root_source_file = exe.root_src.?,
            .target = exe.target,
            .optimize = exe.optimize,
        });

        const runUnitTests = b.addRunArtifact(unitTests);

        // Similar to creating the run step earlier, this exposes a `test` step to
        // the `zig build --help` menu, providing a way for the user to request
        // running the unit tests.
        const testStep = b.step(b.fmt("test-{s}", .{dayNumber}), "Run unit tests");
        testStep.dependOn(&runUnitTests.step);
    }

    {
        const exe = b.addExecutable(.{
            .name = "playground",
            .root_source_file = .{ .path = "src/playground.zig" },
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(exe);
        const runCmd = b.addRunArtifact(exe);

        const runStepPlayground = b.step("playground", "Run playground");
        runStepPlayground.dependOn(&runCmd.step);
    }
}
