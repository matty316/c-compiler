//
//  File.swift
//  
//
//  Created by matty on 7/25/24.
//

import Foundation

enum LexerError: Error {
    case General(String)
}

class Lexer {
    let source: String
    var start: String.Index
    var current: String.Index
    var line = 1
    
    var isAtEnd: Bool {
        return current >= source.endIndex
    }
    
    init(source: String) {
        self.source = source
        self.start = source.startIndex
        self.current = source.startIndex
    }
    
    func lex() throws -> [Token] {
        var tokens = [Token]()
        while !isAtEnd {
            start = current
            let c = advance()
            
            switch c {
            case ";":
                tokens.append(Token(type: .semicolon, luxeme: ";"))
            case "{":
                tokens.append(Token(type: .openBrace, luxeme: "{"))
            case "}":
                tokens.append(Token(type: .closeBrace, luxeme: "}"))
            case "(":
                tokens.append(Token(type: .openParen, luxeme: "("))
            case ")":
                tokens.append(Token(type: .closeParen, luxeme: ")"))
            case "~":
                tokens.append(Token(type: .tilde, luxeme: "~"))
            case "-":
                if peek() == "-" {
                    tokens.append(Token(type: .minusMinus, luxeme: "--"))
                    advance()
                } else {
                    tokens.append(Token(type: .minus, luxeme: "-"))
                }
            case " ", "\t", "\r":
                break
            case "\n":
                line += 1
            default:
                if isAlpha(c: c) {
                    tokens.append(identifier())
                } else if isNumeric(c: c) {
                    tokens.append(try number())
                } else {
                    throw LexerError.General("Unexpected Token \(c) at line \(line)")
                }
            }
        }
        tokens.append(Token(type: .eof, luxeme: ""))
        return tokens
    }
    
    @discardableResult
    func advance() -> Character {
        let prev = current
        current = source.index(after: current)
        return source[prev]
    }
    
    func matchChar(expected: Character) -> Bool {
        if isAtEnd { return false }
        if source[current] != expected { return false }
        
        current = source.index(after: current)
        return true
    }
    
    func peek() -> Character {
        if isAtEnd { return "\0" }
        return source[current]
    }
    
    func peekNext() -> Character {
        if source.index(after: current) >= source.endIndex {
            return "\0"
        }
        return source[source.index(after: current)]
    }
    
    func isAlpha(c: Character) -> Bool {
        return "a" <= c && c <= "z" || "A" <= c && c <= "Z" || c == "_"
    }
    
    func isNumeric(c: Character) -> Bool {
        return "0" <= c && c <= "9"
    }
    
    func isAlphaNumeric(c: Character) -> Bool {
        return isNumeric(c: c) || isAlpha(c: c)
    }
    
    func identifier() -> Token {
        while isAlphaNumeric(c: peek()) { advance() }
        switch source[start] {
        case "i":
            return checkKeyword(begin: 1, length: 2, rest: "nt", tokenType: .intKeyword)
        case "r":
            return checkKeyword(begin: 1, length: 5, rest: "eturn", tokenType: .returnKeyword)
        case "v":
            return checkKeyword(begin: 1, length: 3, rest: "oid", tokenType: .voidKeyword)
        default:
            return Token(type: .identifier, luxeme: String(source[start..<current]))
        }
    }
    
    func checkKeyword(begin: Int, length: Int, rest: String, tokenType: TokenType) -> Token {
        if source[start..<current].count == begin + length && source[source.index(start, offsetBy: begin)..<current] == rest {
            return Token(type: tokenType, luxeme: String(source[start..<current]))
        }
        
        return Token(type: .identifier, luxeme: String(source[start..<current]))
    }
    
    func number() throws -> Token {
        while isNumeric(c: peek()) {
            advance()
        }
        
        if isAlpha(c: peek()) {
            throw LexerError.General("Invalid token at line \(line)")
        }

        return Token(type: .constant, luxeme: Int(source[start..<current]))
    }
}
