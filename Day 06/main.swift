//
//  main.swift
//  Day 06
//
//  Created by Stephen H. Gerstacker on 2021-12-06.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData
let runs = 256

let initialState = data.split(separator: ",").map { Int($0)! }

var state: [Int] = [Int](repeating: 0, count: 7)
var new: [Int] = [Int](repeating: 0, count: 2)

for value in initialState {
    state[value] += 1
}

print("Day 0: \(state) + \(new)")

for day in 0..<runs {
    let value = state.removeFirst()
    state.append(value)
    new.append(value)

    let extra = new.removeFirst()
    state[6] += extra

    print("Day \(day + 1): \(state) + \(new)")
}

let total = state.reduce(0, +) + new.reduce(0, +)
print("Total: \(total)")
