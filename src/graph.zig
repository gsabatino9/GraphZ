const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.hash_map.AutoHashMap;
const StringContext = std.hash_map.StringContext;
const math = std.math;
const Allocator = std.mem.Allocator;

pub const GraphError = error{
    VertexNotFoundError,
};

// lo siguiente sirve en caso de querer usar atributos en la relación
// ej: weight, algún label, etc
pub const Adjacents = ArrayList(u64);
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
            kv.value_ptr.deinit();
        }
        self.adj.deinit();
        self.values.deinit();
        self.* = undefined;
    }

    /// la función devuelve true en caso de haber insertado
    /// el nodo. false en caso de encontrarse presente.
    pub fn add(self: *Self, node_label: []const u8) !bool {
        const h = self.ctx.hash(node_label);

        // si ya existe el nodo, no hago nada
        if (self.adj.contains(h)) {
            return false;
        }

        try self.adj.put(h, Adjacents.init(self.allocator));
        try self.values.put(h, node_label);
        return true;
    }

    pub fn contains(self: *Self, node_label: []const u8) bool {
        return self.values.contains(self.ctx.hash(node_label));
    }

    pub fn lookup(self: *Self, hash: u64) ?[]const u8 {
        return self.values.get(hash);
    }

    pub fn addEdge(self: *Self, label1: []const u8, label2: []const u8) !void {
        const h1 = self.ctx.hash(label1);
        const h2 = self.ctx.hash(label2);

        const map1 = self.adj.getPtr(h1) orelse return GraphError.VertexNotFoundError;
        const map2 = self.adj.getPtr(h2) orelse return GraphError.VertexNotFoundError;

        try map1.append(h2);
        try map2.append(h1);
    }

    pub fn edgeExists(self: *const Self, label1: []const u8, label2: []const u8) bool {
        const h1 = self.ctx.hash(label1);
        const h2 = self.ctx.hash(label2);

        const adj1 = self.adj.getPtr(h1).?;
        for (adj1.items) |item| {
            if (item == h2) {
                return true;
            }
        }
        return false;
    }

    pub fn countNodes(self: *Self) Size {
        return self.values.count();
    }

    pub fn countEdges(self: *Self) Size {
        var amount_edges: Size = 0;
        var it = self.adj.iterator();
        while (it.next()) |node| {
            amount_edges += @intCast(node.value_ptr.items.len);
        }

        return amount_edges / 2;
    }

    pub fn dfsIterator(self: *const Self, label_to_start: []const u8) !DFSIterator {
        const h = self.ctx.hash(label_to_start);

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
                for (map.items) |target| {
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
const print = std.debug.print;
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

    try g.addEdge("A", "B");

    const contains_A_B = g.edgeExists("A", "B");
    const not_contains_A_C = g.edgeExists("A", "C");

    try testing.expect(contains_A_B == true);
    try testing.expect(not_contains_A_C == false);
    try testing.expect(g.countEdges() == 1);
}

test "Test dfs" {
    const allocator = testing.allocator;
    var g = Graph.init(allocator);
    defer g.deinit();

    _ = try g.add("A");
    _ = try g.add("B");

    try g.addEdge("A", "B");

    var it = try g.dfsIterator("A");
    defer it.deinit();

    print("\nDFS iteration: ", .{});
    while (try it.next()) |item| {
        const elem = g.lookup(item).?;
        print("{s}, ", .{elem});
    }
    print("\n", .{});
}
