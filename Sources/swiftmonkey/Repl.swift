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

    repeat {
        print(PROMPT,terminator:"")
        input = readLine()
        if let code = input , code.count > 0{
            let lexer = Lexer(input: code)
            let parser = Parser(lexer: lexer)
            let program = parser.parseProgram()
            if parser.errors.count != 0 {
                for e in parser.errors {
                    print("\t \(e)")
                }
            } else {
                let evaluated = Evaluator()
                let result = evaluated.eval(node: program)
                print(result.inspect())
            }
        }
    } while (input != nil)
}
