//
//  main.swift
//  Day 12
//
//  Created by Stephen H. Gerstacker on 2021-12-12.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

class Cave: Equatable, Hashable {
    
    let name: String
    let isSmall: Bool
    var neighbors: [Cave]
    
    init(name: String) {
        self.name = name
        isSmall = name.uppercased() != name
        neighbors = []
    }
    
    static func == (lhs: Cave, rhs: Cave) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

class CaveSystem {
    
    var caves: [String:Cave] = [:]
    
    func add(lhs: String, rhs: String) {
        add(name: lhs)
        add(name: rhs)
        link(lhs: lhs, rhs: rhs)
    }
    
    private func add(name: String) {
        guard caves[name] == nil else { return }
        
        let cave = Cave(name: name)
        caves[name] = cave
    }
    
    private func link(lhs: String, rhs: String) {
        let leftCave = caves[lhs]!
        let rightCave = caves[rhs]!
        
        leftCave.neighbors.append(rightCave)
        rightCave.neighbors.append(leftCave)
    }
    
    func findAllPaths(withSpecials: Bool = false) -> [[Cave]] {
        let start = caves["start"]!
        let end = caves["end"]!
        
        if withSpecials {
            let smalls = caves.values.filter {
                if $0.name == "start" {
                    return false
                } else if $0.name == "end" {
                    return false
                } else {
                    return $0.isSmall
                }
            }
            
            var paths: [[Cave]] = []
            
            for small in smalls {
                let currentPaths = findPaths(start: start, end: end, currentPath: [start], existingPaths: [], special: small)
                
                for path in currentPaths {
                    if !paths.contains(path) {
                        paths.append(path)
                    }
                }
            }
            
            return paths
        } else {
            return findPaths(start: start, end: end, currentPath: [start], existingPaths: [])
        }
    }
    
    private func findPaths(start: Cave, end: Cave, currentPath: [Cave], existingPaths: [[Cave]], special: Cave? = nil) -> [[Cave]] {
        var nextExistingPaths = existingPaths
        
        let currentCave = currentPath.last!
        let neighbors = currentCave.neighbors
        
        for neighbor in neighbors {
            if let special = special {
                if neighbor.isSmall {
                    if neighbor == special {
                        let count = currentPath.filter { $0 == neighbor }.count
                        if count >= 2 { continue }
                    } else {
                        if currentPath.contains(neighbor) { continue }
                    }
                }
            } else {
                if neighbor.isSmall && currentPath.contains(neighbor) {
                    continue
                }
            }
            
            var nextPath = currentPath
            nextPath.append(neighbor)
            
            if neighbor == end {
                nextExistingPaths.append(nextPath)
            } else {
                nextExistingPaths = findPaths(start: start, end: end, currentPath: nextPath, existingPaths: nextExistingPaths, special: special)
            }
        }
        
        return nextExistingPaths
    }
}

class CaveSolver {
    
    var caves: [String:Cave] = [:]
    
    func add(lhs: String, rhs: String) {
        add(name: lhs)
        add(name: rhs)
        link(lhs: lhs, rhs: rhs)
    }
    
    private func add(name: String) {
        guard caves[name] == nil else { return }
        
        let cave = Cave(name: name)
        caves[name] = cave
    }
    
    private func link(lhs: String, rhs: String) {
        let leftCave = caves[lhs]!
        let rightCave = caves[rhs]!
        
        leftCave.neighbors.append(rightCave)
        rightCave.neighbors.append(leftCave)
    }
    
    func findAllPaths() -> [[Cave]] {
        let start = caves["start"]!
        let end = caves["end"]!
        let smalls = caves.values.filter {
            if $0.name == "start" {
                return false
            } else if $0.name == "end" {
                return false
            } else {
                return $0.isSmall
            }
        }
        
        var allPaths: [[Cave]] = []
        
        for small in smalls {
            var visits: [Cave:Int] = [start: 1, end: 0]
            
            for value in smalls {
                visits[value] = 0
            }
            
            let paths = findPaths(start: start, end: end, special: small, currentPath: [start], visits: visits, existingPaths: [])
            
            for path in paths {
                if !allPaths.contains(path) {
                    allPaths.append(path)
                }
            }
        }
        
        return allPaths
    }
    
    private func findPaths(start: Cave, end: Cave, special: Cave, currentPath: [Cave], visits: [Cave:Int], existingPaths: [[Cave]]) -> [[Cave]] {
        var nextExistingPaths = existingPaths
        
        let currentCave = currentPath.last!
        let neighbors = currentCave.neighbors
        
        for neighbor in neighbors {
            if neighbor.isSmall {
                let count = visits[neighbor]!
                
                if neighbor == special {
                    if count >= 2 { continue }
                } else {
                    if count > 0 { continue }
                }
            }
            
            var nextPath = currentPath
            nextPath.append(neighbor)
            
            var nextVisits = visits
            
            if neighbor.isSmall {
                nextVisits[neighbor]! += 1
            }
            
            if neighbor == end {
                nextExistingPaths.append(nextPath)
            } else {
                nextExistingPaths = findPaths(start: start, end: end, special: special, currentPath: nextPath, visits: nextVisits, existingPaths: nextExistingPaths)
            }
        }
        
        return nextExistingPaths
    }
}

let caveSystem = CaveSystem()

for line in data.components(separatedBy: .newlines) {
    let parts = line.split(separator: "-").map { String($0) }
    precondition(parts.count == 2)
    
    caveSystem.add(lhs: parts[0], rhs: parts[1])
}

let paths = caveSystem.findAllPaths()

for path in paths {
    let output = path.map { $0.name }.joined(separator: ",")
    print(output)
}

print()
print("Total Paths: \(paths.count)")
print()

let solver = CaveSolver()

for line in data.components(separatedBy: .newlines) {
    let parts = line.split(separator: "-").map { String($0) }
    precondition(parts.count == 2)
    
    solver.add(lhs: parts[0], rhs: parts[1])
}

let allPaths = solver.findAllPaths()
let allPathsStrings = allPaths.map { $0.map { $0.name }.joined(separator: ",") }

for path in allPathsStrings.sorted() {
    print(path)
}

print()
print("All Total Paths: \(allPaths.count)")
