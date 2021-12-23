//
//  main.swift
//  Day 22
//
//  Created by Stephen H. Gerstacker on 2021-12-22.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import simd

let data = InputData

struct Cuboid {
    let x: ClosedRange<Int>
    let y: ClosedRange<Int>
    let z: ClosedRange<Int>
    let value: Int
    
    func and(_ other: Cuboid) -> Cuboid? {
        guard let xAnd = x.and(other.x) else { return nil }
        guard let yAnd = y.and(other.y) else { return nil }
        guard let zAnd = z.and(other.z) else { return nil }
        
        return Cuboid(x: xAnd, y: yAnd, z: zAnd, value: 0)
    }
    
    var volume: Int {
        (x.upperBound - x.lowerBound + 1) *
        (y.upperBound - y.lowerBound + 1) *
        (z.upperBound - z.lowerBound + 1)
    }
    
    static func from(line: String) -> Cuboid {
        let range = NSMakeRange(0, line.count)
        
        guard let match = regex.firstMatch(in: line, options: [], range: range) else {
            fatalError("Failed to parse line")
        }
        
        let onOffRange = Range(match.range(at: 1), in: line)!
        let value = line[onOffRange] == "on" ? 1 : 0
        
        let xMinRange = Range(match.range(at: 2), in: line)!
        let xMin = Int(line[xMinRange])!
        
        let xMaxRange = Range(match.range(at: 3), in: line)!
        let xMax = Int(line[xMaxRange])!
        
        let yMinRange = Range(match.range(at: 4), in: line)!
        let yMin = Int(line[yMinRange])!
        
        let yMaxRange = Range(match.range(at: 5), in: line)!
        let yMax = Int(line[yMaxRange])!
        
        let zMinRange = Range(match.range(at: 6), in: line)!
        let zMin = Int(line[zMinRange])!
        
        let zMaxRange = Range(match.range(at: 7), in: line)!
        let zMax = Int(line[zMaxRange])!
        
        let xRange = xMin...xMax
        let yRange = yMin...yMax
        let zRange = zMin...zMax
        
        return Cuboid(x: xRange, y: yRange, z: zRange, value: value)
    }
}

extension ClosedRange where Bound == Int {
    
    func and(_ other: ClosedRange<Bound>) -> ClosedRange<Bound>? {
        let l1 = lowerBound
        let r1 = upperBound
        let l2 = other.lowerBound
        let r2 = other.upperBound
        
        let lhs = Swift.max(l1, l2)
        let rhs = Swift.min(r1, r2)
        
        guard lhs <= rhs else { return nil }
        
        return lhs ... rhs
    }
}

struct Cube: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

struct Reactor {
    
    let minimum: Int
    let maximum: Int
    
    var data: [Cube:Bool] = [:]
    
    init(minimum: Int, maximum: Int) {
        self.minimum = minimum
        self.maximum = maximum
    }
    
    mutating func set(line: String) {
        let range = NSMakeRange(0, line.count)
        
        guard let match = regex.firstMatch(in: line, options: [], range: range) else {
            fatalError("Failed to parse line")
        }
        
        print("Running \(line)")
        
        let onOffRange = Range(match.range(at: 1), in: line)!
        let value = line[onOffRange] == "on" ? true : false
        
        let xMinRange = Range(match.range(at: 2), in: line)!
        let xMin = Int(line[xMinRange])!
        
        let xMaxRange = Range(match.range(at: 3), in: line)!
        let xMax = Int(line[xMaxRange])!
        
        let yMinRange = Range(match.range(at: 4), in: line)!
        let yMin = Int(line[yMinRange])!
        
        let yMaxRange = Range(match.range(at: 5), in: line)!
        let yMax = Int(line[yMaxRange])!
        
        let zMinRange = Range(match.range(at: 6), in: line)!
        let zMin = Int(line[zMinRange])!
        
        let zMaxRange = Range(match.range(at: 7), in: line)!
        let zMax = Int(line[zMaxRange])!
        
        set(value: value, xs: (xMin...xMax), ys: (yMin...yMax), zs: (zMin...zMax))
    }
    
    mutating func set(value: Bool, xs: ClosedRange<Int>, ys: ClosedRange<Int>, zs: ClosedRange<Int>) {
        let xsMin = max(xs.lowerBound, minimum)
        let xsMax = min(xs.upperBound, maximum)
        
        guard xsMin <= xsMax else { return }
        
        let ysMin = max(ys.lowerBound, minimum)
        let ysMax = min(ys.upperBound, maximum)
        
        guard ysMin <= ysMax else { return }
        
        let zsMin = max(zs.lowerBound, minimum)
        let zsMax = min(zs.upperBound, maximum)
        
        guard zsMin <= zsMax else { return }
        
        let clampedXs = (xsMin...xsMax)
        let clampedYs = (ysMin...ysMax)
        let clampedZs = (zsMin...zsMax)
        
        // print("Turning " + (value ? "on" : "off"))
        
        for x in clampedXs {
            for y in clampedYs {
                for z in clampedZs {
                    let key = Cube(x: x, y: y, z: z)
                        if value {
                            data[key] = value
                        } else {
                            data.removeValue(forKey: key)
                        }
                    
                    // print("- \(x),\(y),\(z)")
                }
            }
        }
        
        // print("On: \(totalOn)")
    }
    
    var totalOn: Int {
        data.values.reduce(0) { $0 + ($1 ? 1 : 0 ) }
    }
}

let regex = try! NSRegularExpression(pattern: "(\\S+) x=(-?\\d+)..(-?\\d+),y=(-?\\d+)..(-?\\d+),z=(-?\\d+)..(-?\\d+)")

// MARK: - Part 1

var part1Reactor = Reactor(minimum: -50, maximum: 50)

for line in data.components(separatedBy: .newlines) {
    part1Reactor.set(line: line)
}

print("Part 1:")
print("Ons: \(part1Reactor.totalOn)")

// MARK: - Part 2

var positive: [Cuboid] = []
var negative: [Cuboid] = []

for line in data.components(separatedBy: .newlines) {
    let cube = Cuboid.from(line: line)
    
    let np = negative.compactMap { $0.and(cube) }
    let nn = positive.compactMap { $0.and(cube) }
    
    positive.append(contentsOf: np)
    negative.append(contentsOf: nn)
    
    if cube.value == 1 {
        positive.append(cube)
    }
}

let volumePositive = positive.reduce(0) { $0 + $1.volume }
let volumeNegative = negative.reduce(0) { $0 + $1.volume }

print()
print("Part 2:")
print("On: \(volumePositive - volumeNegative)")
