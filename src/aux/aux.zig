const std = @import("std");
const graph = @import("graph.zig");
const print = std.debug.print;
const get_relation = @import("utils.zig").get_relation;

pub fn main() !void {
    const Graph = graph.DirectedGraph([]const u8, std.hash_map.StringContext);

    // Initialize using some allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var g = Graph.init(allocator);
    defer g.deinit();

    var i: u32 = 0;
    while (i < 5) : (i += 1) {
        const rel = try get_relation(allocator);
        const key = rel[0];
        const value = rel[1];

        try g.add(key);
        try g.add(value);

        try g.addEdge(key, value, 5);
    }

    const count_vertices = g.countVertices();
    const count_edges = g.countEdges();
    print("{}\n", .{count_vertices});
    print("{}\n", .{count_edges});

    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit();

    var it = try g.dfsIterator("a");
    defer it.deinit();

    while (try it.next()) |item| {
        try list.append(g.lookup(item).?);
    }

    for (list.items) |item| {
        print("{s}\n", .{item});
    }

    for (list.items) |item| {
        allocator.free(item);
    }
}

pub fn main_aux() !void {
    // Create a directed graph type for strings.
    const Graph = graph.DirectedGraph([]const u8, std.hash_map.StringContext);

    // Initialize using some allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var g = Graph.init(allocator);
    defer g.deinit();

    print("{any}\n", .{g.ctx});

    // Add some vertices

    try g.add("A");
    try g.add("B");
    try g.add("C");
    try g.add("D");
    try g.add("E");
    try g.add("F");

    // Add some edges with weights. For unweighted edges just make all
    // weights the same value.
    try g.addEdge("A", "B", 5);
    try g.addEdge("B", "C", 5);
    try g.addEdge("B", "D", 5);
    try g.addEdge("C", "E", 5);
    try g.addEdge("E", "F", 5);

    const count_vertices = g.countVertices();
    const count_edges = g.countEdges();
    print("{}\n", .{count_vertices});
    print("{}\n", .{count_edges});

    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit();

    var it = try g.dfsIterator("A");
    defer it.deinit();

    while (try it.next()) |item| {
        try list.append(g.lookup(item).?);
    }

    for (list.items) |item| {
        print("{s}\n", .{item});
    }
}
