//
//  main.swift
//  Day 05
//
//  Created by Stephen H. Gerstacker on 2021-12-05.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import simd

let data = InputData

struct Line: CustomStringConvertible {
    let start: SIMD2<Int>
    let end: SIMD2<Int>
    
    var description: String {
        return "\(start) -> \(end)"
    }
    
    var covers: [SIMD2<Int>] {
        if start.x != end.x && start.y != end.y {
            return []
        }
        
        var result =  [start]
        
        let diff: SIMD2<Int>
        
        if start.x == end.x {
            if start.y > end.y {
                diff = SIMD2<Int>(x: 0, y: -1)
            } else {
                diff = SIMD2<Int>(x: 0, y: 1)
            }
        } else {
            if start.x > end.x {
                diff = SIMD2<Int>(x: -1, y: 0)
            } else {
                diff = SIMD2<Int>(x: 1, y: 0)
            }
        }
        
        var current = start
        
        repeat {
            current &+= diff
            result.append(current)
        } while (current != end)
        
        return result
    }
    
    var coversFull: [SIMD2<Int>] {
        var result =  [start]
        
        let diff: SIMD2<Int> = end &- start
        
        let absX = diff.x == 0 ? 1 : abs(diff.x)
        let absY = diff.y == 0 ? 1 : abs(diff.y)
        
        let absDiff = SIMD2<Int>(x: absX, y: absY)
        let step = diff / absDiff
        
        var current = start
        
        repeat {
            current &+= step
            result.append(current)
        } while (current != end)
        
        return result
    }
}

let lines = data
    .components(separatedBy: .newlines)
    .map { line -> Line in
        let parts = line.split(separator: " ")
        precondition(parts.count == 3)
        
        let leftParts = parts[0].split(separator: ",")
        let rightParts = parts[2].split(separator: ",")
        
        precondition(leftParts.count == 2)
        precondition(rightParts.count == 2)
        
        let start = SIMD2<Int>(x: Int(leftParts[0])!, y: Int(leftParts[1])!)
        let end = SIMD2<Int>(x: Int(rightParts[0])!, y: Int(rightParts[1])!)
        
        return Line(start: start, end: end)
    }

var covered: [SIMD2<Int>:Int] = [:]
var coveredFull: [SIMD2<Int>:Int] = [:]

for line in lines {
    for cover in line.covers {
        if let value = covered[cover] {
            covered[cover] = value + 1
        } else {
            covered[cover] = 1
        }
    }
    
    for cover in line.coversFull {
        if let value = coveredFull[cover] {
            coveredFull[cover] = value + 1
        } else {
            coveredFull[cover] = 1
        }
    }
}

var count = 0

for (_, value) in covered {
    if value >= 2 {
        count += 1
    }
}

print("Count: \(count)")

var fullCount = 0

for (_, value) in coveredFull {
    if value >= 2 {
        fullCount += 1
    }
}

print("Full Count: \(fullCount)")
