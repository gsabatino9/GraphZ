const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS, NODE_NOT_FOUND };

const Node = struct {
    adj: ArrayList(u32),
    weigths: ArrayList(i32),
    label: []const u8,
    const Self = @This();

    pub fn agregarNodo(self: *Self) !void {
        try self.adj.append(0);
        try self.weigths.append(0);
    }

    pub fn iniciarNodo(self: *Self, tam: u32) !void {
        for (0..tam) |_| {
            try self.adj.append(0);
            try self.weigths.append(0);
        }
    }

    pub fn agregarAdyacencia(self: *Self, pos: usize, weigth: i32) void {
        var resultado = self.adj.items[pos];
        resultado += 1;

        const peso = weigth;
        self.adj.items[pos] = resultado;
        self.weigths.items[pos] = peso;
        
    }

    pub fn deinit(self: *Self) void {
        self.adj.deinit();
        self.weigths.deinit();
    }
};

pub const Graph = struct {
    allocator: Allocator,
    nodes_map: ArrayList(Node),
    is_directed: bool,
    tam: u32,
    
    const Self = @This();
    

    pub fn init(allocator: Allocator, is_directed: bool) Self {
        return .{
            .allocator = allocator,
            .nodes_map = ArrayList(Node).init(allocator),
            .tam = 0,
            .is_directed = is_directed,
        };
    }

    pub fn deinit(self: *Self) void {
        for (self.nodes_map.items) |nodo| {
            var n = nodo;
            n.deinit();
        }
        self.nodes_map.deinit();
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
            .adj = ArrayList(u32).init(self.allocator),
            .weigths = ArrayList(i32).init(self.allocator),
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
        if (self.tam == 0) return false;

        for (self.nodes_map.items) |nodo| {
            if (std.mem.eql(u8, nodo.label, node)) return true;
        }
        return false;
    }

    /// devuelve true en caso de que el nodo exista, false en caso de que no
    pub fn nodeExists(self: *Self, node: []const u8) bool {
        if (self.tam == 0) return false;

        for (self.nodes_map.items) |nodo| {
            if (std.mem.eql(u8, nodo.label, node)) return true;
        }
        return false;
    }

    /// devuelve GraphError.NODE_NOT_FOUND en caso de que alguno de los dos nodos
    /// no existan
    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8, peso: i32) !bool {
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
        self.nodes_map.items[node1_pos].agregarAdyacencia(node2_pos, peso);
        if (!self.is_directed) self.nodes_map.items[node2_pos].agregarAdyacencia(node1_pos, peso);
        return true;
    }

    /// devuelve true en caso de que la arista exista, false en caso de que no
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
        // si no existen los nodos, devuelvo error
        if (!(self.contains(node1)) or !(self.contains(node2))) {
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
        if (!self.contains(node1)) {
            return GraphError.NODE_NOT_FOUND;
        }

        var node_pos: usize = undefined;

        for (self.nodes_map.items, 0..) |nodo, i| {
            if (std.mem.eql(u8, nodo.label, node1)) {
                node_pos = i;
            }
        }
        var nodo = self.nodes_map.orderedRemove(node_pos);
        const label = nodo.label;
        nodo.deinit();

        for (self.nodes_map.items, 0..) |n, i| {
            var aux = n;
            _ = aux.adj.orderedRemove(node_pos);
            _ = aux.weigths.orderedRemove(node_pos);

            self.nodes_map.items[i] = aux;
        }
        self.tam = self.tam - 1;
        return label;
    }

    pub fn deleteEdge(self: *Self, node1: []const u8, node2: []const u8) !void {
        // si no existen los nodos, devuelvo error
        if (!(self.contains(node1)) or !(self.contains(node2))) {
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
        self.nodes_map.items[node1_pos].weigths.items[node2_pos] = 0;
        
        if (!self.is_directed) {
            self.nodes_map.items[node2_pos].adj.items[node1_pos] = 0;
            self.nodes_map.items[node2_pos].weigths.items[node1_pos] = 0;
        }
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
        if (self.is_directed) return resultado;
        return resultado / 2;
    }
    
    pub fn getEdge(self: *Self, node1: []const u8, node2: []const u8) !i32 {
        if (!(self.contains(node1)) or !(self.contains(node2))) {
            return GraphError.NODE_NOT_FOUND;
        }
        var node2_pos: usize = undefined;
        for (self.nodes_map.items, 0..) |nodo, i| {
            if (std.mem.eql(u8, nodo.label, node2)) {
                node2_pos = i;
            }
        }
        var resultado: i32 = undefined;
        for (self.nodes_map.items) |nodo| {
            if (std.mem.eql(u8, nodo.label, node1)) {
                resultado = nodo.weigths.items[node2_pos];
            }
        }
        return resultado;
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
