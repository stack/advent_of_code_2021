//
//  main.swift
//  Day 07
//
//  Created by Stephen H. Gerstacker on 2021-12-07.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

let initialPositions = data.split(separator: ",").map { Int($0)! }

let min = initialPositions.min()!
let max = initialPositions.max()!

// MARK: - Part 1

var cheapest: Int = .max
var cheapestCost: Int = .max

for target in (min ... max) {
    let fuelSpent = initialPositions.map { abs($0 - target ) }
    let total = fuelSpent.reduce(0, +)

    if total < cheapestCost {
        cheapestCost = total
        cheapest = target
    }

    print("\(target): \(total)")
}

print("")
print("Cheapest 1: \(cheapest) - \(cheapestCost)")
print("")

// MARK: - Part 2

cheapest = .max
cheapestCost = .max

for target in (min ... max) {
    let fuelSpent = initialPositions.map { value -> Int in
        let distance = abs(value - target )
        return (distance * (distance + 1)) / 2
    }

    let total = fuelSpent.reduce(0, +)

    if total < cheapestCost {
        cheapestCost = total
        cheapest = target
    }

    print("\(target): \(total)")
}

print("")
print("Cheapest 2: \(cheapest) - \(cheapestCost)")
print("")
