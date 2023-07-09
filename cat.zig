const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig").version;

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: cat [オプション]... [ファイル]...\n", .{});
    try stdout.print("ファイル (複数可) の内容を結合して標準出力に出力します。\n\n", .{});
    try stdout.print("ファイルの指定がない場合や FILE が - の場合, 標準入力から読み込みを行います。\n\n", .{});
    //try stdout.print("-c 色\n", .{});
    try stdout.print("-n 全ての行に行番号を付ける\n", .{});
    try stdout.print("-h ヘルプを表示\n", .{});
    try stdout.print("-v バージョンを表示\n", .{});

    try bw.flush();
}

fn ver() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("cat (076 coreutils) {s}\n", .{version});

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

    var iscol: bool = false;
    var isnum: bool = false;

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try ver();
            return;
        }
        if (i == 'c') {
            iscol = true;
        }
        if (i == 'n') {
            isnum = true;
        }
    }

    if (fname.items.len == 0) {
        try help();
        return;
    }

    for (fname.items) |item| {
        const file = try fs.cwd().openFile(item, .{});
        defer file.close();

        var buf: [1024]u8 = undefined;
        while (true) {
            const br = try file.read(buf[0..]);
            if (br == 0) break;
            try io.getStdOut().writer().writeAll(buf[0..br]);
        }
    }
}
