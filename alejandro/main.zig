const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const Graph = @import("graph.zig").Graph;


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
        print("linea {s}\n", .{line});
    }

    print("Todo excelente\n", .{});
    
}
