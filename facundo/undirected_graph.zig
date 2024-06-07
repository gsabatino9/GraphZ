const std = @import("std");
const stdin = std.io.getStdIn().reader();
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const NodesMap = std.StringHashMap(Node);
const AdyMap = std.StringHashMap([]const u8);
const Queue = @import("tdas/queue.zig").Queue;
const DadMap = std.StringHashMap(?[]const u8);
const OrderMap = std.StringHashMap(u8);
const VisitedMap = std.StringHashMap([]const u8);
const Aux = @import("aux.zig");

// Errores
const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS };
const ReadError = error{BadRead};

pub const Node = struct {
    allocator: Allocator,
    ady_map: AdyMap,
    adyNumber: u8,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
            .ady_map = AdyMap.init(allocator),
            .adyNumber = 0,
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
    pub fn adyExist(self: *Self, node: []const u8) bool {
        return self.ady_map.contains(node);
    }

    // devuelve false en caso de no insertar el ady, true en caso de que si
    pub fn addAdy(self: *Self, node_label: []const u8) !void {
        if (!self.adyExist(node_label)) {
            try self.ady_map.put(node_label, node_label);
            self.adyNumber = self.adyNumber + 1;
        }
    }

    // devuelve false en caso de no borrar el ady, true en caso de que si (si ady no existe envia true)
    pub fn removeAdy(self: *Self, node_label: []const u8) bool {
        if (self.adyExist(node_label)) {
            self.adyNumber = self.adyNumber - 1;
            return self.ady_map.remove(node_label);
        }
        return true;
    }

    // devuelve la cantidad de adyacentes del nodo
    pub fn getAdyNumber(self: *Self) u8 {
        return self.adyNumber;
    }
};

pub const Graph = struct {
    allocator: Allocator,
    nodes_map: NodesMap,
    nodeNumber: u8,
    edgeNumber: u8,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
            .nodes_map = NodesMap.init(allocator),
            .nodeNumber = 0,
            .edgeNumber = 0,
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
    pub fn nodeAdyExists(self: *Self, node1: []const u8, node2: []const u8) bool {
        const node = self.nodes_map.getPtr(node1) orelse unreachable;
        return node.adyExist(node2);
    }

    /// devuelve true en caso de que el eje exista, false en caso de que no
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
        if (self.nodeExists(node1) and self.nodeExists(node2)) {
            return self.nodeAdyExists(node1, node2) and self.nodeAdyExists(node2, node1);
        }
        return false;
    }

    /// devuelve false en caso de no insertar el nodo, true en caso de que si
    pub fn addNode(self: *Self, node_label: []const u8) !bool {
        if (self.nodeExists(node_label)) {
            return false;
        }
        const node: Node = Node.init(self.allocator);
        try self.nodes_map.put(node_label, node);
        self.nodeNumber = self.nodeNumber + 1;
        return true;
    }

    /// Conecta 2 nodos, devuelve GraphError.NODE_NOT_EXISTS en caso de que alguno de los dos nodos no existan
    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) !void {
        if (!self.edgeExists(node1, node2)) {
            var node_1 = self.nodes_map.getPtr(node1) orelse unreachable;
            var node_2 = self.nodes_map.getPtr(node2) orelse unreachable;
            if (std.mem.eql(u8, node1, node2)) {
                self.edgeNumber = self.edgeNumber + 1;
                try node_1.addAdy(node2);
            } else {
                self.edgeNumber = self.edgeNumber + 2;
                try node_1.addAdy(node2);
                try node_2.addAdy(node1);
            }
        }
    }

    /// Borra el nodo correspondiente con sus adyacentes (las aristas dirigidas al nodo permanecen hasta que se llame la funcion edgeExist)
    /// devuelve true si borra, false si no
    pub fn removeNode(self: *Self, node1: []const u8) bool {
        if (self.nodeExists(node1)) {
            var node: Node = self.nodes_map.get(node1) orelse unreachable;
            defer node.ady_map.clearAndFree();
            self.nodeNumber = self.nodeNumber - 1;
            // itero por los nodos para borrarlo de sus adyacentes -> O(V)
            var it_nodes = self.nodes_map.iterator();
            while (it_nodes.next()) |entry_node| {
                const node2: []const u8 = entry_node.key_ptr.*;
                _ = self.removeEdge(node1, node2);
            }
            return self.nodes_map.remove(node1);
        }
        return false;
    }

    /// Borra la arista correspondiente. false si no lo borra, true si borra o no existe el ady
    pub fn removeEdge(self: *Self, node1: []const u8, node2: []const u8) bool {
        if (self.edgeExists(node1, node2)) {
            var node_1: Node = self.nodes_map.get(node1) orelse unreachable;
            var node_2: Node = self.nodes_map.get(node2) orelse unreachable;
            if (std.mem.eql(u8, node1, node2)) {
                self.edgeNumber = self.edgeNumber - 1;
                return node_1.removeAdy(node2);
            } else {
                self.edgeNumber = self.edgeNumber - 2;
                const removedAdy1 = node_1.removeAdy(node2);
                const removedAdy2 = node_2.removeAdy(node1);
                return removedAdy1 and removedAdy2;
            }
        }
        return true;
    }

    // Devuelve el diccionario de adyacentes del nodo
    pub fn getAdy(self: *Self, string: []const u8) AdyMap {
        const node: Node = self.nodes_map.get(string) orelse unreachable;
        return node.ady_map;
    }

    // Devuelve la cantidad de nodos del grafo -> O(n)
    pub fn getEdgeNumber(self: *Self) u8 {
        return self.edgeNumber;
    }

    // Devuelve la cantidad de nodos del grafo
    pub fn getNodeNumber(self: *Self) u8 {
        return self.nodeNumber;
    }

    pub fn getAdyNumber(self: *Self, node: []const u8) u8 {
        var node_ = self.nodes_map.getPtr(node) orelse unreachable;
        return node_.getAdyNumber();
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
        // si no hay camino
        if (dads.get(B) == null) {
            print("No hay camino posible \n", .{});
        }
        // si hay camino
        try Aux.printDads(dads, B);
    }

    // recorrido DFS - Complejidad -> O(V+E)
    pub fn dfs(self: *Self, A: []const u8, B: []const u8) !void {
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
        try self.dfs_(A, B, &visited, &dads, &order);
        // si no hay camino
        if (dads.get(B) == null) {
            print("No hay camino posible \n", .{});
        }
        // si hay camino
        try Aux.printDads(dads, B);
    }
    // llamada recursiva dfs
    fn dfs_(self: *Self, A: []const u8, B: []const u8, visited: *VisitedMap, dads: *DadMap, order: *OrderMap) !void {
        if (std.mem.eql(u8, A, B)) {
            return;
        }
        const ady_map: AdyMap = self.getAdy(A);
        var it_ady = ady_map.iterator();
        while (it_ady.next()) |entry_node| {
            const ady = entry_node.key_ptr.*;
            if (!visited.contains(ady)) {
                try dads.put(ady, A);
                const order_node: u8 = order.get(A) orelse unreachable;
                try order.put(ady, order_node + 1);
                try visited.put(ady, ady);
                try self.dfs_(ady, B, visited, dads, order);
            }
        }
    }

    // solicita por stdin nodos y sus adyacentes y los inserta
    pub fn insertStdin(self: *Self, allocator: Allocator) !void {
        while (true) {
            // solicita nodo por stdin
            const node = Aux.read_and_own(allocator, 1) catch {
                break;
            };
            if (!self.nodeExists(node)) {
                _ = self.addNode(node) catch false;
            }
            while (true) {
                // solicita ady por stdin
                const aux = Aux.read_and_own(allocator, 2) catch {
                    break;
                };
                if (!self.nodeExists(aux)) {
                    _ = self.addNode(aux) catch false;
                }
                if (!self.edgeExists(node, aux)) {
                    _ = self.addEdge(node, aux) catch false;
                }
            }
        }
    }
};
