const std = @import("std");
const fs = std.fs;
const io = std.io;
const os = std.os;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: whoami\n", .{});
    try stdout.print("ユーザー名を表示\n\n", .{});
    try stdout.print("-h ヘルプを表示\n", .{});
    try stdout.print("-v バージョンを表示\n", .{});

    try bw.flush();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var option = std.ArrayList(u8).init(alloc);
    defer option.deinit();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    for (args, 0..) |arg, i| {
        if (i == 0) continue;
        var m: [1]u8 = [_]u8{'-'};
        if (std.mem.eql(u8, arg[0..1], m[0..])) {
            for (arg, 0..) |a, j| {
                if (j == 0) continue;
                try option.append(a);
            }
        }
    }

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("whoami");
            return;
        }
    }

    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    const file = try fs.cwd().openFile("/etc/passwd", .{});
    defer file.close();

    var buf: [4096]u8 = undefined;
    const stream = file.reader();
    const real = try stream.readAll(&buf);

    var lines = std.mem.split(u8, buf[0..real], "\n");
    while (lines.next()) |*line| {
        var fields = std.mem.split(u8, line.*, ":");
        var username_opt = fields.next();
        _ = fields.next();
        var uid_str_opt = fields.next();
        if (username_opt != null and uid_str_opt != null) {
            const puid = std.fmt.parseInt(u32, uid_str_opt.?, 10) catch continue;
            if (puid == os.linux.getuid()) {
                try stdout.print("{s}\n", .{username_opt.?});
                try bw.flush();
                return;
            }
        }
    }
}
