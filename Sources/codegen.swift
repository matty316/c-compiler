//
//  codegen.swift
//  c-compiler
//
//  Created by matty on 8/1/24.
//

enum CodeGeneraterError: Error {
    case invalidExpression, invalidOperand
}

class Codegen {
    let program: Tacky.Program
    
    init(program: Tacky.Program) {
        self.program = program
    }
    
    func generate() throws -> Assembly.Program {
        let function = try generateFunction()
        
        let assemblyProgram = Assembly.Program(fuctionDefinition: function)
        
    }
    
    func generateFunction() throws -> Assembly.Function {
        return Assembly.Function(name: program.functionDefinition.name, instructions: try generateInstructions())
    }
    
    func generateInstructions() throws -> [Assembly.Instruction] {
        var instructions = [Assembly.Instruction]()
        
        for i in program.functionDefinition.body {
            if let returnInstuction = i as? Tacky.Return {
                instructions.append(Assembly.Mov(src: try generateOperand(returnInstuction.value), dst: Assembly.Register(reg: .AX)))
                instructions.append(Assembly.Ret())
            } else if let unary = i as? Tacky.Unary {
                instructions.append(Assembly.Mov(src: try generateOperand(unary.src), dst: try generateOperand(unary.dst)))
                instructions.append(Assembly.Unary(op: generateUnaryOp(unary.op), operand: try generateOperand(unary.dst)))
            }
        }
        
        return instructions
    }
    
    func generateOperand(_ val: Tacky.Val) throws -> Assembly.Operand {
        if let constant = val as? Tacky.Constant {
            return Assembly.Imm(value: constant.value)
        } else if let tackyVar = val as? Tacky.Var {
            return Assembly.Pseudo(identifier: tackyVar.identifier)
        }
        throw CodeGeneraterError.invalidOperand
    }
    
    func generateUnaryOp(_ op: Tacky.UnaryOperator) -> Assembly.UnaryOp {
        switch op {
        case .negate: return .neg
        case .complement: return .not
        }
    }
    
    func replacePsuedoRegisters(assemblyProgram: Assembly.Program) -> Assembly.Program {
        let instructions = assemblyProgram.fuctionDefinition.instructions
        var instructionList = [Assembly.Instruction]()
        let stackOp = 
        for i in instructions {
            switch i {
            case let mov as Assembly.Mov:
                instructionList(
            
            }
        }
    }
}
