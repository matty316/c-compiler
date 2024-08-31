//
//  assembly.swift
//  c-compiler
//
//  Created by matty on 8/1/24.
//

struct Assembly {
    struct Program {
        let fuctionDefinition: Function
    }
    
    struct Function {
        let name: String
        let instructions: [Instruction]
    }
    
    protocol Instruction {}
    
    struct Ret: Instruction {}
    
    struct Mov: Instruction {
        let src: Operand
        let dst: Operand
    }
    
    struct AllocateStack: Instruction {
        let bytes: Int
    }
    
    struct Unary: Instruction {
        let op: UnaryOp
        let operand: Operand
    }
    
    enum UnaryOp {
        case neg, not
    }
    
    protocol Operand {}
    
    struct Imm: Operand {
        let value: Int
    }
    
    struct Register: Operand {
        let reg: Reg
    }
    
    enum Reg {
        case AX, R10
    }
    
    struct Pseudo: Operand {
        let identifier: String
    }
    
    struct Stack: Operand {
        let offset: Int
    }
}
