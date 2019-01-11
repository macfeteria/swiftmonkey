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
    case NULL
}

public protocol Object {
    func type() -> ObjectType
    func inspect() -> String
}

struct IntegerObj:Object {
    var value:Int
    func type() -> ObjectType {
        return ObjectType.INTEGER
    }
    
    func inspect() -> String {
        return "\(value)"
    }
    
}

struct BooleanObj:Object, Equatable {
    var value:Bool
    func type() -> ObjectType {
        return ObjectType.BOOLEAN
    }
    
    func inspect() -> String {
        return "\(value)"
    }
    static func == (lhs: BooleanObj, rhs: BooleanObj) -> Bool {
        return lhs.value == rhs.value
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
