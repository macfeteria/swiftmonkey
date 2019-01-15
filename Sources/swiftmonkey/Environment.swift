//
//  Environment.swift
//  swiftmonkey
//
//  Created by Ter on 15/1/19.
//

import Foundation

public class Environment {
    var store:[String: Object] = [:]
    func get(name:String) -> (Object, Bool) {
        if let obj = store[name] {
            return (obj, true)
        }
        return (Evaluator.NULL, false)
    }
    func set(name:String, object:Object) -> Object {
        store[name] = object
        return object
    }
}

