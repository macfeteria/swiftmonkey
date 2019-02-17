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

    public func eval(node: Node, environment env: Environment) -> Object {
        switch node {
        case is Program:
            let program = node as! Program
            return eval(program: program, environment: env)
        case is ExpressionStatement:
            let ex = node as! ExpressionStatement
            return eval(node: ex.expression!, environment: env)
        case is IntegerLiteral:
            let int = node as! IntegerLiteral
            return IntegerObj(value: int.value)
        case is Boolean:
            let boolean = node as! Boolean
            return boolean.value ? Evaluator.TRUE : Evaluator.FALSE
        case is PrefixExpression:
            let pre = node as! PrefixExpression
            let right = eval(node: pre.right!, environment: env)
            if isError(obj: right) { return right }
            return evalPrefixExpression(oper: pre.operatorLiteral, right: right)
        case is InfixExpression:
            let infix = node as! InfixExpression
            let left = eval(node: infix.left, environment: env)
            if isError(obj: left) { return left }
            let right = eval(node: infix.right!, environment: env)
            if isError(obj: right) { return right }
            return evalInfixExpression(oper: infix.operatorLiteral, left: left, right: right)
        case is BlockStatement:
            let block = node as! BlockStatement
            return evalBlockStatement(block: block, environment: env)
        case is IfExpression:
            let ifEx = node as! IfExpression
            return evalIfExpression(expression: ifEx, environment: env)
        case is ReturnStatement:
            let returnStmt = node as! ReturnStatement
            let value = eval(node:returnStmt.returnValue!, environment: env)
            if isError(obj: value) { return value }
            return ReturnValueObj(value: value)
        case is LetStatement:
            let letStmt = node as! LetStatement
            let value = eval(node: letStmt.value!, environment: env)
            if isError(obj: value) { return value }
            env.set(name: letStmt.name.value, object: value)
        case is Identifier:
            let iden = node as! Identifier
            return evalIdentifier(node: iden, environment: env)
        case is FunctionLiteral:
            let funcLit = node as! FunctionLiteral
            let params = funcLit.parameters
            let body = funcLit.body
            return FunctionObj(parameters: params, body: body, env: env)
        case is CallExpression:
            let call = node as! CallExpression
            let function = eval(node: call.function, environment: env)
            if isError(obj: function) {
                return function
            }
            let args = evalExpression(args: call.arguments, environment: env)
            if args.count == 1 && isError(obj: args[0]) {
                return args[0]
            }
            return applyFunction(fn: function, args: args)
        case is ArrayLiteral:
            let array = node as! ArrayLiteral
            let elements = evalExpression(args:array.elements , environment: env)
            if elements.count == 1 && isError(obj: elements[0]) {
                return elements[0]
            }
            return ArrayObj(elements: elements)
        case is StringLiteral:
            let str = node as! StringLiteral
            return StringObj(value: str.value)
        case is IndexExpression:
            let indexEx = node as! IndexExpression
            let left = eval(node: indexEx.left, environment: env)
            if isError(obj: left) {
                return left
            }
            let index = eval(node: indexEx.index, environment: env)
            if isError(obj: index) {
                return index
            }
            return evalIndexExpression(object: left, index: index)
        case is HashLiteral:
            let hash = node as! HashLiteral
            return evalHashLiteral(hash: hash, environment: env)
        default:
            return Evaluator.NULL
        }
        return Evaluator.NULL
    }
    
    func applyFunction(fn: Object, args: [Object]) -> Object {
        switch fn.type() {
        case ObjectType.FUNCTION :
            if let function = fn as? FunctionObj {
                let extendedEnv = extendedFunctionEnv(fn: function, args: args)
                let evaluated = eval(node: function.body, environment: extendedEnv)
                return unwrapReturnValue(obj: evaluated)
            }
        case ObjectType.BUILTIN:
            if let builtin = fn as? BuiltinObj {
                return builtin.fn(args)
            }
        default:
             return ErrorObj(message:"not a function: \(fn.type())")
        }
        return ErrorObj(message:"not a function: \(fn.type())")
    }
    
    func unwrapReturnValue(obj: Object) -> Object {
        if let returnValue = obj as? ReturnValueObj {
            return returnValue.value
        }
        return obj
    }
    
    func extendedFunctionEnv(fn: FunctionObj, args: [Object]) -> Environment {
        let env = Environment()
        env.outer = fn.env
        let param = fn.parameters
        for i in 0 ..< param.count {
            env.set(name: param[i].value, object: args[i])
        }
        return env
    }
    
    func evalExpression(args: [Expression], environment env: Environment) -> [Object] {
        var result:[Object] = []
        for a in args {
            let evaluated = eval(node: a, environment: env)
            if isError(obj: evaluated) {
                return [evaluated]
            }
            result.append(evaluated)
        }
        return result
    }
    
    func evalIdentifier(node: Identifier, environment env: Environment) -> Object {
        let (iden,ok) = env.get(name: node.value)
        if ok {
            return iden
        }
        
        if let builtin = builtins[node.value] {
            return builtin
        }
        return ErrorObj(message: "identifier not found: \(node.value)")
    }
    
    func eval(program:Program, environment env: Environment) -> Object {
        var result: Object = NullObj()
        for s in program.statements {
            result = eval(node: s, environment: env)
            if let returnValue = result as? ReturnValueObj {
                return returnValue.value
            }
            if let error = result as? ErrorObj {
                return error
            }
        }
        return result
    }
    
    func evalBlockStatement(block: BlockStatement, environment env: Environment) -> Object {
        var result: Object = NullObj()
        for s in block.statements {
            result = eval(node: s, environment: env)
            let type = result.type()
            if type == ObjectType.ERROR || type == ObjectType.RETURN_VALUE {
                return result
            }
        }
        return result
    }
    
    func evalInfixExpression(oper: String, left:Object, right: Object) -> Object {
        if left.type() == ObjectType.INTEGER && right.type() == ObjectType.INTEGER {
            return evalIntegerExpression(oper: oper, left: left, right: right)
        }
        if left.type() == ObjectType.STRING && right.type() == ObjectType.STRING {
            return evalStringExpression(oper: oper, left: left, right: right)
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
        if left.type() != right.type() {
            return ErrorObj(message: "type mismatch: \(left.type()) \(oper) \(right.type())")
        }

        return ErrorObj(message: "unknow operator: \(left.type()) \(oper) \(right.type())")
    }

    
    func evalPrefixExpression(oper: String, right: Object) -> Object {
        switch oper {
        case "!" :
            return evalBangOperator(right: right)
        case "-" :
            return evalMinusPrefixOperator(right: right)
        default:
            return ErrorObj(message: "unknow operator: \(oper) \(right.type())")
        }
    }

    func evalStringExpression(oper: String, left:Object, right: Object) -> Object {
        let leftValue = (left as! StringObj).value
        let rightValue = (right as! StringObj).value
        if oper != "+" {
            return ErrorObj(message: "unknow operator: \(left.type()) \(oper) \(right.type())")
        }
        return StringObj(value: leftValue + rightValue)
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
            return ErrorObj(message: "unknow operator: \(left.type()) \(oper) \(right.type())")
        }
    }
    func evalMinusPrefixOperator(right: Object) -> Object {
        if right.type() != ObjectType.INTEGER {
            return ErrorObj(message: "unknow operator: -\(right.type())")
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
    
    func evalIfExpression(expression: IfExpression, environment env: Environment) -> Object {
        let condition = eval(node: expression.condition, environment: env)
        if isError(obj: condition) { return condition }
        if isTruthy(obj: condition) {
            return eval(node: expression.consequence, environment: env)
        } else if let alter = expression.alternative {
            return eval(node: alter, environment: env)
        } else {
            return Evaluator.NULL
        }
    }
    
    func evalIndexExpression(object: Object, index: Object) -> Object {
        if let array = object as? ArrayObj, let idx = index as? IntegerObj {
            if idx.value >= array.elements.count || idx.value < 0 {
                return Evaluator.NULL
            }
            return array.elements[idx.value]
        }
        if let hash = object as? HashObj {
            if let key = index as? ObjectHashable {
                if let item = hash.pairs[key.hashKey()] {
                    return item.value
                }
                return Evaluator.NULL
            }
            return ErrorObj(message: "unusable as hash key: \(index.type())")
        }
        return ErrorObj(message: "index operator not supported: \(object.type())")
    }

    func evalHashLiteral(hash: HashLiteral, environment env: Environment) -> Object {
        var pairs:[HashKey: HashPair] = [:]
        for (keyNode, valueNode) in hash.pairs {
            let key = eval(node: keyNode.expression, environment: env)
            if isError(obj: key) {
               return key
            }
            let value = eval(node: valueNode, environment: env)
            if isError(obj: value) {
                return value
            }
            
            if key is ObjectHashable {
                let keyObject = (key as! ObjectHashable).hashKey()
                pairs[keyObject] = HashPair(key: key, value: value)
            }
        }
        return HashObj(pairs: pairs)
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
    
    func isError(obj: Object) -> Bool {
        return obj.type() == ObjectType.ERROR
    }
    
}
