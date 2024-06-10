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

    // grafo direccionado creado por stdin
    var directedGraphStdin: DirectedGraph = DirectedGraph.init(allocator);
    defer directedGraphStdin.deinit();
    // grafo no direccionado creado por stdin
    var undirectedGraphStdin: UndirectedGraph = UndirectedGraph.init(allocator);
    defer undirectedGraphStdin.deinit();

    // grafo direccionado creado a partir de un .csv
    var directedGraphText: DirectedGraph = DirectedGraph.init(allocator);
    defer directedGraphText.deinit();
    // grafo no direccionado creado a partir de un .csv
    var undirectedGraphText: UndirectedGraph = UndirectedGraph.init(allocator);
    defer undirectedGraphText.deinit();

    ///////////////////////////////////////////////////////////////

    // Grafo direccionado    -> Crea grafo por stdin: solicita nodos y sus adyacentes, y los inserta.
    print("Ingresar los nodos y adyacentes del grafo direccionado: \n");
    try directedGraphStdin.insertStdin(allocator);
    // Grafo no direccionado -> Crea grafo por stdin: solicita nodos y sus adyacentes, y los inserta.
    print("Ingresar los nodos y adyacentes del grafo no direccionado: \n");
    try undirectedGraphStdin.insertStdin(allocator);

    // Grafo direccionado    -> imprime nodos y sus adyacentes
    print("Grafo direccionado: \n");
    try Aux.DirectedGraphPrint(directedGraphStdin);
    // Grafo no direccionado -> imprime nodos y sus adyacentes
    print("Grafo no direccionado: \n");
    try Aux.UndirectedGraphPrint(undirectedGraphStdin);

    ///////////////////////////////////////////////////////////////

    // Grafo direccionado    -> Crea grafo a partir de un .csv
    print("Creando grafo a partir de un .csv: \n");
    try undirectedGraphText.insertFile();
    // Grafo no direccionado -> Crea grafo a partir de un .csv
    print("Creando grafo a partir de un .csv: \n");
    try undirectedGraphText.insertFile();

    // Grafo direccionado    -> imprime nodos y sus adyacentes
    print("Grafo direccionado: \n");
    try Aux.DirectedGraphPrint(directedGraphStdin);
    // Grafo no direccionado -> imprime nodos y sus adyacentes
    print("Grafo no direccionado: \n");
    try Aux.UndirectedGraphPrint(undirectedGraphStdin);
}
