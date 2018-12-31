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
            XCTAssert(tok.tokenType == i.tokenType)
            XCTAssert(tok.literal == i.literal)
        }
    }
}
