//
//  tacky.swift
//  c-compiler
//
//  Created by matty on 8/2/24.
//

struct Tacky {
    struct Program {
        let functionDefinition: Function
    }
    
    struct Function {
        let name: String
        let body: [Instruction]
    }
    
    protocol Instruction {}
    
    struct Return: Instruction {
        let value: Val
    }
    
    struct Unary: Instruction {
        let op: UnaryOperator
        let src: Val
        let dst: Val
    }
        
    enum UnaryOperator {
        case negate
        case complement
    }

    protocol Val {}
    
    struct Constant: Val {
        let value: Int
    }
    
    struct Var: Val {
        let identifier: String
    }
}

enum TackyError: Error {
    case invalidExpression
    case invalidUnaryOp
    
}

class TackyGen {
    let program: AST.Program
    var tempCounter = 0
    var instructions: [Tacky.Instruction] = []
    
    init(program: AST.Program) {
        self.program = program
    }
    
    func gen() throws -> Tacky.Program {
        let functionDefinition = Tacky.Function(name: program.functionDeclaration.name.value, body: try genInstructions())
        return Tacky.Program(functionDefinition: functionDefinition)
    }
    
    func genInstructions() throws -> [Tacky.Instruction] {
        if let returnStmt = program.functionDeclaration.statement as? AST.Return {
            instructions.append(Tacky.Return(value: try genVal(expr: returnStmt.expression)))
        }
        
        return instructions
    }
    
    func genVal(expr: AST.Expr) throws -> Tacky.Val {
        if let expr = expr as? AST.Constant {
            return Tacky.Constant(value: expr.value)
        } else if let expr = expr as? AST.Unary {
            let src = try genVal(expr: expr.expression)
            let dst_name = makeTemp()
            let dst = Tacky.Var(identifier: dst_name)
            let op = try getOp(tokenType: expr.token.type)
            instructions.append(Tacky.Unary(op: op, src: src, dst: dst))
            return dst
        }
        
        throw TackyError.invalidExpression
    }
    
    func makeTemp() -> String {
        let current = tempCounter
        tempCounter += 1
        return "tmp.\(current)"
    }
    
    func getOp(tokenType: TokenType) throws -> Tacky.UnaryOperator {
        switch tokenType {
        case .minus: return .negate
        case .tilde: return .complement
        default: throw TackyError.invalidUnaryOp
        }
    }
}
