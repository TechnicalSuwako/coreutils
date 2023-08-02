const std = @import("std");
const toki = @import("toki");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: ls [オプション]... [ファイル]...\n\n", .{});
    try stdout.print("FILE (デフォルトは現在のディレクトリ) に関する情報を一覧表示します。\n\n", .{});
    //try stdout.print("-a . で始まる要素を無視しない\n", .{});
    //try stdout.print("-A . および .. を一覧表示しない\n", .{});
    try stdout.print("-l use a long listing format\n", .{});
    //try stdout.print("-m -l と併せて使用され、サイズを 1K, 234M, 2Gのような形式で表示する。\n", .{});
    //try stdout.print("-r ソート順を反転させる\n", .{});
    //try stdout.print("-R 子ディレクトリを再帰的に一覧表示する\n", .{});
    try stdout.print("-s ブロック単位で各ファイルサイズを表示する\n", .{});
    //try stdout.print("-S sort by file size, largest first\n", .{});
    //try stdout.print("-t 時刻で新しい順にソートする\n", .{});
    //try stdout.print("-X 拡張子のアルファベット順にソートする\n", .{});
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

    var isa: bool = false;
    var isA: bool = false;
    var isl: bool = false;
    var ism: bool = false;
    var isr: bool = false;
    var isR: bool = false;
    var iss: bool = false;
    var isS: bool = false;
    var ist: bool = false;
    var isX: bool = false;

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("ls");
            return;
        }
        if (i == 'a') isa = true;
        if (i == 'A') isA = true;
        if (i == 'l') isl = true;
        if (i == 'm') ism = true;
        if (i == 'r') isr = true;
        if (i == 'R') isR = true;
        if (i == 's') iss = true;
        if (i == 'S') isS = true;
        if (i == 't') ist = true;
        if (i == 'X') isX = true;
    }

    const dir = try fs.cwd().openIterableDir(".", .{});

    var iter = dir.iterate();
    var stdout = io.getStdOut().writer();
    if (isl) {
        //try stdout.print("許可\tオーナー\tグループ\t", .{});
        try stdout.print("サイズ\t変更日 (GMT)\t\tファイル名\n", .{});
    }

    while (try iter.next()) |entry| {
        if (iss) {
            const BLOCK_SIZE: usize = 4096;
            var file = try fs.cwd().openFile(entry.name, .{});
            defer file.close();
            const stat = try file.stat();
            const size = stat.size;
            try stdout.print("{d} {s}\t", .{ size / BLOCK_SIZE, entry.name });
        } else if (isl) {
            var file = try fs.cwd().openFile(entry.name, .{});
            defer file.close();
            var stats = try file.stat();
            std.debug.print("stat: {}\n", .{stats});
            var t = stats.mtime;
            const unix = toki.nanoToSecond(@intCast(t));
            const dt = toki.unixToDateTime(unix);

            try stdout.print("{d}\t{d}-{s}-{s} {s}:{s}:{s}\t{s}\n", .{
                stats.size,
                dt.year,
                toki.fmtDigit(@intCast(dt.month)),
                toki.fmtDigit(@intCast(dt.day)),
                toki.fmtDigit(@intCast(dt.hour)),
                toki.fmtDigit(@intCast(dt.minute)),
                toki.fmtDigit(@intCast(dt.second)),
                entry.name,
            });
        } else {
            try stdout.print("{s}\t", .{entry.name});
        }
    }
    try stdout.print("\n", .{});
}
