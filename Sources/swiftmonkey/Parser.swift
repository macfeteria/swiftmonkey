//
//  Parser.swift
//  swiftmonkey
//
//  Created by Ter on 3/1/19.
//

import Foundation

typealias prefixParseFn = () -> Expression
typealias infixParseFn = (Expression) -> Expression

enum OperatorOrder:Int {
    case LOWEST = 1
    case EQUALS // ==
    case LESSGREATER // > or <
    case SUM // +
    case PRODUCT // *
    case PREFIX // -X or !X
    case CALL // myFunc(X)
}

public class Parser {
    let lexer:Lexer
    var curToken:Token
    var peekToken:Token
    var errors:[String] = []
    var prefixParseFunctions:[TokenType:prefixParseFn] = [:]
    var infixParseFunctions:[TokenType:infixParseFn] = [:]

    public init(lexer l:Lexer) {
        lexer = l
        curToken = l.nextToken()
        peekToken = l.nextToken()
        registerPrefix(type: TokenType.IDENT, function: parseIdentifier)
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
        case .RETURN:
            return parseReturnStatement()
        default:
            return parseExpressStatement()
        }
    }
    
    func parseExpressStatement() -> ExpressionStatement {
        var statement = ExpressionStatement(token: curToken, expression: nil)
        statement.expression = parseExpression(order: OperatorOrder.LOWEST)
        if isPeekTokenType(type: TokenType.SEMICOLON) {
            nextToken()
        }
        return statement
    }
    
    func parseReturnStatement() -> ReturnStatement? {
        let statement  = ReturnStatement(token: curToken, returnValue: nil)
        nextToken()
        while isCurrentTokenType(type: TokenType.SEMICOLON) == false {
            nextToken()
        }
        return statement
    }
    
    func parseLetStatement() -> LetStatement? {
        let token = curToken
        if expectPeek(type: TokenType.IDENT) == false {
            return nil
        }
        
        let name = Identifier(token: curToken, value: curToken.literal)
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
            peekError(type: type)
            return false
        }
    }
    
    func peekError(type: TokenType) {
        let error = "expected next token to be "
            + peekToken.tokenType.rawValue
            + ", got " + type.rawValue + " instead."
        errors.append(error)
    }
    
    func registerPrefix(type: TokenType, function: @escaping prefixParseFn) {
        prefixParseFunctions[type] = function
    }
    
    func registerInfix(type: TokenType, function: @escaping infixParseFn) {
        infixParseFunctions[type] = function
    }
    
    func parseExpression(order: OperatorOrder) -> Expression? {
        if let prefix = prefixParseFunctions[curToken.tokenType] {
            return prefix()
        }
        return nil
    }
    
    func parseIdentifier() -> Expression {
        return Identifier(token: curToken, value: curToken.literal)
    }
}
