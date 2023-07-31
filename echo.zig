const std = @import("std");
const io = std.io;
const os = std.os;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: echo\n", .{});
    try stdout.print("文章を表示\n\n", .{});
    try stdout.print("-n ニューラインを見逃す\n", .{});
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
    var text: [1024]u8 = undefined;
    var text_len: usize = 0;

    for (args, 0..) |arg, i| {
        if (i == 0) continue;
        var m: [1]u8 = [_]u8{'-'};
        if (std.mem.eql(u8, arg[0..1], m[0..])) {
            for (arg, 0..) |a, j| {
                if (j == 0) continue;
                try option.append(a);
            }
        } else {
            const length = @min(arg.len, text.len - 1);
            std.mem.copy(u8, text[0..length], arg[0..length]);
            text_len = length;
        }
    }

    var isnonl = false;
    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("echo");
            return;
        }
        if (i == 'n') {
            isnonl = true;
        }
    }

    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    if (isnonl) {
        try stdout.print("{s}", .{text[0..text_len]});
    } else {
        try stdout.print("{s}\n", .{text[0..text_len]});
    }
    try bw.flush();
}
