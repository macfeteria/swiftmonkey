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
    
    func validateToken(expect:Token, result: Token) {
        XCTAssert(result.type == expect.type, "Failed Type: \(result.type.rawValue )")
        XCTAssert(result.literal == expect.literal, "Failed Literal: \(result.literal)")
    }
    
    func testEmptyCode() {
        let code = ""
        let expect = Token(type: TokenType.EOF, literal: "\0")
        let lexer = Lexer(input: code)
        let result = lexer.nextToken()

        validateToken(expect: expect, result: result)
    }

    func testNextToken() {
        let code = "=+(){},;"
        let expectResult = [
            Token(type: TokenType.ASSIGN, literal: "="),
            Token(type: TokenType.PLUS, literal: "+"),
            Token(type: TokenType.LPAREN, literal: "("),
            Token(type: TokenType.RPAREN, literal: ")"),
            Token(type: TokenType.LBRACE, literal: "{"),
            Token(type: TokenType.RBRACE, literal: "}"),
            Token(type: TokenType.COMMA, literal: ","),
            Token(type: TokenType.SEMICOLON, literal: ";"),
        ]

        let lexer = Lexer(input: code)
        for expect in expectResult {
            let result = lexer.nextToken()
            validateToken(expect: expect, result: result)
        }
    }
    
    func testStringToken() {
        let code = """
        "foobar"
        "foo bar"
        """
        let expectResult = [
            Token(type: TokenType.STRING, literal: "foobar"),
            Token(type: TokenType.STRING, literal: "foo bar"),
            ]
        
        let lexer = Lexer(input: code)
        for expect in expectResult {
            let result = lexer.nextToken()
            validateToken(expect: expect, result: result)
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

            Token(type: TokenType.LET, literal: "let"),
            Token(type: TokenType.IDENT, literal: "five"),
            Token(type: TokenType.ASSIGN, literal: "="),
            Token(type: TokenType.INT, literal: "5"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            
            Token(type: TokenType.LET, literal: "let"),
            Token(type: TokenType.IDENT, literal: "ten"),
            Token(type: TokenType.ASSIGN, literal: "="),
            Token(type: TokenType.INT, literal: "10"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            
            Token(type: TokenType.LET, literal: "let"),
            Token(type: TokenType.IDENT, literal: "add"),
            Token(type: TokenType.ASSIGN, literal: "="),
            Token(type: TokenType.FUNCTION, literal: "fn"),
            Token(type: TokenType.LPAREN, literal: "("),
            Token(type: TokenType.IDENT, literal: "x"),
            Token(type: TokenType.COMMA, literal: ","),
            Token(type: TokenType.IDENT, literal: "y"),
            Token(type: TokenType.RPAREN, literal: ")"),
            Token(type: TokenType.LBRACE, literal: "{"),
            Token(type: TokenType.IDENT, literal: "x"),
            Token(type: TokenType.PLUS, literal: "+"),
            Token(type: TokenType.IDENT, literal: "y"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            Token(type: TokenType.RBRACE, literal: "}"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            
            Token(type: TokenType.LET, literal: "let"),
            Token(type: TokenType.IDENT, literal: "result"),
            Token(type: TokenType.ASSIGN, literal: "="),
            Token(type: TokenType.IDENT, literal: "add"),
            Token(type: TokenType.LPAREN, literal: "("),
            Token(type: TokenType.IDENT, literal: "five"),
            Token(type: TokenType.COMMA, literal: ","),
            Token(type: TokenType.IDENT, literal: "ten"),
            Token(type: TokenType.RPAREN, literal: ")"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            
            Token(type: TokenType.EOF, literal: "\0"),
        ]
        
        let lexer = Lexer(input: code)
        for expect in expectResult {
            let result = lexer.nextToken()
            validateToken(expect: expect, result: result)
        }
    }
    
    func testExtendOperator() {
        let code = """
            !-/*5;
            5 < 10 > 5;
            """
        let expectResult = [
            Token(type: TokenType.BANG, literal: "!"),
            Token(type: TokenType.MINUS, literal: "-"),
            Token(type: TokenType.SLASH, literal: "/"),
            Token(type: TokenType.ASTERISK, literal: "*"),
            Token(type: TokenType.INT, literal: "5"),
            Token(type: TokenType.SEMICOLON, literal: ";"),

            Token(type: TokenType.INT, literal: "5"),
            Token(type: TokenType.LESSTHAN, literal: "<"),
            Token(type: TokenType.INT, literal: "10"),
            Token(type: TokenType.GREATER, literal: ">"),
            Token(type: TokenType.INT, literal: "5"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            ]
        
        let lexer = Lexer(input: code)
        for expect in expectResult {
            let result = lexer.nextToken()
            validateToken(expect: expect, result: result)
        }
    }

    func testTrueFalseIfElse() {
        let code = """
            if (5 < 10) {
                return true;
            } else {
                return false;
            }
            """
        let expectResult = [
            Token(type: TokenType.IF, literal: "if"),
            Token(type: TokenType.LPAREN, literal: "("),
            Token(type: TokenType.INT, literal: "5"),
            Token(type: TokenType.LESSTHAN, literal: "<"),
            Token(type: TokenType.INT, literal: "10"),
            Token(type: TokenType.RPAREN, literal: ")"),
            Token(type: TokenType.LBRACE, literal: "{"),
            Token(type: TokenType.RETURN, literal: "return"),
            Token(type: TokenType.TRUE, literal: "true"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            Token(type: TokenType.RBRACE, literal: "}"),
            Token(type: TokenType.ELSE, literal: "else"),
            Token(type: TokenType.LBRACE, literal: "{"),
            Token(type: TokenType.RETURN, literal: "return"),
            Token(type: TokenType.FALSE, literal: "false"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            Token(type: TokenType.RBRACE, literal: "}"),
            ]
        
        let lexer = Lexer(input: code)
        for expect in expectResult {
            let result = lexer.nextToken()
            validateToken(expect: expect, result: result)
        }
    }

    func testEqualNotEqual() {
        let code = """
            10 == 10;
            10 != 9;
            """
        let expectResult = [
            Token(type: TokenType.INT, literal: "10"),
            Token(type: TokenType.EQUAL, literal: "=="),
            Token(type: TokenType.INT, literal: "10"),
            Token(type: TokenType.SEMICOLON, literal: ";"),

            Token(type: TokenType.INT, literal: "10"),
            Token(type: TokenType.NOTEQUAL, literal: "!="),
            Token(type: TokenType.INT, literal: "9"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            ]
        
        let lexer = Lexer(input: code)
        for expect in expectResult {
            let result = lexer.nextToken()
            validateToken(expect: expect, result: result)
        }
    }
    
    func testArray() {
        let code = """
            [1, 2];
            """
        
        let expectResult = [
            Token(type: TokenType.LBRACKET, literal: "["),
            Token(type: TokenType.INT, literal: "1"),
            Token(type: TokenType.COMMA, literal: ","),
            Token(type: TokenType.INT, literal: "2"),
            Token(type: TokenType.RBRACKET, literal: "]"),
            Token(type: TokenType.SEMICOLON, literal: ";"),
            ]
        
        let lexer = Lexer(input: code)
        for expect in expectResult {
            let result = lexer.nextToken()
            validateToken(expect: expect, result: result)
        }
    }

    func testHash() {
        let code = """
            {"foo" : "bar"}
            """
        
        let expectResult = [
            Token(type: TokenType.LBRACE, literal: "{"),
            Token(type: TokenType.STRING, literal: "foo"),
            Token(type: TokenType.COLON, literal: ":"),
            Token(type: TokenType.STRING, literal: "bar"),
            Token(type: TokenType.RBRACE, literal: "}"),
            ]
        
        let lexer = Lexer(input: code)
        for expect in expectResult {
            let result = lexer.nextToken()
            validateToken(expect: expect, result: result)
        }
    }

    
}
