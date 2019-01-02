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
            var tok:Token = lexer.nextToken()
            
            while tok.tokenType != TokenType.EOF {
                print("\(tok.tokenType) \(tok.literal)")
                tok = lexer.nextToken()
            }
        }
    } while (input != nil)
}
