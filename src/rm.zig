const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: rm [オプション]... [ファイル]...\n\n", .{});
    try stdout.print("FILE を削除 (unlink) します。\n\n", .{});
    try stdout.print("-f 存在しないファイルを無視する。確認も行わない\n", .{});
    try stdout.print("-i 削除の前に確認を行う\n", .{});
    try stdout.print("-n 出力しない\n", .{});
    try stdout.print("-r ディレクトリとその中身を再帰的に削除する\n", .{});
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

    var isforce: bool = false;
    var ischeck: bool = false;
    var isigout: bool = false;
    var isrecur: bool = false;

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("rm");
            return;
        }
        if (i == 'f') {
            isforce = true;
        }
        if (i == 'i') {
            ischeck = true;
        }
        if (i == 'n') {
            isigout = true;
        }
        if (i == 'r') {
            isrecur = true;
        }
    }

    if (fname.items.len == 0) {
        try help();
        return;
    }

    for (fname.items) |item| {
        const stdof = io.getStdOut().writer();
        var bw = io.bufferedWriter(stdof);
        const stdout = bw.writer();

        const file_result = fs.cwd().openFile(item, .{});
        if (file_result) |*file| {
            defer file.close();
            const stat = try file.stat();

            if (stat.kind != .file) {
                if (isrecur) {
                    if (ischeck) {
                        try stdout.print("rm: '{s}' を削除しますか?\n", .{item});
                        try bw.flush();
                        if (!(try condel())) {
                            if (!isigout) {
                                try stdout.print("rm: '{s}' を削除しませんでした。\n", .{item});
                                try bw.flush();
                            }
                            continue;
                        }
                    }
                    fs.cwd().deleteTree(item) catch |e| {
                        switch (e) {
                            error.AccessDenied => {
                                try stdout.print("rm: 許可がありません。\n", .{});
                                try bw.flush();
                                return;
                            },
                            else => {},
                        }
                    };
                    if (!isigout) {
                        try stdout.print("rm: '{s}' を削除しました。\n", .{item});
                    }
                } else {
                    try stdout.print("rm: '{s}' を削除できません: ディレクトリです\n", .{item});
                }
            } else {
                if (ischeck) {
                    try stdout.print("rm: '{s}' を削除しますか?\n", .{item});
                    try bw.flush();
                    if (!(try condel())) {
                        try stdout.print("rm: '{s}' を削除しませんでした。\n", .{item});
                        try bw.flush();
                    }
                    continue;
                }
                try fs.cwd().deleteFile(item);
                if (!isigout) {
                    try stdout.print("rm: '{s}' を削除しました。\n", .{item});
                }
            }

            try bw.flush();
        } else |_| {
            if (!isforce) {
                try stdout.print("rm: '{s}' を削除できません: そのようなファイルやディレクトリはありません\n", .{item});
                try bw.flush();
            }
            continue;
        }
    }
}

fn condel() !bool {
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
