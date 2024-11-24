const std = @import("std");
const Parser = @import("parser.zig").Parser;
const AstType = @import("parser.zig").AstType;
const Ast = @import("parser.zig").Ast;

fn asm_number(list: *std.ArrayList(u8), node: *const Ast) !void {
    switch (node.*) {
        AstType.Number => |n| {
            try list.appendSlice("\tmov x0, #");
            try list.appendSlice(n);
            try list.append('\n');
        },
        else => unreachable,
    }
}

fn asm_add(list: *std.ArrayList(u8), node: *const Ast) !void {
    switch (node.*) {
        AstType.BinaryOperator => |value| {
            try asm_expression(list, value.left);
            try list.appendSlice("\tmov x1, x0\n");
            try asm_expression(list, value.right);
            try list.appendSlice("\tadd x0, x0, x1\n");
        },
        else => unreachable,
    }
}

fn asm_expression(list: *std.ArrayList(u8), node: *const Ast) anyerror!void {
    switch (node.*) {
        AstType.BinaryOperator => |value| {
            if (std.mem.eql(u8, value.op, "+")) {
                try asm_add(list, node);
            }
        },
        AstType.Number => |_| {
            try asm_number(list, node);
        },
        else => unreachable,
    }
}

fn asm_statement(list: *std.ArrayList(u8), node: *const Ast) !void {
    switch (node.*) {
        AstType.Var => |value| {
            try asm_expression(list, value.value);
        },
        else => unreachable,
    }
}

fn assembler(allocator: std.mem.Allocator, parser: *Parser) !void {
    var list = std.ArrayList(u8).init(allocator);
    const node = try parser.parse();

    switch (node.*) {
        AstType.Block => |value| {
            try list.appendSlice(".section .text\n");
            try list.appendSlice(".global main\n");
            try list.appendSlice("main:\n");
            try list.appendSlice("\tstp x29, x30, [sp, #-16]!\n");
            for (value.items) |_node| {
                const t: AstType = _node;
                if (t == AstType.Var) {
                    try asm_statement(&list, &_node);
                }
            }
        },
        else => return std.debug.print("Invalid node type.\n", .{}),
    }

    try list.appendSlice("\tldp x29, x30, [sp], #16\n");
    try list.appendSlice("\tret");
    try list.append('\n');

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    _ = try stdout.write(list.items);

    try bw.flush(); // don't forget to flush!
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const string_input = "var a = 3; var b = 5; var c = 10 + 23;";

    var parser = try Parser.init(allocator, string_input);

    _ = try assembler(allocator, &parser);
}
