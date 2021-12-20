//
//  main.swift
//  Day 19
//
//  Created by Stephen H. Gerstacker on 2021-12-19.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Algorithms
import Foundation

typealias Position = SIMD3<Int>
typealias Match = (lhs: Position, rhs: Position)

extension Position {
    
    func rotated(axis1: Int, axis2: Int) -> Position {
        var nextPosition = self
        
        let temp = nextPosition[axis1]
        nextPosition[axis1] = nextPosition[axis2]
        nextPosition[axis2] = -temp
        
        return nextPosition
    }
}

extension Position: Comparable {
    public static func < (lhs: SIMD3<Scalar>, rhs: SIMD3<Scalar>) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                return lhs.z < rhs.z
            } else {
                return lhs.y < rhs.y
            }
        } else {
            return lhs.x < rhs.x
        }
    }
}

struct Scanner: CustomStringConvertible {
    let id: Int
    let position: Position
    let rotation: Int
    
    let localBeacons: Set<Position>
    
    init(id: Int, position: Position = .zero, rotation: Int = .zero, beacons: Set<Position> = []) {
        self.id = id
        self.position = position
        self.rotation = rotation
        
        self.localBeacons = beacons
    }
    
    var description: String {
        var output = "Scanner \(id)"
        
        for (idx, beacon) in localBeacons.enumerated() {
            output += "\n[\(idx)] \(beacon.x), \(beacon.y), \(beacon.z)"
        }
        
        return output
    }
    
    func moved(position: Position) -> Scanner {
        return Scanner(id: id, position: position, rotation: rotation, beacons: localBeacons)
    }
    
    func placedBeacons() -> Set<Position> {
        let rotate = { (position: Position) -> Position in
            var next1 = position
            
            switch rotation % 6 {
            case 0:
                next1.x = position.x
                next1.y = position.y
                next1.z = position.z
            case 1:
                next1.x = -position.x
                next1.y = position.y
                next1.z = -position.z
            case 2:
                next1.x = position.y
                next1.y = -position.x
                next1.z = position.z
            case 3:
                next1.x = -position.y
                next1.y = position.x
                next1.z = position.z
            case 4:
                next1.x = position.z
                next1.y = position.y
                next1.z = -position.x
            case 5:
                next1.x = -position.z
                next1.y = position.y
                next1.z = position.x
            default:
                fatalError("Unhandled rotation \(rotation)")
            }
            
            var next2 = next1
            
            switch (rotation / 6) % 4 {
            case 0:
                next2.x = next1.x
                next2.y = next1.y
                next2.z = next1.z
            case 1:
                next2.x = next1.x
                next2.y = -next1.z
                next2.z = next1.y
            case 2:
                next2.x = next1.x
                next2.y = -next1.y
                next2.z = -next1.z
            case 3:
                next2.x = next1.x
                next2.y = next1.z
                next2.z = -next1.y
            default:
                fatalError("Unhandled rotation \(rotation)")
            }
            
            return next2
        }
        
        var result: Set<Position> = []
        
        for beacon in localBeacons {
            let rotated = rotate(beacon)
            let newPosition = position &+ rotated
            result.insert(newPosition)
        }
        
        return result
    }
    
    func rotated() -> Scanner {
        return Scanner(id: id, position: position, rotation: rotation + 1, beacons: localBeacons)
    }
    
    func intersect(with other: Scanner, matchLimit: Int) -> Scanner? {
        var otherScanner = other
        let lhsBeacons = placedBeacons()
        
        for lhsBeacon in lhsBeacons {
            for _ in 0 ..< 24 {
                otherScanner = otherScanner.rotated()
                
                let rhsBeacons = otherScanner.placedBeacons()
                
                for rhsBeacon in rhsBeacons {
                    let center = lhsBeacon &- rhsBeacon
                    
                    let movedScanner = otherScanner.moved(position: center)
                    let movedBeacons = movedScanner.placedBeacons()
                    let intersection = lhsBeacons.intersection(movedBeacons)
                    
                    if intersection.count >= matchLimit {
                        return movedScanner
                    }
                }
            }
        }
        
        return nil
    }
}

struct Solver {
    
    let initialScanners: [Scanner]
    var finalScanners: [Scanner] = []
    
    static func from(data: String) -> Solver {
        var scanners: [Scanner] = []
        
        var currentId = 0
        var beacons: Set<Position> = []
        
        for line in data.components(separatedBy: .newlines) {
            if line.starts(with: "---") {
                if !beacons.isEmpty {
                    let scanner = Scanner(id: currentId, position: .zero, beacons: beacons)
                    scanners.append(scanner)
                    
                    beacons.removeAll()
                }
                
                let parts = line.split(separator: " ")
                assert(parts.count == 4)
                
                currentId = Int(parts[2])!
                
                continue
            } else if line == "" {
                continue
            }
            
            let parts = line.split(separator: ",")
            
            let x = Int(parts[0])!
            let y = Int(parts[1])!
            let z = (parts.count == 3) ? Int(parts[2])! : 0
            
            let position = Position(x: x, y: y, z: z)
            beacons.insert(position)
        }
        
        if !beacons.isEmpty {
            let scanner = Scanner(id: currentId, position: .zero, beacons: beacons)
            scanners.append(scanner)
            
            beacons.removeAll()
        }
        
        let solver = Solver(initialScanners: scanners)
        return solver
    }
    
    mutating func run(matchLimit: Int) {
        var scanners = initialScanners
        var located: [Scanner] = []
        var toVisit: [Scanner] = []
        
        let origin = scanners.removeFirst()
        located.append(origin)
        toVisit.append(origin)
        
        while !toVisit.isEmpty {
            print("Located: \(located.count), To Visit: \(toVisit.count), Scanners: \(scanners.count)")
            
            let scannerA = toVisit.removeFirst()
            
            var toRemove: [Scanner] = []
            
            for scannerB in scanners {
                if let newScanner = scannerA.intersect(with: scannerB, matchLimit: matchLimit) {
                    located.append(newScanner)
                    toVisit.append(newScanner)
                    
                    toRemove.append(scannerB)
                }
            }
            
            for scanner in toRemove {
                if let idx = scanners.firstIndex(where: { $0.id == scanner.id }) {
                    scanners.remove(at: idx)
                }
            }
        }
        
        finalScanners = located
    }
    
    var finalBeacons: Set<Position> {
        var result: Set<Position> = []
        
        for scanner in finalScanners {
            for beacon in scanner.placedBeacons() {
                result.insert(beacon)
            }
        }
        
        return result
    }
    
    var largestDistance: Int {
        var largest: Int = .min
        
        let positions = finalScanners.map { $0.position }
        
        for lhs in positions {
            for rhs in positions {
                guard lhs != rhs else { continue }
                
                let diff = lhs &- rhs
                let distance = abs(diff.x) + abs(diff.y) + abs(diff.z)
                
                if distance > largest {
                    largest = distance
                }
            }
        }
        
        return largest
    }
}

// MARK: - Tests

let runTests = false

if runTests {
    var test1Solver = Solver.from(data: ExampleData1)
    test1Solver.run(matchLimit: 3)

    print("Test 1: \(test1Solver.finalScanners)")
    print("        \(test1Solver.finalBeacons)")

    var test2Solver = Solver.from(data: ExampleData2)
    test2Solver.run(matchLimit: 6)

    print("Test 1: \(test2Solver.finalScanners)")
    print("        \(test2Solver.finalBeacons)")
}

// MARK: - Part 1

let data = InputData

var solver = Solver.from(data: data)
solver.run(matchLimit: 12)

let beacons = solver.finalBeacons

print()
print("Part 1:")
print("Beacons: \(beacons.count)")

// MARK: - Part 2

print()
print("Part 2:")
print("Distance: \(solver.largestDistance)")
