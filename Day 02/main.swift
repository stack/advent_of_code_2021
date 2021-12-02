//
//  main.swift
//  Day 02
//
//  Created by Stephen H. Gerstacker on 2021-12-02.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

enum Command: CustomStringConvertible {
    case forward(Int)
    case down(Int)
    case up(Int)

    static func parse(_ value: String) -> Command {
        let parts = value.split(separator: " ")
        precondition(parts.count == 2)

        let amount = Int(parts[1])!

        switch parts[0] {
        case "forward":
            return .forward(amount)
        case "down":
            return .down(amount)
        case "up":
            return .up(amount)
        default:
            fatalError("Unhandled direction: \(parts[0])")
        }
    }

    var description: String {
        switch self {
        case .forward(let amount):
            return "Forward \(amount)"
        case .down(let amount):
            return "Down \(amount)"
        case.up(let amount):
            return "Up \(amount)"
        }
    }
}

let data = InputData

let commands = data.map { Command.parse($0) }

// MARK: - Part 1

print("Part 1:")
print("")

var x = 0
var y = 0

for command in commands {
    let previousX = x
    let previousY = y

    switch command {
    case .forward(let amount):
        x += amount
    case .down(let amount):
        y += amount
    case .up(let amount):
        y -= amount
    }

    print("[\(previousX), \(previousY)] -> \(command) -> [\(x), \(y)]")
}

print("Horizontal: \(x), Depth: \(y): Result: \(x * y)")

// MARK: - Part 2

print("")
print("Part 1:")
print("")

x = 0
y = 0
var aim = 0

for command in commands {
    let previousX = x
    let previousY = y
    let previousAim = aim

    switch command {
    case .forward(let amount):
        x += amount
        y += aim * amount
    case .down(let amount):
        aim += amount
    case .up(let amount):
        aim -= amount
    }

    print("[\(previousX), \(previousY)] @ \(previousAim) -> \(command) -> [\(x), \(y)] @ \(aim)")
}

print("Horizontal: \(x), Depth: \(y): Result: \(x * y)")
