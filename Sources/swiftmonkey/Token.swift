
public enum TokenType:String {
    case ILLEGAL = "ILLEGAL"
    case EOF     = "EOF"
    
    // Identifier & Literal
    case IDENT = "IDENT"
    case INT   = "INT"
    
    // Operator
    case ASSIGN = "="
    case PLUS   = "+"
    
    // Delimiters
    case COMMA     = ","
    case SEMICOLON = ";"
    
    case LPAREN = "("
    case RPAREN = ")"
    case LBRACE = "{"
    case RBRACE = "}"
    
    // Keywords
    case FUNCTION = "FUNCTION"
    case LET      = "LET"
}

public struct Token {
    var tokenType:TokenType
    var literal:String
}

let keywords = [ "fn": TokenType.FUNCTION,
                 "let" : TokenType.LET]

func lookupIdent(ident:String) -> TokenType {
    if let key = keywords[ident] {
        return key
    } else {
        return TokenType.IDENT
    }
}
