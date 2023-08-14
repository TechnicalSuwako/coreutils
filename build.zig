const std = @import("std");
const toki = @import("libtoki");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ライブラリ
    const lib_toki = b.dependency("toki", .{ .target = target, .optimize = optimize });

    // バイナリ
    const bin_basename = b.addExecutable(.{ .name = "basename", .root_source_file = .{ .path = "src/basename.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_basename);

    const bin_cat = b.addExecutable(.{ .name = "cat", .root_source_file = .{ .path = "src/cat.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_cat);

    const bin_cp = b.addExecutable(.{ .name = "cp", .root_source_file = .{ .path = "src/cp.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_cp);

    const bin_dirname = b.addExecutable(.{ .name = "dirname", .root_source_file = .{ .path = "src/dirname.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_dirname);

    const bin_echo = b.addExecutable(.{ .name = "echo", .root_source_file = .{ .path = "src/echo.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_echo);

    const bin_false = b.addExecutable(.{ .name = "false", .root_source_file = .{ .path = "src/false.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_false);

    const bin_groups = b.addExecutable(.{ .name = "groups", .root_source_file = .{ .path = "src/groups.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_groups);

    const bin_kill = b.addExecutable(.{ .name = "kill", .root_source_file = .{ .path = "src/kill.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_kill);

    const bin_ls = b.addExecutable(.{ .name = "ls", .root_source_file = .{ .path = "src/ls.zig" }, .target = target, .optimize = optimize });
    bin_ls.addModule("toki", lib_toki.module("toki"));
    bin_ls.linkLibrary(lib_toki.artifact("toki"));
    b.installArtifact(bin_ls);

    const bin_mkdir = b.addExecutable(.{ .name = "mkdir", .root_source_file = .{ .path = "src/mkdir.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_mkdir);

    const bin_pwd = b.addExecutable(.{ .name = "pwd", .root_source_file = .{ .path = "src/pwd.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_pwd);

    const bin_rm = b.addExecutable(.{ .name = "rm", .root_source_file = .{ .path = "src/rm.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_rm);

    const bin_touch = b.addExecutable(.{ .name = "touch", .root_source_file = .{ .path = "src/touch.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_touch);

    const bin_true = b.addExecutable(.{ .name = "true", .root_source_file = .{ .path = "src/true.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_true);

    const bin_wc = b.addExecutable(.{ .name = "wc", .root_source_file = .{ .path = "src/wc.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_wc);

    const bin_whoami = b.addExecutable(.{ .name = "whoami", .root_source_file = .{ .path = "src/whoami.zig" }, .target = target, .optimize = optimize });
    b.installArtifact(bin_whoami);
}
