const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const AutoHashMap = std.hash_map.AutoHashMap;
const StringContext = std.hash_map.StringContext;
const math = std.math;
const Allocator = std.mem.Allocator;

const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS };

const AdjacentsType = ArrayList(u64);
const Adjacents = struct {
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

const AdjacentsMapType = AutoHashMap(u64, Adjacents);
const AdjacentsMap = struct {
    map: AdjacentsMapType,
    allocator: Allocator,
    const Self = @This();
    const Size = AdjacentsMapType.Size;

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

const NodesMapType = AutoHashMap(u64, []const u8);
const NodesMap = struct {
    map: NodesMapType,
    ctx: StringContext,
    const Self = @This();
    const Size = NodesMapType.Size;

    pub fn init(allocator: Allocator) Self {
        return .{ .map = NodesMapType.init(allocator), .ctx = undefined };
    }

    pub fn deinit(self: *Self) void {
        self.map.deinit();
    }

    pub fn mapNodeLabel(self: *Self, node_label: []const u8) u64 {
        return self.ctx.hash(node_label);
    }

    pub fn addNodeLabel(self: *Self, node_label: []const u8) !?u64 {
        const node_hash = self.mapNodeLabel(node_label);
        if (self.map.contains(node_hash)) {
            return null;
        }

        try self.map.put(node_hash, node_label);
        return node_hash;
    }

    pub fn containsLabel(self: *Self, node_label: []const u8) bool {
        const node_hash = self.mapNodeLabel(node_label);
        return self.map.contains(node_hash);
    }

    pub fn lookup(self: *Self, node_hash: u64) ![]const u8 {
        const node_label = self.map.get(node_hash);
        if (node_label) |label| {
            return label;
        }

        return GraphError.NODE_NOT_EXISTS;
    }

    pub fn countNodes(self: *Self) Size {
        return self.map.count();
    }
};

pub const Graph = struct {
    nodes_map: NodesMap,
    adjacents_map: AdjacentsMap,
    allocator: Allocator,
    const Self = @This();
    const Size = AdjacentsMap.Size;

    pub fn init(allocator: Allocator) Self {
        return .{ .nodes_map = NodesMap.init(allocator), .adjacents_map = AdjacentsMap.init(allocator), .allocator = allocator };
    }

    pub fn deinit(self: *Self) void {
        self.adjacents_map.deinit();
        self.nodes_map.deinit();
    }

    /// retorna true si lo agrega, false si ya existe
    pub fn addNode(self: *Self, node: []const u8) !bool {
        const node_hash = try self.nodes_map.addNodeLabel(node);
        if (node_hash) |h| {
            _ = try self.adjacents_map.addNode(h);
            return true;
        }
        return false;
    }

    pub fn contains(self: *Self, node: []const u8) bool {
        return self.nodes_map.containsLabel(node);
    }

    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) !void {
        if (!(self.nodes_map.containsLabel(node1) and self.nodes_map.containsLabel(node2))) {
            return GraphError.NODE_NOT_EXISTS;
        }

        const node_hash1 = self.nodes_map.mapNodeLabel(node1);
        const node_hash2 = self.nodes_map.mapNodeLabel(node2);
        try self.adjacents_map.addEdge(node_hash1, node_hash2);
    }

    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
        const node_hash1 = self.nodes_map.mapNodeLabel(node1);
        const node_hash2 = self.nodes_map.mapNodeLabel(node2);

        return self.adjacents_map.edgeExists(node_hash1, node_hash2);
    }

    pub fn countNodes(self: *Self) Size {
        return self.nodes_map.countNodes();
    }

    pub fn countEdges(self: *Self) Size {
        return self.adjacents_map.countEdges();
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

test "Test nodes map" {
    const allocator = testing.allocator;
    var nodes_map = NodesMap.init(allocator);
    defer nodes_map.deinit();

    try testing.expect(nodes_map.mapNodeLabel("a") == 2941419223392617777);

    _ = try nodes_map.addNodeLabel("a");
    try testing.expect(nodes_map.containsLabel("a") == true);

    const lookup_value = try nodes_map.lookup(2941419223392617777);
    try testing.expect(std.mem.eql(u8, lookup_value, "a"));

    try testing.expect(nodes_map.lookup(1234) == GraphError.NODE_NOT_EXISTS);
}

test "Test graph" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("a");
    _ = try graph.addNode("b");

    try testing.expect(graph.contains("a") == true);
    try testing.expect(graph.contains("b") == true);
    try testing.expect(graph.contains("c") == false);

    try graph.addEdge("a", "b");
    try testing.expect(graph.edgeExists("a", "b") == true);
    try testing.expect(graph.edgeExists("a", "c") == false);

    // const err = graph.addEdge("a", "c");
    // try testing.expectError(GraphError.NODE_NOT_EXISTS, err);

    try testing.expect(graph.countNodes() == 2);
    try testing.expect(graph.countEdges() == 1);
}
