const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const NodesMap = std.StringHashMap(Node);
const AdyMap = std.StringHashMap([]const u8);
const stdin = std.io.getStdIn().reader();
// Errores
const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS };
const ReadError = error{BadRead};

pub const Node = struct {
    allocator: Allocator,
    // ady_map: mapea los adyacentes del nodo (por ahora: clave = valor = []const u8)
    ady_map: AdyMap,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
            .ady_map = AdyMap.init(allocator),
        };
    }

    pub fn deinitAdy(self: *Self) void {
        self.ady_map.deinit();
    }

    pub fn deinit(self: *Self, allocator: Allocator) void {
        var it = self.ady_map.iterator();
        while (it.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            allocator.free(entry.value_ptr.*);
        }
        self.ady_map.deinit();
    }

    // devuelve false en caso de no estar el ady, true en caso de que si
    pub fn adyExist(self: *Self, node_label: []const u8) bool {
        return self.ady_map.contains(node_label);
    }

    // devuelve false en caso de no insertar el ady, true en caso de que si
    pub fn addAdy(self: *Self, node_label: []const u8) !void {
        if (!self.adyExist(node_label)) {
            try self.ady_map.put(node_label, node_label);
        }
    }

    // devuelve false en caso de no borrar el ady, true en caso de que si (si ady no existe envia true)
    pub fn removeAdy(self: *Self, node_label: []const u8) bool {
        if (!self.adyExist(node_label)) {
            return self.ady_map.remove(node_label);
        }
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
        var it = self.nodes_map.valueIterator();
        while (it.next()) |map| {
            map.deinitAdy();
        }
        self.nodes_map.deinit();
    }

    /// devuelve true en caso de que el nodo exista, false en caso de que no
    pub fn nodeExists(self: *Self, node_label: []const u8) bool {
        return self.nodes_map.contains(node_label);
    }

    /// devuelve true en caso de que el nodo ady exista, false en caso de que no
    pub fn nodeAdyExists(self: *Self, node_label: []const u8, nodeAdy_label: []const u8) bool {
        const node: Node = self.nodes_map.get(node_label) orelse unreachable;
        const map: AdyMap = node.ady_map;
        return map.contains(nodeAdy_label);
    }

    /// devuelve true en caso de que el eje exista, false en caso de que no
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
        if ((!self.nodeExists(node1) or !self.nodeExists(node2))) {
            if (self.nodeExists(node1) and !self.nodeExists(node2)) {
                var node_1: Node = self.nodes_map.get(node1) orelse unreachable;
                _ = node_1.removeAdy(node2);
            }
            if (!self.nodeExists(node1) and self.nodeExists(node2)) {
                var node_2: Node = self.nodes_map.get(node2) orelse unreachable;
                _ = node_2.removeAdy(node1);
            }
            return false;
        } else {
            return self.nodeAdyExists(node1, node2);
        }
    }

    /// devuelve false en caso de no insertar el nodo, true en caso de que si
    pub fn addNode(self: *Self, node_label: []const u8) !bool {
        if (self.nodeExists(node_label)) {
            return false;
        }
        const node: Node = Node.init(self.allocator);
        try self.nodes_map.put(node_label, node);
        return true;
    }

    /// Conecta 2 nodos, devuelve GraphError.NODE_NOT_EXISTS en caso de que alguno de los dos nodos no existan
    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) !void {
        if (!self.edgeExists(node1, node2)) {
            var node_1 = self.nodes_map.getPtr(node1) orelse unreachable;
            try node_1.addAdy(node2);
        }
    }

    /// Borra el nodo correspondiente con sus adyacentes (las aristas dirigidas al nodo permanecen hasta que se llame la funcion edgeExist)
    /// devuelve true si borra, false si no
    pub fn removeNode(self: *Self, node1: []const u8) bool {
        if (self.nodeExists(node1)) {
            var node: Node = self.nodes_map.get(node1) orelse unreachable;
            node.ady_map.clearAndFree();
            return self.nodes_map.remove(node1);
        }
        return false;
    }

    /// Borra la arista correspondiente. false si no lo borra, true si borra o no existe el ady
    pub fn removeEdge(self: *Self, node1: []const u8, node2: []const u8) !bool {
        if (self.edgeExists(node1, node2)) {
            var node_1: Node = self.nodes_map.get(node1) orelse unreachable;
            return try node_1.removeAdy(node2);
        }
        return true;
    }
};
