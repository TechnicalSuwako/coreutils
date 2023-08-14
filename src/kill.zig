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
    try stdout.print("使用法: kill [オプション]... [PID]...\n", .{});
    try stdout.print("プロセスを終了\n\n", .{});
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

    var pids = std.ArrayList([]const u8).init(alloc);
    defer pids.deinit();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    for (args, 0..) |arg, i| {
        if (i == 0) continue;
        var m: [1]u8 = [_]u8{'-'};
        if (std.mem.eql(u8, arg[0..1], m[0..])) {
            for (arg, 0..) |a, j| {
                if (j == 0) continue;
                try option.append(a);
            }
        } else {
            try pids.append(arg);
        }
    }

    var signal: u8 = 0;

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        } else if (i == 'v') {
            try version.ver("kill");
            return;
        } else {
            signal = i;
        }
    }

    if (pids.items.len == 0) {
        try help();
    } else {
        for (pids.items) |item| {
            const pid = try std.fmt.parseInt(os.pid_t, item, 10);
            _ = try os.kill(pid, signal);
            try stdout.print("酷いよ！！プロセス {} を殺しました。まぁ、しょうがないね…\n", .{pid});
        }
    }

    try bw.flush();
}
