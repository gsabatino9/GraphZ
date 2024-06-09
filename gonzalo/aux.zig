const std = @import("std");
const print = std.debug.print;
const timestamp = std.time.timestamp;
const sleep = std.time.sleep;

pub fn main() !void {
    print("{}\n", .{timestamp()});
    sleep(2);
    print("{}\n", .{timestamp()});
    sleep(2);
    print("{}\n", .{timestamp()});
}
