const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const stdin = std.io.getStdIn().reader();

const ReadError = error{BadRead};

pub fn read_and_alloc_mem(allocator: Allocator) ReadError![]u8 {
    var buf: [30]u8 = undefined;

    print("Enter: ", .{});
    const input: ?[]u8 = stdin.readUntilDelimiterOrEof(&buf, '\n') catch {
        return ReadError.BadRead;
    };

    if (input.?.len == 0) {
        return ReadError.BadRead;
    }
    const owned_input = allocator.dupe(u8, input.?) catch {
        return ReadError.BadRead;
    };

    return owned_input;
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
        const key = read_and_alloc_mem(allocator) catch {
            break;
        };
        const val = read_and_alloc_mem(allocator) catch {
            allocator.free(key);
            break;
        };

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
        print("{s}-{s}, ", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    print("\n", .{});
    print("{any}", .{@TypeOf(map)});
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
