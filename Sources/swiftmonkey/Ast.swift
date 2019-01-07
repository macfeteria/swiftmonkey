//
//  Ast.swift
//  swiftmonkey
//
//  Created by Ter on 3/1/19.
//

import Foundation

public protocol Node {
    func tokenLiteral() -> String
    func string() -> String
}

public protocol Statement: Node {
    func statementNode() -> Void
}

public protocol Expression: Node {
    func expressionNode() -> Void
}

public struct Program: Node  {
    public var statements = [Statement]()
    public func tokenLiteral() -> String {
        if statements.count > 0 {
            return statements[0].tokenLiteral()
        } else {
            return ""
        }
    }
    public func string() -> String {
        var result = ""
        for s in statements {
            result += s.string()
        }
        return result
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

    func string() -> String {
        var result = "\(token.literal) \(name.string()) = "
        if let value = value {
            result += value.string()
        }
        result += ";"
        return result
    }

}

struct ReturnStatement: Statement {
    var token:Token
    var returnValue:Expression?
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func statementNode() {
    }

    func string() -> String {
        var result = "\(token.literal) "
        if let value = returnValue {
            result += value.string()
        }
        result += ";"
        return result
    }
}


struct ExpressionStatement: Statement {
    var token:Token
    var expression:Expression?
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func statementNode() {
    }
    
    func string() -> String {
        if let value = expression {
            return value.string()
        }
        return ""
    }
}

// MARK: Expression
struct Identifier: Expression  {
    var token:Token
    var value:String
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        return value
    }
}

struct IntegerLiteral: Expression {
    var token:Token
    var value:Int
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        return token.literal
    }
}

struct Boolean: Expression {
    var token:Token
    var value:Bool
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        return token.literal
    }
}

struct PrefixExpression: Expression {
    var token:Token
    var operatorLiteral:String
    var right: Expression?
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        let rightEx = right?.string() ?? ""
        let result = "(\(operatorLiteral)\(rightEx))"
        return result
    }
}

struct InvalidExpression: Expression {
    let token:Token = Token(tokenType: TokenType.ILLEGAL, literal: "")
    func expressionNode() {
    }
    func tokenLiteral() -> String {
        return token.literal
    }
    func string() -> String {
        return ""
    }
}

struct InfixExpression: Expression {
    var token:Token
    var left: Expression
    var operatorLiteral:String
    var right: Expression?
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        let rightEx = right?.string() ?? ""
        let result = "(\(left.string()) \(operatorLiteral) \(rightEx))"
        return result
    }
}
