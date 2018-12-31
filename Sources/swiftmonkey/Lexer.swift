//
//  Lexer.swift
//  swiftmonkey
//
//  Created by Ter on 30/12/18.
//

import Foundation

class Lexer {
    var input:String = ""
    var position:Int = 0
    var readPosition:Int = 0
    var ch:Character = "\0"
    
    init (input:String) {
        self.input = input
    }
    
    func nextToken() -> Token {
        var tok: Token!
        readChar()
        switch ch {
            case "=": tok = Token(tokenType: TokenType.ASSIGN, literal: ch)
            case ";": tok = Token(tokenType: TokenType.SEMICOLON, literal: ch)
            case "(": tok = Token(tokenType: TokenType.LPAREN, literal: ch)
            case ")": tok = Token(tokenType: TokenType.RPAREN, literal: ch)
            case ",": tok = Token(tokenType: TokenType.COMMA, literal: ch)
            case "+": tok = Token(tokenType: TokenType.PLUS, literal: ch)
            case "{": tok = Token(tokenType: TokenType.LBRACE, literal: ch)
            case "}": tok = Token(tokenType: TokenType.RBRACE, literal: ch)
            case "0": tok = Token(tokenType: TokenType.EOF, literal: ch)
            default:
                tok = Token(tokenType: TokenType.ILLEGAL, literal: ch)
        }
        return tok
    }
    
    @discardableResult
    func readChar() -> Character {
        if readPosition >= input.count {
            ch = "\0"
        } else {
            let index = input.index(input.startIndex, offsetBy: readPosition)
            ch = input[index]
        }
        position = readPosition
        readPosition += 1
        return ch
    }
    
}
