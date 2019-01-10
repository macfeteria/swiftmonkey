//
//  Parser.swift
//  swiftmonkey
//
//  Created by Ter on 3/1/19.
//

import Foundation

typealias prefixParseFn = () -> Expression
typealias infixParseFn = (Expression) -> Expression

enum OperatorOrder:Int {
    case LOWEST = 1
    case EQUALS // ==
    case LESSGREATER // > or <
    case SUM // +
    case PRODUCT // *
    case PREFIX // -X or !X
    case CALL // myFunc(X)
}

var precedences:[TokenType:OperatorOrder] = [.EQUAL: .EQUALS,
                                             .NOTEQUAL: .EQUALS,
                                             .GREATER: .LESSGREATER,
                                             .LESSTHAN: .LESSGREATER,
                                             .PLUS: .SUM,
                                             .MINUS: .SUM,
                                             .SLASH: .PRODUCT,
                                             .ASTERISK: .PRODUCT,
                                             .LPAREN: .CALL,]

public class Parser {
    let lexer:Lexer
    var curToken:Token
    var peekToken:Token
    var errors:[String] = []
    var prefixParseFunctions:[TokenType:prefixParseFn] = [:]
    var infixParseFunctions:[TokenType:infixParseFn] = [:]
    var peekPercedence: OperatorOrder {
        get {
            if let percedence = precedences[peekToken.tokenType] {
                return percedence
            }
            return OperatorOrder.LOWEST
        }
    }
    var curPercedence: OperatorOrder {
        get {
            if let percedence = precedences[curToken.tokenType] {
                return percedence
            }
            return OperatorOrder.LOWEST
        }
    }

    public init(lexer l:Lexer) {
        lexer = l
        curToken = l.nextToken()
        peekToken = l.nextToken()
        registerPrefix(type: TokenType.IDENT, function: parseIdentifier)
        registerPrefix(type: TokenType.INT, function: parseIntegerLiteral)
        
        registerPrefix(type: TokenType.BANG, function: parsePrefixExpression)
        registerPrefix(type: TokenType.MINUS, function: parsePrefixExpression)

        registerPrefix(type: TokenType.TRUE, function: parseBoolean)
        registerPrefix(type: TokenType.FALSE, function: parseBoolean)

        registerPrefix(type: TokenType.LPAREN, function: parseGroupExpression)
        registerPrefix(type: TokenType.IF, function: parseIfExpression)

        registerPrefix(type: TokenType.FUNCTION, function: parseFunctionLiteral)

        registerInfix(type: TokenType.PLUS, function: parseInfixExpression)
        registerInfix(type: TokenType.MINUS, function: parseInfixExpression)
        registerInfix(type: TokenType.SLASH, function: parseInfixExpression)
        registerInfix(type: TokenType.ASTERISK, function: parseInfixExpression)
        registerInfix(type: TokenType.EQUAL, function: parseInfixExpression)
        registerInfix(type: TokenType.NOTEQUAL, function: parseInfixExpression)
        registerInfix(type: TokenType.LESSTHAN, function: parseInfixExpression)
        registerInfix(type: TokenType.GREATER, function: parseInfixExpression)

        registerInfix(type: TokenType.LPAREN, function: parseCallExpression)

    }
    
    func nextToken() {
        curToken = peekToken
        peekToken = lexer.nextToken()
    }
    
    public func parseProgram() -> Program {
        var program = Program()
        
        while curToken.tokenType != TokenType.EOF {
            if let stmt = parseStatement() {
                program.statements.append(stmt)
            }
            nextToken()
        }
        return program
    }
    
    func parseStatement() -> Statement? {
        switch curToken.tokenType {
        case .LET:
            return parseLetStatement()
        case .RETURN:
            return parseReturnStatement()
        default:
            return parseExpressStatement()
        }
    }
    
    func parseExpressStatement() -> ExpressionStatement {
        var statement = ExpressionStatement(token: curToken, expression: nil)
        statement.expression = parseExpression(precedence: OperatorOrder.LOWEST)
        if isPeekTokenType(type: TokenType.SEMICOLON) {
            nextToken()
        }
        return statement
    }
    
    func parseReturnStatement() -> ReturnStatement? {
        let token = curToken
        nextToken()
        
        let returnValue = parseExpression(precedence: OperatorOrder.LOWEST)
        while isPeekTokenType(type: TokenType.SEMICOLON){
            nextToken()
        }

        return ReturnStatement(token: token, returnValue: returnValue)
    }
    
    func parseLetStatement() -> LetStatement? {
        let token = curToken
        if expectPeek(type: TokenType.IDENT) == false {
            return nil
        }
        
        let name = Identifier(token: curToken, value: curToken.literal)
        if expectPeek(type: TokenType.ASSIGN) == false {
            return nil
        }
        
        nextToken()
        let expression = parseExpression(precedence: OperatorOrder.LOWEST)
        
        while isPeekTokenType(type: TokenType.SEMICOLON) {
            nextToken()
        }
        
        return LetStatement(token: token, name: name, value: expression)
    }
    
    func isCurrentTokenType(type: TokenType) -> Bool {
       return curToken.tokenType == type
    }

    func isPeekTokenType(type: TokenType) -> Bool {
        return peekToken.tokenType == type
    }
    
    func expectPeek(type: TokenType) -> Bool {
        if isPeekTokenType(type: type) {
            nextToken()
            return true
        } else {
            peekError(type: type)
            return false
        }
    }
    
    func peekError(type: TokenType) {
        let error = "expected next token to be "
            + peekToken.tokenType.rawValue
            + ", got " + type.rawValue + " instead."
        errors.append(error)
    }
    
    func registerPrefix(type: TokenType, function: @escaping prefixParseFn) {
        prefixParseFunctions[type] = function
    }
    
    func registerInfix(type: TokenType, function: @escaping infixParseFn) {
        infixParseFunctions[type] = function
    }
    
    func parseExpression(precedence: OperatorOrder) -> Expression? {
        guard let prefix = prefixParseFunctions[curToken.tokenType] else {
            noPrefixParseFunctionError(tokenType: curToken.tokenType)
            return nil
        }
        var leftExp = prefix()
        while ( isPeekTokenType(type: TokenType.SEMICOLON) == false && precedence.rawValue < peekPercedence.rawValue) {
            let infix = infixParseFunctions[peekToken.tokenType]
            if infix == nil {
                return leftExp
            }
            nextToken()
            leftExp = infix!(leftExp)
        }
        return leftExp
    }
    
    func parseIdentifier() -> Expression {
        return Identifier(token: curToken, value: curToken.literal)
    }
    
    func parseBoolean() -> Expression {
        return Boolean(token: curToken, value: isCurrentTokenType(type: TokenType.TRUE))
    }
    
    func parseIntegerLiteral() -> Expression {
        if let intValue = Int(curToken.literal) {
            return IntegerLiteral(token: curToken, value: intValue)
        } else {
            let error = "could not parse \(curToken.literal) as integer"
            errors.append(error)
            return IntegerLiteral(token: curToken, value: 0)
        }
    }
    
    func parsePrefixExpression() -> Expression {
        let token = curToken
        nextToken()
        let expression = PrefixExpression(token: token,
                                          operatorLiteral: token.literal,
                                          right: parseExpression(precedence: OperatorOrder.PREFIX))
        return expression
    }
    
    func parseInfixExpression(left: Expression) -> Expression {
        
        let token = curToken
        let precedence = curPercedence
        nextToken()
        let expression = InfixExpression(token: token,
                                          left: left,
                                          operatorLiteral: token.literal,
                                          right: parseExpression(precedence: precedence))
        return expression
    }

    
    func noPrefixParseFunctionError(tokenType: TokenType){
        let message = "no prefix parse function for \(tokenType.rawValue) found"
        errors.append(message)
    }
    
    func parseGroupExpression() -> Expression {
        nextToken()

        let exp = parseExpression(precedence: OperatorOrder.LOWEST)
        if expectPeek(type: TokenType.RPAREN) == false {
            return InvalidExpression()
        }

        return exp ?? InvalidExpression()
    }
    
    func parseBlockStatement() -> BlockStatement {
        var block = BlockStatement(token:curToken, statements: [])
        nextToken()
        while isCurrentTokenType(type: TokenType.RBRACE) == false
            && isCurrentTokenType(type: TokenType.EOF) == false
        {
            if let stmt = parseStatement() {
                block.statements.append(stmt)
            }
            nextToken()
        }
        return block
    }
    
    func parseIfExpression() -> Expression {
        let token = curToken
        if expectPeek(type: TokenType.LPAREN) == false {
            return InvalidExpression()
        }
        nextToken()
        guard let condition = parseExpression(precedence: OperatorOrder.LOWEST) else { return InvalidExpression() }
        if !expectPeek(type: TokenType.RPAREN) { return InvalidExpression() }
        if !expectPeek(type: TokenType.LBRACE) { return InvalidExpression() }

        let consequence = parseBlockStatement()
        var alter:BlockStatement?
        
        if isPeekTokenType(type: TokenType.ELSE) {
            nextToken()
            if !expectPeek(type: TokenType.LBRACE) {
                return InvalidExpression()
            }
            alter = parseBlockStatement()
        }
        
        let ifExp = IfExpression(token: token, condition: condition, consequence: consequence, alternative: alter)
        return ifExp
    }
    
    func parseFunctionLiteral() -> Expression {
        let token = curToken
        if expectPeek(type: TokenType.LPAREN) == false {
            return InvalidExpression()
        }
        let param = parseFunctionParameters()
        if expectPeek(type: TokenType.LBRACE) == false {
            return InvalidExpression()
        }
        let body = parseBlockStatement()
        return FunctionLiteral(token:token, parameters: param, body: body)
    }
    
    func parseFunctionParameters() -> [Identifier] {
        var identfiers:[Identifier] = []
        if isPeekTokenType(type: TokenType.RPAREN) {
            nextToken()
            return identfiers
        }
        nextToken()
        let ident = Identifier(token: curToken, value: curToken.literal)
        identfiers.append(ident)
        
        while isPeekTokenType(type: TokenType.COMMA) {
            nextToken()
            nextToken()
            let idenParam = Identifier(token: curToken, value: curToken.literal)
            identfiers.append(idenParam)
        }
        
        if expectPeek(type: TokenType.RPAREN) == false {
            return []
        }
        return identfiers
    }
    
    func parseCallExpression(function: Expression) -> Expression {
        let token = curToken
        let args = parseCallArguments()
        return CallExpression(token: token, function: function, arguments: args)
    }
    
    func parseCallArguments() -> [Expression] {
        var args:[Expression] = []
        if isPeekTokenType(type: TokenType.RPAREN) {
            nextToken()
            return args
        }
        nextToken()
        if let ex = parseExpression(precedence: OperatorOrder.LOWEST) {
            args.append(ex)
        }
        
        while isPeekTokenType(type: TokenType.COMMA) {
            nextToken()
            nextToken()
            if let ex = parseExpression(precedence: OperatorOrder.LOWEST) {
                args.append(ex)
            }
        }
        
        if expectPeek(type: TokenType.RPAREN) == false {
            return []
        }
        return args
    }

}
