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
        input = readLine()
        if let code = input , code.count > 0{
//            if code != code.alphanumeric {
//                print("\t Code contains special character")
//                continue
//            }
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
                print(result.inspect())
            }
        }
    } while (input != nil)
}

extension String {
    var alphanumeric: String {
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
    }
}
