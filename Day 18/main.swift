//
//  main.swift
//  Day 18
//
//  Created by Stephen H. Gerstacker on 2021-12-18.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

enum Token: Equatable {
    case openParen
    case closeParen
    case number(Int)
}

struct SnailfishNumber: CustomStringConvertible, Equatable {
    
    var data: [Token]
    
    static func from(_ value: String) -> SnailfishNumber {
        let data = value.compactMap { char -> Token? in
            switch char {
            case "[":
                return .openParen
            case "]":
                return .closeParen
            case ",":
                return nil
            default:
                let v = Int(String(char))!
                return .number(v)
            }
        }
        
        return SnailfishNumber(data: data)
    }
    
    static func + (lhs: SnailfishNumber, rhs: SnailfishNumber) -> SnailfishNumber {
        var nextData: [Token] = [.openParen]
        nextData.append(contentsOf: lhs.data)
        nextData.append(contentsOf: rhs.data)
        nextData.append(.closeParen)
        
        let result = SnailfishNumber(data: nextData)
        // print("after addition: \(result)")
        
        return result
    }
    
    var description: String {
        var output = ""
        
        for (idx, token) in data.enumerated() {
            let stringValue: String
            
            switch token {
            case .closeParen:
                stringValue = "]"
            case .openParen:
                stringValue = "["
            case .number(let value):
                stringValue = String(value)
            }
            
            if idx == 0 {
                output += stringValue
                continue
            }
            
            let previous = data[idx - 1]
            
            if token == .openParen {
                if previous != .openParen {
                    output += ","
                }
                
                output += stringValue
            } else if token == .closeParen {
                output += stringValue
            } else {
                if previous != .openParen {
                    output += ","
                }
                
                output += stringValue
            }
        }
        
        return output
    }
    
    var magnitude: Int {
        var workingSet = data
        
        while workingSet.count > 1 {
            for idx in 0 ..< workingSet.count - 1 {
                let lhs = workingSet[idx]
                
                guard case .number(let lhsValue) = lhs else {
                    continue
                }
                
                let rhs = workingSet[idx + 1]
                
                guard case .number(let rhsValue) = rhs else {
                    continue
                }
                
                let targetIdx = idx - 1
                workingSet.remove(at: targetIdx) // [
                workingSet.remove(at: targetIdx) // L
                workingSet.remove(at: targetIdx) // R
                workingSet.remove(at: targetIdx) // ]
                
                let result = 3 * lhsValue + 2 * rhsValue
                let token: Token = .number(result)
                
                workingSet.insert(token, at: targetIdx)
                
                break
            }
        }
        
        guard case .number(let value) = workingSet.removeFirst() else {
            fatalError("Magnitude was not a number")
        }
        
        return value
    }
    
    mutating func reduce() {
        var didRecude = false
        
        repeat {
            didRecude = reduceInternal()
        } while didRecude
    }
    
    mutating func reduceOnce() {
        reduceInternal()
    }
    
    @discardableResult private mutating func reduceInternal() -> Bool {
        var parenDepth = 0
        
        for (idx, token) in data.enumerated() {
            switch token {
            case .openParen:
                parenDepth += 1
            case .closeParen:
                parenDepth -= 1
            case .number(_):
                if parenDepth > 4 {
                    explode(at: idx - 1)
                    // print("after explode:  \(self)")
                    return true
                }
            }
        }
        
        for (idx, token) in data.enumerated() {
            if case .number(let value) = token {
                if value >= 10 {
                    split(at: idx)
                    // print("after split:    \(self)")
                    return true
                }
            }
        }
        
        return false
    }
    
    private mutating func explode(at index: Int) {
        let open = data.remove(at: index) // [
        assert(open == .openParen)
        
        let lhs = data.remove(at: index) // X
        
        guard case .number(let lhsValue) = lhs else {
            fatalError("Cannot explode, lhs is not a number")
        }
        
        let rhs = data.remove(at: index) // Y
        
        guard case .number(let rhsValue) = rhs else {
            fatalError("Cannot explode, rhs is not a number")
        }
        
        let closed = data.remove(at: index) // ]
        assert(closed == .closeParen)
        
        for leftIdx in (0 ..< index).reversed() {
            if case .number(let tokenValue) = data[leftIdx] {
                data[leftIdx] = .number(tokenValue + lhsValue)
                break
            }
        }
        
        for rightIdx in (index ..< data.count - 1) {
            if case .number(let tokenValue) = data[rightIdx] {
                data[rightIdx] = .number(tokenValue + rhsValue)
                break
            }
        }
        
        data.insert(.number(0), at: index)
    }
    
    private mutating func split(at index: Int) {
        let token = data.remove(at: index)
        
        guard case .number(let tokenValue) = token else {
            fatalError("Cannot split, value is not a number")
        }
        
        let lhs = tokenValue / 2
        let rhs = (tokenValue + 1) / 2
        
        data.insert(.closeParen, at: index)
        data.insert(.number(rhs), at: index)
        data.insert(.number(lhs), at: index)
        data.insert(.openParen, at: index)
    }
}

// MARK: - Tests

let singleTests = [
    (input: "[[[[[9,8],1],2],3],4]", expected: "[[[[0,9],2],3],4]"),
    (input: "[7,[6,[5,[4,[3,2]]]]]", expected: "[7,[6,[5,[7,0]]]]"),
    (input: "[[6,[5,[4,[3,2]]]],1]", expected: "[[6,[5,[7,0]]],3]"),
    (input: "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]", expected: "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"),
    (input: "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", expected: "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"),
]

for test in singleTests {
    var input = SnailfishNumber.from(test.input)
    let expected = SnailfishNumber.from(test.expected)
    
    input.reduceOnce()
    
    assert(input == expected, "Expected \(expected), Got \(input)")
}

let additionTests = [
    (lhs: "[1,2]", rhs: "[[3,4],5]", expected: "[[1,2],[[3,4],5]]"),
    (lhs: "[[[[4,3],4],4],[7,[[8,4],9]]]", rhs: "[1,1]", expected: "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"),
]

for test in additionTests {
    let lhs = SnailfishNumber.from(test.lhs)
    let rhs = SnailfishNumber.from(test.rhs)
    let expected = SnailfishNumber.from(test.expected)
    
    let result = lhs + rhs
    
    assert(result == expected, "Expected \(expected), Got \(result)")
}

let sumTests = [
    (input: Example1Data, expected: Example1Expected),
    (input: Example2Data, expected: Example2Expected),
    (input: Example3Data, expected: Example3Expected),
    (input: Example4Data, expected: Example4Expected),
]

for test in sumTests {
    var inputs = test.input.components(separatedBy: .newlines).map { SnailfishNumber.from($0) }
    let expected = SnailfishNumber.from(test.expected)
    
    var result = inputs.removeFirst()
    result.reduce()
    
    for input in inputs {
        
        print()
        print("  \(result)")
        print("+ \(input)")
        
        var reducedInput = input
        reducedInput.reduce()
        
        result = result + reducedInput
        result.reduce()
        
        print("= \(result)")
    }
    
    assert(result == expected, "Expected \(expected), Got \(result)")
}

let magnitudeTests = [
    (input: "[[1,2],[[3,4],5]]", expected: 143),
    (input: "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", expected: 1384),
    (input: "[[[[1,1],[2,2]],[3,3]],[4,4]]", expected: 445),
    (input: "[[[[3,0],[5,3]],[4,4]],[5,5]]", expected: 791),
    (input: "[[[[5,0],[7,4]],[5,5]],[6,6]]", expected: 1137),
    (input: "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]", expected: 3488),
]

for test in magnitudeTests {
    let input = SnailfishNumber.from(test.input)
    let expected = test.expected
    
    let result = input.magnitude
    
    assert(result == expected, "Expected \(expected), Got \(result)")
}

// MARK: - Part 1

var inputs1 = data.components(separatedBy: .newlines).map { SnailfishNumber.from($0) }

var result1 = inputs1.removeFirst()

for input in inputs1 {
    result1 = result1 + input
    result1.reduce()
}

print()
print("Part 1:")
print("Sum: \(result1)")
print("Magnitude: \(result1.magnitude)")

// MARK: - Part 2

let inputs2 = data.components(separatedBy: .newlines).map { SnailfishNumber.from($0) }

var bestLhs = inputs2.first!
var bestRhs = inputs2.last!
var bestResult = inputs2.first!
var bestMagnitued: Int = .min

for (lhsIdx, lhs) in inputs2.enumerated() {
    for (rhsIdx, rhs) in inputs2.enumerated() {
        guard lhsIdx != rhsIdx else { continue }
        
        var result = lhs + rhs
        result.reduce()
        
        let magnitued = result.magnitude
        
        if magnitued > bestMagnitued {
            bestLhs = lhs
            bestRhs = rhs
            bestResult = result
            bestMagnitued = magnitued
        }
    }
}

assert(bestMagnitued != .min)

print()
print("Part 2:")
print()
print("  \(bestLhs)")
print("+ \(bestRhs)")
print("= \(bestResult)")
print("^ \(bestMagnitued)")
