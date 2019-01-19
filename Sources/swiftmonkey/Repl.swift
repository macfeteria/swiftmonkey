//
//  Repl.swift
//  swiftmonkey
//
//  Created by Ter on 2/1/19.
//

import Foundation

let PROMPT = ">> "

public func startRepl () {
    
    var input:String?
    let env = Environment()

    repeat {
        print(PROMPT,terminator:"")
        input = readLine(strippingNewline:false)
        if let code = input , code.count > 0 {
            let lexer = Lexer(input: code + "\0")
            let parser = Parser(lexer: lexer)
            let program = parser.parseProgram()
            if parser.errors.count != 0 {
                for e in parser.errors {
                    print("\t \(e)")
                }
            } else {
                let evaluated = Evaluator()
                let result = evaluated.eval(program: program, environment: env)
                if result.type() != ObjectType.NULL {
                    print(result.inspect())
                }
            }
        }
    } while (input != nil)
}
