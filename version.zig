const std = @import("std");

pub const version = "0.0.1";

pub fn ver(name: []const u8) !void {
    const stdof = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("{s} (076 coreutils) {s}\n", .{ name, version });

    try bw.flush();
}
