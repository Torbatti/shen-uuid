const std = @import("std");
const builtin = @import("builtin");

const zig_version = std.SemanticVersion{
    .major = 0,
    .minor = 14,
    .patch = 0,
};

comptime {
    // Compare versions while allowing different pre/patch metadata.
    const zig_version_eq = zig_version.major == builtin.zig_version.major and
        zig_version.minor == builtin.zig_version.minor and
        zig_version.patch == builtin.zig_version.patch;
    if (!zig_version_eq) {
        @compileError(std.fmt.comptimePrint(
            "unsupported zig version: expected {}, found {}",
            .{ zig_version, builtin.zig_version },
        ));
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSafe });

    // Top-level steps you can invoke on the command line.
    // const build_steps = .{
    //     .check = b.step("check", "Check if lib compiles"),
    //     .static = b.step("static", "Build lib staticly"),
    //     .@"test" = b.step("test", "Run all tests"),
    // };

    // Build options passed with `-D` flags.
    // const build_options = .{};

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "shenuuid",
        .root_module = lib_mod,
    });

    b.installArtifact(lib);
}
