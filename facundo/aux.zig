const std = @import("std");
const stdin = std.io.getStdIn().reader();
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const AdyMap = std.StringHashMap([]const u8);
const DadMap = std.StringHashMap(?[]const u8);
const DirectedNodesMap = std.StringHashMap(DirectedNode);
const DirectedGraph = @import("directed_graph.zig").Graph;
const DirectedNode = @import("directed_graph.zig").Node;
const UndirectedNodesMap = std.StringHashMap(UndirectedNode);
const UndirectedGraph = @import("undirected_graph.zig").Graph;
const UndirectedNode = @import("undirected_graph.zig").Node;
// Errores
const ReadError = error{BadRead};

// FUNCIONES AUXILIARES

// toma valor por stdin
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

// imprime los nodos de un grafo direccionado con sus respectivos adyacentes
pub fn DirectedGraphPrint(graph: DirectedGraph) !void {
    print("\n", .{});
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

// imprime los nodos de un grafo no direccionado con sus respectivos adyacentes
pub fn UndirectedGraphPrint(graph: UndirectedGraph) !void {
    print("\n", .{});
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

// imprime recursivamente todos los nodos del camino menos la ultima
pub fn printDads(dads: DadMap, B: []const u8) !void {
    print("Camino ", .{});
    try printDads_(dads, B);
    print(" -> {s}", .{B});
    print("\n", .{});
}
fn printDads_(dads: DadMap, B: []const u8) !void {
    const dadB: ?[]const u8 = dads.get(B).?;
    if (dadB == null) {
        return;
    }
    try printDads_(dads, dadB.?);
    print("-> {s}", .{dadB.?});
}

//////////////////////////////////////////////////////////////////////////////////////
// BORRADOR
//
//    while (true) {
//        // solicita nodo por stdin
//        const node = Aux.read_and_own(allocator, 1) catch {
//            break;
//        };
//        if (!graph.nodeExists(node)) {
//            _ = graph.addNode(node) catch false;
//        }
//        while (true) {
//            // solicita ady por stdin
//            const aux = Aux.read_and_own(allocator, 2) catch {
//                break;
//            };
//            if (!graph.nodeExists(aux)) {
//                _ = graph.addNode(aux) catch false;
//            }
//            if (!graph.edgeExists(node, aux)) {
//                _ = graph.addEdge(node, aux) catch false;
//            }
//        }
//    }
