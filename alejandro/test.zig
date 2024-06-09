const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph_w = @import("weighted_graph.zig").Graph;
const Graph = @import("graph.zig").Graph;
const testing = std.testing;


// Test para el grafo no dirigido
test "Test agrego un nodo y existe\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.countNodes() == 1);

}

test "Test agrego nodos y existen\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");

    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.countNodes() == 2);

}


test "Test agrego nodos y aristas\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B");

    try testing.expect(graph.countEdges() == 1);
    try testing.expect(graph.edgeExists("A", "B") == true);
    
}

test "Test agrego un nodo repetido y no se agrega 2 veces"{
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("A");

    try testing.expect(graph.countNodes() == 1);
}

test "Test agrego una arista a un solo nodo"{ //podria borrarse esta
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addEdge("A", "A");

    try testing.expect(graph.countEdges() == 1);
    try testing.expect(graph.edgeExists("A", "A") == true);
    
}

test "Test verifico que un nodo no agregado no existe"{
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    try testing.expect(graph.nodeExists("C") == false);
}

test "Test verifico que una arista no agregada no existe"{
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");

    try testing.expect(graph.edgeExists("A","B") == false);
}

test "Test agregar una arista a un nodo no existente devuelve error"{
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    try std.testing.expectError(error.NODE_NOT_FOUND, graph.addEdge("A", "C"));
    }

test "Test borrar una arista que no existe devuelve error"{
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();
    _ = try graph.addNode("A");
    
    try std.testing.expectError(error.NODE_NOT_FOUND, graph.deleteEdge("A", "C"));
}

test "Test borrar un nodo no existente devuelve error"{
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    try std.testing.expectError(error.NODE_NOT_FOUND, graph.deleteNode("Z"));

}

test "Test de varias operaciones\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    
    _ = try graph.addEdge("A", "B");
    
    _ = try graph.addNode("A");
    
    _ = try graph.addNode("C");
    _ = try graph.addEdge("A", "C");
    
    _ = try graph.addEdge("A", "C");
    
    _ = try graph.addEdge("A", "A");
    try testing.expect(graph.countEdges() == 4);

    _ = try graph.deleteEdge("A", "B");
    try testing.expect(graph.edgeExists("A", "B") == false);
    try testing.expect(graph.edgeExists("B", "A") == false);
    try testing.expect(graph.countEdges() == 3);

    const A = try graph.deleteNode("A");
    try testing.expect(graph.nodeExists("A") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);
    try testing.expect(graph.countEdges() == 0);
    try testing.expect(std.mem.eql(u8, A, "A"));

    try testing.expect(graph.countNodes() == 2);

    const B = try graph.deleteNode("B");
    try testing.expect(std.mem.eql(u8, B, "B"));

    const C = try graph.deleteNode("C");
    try testing.expect(std.mem.eql(u8, C, "C"));

    try testing.expect(graph.countNodes() == 0);

    _ = try graph.addNode("C");
    const valor = try graph.borrarNodo();

    try testing.expect(std.mem.eql(u8, valor, "C"));

    try testing.expect(graph.countNodes() == 0);
}


// Test para el grafo dirigido


test "Test agrego nodos y aristas a un grafo dirigido\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, true);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B");

    try testing.expect(graph.countEdges() == 1);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("B", "A") == false);    
}

test "Test verifico que una arista no agregada no existe en un grafo dirigido"{
    const allocator = testing.allocator;
    var graph = Graph.init(allocator, true);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");

    try testing.expect(graph.edgeExists("A","B") == false);
}


//Test de grafo pesado

test "Test agrego nodos, aristas y pesos" {
    const allocator = testing.allocator;
    var graph = Graph_w.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B", 2);

    _ = try graph.addNode("C");
    _ = try graph.addNode("D");
    _ = try graph.addEdge("C", "D", 5);


    try testing.expect(graph.countEdges() == 2);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("C", "D") == true);

    try testing.expect(try graph.getEdge("A", "B") == 2);
    try testing.expect(try graph.getEdge("C", "D") == 5);
    
}


test "Verificar el peso de un nodo no existente devuelve error"{
    const allocator = testing.allocator;
    var graph = Graph_w.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B", 2);

    try std.testing.expectError(error.NODE_NOT_FOUND, graph.getEdge("A","C"));

}

test "Agrego y elimino aristas y pesos "{
    const allocator = testing.allocator;
    var graph = Graph_w.init(allocator, false);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B", 2);

    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(try graph.getEdge("A", "B") == 2);
    
    _ = try graph.deleteEdge("A", "B");

    try testing.expect(graph.edgeExists("A", "B") == false);
    try testing.expect(try graph.getEdge("A", "B") == 0);
    
}


test "Agrego y elimino aristas y pesos a un grafo dirigido "{
    const allocator = testing.allocator;
    var graph = Graph_w.init(allocator, true);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B", 2);

    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(try graph.getEdge("A", "B") == 2);

    try testing.expect(graph.edgeExists("B", "A") == false);
    try testing.expect(try graph.getEdge("B", "A") == 0);
}


test "Agrego y elimino aristas y pesos a un grafo dirigido parte 2"{
    const allocator = testing.allocator;
    var graph = Graph_w.init(allocator, true);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B", 2);

    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(try graph.getEdge("A", "B") == 2);

    try testing.expect(graph.edgeExists("B", "A") == false);
    try testing.expect(try graph.getEdge("B", "A") == 0);

    _ = try graph.addEdge("B", "A", 10);
    
    try testing.expect(graph.edgeExists("B", "A") == true);
    try testing.expect(try graph.getEdge("B", "A") == 10);

}