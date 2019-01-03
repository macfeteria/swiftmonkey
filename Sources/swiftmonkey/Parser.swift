//
//  Parser.swift
//  swiftmonkey
//
//  Created by Ter on 3/1/19.
//

import Foundation

public class Parser {
    let lexer:Lexer
    var curToken:Token
    var peekToken:Token

    public init(lexer l:Lexer) {
        lexer = l
        curToken = l.nextToken()
        peekToken = l.nextToken()
    }
    
    func nextToken() {
        curToken = peekToken
        peekToken = lexer.nextToken()
    }
    
    public func parseProgram() -> Program {
        var program = Program()
        
        while curToken.tokenType != TokenType.EOF {
            if let stmt = parseStatement() {
                program.statements.append(stmt)
            }
            nextToken()
        }
        return program
    }
    
    func parseStatement() -> Statement? {
        switch curToken.tokenType {
        case .LET:
            return parseLetStatement()
        default:
            return nil
        }
    }
    
    func parseLetStatement() -> LetStatement? {
        let token = curToken
        if expectPeek(type: TokenType.IDENT) == false {
            return nil
        }
        
        let name = Identifier(value: curToken.literal , token: curToken)
        if expectPeek(type: TokenType.ASSIGN) == false {
            return nil
        }
        
        while isCurrentTokenType(type: TokenType.SEMICOLON) == false {
            nextToken()
        }
        
        return LetStatement(token: token, name: name, value: nil)
    }
    
    func isCurrentTokenType(type: TokenType) -> Bool {
       return curToken.tokenType == type
    }

    func isPeekTokenType(type: TokenType) -> Bool {
        return peekToken.tokenType == type
    }
    
    func expectPeek(type: TokenType) -> Bool {
        if isPeekTokenType(type: type) {
            nextToken()
            return true
        } else {
            return false
        }
    }
    
}
