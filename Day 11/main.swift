//
//  main.swift
//  Day 11
//
//  Created by Stephen H. Gerstacker on 2021-12-11.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

struct Point: CustomStringConvertible, CustomDebugStringConvertible, Hashable {
    let x: Int
    let y: Int
    
    var description: String {
        "(\(x),\(y))"
    }
    
    var debugDescription: String {
        description
    }
}

func printBoard(data: [[Int]]) {
    for line in data {
        let output = line.map {
            if $0 == 0 {
                return "•"
            } else if $0 > 9 {
                return "+"
            } else {
                return String($0)
            }
        }.joined()
        
        print(output)
    }
}

var current = data
    .components(separatedBy: .newlines)
    .map { $0.map { Int(String($0))! } }
var next = current

print("Before any steps:")
printBoard(data: current)

var first100Flashes = 0
var firstAllFlashes: Int? = nil
var step = 0

while true {
    var toFlash: [Point] = []
    
    for y in 0 ..< current.count {
        for x in 0 ..< current[0].count {
            next[y][x] = current[y][x] + 1
            
            if next[y][x] > 9 {
                toFlash.append(Point(x: x, y: y))
            }
        }
    }
    
    var hasFlashed: Set<Point> = []
    
    while !toFlash.isEmpty {
        let flashPoint = toFlash.removeFirst()
        
        guard !hasFlashed.contains(flashPoint) else { continue }
        
        hasFlashed.insert(flashPoint)
        
        if step < 100 {
            first100Flashes += 1
        }
        
        for yOffset in -1...1 {
            for xOffset in -1...1 {
                guard xOffset != 0 || yOffset != 0 else { continue }
                
                let testPoint = Point(x: flashPoint.x + xOffset, y: flashPoint.y + yOffset)
                
                guard (0..<next[0].count).contains(testPoint.x) else { continue }
                guard (0..<next.count).contains(testPoint.y) else { continue }
                
                next[testPoint.y][testPoint.x] += 1
                
                if next[testPoint.y][testPoint.x] > 9 {
                    toFlash.append(testPoint)
                }
            }
        }
    }
    
    for point in hasFlashed {
        next[point.y][point.x] = 0
    }
    
    let temp = current
    current = next
    next = temp
    
    print()
    print("After step \(step + 1)")
    printBoard(data: current)
    
    if firstAllFlashes == nil {
        if hasFlashed.count == (current.count * current[0].count) {
            firstAllFlashes = step + 1
            break
        }
    }
    
    step += 1
}

print()
print("First 100 Flashes: \(first100Flashes)")
print("First All Flashes: \(firstAllFlashes!)")
