const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

// implementación dict + adyacencias
const Label = struct {
    label: []const u8,

    fn deinit(self: Label, allocator: Allocator) void {
        allocator.free(self.label);
    }
};

const Adjacencies = struct {
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

const Node = struct { label: []u8, adjacencies: Adjacencies };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var adjacencies = Adjacencies.init(allocator);
    defer adjacencies.deinit();

    const stdin = std.io.getStdIn().reader();

    // stdout is an std.io.Writer
    const stdout = std.io.getStdOut().writer();

    var i: i32 = 0;
    while (true) : (i += 1) {
        var buf: [30]u8 = undefined;
        try stdout.print("Please enter a name: ", .{});
        if (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |name| {
            if (name.len == 0) {
                break;
            }
            try adjacencies.add(name);
        }
    }

    adjacencies.print_items();
    print("\n", .{});
    print("{any}\n", .{@TypeOf(adjacencies)});
}
