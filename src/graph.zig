const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const GraphError = error{ PutError, RelationError };

pub const Graph = struct {
    map: std.StringHashMap(std.ArrayList([]u8)),
    allocator: Allocator,

    pub fn init(allocator: Allocator) Graph {
        return .{ .map = std.StringHashMap(std.ArrayList([]u8)).init(allocator), .allocator = allocator };
    }

    pub fn deinit(self: *Graph) void {
        var it = self.map.iterator();
        while (it.next()) |entry| {
            const source = entry.key_ptr.*;
            self.allocator.free(source);
            const adjacencies = entry.value_ptr.*;
            for (adjacencies.items) |adj| {
                self.allocator.free(adj);
            }
            adjacencies.deinit();
        }

        self.map.deinit();
    }

    pub fn add_relation(self: *Graph, source: []u8, target: []u8) !bool {
        const v = self.map.getOrPut(source) catch {
            return GraphError.PutError;
        };

        if (!v.found_existing) {
            var adjacencies = std.ArrayList([]u8).init(self.allocator);
            try adjacencies.append(target);
            v.value_ptr.* = adjacencies;
            return false;
        } else {
            try v.value_ptr.*.append(target);
            return true;
        }
    }

    pub fn add_relation_release_memory(self: *Graph, source: []u8, target: []u8) !void {
        const key_exists = self.add_relation(source, target) catch {
            self.allocator.free(source);
            self.allocator.free(target);
            return GraphError.RelationError;
        };
        if (key_exists) {
            self.allocator.free(source);
        }
    }

    pub fn relation_exists(self: *Graph, source: []u8, target: []u8) !bool {
        const obtained_result = self.map.get(source);
        if (obtained_result) |adjacencies| {
            for (adjacencies.items) |item| {
                if (std.mem.eql(u8, target, item)) {
                    return true;
                }
            }
        }

        return false;
    }

    pub fn print_relations(self: *Graph) void {
        var it = self.map.iterator();
        while (it.next()) |entry| {
            const source = entry.key_ptr.*;
            const adjs = entry.value_ptr.*;

            print("{s} -> [", .{source});
            for (adjs.items) |item| {
                print("{s}, ", .{item});
            }
            print("]\n", .{});
        }
    }
};

const testing = std.testing;
const get_relation = @import("utils.zig").get_relation;

test "Test graph memory leak" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator);
    defer graph.deinit();

    while (true) {
        const relation = get_relation(allocator) catch {
            break;
        };
        const source = relation[0];
        const target = relation[1];

        graph.add_relation_release_memory(source, target) catch {
            break;
        };
    }

    graph.print_relations();
}

test "Template" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator);
    defer graph.deinit();

    const s = try allocator.dupe(u8, "a");
    const t = try allocator.dupe(u8, "b");
    const a = try allocator.dupe(u8, "c");

    _ = try graph.add_relation(s, t);
    // _ = try graph.add_relation(s, a);
    const e = try graph.relation_exists(s, t);
    const e2 = try graph.relation_exists(s, a);

    try testing.expect(e == true);
    try testing.expect(e2 == false);

    allocator.free(a);
}
