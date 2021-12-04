//
//  main.swift
//  Day 03
//
//  Created by Stephen H. Gerstacker on 2021-12-03.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

struct DataSet {
    let data: [[Int]]
    let length: Int

    let mostCommon: [Int]
    let leastCommon: [Int]

    init(_ rawString: String) {
        let separatedData = rawString.components(separatedBy: .newlines).map {
            $0.map { char -> Int in
                Int(String(char))!
            }
        }

        self.init(separatedData)
    }

    init(_ values: [[Int]]) {
        data = values
        length = values.first?.count ?? 0

        var zeroes = [Int](repeating: 0, count: length)
        var ones = [Int](repeating: 0, count: length)

        for line in values {
            for (idx, value) in line.enumerated() {
                if value == 0 {
                    zeroes[idx] += 1
                } else {
                    ones[idx] += 1
                }
            }
        }

        var most = [Int](repeating: .min, count: length)
        var least = [Int](repeating: .min, count: length)

        for (idx, (zero, one)) in zip(zeroes, ones).enumerated() {
            guard zero != one else { continue }

            most[idx] = zero > one ? 0 : 1
            least[idx] = zero < one ? 0 : 1
        }

        mostCommon = most
        leastCommon = least
    }
}

// MARK: - Part 1

let dataSet = DataSet(data)

let gammaString = dataSet.mostCommon.map { String($0) }.joined()
let epsilonString = dataSet.leastCommon.map { String($0) }.joined()

let gammaValue = Int(gammaString, radix: 2)!
let epsilonValue = Int(epsilonString, radix: 2)!

print("Part 1")
print("")
print("Gamma: \(gammaValue)")
print("Epsion: \(epsilonValue)")
print("Result: \(gammaValue * epsilonValue)")

// MARK: - Part 2

var generatorDataSet = dataSet
var scrubberDataSet = dataSet

var generatorString: String = ""
var scrubberString: String = ""

for idx in 0 ..< dataSet.length {
    var mostCommon = generatorDataSet.mostCommon[idx]
    mostCommon = (mostCommon == .min) ? 1 : mostCommon

    let filteredList = generatorDataSet.data.filter {
        $0[idx] == mostCommon
    }

    precondition(!filteredList.isEmpty)

    if filteredList.count == 1 {
        generatorString = filteredList.first!.map { String($0) }.joined()
        break
    } else {
        generatorDataSet = DataSet(filteredList)
    }
}

for idx in 0 ..< dataSet.length {
    var leastCommon = scrubberDataSet.leastCommon[idx]
    leastCommon = (leastCommon == .min) ? 0 : leastCommon

    let filteredList = scrubberDataSet.data.filter {
        $0[idx] == leastCommon
    }

    precondition(!filteredList.isEmpty)

    if filteredList.count == 1 {
        scrubberString = filteredList.first!.map { String($0) }.joined()
        break
    } else {
        scrubberDataSet = DataSet(filteredList)
    }
}

precondition(!generatorString.isEmpty)
precondition(!scrubberString.isEmpty)

let generatorValue = Int(generatorString, radix: 2)!
let scrubberValue = Int(scrubberString, radix: 2)!

print("")
print("Part 2")
print("")

print("Generator: \(generatorValue)")
print("Scrubber: \(scrubberValue)")
print("Result: \(generatorValue * scrubberValue)")
