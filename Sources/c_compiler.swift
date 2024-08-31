// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct c_compiler: ParsableCommand {
    @Argument(help: "path to source")
    var path: String
    
    @Flag(help: "run lexer")
    var lex = false
    
    @Flag(help: "run lexer and parser")
    var parse = false
    
    @Flag(help: "run lexer, parser, and tacky")
    var tacky = false
    
    @Flag(help: "run lexer, parser, tacky and codegen")
    var codegen = false
    
    mutating func run() throws {
        let processed = path.replacingOccurrences(of: ".c", with: ".i")
        let assemblyPath = path.replacingOccurrences(of: ".c", with: ".s")
        let output = path.replacingOccurrences(of: ".c", with: "")
        
        let process = shell("gcc -E -P \(path) -o \(processed)")
        print(process)
        
        let source = try String(contentsOfFile: processed)
        
        if lex {
            let tokens = try Lexer(source: source).lex()
            print(tokens)
        } else if parse {
            let tokens = try Lexer(source: source).lex()
            let program = try Parser(tokens: tokens).parse()
            print(program)
        } else if codegen {
            let tokens = try Lexer(source: source).lex()
            let program = try Parser(tokens: tokens).parse()
            let tacky = try TackyGen(program: program).gen()
            let assembly = try Codegen(program: tacky).generate()
            print(assembly)
        } else if tacky {
            let tokens = try Lexer(source: source).lex()
            let program = try Parser(tokens: tokens).parse()
            let tacky = try TackyGen(program: program).gen()
            print(tacky)
        } else {
            let tokens = try Lexer(source: source).lex()
            let program = try Parser(tokens: tokens).parse()
            let tacky = try TackyGen(program: program).gen()
            let assembly = try Codegen(program: tacky).generate()
            let code = CodeEmmiter(program: assembly).emit()
            try code.write(toFile: assemblyPath, atomically: true, encoding: .ascii)
            let assemble = shell("gcc \(assemblyPath) -o \(output)")
            print(assemble)
        }
        
        shell("rm -rf \(processed) \(assemblyPath)")
    }
    
    @discardableResult
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
