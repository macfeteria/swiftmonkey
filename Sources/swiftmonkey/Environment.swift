//
//  Environment.swift
//  swiftmonkey
//
//  Created by Ter on 15/1/19.
//

import Foundation

public class Environment {
    var store:[String: Object] = [:]
    var outer:Environment? = nil
    
    func get(name:String) -> (Object, Bool) {
        if let obj = store[name] {
            return (obj, true)
        }
        if let obj = outer {
            return obj.get(name: name)
        }
        return (Evaluator.NULL, false)
    }

    func set(name:String, object:Object) {
        store[name] = object
    }
}

