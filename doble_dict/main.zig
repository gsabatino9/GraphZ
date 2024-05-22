const std = @import("std");
const print = std.debug.print;
// const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const NodesMap = std.StringHashMap(AdyMap);
const AdyMap = std.StringHashMap([]const u8);
const stdin = std.io.getStdIn().reader();
// Errores
const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS };
const ReadError = error{BadRead};

// // Nodo struct
// const Node = struct {
//     title: []const u8,
//     ady: AdyMap,
// };

const Graph = struct {
    // allocator: aloja memoria para las estructuras de datos (solo eso)
    allocator: Allocator,
    // nodes_map: mapea nombre del nodo ([]const u8) a su nodo (tipo Node)
    nodes_map: NodesMap,
    // ady_map: mapea los adyacentes del nodo (por ahora: clave = valor = []const u8)
    ady_map: AdyMap,

    // parseo el tipo del grafo asi si le cambio el nombre no se ve impactado en ningun lado más
    const Self = @This();

    // guardo allocator y creo estructuras iniciales pasandole el allocator, solo eso
    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
            .nodes_map = NodesMap.init(allocator),
            .ady_map = AdyMap.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        // en vez de andar loopeando por cada uno de estos,
        // no estaria bueno que cada estructura loopee por si sola
        // y haga el free necesario?
        // HINT: los frees son faciles
        // itero por nodo
        var it = self.nodes_map.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            // itero nodos adyacentes
            var it_node = entry.value_ptr.*.iterator();
            while (it_node.next()) |entry_node| {
                if (entry.value_ptr.*.contains(entry_node.key_ptr.*)) {
                    self.allocator.free(entry_node.key_ptr.*);
                    self.allocator.free(entry_node.value_ptr.*); // linea comentada porque por ahora key = val
                }
            }
            entry.value_ptr.*.deinit();
        }
        self.nodes_map.deinit();
    }

    /// devuelve true en caso de que el nodo exista, false en caso de que no
    pub fn nodeExists(self: *Self, node_label: []const u8) bool {
        return self.nodes_map.contains(node_label);
    }

    /// devuelve true en caso de que el nodo ady exista, false en caso de que no
    pub fn nodeAdyExists(self: *Self, node_label: []const u8, nodeAdy_label: []const u9) bool {
        const map: AdyMap = self.nodes_map.get(node_label);
        return map.contains(nodeAdy_label);
    }

    /// devuelve true en caso de que el eje exista, false en caso de que no
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) GraphError!bool {
        if ((!self.nodeExists(node1)) or (!self.nodeExists(node2))) {
            return GraphError.EDGE_NOT_EXISTS;
        }
        const mapAdy1: AdyMap = self.nodes_map.get(node1) orelse unreachable;
        const mapAdy2: AdyMap = self.nodes_map.get(node2) orelse unreachable;
        return mapAdy1.contains(node2) and mapAdy2.contains(node1);
        // si se desea un grafo con direccion poner solo 1 condicion (MODIFICAR)
    }

    /// devuelve false en caso de no insertar el nodo, true en caso de que si
    pub fn addNode(self: *Self, node_label: []const u8) !bool {
        // TODO: implementar. Los pasos a seguir:
        // 1. ver si el nodo esta en el mapa de nodos, si es asi no hago nada
        // 2. si no esta, tengo que crear sus adyacentes, el codigo va a
        // tener algo como:
        // self.nodes_map.put(node_label, Adjacents.init(allocator));
        if (self.nodeExists(node_label)) {
            return false;
        }
        // const node = Node{
        //     .title = node_label,
        //     .ady = AdyMap.init(self.allocator),
        // };
        try self.nodes_map.put(node_label, self.ady_map);
        return true;
    }

    /// Conecta 2 nodos, devuelve GraphError.NODE_NOT_EXISTS en caso de que alguno de los dos nodos no existan
    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) GraphError!void {
        if ((!self.nodeExists(node1)) or (!self.nodeExists(node2))) {
            return GraphError.NODE_NOT_EXISTS;
        }
        const edge1: bool = try self.edgeExists(node1, node2);
        const edge2: bool = try self.edgeExists(node2, node1);
        if (!edge1) {
            var mapAdy1: AdyMap = self.nodes_map.get(node1) orelse GraphError.EDGE_NOT_EXISTS;
            try mapAdy1.put(node1, node2);
        }
        if (!edge2) {
            var mapAdy2: AdyMap = self.nodes_map.get(node2) orelse GraphError.EDGE_NOT_EXISTS;
            try mapAdy2.put(node2, node1);
        }
        // si se desea un grafo con direccion poner solo 1 arista y no 2 (MODIFICAR)
    }
};

// MAIN - implementación usando doble diccionario

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    // grafo
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();
    // imprimo
    try graph_print(graph.nodes_map);
}

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

pub fn graph_print(graph: NodesMap) !void {
    var it = graph.iterator();
    while (it.next()) |entry| {
        print("Nodo: '{s}' -> ", .{entry.key_ptr.*});
        var it_node = entry.value_ptr.*.iterator();
        while (it_node.next()) |entry_node| {
            print("{s}, ", .{entry_node.key_ptr.*});
        }
        print("\n", .{});
    }
    print("\n", .{});
}
// Test

const testing = std.testing;
test "Test agrego nodos y existen" {
    const allocator = testing.allocator;
    var graph: Graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B");

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("B", "A") == true);
    try testing.expect(graph.edgeExists("A", "C") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);
}
