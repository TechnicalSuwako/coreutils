const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: basename 名前 [接尾辞]\n", .{});
    try stdout.print("パス名からディレクトリ部分を取り除いた名前を表示します。\n", .{});
    try stdout.print("指定があれば、末尾の接尾辞も取り除きます。\n\n", .{});
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

    var name = std.ArrayList([]const u8).init(alloc);
    defer name.deinit();

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
            try name.append(arg);
        }
    }

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("basename");
            return;
        }
    }

    if (name.items.len == 0) {
        try help();
        return;
    }

    var basename: []const u8 = undefined;

    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    for (name.items, 0..) |item, i| {
        if (i > 1) break;

        if (i == 0) basename = fs.path.basename(item);
        if (i == 1) {
            if (std.mem.endsWith(u8, basename, item)) {
                const end = basename.len - item.len;
                basename = basename[0..end];
            }
        }
    }

    try stdout.print("{s}\n", .{basename});
    try bw.flush();
}
