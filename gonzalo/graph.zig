const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const GraphError = @import("errors.zig").GraphError;
const GraphUnmanaged = @import("graph_unmanaged.zig").GraphUnmanaged;

pub const GraphConfig = struct {
    is_directed: bool = true,
};

pub const Graph = struct {
    allocator: Allocator,
    graph_config: GraphConfig,
    graph_unmanaged: GraphUnmanaged,
    const Self = @This();
    const Size = GraphUnmanaged.Size;

    pub fn init(allocator: Allocator, graph_config: GraphConfig) Self {
        return .{ .allocator = allocator, .graph_config = graph_config, .graph_unmanaged = GraphUnmanaged.init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.graph_unmanaged.deinit();
    }

    /// retorna true si lo agrega, false si ya existe
    pub fn addNode(self: *Self, node: []const u8) !bool {
        return try self.graph_unmanaged.addNode(node);
    }

    pub fn contains(self: *Self, node: []const u8) bool {
        return self.graph_unmanaged.contains(node);
    }

    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) !void {
        try self.graph_unmanaged.addEdge(node1, node2, self.graph_config.is_directed);
    }

    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
        return self.graph_unmanaged.edgeExists(node1, node2);
    }

    pub fn countNodes(self: *Self) Size {
        return self.graph_unmanaged.countNodes();
    }

    pub fn countEdges(self: *Self) Size {
        return self.graph_unmanaged.countEdges(self.graph_config.is_directed);
    }
};

const testing = std.testing;
test "Test graph. Default: directed" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, .{});
    defer graph.deinit();

    _ = try graph.addNode("a");
    _ = try graph.addNode("b");

    try testing.expect(graph.contains("a") == true);
    try testing.expect(graph.contains("b") == true);
    try testing.expect(graph.contains("c") == false);

    try graph.addEdge("a", "b");
    try testing.expect(graph.edgeExists("a", "b") == true);
    try testing.expect(graph.edgeExists("b", "a") == false);
    try testing.expect(graph.edgeExists("a", "c") == false);

    try testing.expect(graph.countNodes() == 2);
    try testing.expect(graph.countEdges() == 1);
}

test "Test graph. Graph type: undirected" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, .{ .is_directed = false });
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

    try testing.expect(graph.countNodes() == 2);
    try testing.expect(graph.countEdges() == 1);
}
