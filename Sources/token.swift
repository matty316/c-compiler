//
//  File.swift
//  
//
//  Created by matty on 7/25/24.
//

import Foundation

enum TokenType {
    case identifier, constant, intKeyword, voidKeyword, returnKeyword, openParen, closeParen, openBrace, closeBrace, semicolon, tilde, minus, minusMinus, eof
}

struct Token {
    let type: TokenType
    let luxeme: Any
}
