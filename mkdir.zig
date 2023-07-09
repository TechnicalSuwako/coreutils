const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig").version;

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: mkdir [OPTION]... DIRECTORY...\n", .{});
    try stdout.print("ディレクトリが存在しない場合に、ディレクトリを作成します。\n\n", .{});
    try stdout.print("-p ディレクトリが存在していてもエラーを返さない。\n   必要に応じて親ディレクトリを作成する。\n", .{});
    try stdout.print("-h ヘルプを表示\n", .{});
    try stdout.print("-v バージョンを表示\n", .{});

    try bw.flush();
}

fn ver() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("mkdir (076 coreutils) {s}\n", .{version});

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

    var isoya: bool = false;

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try ver();
            return;
        }
        if (i == 'p') {
            isoya = true;
        }
    }

    if (fname.items.len == 0) {
        try help();
        return;
    }

    for (fname.items) |item| {
        if (isoya) {
            var tmp_path = std.ArrayList(u8).init(alloc);
            defer tmp_path.deinit();

            var it = std.mem.split(u8, item, "/");
            while (it.next()) |comp| {
                _ = try tmp_path.appendSlice(comp);
                _ = try tmp_path.append('/');
                const tmp_path_str = tmp_path.items;
                _ = fs.cwd().makeDir(tmp_path_str) catch |err| switch (err) {
                    error.PathAlreadyExists => {},
                    else => |e| return e,
                };
            }
        } else {
            try fs.cwd().makeDir(item);
        }
    }
}
