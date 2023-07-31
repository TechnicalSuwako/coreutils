const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: touch [OPTION]... FILE...\n", .{});
    try stdout.print("各 FILE のアクセス日時と更新日時を現在時刻に更新します。\n\n", .{});
    try stdout.print("引数 FILE が存在しない場合、 -c または -h オプションが指定されない限り、空ファイルが作成されます。\n\n", .{});
    try stdout.print("FILE 引数に - を指定した場合は、特別な動作となり、標準出力に関係づけられているファイルの日時を変更します。\n\n", .{});
    //try stdout.print("-a アクセス日時のみ変更する\n", .{});
    try stdout.print("-c 既に存在する場合、ファイルを作成しない\n", .{});
    //try stdout.print("-m 変更日時のみ変更する\n", .{});
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

    var iscreate: bool = true;
    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("touch");
            return;
        }
        if (i == 'c') {
            iscreate = false;
        }
    }

    if (fname.items.len == 0) {
        try help();
        return;
    }

    for (fname.items) |item| {
        if (iscreate) {
            const file = try fs.cwd().createFile(item, .{ .read = true });
            defer file.close();

            try file.writeAll("");
        }
    }
}
