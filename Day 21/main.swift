//
//  main.swift
//  Day 21
//
//  Created by Stephen H. Gerstacker on 2021-12-21.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let data = InputData

protocol Die {
    
    mutating func roll() -> Int
    
    var totalRolls: Int { get }
}

struct DeterministicDie: Die {
    let sides: Int
    
    private var current: Int
    private(set) var totalRolls: Int
    
    init(sides: Int) {
        self.sides = sides
        
        current = 1
        totalRolls = 0
    }
    
    mutating func roll() -> Int {
        let value = current
        
        current += 1
        if current > sides {
            current = 1
        }
        
        totalRolls += 1
        
        return value
    }
}

struct Board {
    
    var positions: [Int]
    var scores: [Int]
    var currentPlayer: Int
    
    var dice: [Die]
    var currentDie: Int
    
    init(positions: [Int]) {
        self.positions = positions.map { $0 - 1 }
        scores = [Int](repeating: 0, count: positions.count)
        
        currentPlayer = 0
        
        dice = [
            DeterministicDie(sides: 100)
        ]
        
        currentDie = 0
    }
    
    mutating func takeTurn() {
        let rolls = (0 ..< 3).map { _ -> Int in
            let value = dice[currentDie].roll()
            currentDie = (currentDie + 1) % dice.count
            
            return value
        }
        
        let total = rolls.reduce(0, +)
        positions[currentPlayer] = (positions[currentPlayer] + total) % 10
        scores[currentPlayer] = scores[currentPlayer] + positions[currentPlayer] + 1
        
        let rollsString = rolls.map { String($0) }.joined(separator: "+")
        print("Player \(currentPlayer + 1) roles \(rollsString) and moves to space \(positions[currentPlayer] + 1) for a total score of \(scores[currentPlayer])")
        
        currentPlayer = (currentPlayer + 1) % positions.count
    }
    
    var hasWinner: Bool {
        for score in scores {
            if score >= 1000 {
                return true
            }
        }
        
        return false
    }
    
    var part1Score: Int {
        let losingScore = scores.min()!
        let rolls = dice[0].totalRolls
        
        return losingScore * rolls
    }
}

let positions = data.components(separatedBy: "\n").map { line -> Int in
    let parts = line.split(separator: " ")
    assert(parts.count == 5)
    
    return Int(parts[4])!
}

// MARK: - Part 1

print("Part 1:")
print("Turns:")

var board1 = Board(positions: positions)

while !board1.hasWinner {
    board1.takeTurn()
}

print()
print("Score: \(board1.part1Score)")

// MARK: - Part 2

struct State: Hashable {
    let playerPosition: Int
    let otherPosition: Int
    let playerScore: Int
    let otherScore: Int
}

var cache: [State:SIMD2<Int>] = [:]

func roll(with currentState: State) -> SIMD2<Int> {
    if currentState.playerScore >= 21 {
        return SIMD2<Int>(x: 1, y: 0)
    } else if currentState.otherScore >= 21 {
        return SIMD2<Int>(x: 0, y: 1)
    }
    
    var totalPlayerWins = 0
    var totalOtherWins = 0
    
    let sums = [(3,1), (4,3), (5,6), (6,7), (7,6), (8,3), (9,1)]
    
    for (sum, count) in sums {
        let nextPosition = (currentState.playerPosition + sum) % 10
        let nextScore = currentState.playerScore + nextPosition + 1
        
        let nextState = State(playerPosition: currentState.otherPosition, otherPosition: nextPosition, playerScore: currentState.otherScore, otherScore: nextScore)
        
        let result: SIMD2<Int>
        
        if let cachedResult = cache[nextState] {
            result = cachedResult
        } else {
            result = roll(with: nextState)
            cache[nextState] = result
        }
        
        totalPlayerWins += result.y * count
        totalOtherWins += result.x * count
    }
    
    return SIMD2<Int>(x: totalPlayerWins, y: totalOtherWins)
}

let part2State = State(playerPosition: positions[0] - 1, otherPosition: positions[1] - 1, playerScore: 0, otherScore: 0)
let (part2Timing, part2Result) = benchmark {
    roll(with: part2State)
}

print()
print("Part 2:")
print("Result: \(part2Result)")
print("Max: \(part2Result.max())")
print("Time: \(part2Timing)")
