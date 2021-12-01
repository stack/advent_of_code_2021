//
//  main.swift
//  Day 01
//
//  Created by Stephen H. Gerstacker on 2021-12-01.
//

import Foundation

let data = InputData

func increasedCount(_ data: [Int]) -> Int {
    let increasedData = data.enumerated().map { (idx, depth) -> Bool in
        guard idx != 0 else { return false }

        let previousDepth = data[idx - 1]

        return depth > previousDepth
    }

    let increases = increasedData.reduce(0) { partialResult, increase in
        partialResult + (increase ? 1 : 0)
    }

    return increases
}
// MARK: - Part 1

var increases = increasedCount(data)
print("Increases: \(increases)")

// MARK: - Part 2

let windowSums = (0 ..< (data.count - 2)).map { idx -> Int in
   data[idx] + data[idx + 1] + data[idx + 2]
}

increases = increasedCount(windowSums)
print("Windowed Increases: \(increases)")
