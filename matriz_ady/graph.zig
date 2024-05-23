const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS, NODE_NOT_FOUND };

const Node = struct {
    adj: ArrayList(u8),
    label: []const u8,
    pos: u32,
    const Self = @This();

    pub fn agregar_nodo(self: *Self) !void{
        try self.adj.append(0);    
    }

    pub fn iniciar_nodo(self: *Self, tam: u32) !void{
        for (0..tam) | _ |{
            try self.adj.append(0);
        }
    }

    pub fn agregar_adyacencia(self: *Self, pos:u32) void{
        var resultado = self.adj.items[pos];
        resultado += 1;
        self.adj.items[pos] = resultado;
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
        print("Elimino el grafo\n", .{});
        for (self.nodes_map.items) | nodo |{   
            nodo.adj.deinit();
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
            .pos = self.tam,
            
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
    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8) !void {
        // si no existen los nodos, devuelvo error 
        if (!(self.contiene(node1)) and !(self.contiene(node2))) {
            return GraphError.NODE_NOT_FOUND;
        }
        var node1_pos: u32 = undefined;
        var node2_pos: u32 = undefined;
        
        for (self.nodes_map.items) | nodo | {
            if (std.mem.eql(u8, nodo.label, node1)){
                node1_pos = nodo.pos;
                break;
            }
        
        }
        for (self.nodes_map.items) | nodo | {
            if ((std.mem.eql(u8, nodo.label, node2))){
                node2_pos = nodo.pos;
                break;   
            }
           
        }
        self.nodes_map.items[node1_pos].agregar_adyacencia(node2_pos);
        self.nodes_map.items[node2_pos].agregar_adyacencia(node1_pos);
    }

    /// devuelve true en caso de que el eje exista, false en caso de que no
    /// la implementación cambia si el grafo es dirigido o no
    /// en este caso no es dirigido
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
       // si no existen los nodos, devuelvo error
        if (!(self.contiene(node1)) or !(self.contiene(node2))) {
            return false;
        }
        var node2_pos: u32 = undefined;
        for (self.nodes_map.items) | nodo |{
            if (std.mem.eql(u8, nodo.label, node2)){
                node2_pos = nodo.pos;
            }
        }

        for (self.nodes_map.items) | nodo | {
            if (std.mem.eql(u8, nodo.label, node1)){
                return (nodo.adj.items[node2_pos] >= 1);
            }
        }
        return false;
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

    try testing.expect(graph.nodeExists("A") == true);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.nodeExists("B") == true);
    try testing.expect(graph.nodeExists("C") == false);
    try testing.expect(graph.edgeExists("A", "B") == true);
    try testing.expect(graph.edgeExists("B", "A") == true);
    try testing.expect(graph.edgeExists("A", "C") == false);
    try testing.expect(graph.edgeExists("C", "A") == false);
}