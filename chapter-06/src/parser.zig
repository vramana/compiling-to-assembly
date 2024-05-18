const std = @import("std");

const AstType = enum {
    Number,
    UnaryOperator,
    BinaryOperator,
    If,
    Identifier,
    Call,
    Function,
    Block,
    Return,
    Var,
};

fn log(message: []const u8) void {
    if (1 > 2) {
        std.debug.print("{s}\n", .{message});
    }
}

const Ast = union(AstType) {
    Number: i64,
    UnaryOperator: struct {
        op: []const u8,
        expr: *Ast,
    },
    BinaryOperator: struct {
        op: []const u8,
        left: *Ast,
        right: *Ast,
    },
    If: void,
    Identifier: []const u8,
    Call: struct {
        func: *Ast,
        args: []*Ast,
    },
    Function: void,
    Block: AstArray,
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
    MissingToken,
};

pub const Precedence = enum(u8) {
    Lowest,
    Sum,
    Product,
    Prefix,
    Call,
};

pub const Parser = struct {
    lexer: Lexer,
    allocator: std.mem.Allocator,
    nodes: AstArray,

    fn init(allocator: std.mem.Allocator, input: []const u8) !Parser {
        const nodes = try AstArray.initCapacity(allocator, 100);
        return Parser{
            .lexer = Lexer.init(input),
            .allocator = allocator,
            .nodes = nodes,
        };
    }

    fn push_node(self: *Parser, node: Ast) !*Ast {
        try self.nodes.append(node);
        return &self.nodes.items[self.nodes.items.len - 1];
    }

    pub fn getPrecedence(self: *Parser, token: Token) Precedence {
        switch (token.token_type) {
            TokenType.Operator => {
                switch (self.lexer.input[token.start]) {
                    '+', '-' => return Precedence.Sum,
                    '*', '/' => return Precedence.Product,
                    else => return Precedence.Lowest,
                }
            },
            else => return Precedence.Lowest,
        }
    }

    fn check_token_str(self: *Parser, token: Token, str: []const u8) bool {
        return std.mem.eql(u8, self.lexer.slice(token), str);
    }

    fn expect(self: *Parser, str: []const u8) !void {
        const _token = self.lexer.next();
        if (_token) |token| {
            if (!std.mem.eql(u8, self.lexer.slice(token), str)) {
                return ParserError.InvalidToken;
            }
        }

        return ParserError.MissingToken;
    }

    fn expect_token_type(self: *Parser, token_type: TokenType) !void {
        const _token = self.lexer.next();
        if (_token) |token| {
            if (token.token_type != token_type) {
                return ParserError.InvalidToken;
            }
            return;
        }

        log("missing token in expect");

        return ParserError.MissingToken;
    }

    fn parse(self: *Parser) !void {
        _ = try self.parse_body();
    }

    fn parse_body(self: *Parser) !void {
        var nodes = AstArray.init(self.allocator);

        while (true) {
            const _next = self.lexer.peek();
            if (_next == null) break;

            const node = try self.parse_statement();
            try nodes.append(node);
        }

        try self.nodes.append(Ast{ .Block = nodes });
    }

    fn parse_statement(self: *Parser) !Ast {
        const _token = self.lexer.next();
        if (_token == null) return ParserError.MissingToken;

        const token = _token.?;
        switch (token.token_type) {
            TokenType.Identifier => {
                if (!self.check_token_str(token, "var")) {
                    return ParserError.InvalidToken;
                }
                const identifier = try self.parse_identifier();
                const _eq_token = self.lexer.next();
                if (_eq_token == null) return ParserError.InvalidToken;

                const eq_token = _eq_token.?;
                if (eq_token.token_type != TokenType.Operator) {
                    return ParserError.InvalidToken;
                }
                if (!self.check_token_str(eq_token, "=")) {
                    return ParserError.InvalidToken;
                }

                const value = try self.parse_expression(0);

                const semicolon_token = self.lexer.next();
                if (semicolon_token == null) return ParserError.MissingToken;

                if (semicolon_token.?.token_type != TokenType.Semicolon) {
                    return ParserError.InvalidToken;
                }

                // std.debug.print("identifier: {s}\n", .{@tagName(@as(AstType, identifier))});
                // const value = try self.parse_expression();
                const var_stmt = Ast{ .Var = .{ .identifier = identifier, .value = value } };
                return var_stmt;
            },
            else => {
                return ParserError.InvalidToken;
            },
        }
    }

    fn parse_var_statement(self: *Parser) !void {
        _ = self;
    }

    fn parse_expression(self: *Parser, precedence: u8) anyerror!*Ast {
        log("start parsing expression\n");
        var prefix = try self.parse_prefix();

        while (self.lexer.peek() != null and precedence < @intFromEnum(self.getPrecedence(self.lexer.peek().?))) {
            log("inside while block\n");
            prefix = try self.parse_infix(prefix);
        }

        return prefix;
    }

    fn parse_prefix(self: *Parser) !*Ast {
        const _token = self.lexer.peek();

        if (_token) |token| {
            switch (token.token_type) {
                TokenType.Number, TokenType.Identifier => return self.parse_primary_expression(),
                TokenType.LeftParen => {
                    log("left paren");
                    try self.expect_token_type(TokenType.LeftParen);
                    const node = try self.parse_expression(0);
                    try self.expect_token_type(TokenType.RightParen);
                    log("right paren");

                    return node;
                },
                else => {
                    return ParserError.InvalidToken;
                },
            }
        }

        return ParserError.MissingToken;
    }

    fn parse_infix(self: *Parser, left: *Ast) !*Ast {
        const _token = self.lexer.next();
        if (_token) |token| {
            switch (token.token_type) {
                TokenType.Operator => {
                    if (self.check_token_str(token, "+") or
                        self.check_token_str(token, "-") or
                        self.check_token_str(token, "*") or
                        self.check_token_str(token, "/"))
                    {
                        const op = self.lexer.slice(token);

                        log("parsing infix \n");

                        const token_precedence = @intFromEnum(self.getPrecedence(token));
                        const right = try self.parse_expression(token_precedence);

                        log("parsed right \n");

                        const node = Ast{ .BinaryOperator = .{ .op = op, .left = left, .right = right } };

                        return try self.push_node(node);
                    } else {
                        return ParserError.InvalidToken;
                    }
                },
                else => {
                    return ParserError.InvalidToken;
                },
            }
        }

        return ParserError.MissingToken;
    }

    fn parse_primary_expression(self: *Parser) !*Ast {
        const _token = self.lexer.peek();

        if (_token) |token| {
            switch (token.token_type) {
                TokenType.Identifier => {
                    return self.parse_identifier();
                },
                TokenType.Number => {
                    return self.parse_number();
                },
                else => {
                    return ParserError.InvalidToken;
                },
            }
        }

        return ParserError.MissingToken;
    }

    fn parse_identifier(self: *Parser) !*Ast {
        const _token = self.lexer.next();
        if (_token) |token| {
            if (token.token_type != TokenType.Identifier) {
                return ParserError.InvalidToken;
            }
            const node = Ast{ .Identifier = self.lexer.slice(token) };
            return try self.push_node(node);
        }

        return ParserError.MissingToken;
    }

    fn parse_number(self: *Parser) !*Ast {
        const _token = self.lexer.next();
        if (_token) |token| {
            if (token.token_type != TokenType.Number) {
                return ParserError.InvalidToken;
            }
            const number = try std.fmt.parseInt(i64, self.lexer.slice(token), 10);
            const node = Ast{ .Number = number };

            return try self.push_node(node);
        }

        return ParserError.MissingToken;
    }

    fn deinint(self: *Parser) void {
        self.nodes.deinit();
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
    var string_input: []const u8 = "var x = 123;";
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
    _ = try parser.parse_statement();

    string_input = "var x = a;";

    parser = try Parser.init(allocator, string_input);
    _ = try parser.parse_statement();
}

test "expression" {
    log("\n");
    const string_input: []const u8 = "(1 + 2)";

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var parser = try Parser.init(allocator, string_input);

    _ = try parser.parse_expression(0);
}

test "block" {
    log("\n");
    const string_input =
        \\var x = 34;
        \\var z = (1 + 2);
        \\var y = (x * z) / t;
    ;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var parser = try Parser.init(allocator, string_input);
    try parser.parse();
}
