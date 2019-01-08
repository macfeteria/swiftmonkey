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

        (code: "a + add(b * c) + d", expected: "((a + add((b * c))) + d)"),
        (code: "add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", expected: "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
        (code: "add(a + b + c * d / f + g)", expected: "add((((a + b) + ((c * d) / f)) + g))"),

        ]

        for test in tests {
            let lexer = Lexer(input: test.code)
            let parser = Parser(lexer: lexer)
            
            let program = parser.parseProgram()
            XCTAssertTrue(parser.errors.count == 0)
            let result = program.string()
            XCTAssertTrue(result == test.expected)
            print(result)
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
    
    func testIfStatement() {
        let code = "if (x < y) { x }"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        XCTAssertTrue(parser.errors.count == 0)
        for e in parser.errors {
            print(e)
        }
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let ifExp = statement.expression as! IfExpression
        XCTAssertTrue(ifExp.consequence.statements.count == 1)

        let consequence = ifExp.consequence.statements[0] as! ExpressionStatement
        let ident = consequence.expression as! Identifier
        XCTAssertTrue(ident.value == "x")
        XCTAssertTrue(ident.tokenLiteral() == "x")

        XCTAssertTrue(ifExp.alternative == nil)
    }
    
    func testIfElseStatement() {
        let code = "if (x < y) { x } else { y }"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        XCTAssertTrue(parser.errors.count == 0)
        for e in parser.errors {
            print(e)
        }
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let ifExp = statement.expression as! IfExpression
        XCTAssertTrue(ifExp.consequence.statements.count == 1)
        
        let consequence = ifExp.consequence.statements[0] as! ExpressionStatement
        let ident = consequence.expression as! Identifier
        XCTAssertTrue(ident.value == "x")
        XCTAssertTrue(ident.tokenLiteral() == "x")
       
        XCTAssertNotNil(ifExp.alternative)
        let alter = ifExp.alternative!
        let alterStatement = alter.statements[0]  as! ExpressionStatement
        let iden = alterStatement.expression as! Identifier

        XCTAssertTrue(iden.value == "y")
        XCTAssertTrue(iden.tokenLiteral() == "y")
    }
    
    
    func testFunctionLiteral() {
        let code = "fn(x, y) { x + y }"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        XCTAssertTrue(parser.errors.count == 0)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let function = statement.expression as! FunctionLiteral
        XCTAssertTrue(function.parameters.count == 2)
        
        XCTAssertTrue(function.parameters[0].value == "x")
        XCTAssertTrue(function.parameters[1].value == "y")

        XCTAssertTrue(function.body.statements.count == 1)

        let body = function.body.statements[0] as! ExpressionStatement
        let expression = body.expression as! InfixExpression
        
        let leftIdent = expression.left as! Identifier
        XCTAssertTrue(leftIdent.value == "x")
        
        XCTAssertTrue(expression.operatorLiteral == "+")
        
        let rightIdent = expression.right as! Identifier
        XCTAssertTrue(rightIdent.value == "y")
        
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
            XCTAssertTrue(parser.errors.count == 0)
            XCTAssertTrue(program.statements.count == 1)
            
            let statement = program.statements[0] as! ExpressionStatement
            let function = statement.expression as! FunctionLiteral
            XCTAssertTrue(function.parameters.count == test.expected.count)
            
            for i in 0..<function.parameters.count {
                XCTAssertTrue(function.parameters[i].value == test.expected[i])
            }
        }
    }
    
    func testCallExpressionParsing() {
        let code = "add(1, 2 * 3, 4 + 5);"
        
        let lexer = Lexer(input: code)
        let parser = Parser(lexer: lexer)
        
        let program = parser.parseProgram()
        XCTAssertTrue(parser.errors.count == 0)
        XCTAssertTrue(program.statements.count == 1)
        
        let statement = program.statements[0] as! ExpressionStatement
        let expression = statement.expression as! CallExpression
        
        let functionIden = expression.function as! Identifier
        XCTAssertTrue(functionIden.value == "add")

        XCTAssertTrue(expression.arguments.count == 3)

        let param0 = expression.arguments[0] as! IntegerLiteral
        XCTAssertTrue(param0.value == 1)
        
        let param1 = expression.arguments[1] as! InfixExpression
        let leftIdent1 = param1.left as! IntegerLiteral
        XCTAssertTrue(leftIdent1.value == 2)
        XCTAssertTrue(param1.operatorLiteral == "*")
        let rightIdent1 = param1.right as! IntegerLiteral
        XCTAssertTrue(rightIdent1.value == 3)

        let param2 = expression.arguments[2] as! InfixExpression
        let leftIdent2 = param2.left as! IntegerLiteral
        XCTAssertTrue(leftIdent2.value == 4)
        XCTAssertTrue(param2.operatorLiteral == "+")
        let rightIdent2 = param2.right as! IntegerLiteral
        XCTAssertTrue(rightIdent2.value == 5)

        
    }
    
}
