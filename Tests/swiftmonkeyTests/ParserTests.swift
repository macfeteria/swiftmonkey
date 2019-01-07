//
//  ParserTests.swift
//  swiftmonkeyTests
//
//  Created by Ter on 3/1/19.
//

import XCTest
@testable import swiftmonkey

class ParserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLetStatement() {
        let code = """
            let x = 5;
            let y = 10;
            let foobar = 838383;
            """

        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)

        let program = parser.parseProgram()
        XCTAssertTrue(program.statements.count == 3)
        
        let expectIdentifier = ["x", "y", "foobar"]
        
        for (index, element) in expectIdentifier.enumerated() {
            let statement = program.statements[index]
            XCTAssertTrue(statement.tokenLiteral() == "let")
            
            let letStatement = statement as! LetStatement
            XCTAssertTrue(letStatement.name.tokenLiteral() == element)
            XCTAssertTrue(letStatement.name.value  == element)
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
        XCTAssertTrue(parser.errors.count != 0)
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
        XCTAssertTrue(parser.errors.count == 0)
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
        XCTAssertTrue(parser.errors.count == 0)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let statementIdentifier = statement.expression as! Identifier
        XCTAssertTrue(statementIdentifier.value == "foobar")
        XCTAssertTrue(statementIdentifier.tokenLiteral() == "foobar")
    }
    
    func testIntegerExpression() {
        let code = "5;"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        XCTAssertTrue(parser.errors.count == 0)

        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let statementIdentifier = statement.expression as! IntegerLiteral
        XCTAssertTrue(statementIdentifier.value == 5)
        XCTAssertTrue(statementIdentifier.tokenLiteral() == "5")
    }

    
    func testPrefixExpression() {
        let tests = [(code:"-15;", oper:"-", intValue:15),
                     (code:"!5;", oper:"!", intValue:5),
                     ]
        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            XCTAssertTrue(parser.errors.count == 0)
            for e in parser.errors {
                print(e)
            }

            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            let expression = statement.expression as! PrefixExpression

            XCTAssertTrue(expression.operatorLiteral == test.oper)

            let integerLit = expression.right as! IntegerLiteral
            XCTAssertTrue(integerLit.value == test.intValue)
            XCTAssertTrue(integerLit.tokenLiteral() == "\(test.intValue)")
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
            XCTAssertTrue(parser.errors.count == 0)
            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            let expression = statement.expression as! PrefixExpression
            
            XCTAssertTrue(expression.operatorLiteral == test.oper)
            
            let integerLit = expression.right as! Boolean
            XCTAssertTrue(integerLit.value == test.value)
            XCTAssertTrue(integerLit.tokenLiteral() == "\(test.value)")
        }
    }

    
    
    func testInfixExpressionBoolean() {
        let tests = [(code:"true == true", leftValue: true, oper:"==", rightValue:true),
                    (code:"true != false", leftValue: true, oper:"!=", rightValue:false),
                    (code:"false == false", leftValue: false, oper:"==", rightValue:false),
                    ]
        
        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            XCTAssertTrue(parser.errors.count == 0)
            for e in parser.errors {
                print(e)
            }
            
            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            let expression = statement.expression as! InfixExpression
            
            let leftBool = expression.left as! Boolean
            XCTAssertTrue(leftBool.value == test.leftValue)

            XCTAssertTrue(expression.operatorLiteral == test.oper)
            
            let rightBool = expression.right as! Boolean
            XCTAssertTrue(rightBool.value == test.rightValue)
        }
    }

    func testInfixExpression() {
        let tests = [(code:"5 + 6;", leftValue: 5, oper:"+", rightValue:6),
                     (code:"5 - 6;", leftValue: 5, oper:"-", rightValue:6),
                     (code:"5 * 6;", leftValue: 5, oper:"*", rightValue:6),
                     (code:"5 / 6;", leftValue: 5, oper:"/", rightValue:6),
                     (code:"5 < 6;", leftValue: 5, oper:"<", rightValue:6),
                     (code:"5 > 6;", leftValue: 5, oper:">", rightValue:6),
                     (code:"5 == 6;", leftValue: 5, oper:"==", rightValue:6),
                     (code:"5 != 6;", leftValue: 5, oper:"!=", rightValue:6),
                     ]
        
        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            XCTAssertTrue(parser.errors.count == 0)
            for e in parser.errors {
                print(e)
            }
            
            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            let expression = statement.expression as! InfixExpression
            
            let leftInt = expression.left as! IntegerLiteral
            XCTAssertTrue(leftInt.value == test.leftValue)
            
            XCTAssertTrue(expression.operatorLiteral == test.oper)
            
            let rightInt = expression.right as! IntegerLiteral
            XCTAssertTrue(rightInt.value == test.rightValue)
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
        ]

        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            XCTAssertTrue(parser.errors.count == 0)
            let result = program.string()
            XCTAssertTrue(result == test.expected)            
        }
    }
    
    
    func testBooleanExpression() {
        let code = "true;"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        XCTAssertTrue(parser.errors.count == 0)
        
        XCTAssertTrue(program.statements.count == 1)

        
        let statement = program.statements[0] as! ExpressionStatement
        let statementIdentifier = statement.expression as! Boolean
        XCTAssertTrue(statementIdentifier.value == true)
        XCTAssertTrue(statementIdentifier.tokenLiteral() == "true")
    }
}
