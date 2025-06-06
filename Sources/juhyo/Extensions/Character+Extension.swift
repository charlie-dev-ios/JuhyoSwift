import Foundation

extension Character {
    var isPrintable: Bool {
        isLetter || isNumber || isPunctuation || isSymbol || (isWhitespace && !isNewline)
    }
}
