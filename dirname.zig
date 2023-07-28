const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig").version;

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: dirname 名前\n", .{});
    try stdout.print("NAME の最後の / (スラッシュ) 以降の要素 (/ を含む) を削除して表示します。\n", .{});
    try stdout.print("NAME に / が含まれない場合は、(カレントディレクトリを意味する) '.' を表示します。\n\n", .{});
    try stdout.print("-h ヘルプを表示\n", .{});
    try stdout.print("-v バージョンを表示\n", .{});

    try bw.flush();
}

fn ver() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("dirname (076 coreutils) {s}\n", .{version});

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
            try ver();
            return;
        }
    }

    if (name.items.len == 0) {
        try help();
        return;
    }

    var dirname: []const u8 = undefined;

    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    for (name.items) |item| {
        dirname = fs.path.dirname(item) orelse "";
        try stdout.print("{s}\n", .{dirname});
    }

    try bw.flush();
}
