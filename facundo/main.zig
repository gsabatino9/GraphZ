const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph = @import("graph.zig").Graph;
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
    while (true) {
        // solicita nodo por stdin
        const node = Aux.read_and_own(allocator, 1) catch {
            break;
        };
        if (!graph.nodeExists(node)) {
            _ = graph.addNode(node) catch false;
        }
        while (true) {
            // solicita ady por stdin
            const aux = Aux.read_and_own(allocator, 2) catch {
                break;
            };
            if (!graph.nodeExists(aux)) {
                _ = graph.addNode(aux) catch false;
            }
            if (!graph.edgeExists(node, aux)) {
                _ = graph.addEdge(node, aux) catch false;
            }
        }
    }

    // imprime nodos y sus adyacentes
    try Aux.graph_print(graph);
}
