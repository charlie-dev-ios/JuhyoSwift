// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation
import Darwin

@main
struct JuhyoCLI: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "juhyo",
            subcommands: [
                Repeat.self,
                Sample.self,
            ]
        )
    }

    func run() async throws {
        throw CleanExit.helpRequest()
    }
}

struct Repeat: AsyncParsableCommand {
    @Argument(help: "The phrase to repeat.")
    var phrase: String

    @Option(help: "The number of times to repeat 'phrase'.")
    var count: Int? = nil

    mutating func run() async throws {
        let repeatCount = count ?? 2
        for _ in 0 ..< repeatCount {
            print(phrase)
        }
    }
}

struct Sample: AsyncParsableCommand {
    func run() async throws {
        let e = "\u{1B}"
        let bold = "\(e)[1m"
        let black = "\(e)[30m"
        let red = "\(e)[31m"
        let green = "\(e)[32m"
        let yellow = "\(e)[33m"
        let blue = "\(e)[34m"
        let magenta = "\(e)[35m"
        let cyan = "\(e)[36m"
        let white = "\(e)[37m"
        let reset = "\(e)[0m"

        let outputText = """
        \(e)[30mtext\(reset)
        \(e)[31mtext\(reset)
        \(e)[32mtext\(reset)
        \(e)[33mtext\(reset)
        \(e)[34mtext\(reset)
        \(e)[35mtext\(reset)
        \(e)[36mtext\(reset)
        \(e)[37mtext\(reset)
        \(e)[0mtext\(reset)

        \(bold)\(magenta)  ● andOperator\(reset)
          Prefer comma over && in if, guard or while conditions.
        \(white)
          ╭──────────────────────────────────────────────────────────────────────────────┬───────────────────────────────────────────────────────────────────────────╮
          │                                                                              │                                                                           │
          │ \(reset)\(bold)--enable andOperator\(reset)\(white)                                                         │ \(reset)\(bold)--disable andOperator\(reset)\(white)                                                     │
          │                                                                              │                                                                           │
          ├──────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────┤
          │ \(red)if true && true {\(white)                                                            │ \(green)if true, true {\(white)                                                           │
          ├──────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────┤
          │ \(red)guard true && true else {\(white)                                                    │ \(green)guard true, true else {\(white)                                                   │
          ├──────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────┤
          │ \(red)if functionReturnsBool() && true {\(white)                                           │ \(green)if functionReturnsBool(), true {\(white)                                          │
          ├──────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────┤
          │ \(red)if functionReturnsBool() && variable {\(white)                                       │ \(green)if functionReturnsBool(), variable {\(white)                                      │
          ╰──────────────────────────────────────────────────────────────────────────────┴───────────────────────────────────────────────────────────────────────────╯

        """
        print(outputText)

        print("キー入力を監視中 (Ctrl+C で終了):")

        let terminal = TerminalImpl()
        let renderer = RendererImpl(terminal: terminal)
        let keyStrokeListener = KeyStrokeListener(terminal: terminal)

        keyStrokeListener.listen(onKeyPress: { keyStroke in
            if case .escape = keyStroke {
                renderer.render("exit")
                return .abort
            }
            if case .arrowUp = keyStroke {
                renderer.moveCursorUp()
                return .continue
            }
            renderer.render("\(keyStroke)")
            return .continue
        })
        _stdlib.exit(0)
    }
}

