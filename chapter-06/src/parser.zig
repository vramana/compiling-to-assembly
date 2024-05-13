const std = @import("std");

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
                '+' | '-' | '*' | '/' => {
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
                        if (c2 == '=' and c2 == '<') {
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
                        if (c2 == '=' and c2 == '>') {
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
