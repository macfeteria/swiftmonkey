//
//  EvaluatorTests.swift
//  swiftmonkeyTests
//
//  Created by Ter on 10/1/19.
//

import XCTest
@testable import swiftmonkey

class EvaluatorTests: XCTestCase {
    
    func evaluate(input:String) -> Object {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        let evaluated = Evaluator()
        return evaluated.eval(node: program)
    }
    
    func validateIntegerObject(obj:Object, expect: Int) {
        let intObj = obj as! IntegerObj
        XCTAssertTrue(intObj.value == expect)
    }
    
    func validateBooleanObject(obj:Object, expect: Bool) {
        let intObj = obj as! BooleanObj
        XCTAssertTrue(intObj.value == expect)
    }

    func testEvalIntegerExpression () {
        let tests = [(code:"5",expectedValue:5),
                     (code:"10",expectedValue:10),
                     (code:"-10",expectedValue:-10),
                     (code:"-5",expectedValue:-5),
                     
                     (code:"5 + 5 + 5 + 5 -10", expectedValue:10),
                     (code:"2 * 2 * 2 * 2 * 2", expectedValue:32),
                     (code:"-50 + 100 -50", expectedValue:0),
                     (code:"5 * 2 + 10", expectedValue:20),
                     (code:"5 + 2 * 10", expectedValue:25),
                     (code:"50 / 2 * 2 + 10", expectedValue:60),
                     (code:"2 * (5 + 10)", expectedValue:30),
                     (code:"3 * (3 * 3) + 10", expectedValue:37),
                     (code:"3 * 3 * 3 + 10", expectedValue:37),
                     (code:"(5 + 10 * 2 + 15 / 3) * 2 + -10", expectedValue:50),
    
                     ]
        
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateIntegerObject(obj: resultObj, expect: test.expectedValue)
        }
    }
    
    func testEvalBooleanExpression () {
        let tests = [(code:"true",expectedValue:true),
                     (code:"false",expectedValue:false),
                     ]
        
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateBooleanObject(obj: resultObj, expect: test.expectedValue)
        }
    }
    
    func testBangOperator () {
        let tests = [(code:"!true",expectedValue:false),
                     (code:"!false",expectedValue:true),
                     (code:"!5",expectedValue:false),
                     (code:"!!true",expectedValue:true),
                     (code:"!!false",expectedValue:false),
                     (code:"!!5",expectedValue:true),
                     ]
        
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateBooleanObject(obj: resultObj, expect: test.expectedValue)
        }
    }


}
