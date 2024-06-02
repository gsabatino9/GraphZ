const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
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

        const nodo1_aux = allocator.dupe(u8, nodo1) catch {
        return ReadError.BadRead;
        };
        const nodo2_aux = allocator.dupe(u8, nodo2) catch {
            return ReadError.BadRead;
        };

        _ = try graph.addNode(nodo1_aux);
        _ = try graph.addNode(nodo2_aux);
        _ = try graph.addEdge(nodo1_aux, nodo2_aux);

        //print("nodo 1 {s}, nodo 2 {s},\n",.{nodo1, nodo2});
     

    }
    graph.printG();
    print("tamano = {}\n",.{graph.countNodes()});
    print("tamano = {}\n",.{graph.countEdges()});
}



const testing = std.testing;
test "Test creo un grafo con un archivo vacio\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator);
    defer graph.deinit();

    var file = try std.fs.cwd().openFile("vacio.txt", .{});
    defer file.close();

    try testing.expect(graph.countNodes() == 0);
    try testing.expect(graph.countEdges() == 0);
 
}


test "Test creo un grafo con un archivo normal\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator);
    defer graph.deinit();

    var file = try std.fs.cwd().openFile("grafo.txt", .{});
    defer file.close();

    //try testing.expect(graph.countNodes() == 7);
    //try testing.expect(graph.countEdges() == 6);
 
}