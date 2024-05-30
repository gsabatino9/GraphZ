const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const NodesMap = std.StringHashMap(Node);
const AdyMap = std.StringHashMap([]const u8);
const Graph = @import("graph.zig").Graph;
const Node = @import("graph.zig").Node;
const stdin = std.io.getStdIn().reader();

// Test

const testing = std.testing;
test "Test agrego nodos y aristas, y existen" {
    const allocator = testing.allocator;
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B");

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("B", "A") == false);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.edgeExists("A", "C") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);
}

test "Borro nodos y aristas, y no existen" {
    const allocator = testing.allocator;
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B");
    _ = try graph.addEdge("B", "A");

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.removeNode("B") == true);
    try testing.expect(graph.nodeExists("B") == false);
    try testing.expect(graph.edgeExists("A", "B") == false);
    try testing.expect(graph.edgeExists("B", "A") == false);
}
