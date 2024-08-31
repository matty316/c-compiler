//
//  File.swift
//  
//
//  Created by matty on 7/31/24.
//

import Foundation

enum ParseError: Error {
    case unexpectedToken(Token)
}

class Parser {
    let tokens: [Token]
    var current = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() throws -> AST.Program {
        let function = try parseFunction()
        try expect(.eof)
        return AST.Program(functionDeclaration: function)
    }
    
    func parseFunction() throws -> AST.Function {
        try expect(.intKeyword)
        let identifier = try parseIdentifier()
        try expect(.openParen)
        try expect(.voidKeyword)
        try expect(.closeParen)
        try expect(.openBrace)
        let statement = try parseStatement()
        try expect(.closeBrace)
        return AST.Function(name: identifier, statement: statement)
    }
    
    func parseIdentifier() throws -> AST.Identifier {
        let token = getToken()
        
        if let identifier = token.luxeme as? String {
            if identifier.isEmpty {
                throw ParseError.unexpectedToken(token)
            }
            return AST.Identifier(value: identifier)
        }
        
        throw  ParseError.unexpectedToken(token)
    }
    
    func parseStatement() throws -> AST.Stmt {
        try expect(.returnKeyword)
        let expression = try parseExpression()
        try expect(.semicolon)
        return AST.Return(expression: expression)
    }
    
    func parseExpression() throws -> AST.Expr {
        switch peek().type {
        case .constant: return try parseConstant()
        case .minus, .tilde: return try parseUnary()
        case .openParen:
            advance()
            let inner = try parseExpression()
            try expect(.closeParen)
            return inner
        default: throw ParseError.unexpectedToken(peek())
        }
    }
    
    func parseUnary() throws -> AST.Unary {
        let token = getToken()
        
        switch token.type {
        case .minus, .tilde: return AST.Unary(expression: try parseExpression(), token: token)
        default: throw ParseError.unexpectedToken(token)
        }
    }
    
    func parseConstant() throws -> AST.Constant {
        let token = getToken()
        
        if let number = token.luxeme as? Int {
            return AST.Constant(value: number)
        }
        
        throw ParseError.unexpectedToken(token)
    }
    
    @discardableResult
    func expect(_ tokenType: TokenType) throws -> Bool {
        if current >= tokens.count {
            return false
        }
        
        if tokens[current].type == tokenType {
            current += 1
            return true
        }
        
        throw ParseError.unexpectedToken(tokens[current])
    }
    
    func getToken() -> Token {
        if current >= tokens.count {
            return Token(type: .eof, luxeme: "")
        }
        
        let token = tokens[current]
        current += 1
        return token
    }
    
    func peek() -> Token {
        if current >= tokens.count {
            return Token(type: .eof, luxeme: "")
        }
        
        return tokens[current]
    }
    
    func advance() {
        current += 1
    }
}
