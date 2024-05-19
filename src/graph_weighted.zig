const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const AutoHashMap = std.hash_map.AutoHashMap;
const StringContext = std.hash_map.StringContext;
const math = std.math;
const Allocator = std.mem.Allocator;

pub const GraphError = error{
    VertexNotFoundError,
    EdgeNotFoundError,
};

// lo siguiente sirve en caso de querer usar atributos en la relación
// ej: weight, algún label, etc

const RelationAttributes = struct { weight: i32 };
const Relation = struct { node_relation: u64, relation_attrs: RelationAttributes };

// pub const Adjacents = AutoHashMap(u64, u64);
// pub const Adjacents = ArrayList(u64);
pub const Adjacents = std.MultiArrayList(Relation);
pub const AdjacentsMap = AutoHashMap(u64, Adjacents);

// lo siguiente sirve para guardar atributos en el nodo.
// Por ahora solo tiene el label, pero se puede extender más.
pub const NodesMap = AutoHashMap(u64, []const u8);

pub const Graph = struct {
    allocator: Allocator,
    ctx: StringContext,
    adj: AdjacentsMap,
    values: NodesMap,

    const Self = @This();
    const Size = AdjacentsMap.Size;

    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
            .ctx = undefined,
            .adj = AdjacentsMap.init(allocator),
            .values = NodesMap.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.adj.iterator();
        while (it.next()) |kv| {
            kv.value_ptr.deinit(self.allocator);
        }
        self.adj.deinit();
        self.values.deinit();
        self.* = undefined;
    }

    /// la función devuelve true en caso de haber insertado
    /// el nodo. false en caso de encontrarse presente.
    pub fn add(self: *Self, v: []const u8) !bool {
        const h = self.ctx.hash(v);

        // si ya existe el nodo, no hago nada
        if (self.adj.contains(h)) {
            return false;
        }

        try self.adj.put(h, Adjacents{});
        try self.values.put(h, v);
        return true;
    }

    pub fn contains(self: *Self, v: []const u8) bool {
        return self.values.contains(self.ctx.hash(v));
    }

    pub fn lookup(self: *Self, hash: u64) ?[]const u8 {
        return self.values.get(hash);
    }

    pub fn addEdge(self: *Self, v1: []const u8, v2: []const u8, relation_attrs: RelationAttributes) !void {
        const h1 = self.ctx.hash(v1);
        const h2 = self.ctx.hash(v2);

        const map1 = self.adj.getPtr(h1) orelse return GraphError.VertexNotFoundError;
        const map2 = self.adj.getPtr(h2) orelse return GraphError.VertexNotFoundError;

        const relation_1_2 = Relation{ .node_relation = h2, .relation_attrs = relation_attrs };
        const relation_2_1 = Relation{ .node_relation = h1, .relation_attrs = relation_attrs };
        try map1.append(self.allocator, relation_1_2);
        try map2.append(self.allocator, relation_2_1);
    }

    pub fn edgeExists(self: *const Self, v1: []const u8, v2: []const u8) bool {
        const h1 = self.ctx.hash(v1);
        const h2 = self.ctx.hash(v2);

        const adj1 = self.adj.getPtr(h1).?;
        for (adj1.items(.node_relation)) |item| {
            if (item == h2) {
                return true;
            }
        }
        return false;
    }

    pub fn getEdge(self: *const Self, v1: []const u8, v2: []const u8) !RelationAttributes {
        const h1 = self.ctx.hash(v1);
        const h2 = self.ctx.hash(v2);

        const adj1 = self.adj.getPtr(h1).?;
        for (adj1.items(.node_relation), adj1.items(.relation_attrs)) |node_relation, relation_attrs| {
            if (node_relation == h2) {
                return relation_attrs;
            }
        }

        return GraphError.EdgeNotFoundError;
    }

    pub fn countNodes(self: *Self) Size {
        return self.values.count();
    }

    pub fn countEdges(self: *Self) Size {
        var amount_edges: Size = 0;
        var it = self.adj.iterator();
        while (it.next()) |node| {
            amount_edges += @intCast(node.value_ptr.len);
        }

        return amount_edges / 2;
    }

    pub fn dfsIterator(self: *const Self, start: []const u8) !DFSIterator {
        const h = self.ctx.hash(start);

        if (!self.values.contains(h)) {
            return GraphError.VertexNotFoundError;
        }

        const stack = std.ArrayList(u64).init(self.allocator);
        const visited = std.AutoHashMap(u64, void).init(self.allocator);

        return DFSIterator{
            .g = self,
            .stack = stack,
            .visited = visited,
            .current = h,
        };
    }

    pub const DFSIterator = struct {
        g: *const Self,
        stack: std.ArrayList(u64),
        visited: std.AutoHashMap(u64, void),
        current: ?u64,

        pub fn deinit(it: *DFSIterator) void {
            it.stack.deinit();
            it.visited.deinit();
        }

        pub fn next(it: *DFSIterator) !?u64 {
            if (it.current == null) return null;

            const result = it.current orelse unreachable;
            try it.visited.put(result, {});

            if (it.g.adj.getPtr(result)) |map| {
                for (map.items(.node_relation)) |target| {
                    if (!it.visited.contains(target)) {
                        try it.stack.append(target);
                    }
                }
            }

            it.current = null;
            while (it.stack.popOrNull()) |nextVal| {
                if (!it.visited.contains(nextVal)) {
                    it.current = nextVal;
                    break;
                }
            }

            return result;
        }
    };
};

const testing = std.testing;
test "Test add nodes" {
    const allocator = testing.allocator;
    var g = Graph.init(allocator);
    defer g.deinit();

    _ = try g.add("A");
    _ = try g.add("B");

    const contains_A: bool = g.contains("A");
    const contains_B: bool = g.contains("B");

    try testing.expect(contains_A == true);
    try testing.expect(contains_B == true);
    try testing.expect(g.countNodes() == 2);
}

test "Test add edges" {
    const allocator = testing.allocator;
    var g = Graph.init(allocator);
    defer g.deinit();

    _ = try g.add("A");
    _ = try g.add("B");

    try g.addEdge("A", "B", RelationAttributes{ .weight = 10 });

    const contains_A_B = g.edgeExists("A", "B");
    const not_contains_A_C = g.edgeExists("A", "C");
    const relation_attrs = try g.getEdge("A", "B");

    try testing.expect(contains_A_B == true);
    try testing.expect(not_contains_A_C == false);
    try testing.expect(relation_attrs.weight == 10);
    try testing.expect(g.countEdges() == 1);
}

test "Test dfs" {
    const allocator = testing.allocator;
    var g = Graph.init(allocator);
    defer g.deinit();

    _ = try g.add("A");
    _ = try g.add("B");

    try g.addEdge("A", "B", RelationAttributes{ .weight = 10 });

    var it = try g.dfsIterator("A");
    defer it.deinit();

    print("\nDFS iteration: ", .{});
    while (try it.next()) |item| {
        const elem = g.lookup(item).?;
        print("{s}, ", .{elem});
    }
    print("\n", .{});
}
