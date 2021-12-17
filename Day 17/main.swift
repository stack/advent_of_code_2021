//
//  main.swift
//  Day 17
//
//  Created by Stephen H. Gerstacker on 2021-12-17.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Algorithms
import Foundation
import Utilities

let data = ExampleData

enum ProjectileState: CustomStringConvertible {
    case inFlight
    case hit
    case miss

    var description: String {
        switch self {
        case .inFlight:
            return "In Flight…"
        case .hit:
            return "Hit!"
        case .miss:
            return "Miss!"
        }
    }
}

struct Projectile: CustomStringConvertible {

    var visited: [SIMD2<Int>]
    var velocity: SIMD2<Int>

    var targetMin: SIMD2<Int>
    var targetMax: SIMD2<Int>

    mutating func step() {
        let currentPosition = visited.last!

        let nextPosition = currentPosition &+ velocity
        visited.append(nextPosition)

        var nextVelocity = velocity

        if nextVelocity.x > 0 {
            nextVelocity.x -= 1
        } else if nextVelocity.x < 0 {
            nextVelocity.x += 1
        }
        
        nextVelocity.y -= 1

        velocity = nextVelocity
    }

    var description: String {
        var minX = min(targetMin.x, targetMax.x)
        var maxX = max(targetMin.x, targetMax.x)
        var minY = min(targetMin.y, targetMax.y)
        var maxY = max(targetMin.y, targetMax.y)

        for visit in visited {
            if visit.x < minX { minX = visit.x }
            if visit.x > maxX { maxX = visit.x }
            if visit.y < minY { minY = visit.y }
            if visit.y > maxY { maxY = visit.y }
        }

        let width = maxX - minX + 1
        let height = maxY - minY + 1
        
        var screen = [[String]](repeating: [String](repeating: ".", count: width), count: height)
        
        for y in targetMax.y ... targetMin.y {
            for x in targetMin.x ... targetMax.x {
                let point = SIMD2<Int>(x: minX + x, y: maxY - y)
                
                screen[point.y][point.x] = "T"
            }
        }
        
        for visit in visited {
            let point = SIMD2<Int>(x: minX + visit.x, y: maxY - visit.y)
            
            if visit == visited.first! {
                screen[point.y][point.x] = "S"
            } else {
                screen[point.y][point.x] = "#"
            }
        }

        let result = screen.map { $0.joined() }.joined(separator: "\n")

        return result
    }
    
    var maxHeight: Int {
        return visited.map { $0.y }.max()!
    }

    var state: ProjectileState {
        let currentPosition = visited.last!

        if isHit(point: currentPosition) {
            return .hit
        } else if isBeyond(point: currentPosition) {
            return .miss
        } else {
            return .inFlight
        }
    }

    private func isBeyond(point: SIMD2<Int>) -> Bool {
        let startPoint = visited.first!

        if !isBetween(p0: targetMin.x, p1: startPoint.x, p2: point.x) && !isBetween(p0: targetMax.x, p1: startPoint.x, p2: point.x) {
            return false
        }

        if !isBetween(p0: targetMin.y, p1: startPoint.y, p2: point.y) && !isBetween(p0: targetMax.y, p1: startPoint.y, p2: point.y) {
            return false
        }

        if isBetween(p0: point.x, p1: startPoint.x, p2: targetMin.x) || isBetween(p0: point.x, p1: startPoint.x, p2: targetMax.x) {
            return false
        }

        if isBetween(p0: point.y, p1: startPoint.y, p2: targetMin.y) || isBetween(p0: point.y, p1: startPoint.y, p2: targetMax.y) {
            return false
        }

        return true
    }

    private func isHit(point: SIMD2<Int>) -> Bool {
        guard isBetween(p0: point.x, p1: targetMin.x, p2: targetMax.x) else {
            return false
        }

        guard isBetween(p0: point.y, p1: targetMin.y, p2: targetMax.y) else {
            return false
        }

        return true
    }

    private func isBetween(p0: Int, p1: Int, p2: Int) -> Bool {
        let minP = min(p1, p2)
        let maxP = max(p1, p2)

        return p0 >= minP && p0 <= maxP
    }
}

// MARK: - Tests

let testStartPoint = SIMD2<Int>(x: 0, y: 0)
let testTargetMin = SIMD2<Int>(x: 20, y: -5)
let testTargetMax = SIMD2<Int>(x: 30, y: -10)

let testVelocities = [
    SIMD2<Int>(x: 7, y: 2),
    SIMD2<Int>(x: 6, y: 3),
    SIMD2<Int>(x: 9, y: 0),
    SIMD2<Int>(x: 17, y: -4),
]

for testVelocity in testVelocities {
    print()
    print("Test Velocity: \(testVelocity)")
    print()

    var projectile = Projectile(visited: [testStartPoint], velocity: testVelocity, targetMin: testTargetMin, targetMax: testTargetMax)

    print(projectile)

    while projectile.state == .inFlight {
        projectile.step()

        print()
        print(projectile)
    }

    print()
    print(projectile.state)
}

// MARK: - Part 1

func isBetween(p0: Int, p1: Int, p2: Int) -> Bool {
    let minP = min(p1, p2)
    let maxP = max(p1, p2)
    
    let result = p0 >= minP && p0 <= maxP
    return result
}

func isBeyond(point: Int, start: Int, targetMin: Int, targetMax: Int) -> Bool {
    if !isBetween(p0: targetMin, p1: start, p2: point) && !isBetween(p0: targetMax, p1: start, p2: point) {
        return false
    }

    if isBetween(p0: point, p1: start, p2: targetMin) || isBetween(p0: point, p1: start, p2: targetMax) {
        return false
    }
    
    return true
}

/*
// Example Data
let startY = 0
let targetY1 = -5
let targetY2 = -10

let startX = 0
let targetX1 = 20
let targetX2 = 30
 */

// Input Data
let startY = 0
let targetY1 = -63
let targetY2 = -109

let startX = 0
let targetX1 = 179
let targetX2 = 201

let absoluteLimitY = [abs(targetY1), abs(targetY2)].max()!

var yHits: [(velocity: Int, time: Int)] = []

for velocityY in (-absoluteLimitY ... absoluteLimitY) {
    var currentPoint = startY
    var currentVelocity = velocityY
    var ticks = 0
    
    print("Y Velocity: \(velocityY)")
    
    while true {
        if isBetween(p0: currentPoint, p1: targetY1, p2: targetY2) {
            print("-   Hit: p: \(currentPoint), t: \(ticks)")
            let value = (velocity: velocityY, time: ticks)
            yHits.append(value)
        }
        
        if isBeyond(point: currentPoint, start: startY, targetMin: targetY1, targetMax: targetY2) {
            print("-   Beyond: p: \(currentPoint), t: \(ticks)")
            break
        }
        
        currentPoint += currentVelocity
        currentVelocity -= 1
        ticks += 1
        
        print("-   Step - p: \(currentPoint), v: \(currentVelocity), t: \(ticks)")
    }
}

print("Y Hits: \(yHits)")

let uniqueTimes = yHits.map { $0.time }.uniqued().sorted()

print("Unique Times: \(uniqueTimes)")

var xHits: [(time: Int, velocity: Int)] = []
let maxX = max(targetX1, targetX2)

for time in uniqueTimes {
    for velocityX in 0 ... maxX {
        var currentPoint = startX
        var currentVelocity = velocityX
        
        for _ in 0 ..< time {
            currentPoint += currentVelocity
            
            if currentVelocity > 0 {
                currentVelocity -= 1
            } else if currentVelocity < 0 {
                currentVelocity += 1
            }
        }
        
        if isBetween(p0: currentPoint, p1: targetX1, p2: targetX2) {
            let value = (time: time, velocity: velocityX)
            xHits.append(value)
        }
    }
}

print("X Hits: \(xHits)")

let start = SIMD2<Int>(x: startX, y: startY)
let target1 = SIMD2<Int>(x: targetX1, y: targetY1)
let target2 = SIMD2<Int>(x: targetX2, y: targetY2)

var maxProjectile: Projectile? = nil

var hitVelocities: [SIMD2<Int>] = []

for yHit in yHits {
    for xHit in xHits {
        guard xHit.time == yHit.time else { continue }
        
        let velocity = SIMD2<Int>(x: xHit.velocity, y: yHit.velocity)
        var projectile = Projectile(visited: [start], velocity: velocity, targetMin: target1, targetMax: target2)
        
        while projectile.state == .inFlight {
            projectile.step()
        }
        
        if projectile.state == .hit {
            // print()
            // print("Velocity: \(velocity.x), \(velocity.y)")
            // print(projectile)
            
            hitVelocities.append(velocity)
        
            if let max = maxProjectile {
                if projectile.maxHeight > max.maxHeight {
                    maxProjectile = projectile
                }
            } else {
                maxProjectile = projectile
            }
        }
    }
}

if let maxProjectile = maxProjectile {
    print()
    print("Max Height: \(maxProjectile.maxHeight)")
    print(maxProjectile)
}

for velocity in hitVelocities.map({ "\($0.x),\($0.y)" }).uniqued().sorted() {
    print(velocity)
}

let uniqueHitVelocities = Array(hitVelocities.uniqued())
print("Unique Velocities: \(uniqueHitVelocities.count)")
