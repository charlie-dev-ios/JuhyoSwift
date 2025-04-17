import Darwin

protocol Terminal {
    func readCharacter(nonBlockingMode: Bool) -> Character?
}

final class TerminalImpl: Terminal {
    func readCharacter(nonBlockingMode: Bool) -> Character? {
        var term = termios()
        let stdinFileDescriptor = fileno(stdin) // Get file descriptor of standard input stream
        tcgetattr(stdinFileDescriptor, &term) // Get terminal attributes of standard input stream
        var original = term

        let flags = fcntl(stdinFileDescriptor, F_GETFL) // Get the current file status flags for the standard input file descriptor
        if nonBlockingMode {
            _ = fcntl(stdinFileDescriptor, F_SETFL, flags | O_NONBLOCK) // Set non-blocking mode
        }

        term.c_lflag &= ~tcflag_t(ECHO)   // Disable echoing of input characters to the terminal.
        term.c_lflag &= ~tcflag_t(ICANON) // Disable canonical mode, allowing raw character input.
        tcsetattr(stdinFileDescriptor, TCSANOW, &term) // Apply changes immediately

        let char = getchar() // Read single character

        if nonBlockingMode {
            _ = fcntl(stdinFileDescriptor, F_SETFL, flags)
        }

        tcsetattr(stdinFileDescriptor, TCSANOW, &original) // Restore original settings immediately
        return char != EOF ? Character(UnicodeScalar(UInt8(char))) : nil
    }
}

extension Character {
    var isPrintable: Bool {
        isLetter || isNumber || isPunctuation || isSymbol || (isWhitespace && !isNewline)
    }
}

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
}

struct KeyStrokeListener {
    private let terminal: Terminal

    init(terminal: Terminal) {
        self.terminal = terminal
    }

    func listen(onKeyPress: @escaping (KeyStroke) -> OnKeyPressResult) {
        loop: while let character = terminal.readCharacter(nonBlockingMode: false) {
            var buffer = String(character)

            if buffer == .escapeSequence {
                while let nextCharacter = terminal.readCharacter(nonBlockingMode: true) {
                    buffer.append(nextCharacter)
                }
            }

            let keyStroke: KeyStroke? = switch buffer {
            case let buffer where buffer.count == 1 && character.isPrintable:
                .printable(character)
            case .returnKey:
                .returnKey
            case .arrowUpKey:
                .arrowUpKey
            case .arrowDownKey:
                .arrowDownKey
            case .arrowRightKey:
                .arrowRightKey
            case .arrowLeftKey:
                .arrowLeftKey
            case .backspaceKey:
                .backspace
            case .deleteKey:
                .delete
            case .escapeKey:
                .escape
            default:
                nil
            }

            if let keyStroke {
                switch onKeyPress(keyStroke) {
                case .abort:
                    break loop
                case .continue:
                    continue
                }
            }
        }
    }
}

public enum KeyStroke {
    case returnKey
    case printable(Character)
    case arrowUpKey
    case arrowDownKey
    case arrowLeftKey
    case arrowRightKey
    case backspace
    case delete
    case escape
}

public enum OnKeyPressResult {
    case abort
    case `continue`
}

