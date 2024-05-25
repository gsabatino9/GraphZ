const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS, NODE_NOT_FOUND };

const Node = struct {
    adj: ArrayList(u8),
    label: []const u8,
    const Self = @This();

    pub fn agregar_nodo(self: *Self) !void{
        try self.adj.append(0);    
    }

    pub fn iniciar_nodo(self: *Self, tam: u32) !void{
        for (0..tam) | _ |{
            try self.adj.append(0);
        }
    }

    pub fn agregar_adyacencia(self: *Self, pos:usize) void{
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
        for (self.nodes_map.items) | nodo |{   
            var n = nodo;
            n.deinit();
            //nodo.label.deinit();
        }
        self.nodes_map.deinit();
    }

    pub fn contiene(self: *Self, valor: []const u8) bool{
        if (self.tam == 0) return false;

        for (self.nodes_map.items) | nodo |{
            if (std.mem.eql(u8, nodo.label, valor)) return true;
        }
        return false;
    }

    /// la función devuelve true en caso de haber insertado
    /// el nodo. false en caso de encontrarse presente.
    pub fn addNode(self: *Self, node_label: []const u8) !bool {
        // si ya existe el nodo, no hago nada
        if (self.contiene(node_label)) {
            return false; //o true?
        }
        //creo el nodo
        var nodo = Node{
            .adj = ArrayList(u8).init(self.allocator),
            .label = node_label,
        };

        if (self.tam == 0){
            try nodo.agregar_nodo();
            try self.nodes_map.append(nodo);
            self.tam +=1;
            return true;
        }

        try nodo.iniciar_nodo(self.tam);
        try self.nodes_map.append(nodo);

        for (self.nodes_map.items, 0..) | nodo_aux, i |{
            var n = nodo_aux;
            try n.agregar_nodo();
            self.nodes_map.items[i] = n;
        }
        self.tam +=1;
        return true;
    }

    pub fn contains(self: *Self, node_label: []const u8) bool {
        return self.contiene(node_label);
    }

    /// devuelve true en caso de que el nodo exista, false en caso de que no
    pub fn nodeExists(self: *Self, node_label: []const u8) bool {
        for (self.nodes_map.items) | nodo | {
            if (std.mem.eql(u8, nodo.label, node_label)) return true;
        }
        return false;
        
    }

    /// devuelve GraphError.NODE_NOT_FOUND en caso de que alguno de los dos nodos
    /// no existan
    /// Esta implementación es para grafos no dirigidos
    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) !bool {
        // si no existen los nodos, devuelvo error 
        if (!(self.contiene(node1)) or !(self.contiene(node2))) {
            return GraphError.NODE_NOT_FOUND;
        }
        var node1_pos: usize = undefined;
        var node2_pos: usize = undefined;
        
        for (self.nodes_map.items, 0..) | nodo, i| {
            if (std.mem.eql(u8, nodo.label, node1)){
                node1_pos = i;
                break;
            }
        }

        for (self.nodes_map.items, 0..) | nodo, i| {
            if ((std.mem.eql(u8, nodo.label, node2))){
                node2_pos = i;
                break;
            }           
        }
        self.nodes_map.items[node1_pos].agregar_adyacencia(node2_pos);
        self.nodes_map.items[node2_pos].agregar_adyacencia(node1_pos);
        return true;
    }

    /// devuelve true en caso de que la arista exista, false en caso de que no
    /// la implementación cambia si el grafo es dirigido o no
    /// en este caso no es dirigido
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
       // si no existen los nodos, devuelvo error
        if (!(self.contiene(node1)) or !(self.contiene(node2))) {
            return false;
        }
        var node2_pos: usize = undefined;
        for (self.nodes_map.items, 0..) | nodo, i |{
            if (std.mem.eql(u8, nodo.label, node2)){
                node2_pos = i;
            }
        }

        for (self.nodes_map.items) | nodo | {
            if (std.mem.eql(u8, nodo.label, node1)){
                return (nodo.adj.items[node2_pos] >= 1);
            }
        }
        return false;
    }

    pub fn deleteNode(self: *Self, node1: []const u8) !void{
        if (!self.contiene(node1)) {
            return GraphError.NODE_NOT_FOUND;
        }

        var node_pos: usize = undefined;
        //var label: u8 = undefined;

        for (self.nodes_map.items, 0..) | nodo, i| {
            if (std.mem.eql(u8, nodo.label, node1)){
                node_pos = i;
            }
        }
        var n = self.nodes_map.orderedRemove(node_pos);
        //const label = n.label;
        //label = n.label; //esta linea falla
        n.deinit();
        
        for (self.nodes_map.items, 0..) | nodo, i| {
            var aux = nodo;
            _ = aux.adj.orderedRemove(node_pos);

            self.nodes_map.items[i] = aux;
        }
        self.tam = self.tam - 1;
        //return label;
    }

    pub fn deleteEdge(self: *Self, node1: []const u8, node2: []const u8) !void {
        // si no existen los nodos, devuelvo error 
        if (!(self.contiene(node1)) or !(self.contiene(node2))) {
            return GraphError.NODE_NOT_FOUND;
        }
        var node1_pos: usize = undefined;
        var node2_pos: usize = undefined;
        
        for (self.nodes_map.items, 0..) | nodo, i |{
            if (std.mem.eql(u8, nodo.label, node1)){
                node1_pos = i;
                break;
            }
        }
        for (self.nodes_map.items, 0..) | nodo, i |{
            if ((std.mem.eql(u8, nodo.label, node2))){
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
        for (self.nodes_map.items) | nodo |{
            //print("label {any}\n",.{nodo.label});
            for (nodo.adj.items) | adj |{
                //print("valor = {any}\n",.{adj});
                resultado += adj;
            }
        }
        //print("resultado = {any}\n",.{resultado/2});
        return resultado/2;
    }
};


const testing = std.testing;
test "Test agrego nodos y existen\n" {
    const allocator = testing.allocator;
    var graph = Graph.init(allocator);
    defer graph.deinit();

    _ = try graph.addNode("A");
    _ = try graph.addNode("B");
    _ = try graph.addEdge("A", "B");
    try testing.expect(graph.countEdges() == 1);

    _ = try graph.addNode("A");

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("B", "A") == true);
    try testing.expect(graph.edgeExists("A", "C") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);

    _ = try graph.addNode("C");
    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.countEdges() == 2);
    try testing.expect(graph.edgeExists("A", "C") == true);
    try testing.expect(graph.edgeExists("C", "A") == true);

    _ = try graph.addEdge("A", "C");
    try testing.expect(graph.countEdges() == 3);
    try testing.expect(graph.edgeExists("A", "C") == true);

    _ = try graph.addEdge("A", "A");
    try testing.expect(graph.countEdges() == 4);

    _ = try graph.deleteEdge("A", "B");
    try testing.expect(graph.edgeExists("A", "B") == false);
    try testing.expect(graph.edgeExists("B", "A") == false);
    try testing.expect(graph.countEdges() == 3);

    _ = try graph.deleteNode("A");
    try testing.expect(graph.nodeExists("A") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);
    try testing.expect(graph.countEdges() == 0);

    try testing.expect(graph.countNodes() == 2);
    try testing.expect(graph.edgeExists("C", "A") == false);
}
