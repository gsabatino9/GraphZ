const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const AutoHashMap = std.hash_map.AutoHashMap;
const StringContext = std.hash_map.StringContext;
const math = std.math;
const Allocator = std.mem.Allocator;
const AdjacentsMap = @import("adjacents/adjacents.zig").AdjacentsMap;
const NodesMap = @import("nodes/nodes_map.zig").NodesMap;
const GraphError = @import("errors.zig").GraphError;

pub const GraphType = enum { Directed, Undirected };

pub const Graph = struct {
    nodes_map: NodesMap,
    adjacents_map: AdjacentsMap,
    allocator: Allocator,
    is_directed: bool,
    const Self = @This();
    const Size = AdjacentsMap.Size;

    pub fn init(allocator: Allocator, graph_type: GraphType) Self {
        const is_directed = graph_type == GraphType.Directed;
        // graph type default is undirected
        return .{ .nodes_map = NodesMap.init(allocator), .adjacents_map = AdjacentsMap.init(allocator), .allocator = allocator, .is_directed = is_directed };
    }

    pub fn init_undirected(allocator: Allocator) Self {
        return Self.init(allocator, GraphType.Undirected);
    }

    pub fn init_directed(allocator: Allocator) Self {
        return Self.init(allocator, GraphType.Directed);
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
        if (!self.is_directed) {
            try self.adjacents_map.addEdge(node_hash2, node_hash1);
        }
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
        if (self.is_directed) {
            return self.adjacents_map.countEdges();
        } else {
            return self.adjacents_map.countEdges() / 2;
        }
    }
};

const testing = std.testing;
test "Test graph" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, GraphType.Undirected);
    defer graph.deinit();

    _ = try graph.addNode("a");
    _ = try graph.addNode("b");

    try testing.expect(graph.contains("a") == true);
    try testing.expect(graph.contains("b") == true);
    try testing.expect(graph.contains("c") == false);

    try graph.addEdge("a", "b");
    try testing.expect(graph.edgeExists("a", "b") == true);
    try testing.expect(graph.edgeExists("b", "a") == true);
    try testing.expect(graph.edgeExists("a", "c") == false);

    // const err = graph.addEdge("a", "c");
    // try testing.expectError(GraphError.NODE_NOT_EXISTS, err);

    try testing.expect(graph.countNodes() == 2);
    try testing.expect(graph.countEdges() == 1);
}
