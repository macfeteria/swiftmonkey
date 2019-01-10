//
//  Evaluator.swift
//  swiftmonkey
//
//  Created by Ter on 10/1/19.
//

import Foundation

public struct Evaluator {
    public func eval(node: Node) -> Object {
        switch node {
        case is Program:
            let program = node as! Program
            return eval(statements: program.statements)
        case is ExpressionStatement:
            let ex = node as! ExpressionStatement
            return eval(node: ex.expression!)
        case is IntegerLiteral:
            let int = node as! IntegerLiteral
            return IntegerObj(value: int.value)
        case is Boolean:
            let boolean = node as! Boolean
            return BooleanObj(value: boolean.value)
        default:
            return NullObj()
        }
    }
    
    func eval(statements:[Statement]) -> Object {
        var result: Object = NullObj()
        for s in statements {
            result = eval(node: s)
        }
        return result
    }
}
