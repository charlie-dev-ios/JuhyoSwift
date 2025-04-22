import Foundation

protocol Renderer {

}

final class RendererImpl: Renderer {
    private let terminal: any Terminal

    private var lastRenderedContent: [String] = []

    init(
        terminal: some Terminal
    ) {
        self.terminal = terminal
    }

    func eraseLine() {
        terminal.write("\u{001B}[2K")
    }

    func moveCursorUp() {
        terminal.write("\u{001B}[1A")
    }

    func moveCursorToBeginningOfLine() {
        terminal.write("\u{001B}[1G")
    }

    func render(_ input: String) {
        let lines = input.split(separator: "\n")

        eraseLines(lastRenderedContent.count)

        for line in lines {
            terminal.write(String("\(line)\n"))
        }

        lastRenderedContent = lines.map { String($0) }
    }

    private func eraseLines(_ lines: Int) {
        if lines == 0 { return }
        for index in 0 ... lines {
            eraseLine()
            if index < lastRenderedContent.count {
                moveCursorUp()
            }
        }
        moveCursorToBeginningOfLine()
    }
}
