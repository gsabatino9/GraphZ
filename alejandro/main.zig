const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph = @import("graph.zig").Graph;

const ReadError = error{BadRead};

pub fn main() !void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var graph = Graph.init(allocator);
    defer graph.deinit();

    var file = try std.fs.cwd().openFile("grafo.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    //The std.io.bufferedReader isn’t mandatory but recommended for better performance.

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        
        var splits = std.mem.split(u8, line, "-");
        const nodo1_next = splits.next();
        if (nodo1_next == null) {
            return ReadError.BadRead;
        }
        const nodo1 = nodo1_next.?;

        const nodo2_next = splits.next();
        if (nodo2_next == null) {
            return ReadError.BadRead;
        }
        const nodo2 = nodo2_next.?;

        
        const v1 = try graph.addNode(nodo1);
        const v2 = try graph.addNode(nodo2);
        const v3 = try graph.addEdge(nodo1, nodo2);
        print("nodo 1 {s}, nodo 2 {s}, {} {} {}\n",.{nodo1, nodo2, v1, v2, v3});
    
        //try agregarNodos(&graph, line);
        //print("Grafo: {any},\n", .{graph.nodes_map.items});
    }
    graph.printG();
    const a1 = graph.nodeExists("A");
    const a2 = graph.nodeExists("B");
    const a3 = graph.nodeExists("C");
    const a4 = graph.nodeExists("H");
    const a5 = graph.nodeExists("Z");
    
    print(" {} {} {} {} {}\n",.{ a1, a2, a3, a4, a5});
    
    const e1 = graph.edgeExists("H", "Z");
    const e2 = graph.edgeExists("Z", "H");

    const e3 = graph.edgeExists("A", "B");

    
    print(" {} {} {}\n",.{ e1, e2, e3});
    
    
    //print("Grafo: {any},\n", .{graph.nodes_map.items});
}

pub fn agregarNodos(grafo: *Graph, linea: []u8) !void {
    var splits = std.mem.split(u8, linea, "-");

    const nodo1_next = splits.next();
    if (nodo1_next == null) {
        return ReadError.BadRead;
    }
    const nodo1 = nodo1_next.?;

    const nodo2_next = splits.next();
    if (nodo2_next == null) {
        return ReadError.BadRead;
    }
    const nodo2 = nodo2_next.?;

    var graph = grafo;
    const v1 = try graph.addNode(nodo1);
    const v2 = try graph.addNode(nodo2);
    const v3 = try graph.addEdge(nodo1, nodo2);
    
    print("nodo 1 {s}, nodo 2 {s}, {} {} {}\n",.{nodo1, nodo2, v1, v2, v3});
    //return graph;
}