//
//  main.swift
//  Day 08
//
//  Created by Stephen H. Gerstacker on 2021-12-08.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

struct Segment {

    let initial: String
    let activated: Set<String>

    init(stringValue: String) {
        initial = stringValue
        activated = Set(stringValue.map { String($0) })
    }

    init(stringValue: Substring) {
        initial = String(stringValue)
        activated = Set(stringValue.map { String($0) })
    }

    var possibleValues: [Int] {
        switch activated.count {
        case 2:
            return [1]
        case 3:
            return [7]
        case 4:
            return [4]
        case 5:
            return [2, 3, 5]
        case 6:
            return [0, 6, 9]
        case 7:
            return [8]
        default:
            fatalError("Unhandled count")
        }
    }
}

struct SegmentSolver {

    var segmentPossibilities: [Set<String>]

    init() {
        let fullSet: Set<String> = ["a", "b", "c", "d", "e", "f", "g"]
        segmentPossibilities = [Set<String>](repeating: fullSet, count: 7)
    }

    mutating func consider(_ segment: Segment) {
        let indexes: [Int]

        switch segment.activated.count {
        case 2: // This is a one
            indexes = [2, 5]
        case 3: // This is a seven
            indexes = [0, 2, 5]
        case 4: // This is a four
            indexes = [1, 2, 3, 5]
        case 7: // This is an eight
            indexes = [0, 1, 2, 3, 4, 5, 6]
        default:
            fatalError("Unhandled segment type")
        }

        for index in indexes {
            segmentPossibilities[index] = segmentPossibilities[index].intersection(segment.activated)
        }
    }

    mutating func reduce() {
        var visitedSets: Set<Set<String>> = []

        while !allVisited(visitedSets) {
            for count in 1...7 {
                var reset = false

                for index in 0..<segmentPossibilities.count {
                    guard segmentPossibilities[index].count == count else { continue }
                    guard !visitedSets.contains(segmentPossibilities[index]) else { continue }

                    if countMatchingSets(segmentPossibilities[index]) == count {
                        drop(segmentPossibilities[index])
                        visitedSets.insert(segmentPossibilities[index])

                        reset = true
                        break
                    }
                }

                if reset { break }
            }
        }
    }

    func guess(_ segment: Segment) -> [Int] {
        var guesses: [Int] = []

        let possibles = segment.possibleValues

        if possibles.count == 1 {
            return possibles
        }

        for possible in possibles {
            if doesFit(value: possible, segment: segment) {
                guesses.append(possible)
            }
        }

        return guesses
    }

    private func allVisited(_ visited: Set<Set<String>>) -> Bool {
        var current: Set<Set<String>> = []

        for segmentPossibility in segmentPossibilities {
            current.insert(segmentPossibility)
        }

        return visited == current
    }

    private func doesFit(value: Int, segment: Segment) -> Bool {
        precondition(value >= 0)
        precondition(value < 10)

        let allIndexes = [
            [0, 1, 2, 4, 5, 6],
            [2, 5],
            [0, 2, 3, 4, 6],
            [0, 2, 3, 5, 6],
            [1, 2, 3, 5],
            [0, 1, 3, 5, 6],
            [0, 1, 3, 4, 5, 6],
            [0, 2, 5],
            [0, 1, 2, 3, 4, 5, 6],
            [0, 1, 2, 3, 5, 6],
        ]

        var possibilities = segmentPossibilities

        for current in segment.activated {
            var found = false

            for index in allIndexes[value] {
                if possibilities[index].contains(current) {
                    if found {
                        possibilities[index].remove(current)
                    } else {
                        possibilities[index] = [current]
                        found = true
                    }
                }
            }

            if !found {
                return false
            }
        }

        return true
    }

    private func countMatchingSets(_ source: Set<String>) -> Int {
        segmentPossibilities.filter { $0 == source }.count
    }

    private mutating func drop(_ set: Set<String>) {
        for index in 0 ..< segmentPossibilities.count {
            guard segmentPossibilities[index] != set else { continue }

            segmentPossibilities[index] = segmentPossibilities[index].subtracting(set)
        }
    }
}

var inputs: [[Segment]] = []
var outputs: [[Segment]] = []

for line in data.components(separatedBy: .newlines) {
    let parts = line.split(separator: "|")
    precondition(parts.count == 2)

    let input = parts[0].split(separator: " ").map { Segment(stringValue: $0) }
    inputs.append(input)

    let output = parts[1].split(separator: " ").map { Segment(stringValue: $0) }
    outputs.append(output)
}

// MARK: - Part 1

let uniqueCount = outputs.reduce(0) { sum, segments in
    return sum + segments.reduce(0, { sum, segment in
        return sum + (segment.possibleValues.count == 1 ? 1 : 0)
    })
}

print("Unique Count: \(uniqueCount)")

// MARK: - Part 2

var total = 0

for (input, output) in zip(inputs, outputs) {
    var solver = SegmentSolver()

    for segment in input {
        if segment.possibleValues.count == 1 {
            solver.consider(segment)
        }
    }

    solver.reduce()

    let inputDecoded: [Int] = input.reduce([]) { sum, segment in
        sum + solver.guess(segment)
    }

    precondition(inputDecoded.count == input.count)

    let inputs = input.map { $0.initial }.joined(separator: " ")
    print(inputs)
    print(inputDecoded.map { String($0) }.joined(separator: " "))

    let outputDecoded: [Int] = output.reduce([]) { sum, segment in
        sum + solver.guess(segment)
    }

    precondition(outputDecoded.count == output.count)

    let outputs = output.map { $0.initial }.joined(separator: " ")
    print(outputs)
    print(outputDecoded.map { String($0) }.joined(separator: " "))

    let outputValue = Int(outputDecoded.map { String($0) }.joined())!
    total += outputValue
}

print("Total: \(total)")
