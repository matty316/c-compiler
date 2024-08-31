//
//  codeEmitter.swift
//  c-compiler
//
//  Created by matty on 8/1/24.
//

class CodeEmmiter {
    let program: Assembly.Program
    
    init(program: Assembly.Program) {
        self.program = program
    }
    
    func emit() -> String {
        let functionDefinition = functionDefinition()
        return functionDefinition
    }
    
    func functionDefinition() -> String {
        let name = program.fuctionDefinition.name
        let instructions = instructions()
        return """
    .globl _\(name)
_\(name):
\(instructions)
"""
    }
    
    func instructions() -> String {
        var instructions = ""
        for i in program.fuctionDefinition.instructions {
            if let _ = i as? Assembly.Ret {
                instructions.append("\tret\n")
            } else if let i = i as? Assembly.Mov {
                if let src = i.src as? Assembly.Imm {
                    instructions.append("\tmov $\(src.value), %eax\n")
                }
            }
        }
        return instructions
    }
}
