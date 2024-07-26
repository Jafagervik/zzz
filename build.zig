const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const core = b.addModule("core", .{
        .root_source_file = b.path("src/core/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zzz = b.addModule("zzz", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    zzz.addImport("core", core);

    addExample(b, "http", target, optimize, zzz);
    addExample(b, "http_blocking", target, optimize, zzz);
}

fn addExample(
    b: *std.Build,
    name: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.Mode,
    zzz_module: *std.Build.Module,
) void {
    const example = b.addExecutable(.{
        .name = b.fmt("zzz_example_{s}", .{name}),
        .root_source_file = b.path(b.fmt("src/examples/{s}/main.zig", .{name})),
        .target = target,
        .optimize = optimize,
    });

    example.root_module.addImport("zzz", zzz_module);
    b.installArtifact(example);

    const run_cmd = b.addRunArtifact(example);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(b.fmt("run_{s}", .{name}), b.fmt("Run zzz example ({s})", .{name}));
    run_step.dependOn(&run_cmd.step);
}
