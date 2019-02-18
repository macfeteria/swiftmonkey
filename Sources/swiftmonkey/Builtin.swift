//
//  Builtin.swift
//  swiftmonkey
//
//  Created by Ter on 17/2/19.
//

import Foundation

let builtins = [
    "len": BuiltinObj(fn: {(args: [Object]) -> Object in
        if args.count != 1 {
            return ErrorObj(message: "wrong number of arguments. got=\(args.count), want=1")
        }
        let arg = args[0].type()
        switch arg {
        case ObjectType.STRING:
             let stringObj = args[0] as! StringObj
            return IntegerObj(value: stringObj.value.count)
        case ObjectType.ARRAY:
            let arrObj = args[0] as! ArrayObj
            return IntegerObj(value: arrObj.elements.count)
        case ObjectType.HASH:
            let hashObj = args[0] as! HashObj
            return IntegerObj(value: hashObj.pairs.count)
        default:
            return ErrorObj(message: "argument to `len` not supported, got \(args[0].type())")
        }
    }),
    "first": BuiltinObj(fn: {(args: [Object]) -> Object in
        if args.count != 1 {
            return ErrorObj(message: "wrong number of arguments. got=\(args.count), want=1")
        }
        if args[0].type() !=  ObjectType.ARRAY {
            return ErrorObj(message: "argument to `first` must be array, got \(args[0].type())")
        }
        let arrObj = args[0] as! ArrayObj
        if arrObj.elements.count > 0 {
            return arrObj.elements[0]
        }
        return Evaluator.NULL
    }),
    "last": BuiltinObj(fn: {(args: [Object]) -> Object in
        if args.count != 1 {
            return ErrorObj(message: "wrong number of arguments. got=\(args.count), want=1")
        }
        if args[0].type() !=  ObjectType.ARRAY {
            return ErrorObj(message: "argument to `last` must be array, got \(args[0].type())")
        }
        let arrObj = args[0] as! ArrayObj
        let count =  arrObj.elements.count
        if count > 0 {
            return arrObj.elements[count - 1]
        }
        return Evaluator.NULL
    }),
    "rest": BuiltinObj(fn: {(args: [Object]) -> Object in
        if args.count != 1 {
            return ErrorObj(message: "wrong number of arguments. got=\(args.count), want=1")
        }
        if args[0].type() !=  ObjectType.ARRAY {
            return ErrorObj(message: "argument to `rest` must be array, got \(args[0].type())")
        }
        let arrObj = args[0] as! ArrayObj
        let count =  arrObj.elements.count
        if count > 0 {
            let lastIndex = arrObj.elements.count
            let newElement = Array(arrObj.elements[1..<lastIndex])
            return ArrayObj(elements: newElement)
        }
        return Evaluator.NULL
    }),
    "push": BuiltinObj(fn: {(args: [Object]) -> Object in
        if args.count != 2 {
            return ErrorObj(message: "wrong number of arguments. got=\(args.count), want=2")
        }
        if args[0].type() !=  ObjectType.ARRAY {
            return ErrorObj(message: "argument to `push` must be array, got \(args[0].type())")
        }
        let arrObj = args[0] as! ArrayObj
        let count =  arrObj.elements.count
        var newElement = arrObj.elements
        newElement.append(args[1])
        return ArrayObj(elements: newElement)
    }),
    "puts": BuiltinObj(fn: {(args: [Object]) -> Object in
        for arg in args {
            print(arg.inspect())
        }
        return Evaluator.NULL
    }),
]
