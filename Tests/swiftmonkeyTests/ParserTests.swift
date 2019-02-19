//
//  ParserTests.swift
//  swiftmonkeyTests
//
//  Created by Ter on 3/1/19.
//

import XCTest
@testable import swiftmonkey

class ParserTests: XCTestCase {

    func validateLiteralExpression<T>(expression: Expression?, result: T) {
        guard let expression = expression else {
            XCTAssertTrue(false)
            return
        }
        if T.self is IntegerLiteral.Type {
            let identExpression = expression as! Identifier
            let resultString = result as! String
            validateIdentifier(identifier: identExpression, expect: resultString)
        }
        if T.self is Identifier.Type {
            let integerExpression = expression as! IntegerLiteral
            let resultInt = result as! Int
            validateInteger(integerLiteral: integerExpression, expect: resultInt)
        }
        if T.self is Boolean.Type {
            let boolean = expression as! Boolean
            let resultBoolean = result as! Bool
            validateBoolean(boolean: boolean, expect: resultBoolean)
        }
    }
    
    func validateInteger(integerLiteral: IntegerLiteral, expect: Int ) {
        XCTAssertTrue(integerLiteral.value == expect, "Expect \(expect) Got \(integerLiteral.value)")
        XCTAssertTrue(integerLiteral.tokenLiteral() == "\(expect)", "Expect \(expect) Got \(integerLiteral.tokenLiteral())")
    }
    
    func validateIdentifier(identifier: Identifier, expect: String ) {
        XCTAssertTrue(identifier.value == expect, "Expect \(expect) Got \(identifier.value)")
        XCTAssertTrue(identifier.tokenLiteral() == expect, "Expect \(expect) Got \(identifier.tokenLiteral())")
    }
    
    func validateBoolean(boolean: Boolean, expect: Bool) {
        XCTAssertTrue(boolean.value == expect)
        XCTAssertTrue(boolean.tokenLiteral() == String(expect), "Expect \(expect) Got \(boolean.tokenLiteral())")
    }

    func validateInfix<T>(infix: InfixExpression, left: T, op: String, right: T) {
        validateLiteralExpression(expression: infix, result: left)
        XCTAssertTrue(infix.operatorLiteral == op, "Expect \(infix.operatorLiteral) Got \(op)")
        validateLiteralExpression(expression: infix, result: right)
    }
    
    func validateInfix<T>(statement: ExpressionStatement, left: T, op: String, right: T) {
        let infix = statement.expression as! InfixExpression
        validateInfix(infix: infix, left: left, op: op, right: right)
    }
    
    func validateParserError(parser: Parser) {
        for e in parser.errors {
            print(e)
        }
        XCTAssertTrue(parser.errors.count == 0,  "Expect no error")
    }
    
    func testLetStatement() {
        
        struct stmt {
            var code:String
            var expectedIdentifier:String
            var expectedValue:Any
        }
        
        let tests = [stmt(code:"let x = 5;", expectedIdentifier:"x", expectedValue:5),
                     stmt(code:"let y = true;", expectedIdentifier:"y", expectedValue:false),
                     stmt(code:"let foo = y;", expectedIdentifier:"foo", expectedValue:"y"),
                     ]
        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            validateParserError(parser: parser)
            
            let letStatement = program.statements[0] as! LetStatement
            validateIdentifier(identifier: letStatement.name, expect:test.expectedIdentifier)
            validateLiteralExpression(expression: letStatement.value, result: test.expectedValue)
        }
        
    }
    
    func testParserError() {
        let code = """
            let x = 5;
            let y = 10;
            let 838383;
            """
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        let _ = parser.parseProgram()
        XCTAssertTrue(parser.errors.count != 0, "Expect no error")
    }
    
    
    func testReturnStatement() {
        let code = """
            return 5;
            return 10;
            return 838383;
            """
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)

        XCTAssertTrue(program.statements.count == 3)
        
        for statement in program.statements {
            XCTAssertTrue(statement.tokenLiteral() == "return")
        }
    }
    
    func testIdentifierExpression() {
        let code = "foobar;"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let stmt = program.statements[0] as! ExpressionStatement
        validateLiteralExpression(expression: stmt.expression!, result: "foobar")
    }
    
    func testIntegerExpression() {
        let code = "5;"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let stmt = program.statements[0] as! ExpressionStatement
        validateLiteralExpression(expression: stmt.expression!, result: 5)
    }

    
    func testPrefixExpression() {
        let tests = [(code:"-15;", oper:"-", intValue:15),
                     (code:"!5;", oper:"!", intValue:5),
                     ]
        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            validateParserError(parser: parser)

            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            let expression = statement.expression as! PrefixExpression

            XCTAssertTrue(expression.operatorLiteral == test.oper)

            let integerLit = expression.right as! IntegerLiteral
            validateInteger(integerLiteral: integerLit, expect: test.intValue)
        }
    }

    func testPrefixExpressionBoolean() {
        let tests = [(code:"!true;", oper:"!", value:true),
                     (code:"!false;", oper:"!", value:false),
                     ]
        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            validateParserError(parser: parser)
            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            let expression = statement.expression as! PrefixExpression
            
            XCTAssertTrue(expression.operatorLiteral == test.oper)
            
            let boolLit = expression.right as! Boolean
            validateBoolean(boolean: boolLit, expect: test.value)
        }
    }

    func testInfixExpression() {
        struct infix {
            var code:String
            var leftValue:Any
            var oper:String
            var rightValue:Any
        }
        
        let tests = [infix(code:"5 + 6;", leftValue: 5, oper:"+", rightValue:6),
                     infix(code:"5 - 6;", leftValue: 5, oper:"-", rightValue:6),
                     infix(code:"5 * 6;", leftValue: 5, oper:"*", rightValue:6),
                     infix(code:"5 / 6;", leftValue: 5, oper:"/", rightValue:6),
                     infix(code:"5 < 6;", leftValue: 5, oper:"<", rightValue:6),
                     infix(code:"5 > 6;", leftValue: 5, oper:">", rightValue:6),
                     infix(code:"5 == 6;", leftValue: 5, oper:"==", rightValue:6),
                     infix(code:"5 != 6;", leftValue: 5, oper:"!=", rightValue:6),
                     
                     infix(code:"true == true", leftValue: true, oper:"==", rightValue:true),
                     infix(code:"true != false", leftValue: true, oper:"!=", rightValue:false),
                     infix(code:"false == false", leftValue: false, oper:"==", rightValue:false),
                     ]
        
        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            validateParserError(parser: parser)

            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            validateInfix(statement: statement, left: test.leftValue, op: test.oper, right: test.rightValue)
        }
    }
    
    func testOperatorPrecedenceParsing() {
        let tests = [(code: "-a * b", expected: "((-a) * b)"),
        (code: "!-a", expected: "(!(-a))"),
        (code: "a + b + c", expected: "((a + b) + c)"),
        (code: "a + b - c", expected: "((a + b) - c)"),
        (code: "a * b / c", expected: "((a * b) / c)"),
        (code: "a * b * c", expected: "((a * b) * c)"),
        (code: "a + b * c", expected: "(a + (b * c))"),
        (code: "a + b * c + d / e - f", expected: "(((a + (b * c)) + (d / e)) - f)"),
        (code: "3 + 4; -5 * 5", expected: "(3 + 4)((-5) * 5)"),
        (code: "5 > 4 == 3 < 4", expected: "((5 > 4) == (3 < 4))"),
        (code: "5 > 4 != 3 < 4", expected: "((5 > 4) != (3 < 4))"),
        (code: "3 + 4 * 5 == 3 * 1 + 4 * 5", expected: "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
        (code: "true", expected: "true"),
        (code: "false", expected: "false"),
        (code: "3 < 5 == true", expected: "((3 < 5) == true)"),
        (code: "3 > 5 == false", expected: "((3 > 5) == false)"),

        (code: "1 + (2 +3) +4", expected: "((1 + (2 + 3)) + 4)"),
        (code: "(5 + 5) * 2", expected: "((5 + 5) * 2)"),
        (code: "2 / (5 + 5)", expected: "(2 / (5 + 5))"),
        (code: "-(5 + 5)", expected: "(-(5 + 5))"),
        (code: "!(true == true)", expected: "(!(true == true))"),

        (code: "a + add(b * c) + d", expected: "((a + add((b * c))) + d)"),
        (code: "add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", expected: "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
        (code: "add(a + b + c * d / f + g)", expected: "add((((a + b) + ((c * d) / f)) + g))"),

        (code: "a * [1, 2, 3, 4][b * c] * d", expected: "((a * ([1, 2, 3, 4][(b * c)])) * d)"),
        (code: "add(a * b[2], b[1], 2 * [1, 2][1])", expected: "add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))"),
        ]

        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            validateParserError(parser: parser)
            let result = program.string()
            XCTAssertTrue(result == test.expected , "Expect \(test.expected) Got \(result)" )
        }
    }
    
    func testBooleanExpression() {
        let code = "true;"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)

        XCTAssertTrue(program.statements.count == 1)

        let statement = program.statements[0] as! ExpressionStatement
        validateLiteralExpression(expression: statement.expression!, result: true)
    }
    
    func testIfStatement() {
        let code = "if (x < y) { x }"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let ifExp = statement.expression as! IfExpression
        XCTAssertTrue(ifExp.alternative == nil)
        XCTAssertTrue(ifExp.consequence.statements.count == 1)

        let consequence = ifExp.consequence.statements[0] as! ExpressionStatement
        validateLiteralExpression(expression: consequence.expression, result: "x")
    }
    
    func testIfElseStatement() {
        let code = "if (x < y) { x } else { y }"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let ifExp = statement.expression as! IfExpression
        XCTAssertTrue(ifExp.consequence.statements.count == 1)
        
        let consequence = ifExp.consequence.statements[0] as! ExpressionStatement
        validateLiteralExpression(expression: consequence.expression, result: "x")
       
        XCTAssertNotNil(ifExp.alternative)
        let alter = ifExp.alternative!
        let alterStatement = alter.statements[0]  as! ExpressionStatement
        
        validateLiteralExpression(expression: alterStatement.expression, result: true)
    }
    
    
    func testFunctionExpression() {
        let code = "fn(x, y) { x + y }"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        XCTAssertTrue(parser.errors.count == 0)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let function = statement.expression as! FunctionLiteral
        XCTAssertTrue(function.parameters.count == 2)
        
        validateIdentifier(identifier: function.parameters[0], expect: "x")
        validateIdentifier(identifier: function.parameters[1], expect: "y")
        
        XCTAssertTrue(function.body.statements.count == 1)
        let body = function.body.statements[0] as! ExpressionStatement
        validateInfix(statement: body, left: "x", op: "+", right: "y")
    }
    
    func testFunctionParameters() {
        let tests = [(code: "fn() {};", expected: []),
                     (code: "fn(x) {};", expected: ["x"]),
                     (code: "fn(x, y, z) {};", expected: ["x", "y", "z"]),
                     ]

        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            validateParserError(parser: parser)
            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            let function = statement.expression as! FunctionLiteral
            XCTAssertTrue(function.parameters.count == test.expected.count)
            
            for i in 0 ..< function.parameters.count {
                validateIdentifier(identifier: function.parameters[i], expect: test.expected[i])
            }
        }
    }
    
    func testCallExpressionParsing() {
        let code = "add(1, 2 * 3, 4 + 5);"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let expression = statement.expression as! CallExpression
        
        let functionIden = expression.function as! Identifier
        validateIdentifier(identifier: functionIden, expect: "add")

        XCTAssertTrue(expression.arguments.count == 3)
        
        validateLiteralExpression(expression: expression.arguments[0], result: 1)
        
        let param1 = expression.arguments[1] as! InfixExpression
        let param2 = expression.arguments[2] as! InfixExpression
        
        validateInfix(infix: param1, left: 2, op: "*", right: 3)
        validateInfix(infix: param2, left: 4, op: "+", right: 5)
    }
    
    
    func testArrayLiteralParsing() {
        let code = "[1, 2 * 2, 3 + 3]"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        
        let statement = program.statements[0] as! ExpressionStatement
        let array = statement.expression as! ArrayLiteral
        XCTAssertTrue(array.elements.count == 3)

        let intElement = array.elements[0] as! IntegerLiteral
        validateInteger(integerLiteral: intElement, expect: 1)
        
        let ele1 = array.elements[1] as! InfixExpression
        let ele2 = array.elements[2] as! InfixExpression
        
        validateInfix(infix: ele1, left: 2, op: "*", right: 2)
        validateInfix(infix: ele2, left: 3, op: "+", right: 3)
    }
    
    func testParsingIndexExpressions() {
        let code = "myArray[1 + 1]"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let expression = statement.expression as! IndexExpression
        
        let arrayIden = expression.left as! Identifier
        validateIdentifier(identifier: arrayIden, expect: "myArray")
        
        let index = expression.index as! InfixExpression
        validateInfix(infix: index, left: 1, op: "+", right: 1)

    }
    
    func testParsingHashLiteralsStringKeys() {
        let code = """
            {"one": 1, "two": 2, "three": 3}
        """
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let hash = statement.expression as! HashLiteral
        
        XCTAssertTrue(hash.pairs.count == 3)
        
        let expected = ["one": 1, "two": 2, "three": 3]
        for (key, value) in hash.pairs {
            let expectedValue = expected[key.expression.string()]
            validateInteger(integerLiteral: value as! IntegerLiteral, expect: expectedValue!)
        }
    }

    func testParsingEmptyHashLiteral() {
        let code = "{}"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let hash = statement.expression as! HashLiteral
        
        XCTAssertTrue(hash.pairs.count == 0)
    }
    
    func testParsingHashLiteralsWithExpression() {
        let code = """
            {"one": 0 + 1, "two": 10 - 8, "three": 15 / 5}
        """
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        validateParserError(parser: parser)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let hash = statement.expression as! HashLiteral
        
        XCTAssertTrue(hash.pairs.count == 3)
        
        let expected = ["one": (left: 0, op: "+" , right: 1),
                        "two": (left: 10, op: "-" , right: 8),
                        "three": (left: 15, op: "/" , right: 5)]
        for (key, value) in hash.pairs {
            let expect = expected[key.expression.string()]!
            let resultValue = value as! InfixExpression
            validateInfix(infix: resultValue, left: expect.left, op: expect.op, right: expect.right)
        }
    }
}
