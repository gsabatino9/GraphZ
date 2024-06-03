const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph = @import("graph.zig").Graph;
const Aux = @import("aux.zig");

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
        const node = Aux.stdInput(allocator, 1) catch {
            break;
        };
        if (!graph.nodeExists(node)) {
            _ = graph.addNode(node);
        }
        while (true) {
            // solicita nodo por stdin
            const aux = Aux.stdInput(allocator, 2) catch {
                break;
            };
            if (!graph.nodeExists(aux)) {
                graph.addNode(aux);
            }
            if (!graph.edgeExists(node, aux)) {
                graph.addEdge(node, aux);
            }
        }
    }
    Aux.graph_print(graph);
}
