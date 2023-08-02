const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: cp [OPTION]... [-T] SOURCE DEST\n", .{});
    try stdout.print("または: cp [OPTION]... SOURCE... DIRECTORY\n", .{});
    try stdout.print("または: cp [OPTION]... -t DIRECTORY SOURCE...\n", .{});
    try stdout.print("SOURCE から DEST へのコピー、または複数の SOURCE の DIRECTORY へのコピーを行います。\n\n", .{});
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

    var fname = std.ArrayList([]const u8).init(alloc);
    defer fname.deinit();

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
        } else {
            try fname.append(arg);
        }
    }

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("cp");
            return;
        }
    }

    if (fname.items.len != 2) {
        try help();
        return;
    }

    const in = try fs.cwd().openFile(fname.items[0], .{});
    defer in.close();
    const out = try fs.cwd().createFile(fname.items[1], .{ .read = true });
    defer out.close();

    var buf: [1024]u8 = undefined;
    while (true) {
        const br = try in.read(buf[0..]);
        if (br == 0) break;
        try out.writeAll(buf[0..br]);
    }
}
