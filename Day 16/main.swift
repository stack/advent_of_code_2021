//
//  main.swift
//  Day 16
//
//  Created by Stephen H. Gerstacker on 2021-12-16.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

BitsDecoder.test()

// MARK: - Part 1

let data1 = InputData

let decoder1 = BitsDecoder()
let results1 = decoder1.decode(data1)
let result1 = results1.first!

print("Part 1:")
print("Version sum: \(result1.versionSum)")

// MARK: - Part 2

let data2 = InputData

let decoder2 = BitsDecoder()
let results2 = decoder2.decode(data2)
let result2 = results2.first!

print()
print("Part 2:")
print("Tree:\n\(result2.description)")
print("Result: \(result2.evaluate())")

