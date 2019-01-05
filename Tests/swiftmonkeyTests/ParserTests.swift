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


}
