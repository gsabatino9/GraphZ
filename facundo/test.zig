const std = @import("std");
const stdin = std.io.getStdIn().reader();
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const AdyMap = std.StringHashMap([]const u8);
const DirectedNodesMap = std.StringHashMap(DirectedGraph);
const DirectedGraph = @import("directed_graph.zig").Graph;
const DirectedNode = @import("directed_graph.zig").Node;
const UndirectedNodesMap = std.StringHashMap(DirectedGraph);
const UndirectedGraph = @import("undirected_graph.zig").Graph;
const UndirectedNode = @import("undirected_graph.zig").Node;
const Aux = @import("aux.zig");
const testing = std.testing;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TEST DIRECTED GRAPH

test "TEST DIRECTED GRAPH: Test agrego nodos y aristas, y existen" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
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

test "TEST DIRECTED GRAPH: Borro nodos y aristas, y no existen" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    _ = try graph.addEdge("A", "B");
    _ = try graph.addEdge("B", "A");
    _ = try graph.addEdge("C", "D");
    _ = try graph.addEdge("D", "D");

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.nodeExists("C") == true);
    try testing.expect(graph.nodeExists("D") == true);
    try testing.expect(graph.getEdgeNumber() == 4);
    try testing.expect(graph.removeNode("B") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.nodeExists("B") == false);
    try testing.expect(graph.removeNode("D") == true);
    try testing.expect(graph.nodeExists("D") == false);
    try testing.expect(graph.edgeExists("A", "B") == false);
    try testing.expect(graph.edgeExists("B", "A") == false);
    try testing.expect(graph.edgeExists("C", "D") == false);
    try testing.expect(graph.edgeExists("D", "D") == false);
}

test "TEST DIRECTED GRAPH: La cantidad de nodos y adyacentes registrados es correcta" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
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

test "TEST DIRECTED GRAPH: Agrego nodos y aristas, y saco por nodos" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
    defer graph.deinit();
    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 1);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 2);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getEdgeNumber() == 3);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getEdgeNumber() == 4);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 5);
    _ = try graph.addEdge("B", "D");
    try testing.expect(graph.getEdgeNumber() == 6);
    _ = try graph.addEdge("C", "A");
    try testing.expect(graph.getEdgeNumber() == 7);
    try testing.expect(graph.removeNode("C") == true);
    try testing.expect(graph.getEdgeNumber() == 5);
    try testing.expect(graph.removeNode("D") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeNode("A") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.removeNode("B") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.nodeExists("A") == false);
    try testing.expect(graph.nodeExists("B") == false);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.nodeExists("D") == false);
    // Se vuelve a probar otra vez despues de borrar nodos
    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 1);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 2);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getEdgeNumber() == 3);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getEdgeNumber() == 4);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 5);
    _ = try graph.addEdge("B", "D");
    try testing.expect(graph.getEdgeNumber() == 6);
    _ = try graph.addEdge("C", "A");
    try testing.expect(graph.getEdgeNumber() == 7);
    try testing.expect(graph.removeNode("C") == true);
    try testing.expect(graph.getEdgeNumber() == 5);
    try testing.expect(graph.removeNode("D") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeNode("A") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.removeNode("B") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.nodeExists("A") == false);
    try testing.expect(graph.nodeExists("B") == false);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.nodeExists("D") == false);
}

test "TEST DIRECTED GRAPH: Agrego nodos y aristas, y saco por aristas" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
    defer graph.deinit();
    // agrego nodos y aristas, y saco por aristas
    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 1);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 2);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getEdgeNumber() == 3);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getEdgeNumber() == 4);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 5);
    _ = try graph.addEdge("B", "D");
    try testing.expect(graph.getEdgeNumber() == 6);
    _ = try graph.addEdge("C", "A");
    try testing.expect(graph.getEdgeNumber() == 7);
    try testing.expect(graph.removeEdge("D", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 6);
    try testing.expect(graph.removeEdge("A", "B") == true);
    try testing.expect(graph.getEdgeNumber() == 5);
    try testing.expect(graph.removeEdge("A", "C") == true);
    try testing.expect(graph.getEdgeNumber() == 4);
    try testing.expect(graph.removeEdge("A", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 3);
    try testing.expect(graph.removeEdge("B", "A") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeEdge("B", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 1);
    try testing.expect(graph.removeEdge("C", "A") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    // Se vuelve a probar otra vez despues de borrar aristas
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 1);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 2);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getEdgeNumber() == 3);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getEdgeNumber() == 4);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 5);
    _ = try graph.addEdge("B", "D");
    try testing.expect(graph.getEdgeNumber() == 6);
    _ = try graph.addEdge("C", "A");
    try testing.expect(graph.getEdgeNumber() == 7);
    try testing.expect(graph.removeEdge("D", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 6);
    try testing.expect(graph.removeEdge("A", "B") == true);
    try testing.expect(graph.getEdgeNumber() == 5);
    try testing.expect(graph.removeEdge("A", "C") == true);
    try testing.expect(graph.getEdgeNumber() == 4);
    try testing.expect(graph.removeEdge("A", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 3);
    try testing.expect(graph.removeEdge("B", "A") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeEdge("B", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 1);
    try testing.expect(graph.removeEdge("C", "A") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
}

test "TEST DIRECTED GRAPH: Agrego nodos y aristas, e imprimo" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
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
    try Aux.DirectedGraphPrint(graph);
}

test "TEST DIRECTED GRAPH: Recorrido BFS" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
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

test "TEST DIRECTED GRAPH: Recorrido DFS" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
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

test "TEST DIRECTED GRAPH: Lee archivo sin errores" {
    const allocator = testing.allocator;
    var graph: DirectedGraph = DirectedGraph.init(allocator);
    defer graph.deinit();

    try graph.insertFile();
    // try Aux.DirectedGraphPrint(graph);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TEST UNDIRECTED GRAPH

test "TEST UNDIRECTED GRAPH: Test agrego nodos y aristas, y existen" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B");

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("B", "A") == true);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.edgeExists("A", "C") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);
}

test "TEST UNDIRECTED GRAPH: Borro nodos y aristas, y no existen" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 2);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 2);
    _ = try graph.addEdge("C", "D");
    try testing.expect(graph.getEdgeNumber() == 4);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 5);

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.nodeExists("C") == true);
    try testing.expect(graph.nodeExists("D") == true);
    try testing.expect(graph.removeNode("B") == true);
    try testing.expect(graph.getEdgeNumber() == 3);
    try testing.expect(graph.nodeExists("B") == false);
    try testing.expect(graph.removeNode("D") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.nodeExists("D") == false);
    try testing.expect(graph.edgeExists("A", "B") == false);
    try testing.expect(graph.edgeExists("B", "A") == false);
    try testing.expect(graph.edgeExists("C", "D") == false);
    try testing.expect(graph.edgeExists("D", "D") == false);
}

test "TEST UNDIRECTED GRAPH: La cantidad de nodos y adyacentes registrados es correcta" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
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

test "TEST UNDIRECTED GRAPH: Agrego nodos y aristas, y saco por nodos" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
    defer graph.deinit();
    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 1);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 3);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getEdgeNumber() == 5);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getEdgeNumber() == 7);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 7);
    _ = try graph.addEdge("B", "D");
    try testing.expect(graph.getEdgeNumber() == 9);
    _ = try graph.addEdge("C", "A");
    try testing.expect(graph.getEdgeNumber() == 9);
    try testing.expect(graph.removeNode("C") == true);
    try testing.expect(graph.getEdgeNumber() == 7);
    try testing.expect(graph.removeNode("D") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeNode("A") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.removeNode("B") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.nodeExists("A") == false);
    try testing.expect(graph.nodeExists("B") == false);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.nodeExists("D") == false);
    // Se vuelve a probar otra vez despues de borrar nodos
    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 1);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 3);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getEdgeNumber() == 5);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getEdgeNumber() == 7);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 7);
    _ = try graph.addEdge("B", "D");
    try testing.expect(graph.getEdgeNumber() == 9);
    _ = try graph.addEdge("C", "A");
    try testing.expect(graph.getEdgeNumber() == 9);
    try testing.expect(graph.removeNode("C") == true);
    try testing.expect(graph.getEdgeNumber() == 7);
    try testing.expect(graph.removeNode("D") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeNode("A") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.removeNode("B") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.nodeExists("A") == false);
    try testing.expect(graph.nodeExists("B") == false);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.nodeExists("D") == false);
}

test "TEST UNDIRECTED GRAPH: Agrego nodos y aristas, y saco por aristas" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
    defer graph.deinit();
    // agrego nodos y aristas, y saco por aristas
    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 1);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 3);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getEdgeNumber() == 5);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getEdgeNumber() == 7);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 7);
    _ = try graph.addEdge("B", "D");
    try testing.expect(graph.getEdgeNumber() == 9);
    _ = try graph.addEdge("C", "A");
    try testing.expect(graph.getEdgeNumber() == 9);
    try testing.expect(graph.removeEdge("D", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 8);
    try testing.expect(graph.removeEdge("A", "B") == true);
    try testing.expect(graph.getEdgeNumber() == 6);
    try testing.expect(graph.removeEdge("A", "C") == true);
    try testing.expect(graph.getEdgeNumber() == 4);
    try testing.expect(graph.removeEdge("A", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeEdge("B", "A") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeEdge("B", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.removeEdge("C", "A") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    // Se vuelve a probar otra vez despues de borrar aristas
    try testing.expect(graph.getEdgeNumber() == 0);
    _ = try graph.addEdge("D", "D");
    try testing.expect(graph.getEdgeNumber() == 1);
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.getEdgeNumber() == 3);
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.getEdgeNumber() == 5);
    _ = try graph.addEdge("A", "D");
    try testing.expect(graph.getEdgeNumber() == 7);
    _ = try graph.addEdge("B", "A");
    try testing.expect(graph.getEdgeNumber() == 7);
    _ = try graph.addEdge("B", "D");
    try testing.expect(graph.getEdgeNumber() == 9);
    _ = try graph.addEdge("C", "A");
    try testing.expect(graph.getEdgeNumber() == 9);
    try testing.expect(graph.removeEdge("D", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 8);
    try testing.expect(graph.removeEdge("A", "B") == true);
    try testing.expect(graph.getEdgeNumber() == 6);
    try testing.expect(graph.removeEdge("A", "C") == true);
    try testing.expect(graph.getEdgeNumber() == 4);
    try testing.expect(graph.removeEdge("A", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeEdge("B", "A") == true);
    try testing.expect(graph.getEdgeNumber() == 2);
    try testing.expect(graph.removeEdge("B", "D") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
    try testing.expect(graph.removeEdge("C", "A") == true);
    try testing.expect(graph.getEdgeNumber() == 0);
}

test "TEST UNDIRECTED GRAPH Agrego nodos y aristas, e imprimo" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
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
    try Aux.UndirectedGraphPrint(graph);
}

test "TEST UNDIRECTED GRAPH Recorrido BFS" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
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

test "TEST UNDIRECTED GRAPH: Recorrido DFS" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
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

test "TEST UNDIRECTED GRAPH: Lee archivo sin errores" {
    const allocator = testing.allocator;
    var graph: UndirectedGraph = UndirectedGraph.init(allocator);
    defer graph.deinit();

    try graph.insertFile();
    // try Aux.UndirectedGraphPrint(graph);
}
