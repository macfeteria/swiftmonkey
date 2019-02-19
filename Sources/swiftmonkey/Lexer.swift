//
//  Lexer.swift
//  swiftmonkey
//
//  Created by Ter on 30/12/18.
//

import Foundation

public class Lexer {
    var input:String = ""
    var position:Int = 0
    var readPosition:Int = 0
    var ch:Character = "\0"
    
    public init (input:String) {
        self.input = input
        if input.count > 0 {
            readChar()
        }
    }
    
    func isLetter(char: Character) -> Bool {
        return Character("a") <= char && char <= Character("z") ||
               Character("A") <= char && char <= Character("Z") ||
               Character("_") == char
    }
    
    func isDigit(char: Character) -> Bool {
        return Character("0") <= char && char <= Character("9")
    }
    
    public func nextToken() -> Token {
        var tok: Token!
        skipWhitespace()
        switch ch {
            case "=":
                if peekChar() == "=" {
                    let curent = ch
                    readChar()
                    tok = Token(type: TokenType.EQUAL, literal: String("\(curent)\(ch)"))
                } else {
                    tok = Token(type: TokenType.ASSIGN, literal: String(ch))
                }
            case ";": tok = Token(type: TokenType.SEMICOLON, literal: String(ch))
            case "(": tok = Token(type: TokenType.LPAREN, literal: String(ch))
            case ")": tok = Token(type: TokenType.RPAREN, literal: String(ch))
            case ",": tok = Token(type: TokenType.COMMA, literal: String(ch))

            case "+": tok = Token(type: TokenType.PLUS, literal: String(ch))
            case "-": tok = Token(type: TokenType.MINUS, literal: String(ch))
            case "/": tok = Token(type: TokenType.SLASH, literal: String(ch))
            case "*": tok = Token(type: TokenType.ASTERISK, literal: String(ch))
            case "!":
                if peekChar() == "=" {
                    let curent = ch
                    readChar()
                    tok = Token(type: TokenType.NOTEQUAL, literal: String("\(curent)\(ch)"))
                } else {
                    tok = Token(type: TokenType.BANG, literal: String(ch))
                }
            case "<": tok = Token(type: TokenType.LESSTHAN, literal: String(ch))
            case ">": tok = Token(type: TokenType.GREATER, literal: String(ch))

            case "{": tok = Token(type: TokenType.LBRACE, literal: String(ch))
            case "}": tok = Token(type: TokenType.RBRACE, literal: String(ch))
            case "\0": tok = Token(type: TokenType.EOF, literal: String(ch))
            case "\"":
                let lit = readString()
                return Token(type: TokenType.STRING, literal: lit)
            case "[": tok = Token(type: TokenType.LBRACKET, literal: String(ch))
            case "]": tok = Token(type: TokenType.RBRACKET, literal: String(ch))
            case ":": tok = Token(type: TokenType.COLON, literal: String(ch))
            default:
                if isLetter(char:ch) {
                    let lit = readIdentifier()
                    let type = lookupIdent(ident: lit)
                    return Token(type: type, literal: lit)
                } else if isDigit(char:ch) {
                    let lit = readNumber()
                    return Token(type: TokenType.INT, literal: lit)
                } else {
                    return Token(type: TokenType.ILLEGAL, literal: String(ch))
                }
        }
        readChar()
        return tok
    }
    
    func readIdentifier() -> String {
        var iden = ""
        while (isLetter(char: ch)) {
            iden.append(ch)
            readChar()
        }
        return iden
    }
    
    func readString() -> String {
        var text = ""
        while (true) {
            readChar()
            if ch == "\"" || ch == "\0" {
                readChar()
                break
            } else {
                text.append(ch)
            }
        }
        
        return text
    }
    
    
    func readNumber() -> String {
        var num = ""
        while isDigit(char: ch) {
            num.append(ch)
            readChar()
        }
        return num
    }

    func skipWhitespace() {
        while ((ch == " ") || (ch == "\n") ||
               (ch == "\t") || (ch == "\r")){
            readChar()
        }
    }
    
    func peekChar() -> Character {
        if readPosition >= input.count {
            return "\0"
        } else {
            let index = input.index(input.startIndex, offsetBy: readPosition)
            return input[index]
        }
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
