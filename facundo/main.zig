const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph = @import("directed_graph.zig").Graph;
const Aux = @import("aux.zig");
const ReadError = error{BadRead};

// MAIN - implementación usando doble diccionario

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    // grafo
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();

    // solicita por stdin nodos y sus adyacentes y los inserta
    try graph.insertStdin(allocator);

    // imprime nodos y sus adyacentes
    try Aux.graph_print(graph);
}
