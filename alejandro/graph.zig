const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS, NODE_NOT_FOUND };

const Node = struct {
    adj: ArrayList(u8),
    label: []const u8,
    const Self = @This();

    pub fn agregarNodo(self: *Self) !void {
        try self.adj.append(0);
    }

    pub fn iniciarNodo(self: *Self, tam: u32) !void {
        for (0..tam) |_| {
            try self.adj.append(0);
        }
    }

    pub fn agregarAdyacencia(self: *Self, pos: usize) void {
        var resultado = self.adj.items[pos];
        resultado += 1;
        self.adj.items[pos] = resultado;
    }

    pub fn deinit(self: *Self) void {
        self.adj.deinit();
    }
};

pub const Graph = struct {
    allocator: Allocator,
    nodes_map: ArrayList(Node),
    tam: u32,
    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        print("Inicio el grafo\n", .{});
        return .{
            .allocator = allocator,
            .nodes_map = ArrayList(Node).init(allocator),
            .tam = 0,
        };
    }

    pub fn deinit(self: *Self) void {
        for (self.nodes_map.items) |nodo| {
            var n = nodo;
            //print("nodo borrado: {s}\n",.{nodo.label});
            n.deinit();
            //nodo.label.deinit();
        }
        self.nodes_map.deinit();
    }

    pub fn auxContains(self: *Self, node: []const u8) bool {
        if (self.tam == 0) return false;

        for (self.nodes_map.items) |nodo| {
            if (std.mem.eql(u8, nodo.label, node)) return true;
        }
        return false;
    }

    /// la función devuelve true en caso de haber insertado
    /// el nodo. false en caso de encontrarse presente.
    pub fn addNode(self: *Self, node: []const u8) !bool {
        // si ya existe el nodo, no hago nada
        if (self.nodeExists(node)) {
            //print("Ya tengo el nodo: {s} bro\n",.{node});
            return false; //o true?
        }
        //creo el nodo
        var nodo = Node{
            .adj = ArrayList(u8).init(self.allocator),
            .label = node,
        };

        if (self.tam == 0) {
            try nodo.agregarNodo();
            try self.nodes_map.append(nodo);
            self.tam += 1;
            return true;
        }

        try nodo.iniciarNodo(self.tam);
        try self.nodes_map.append(nodo);

        for (self.nodes_map.items, 0..) |nodo_aux, i| {
            var n = nodo_aux;
            try n.agregarNodo();
            self.nodes_map.items[i] = n;
        }
        self.tam += 1;
        return true;
    }

    pub fn contains(self: *Self, node: []const u8) bool {
        return self.auxContains(node);
    }

    /// devuelve true en caso de que el nodo exista, false en caso de que no
    pub fn nodeExists(self: *Self, node: []const u8) bool {
        for (self.nodes_map.items) |nodo| {
            //print("nodo pasado: {s}, nodo encontrado: {s}\n",.{node, nodo.label});
                
            if (std.mem.eql(u8, nodo.label, node)) {
                return true;
                }
        }
        return false;
    }

    /// devuelve GraphError.NODE_NOT_FOUND en caso de que alguno de los dos nodos
    /// no existan
    /// Esta implementación es para grafos no dirigidos
    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) !bool {
        // si no existen los nodos, devuelvo error
        if (!(self.nodeExists(node1)) or !(self.nodeExists(node2))) {
            return GraphError.NODE_NOT_FOUND;
        }
        var node1_pos: usize = undefined;
        var node2_pos: usize = undefined;

        for (self.nodes_map.items, 0..) |nodo, i| {
            if (std.mem.eql(u8, nodo.label, node1)) {
                node1_pos = i;
                break;
            }
        }

        for (self.nodes_map.items, 0..) |nodo, i| {
            if ((std.mem.eql(u8, nodo.label, node2))) {
                node2_pos = i;
                break;
            }
        }
        self.nodes_map.items[node1_pos].agregarAdyacencia(node2_pos);
        self.nodes_map.items[node2_pos].agregarAdyacencia(node1_pos);
        return true;
    }

    /// devuelve true en caso de que la arista exista, false en caso de que no
    /// la implementación cambia si el grafo es dirigido o no
    /// en este caso no es dirigido
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
        // si no existen los nodos, devuelvo error
        if (!(self.auxContains(node1)) or !(self.auxContains(node2))) {
            return false;
        }
        var node2_pos: usize = undefined;
        for (self.nodes_map.items, 0..) |nodo, i| {
            if (std.mem.eql(u8, nodo.label, node2)) {
                node2_pos = i;
            }
        }

        for (self.nodes_map.items) |nodo| {
            if (std.mem.eql(u8, nodo.label, node1)) {
                return (nodo.adj.items[node2_pos] >= 1);
            }
        }
        return false;
    }

    pub fn deleteNode(self: *Self, node1: []const u8) ![]const u8 {
        if (!self.auxContains(node1)) {
            return GraphError.NODE_NOT_FOUND;
        }

        var node_pos: usize = undefined;
        //var label: u8 = undefined;

        for (self.nodes_map.items, 0..) |nodo, i| {
            if (std.mem.eql(u8, nodo.label, node1)) {
                node_pos = i;
            }
        }
        var n = self.nodes_map.orderedRemove(node_pos);
        const label = n.label;
        n.deinit();

        for (self.nodes_map.items, 0..) |nodo, i| {
            var aux = nodo;
            _ = aux.adj.orderedRemove(node_pos);

            self.nodes_map.items[i] = aux;
        }
        self.tam = self.tam - 1;
        return label;
    }

    pub fn deleteEdge(self: *Self, node1: []const u8, node2: []const u8) !void {
        // si no existen los nodos, devuelvo error
        if (!(self.auxContains(node1)) or !(self.auxContains(node2))) {
            return GraphError.NODE_NOT_FOUND;
        }
        var node1_pos: usize = undefined;
        var node2_pos: usize = undefined;

        for (self.nodes_map.items, 0..) |nodo, i| {
            if (std.mem.eql(u8, nodo.label, node1)) {
                node1_pos = i;
                break;
            }
        }
        for (self.nodes_map.items, 0..) |nodo, i| {
            if ((std.mem.eql(u8, nodo.label, node2))) {
                node2_pos = i;
                break;
            }
        }
        self.nodes_map.items[node1_pos].adj.items[node2_pos] = 0;
        self.nodes_map.items[node2_pos].adj.items[node1_pos] = 0;
    }

    pub fn countNodes(self: *Self) u32 {
        return self.tam;
    }

    pub fn countEdges(self: *Self) u32 {
        var resultado: u32 = 0;
        for (self.nodes_map.items) |nodo| {
            for (nodo.adj.items) |adj| {
                resultado += adj;
            }
        }
        return resultado / 2;
    }
    pub fn printG(self: *Self) void {
        for (self.nodes_map.items) |nodo| {
            print("{s} ",.{nodo.label});
        }
    print("\n",.{});
    }

    pub fn borrarNodo(self: *Self) ![]const u8 {
        if (self.countNodes() == 0) {
            return GraphError.NODE_NOT_FOUND;
        }
        
        var n = self.nodes_map.orderedRemove(0);
        const label = n.label;
        n.deinit();

        for (self.nodes_map.items, 0..) |nodo, i| {
            var aux = nodo;
            _ = aux.adj.orderedRemove(0);

            self.nodes_map.items[i] = aux;
        }
        self.tam = self.tam - 1;
        return label;
    }
};   

const testing = std.testing;
test "Test agrego nodos y existen\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    try testing.expect(graph.countNodes() == 2);

    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.countEdges() == 1);
    _ = try graph.addNode("A");
    try testing.expect(graph.countNodes() == 2);

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("B", "A") == true);
    try testing.expect(graph.edgeExists("A", "C") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);

   
    try std.testing.expectError(error.NODE_NOT_FOUND, graph.addEdge("A", "C"));
    try std.testing.expectError(error.NODE_NOT_FOUND, graph.deleteEdge("A", "C"));

    try std.testing.expectError(error.NODE_NOT_FOUND, graph.deleteNode("Z"));

    _ = try graph.addNode("C");
    try testing.expect(graph.countNodes() == 3);

    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.countEdges() == 2);
    try testing.expect(graph.edgeExists("A", "C") == true);
    try testing.expect(graph.edgeExists("C", "A") == true);

    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.countEdges() == 3);
    try testing.expect(graph.edgeExists("A", "C") == true);

    //print("grafo {s} \n",.{graph.nodes_map.items});
    _ = try graph.addEdge("A", "A");
    try testing.expect(graph.countEdges() == 4);

    _ = try graph.deleteEdge("A", "B");
    try testing.expect(graph.edgeExists("A", "B") == false);
    try testing.expect(graph.edgeExists("B", "A") == false);
    try testing.expect(graph.countEdges() == 3);

    const A = try graph.deleteNode("A");
    try testing.expect(graph.nodeExists("A") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);
    try testing.expect(graph.countEdges() == 0);
    try testing.expect(std.mem.eql(u8, A, "A"));

    try testing.expect(graph.countNodes() == 2);

    const B = try graph.deleteNode("B");
    try testing.expect(std.mem.eql(u8, B, "B"));

    const C = try graph.deleteNode("C");
    try testing.expect(std.mem.eql(u8, C, "C"));

    try testing.expect(graph.countNodes() == 0);

    _ = try graph.addNode("C");
    const valor = try graph.borrarNodo();

    try testing.expect(std.mem.eql(u8, valor, "C"));

    try testing.expect(graph.countNodes() == 0);
}
