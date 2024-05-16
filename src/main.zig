const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const stdin = std.io.getStdIn().reader();

const ReadError = error{BadRead};
const GraphError = error{ PutError, RelationError };

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

const Graph = struct {
    map: std.StringHashMap(std.ArrayList([]u8)),
    allocator: Allocator,

    pub fn init(allocator: Allocator) Graph {
        return .{ .map = std.StringHashMap(std.ArrayList([]u8)).init(allocator), .allocator = allocator };
    }

    pub fn deinit(self: *Graph) void {
        var it = self.map.iterator();
        while (it.next()) |entry| {
            const key = entry.key_ptr.*;
            self.allocator.free(key);
            const adjacencies = entry.value_ptr.*;
            for (adjacencies.items) |adj| {
                self.allocator.free(adj);
            }
            adjacencies.deinit();
        }

        self.map.deinit();
    }

    pub fn add_relation(self: *Graph, key: []u8, value: []u8) !bool {
        const v = self.map.getOrPut(key) catch {
            return GraphError.PutError;
        };

        if (!v.found_existing) {
            var adjacencies = std.ArrayList([]u8).init(self.allocator);
            try adjacencies.append(value);
            v.value_ptr.* = adjacencies;
            return false;
        } else {
            try v.value_ptr.*.append(value);
            return true;
        }
    }

    pub fn add_relation_release_memory(self: *Graph, key: []u8, value: []u8) !void {
        const key_exists = self.add_relation(key, value) catch {
            self.allocator.free(key);
            self.allocator.free(value);
            return GraphError.RelationError;
        };
        if (key_exists) {
            self.allocator.free(key);
        }
    }

    pub fn print_relations(self: *Graph) void {
        var it = self.map.iterator();
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
};

pub fn imp_hash(allocator: Allocator) !void {
    var graph = Graph.init(allocator);
    defer graph.deinit();

    while (true) {
        const key_value = get_key_value(allocator) catch {
            break;
        };
        const key = key_value[0];
        const value = key_value[1];

        graph.add_relation_release_memory(key, value) catch {
            break;
        };
    }

    graph.print_relations();
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
