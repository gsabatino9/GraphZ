const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const stdin = std.io.getStdIn().reader();

const ReadError = error{BadRead};

pub fn get_relation(allocator: Allocator) ![2][]u8 {
    var buf: [30]u8 = undefined;
    print("Enter key, value: ", .{});

    const key_value: ?[]u8 = stdin.readUntilDelimiterOrEof(&buf, '\n') catch {
        return ReadError.BadRead;
    };
    var splits = std.mem.split(u8, key_value.?, ",");

    const k_next = splits.next();
    if (k_next == null) {
        return ReadError.BadRead;
    }
    const key = k_next.?;

    const v_next = splits.next();
    if (v_next == null) {
        return ReadError.BadRead;
    }
    const value = v_next.?;

    const owned_key = allocator.dupe(u8, key) catch {
        return ReadError.BadRead;
    };
    const owned_value = allocator.dupe(u8, value) catch {
        return ReadError.BadRead;
    };

    const arr = [2][]u8{ owned_key, owned_value };
    return arr;
}
