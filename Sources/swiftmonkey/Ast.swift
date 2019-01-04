//
//  Ast.swift
//  swiftmonkey
//
//  Created by Ter on 3/1/19.
//

import Foundation

public protocol Node {
    func tokenLiteral() -> String
}

public protocol Statement: Node {
    func statementNode() -> Void
}

public protocol Expression: Node {
    func expressionNode() -> Void
}

public struct Program: Node {
    public var statements = [Statement]()
    public func tokenLiteral() -> String {
        if statements.count > 0 {
            return statements[0].tokenLiteral()
        } else {
            return ""
        }
    }
}

struct Identifier: Statement  {
    var value:String
    var token:Token
    func statementNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
}

struct LetStatement: Statement {
    var token: Token
    var name: Identifier
    var value: Expression?
    
    func statementNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
}

struct ReturnStatement: Statement {
    var token:Token
    func tokenLiteral() -> String {
        return token.literal
    }
    func statementNode() {
    }
}
