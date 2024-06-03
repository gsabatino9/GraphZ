const std = @import("std");
const Node = @import("graph.zig").Node;
const Graph = @import("graph.zig").Graph;
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const NodesMap = std.StringHashMap(Node);
const AdyMap = std.StringHashMap([]const u8);
const stdin = std.io.getStdIn().reader();
// Errores
const ReadError = error{BadRead};

// FUNCIONES AUXILIARES

// toma valor por stdin
pub fn stdInput(allocator: Allocator, is_title: u8) ReadError![]const u8 {
    while (true) {
        // solicita key por stdin
        const key = read_and_own(allocator, is_title) catch {
            break;
        };
        return key;
    }
}

pub fn read_and_own(allocator: Allocator, is_title: u8) ReadError![]const u8 {
    var buf: [30]u8 = undefined;
    switch (is_title) {
        1 => print("Ingresar titulo del nodo: ", .{}),
        2 => print("Ingresar titulo del nodo adyacente: ", .{}),
        else => unreachable,
    }
    const key: ?[]u8 = stdin.readUntilDelimiterOrEof(&buf, '\n') catch null;
    if (key == null) {
        return ReadError.BadRead;
    } else {
        if (key.?.len == 0) {
            return ReadError.BadRead;
        }
        const owned_label = allocator.dupe(u8, key.?) catch null;
        if (owned_label == null) {
            return ReadError.BadRead;
        } else {
            return owned_label.?;
        }
    }
}

// imprime el grafico
pub fn graph_print(graph: Graph) !void {
    var it = graph.nodes_map.iterator();
    while (it.next()) |entry| {
        print("Nodo: '{s}' Adyacentes: ", .{entry.key_ptr.*});
        var it_node = entry.value_ptr.*.ady_map.iterator();
        while (it_node.next()) |entry_node| {
            print("{s}, ", .{entry_node.key_ptr.*});
        }
        print("\n", .{});
    }
    print("\n", .{});
}
