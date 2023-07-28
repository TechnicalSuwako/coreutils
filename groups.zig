const std = @import("std");
const fs = std.fs;
const io = std.io;
const os = std.os;
const mem = std.mem;

const version = @import("version.zig").version;

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: groups\n", .{});
    try stdout.print("グループ名を表示\n\n", .{});
    try stdout.print("-h ヘルプを表示\n", .{});
    try stdout.print("-v バージョンを表示\n", .{});

    try bw.flush();
}

fn ver() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("groups (076 coreutils) {s}\n", .{version});

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
    var username: [32]u8 = undefined;

    for (args, 0..) |arg, i| {
        if (i == 0) continue;
        var m: [1]u8 = [_]u8{'-'};
        if (mem.eql(u8, arg[0..1], m[0..])) {
            for (arg, 0..) |a, j| {
                if (j == 0) continue;
                try option.append(a);
            }
        } else {
            const length = @min(arg.len, username.len - 1);
            mem.copy(u8, username[0..length], arg[0..length]);
            username[length] = 0;
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

    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();
    var buf: [4096]u8 = undefined;

    if (username[0] == 0) {
        const pfile = try fs.cwd().openFile("/etc/passwd", .{});
        defer pfile.close();

        const pstream = pfile.reader();
        const preal = try pstream.readAll(&buf);

        var plines = mem.split(u8, buf[0..preal], "\n");
        while (plines.next()) |*line| {
            var fields = mem.split(u8, line.*, ":");
            var username_opt = fields.next();
            _ = fields.next();
            var uid_str_opt = fields.next();
            if (username_opt != null and uid_str_opt != null) {
                const puid = std.fmt.parseInt(u32, uid_str_opt.?, 10) catch continue;
                if (puid == os.linux.getuid()) {
                    if (username_opt) |username_slice| {
                        mem.copy(u8, username[0..], username_slice);
                    }
                    break;
                }
            }
        }
    }

    const cwd = fs.cwd();

    const file = try cwd.openFile("/etc/group", .{});
    defer file.close();

    const stream = file.reader();
    const real = try stream.readAll(&buf);
    var user_found_in_group = false;

    var lines = mem.split(u8, buf[0..real], "\n");
    while (lines.next()) |*line| {
        var fields = mem.split(u8, line.*, ":");
        var group_opt = fields.next();
        _ = fields.next();
        _ = fields.next();
        var users_str_opt = fields.next();
        if (group_opt != null and users_str_opt != null) {
            var users = mem.split(u8, users_str_opt.?, ",");
            while (users.next()) |user| {
                var user_length: usize = 0;
                while (user[user_length] != ':' and user[user_length] != '\n') : (user_length += 1) {}
                var username_length: usize = 0;
                while (username[username_length] != 0) : (username_length += 1) {}

                if (mem.eql(u8, user[0..user_length], username[0..username_length])) {
                    try stdout.print("{s} ", .{group_opt.?});
                }
            }
        }
    }

    var it = mem.split(u8, buf[0..real], "\n");
    while (it.next()) |line| {
        user_found_in_group = false;
        var split = mem.split(u8, line, ":");

        if (split.next()) |group| {
            var group_length: usize = 0;
            while (group[group_length] != ':' and group[group_length] != '\n') : (group_length += 1) {}
            var username_length: usize = 0;
            while (username[username_length] != 0) : (username_length += 1) {}

            if (split.next()) |_| {
                if (split.next()) |_| {
                    if (split.next()) |users| {
                        var users_list = mem.split(u8, users, ",");
                        while (users_list.next()) |user| {
                            var user_length: usize = 0;
                            while (user[user_length] != ':' and user[user_length] != '\n') : (user_length += 1) {}
                            if (std.mem.eql(u8, user[0..user_length], username[0..username_length])) {
                                user_found_in_group = true;
                            }
                        }
                    }
                }
            }

            if (std.mem.eql(u8, group[0..group_length], username[0..username_length]) and !user_found_in_group) {
                try stdout.print("{s} ", .{group});
            }
        }
    }
    try stdout.print("\n", .{});
    try bw.flush();
}
