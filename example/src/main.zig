const std = @import("std");
const String = @import("string").String;
const print = std.debug.print;

const debug = std.debug;
const io = std.io;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var str = String.init(allocator);
    defer str.deinit();

    try str.setStr("Goodbye, cruel world!");
    print("{s}\n", .{str.str()});
}
