const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const get_relation = @import("utils.zig").get_relation;
const Graph = @import("graph.zig").Graph;

pub fn loop_add_relations(allocator: Allocator) !void {
    var graph = Graph.init(allocator);
    defer graph.deinit();
    var list_inserted = std.ArrayList([]const u8).init(allocator);
    defer list_inserted.deinit();

    while (true) {
        const relation = get_relation(allocator) catch {
            break;
        };
        const source = relation[0];
        const target = relation[1];

        const s_added = try graph.addNode(source);
        const t_added = try graph.addNode(target);

        try graph.addEdge(source, target);

        if (!s_added) {
            allocator.free(source);
        } else {
            try list_inserted.append(source);
        }
        if (!t_added) {
            allocator.free(target);
        } else {
            try list_inserted.append(target);
        }
    }

    print("{}\n", .{graph.countNodes()});
    print("{}\n", .{graph.countEdges()});

    for (list_inserted.items) |item| {
        allocator.free(item);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try loop_add_relations(allocator);
}

const testing = std.testing;
test "Test io" {
    const allocator = testing.allocator;
    try loop_add_relations(allocator);
}
