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

    ///////////////////////////////////////////////////////////////
    // GRAFO CREADO POR STDIN
    ///////////////////////////////////////////////////////////////

    // GRADO DIRECCIONADO
    var directedGraphStdin: DirectedGraph = DirectedGraph.init(allocator);
    defer directedGraphStdin.deinit();
    // solicita nodos y sus adyacentes, y los inserta.
    print("\nIngresar los nodos y adyacentes del grafo direccionado: \n", .{});
    try directedGraphStdin.insertStdin(allocator);
    // imprime nodos y sus adyacentes
    print("\nGrafo direccionado: \n", .{});
    try Aux.DirectedGraphPrint(directedGraphStdin);

    // GRAFO NO DIRECCIONADO
    var undirectedGraphStdin: UndirectedGraph = UndirectedGraph.init(allocator);
    defer undirectedGraphStdin.deinit();
    // solicita nodos y sus adyacentes, y los inserta.
    print("\nIngresar los nodos y adyacentes del grafo no direccionado: \n", .{});
    try undirectedGraphStdin.insertStdin(allocator);
    // imprime nodos y sus adyacentes
    print("\nGrafo no direccionado: \n", .{});
    try Aux.UndirectedGraphPrint(undirectedGraphStdin);

    ///////////////////////////////////////////////////////////////
    // GRAFO CREADO LEYENDO UN ARCHIVO
    ///////////////////////////////////////////////////////////////

    // GRAFO DIRECCIONADO
    var directedGraphText: DirectedGraph = DirectedGraph.init(allocator);
    defer directedGraphText.deinit();
    // Crea grafo a partir de un archivo
    print("\nCreando grafo a partir de un archivo: \n", .{});
    try directedGraphText.insertFile();
    // imprime nodos y sus adyacentes
    print("\nGrafo direccionado: \n", .{});
    try Aux.DirectedGraphPrint(directedGraphText);

    // GRADO NO DIRECCIONADO
    var undirectedGraphText: UndirectedGraph = UndirectedGraph.init(allocator);
    defer undirectedGraphText.deinit();
    // Crea grafo a partir de un archivo
    print("\nCreando grafo a partir de un archivo: \n", .{});
    try undirectedGraphText.insertFile();
    // imprime nodos y sus adyacentes
    print("\nGrafo no direccionado: \n", .{});
    try Aux.UndirectedGraphPrint(undirectedGraphText);
}
