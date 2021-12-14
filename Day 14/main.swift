//
//  main.swift
//  Day 14
//
//  Created by Stephen H. Gerstacker on 2021-12-14.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Algorithms
import Foundation
import Utilities

let data = InputData

struct Rule: CustomDebugStringConvertible, Hashable {
    let input: String
    let result: String.Element
    let output: [String]

    init(input: String, result: String.Element) {
        self.input = input
        self.result = result

        let firstIndex = input.startIndex
        let first = String(input[firstIndex])

        let secondIndex = input.index(after: firstIndex)
        let second = String(input[secondIndex])

        self.output = [
            "\(first)\(result)",
            "\(result)\(second)"
        ]
    }

    var debugDescription: String {
        return "\(input) -> [\(output[0]),\(output[1])]"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(input)
    }
}

struct SolverResult {
    let maxCharacter: String
    let maxCount: Int

    let minCharacter: String
    let minCount: Int

    var result: Int {
        maxCount - minCount
    }
}

class Solver {

    let initialPairs: [String]
    let rules: [String:Rule]

    init(template: String, rules: [String:Rule]) {
        initialPairs = template.adjacentPairs().map { "\($0.0)\($0.1)" }
        self.rules = rules
    }

    func run(steps: Int) -> SolverResult {
        var currentTotals: [String:Int] = [:]

        for pair in initialPairs {
            currentTotals[pair] = (currentTotals[pair] ?? 0) + 1
        }

        for _ in 0 ..< steps {
            var nextTotals: [String:Int] = [:]

            for (key, value) in currentTotals {
                let rule = rules[key]!

                for pair in rule.output {
                    nextTotals[pair] = (nextTotals[pair] ?? 0) + value
                }
            }

            currentTotals = nextTotals
        }

        var finalTotals: [String.Element:Int] = [:]

        for (key, value) in currentTotals {
            let firstIndex = key.startIndex
            let first = key[firstIndex]

            finalTotals[first] = (finalTotals[first] ?? 0) + value

            let secondIndex = key.index(after: firstIndex)
            let second = key[secondIndex]

            finalTotals[second] = (finalTotals[second] ?? 0) + value
        }

        let (maxCharacter, maxCount) = finalTotals.max { $0.1 < $1.1 }!
        let (minCharacter, minCount) = finalTotals.min { $0.1 < $1.1 }!

        return SolverResult(
            maxCharacter: String(maxCharacter),
            maxCount: Int(ceil(Double(maxCount) / 2.0)),
            minCharacter: String(minCharacter),
            minCount: Int(ceil(Double(minCount) / 2.0))
        )
    }
}

var lines = data.components(separatedBy: .newlines)

let templateString = lines.removeFirst()

lines.removeFirst()

var rules: [String:Rule] = [:]

for line in lines {
    let parts = line.split(separator: " ")
    precondition(parts.count == 3)

    let lhs = String(parts[0])
    let rhs = String(parts[2])

    let rule = Rule(input: lhs, result: rhs.first!)
    rules[lhs] = rule
}

// MARK: - Part 1

let solver1 = Solver(template: templateString, rules: rules)

let (time1, result1) = benchmark {
    solver1.run(steps: 10)
}

print("Part 1")
print("------")
print("Max: \(result1.maxCharacter) = \(result1.maxCount)")
print("Min: \(result1.minCharacter) = \(result1.minCount)")
print("Result: \(result1.result)")
print("Duration: \(time1)")

// MARK: - Part 2

let solver2 = Solver(template: templateString, rules: rules)

let (time2, result2) = benchmark {
    solver2.run(steps: 40)
}

print()
print("Part 2")
print("------")
print("Max: \(result2.maxCharacter) = \(result2.maxCount)")
print("Min: \(result2.minCharacter) = \(result2.minCount)")
print("Result: \(result2.result)")
print("Duration: \(time2)")
