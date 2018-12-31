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
            case "=": tok = Token(tokenType: TokenType.ASSIGN, literal: String(ch))
            case ";": tok = Token(tokenType: TokenType.SEMICOLON, literal: String(ch))
            case "(": tok = Token(tokenType: TokenType.LPAREN, literal: String(ch))
            case ")": tok = Token(tokenType: TokenType.RPAREN, literal: String(ch))
            case ",": tok = Token(tokenType: TokenType.COMMA, literal: String(ch))
            case "+": tok = Token(tokenType: TokenType.PLUS, literal: String(ch))
            case "{": tok = Token(tokenType: TokenType.LBRACE, literal: String(ch))
            case "}": tok = Token(tokenType: TokenType.RBRACE, literal: String(ch))
            case "0": tok = Token(tokenType: TokenType.EOF, literal: String(ch))
            default:
                tok = Token(tokenType: TokenType.ILLEGAL, literal: String(ch))
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
