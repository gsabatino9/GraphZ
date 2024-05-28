const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph = @import("graph.zig").Graph;

const ReadError = error{BadRead};

// implementación usando matriz de adyacencias
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
        try crearGrafo(line);
        //print("linea {s}\n", .{line});
    }

    print("Todo excelente\n", .{});
    
}

pub fn crearGrafo( linea: []u8) !void { //grafo: Graph,

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


    print("nodo 1 {s}, nodo 2 {s}\n",.{nodo1, nodo2});

}