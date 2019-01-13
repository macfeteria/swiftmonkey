//
//  Evaluator.swift
//  swiftmonkey
//
//  Created by Ter on 10/1/19.
//

import Foundation

public struct Evaluator {
    static let TRUE = BooleanObj(value: true)
    static let FALSE = BooleanObj(value: false)
    static let NULL = NullObj()

    public func eval(node: Node) -> Object {
        switch node {
        case is Program:
            let program = node as! Program
            return eval(program: program)
        case is ExpressionStatement:
            let ex = node as! ExpressionStatement
            return eval(node: ex.expression!)
        case is IntegerLiteral:
            let int = node as! IntegerLiteral
            return IntegerObj(value: int.value)
        case is Boolean:
            let boolean = node as! Boolean
            return boolean.value ? Evaluator.TRUE : Evaluator.FALSE
        case is PrefixExpression:
            let pre = node as! PrefixExpression
            let right = eval(node: pre.right!)
            return evalPrefixExpression(oper: pre.operatorLiteral, right: right)
        case is InfixExpression:
            let infix = node as! InfixExpression
            let left = eval(node: infix.left)
            let right = eval(node: infix.right!)
            return evalInfixExpression(oper: infix.operatorLiteral, left: left, right: right)
        case is BlockStatement:
            let block = node as! BlockStatement
            return evalBlockStatement(block: block)
        case is IfExpression:
            let ifEx = node as! IfExpression
            return evalIfExpression(expression: ifEx)
        case is ReturnStatement:
            let returnStmt = node as! ReturnStatement
            let value = eval(node:returnStmt.returnValue!)
            return ReturnValueObj(value: value)
        default:
            return Evaluator.NULL
        }
    }
    
    func eval(program:Program) -> Object {
        var result: Object = NullObj()
        for s in program.statements {
            result = eval(node: s)
            if let returnValue = result as? ReturnValueObj {
                return returnValue.value
            }
        }
        return result
    }
    
    func evalBlockStatement(block: BlockStatement) -> Object {
        var result: Object = NullObj()
        for s in block.statements {
            result = eval(node: s)
            let type = result.type()
            if type != ObjectType.NULL && type == ObjectType.RETURN_VALUE {
                return result
            }
        }
        return result
    }
    
//    func eval(statements:[Statement]) -> Object {
//        var result: Object = NullObj()
//        for s in statements {
//            result = eval(node: s)
//        }
//        return result
//    }
    
    func evalInfixExpression(oper: String, left:Object, right: Object) -> Object {
        if left.type() == ObjectType.INTEGER && right.type() == ObjectType.INTEGER {
            return evalIntegerExpression(oper: oper, left: left, right: right)
        }

        if left.type() == ObjectType.BOOLEAN && right.type() == ObjectType.BOOLEAN {
            let leftBool = left as! BooleanObj
            let rightBool = right as! BooleanObj
            if oper == "==" {
                return leftBool.value == rightBool.value ? Evaluator.TRUE : Evaluator.FALSE
            }
            if oper == "!=" {
                return leftBool.value != rightBool.value ? Evaluator.TRUE : Evaluator.FALSE
            }
        }

        return Evaluator.NULL
    }

    
    func evalPrefixExpression(oper: String, right: Object) -> Object {
        switch oper {
        case "!" :
            return evalBangOperator(right: right)
        case "-" :
            return evalMinusPrefixOperator(right: right)
        default:
            return Evaluator.NULL
        }
    }

    func evalIntegerExpression(oper: String, left:Object, right: Object) -> Object {
        let leftValue = (left as! IntegerObj).value
        let rightValue = (right as! IntegerObj).value
        switch oper {
        case "+" :
            return IntegerObj(value: leftValue + rightValue)
        case "-" :
            return IntegerObj(value: leftValue - rightValue)
        case "*" :
            return IntegerObj(value: leftValue * rightValue)
        case "/" :
            return IntegerObj(value: leftValue / rightValue)
        case "<" :
            return leftValue < rightValue ? Evaluator.TRUE : Evaluator.FALSE
        case ">" :
            return leftValue > rightValue ? Evaluator.TRUE : Evaluator.FALSE
        case "==" :
            return leftValue == rightValue ? Evaluator.TRUE : Evaluator.FALSE
        case "!=" :
            return leftValue != rightValue ? Evaluator.TRUE : Evaluator.FALSE
        default:
            return Evaluator.NULL
        }
    }
    func evalMinusPrefixOperator(right: Object) -> Object {
        if right.type() != ObjectType.INTEGER {
            return Evaluator.NULL
        }
        let intObj = right as! IntegerObj
        return IntegerObj(value: -intObj.value)
    }
    
    func evalBangOperator(right: Object) -> Object {
        switch right {
        case is BooleanObj:
            let bool = right as! BooleanObj
            return bool.value ? Evaluator.FALSE : Evaluator.TRUE
        case is NullObj:
            return Evaluator.TRUE
        default:
            return Evaluator.FALSE
        }
    }
    
    func evalIfExpression(expression: IfExpression) -> Object {
        let condition = eval(node: expression.condition)
        if isTruthy(obj: condition) {
            return eval(node: expression.consequence)
        } else if let alter = expression.alternative {
            return eval(node: alter)
        } else {
            return Evaluator.NULL
        }
    }
    
    func isTruthy(obj: Object) -> Bool {
        if obj is NullObj {
            return false
        }
        if let boolObj = obj as? BooleanObj {
          return boolObj.value
        }
        if let intObj = obj as? IntegerObj {
            return intObj.value != 0
        }
        return true
    }
}
