import Foundation

public enum OnKeyPressResult {
    case abort
    case `continue`
}

struct KeyStrokeListener {
    private let terminal: any Terminal

    init(terminal: some Terminal) {
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

