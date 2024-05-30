const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const AutoHashMap = std.hash_map.AutoHashMap;
const StringContext = std.hash_map.StringContext;
const math = std.math;
const Allocator = std.mem.Allocator;
const GraphError = @import("../errors.zig").GraphError;

pub const AdjacentsType = ArrayList(u64);
pub const Adjacents = struct {
    adjacencies: AdjacentsType,
    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{ .adjacencies = AdjacentsType.init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.adjacencies.deinit();
    }

    pub fn add(self: *Self, adjacent: u64) !void {
        try self.adjacencies.append(adjacent);
    }

    pub fn contains(self: *Self, adjacent_required: u64) bool {
        for (self.adjacencies.items) |adjacent| {
            if (adjacent == adjacent_required) {
                return true;
            }
        }

        return false;
    }

    pub fn count(self: *Self) usize {
        return self.adjacencies.items.len;
    }
};

pub const AdjacentsMapType = AutoHashMap(u64, Adjacents);
pub const AdjacentsMap = struct {
    map: AdjacentsMapType,
    allocator: Allocator,
    const Self = @This();
    pub const Size = AdjacentsMapType.Size;

    pub fn init(allocator: Allocator) Self {
        return .{ .map = AdjacentsMapType.init(allocator), .allocator = allocator };
    }

    pub fn deinit(self: *Self) void {
        var adjacents_iterator = self.map.iterator();
        while (adjacents_iterator.next()) |adjacents_ptr| {
            adjacents_ptr.value_ptr.deinit();
        }

        self.map.deinit();
    }

    /// devuelve true en caso de que inserte el nodo.
    /// false en caso de que no
    pub fn addNode(self: *Self, node: u64) !bool {
        // si el nodo ya está, no hago nada
        if (self.map.contains(node)) {
            return false;
        }

        try self.map.put(node, Adjacents.init(self.allocator));
        return true;
    }

    pub fn addEdge(self: *Self, node: u64, new_adj: u64) !void {
        const nodes_adjacents: *Adjacents = self.map.getPtr(node) orelse return GraphError.NODE_NOT_EXISTS;
        try nodes_adjacents.add(new_adj);
    }

    pub fn edgeExists(self: *Self, node1: u64, node2: u64) bool {
        const nodes_adjacents: *Adjacents = self.map.getPtr(node1) orelse return false;
        return nodes_adjacents.contains(node2);
    }

    pub fn countEdges(self: *Self) Size {
        var amount_edges: Size = 0;
        var it = self.map.iterator();
        while (it.next()) |node| {
            amount_edges += @intCast(node.value_ptr.count());
        }

        return amount_edges;
    }
};

const testing = std.testing;
test "Test adjacents" {
    const allocator = testing.allocator;
    var adjacents = Adjacents.init(allocator);
    defer adjacents.deinit();

    try adjacents.add(1);
    try adjacents.add(2);

    try testing.expect(adjacents.contains(1) == true);
    try testing.expect(adjacents.contains(2) == true);
    try testing.expect(adjacents.contains(3) == false);
}

test "Test adjacents map" {
    const allocator = testing.allocator;
    var adjacents_map = AdjacentsMap.init(allocator);
    defer adjacents_map.deinit();

    _ = try adjacents_map.addNode(1);

    try adjacents_map.addEdge(1, 2);
    const edge_3_1 = adjacents_map.addEdge(3, 1);

    try testing.expect(edge_3_1 == GraphError.NODE_NOT_EXISTS);
    try testing.expect(adjacents_map.edgeExists(1, 2) == true);
    try testing.expect(adjacents_map.edgeExists(1, 3) == false);
}
