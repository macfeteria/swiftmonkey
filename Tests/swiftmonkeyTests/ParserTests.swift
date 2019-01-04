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

    func testParser() {
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

}
