import Foundation

extension String {
    static let escapeSequence = "\u{1B}"
    static let arrowUpKey = "\u{1B}[A"
    static let arrowDownKey = "\u{1B}[B"
    static let arrowRightKey = "\u{1B}[C"
    static let arrowLeftKey = "\u{1B}[D"
    static let backspaceKey = "\u{08}"
    static let deleteKey = "\u{7F}"
    static let escapeKey = "\u{1B}"
    static let returnKey = "\n"
    static let deleteLine = "\u{1B}[2K"
    static let moveUpKey = "\u{1B}[1A"
}
