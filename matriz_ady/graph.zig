const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const GraphError = error{ NODE_NOT_EXISTS, EDGE_NOT_EXISTS, NODE_NOT_FOUND };

// []
// [{a, [1]}]
//  [{a, [1,0]} , {b, [0,1]}]
// 
//

const Node = struct {
    adj: ArrayList(u8),
    label: []const u8,
    pos: ?u32,
    const Self = @This();

    pub fn agregar_nodo(self: *Self) !void{
        try self.adj.append(0);    
    }

    pub fn iniciar_nodo(self: *Self, tam: u32) !void{
        //var i = 0;
        //while (i < tam){
        for (0..tam) | _ |{
            try self.adj.append(0);
            //i += 1;
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
            //const nodo = self.nodes_map.items[n];
            nodo.adj.deinit();
            //nodo.label.deinit();
            print("nodo borrado {any}\n",.{nodo});
        }
        self.nodes_map.deinit();
    }

    pub fn contiene(self: *Self, valor: []const u8) bool{
        if (self.tam == 0) return false;

        for (self.nodes_map.items) | nodo |{
            const aux = nodo;
            if (std.mem.eql(Node, aux, valor)){
            //if (nodo.label == valor){
                return true;
            }
        }
        return false;
    }

    /// la función devuelve true en caso de haber insertado
    /// el nodo. false en caso de encontrarse presente.
    pub fn addNode(self: *Self, node_label: []const u8) !bool {
        //const valor = node_label;
        
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

        try nodo.agregar_nodo();
        try self.nodes_map.append(nodo);
        self.tam += 1;

        //si es el primero que agrego, ya está terminado
        if (self.tam == 1){
            return true;
        }

        try nodo.iniciar_nodo(self.tam);
        //sino itero sobre todos los nodos para agrarle el nuevo
        
        for (self.nodes_map.items) | nodo_aux | {
            var n = nodo_aux;
            try n.agregar_nodo();
        }
        return true;
        
    }

    pub fn contains(self: *Self, node_label: []const u8) bool {
        return self.contiene(node_label);
    }

    /// devuelve true en caso de que el nodo exista, false en caso de que no
    pub fn nodeExists(self: *Self, node_label: []const u8) bool {
        for (self.nodes_map.items) | nodo | {
            if (nodo.label == node_label){
                return true;
            }
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
        //var contador = 0;
        for (self.nodes_map.items) | nodo | {
            if ((nodo.label == node1) or (nodo.label == node2)){
                nodo.agregar_adyacencia(nodo.pos);
            //    contador += 1;
            }
            //if (contador == 2){
            //    return;
            //}
        }
        
    }

    /// devuelve true en caso de que el eje exista, false en caso de que no
    /// la implementación cambia si el grafo es dirigido o no
    /// en este caso no es dirigido
    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8) bool {
       // si no existen los nodos, devuelvo error
       if (!(self.nodes_map.contiene(node1)) and !(self.nodes_map.contiene(node2))) {
        return GraphError.NODE_NOT_FOUND;
        }
       //var contador = 0;
       for (self.nodes_map.items) | nodo | {
        //    if (std.mem.eql(nodo, node1)){
            if ((nodo.label == node1)){
                return (nodo.adj.items[node2.pos] >= 1);
                //contador += 1;
            }
        }
    }

};


const testing = std.testing;
test "Test agrego nodos y existen" {
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
