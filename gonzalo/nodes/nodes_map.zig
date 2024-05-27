const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const AutoHashMap = std.hash_map.AutoHashMap;
const StringContext = std.hash_map.StringContext;
const math = std.math;
const Allocator = std.mem.Allocator;
const AdjacentsMap = @import("../adjacents/adjacents.zig").AdjacentsMap;
const GraphError = @import("../errors.zig").GraphError;

pub const NodesMapType = AutoHashMap(u64, []const u8);
pub const NodesMap = struct {
    map: NodesMapType,
    ctx: StringContext,
    const Self = @This();
    const Size = NodesMapType.Size;

    pub fn init(allocator: Allocator) Self {
        return .{ .map = NodesMapType.init(allocator), .ctx = undefined };
    }

    pub fn deinit(self: *Self) void {
        self.map.deinit();
    }

    pub fn mapNodeLabel(self: *Self, node_label: []const u8) u64 {
        return self.ctx.hash(node_label);
    }

    pub fn addNodeLabel(self: *Self, node_label: []const u8) !?u64 {
        const node_hash = self.mapNodeLabel(node_label);
        if (self.map.contains(node_hash)) {
            return null;
        }

        try self.map.put(node_hash, node_label);
        return node_hash;
    }

    pub fn containsLabel(self: *Self, node_label: []const u8) bool {
        const node_hash = self.mapNodeLabel(node_label);
        return self.map.contains(node_hash);
    }

    pub fn lookup(self: *Self, node_hash: u64) ![]const u8 {
        const node_label = self.map.get(node_hash);
        if (node_label) |label| {
            return label;
        }

        return GraphError.NODE_NOT_EXISTS;
    }

    pub fn countNodes(self: *Self) Size {
        return self.map.count();
    }
};

const testing = std.testing;
test "Test nodes map" {
    const allocator = testing.allocator;
    var nodes_map = NodesMap.init(allocator);
    defer nodes_map.deinit();

    try testing.expect(nodes_map.mapNodeLabel("a") == 2941419223392617777);

    _ = try nodes_map.addNodeLabel("a");
    try testing.expect(nodes_map.containsLabel("a") == true);

    const lookup_value = try nodes_map.lookup(2941419223392617777);
    try testing.expect(std.mem.eql(u8, lookup_value, "a"));

    try testing.expect(nodes_map.lookup(1234) == GraphError.NODE_NOT_EXISTS);
}
