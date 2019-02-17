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
]
