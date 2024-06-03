const std = @import("std");
const Queue = @import("tdas/Queue.zig").Queue;
const Aux = @import("aux.zig");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const NodesMap = std.StringHashMap(Node);
const AdyMap = std.StringHashMap([]const u8);
const DadMap = std.StringHashMap(?[]const u8);
const OrderMap = std.StringHashMap(u8);
const VisitedMap = std.StringHashMap([]const u8);
const stdin = std.io.getStdIn().reader();
// Errores
const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS };
const ReadError = error{BadRead};

pub const Node = struct {
    allocator: Allocator,
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
    allocator: Allocator,
    nodes_map: NodesMap,

    const Self = @This();

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

    // Devuelve el diccionario de adyacentes del nodo
    pub fn getAdy(self: *Self, string: []const u8) AdyMap {
        const node: Node = self.nodes_map.get(string) orelse unreachable;
        return node.ady_map;
    }

    // recorrido BFS - Complejidad -> O(V+E)
    pub fn bfs(self: *Self, A: []const u8, B: []const u8) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        var dads: DadMap = DadMap.init(allocator);
        var order: OrderMap = OrderMap.init(allocator);
        var visited: VisitedMap = VisitedMap.init(allocator);
        var queue = Queue([]const u8).init(allocator);
        defer dads.deinit();
        defer order.deinit();
        defer visited.deinit();

        try dads.put(A, null);
        try order.put(A, 0);
        try visited.put(A, A);
        try queue.enqueue(A);
        while (true) {
            const node: []const u8 = queue.dequeue() orelse break;
            // se llega a destino
            if (std.mem.eql(u8, node, B)) {
                break;
            }
            const ady_map: AdyMap = self.getAdy(node);
            var it_ady = ady_map.iterator();
            while (it_ady.next()) |entry_node| {
                const ady = entry_node.key_ptr.*;
                if (!visited.contains(ady)) {
                    try dads.put(ady, node);
                    const order_node: u8 = order.get(node) orelse unreachable;
                    try order.put(ady, order_node + 1);
                    try visited.put(ady, ady);
                    try queue.enqueue(ady);
                }
            }
        }
        if (dads.get(B) == null) {
            print("No hay camino posible \n", .{});
        }
        print("Camino ", .{});
        try Aux.printdads(dads, B);
        print(" -> {s}", .{B});
        print("\n", .{});
    }
};
