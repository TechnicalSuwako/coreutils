const std = @import("std");
const fs = std.fs;
const io = std.io;

const version = @import("version.zig");

fn help() !void {
    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    try stdout.print("076 coreutils\n", .{});
    try stdout.print("使用法: wc [オプション]... [ファイル]...\n", .{});
    try stdout.print("ファイル (複数可) の内容を結合して標準出力に出力します。\n", .{});
    try stdout.print("FILE が複数指定された場合は行数の合計も表示します。\n", .{});
    try stdout.print("FILE が指定されないか、 FILE が - の場合、 標準入力から読み込みます。\n", .{});
    try stdout.print("単語は、空白類文字で区切られる、長さが 0 でない表示可能文字の列です。\n\n", .{});
    try stdout.print("ファイルの指定がない場合や FILE が - の場合, 標準入力から読み込みを行います。\n\n", .{});
    try stdout.print("下記のオプションを使って、何を数えて表示するかを選択できます。\n", .{});
    try stdout.print("表示は常に次の順です: 改行数、単語数、文字数、バイト数。\n", .{});
    try stdout.print("-c バイト数を表示する\n", .{});
    try stdout.print("-m 文字数を表示する\n", .{});
    try stdout.print("-n ヘッダーを非表示にする\n", .{});
    try stdout.print("-l 改行の数を表示する\n", .{});
    try stdout.print("-w 単語数を表示する\n", .{});
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

    var isbyte: bool = false;
    var isline: bool = false;
    var ischar: bool = false;
    var isword: bool = false;
    var isnhed: bool = false;
    var byte_cunt: usize = 0;
    var line_cunt: usize = 0;
    var char_cunt: usize = 0;
    var word_cunt: usize = 0;
    var byte_cuntt: usize = 0;
    var line_cuntt: usize = 0;
    var char_cuntt: usize = 0;
    var word_cuntt: usize = 0;

    for (option.items) |i| {
        if (i == 'h') {
            try help();
            return;
        }
        if (i == 'v') {
            try version.ver("wc");
            return;
        }
        if (i == 'c') isbyte = true;
        if (i == 'l') isline = true;
        if (i == 'm') ischar = true;
        if (i == 'n') isnhed = true;
        if (i == 'w') isword = true;
    }

    const stdof = io.getStdOut().writer();
    var bw = io.bufferedWriter(stdof);
    const stdout = bw.writer();

    if (!isnhed) {
        if (isline) {
            try stdout.print("改行数\tファル名\n", .{});
        } else if (isword) {
            try stdout.print("単語数\tファル名\n", .{});
        } else if (ischar) {
            try stdout.print("文字数\tファル名\n", .{});
        } else if (isbyte) {
            try stdout.print("バイト数\tファル名\n", .{});
        } else {
            try stdout.print("改行数\t単語数\t文字数\tバイト数\tファル名\n", .{});
        }
    }

    const stdin = io.getStdIn().reader();
    if (fname.items.len == 0) {
        // -l -c -m
        var buf: [2048]u8 = undefined;
        while (true) {
            const lne = try stdin.read(buf[0..]);
            if (lne == 0) {
                break;
            }

            const chr = try std.unicode.utf8CountCodepoints(buf[0..lne]);
            for (buf[0..lne]) |char| {
                if (char == '\n') {
                    line_cunt += 1;
                }
            }
            char_cunt += chr;
            byte_cunt += lne;

            // -w
            var insideWord: bool = false;
            for (buf[0..lne]) |char| {
                if (std.ascii.isWhitespace(char)) {
                    insideWord = false;
                } else if (!insideWord) {
                    insideWord = true;
                    word_cunt += 1;
                }
            }
        }

        if (isline) {
            try stdout.print("{d}\n", .{line_cunt});
        } else if (isword) {
            try stdout.print("{d}\n", .{word_cunt});
        } else if (ischar) {
            try stdout.print("{d}\n", .{char_cunt});
        } else if (isbyte) {
            try stdout.print("{d}\n", .{byte_cunt});
        } else {
            try stdout.print("{d}\t{d}\t{d}\t{d}\n", .{ line_cunt, word_cunt, char_cunt, byte_cunt });
        }
    } else {
        for (fname.items, 0..) |item, i| {
            byte_cunt = 0;
            line_cunt = 0;
            char_cunt = 0;
            word_cunt = 0;
            const file = try fs.cwd().openFile(item, .{});
            defer file.close();

            // -l -c -m
            var buf: [2048]u8 = undefined;
            while (true) {
                const lne = try stdin.read(buf[0..]);
                if (lne == 0) {
                    break;
                }

                const chr = try std.unicode.utf8CountCodepoints(buf[0..lne]);
                for (buf[0..lne]) |char| {
                    if (char == '\n') {
                        line_cunt += 1;
                    }
                }
                char_cunt += chr;
                byte_cunt += lne;

                // -w
                var insideWord: bool = false;
                for (buf[0..lne]) |char| {
                    if (std.ascii.isWhitespace(char)) {
                        insideWord = false;
                    } else if (!insideWord) {
                        insideWord = true;
                        word_cunt += 1;
                    }
                }
            }

            line_cuntt += line_cunt;
            char_cuntt += char_cunt;
            byte_cuntt += byte_cunt;
            word_cuntt += word_cunt;

            if (isline) {
                try stdout.print("{d}\t{s}\n", .{ line_cunt, item });
            } else if (isword) {
                try stdout.print("{d}\t{s}\n", .{ word_cunt, item });
            } else if (ischar) {
                try stdout.print("{d}\t{s}\n", .{ char_cunt, item });
            } else if (isbyte) {
                try stdout.print("{d}\t\t{s}\n", .{ byte_cunt, item });
            } else {
                try stdout.print("{d}\t{d}\t{d}\t{d}\t\t{s}\n", .{ line_cunt, word_cunt, char_cunt, byte_cunt, item });
            }

            if (i > 0) {
                if (isline) {
                    try stdout.print("{d}\t合計\n", .{line_cuntt});
                } else if (isword) {
                    try stdout.print("{d}\t合計\n", .{word_cuntt});
                } else if (ischar) {
                    try stdout.print("{d}\t合計\n", .{char_cuntt});
                } else if (isbyte) {
                    try stdout.print("{d}\t\t合計\n", .{byte_cuntt});
                } else {
                    try stdout.print("{d}\t{d}\t{d}\t{d}\t\t合計\n", .{ line_cuntt, word_cuntt, char_cuntt, byte_cuntt });
                }
            }
        }
    }

    try bw.flush();
}
