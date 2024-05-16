const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

pub const Label = struct {
    label: []const u8,

    fn deinit(self: Label, allocator: Allocator) void {
        allocator.free(self.label);
    }
};

pub const Adjacencies = struct {
    adjacencies: std.ArrayList(Label),
    allocator: Allocator,

    pub fn init(allocator: Allocator) Adjacencies {
        const adjacencies = std.ArrayList(Label).init(allocator);
        return Adjacencies{ .adjacencies = adjacencies, .allocator = allocator };
    }

    pub fn deinit(self: Adjacencies) void {
        for (self.adjacencies.items) |adj| {
            adj.deinit(self.allocator);
        }
        self.adjacencies.deinit();
    }

    pub fn add(self: *Adjacencies, label: []u8) !void {
        const owned_label = try self.allocator.dupe(u8, label);
        try self.adjacencies.append(.{ .label = owned_label });
    }

    pub fn print_items(self: Adjacencies) void {
        for (self.adjacencies.items) |adj| {
            print("{s}, ", .{adj.label});
        }
    }
};

const testing = std.testing;
test "Test: Adjacencies" {
    const allocator = testing.allocator;
    var adjacencies = Adjacencies.init(allocator);
    defer adjacencies.deinit();

    var s = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    const a = s[1..];
    for (0..10) |i| {
        _ = i;
        try adjacencies.add(a);
    }

    try testing.expectEqual(@as(usize, 10), adjacencies.adjacencies.items.len);
}
