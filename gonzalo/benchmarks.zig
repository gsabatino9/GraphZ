const std = @import("std");
const print = std.debug.print;
const milliTimestamp = std.time.milliTimestamp;
const Allocator = std.mem.Allocator;

const Graph = @import("graph.zig").Graph;

const BenchmarkError = error{DumpError};

pub fn benchmarkInit(allocator: Allocator, amount_iterations: u32, amount_dump: u32) !void {
    var time_list = std.ArrayList(i64).init(allocator);
    defer time_list.deinit();

    if (amount_iterations < amount_dump) {
        return BenchmarkError.DumpError;
    }
    const random_gen = std.rand.DefaultPrng;

    var rnd = random_gen.init(0);
    var graph = Graph.init(.{ .structures_allocator = allocator, .is_directed = false });
    defer graph.deinit();

    for (0..amount_iterations) |i| {
        if (i % amount_dump == 0) {
            try time_list.append(milliTimestamp());
        }
        const rand_num = rnd.random().int(i32);
        const max_len = 20;
        var buf: [max_len]u8 = undefined;
        const label = try std.fmt.bufPrint(&buf, "{}", .{rand_num});

        _ = try graph.addNode(label);
    }

    for (time_list.items) |time| {
        print("{}, ", .{time});
    }
}

const testing = std.testing;
test "Test benchmarkInit" {
    const allocator = testing.allocator;
    const amount_iterations: u32 = 1;
    const amount_dump: u32 = 1;

    try benchmarkInit(allocator, amount_iterations, amount_dump);
}

test "Test benchmarkInit and dump files" {
    const allocator = testing.allocator;
    const amount_iterations: u32 = 100000;
    const amount_dump: u32 = 5000;

    try benchmarkInit(allocator, amount_iterations, amount_dump);
}
