//
//  main.swift
//  Day 17
//
//  Created by Stephen H. Gerstacker on 2021-12-17.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

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

        let result = (0 ..< height).map { y -> String in
            (0 ..< width).map { x -> String in
                let point = SIMD2<Int>(x: minX + x, y: maxY - y)

                if point == visited.first! {
                    return "S"
                } else if visited.contains(point) {
                    return "#"
                } else if isHit(point: point) {
                    return "T"
                } else {
                    return "."
                }
            }.joined()
        }.joined(separator: "\n")

        return result
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

        if isBetween(p0: point.x, p1: startPoint.x, p2: targetMin.x) && isBetween(p0: point.x, p1: startPoint.x, p2: targetMax.x) {
            return false
        }

        if isBetween(p0: point.y, p1: startPoint.y, p2: targetMin.y) && isBetween(p0: point.y, p1: startPoint.y, p2: targetMax.y) {
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
