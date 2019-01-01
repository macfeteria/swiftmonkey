//
//  LexerTests.swift
//  swiftmonkeyTests
//
//  Created by Ter on 30/12/18.
//

import XCTest
@testable import swiftmonkey

class LexerTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }
    
    func testEmptyCode() {
        let code = ""
        let expectResult = Token(tokenType: TokenType.EOF, literal: "\0")
        let lexer = Lexer(input: code)
        let tok = lexer.nextToken()

        XCTAssert(tok.tokenType == expectResult.tokenType, "Failed Type: \(tok.tokenType.rawValue )")
        XCTAssert(tok.literal == expectResult.literal, "Failed Literal: \(tok.literal)")
    }

    func testNextToken() {
        let code = "=+(){},;"
        let expectResult = [
            Token(tokenType: TokenType.ASSIGN, literal: "="),
            Token(tokenType: TokenType.PLUS, literal: "+"),
            Token(tokenType: TokenType.LPAREN, literal: "("),
            Token(tokenType: TokenType.RPAREN, literal: ")"),
            Token(tokenType: TokenType.LBRACE, literal: "{"),
            Token(tokenType: TokenType.RBRACE, literal: "}"),
            Token(tokenType: TokenType.COMMA, literal: ","),
            Token(tokenType: TokenType.SEMICOLON, literal: ";"),
        ]

        let lexer = Lexer(input: code)
        for i in expectResult {
            let tok = lexer.nextToken()
            XCTAssert(tok.tokenType == i.tokenType, "Failed Type: \(tok.tokenType.rawValue )")
            XCTAssert(tok.literal == i.literal, "Failed Literal: \(tok.literal)")
        }
    }
    
    func testComplexCode() {
        let code = """
            let five = 5;
            let ten = 10;
            let add = fn(x, y) {
                x + y;
            };
            let result = add(five, ten);
        """

        let expectResult = [

            Token(tokenType: TokenType.LET, literal: "let"),
            Token(tokenType: TokenType.IDENT, literal: "five"),
            Token(tokenType: TokenType.ASSIGN, literal: "="),
            Token(tokenType: TokenType.INT, literal: "5"),
            Token(tokenType: TokenType.SEMICOLON, literal: ";"),
            
            Token(tokenType: TokenType.LET, literal: "let"),
            Token(tokenType: TokenType.IDENT, literal: "ten"),
            Token(tokenType: TokenType.ASSIGN, literal: "="),
            Token(tokenType: TokenType.INT, literal: "10"),
            Token(tokenType: TokenType.SEMICOLON, literal: ";"),
            
            Token(tokenType: TokenType.LET, literal: "let"),
            Token(tokenType: TokenType.IDENT, literal: "add"),
            Token(tokenType: TokenType.ASSIGN, literal: "="),
            Token(tokenType: TokenType.FUNCTION, literal: "fn"),
            Token(tokenType: TokenType.LPAREN, literal: "("),
            Token(tokenType: TokenType.IDENT, literal: "x"),
            Token(tokenType: TokenType.COMMA, literal: ","),
            Token(tokenType: TokenType.IDENT, literal: "y"),
            Token(tokenType: TokenType.RPAREN, literal: ")"),
            Token(tokenType: TokenType.LBRACE, literal: "{"),
            Token(tokenType: TokenType.IDENT, literal: "x"),
            Token(tokenType: TokenType.PLUS, literal: "+"),
            Token(tokenType: TokenType.IDENT, literal: "y"),
            Token(tokenType: TokenType.SEMICOLON, literal: ";"),
            Token(tokenType: TokenType.RBRACE, literal: "}"),
            Token(tokenType: TokenType.SEMICOLON, literal: ";"),
            
            Token(tokenType: TokenType.LET, literal: "let"),
            Token(tokenType: TokenType.IDENT, literal: "result"),
            Token(tokenType: TokenType.ASSIGN, literal: "="),
            Token(tokenType: TokenType.IDENT, literal: "add"),
            Token(tokenType: TokenType.LPAREN, literal: "("),
            Token(tokenType: TokenType.IDENT, literal: "five"),
            Token(tokenType: TokenType.COMMA, literal: ","),
            Token(tokenType: TokenType.IDENT, literal: "ten"),
            Token(tokenType: TokenType.RPAREN, literal: ")"),
            Token(tokenType: TokenType.SEMICOLON, literal: ";"),
            
            Token(tokenType: TokenType.EOF, literal: "\0"),
        ]
        
        let lexer = Lexer(input: code)
        for i in expectResult {
            let tok = lexer.nextToken()
            XCTAssert(tok.tokenType == i.tokenType, "Failed Type: \(tok.tokenType.rawValue )")
            XCTAssert(tok.literal == i.literal, "Failed Literal: \(tok.literal)")
        }
    }
}
