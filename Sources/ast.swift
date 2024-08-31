//
//  ast.swift
//
//
//  Created by matty on 7/31/24.
//

import Foundation

struct AST {
    struct Program {
        let functionDeclaration: Function
    }

    protocol Stmt {}

    struct Function {
        let name: Identifier
        let statement: Stmt
    }

    struct Return: Stmt {
        let expression: Expr
    }

    protocol Expr {}

    struct Identifier {
        let value: String
    }

    struct Constant: Expr {
        let value: Int
    }

    struct Unary: Expr {
        let expression: Expr
        let token: Token
    }
}
