const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: cat [オプション]... [ファイル]...\n", .{});
    try stdout.print("ファイル (複数可) の内容を結合して標準出力に出力します。\n\n", .{});
    try stdout.print("ファイルの指定がない場合や FILE が - の場合, 標準入力から読み込みを行います。\n\n", .{});
    try stdout.print("-b カッコの行列以外、全ての行に行番号を付ける\n", .{});
    try stdout.print("-d 全部は１行列に表示する\n", .{});
    try stdout.print("-n 全ての行に行番号を付ける\n", .{});
    try stdout.print("-s カッコの行列を見逃す\n", .{});
    try stdout.print("-u 不使用\n", .{});
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

    var isnun: bool = false;
    var iscol: bool = false;
    var isone: bool = false;
    var isnum: bool = false;
    var issqz: bool = false;
    var line_number: usize = 0;

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("cat");
            return;
        }
        if (i == 'b') isnun = true;
        if (i == 'c') iscol = true;
        if (i == 'd') isone = true;
        if (i == 'n') isnum = true;
        if (i == 's') issqz = true;
    }

    if (fname.items.len == 0) {
        const stdin = io.getStdIn().reader();
        var buf: [2048]u8 = undefined;
        while (true) {
            const lne = try stdin.read(buf[0..]);
            if (lne == 0) {
                break;
            }

            try io.getStdOut().writer().writeAll(buf[0..lne]);
        }
    } else {
        for (fname.items) |item| {
            const file = fs.cwd().openFile(item, .{});
            if (file) |f| {
                defer f.close();
                const stat = try f.stat();
                if (stat.kind == .directory) {
                    std.debug.print("'{s}' はディレクトリです。\n", .{item});
                    continue;
                }

                var buf: [1024]u8 = undefined;
                while (true) {
                    const result = try f.reader().readUntilDelimiterOrEof(buf[0..], '\n') orelse break;
                    if (issqz and std.mem.trimRight(u8, result, "\n\r").len == 0) continue;
                    const stripped = std.mem.trim(u8, result, " \n\t\r");

                    if (isone) {
                        try io.getStdOut().writer().writeAll(stripped);
                    } else {
                        if (isnum or (isnun and stripped.len != 0)) {
                            line_number += 1;
                            try io.getStdOut().writer().print("  {:3} | ", .{line_number});
                        } else if (isnum) {
                            line_number += 1;
                            try io.getStdOut().writer().print("  {:3} | ", .{line_number});
                        }

                        try io.getStdOut().writer().writeAll(result);
                        try io.getStdOut().writer().print("\n", .{});
                    }
                }
            } else |err| {
                switch (err) {
                    error.FileNotFound => {
                        std.debug.print("ファイルを見つけられません。\n", .{});
                        break;
                    },
                    error.AccessDenied => {
                        std.debug.print("アクセスに出来ません。\n", .{});
                        break;
                    },
                    else => {
                        std.debug.print("エラー。\n", .{});
                        break;
                    },
                }
            }
        }
    }
}
