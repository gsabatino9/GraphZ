const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const NodesMap = std.StringHashMap(Node);
const AdyMap = std.StringHashMap([]const u8);
const Graph = @import("graph.zig").Graph;
const Node = @import("graph.zig").Node;
const Aux = @import("aux.zig");
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

test "La cantidad de nodos y adyacentes registrados es correcta" {
    const allocator = testing.allocator;
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();

    try testing.expect(graph.getNodeNumber() == 0);
    _ = try graph.addNode("A");
    try testing.expect(graph.getNodeNumber() == 1);
    _ = try graph.addNode("B");
    try testing.expect(graph.getNodeNumber() == 2);
    _ = try graph.addNode("C");
    try testing.expect(graph.getNodeNumber() == 3);
    _ = try graph.addNode("D");
    try testing.expect(graph.getNodeNumber() == 4);
    try testing.expect(graph.getAdyNumber("A") == 0);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getAdyNumber("A") == 1);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getAdyNumber("A") == 2);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getAdyNumber("A") == 3);
}

test "Agrego nodos y aristas, e imprimo" {
    const allocator = testing.allocator;
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("E");
    _ = try graph.addNode("I");
    _ = try graph.addNode("O");
    _ = try graph.addNode("U");
    _ = try graph.addEdge("A", "E");
    _ = try graph.addEdge("E", "I");
    _ = try graph.addEdge("I", "O");
    _ = try graph.addEdge("O", "U");
    _ = try graph.addEdge("U", "A");
    print("\n", .{});
    try Aux.graph_print(graph);
}

test "Recorrido BFS" {
    const allocator = testing.allocator;
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    _ = try graph.addNode("E");
    _ = try graph.addNode("F");
    _ = try graph.addNode("G");
    _ = try graph.addNode("H");
    _ = try graph.addNode("I");
    _ = try graph.addNode("J");
    _ = try graph.addEdge("A", "B");
    _ = try graph.addEdge("B", "C");
    _ = try graph.addEdge("C", "D");
    _ = try graph.addEdge("D", "E");
    _ = try graph.addEdge("E", "F");
    _ = try graph.addEdge("F", "G");
    _ = try graph.addEdge("G", "H");
    _ = try graph.addEdge("H", "I");
    _ = try graph.addEdge("I", "J");
    _ = try graph.addEdge("A", "D");
    _ = try graph.addEdge("D", "J");
    _ = try graph.addEdge("A", "C");
    _ = try graph.addEdge("C", "J");
    _ = try graph.addEdge("A", "C");

    print("\n", .{});
    try graph.bfs("A", "B");
    try graph.bfs("A", "C");
    try graph.bfs("A", "D");
    try graph.bfs("A", "I");
    try graph.bfs("A", "J");
}

test "Recorrido DFS" {
    const allocator = testing.allocator;
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    _ = try graph.addNode("E");
    _ = try graph.addNode("F");
    _ = try graph.addNode("G");
    _ = try graph.addNode("H");
    _ = try graph.addNode("I");
    _ = try graph.addNode("J");
    _ = try graph.addEdge("A", "B");
    _ = try graph.addEdge("B", "C");
    _ = try graph.addEdge("C", "D");
    _ = try graph.addEdge("D", "E");
    _ = try graph.addEdge("E", "F");
    _ = try graph.addEdge("F", "G");
    _ = try graph.addEdge("G", "H");
    _ = try graph.addEdge("H", "I");
    _ = try graph.addEdge("I", "J");
    _ = try graph.addEdge("A", "D");
    _ = try graph.addEdge("D", "J");
    _ = try graph.addEdge("A", "C");
    _ = try graph.addEdge("C", "J");
    _ = try graph.addEdge("A", "C");

    print("\n", .{});
    try graph.dfs("A", "B");
    try graph.dfs("A", "C");
    try graph.dfs("A", "D");
    try graph.dfs("A", "I");
    try graph.dfs("A", "J");
}
