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
    // test
    const A: []const u8 = "A";
    const B: []const u8 = "B";

    const A_bool = try graph.addNode(A);
    if (A_bool) {
        print("A insertado", .{});
    }
    if (graph.nodeExists(A)) {
        print("A guardado", .{});
    }

    const B_bool = try graph.addNode(B);
    if (B_bool) {
        print("B insertado", .{});
    }
    if (graph.nodeExists(B)) {
        print("B guardado", .{});
    }
}
