const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const DirectedGraph = @import("directed_graph.zig").Graph;
const UndirectedGraph = @import("undirected_graph.zig").Graph;
const Aux = @import("aux.zig");

// MAIN - implementación usando doble diccionario

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    // grafo direccionado
    var directedGraph: DirectedGraph = DirectedGraph.init(allocator);
    defer directedGraph.deinit();
    // grafo no direccionado
    var undirectedGraph: UndirectedGraph = UndirectedGraph.init(allocator);
    defer undirectedGraph.deinit();

    // Grafo direccionado    -> solicita por stdin nodos y sus adyacentes y los inserta
    print("Ingresar los nodos y adyacentes del grafo direccionado: \n");
    try directedGraph.insertStdin(allocator);
    // Grafo no direccionado -> solicita por stdin nodos y sus adyacentes y los inserta
    print("Ingresar los nodos y adyacentes del grafo no direccionado: \n");
    try undirectedGraph.insertStdin(allocator);

    // Grafo direccionado    -> imprime nodos y sus adyacentes
    print("Grafo direccionado: \n");
    try Aux.DirectedGraphPrint(directedGraph);
    // Grafo no direccionado -> imprime nodos y sus adyacentes
    print("Grafo no direccionado: \n");
    try Aux.UndirectedGraphPrint(undirectedGraph);

    // crear grafo a partir de un .csv
}
