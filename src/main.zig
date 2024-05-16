const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const get_relation = @import("utils.zig").get_relation;
const Graph = @import("graph.zig").Graph;

pub fn loop_add_relations(allocator: Allocator) !void {
    var graph = Graph.init(allocator);
    defer graph.deinit();

    while (true) {
        const relation = get_relation(allocator) catch {
            break;
        };
        const source = relation[0];
        const target = relation[1];

        graph.add_relation_release_memory(source, target) catch {
            break;
        };
    }

    graph.print_relations();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try loop_add_relations(allocator);
}
