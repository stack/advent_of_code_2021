//
//  main.swift
//  Day 10
//
//  Created by Stephen H. Gerstacker on 2021-12-10.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

let openers: Set<String.Element> = ["(", "[", "{", "<"]
let closers: Set<String.Element> = [")", "]", "}", ">"]

let matches: [String.Element:String.Element] = [
    "(": ")",
    ")": "(",
    "[": "]",
    "]": "[",
    "{": "}",
    "}": "{",
    "<": ">",
    ">": "<",
]

let corruptedPoints: [String.Element:Int] = [
    ")" : 3,
    "]" : 57,
    "}" : 1197,
    ">" : 25137,
]

let incompletePoints: [String.Element:Int] = [
    ")": 1,
    "]": 2,
    "}": 3,
    ">": 4,
]

var totalCorruptedPoints = 0
var totalIncompletePoints: [Int] = []

for line in data.components(separatedBy: .newlines) {
    var chunkStack: [String.Element] = []

    var illegalChar: String.Element? = nil
    var expectedChar: String.Element? = nil

    for char in line {
        if chunkStack.isEmpty {
            chunkStack.append(char)
        } else if openers.contains(char) {
            chunkStack.append(char)
        } else if closers.contains(char) {
            let latestOpener = chunkStack.last!
            let expectedCloser = matches[latestOpener]!

            if char == expectedCloser {
                chunkStack.removeLast()
            } else {
                illegalChar = char
                expectedChar = expectedCloser
                break
            }
        } else {
            fatalError("Invalid state!")
        }
    }

    if let illegal = illegalChar, let expected = expectedChar {
        print("\(line) - Expected \(expected), but found \(illegal) instead.")
        totalCorruptedPoints += corruptedPoints[illegal]!
    } else if !chunkStack.isEmpty {
        let completion = chunkStack.reversed().map { matches[$0]! }
        let completionString = completion.map { String($0) }.joined()

        print("\(line) - Complete by adding \(completionString)")

        let total = completion.reduce(0) { ($0 * 5) + incompletePoints[$1]! }
        totalIncompletePoints.append(total)
    }
}

print("Total Corrupted Points: \(totalCorruptedPoints)")

let middle = totalIncompletePoints.sorted()[totalIncompletePoints.count /  2]
print("Middle Incomplete Points: \(middle)")
