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

extension Expression {
    public static func == (lhs: Expression, rhs: Expression) -> Bool {
        return lhs.string() == rhs.string()
    }
    
    var hashValue: Int {
        return string().hashValue
    }
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


struct BlockStatement: Expression {
    var token:Token
    var statements = [Statement]()
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    func string() -> String {
        var result = ""
        for s in statements {
            result += s.string()
        }
        return result
    }
}

struct IfExpression: Expression {
    var token:Token
    var condition: Expression
    var consequence: BlockStatement
    var alternative: BlockStatement?
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        var result = "if \(condition.string()) \(consequence.string())"
        if let alt = alternative {
            result += "else \(alt.string())"
        }
        return result
    }
}

struct FunctionLiteral: Expression {
    var token:Token
    var parameters:[Identifier]
    var body: BlockStatement
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        var result = ""
        var param:[String] = []
        for p in parameters {
            param.append(p.string())
        }
        let joinParam = param.joined(separator: ", ")
        result += "\(tokenLiteral())(\(joinParam))\(body.string())"
        return result
    }
}

struct CallExpression: Expression {
    var token:Token
    var function:Expression
    var arguments: [Expression]
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        var result = ""
        var args:[String] = []
        for a in arguments {
            args.append(a.string())
        }
        let joinArgs = args.joined(separator: ", ")
        result += "\(function.string())(\(joinArgs))"
        return result
    }
}

struct StringLiteral: Expression {
    var token:Token
    var value:String
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        return token.literal
    }
}


struct ArrayLiteral: Expression {
    var token:Token
    var elements: [Expression]
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        var result = ""
        var elem:[String] = []
        for e in elements {
            elem.append(e.string())
        }
        let joinEle = elem.joined(separator: ", ")
        result += "[\(joinEle)]"
        return result
    }
}

struct IndexExpression: Expression {
    var token:Token
    var left:Expression
    var index:Expression
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        return "(\(left.string())[\(index.string())])"
    }
}

struct HashLiteral: Expression {
    struct ExpressionKey:Hashable {
        static func == (lhs: HashLiteral.ExpressionKey, rhs: HashLiteral.ExpressionKey) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
        var expression:Expression
        var hashValue:Int
    }
    
    var token:Token
    var pairs:[ExpressionKey:Expression]
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
    func string() -> String {
        var result = ""
        var elem:[String] = []

        for (key,value) in pairs {
            elem.append("\(key):\(value.string())")
        }
        let joinEle = elem.joined(separator: ", ")
        result += "{\(joinEle)}"
        return result
    }
}
