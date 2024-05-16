const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const stdin = std.io.getStdIn().reader();

const ReadError = error{BadRead};

pub fn get_key_value(allocator: Allocator) ![2][]u8 {
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

pub fn imp_hash(allocator: Allocator) !void {
    var map = std.StringHashMap(std.ArrayList([]u8)).init(allocator);
    defer {
        var it = map.iterator();
        while (it.next()) |entry| {
            const key = entry.key_ptr.*;
            allocator.free(key);
            const adjacencies = entry.value_ptr.*;
            for (adjacencies.items) |adj| {
                allocator.free(adj);
            }
            adjacencies.deinit();
        }
        map.deinit();
    }

    while (true) {
        const key_value = get_key_value(allocator) catch {
            break;
        };
        const key = key_value[0];
        const val = key_value[1];

        const v = map.getOrPut(key) catch {
            allocator.free(key);
            allocator.free(val);
            break;
        };

        if (!v.found_existing) {
            var adjacencies = std.ArrayList([]u8).init(allocator);
            try adjacencies.append(val);
            v.value_ptr.* = adjacencies;
        } else {
            try v.value_ptr.*.append(val);
            allocator.free(key);
        }
    }

    var it = map.iterator();
    while (it.next()) |entry| {
        const key = entry.key_ptr.*;
        const adjs = entry.value_ptr.*;

        print("{s} -> [", .{key});
        for (adjs.items) |item| {
            print("{s}, ", .{item});
        }
        print("]\n", .{});
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try imp_hash(allocator);
}

const testing = std.testing;
test "Test memory leak" {
    const allocator = testing.allocator;
    try imp_hash(allocator);
    try testing.expect(1 == 1);
}
