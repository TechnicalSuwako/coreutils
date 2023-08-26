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
    try stdout.print("-e ファイルが既に存在したら、上書かない\n", .{});
    //try stdout.print("-f コピー先にファイルが存在し、開くことができない場合、\n  削除してから再度試みる (-e オプションも指定した\n  場合はこのオプションは無視される)\n", .{});
    try stdout.print("-i 上書きする前に確認する (前に指定した -n オプション\n  を上書きする)\n", .{});
    try stdout.print("-n 出力しない\n", .{});
    //try stdout.print("-p 許可、所有者、とタイムスタンプを保管\n", .{});
    //try stdout.print("-r 再帰的にディレクトリをコピーする\n", .{});
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

    var isnover: bool = false;
    var isforce: bool = false;
    var ischeck: bool = false;
    var isigout: bool = false;
    var isprsrv: bool = false;
    var isrecur: bool = false;

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("cp");
            return;
        }
        if (i == 'e') isnover = true;
        if (i == 'f') isforce = true; // TODO
        if (i == 'i') ischeck = true;
        if (i == 'n') isigout = true;
        if (i == 'p') isprsrv = true; // TODO
        if (i == 'r') isrecur = true; // TODO
    }

    if (isnover and ischeck) ischeck = false;
    if (isnover and isforce) isnover = false;

    if (fname.items.len != 2) {
        try help();
        return;
    }

    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    const in = try fs.cwd().openFile(fname.items[0], .{});
    defer in.close();
    const instat = try in.stat();

    const chk = fs.cwd().openFile(fname.items[1], .{});
    if (chk) |f| {
        f.close();
        if (isnover) {
            try stdout.print("cp: '{s}' は既に存在しています。コピーしません。\n", .{fname.items[1]});
            try bw.flush();
            return;
        }
    } else |e| {
        switch (e) {
            error.FileNotFound => {},
            else => {},
        }
    }

    const out = try fs.cwd().createFile(fname.items[1], .{ .read = true });
    defer out.close();

    if (instat.kind != .file) {
        if (isrecur) {
            if (ischeck) {
                try stdout.print("cp: '{s}' をコピーしますか?\n", .{fname.items[0]});
                try bw.flush();
                if (!(try concpy())) {
                    if (!isigout) {
                        try stdout.print("cp: '{s}' をコピーしませんでした。\n", .{fname.items[0]});
                        try bw.flush();
                    }
                    return;
                }
            }
            try copyfile(in, out);
            if (!isigout) {
                try stdout.print("cp: '{s}' は '{s}' にコピーしました。\n", .{ fname.items[0], fname.items[1] });
            }
        } else {
            try stdout.print("cp: '{s}' をコピーできません: ディレクトリです\n", .{fname.items[0]});
        }
    } else {
        if (ischeck) {
            try stdout.print("cp: '{s}' を上書きしますか?\n", .{fname.items[1]});
            try bw.flush();
            if (!(try concpy())) {
                if (!isigout) {
                    try stdout.print("cp: '{s}' をコピーしませんでした。\n", .{fname.items[0]});
                    try bw.flush();
                }
                return;
            }
        }
        try copyfile(in, out);
        if (!isigout) {
            try stdout.print("cp: '{s}' は '{s}' にコピーしました。\n", .{ fname.items[0], fname.items[1] });
        }
    }

    try bw.flush();
}

fn copyfile(in: fs.File, out: fs.File) !void {
    var buf: [1024]u8 = undefined;
    while (true) {
        const br = try in.read(buf[0..]);
        if (br == 0) break;
        try out.writeAll(buf[0..br]);
    }
}

fn concpy() !bool {
    const stdin = io.getStdIn();
    var buf = io.bufferedReader(stdin.reader());
    var r = buf.reader();
    var cbuf: [10]u8 = undefined;
    var input = try r.readUntilDelimiterOrEof(&cbuf, '\n');
    var ly: [1]u8 = [_]u8{'y'};
    var uy: [1]u8 = [_]u8{'Y'};
    if (input) |i| {
        if (i.len == 1) {
            return (std.mem.eql(u8, i[0..1], &ly) or std.mem.eql(u8, i[0..1], &uy));
        } else {
            return false;
        }
    } else {
        return false;
    }
}
