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
