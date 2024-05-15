const std = @import("std");

const AstType = enum {
    Number,
    Operator,
    If,
    Identifier,
    Call,
    Function,
    Block,
    Return,
    Var,
};

const Ast = union(AstType) {
    Number: i64,
    Operator: []const u8,
    If: void,
    Identifier: []const u8,
    Call: struct {
        func: *Ast,
        args: []*Ast,
    },
    Function: void,
    Block: struct {
        stmts: []*Ast,
    },
    Return: *Ast,
    Var: struct {
        identifier: *Ast,
        value: *Ast,
    },
};

pub const TokenType = enum {
    Identifier,
    Number,
    Keyword,
    Operator,
    LeftCurly,
    RightCurly,
    LeftParen,
    RightParen,
    LeftBracket,
    RightBracket,
    Comma,
    Semicolon,
    Colon,
};

pub const Token = struct {
    token_type: TokenType,
    start: usize,
    end: usize,
};

fn isNumeric(c: u8) bool {
    return c > '0' and c < '9';
}

fn isAlphabetic(c: u8) bool {
    return c >= 'a' and c <= 'z' or c >= 'A' and c <= 'Z';
}

pub const Lexer = struct {
    input: []const u8,
    index: usize,
    done: bool,

    pub fn init(input: []const u8) Lexer {
        return Lexer{
            .input = input,
            .index = 0,
            .done = false,
        };
    }

    pub fn slice(self: *Lexer, token: Token) []const u8 {
        return self.input[token.start..token.end];
    }

    pub fn peek(self: *Lexer) ?Token {
        const start = self.index;
        const token = self.next();
        self.index = start;
        return token;
    }

    pub fn next(self: *Lexer) ?Token {
        if (self.done) return null;

        const token = null;

        while (self.index < self.input.len) {
            const ch = self.input[self.index];
            switch (ch) {
                'a'...'z', 'A'...'Z', '_' => {
                    const start = self.index;
                    while (self.index < self.input.len) {
                        const c = self.input[self.index];
                        if (c != '_' and !isAlphabetic(c) and !isNumeric(c)) break;

                        self.index += 1;
                    }
                    return Token{
                        .token_type = TokenType.Identifier,
                        .start = start,
                        .end = self.index,
                    };
                },
                '1'...'9' => {
                    const start = self.index;
                    while (self.index < self.input.len) {
                        const c = self.input[self.index];
                        if (!isNumeric(c)) break;

                        self.index += 1;
                    }
                    return Token{
                        .token_type = TokenType.Number,
                        .start = start,
                        .end = self.index,
                    };
                },
                '{' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.LeftCurly, .start = start, .end = self.index };
                },
                '}' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.RightCurly, .start = start, .end = self.index };
                },
                '(' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.LeftParen, .start = start, .end = self.index };
                },
                ')' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.RightParen, .start = start, .end = self.index };
                },
                '[' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.LeftBracket, .start = start, .end = self.index };
                },
                ']' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.RightBracket, .start = start, .end = self.index };
                },
                '+', '-', '*', '/' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                },
                '=' => {
                    const start = self.index;
                    self.index += 1;
                    if (self.index < self.input.len) {
                        const c2 = self.input[self.index];
                        if (c2 == '=') {
                            self.index += 1;
                            return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                        }
                    }
                    return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                },
                '<' => {
                    const start = self.index;
                    self.index += 1;
                    if (self.index < self.input.len) {
                        const c2 = self.input[self.index];
                        if (c2 == '=' or c2 == '<') {
                            self.index += 1;
                            return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                        }
                    }
                    return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                },
                '>' => {
                    const start = self.index;
                    self.index += 1;
                    if (self.index < self.input.len) {
                        const c2 = self.input[self.index];
                        if (c2 == '=' or c2 == '>') {
                            self.index += 1;
                            return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                        }
                    }
                    return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                },
                ',' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.Comma, .start = start, .end = self.index };
                },
                ';' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.Semicolon, .start = start, .end = self.index };
                },
                ':' => {
                    const start = self.index;
                    self.index += 1;
                    return Token{ .token_type = TokenType.Colon, .start = start, .end = self.index };
                },
                '!' => {
                    const start = self.index;
                    self.index += 1;
                    if (self.index < self.input.len) {
                        const c2 = self.input[self.index];
                        if (c2 == '=') {
                            self.index += 1;
                            return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                        }
                    }
                    return Token{ .token_type = TokenType.Operator, .start = start, .end = self.index };
                },
                else => {
                    self.index += 1;
                },
            }
        }

        return token;
    }
};

const AstArray = std.ArrayList(Ast);

pub const ParserError = error{
    InvalidToken,
};

pub const Parser = struct {
    lexer: Lexer,
    allocator: std.mem.Allocator,
    statements: AstArray,

    fn init(allocator: std.mem.Allocator, input: []const u8) !Parser {
        const statements = try AstArray.initCapacity(allocator, 100);
        return Parser{
            .lexer = Lexer.init(input),
            .allocator = allocator,
            .statements = statements,
        };
    }

    fn check_token_str(self: *Parser, token: Token, str: []const u8) bool {
        return std.mem.eql(u8, self.lexer.slice(token), str);
    }

    fn parse(self: *Parser) !void {
        _ = try self.parse_statement();
    }

    fn parse_statement(self: *Parser) !void {
        const _token = self.lexer.next();
        if (_token == null) return;

        const token = _token.?;
        switch (token.token_type) {
            TokenType.Identifier => {
                if (!self.check_token_str(token, "var")) {
                    return ParserError.InvalidToken;
                }
                _ = try self.parse_identifier();
                const _eq_token = self.lexer.next();
                if (_eq_token == null) return;

                const eq_token = _eq_token.?;
                if (eq_token.token_type != TokenType.Operator) {
                    return ParserError.InvalidToken;
                }
                if (!self.check_token_str(eq_token, "=")) {
                    return ParserError.InvalidToken;
                }

                // std.debug.print("identifier: {s}\n", .{@tagName(@as(AstType, identifier))});
                // const value = try self.parse_expression();
                // const var_stmt = Ast{ .Var = .{ .identifier = identifier, .value = value } };
                // try self.statements.append(var_stmt);
            },
            else => {
                return ParserError.InvalidToken;
            },
        }
    }

    fn parse_identifier(self: *Parser) !*const Ast {
        const _token = self.lexer.next();
        if (_token) |token| {
            if (token.token_type != TokenType.Identifier) {
                return ParserError.InvalidToken;
            }
            const node = Ast{ .Identifier = self.lexer.slice(token) };
            try self.statements.append(node);
            return &self.statements.getLast();
        }

        return ParserError.InvalidToken;
    }

    fn deinint(self: *Parser) void {
        self.statements.deinit();
    }
};

test "identifiers and numbers" {
    const string_input = "test test_123 123";
    var lexer = Lexer.init(string_input);
    var token = lexer.next();
    try std.testing.expect(token != null);
    if (token) |_token| {
        try std.testing.expect(_token.token_type == TokenType.Identifier);
        try std.testing.expect(_token.start == 0);
        try std.testing.expect(_token.end == 4);
    }
    token = lexer.next();
    try std.testing.expect(token != null);
    if (token) |_token| {
        try std.testing.expect(_token.token_type == TokenType.Identifier);
        try std.testing.expect(_token.start == 5);
        try std.testing.expect(_token.end == 13);
    }
    token = lexer.next();
    try std.testing.expect(token != null);
    if (token) |_token| {
        try std.testing.expect(_token.token_type == TokenType.Number);
        try std.testing.expect(_token.start == 14);
        try std.testing.expect(_token.end == 17);
    }
    const t = lexer.next();
    try std.testing.expect(t == null);
}

test "operators" {
    const string_input = "+ - * / < <= > >= == != << >>";
    var lexer = Lexer.init(string_input);
    for (0..12) |_| {
        const token = lexer.next();
        try std.testing.expect(token != null);
        if (token) |_token| {
            try std.testing.expect(_token.token_type == TokenType.Operator);
        }
    }
    const t = lexer.next();
    try std.testing.expect(t == null);
}

test "punctuation" {
    const string_input = "{ } ( ) [ ] , ; :";
    var lexer = Lexer.init(string_input);
    var token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.LeftCurly);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.RightCurly);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.LeftParen);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.RightParen);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.LeftBracket);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.RightBracket);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.Comma);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.Semicolon);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.Colon);
    const t = lexer.next();
    try std.testing.expect(t == null);
}

test "var statement" {
    const string_input = "var x = 123;";
    var lexer = Lexer.init(string_input);
    var token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.Identifier);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.Identifier);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.Operator);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.Number);
    token = lexer.next().?;
    try std.testing.expect(token.token_type == TokenType.Semicolon);
    const t = lexer.next();
    try std.testing.expect(t == null);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var parser = try Parser.init(allocator, string_input);

    try parser.parse();
}
