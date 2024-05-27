const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph = @import("graph.zig").Graph;


// implementación usando matriz de adyacencias
pub fn main() !void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var graph = Graph.init(allocator);
    defer graph.deinit();

    print("GraphZ\n", .{});
    print("{any}\n", .{graph});
}
