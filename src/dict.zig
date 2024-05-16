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
    var map = std.StringHashMap([]u8).init(allocator);
    defer {
        var it = map.iterator();
        while (it.next()) |entry| {
            const key = entry.key_ptr.*;
            allocator.free(key);
            const value = entry.value_ptr.*;
            allocator.free(value);
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
            v.value_ptr.* = val;
        } else {
            const aux = v.value_ptr.*;
            v.value_ptr.* = val;
            // tengo que liberar el viejo valor porque
            // se inserta uno nuevo. Y tengo que eliminar la clave porque
            // ya existe una.
            allocator.free(aux);
            allocator.free(key);
        }
    }

    var it = map.iterator();
    while (it.next()) |entry| {
        print("{s} -> {s}, ", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    print("\n", .{});
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
