const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Graph = @import("graph.zig").Graph;
const Tuple = std.meta.Tuple;
const SomeTuple = Tuple(&.{ArrayList([]const u8), Graph});

const ReadError = error{BadRead};

const random_gen = std.rand.DefaultPrng;
pub fn loop_graph(allocator: Allocator) !void {
    var rnd = random_gen.init(0);
    var graph = Graph.init(allocator, false);
    defer graph.deinit();

    for (0..10000) |_| {
        const rand_num = rnd.random().int(i32);
        const max_len = 20;
        var buf: [max_len]u8 = undefined;
        const label = try std.fmt.bufPrint(&buf, "{}", .{rand_num});
        //print("label = {s}, iteracion numero {}\n",.{label, i});
        _ = try graph.addNode(label);
    }//841629273 -841629273� -84162927 -84162 -8416292 -841629 
    graph.printG();
    print("tamano del segundo grafo = {}\n",.{graph.countNodes()});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const tupla = try crearGrafo(allocator, "grafo.csv");
    //const tupla = try crearGrafo(allocator, "vacio.txt");
    var graph = tupla[1];
    var valores = tupla[0];
        
    defer graph.deinit();
    defer valores.deinit();

    graph.printG();
    print("tamano = {}\n",.{graph.countNodes()});
    print("tamano = {}\n",.{graph.countEdges()});

    for (valores.items) |item| {
        allocator.free(item);
    }
    //try loop_graph(allocator);
}

pub fn mainq() !void{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    
    var valores = ArrayList([]const u8).init(allocator);

    _ = try valores.append("A");
    _ = try valores.append("B");
    _ = try valores.append("C");
    _ = try valores.append("D");

    print("hola mundo {s}\n",.{valores.items});
    valores.deinit();
    

}
pub fn crearGrafo(allocator: Allocator, nombre_archivo: []const u8) !SomeTuple{ 

    var valores = ArrayList([]const u8).init(allocator);
    
    var graph = Graph.init(allocator, false);
    const archivo = nombre_archivo;

    var file = try std.fs.cwd().openFile(archivo, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    //The std.io.bufferedReader isn’t mandatory but recommended for better performance.

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        
        var splits = std.mem.split(u8, line, ",");
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

        if (bool_nodo1) {
            allocator.free(nodo1);
        }
        else{
            _ = try valores.append(nodo1);
        }
        
        if (bool_nodo2) {
            allocator.free(nodo2);
        }
        else{
            _ = try valores.append(nodo2);
        }
    }
    return .{
        @as(ArrayList([]const u8), valores),
        @as(Graph, graph),
    };
}


const testing = std.testing;
test "Test creo un grafo con un archivo vacio\n" {
    const allocator = testing.allocator;
    const tupla = try crearGrafo(allocator, "vacio.txt");
    var graph = tupla[1];
    var valores = tupla[0];
        
    defer graph.deinit();
    defer valores.deinit();

    try testing.expect(graph.countNodes() == 0);
    try testing.expect(graph.countEdges() == 0);

    for (valores.items) |item| {
        allocator.free(item);
    }
}

test "Test creo un grafo con un archivo txt normal\n" {
    const allocator = testing.allocator;
    const tupla = try crearGrafo(allocator, "grafo.txt");
    
    var graph = tupla[1];
    var valores = tupla[0];
        
    defer graph.deinit();
    defer valores.deinit();

    try testing.expect(graph.countNodes() == 7);
    try testing.expect(graph.countEdges() == 6);

    try testing.expect(graph.edgeExists("A","B") == true);
    try testing.expect(graph.edgeExists("H","Z") == true);
    try testing.expect(graph.edgeExists("C","B") == true);
    try testing.expect(graph.edgeExists("A","C") == true);
    try testing.expect(graph.edgeExists("A","B") == true);
    try testing.expect(graph.edgeExists("G","B") == true);
    try testing.expect(graph.edgeExists("C","D") == true);
    
    for (valores.items) |item| {
        allocator.free(item);
    }
}


test "Test creo un grafo con un archivo csv normal\n" {
    const allocator = testing.allocator;
    const tupla = try crearGrafo(allocator, "grafo.csv");
    
    var graph = tupla[1];
    var valores = tupla[0];
        
    defer graph.deinit();
    defer valores.deinit();


    try testing.expect(graph.countNodes() == 5);
    try testing.expect(graph.countEdges() == 4);

    try testing.expect(graph.edgeExists("A","B") == true);
    try testing.expect(graph.edgeExists("C","B") == true);
    try testing.expect(graph.edgeExists("A","C") == true);
    try testing.expect(graph.edgeExists("G","E") == true);
    
    for (valores.items) |item| {
        allocator.free(item);
    }
}