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
        let env = Environment()
        return evaluated.eval(program: program, environment: env)
    }
    
    func validateStringObject(obj:Object, expect: String) {
        let strObj = obj as! StringObj
        XCTAssertTrue(strObj.value == expect, "Expect \(expect) Got \(strObj.value)")
    }
    
    func validateIntegerObject(obj:Object, expect: Int) {
        let intObj = obj as! IntegerObj
        XCTAssertTrue(intObj.value == expect, "Expect \(expect) Got \(intObj.value)")
    }
    
    func validateBooleanObject(obj:Object, expect: Bool) {
        let boolObj = obj as! BooleanObj
        XCTAssertTrue(boolObj.value == expect,"Expect \(expect) Got \(boolObj.value)")
    }
    
    func validateNullObject(obj:Object) {
        let nullObj = obj as? NullObj
        XCTAssertNotNil(nullObj)
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
        let tests = [
                     (code:"true",expectedValue:true),
                     (code:"false",expectedValue:false),
                     
                     (code:"true == true",expectedValue:true),
                     (code:"false == false",expectedValue:true),
                     (code:"true == false",expectedValue:false),
                     (code:"true != false",expectedValue:true),
                     (code:"false != true",expectedValue:true),

                     (code:"1 < 2",expectedValue:true),
                     (code:"1 > 2",expectedValue:false),
                     (code:"1 < 1",expectedValue:false),
                     (code:"1 > 1",expectedValue:false),
                     (code:"1 == 1",expectedValue:true),
                     (code:"1 != 1",expectedValue:false),
                     (code:"1 == 2",expectedValue:false),
                     (code:"1 != 2",expectedValue:true),

                     (code:"(1 < 2) == true",expectedValue:true),
                     (code:"(1 < 2) == false",expectedValue:false),
                     (code:"(1 > 2) == true",expectedValue:false),
                     (code:"(1 > 2) == false",expectedValue:true),

                     (code:"true == (1 < 2)",expectedValue:true),
                     ]
        
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateBooleanObject(obj: resultObj, expect: test.expectedValue)
        }
    }
    
    func testIfExpression () {
        let tests = [
                     (code:"if (true) { 10 }",expectedValue: 10),
                     (code:"if (false) { 10 }",expectedValue: nil),
                     (code:"if (1) { 10 }",expectedValue: 10),
                     (code:"if (1 < 2) { 10 }",expectedValue: 10),
                     (code:"if (1 > 2) { 10 }",expectedValue: nil),
                     (code:"if (1 > 2) { 10 } else { 20 }",expectedValue: 20),
                     (code:"if (1 < 2) { 10 } else { 20 }",expectedValue: 10),
                     ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            if let value = test.expectedValue {
                validateIntegerObject(obj: resultObj, expect: value)
            } else {
                validateNullObject(obj: resultObj)
            }
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
    
    func testReturnStatement () {
        let tests = [
                    (code:"return 10;", expectedValue:10),
                    (code:"return 10; 9;", expectedValue:10),
                    (code:"return 2 * 5; 9;", expectedValue:10),
                    (code:"9; return 2 * 5; 8;", expectedValue:10),
                    (code:"""
                        if ( 10 > 1 ) {
                            if ( 10 > 1 ) {
                                return 10;
                            }
                            return 1;
                        }
                        """, expectedValue: 10),
                    ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateIntegerObject(obj: resultObj, expect: test.expectedValue)
        }
    }

    func testErrorHandling () {
        let tests = [
            (code:"5 + true;", expectedValue:"type mismatch: INTEGER + BOOLEAN"),
            (code:"5 + true; 5;", expectedValue:"type mismatch: INTEGER + BOOLEAN"),
            (code:"-true;", expectedValue:"unknow operator: -BOOLEAN"),
            (code:"true + false;", expectedValue:"unknow operator: BOOLEAN + BOOLEAN"),
            (code:"5; true + false; 5", expectedValue:"unknow operator: BOOLEAN + BOOLEAN"),
            (code:"if (10 > 1) { true + false; }", expectedValue:"unknow operator: BOOLEAN + BOOLEAN"),
            (code:"""
                if ( 10 > 1 ) {
                    if ( 10 > 1 ) {
                        return true + false;
                    }
                    return 1;
                }
                """, expectedValue:"unknow operator: BOOLEAN + BOOLEAN"),
            (code:"foobar", expectedValue:"identifier not found: foobar"),
            (code:"""
                "Hello" - "World!"
                """, expectedValue:"unknow operator: STRING - STRING"),
            (code:"""
                {"name": "Monkey"}[fn(x) { x }];
                """, expectedValue:"unusable as hash key: FUNCTION"),
        ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            XCTAssertTrue(resultObj.inspect() == test.expectedValue, "Expect \(test.expectedValue) Got \(resultObj.inspect())" )
        }
    }
    
    func testLetStatement () {
        let tests = [
            (code:"let a = 5; a;", expectedValue: 5),
            (code:"let a = 5 * 5; a;", expectedValue: 25),
            (code:"let a = 5; let b = a; b;", expectedValue: 5),
            (code:"let a = 5; let b = a; let c = a + b + 5; c;", expectedValue: 15),
            ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateIntegerObject(obj: resultObj, expect: test.expectedValue)
        }
    }
    
    func testFunctionObject () {
        let code = "fn(x) { x + 2; };"
        
        let obj = evaluate(input: code)
        let funcObj = obj as! FunctionObj
        XCTAssertTrue(funcObj.parameters.count == 1)
        XCTAssertTrue(funcObj.parameters[0].string() == "x",  "got \(funcObj.parameters[0].string())")
        XCTAssertTrue(funcObj.body.string() == "(x + 2)", "got \(funcObj.body.string())")
    }
    
    func testFunctionApplication () {
        
        let tests = [
            (code:"let identity = fn(x) { x; }; identity(5);", expectedValue: 5),
            (code:"let double = fn(x) { return x * 2; }; double(5);", expectedValue: 10),
            (code:"let add = fn(x, y) { x + y; }; add(5, 5);", expectedValue: 10),
            (code:"let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));", expectedValue: 20),
            ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateIntegerObject(obj: resultObj, expect: test.expectedValue)
        }
        
    }
    
    func testClosure() {
        let code = """
            let newAdder = fn(x) {
                fn(y) { x + y };
            };
            let addTwo = newAdder(2)
            addTwo(2);
        """
        
        let resultObj = evaluate(input: code)
        validateIntegerObject(obj: resultObj, expect: 4)
    }
    
    func testStringLiteral() {
        let code = "\"Hello\""
        let resultObj = evaluate(input: code)
        validateStringObject(obj: resultObj, expect: "Hello")
    }

    
    func testStringConcatenation() {
        let code = "\"Hello\" + \" \" + \"World!\""
        let resultObj = evaluate(input: code)
        validateStringObject(obj: resultObj, expect: "Hello World!")
    }

    func testArrayLiteral() {
        let code = "[1, 2 * 2, 3 + 3]"
        let resultObj = evaluate(input: code)
        let arrayObj = resultObj as! ArrayObj
        XCTAssertTrue(arrayObj.elements.count == 3)
        validateIntegerObject(obj: arrayObj.elements[0], expect: 1)
        validateIntegerObject(obj: arrayObj.elements[1], expect: 4)
        validateIntegerObject(obj: arrayObj.elements[2], expect: 6)
    }
    
    func testArrayIndexExpression() {
        let tests = [
            (code:"[1, 2, 3][0]", expectedValue: 1),
            (code:"[1, 2, 3][1]", expectedValue: 2),
            (code:"[1, 2, 3][2]", expectedValue: 3),
            (code:"let i = 0; [1][i];", expectedValue: 1),
            (code:"[1, 2, 3][1 + 1];", expectedValue: 3),
            (code:"let myArray = [1, 2, 3]; myArray[2];", expectedValue: 3),
            (code:"let myArray = [1, 2, 3]; myArray[0] + myArray[1] + myArray[2];", expectedValue: 6),
            (code:"let myArray = [1, 2, 3]; let i = myArray[0]; myArray[i]", expectedValue: 2),
            ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateIntegerObject(obj: resultObj, expect: test.expectedValue)
        }
    }

    func testArrayIndexExpressionNull() {
        let tests = ["[1, 2, 3][3]", "[1, 2, 3][-1]",]
        for test in tests {
            let resultObj = evaluate(input: test)
            validateNullObject(obj: resultObj)
        }
    }

    func testHashLiterals() {
        let code = """
            let two = "two";
            {   "one": 10 - 9,
                two: 1 + 1,
                "thr" + "ee": 6 / 2,
                4 : 4,
                true: 5,
                false: 6
            }
        """
        
        let resultObj = evaluate(input: code)
        let hashobj = resultObj as! HashObj

        let one = hashobj.pairs[HashKey(type: ObjectType.STRING, hashValue: "one".hashValue)]!.value
        let two = hashobj.pairs[HashKey(type: ObjectType.STRING, hashValue: "two".hashValue)]!.value
        let three = hashobj.pairs[HashKey(type: ObjectType.STRING, hashValue: "three".hashValue)]!.value
        let four = hashobj.pairs[HashKey(type: ObjectType.INTEGER, hashValue: 4.hashValue)]!.value
        let five = hashobj.pairs[HashKey(type: ObjectType.BOOLEAN, hashValue: true.hashValue)]!.value
        let six = hashobj.pairs[HashKey(type: ObjectType.BOOLEAN, hashValue: false.hashValue)]!.value

        validateIntegerObject(obj: one, expect: 1)
        validateIntegerObject(obj: two, expect: 2)
        validateIntegerObject(obj: three, expect: 3)
        validateIntegerObject(obj: four, expect: 4)
        validateIntegerObject(obj: five, expect: 5)
        validateIntegerObject(obj: six, expect: 6)
    }


    func testHashExpression() {
        let tests = [
            (code:"""
                {"foo":5}["foo"]
                """,expectedValue: 5),
            (code:"""
                let key = "foo";
                {"foo":5}[key]
                """,expectedValue: 5),
            (code:"""
                {5:5}[5]
                """,
             expectedValue: 5),
            (code:"""
                {true:5}[true]
                """,
             expectedValue: 5),
            (code:"""
                {false:5}[false]
                """,
             expectedValue: 5),
            ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            let intResult = resultObj as! IntegerObj
            validateIntegerObject(obj: intResult, expect: test.expectedValue)
        }
    }

    func testHashNull () {
        let tests = ["""
                {}["foo"]
                """,
                """
                {"foo":5}["bar"]
                """,
        ]
        for test in tests {
            let resultObj = evaluate(input: test)
            validateNullObject(obj: resultObj)
        }
    }
    
    func testBuiltinFunctions () {
        let tests = [
            (code:"""
                len("")
            """, expectedValue: 0),
            (code:"""
                len("four")
            """, expectedValue: 4),
            (code:"""
                len("hello world")
            """, expectedValue: 11),
            (code:"""
                len([1, 2, 3])
            """, expectedValue: 3),
            (code:"""
                len(["one", "two", "three"])
            """, expectedValue: 3),
            (code:"""
                len({"one": 1, "two": 2, "three": 3})
            """, expectedValue: 3),
            ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateIntegerObject(obj: resultObj, expect: test.expectedValue)
        }
    }
    
    func testBuiltinFunctionsArray () {
        let tests = [
            (code:"""
                first(["one", "two", "three"])
            """, expectedValue: "one"),
            (code:"""
                last(["one", "two", "three"])
            """, expectedValue: "three"),
            (code:"""
                first(["single"])
            """, expectedValue: "single"),
            (code:"""
                last(["single"])
            """, expectedValue: "single"),
            ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            validateStringObject(obj: resultObj, expect: test.expectedValue)
        }
    }
    
    func testBuiltinFunctionsError () {
        let tests = [
            (code:"""
                len(1)
            """, expectedValue: "argument to `len` not supported, got INTEGER"),
            (code:"""
                len("one", "two")
            """, expectedValue: "wrong number of arguments. got=2, want=1"),
            (code:"""
                first("element")
            """, expectedValue: "argument to `first` must be array, got STRING"),
            (code:"""
                last("element")
            """, expectedValue: "argument to `last` must be array, got STRING"),
            ]
        for test in tests {
            let resultObj = evaluate(input: test.code)
            XCTAssertTrue(resultObj.inspect() == test.expectedValue, "Expect \(test.expectedValue) Got \(resultObj.inspect())" )
        }
    }
    
    func testBuiltinFunctionNull () {
        let tests = ["""
                first([])
            """,
            """
                last([])
            """]
        for test in tests {
            let resultObj = evaluate(input: test)
            validateNullObject(obj: resultObj)
        }
    }

}
