//
//  main.swift
//  Day 23
//
//  Created by Stephen H. Gerstacker on 2021-12-23.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Space {
    case wall
    case home
    case hallway
    case empty
}

enum Amphipod: CustomStringConvertible {
    case amber
    case bronze
    case copper
    case desert
    
    var description: String {
        switch self {
        case .amber:
            return "A"
        case .bronze:
            return "B"
        case .copper:
            return "C"
        case .desert:
            return "D"
        }
    }
    
    var movementCost: Int {
        switch self {
        case .amber:
            return 1
        case .bronze:
            return 10
        case .copper:
            return 100
        case .desert:
            return 1000
        }
    }
}

struct Movement {
    let start: Point
    let end: Point
    let cost: Int
}

struct Board: CustomStringConvertible, Hashable {
    
    let board: [[Space]]
    let amphipods: [Point:Amphipod]
    
    let pointToAmphipodHome: [Point:Amphipod]
    let amphipodToHomePoints: [Amphipod:[Point]]
    
    let costSoFar: Int

    init(board: [[Space]], amphipods: [Point:Amphipod], pointToAmphipodHome: [Point:Amphipod], amphipodToHomePoints: [Amphipod:[Point]], costSoFar: Int) {
        self.board = board
        self.amphipods = amphipods
        self.pointToAmphipodHome = pointToAmphipodHome
        self.amphipodToHomePoints = amphipodToHomePoints
        self.costSoFar = costSoFar
    }
    
    static func ==(lhs: Board, rhs: Board) -> Bool {
        return lhs.board == rhs.board && lhs.amphipods == rhs.amphipods
    }
    
    init(string: String) {
        let rows = string.components(separatedBy: .newlines)
        
        var board: [[Space]] = []
        var amphipods: [Point:Amphipod] = [:]
        
        for (y, row) in rows.enumerated() {
            var boardRow: [Space] = []
            
            for (x, value) in row.enumerated() {
                let point = Point(x: x, y: y)
                
                switch value {
                case "#":
                    boardRow.append(.wall)
                case ".":
                    boardRow.append(.hallway)
                case " ":
                    boardRow.append(.empty)
                case "A":
                    boardRow.append(.home)
                    amphipods[point] = .amber
                case "B":
                    boardRow.append(.home)
                    amphipods[point] = .bronze
                case "C":
                    boardRow.append(.home)
                    amphipods[point] = .copper
                case "D":
                    boardRow.append(.home)
                    amphipods[point] = .desert
                default:
                    fatalError("Unhandled space: \(value)")
                }
            }
            
            board.append(boardRow)
        }
        
        self.board = board
        self.amphipods = amphipods
        
        if amphipods.count == 8 {
            pointToAmphipodHome = [
                Point(x: 3, y: 2): .amber,
                Point(x: 3, y: 3): .amber,
                Point(x: 5, y: 2): .bronze,
                Point(x: 5, y: 3): .bronze,
                Point(x: 7, y: 2): .copper,
                Point(x: 7, y: 3): .copper,
                Point(x: 9, y: 2): .desert,
                Point(x: 9, y: 3): .desert,
            ]
        } else {
            pointToAmphipodHome = [
                Point(x: 3, y: 2): .amber,
                Point(x: 3, y: 3): .amber,
                Point(x: 3, y: 4): .amber,
                Point(x: 3, y: 5): .amber,
                Point(x: 5, y: 2): .bronze,
                Point(x: 5, y: 3): .bronze,
                Point(x: 5, y: 4): .bronze,
                Point(x: 5, y: 5): .bronze,
                Point(x: 7, y: 2): .copper,
                Point(x: 7, y: 3): .copper,
                Point(x: 7, y: 4): .copper,
                Point(x: 7, y: 5): .copper,
                Point(x: 9, y: 2): .desert,
                Point(x: 9, y: 3): .desert,
                Point(x: 9, y: 4): .desert,
                Point(x: 9, y: 5): .desert,
            ]
        }
        
        if amphipods.count == 8 {
            amphipodToHomePoints = [
                .amber: [Point(x: 3, y: 2), Point(x: 3, y: 3)],
                .bronze: [Point(x: 5, y: 2), Point(x: 5, y: 3)],
                .copper: [Point(x: 7, y: 2), Point(x: 7, y: 3)],
                .desert: [Point(x: 9, y: 2), Point(x: 9, y: 3)],
            ]
        } else {
            amphipodToHomePoints = [
                .amber: [Point(x: 3, y: 2), Point(x: 3, y: 3), Point(x: 3, y: 4), Point(x: 3, y: 5)],
                .bronze: [Point(x: 5, y: 2), Point(x: 5, y: 3), Point(x: 5, y: 4), Point(x: 5, y: 5)],
                .copper: [Point(x: 7, y: 2), Point(x: 7, y: 3), Point(x: 7, y: 4), Point(x: 7, y: 5)],
                .desert: [Point(x: 9, y: 2), Point(x: 9, y: 3), Point(x: 9, y: 4), Point(x: 9, y: 5)],
            ]
        }
        
        costSoFar = 0
    }
    
    var isSolved: Bool {
        for (_, amphipod) in amphipods {
            if !isHomeComplete(amphipod: amphipod) { return false }
        }
        
        return true
    }
    
    var description: String {
        var boardStrings: [[String]] = board.map { row -> [String] in
            row.map {
                switch $0 {
                case .hallway:
                    return "."
                case .home:
                    return "."
                case .wall:
                    return "#"
                case .empty:
                    return " "
                }
            }
        }
        
        for (amphipodPoint, amphipod) in amphipods {
            boardStrings[amphipodPoint.y][amphipodPoint.x] = amphipod.description
        }
        
        return boardStrings.map { $0.joined(separator: "") }.joined(separator: "\n")
    }
    
    func applying(movement: Movement) -> Board {
        var nextAmphipods = amphipods
        
        let value = nextAmphipods.removeValue(forKey: movement.start)
        nextAmphipods[movement.end] = value
        
        let nextCost = costSoFar + movement.cost
        
        return Board(board: board, amphipods: nextAmphipods, pointToAmphipodHome: pointToAmphipodHome, amphipodToHomePoints: amphipodToHomePoints, costSoFar: nextCost)
    }
    
    // MARK: - Newer Movement
    
    private func findNextHallwayToHomeMovements(amphipod: Amphipod, at point: Point) -> Movement? {
        // Hallways can only move in to their homes, and only if they are empty or have like occupants
        let homeTargets = amphipodToHomePoints[amphipod]!
        
        var bestTarget: Point? = nil
        
        for homeTarget in homeTargets {
            if let value = amphipods[homeTarget] {
                if value != amphipod {
                    bestTarget = nil
                }
                
                break
            } else {
                bestTarget = homeTarget
            }
        }
        
        // If there's no target, return nothing
        guard let target = bestTarget else { return nil }
        
        // Can the path work?
        let xOffset = target.x - point.x
        let xStep = xOffset / abs(xOffset)
        var steps = 0
        
        var current = Point(x: point.x, y: point.y)
        
        while current.x != target.x {
            current = Point(x: current.x + xStep, y: current.y)
            steps += 1
            
            guard amphipods[current] == nil else { return nil }
        }
        
        while current.y != target.y {
            current = Point(x: current.x, y: current.y + 1)
            steps += 1
            
            guard amphipods[current] == nil else { return nil }
        }
        
        let cost = steps * amphipod.movementCost
        let movement = Movement(start: point, end: target, cost: cost)
        
        return movement
    }
            
    private func findNextHomeMovements(amphipod: Amphipod, at point: Point) -> [Movement] {
        var result: [Movement] = []
        
        var current = point
        var steps = 0
        
        // Attempt to go up to the hallway
        while board[current.y][current.x] != .hallway {
            current = Point(x: current.x, y: current.y - 1)
            steps += 1
            
            guard amphipods[current] == nil else { return [] }
        }
        
        // Attempt to go left
        var leftCurrent = current
        var leftSteps = steps
        
        while true {
            leftCurrent = Point(x: leftCurrent.x - 1, y: leftCurrent.y)
            leftSteps += 1
            
            guard board[leftCurrent.y][leftCurrent.x] == .hallway else { break }
            guard amphipods[leftCurrent] == nil else { break }
            
            let hallwayPoint = Point(x: leftCurrent.x, y: leftCurrent.y + 1)
            
            guard pointToAmphipodHome[hallwayPoint] == nil else { continue }
            
            let cost = leftSteps * amphipod.movementCost
            let movement = Movement(start: point, end: leftCurrent, cost: cost)
            
            result.append(movement)
        }
        
        // Attempt to go right
        var rightCurrent = current
        var rightSteps = steps
        
        while true {
            rightCurrent = Point(x: rightCurrent.x + 1, y: rightCurrent.y)
            rightSteps += 1
            
            guard board[rightCurrent.y][rightCurrent.x] == .hallway else { break }
            guard amphipods[rightCurrent] == nil else { break }
            
            let hallwayPoint = Point(x: rightCurrent.x, y: rightCurrent.y + 1)
            
            guard pointToAmphipodHome[hallwayPoint] == nil else { continue }
            
            let cost = rightSteps * amphipod.movementCost
            let movement = Movement(start: point, end: rightCurrent, cost: cost)
            
            result.append(movement)
        }
        
        return result
    }
    
    private func findNextHomeToHomeMovement(amphipod: Amphipod, at point: Point) -> Movement? {
        let homeTargets = amphipodToHomePoints[amphipod]!
        
        var bestTarget: Point? = nil
        
        for homeTarget in homeTargets {
            guard point.x != homeTarget.x else {
                return nil
            }
            
            if let value = amphipods[homeTarget] {
                if value != amphipod {
                    bestTarget = nil
                }
                
                break
            } else {
                bestTarget = homeTarget
            }
        }
        
        // If there's no target, return nothing
        guard let target = bestTarget else { return nil }
        
        // Can the path work?
        let xOffset = target.x - point.x
        let xStep = xOffset / abs(xOffset)
        var steps = 0
        
        var current = Point(x: point.x, y: point.y)
        
        while board[current.y][current.x] != .hallway {
            current = Point(x: current.x, y: current.y - 1)
            steps += 1
            
            guard amphipods[current] == nil else { return nil }
        }
        
        while current.x != target.x {
            current = Point(x: current.x + xStep, y: current.y)
            steps += 1
            
            guard amphipods[current] == nil else { return nil }
        }
        
        while current.y != target.y {
            current = Point(x: current.x, y: current.y + 1)
            steps += 1
            
            guard amphipods[current] == nil else { return nil }
        }
        
        let cost = steps * amphipod.movementCost
        let movement = Movement(start: point, end: target, cost: cost)
        
        return movement
    }
    
    func findNextMovements() -> [Movement] {
        var result: [Movement] = []
        
        for (amphipodPoint, amphipod) in amphipods {
            guard !isHomeComplete(amphipod: amphipod) else { continue }
            
            let boardValue = board[amphipodPoint.y][amphipodPoint.x]
            
            if boardValue == .hallway {
                if let movement = findNextHallwayToHomeMovements(amphipod: amphipod, at: amphipodPoint) {
                    result.append(movement)
                }
            } else if boardValue == .home {
                if let movement = findNextHomeToHomeMovement(amphipod: amphipod, at: amphipodPoint) {
                    result.append(movement)
                } else {
                    let movements = findNextHomeMovements(amphipod: amphipod, at: amphipodPoint)
                    result.append(contentsOf: movements)
                }
            } else {
                fatalError("Illegal amphipod position")
            }
        }
        
        return result.sorted { $0.cost < $1.cost }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(board)
        hasher.combine(amphipods)
    }
    
    private func isHomeComplete(amphipod: Amphipod) -> Bool {
        let homePoints = amphipodToHomePoints[amphipod]!
        let values = homePoints.map { amphipods[$0] }
        
        return values.allSatisfy { $0 == amphipod }
    }
}

struct Solver {
    
    let initialBoard: Board
    
    private var frontier: PriorityQueue<Board> = PriorityQueue<Board>()
    private var cameFrom: [Board:Board] = [:]
    private var costSoFar: [Board:Int] = [:]
    private var path: [Board] = []
    
    init(board: Board) {
        initialBoard = board
    }
    
    var finalBoard: Board {
        return path.last!
    }
    
    mutating func solve() {
        frontier.removeAll()
        cameFrom.removeAll()
        costSoFar.removeAll()
        path.removeAll()
        
        frontier.push(initialBoard, priority: 0)
        costSoFar[initialBoard] = 0
        
        var finalBoard: Board? = nil
        
        while !frontier.isEmpty {
            let current = frontier.pop()!
            
            guard !current.isSolved else {
                finalBoard = current
                break
            }
            
            let movements = current.findNextMovements()
            
            for movement in movements {
                let nextBoard = current.applying(movement: movement)
                let currentCost = (costSoFar[nextBoard] ?? .max)
                
                if nextBoard.costSoFar < currentCost {
                    costSoFar[nextBoard] = nextBoard.costSoFar
                    
                    frontier.push(nextBoard, priority: nextBoard.costSoFar)
                    
                    cameFrom[nextBoard] = current
                }
            }
        }
        
        guard let endBoard = finalBoard else {
            fatalError("Failed to find a path")
        }
        
        path = [endBoard]
        
        while path.first != initialBoard {
            let next = cameFrom[path.first!]!
            path.insert(next, at: 0)
        }
    }
    
    func printBoards() {
        for board in path {
            print()
            print(board)
            print("Cost: \(board.costSoFar)")
        }
    }
}

let board = Board(string: ExampleDataFull)
var solver = Solver(board: board)
solver.solve()

print("Part 2:")
print("Energy: \(solver.finalBoard.costSoFar)")
print("")
solver.printBoards()

