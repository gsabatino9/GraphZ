const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Graph = @import("graph.zig").Graph;
const ReadError = error{BadRead};

pub fn main() !void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var graph = try crearGrafo(allocator, "grafo.txt");
    defer graph.deinit();

    
    graph.printG();
    print("tamano = {}\n",.{graph.countNodes()});
    print("tamano = {}\n",.{graph.countEdges()});
}

//corregir lo del nombre de archivo
pub fn crearGrafo(allocator: Allocator, nombre_archivo: *const [9:0]u8) !Graph{ 

    var graph = Graph.init(allocator);
    const archivo = nombre_archivo;

    var file = try std.fs.cwd().openFile(archivo, .{});
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
        const nodo1_aux = nodo1_next.?;

        const nodo2_next = splits.next();
        if (nodo2_next == null) {
            return ReadError.BadRead;
        }
        const nodo2_aux = nodo2_next.?;

        const nodo1 = allocator.dupe(u8, nodo1_aux) catch {
                return ReadError.BadRead;
            };
        

        
        const nodo2 = allocator.dupe(u8, nodo2_aux) catch {
            return ReadError.BadRead;
        };

        const bool_nodo1 = graph.contains(nodo1);
        const bool_nodo2 = graph.contains(nodo2);
        

        _ = try graph.addNode(nodo1);
        _ = try graph.addNode(nodo2);
        _ = try graph.addEdge(nodo1, nodo2);

        if (bool_nodo1) allocator.free(nodo1);
        if (bool_nodo2) allocator.free(nodo2);
        
        //print("nodo 1 {s}, nodo 2 {s},\n",.{nodo1, nodo2});
    }
    return graph;
}



const testing = std.testing;
test "Test creo un grafo con un archivo vacio\n" {
    const allocator = testing.allocator;
    var graph = try crearGrafo(allocator, "vacio.txt");
    defer graph.deinit();

    try testing.expect(graph.countNodes() == 0);
    try testing.expect(graph.countEdges() == 0);
 
}


test "Test creo un grafo con un archivo normal\n" {
    const allocator = testing.allocator;
    var graph = try crearGrafo(allocator, "grafo.txt");
    defer graph.deinit();

    try testing.expect(graph.countNodes() == 7);
    try testing.expect(graph.countEdges() == 6);

    try testing.expect(graph.edgeExists("A","B") == true);
    try testing.expect(graph.edgeExists("H","Z") == true);
    try testing.expect(graph.edgeExists("C","B") == true);
    try testing.expect(graph.edgeExists("A","C") == true);
    try testing.expect(graph.edgeExists("A","B") == true);
    try testing.expect(graph.edgeExists("G","B") == true);
    try testing.expect(graph.edgeExists("C","D") == true);
    
    const tam = graph.countNodes();

    for (0..tam) |_|{
        const label = try graph.borrarNodo();
        allocator.free(label);
    }
}