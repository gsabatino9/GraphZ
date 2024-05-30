const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph = @import("graph.zig").Graph;

// MAIN - implementación usando doble diccionario

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    // grafo
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();
}
