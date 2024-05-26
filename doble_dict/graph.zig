const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const NodesMap = std.StringHashMap(Node);
const AdyMap = std.StringHashMap([]const u8);
const stdin = std.io.getStdIn().reader();
// Errores
const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS };
const ReadError = error{BadRead};

const Node = struct {

    // ady_map: mapea los adyacentes del nodo (por ahora: clave = valor = []const u8)
    ady_map: AdyMap,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .ady_map = AdyMap.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.ady_map.deinit();
    }

    // devuelve false en caso de no insertar el ady, true en caso de que si
    pub fn addAdy(self: *Self, node_label: []const u8) !bool {
        if (self.ady_map.contains(node_label)) {
            return false;
        }
        try self.ady_map.put(node_label, node_label);
        return true;
    }
};

pub const Graph = struct {
    // allocator: aloja memoria para las estructuras de datos (solo eso)
    allocator: Allocator,
    // nodes_map: mapea nombre del nodo ([]const u8) a su nodo (tipo Node)
    nodes_map: NodesMap,

    // parseo el tipo del grafo asi si le cambio el nombre no se ve impactado en ningun lado más
    const Self = @This();

    // guardo allocator y creo estructuras iniciales pasandole el allocator, solo eso
    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
            .nodes_map = NodesMap.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.nodes_map.iterator();
        while (it.next()) |entry| {
            var nodo: Node = entry.value_ptr.*;
            // self.allocator.free(entry.key_ptr.*);
            nodo.deinit();
            // self.allocator.free(entry.value_ptr.*);
        }
        self.nodes_map.deinit();
    }

    /// devuelve true en caso de que el nodo exista, false en caso de que no
    pub fn nodeExists(self: *Self, node_label: []const u8) bool {
        return self.nodes_map.contains(node_label);
    }

    /// devuelve true en caso de que el nodo ady exista, false en caso de que no
    pub fn nodeAdyExists(self: *Self, node_label: []const u8, nodeAdy_label: []const u9) bool {
        const node: Node = self.nodes_map.get(node_label);
        const map: AdyMap = node.ady_map;
        return map.contains(nodeAdy_label);
    }

    /// devuelve true en caso de que el eje exista, false en caso de que no
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) GraphError!bool {
        if ((!self.nodeExists(node1)) or (!self.nodeExists(node2))) {
            return GraphError.EDGE_NOT_EXISTS;
        }
        const node_1: Node = self.nodes_map.get(node1) orelse unreachable;
        const mapAdy1: AdyMap = node_1.ady_map;

        const node_2: Node = self.nodes_map.get(node2) orelse unreachable;
        const mapAdy2: AdyMap = node_2.ady_map;

        return mapAdy1.contains(node2) and mapAdy2.contains(node1);
        // si se desea un grafo con direccion poner solo 1 condicion (MODIFICAR)
    }

    /// devuelve false en caso de no insertar el nodo, true en caso de que si
    pub fn addNode(self: *Self, node_label: []const u8) !bool {
        if (self.nodeExists(node_label)) {
            return false;
        }
        try self.nodes_map.put(node_label, Node.init(self.allocator));
        return true;
    }

    /// Conecta 2 nodos, devuelve GraphError.NODE_NOT_EXISTS en caso de que alguno de los dos nodos no existan
    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) GraphError!void {
        var node_1: Node = self.nodes_map.get(node1) orelse return GraphError.NODE_NOT_EXISTS;
        try node_1.addAdy(node2) orelse return GraphError.NODE_NOT_EXISTS;
        var node_2: Node = self.nodes_map.get(node2) orelse return GraphError.NODE_NOT_EXISTS;
        try node_2.addAdy(node1) orelse return GraphError.NODE_NOT_EXISTS;
        return;
        // si se desea un grafo con direccion poner solo 1 arista y no 2 (MODIFICAR)
    }
};

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
    _ = try graph.addEdge("B", "A");

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("B", "A") == true);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.edgeExists("A", "C") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);
}
