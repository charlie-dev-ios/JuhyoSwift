// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ArgumentParser

@main
struct JuhyoCLI: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "juhyo",
            subcommands: [Repeat.self]
        )
    }

    mutating func run() async throws {
       throw CleanExit.helpRequest()
    }
}

struct Repeat: ParsableCommand {
    @Argument(help: "The phrase to repeat.")
    var phrase: String

    @Option(help: "The number of times to repeat 'phrase'.")
    var count: Int? = nil

    mutating func run() throws {
        let repeatCount = count ?? 2
        for _ in 0..<repeatCount {
            print(phrase)
        }
    }
}
