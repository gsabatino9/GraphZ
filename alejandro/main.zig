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
        const nodo1 = nodo1_next.?;

        const nodo2_next = splits.next();
        if (nodo2_next == null) {
            return ReadError.BadRead;
        }
        const nodo2 = nodo2_next.?;

        const nodo1_aux = allocator.dupe(u8, nodo1) catch {
                return ReadError.BadRead;
            };
        

        
        const nodo2_aux = allocator.dupe(u8, nodo2) catch {
            return ReadError.BadRead;
        };

        const bool_nodo1 = graph.contains(nodo1_aux);
        const bool_nodo2 = graph.contains(nodo2_aux);
        

        _ = try graph.addNode(nodo1_aux);
        _ = try graph.addNode(nodo2_aux);
        _ = try graph.addEdge(nodo1_aux, nodo2_aux);

        if (bool_nodo1) allocator.free(nodo1_aux);
        if (bool_nodo2) allocator.free(nodo2_aux);
        
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

    const tam = graph.countNodes();

    for (0..tam) |_|{
        const label = try graph.borrarNodo();
        print("el label es : {s}\n",.{label});
        allocator.free(label);
    }
}