//
//  Object.swift
//  swiftmonkey
//
//  Created by Ter on 10/1/19.
//

import Foundation

public enum ObjectType {
    case INTEGER
    case BOOLEAN
    case RETURN_VALUE
    case NULL
    case ERROR
    case FUNCTION
    case STRING
    case ARRAY
    case HASH
    case BUILTIN
}

public protocol Object {
    func type() -> ObjectType
    func inspect() -> String
}

protocol ObjectHashable {
    func hashKey() -> HashKey
}

typealias BuildinFunction = ([Object]) -> Object

struct IntegerObj:Object, ObjectHashable {
    var value:Int
    func type() -> ObjectType {
        return ObjectType.INTEGER
    }
    
    func inspect() -> String {
        return "\(value)"
    }
    func hashKey() -> HashKey {
        return HashKey(type: ObjectType.INTEGER, hashValue: value.hashValue)
    }
}

struct BooleanObj:Object, ObjectHashable {
    var value:Bool
    func type() -> ObjectType {
        return ObjectType.BOOLEAN
    }
    
    func inspect() -> String {
        return "\(value)"
    }

    func hashKey() -> HashKey {
        return HashKey(type: ObjectType.BOOLEAN, hashValue: value.hashValue)
    }
}

struct ReturnValueObj:Object {
    var value:Object
    func type() -> ObjectType {
        return ObjectType.RETURN_VALUE
    }
    
    func inspect() -> String {
        return "\(value.inspect())"
    }    
}

struct NullObj:Object {
    func type() -> ObjectType {
        return ObjectType.NULL
    }
    
    func inspect() -> String {
        return "null"
    }
}

struct ErrorObj:Object {
    var message:String
    func type() -> ObjectType {
        return ObjectType.ERROR
    }
    
    func inspect() -> String {
        return "\(message)"
    }
}

struct FunctionObj:Object {
    var parameters:[Identifier]
    var body:BlockStatement
    var env:Environment

    func type() -> ObjectType {
        return ObjectType.FUNCTION
    }
    
    func inspect() -> String {
        let param = parameters.map { (iden) -> String in
            return iden.value
        }.joined(separator: ",")
        
        return """
        fn(\(param)) {
        \(body.string())
        }
        """
    }
}

struct StringObj:Object, ObjectHashable {
    var value:String
    func type() -> ObjectType {
        return ObjectType.STRING
    }
    
    func inspect() -> String {
        return value
    }
    
    func hashKey() -> HashKey {
        return HashKey(type: ObjectType.STRING, hashValue: value.hashValue)
    }
}

struct ArrayObj:Object {
    var elements:[Object]
    func type() -> ObjectType {
        return ObjectType.ARRAY
    }
    
    func inspect() -> String {
        let allElements = elements.map { (ele) -> String in
            return ele.inspect()
            }.joined(separator: ",")
        return "[\(allElements)]"
    }
}

struct HashKey: Hashable {
    var type:ObjectType
    var hashValue: Int
}

struct HashPair {
    var key: Object
    var value: Object
}

struct HashObj:Object {
    var pairs:[HashKey:HashPair]
    func type() -> ObjectType {
        return ObjectType.HASH
    }
    func inspect() -> String {
        let allElements = pairs.map { (_,ele) -> String in
            return "\(ele.key.inspect()):\(ele.value.inspect())"
            }.joined(separator: ",")
        return "{\(allElements)}"
    }

}

struct BuiltinObj:Object {
    var fn:BuildinFunction
    func type() -> ObjectType {
        return ObjectType.BUILTIN
    }
    
    func inspect() -> String {
        return "buildin function"
    }
}
