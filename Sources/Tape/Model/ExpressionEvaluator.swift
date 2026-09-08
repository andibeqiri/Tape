import Foundation

enum ExpressionEvaluator {
    static func evaluate(_ expression: String) -> Double? {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        guard let tokens = tokenize(trimmed) else { return nil }
        guard !tokens.isEmpty else { return nil }
        var parser = Parser(tokens: tokens)
        guard let result = parser.parseExpression() else { return nil }
        guard parser.pos == tokens.count else { return nil }
        return result
    }
}

// MARK: - Tokens

private enum Token: Equatable {
    case number(Double)
    case plus, minus, times, divide
    case lparen, rparen
}

private func tokenize(_ input: String) -> [Token]? {
    var tokens: [Token] = []
    var i = input.startIndex
    while i < input.endIndex {
        let ch = input[i]
        if ch.isWhitespace { i = input.index(after: i); continue }
        if ch.isNumber || ch == "." {
            var numStr = String(ch)
            i = input.index(after: i)
            while i < input.endIndex && (input[i].isNumber || input[i] == ".") {
                numStr.append(input[i])
                i = input.index(after: i)
            }
            guard let val = Double(numStr) else { return nil }
            tokens.append(.number(val))
        } else {
            let tok: Token
            switch ch {
            case "+":       tok = .plus
            case "-":       tok = .minus
            case "*", "×":  tok = .times
            case "/", "÷":  tok = .divide
            case "(":       tok = .lparen
            case ")":       tok = .rparen
            default:        return nil
            }
            tokens.append(tok)
            i = input.index(after: i)
        }
    }
    return tokens
}

// MARK: - Parser

private struct Parser {
    let tokens: [Token]
    var pos: Int = 0

    var current: Token? { pos < tokens.count ? tokens[pos] : nil }

    mutating func advance() { pos += 1 }

    mutating func parseExpression() -> Double? {
        guard var result = parseTerm() else { return nil }
        while let tok = current, tok == .plus || tok == .minus {
            advance()
            guard let right = parseTerm() else { return nil }
            result = tok == .plus ? result + right : result - right
        }
        return result
    }

    mutating func parseTerm() -> Double? {
        guard var result = parseUnary() else { return nil }
        while let tok = current, tok == .times || tok == .divide {
            advance()
            guard let right = parseUnary() else { return nil }
            if tok == .divide {
                guard right != 0 else { return nil }
                result /= right
            } else {
                result *= right
            }
        }
        return result
    }

    mutating func parseUnary() -> Double? {
        if current == .minus { advance(); guard let v = parseUnary() else { return nil }; return -v }
        if current == .plus  { advance(); return parseUnary() }
        return parsePrimary()
    }

    mutating func parsePrimary() -> Double? {
        guard let tok = current else { return nil }
        switch tok {
        case .number(let val):
            advance()
            return val
        case .lparen:
            advance()
            guard let val = parseExpression() else { return nil }
            guard current == .rparen else { return nil }
            advance()
            return val
        default:
            return nil
        }
    }
}
