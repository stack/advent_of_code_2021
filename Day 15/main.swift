//
//  main.swift
//  Day 15
//
//  Created by Stephen H. Gerstacker on 2021-12-15.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let data = InputData

class Solver {
    let map: [[Int]]
    let startingPoint: Point
    let endingPoint: Point

    private(set) var path: [Point] = []

    private let width: Int
    private let height: Int

    private var frontier: PriorityQueue<Point> = PriorityQueue<Point>()
    private var cameFrom: [Point:Point] = [:]
    private var costSoFar: [Point:Int] = [:]

    init(map: [[Int]], startingPoint: Point, endingPoint: Point) {
        self.map = map
        self.startingPoint = startingPoint
        self.endingPoint = endingPoint

        width = map[0].count
        height = map.count
    }

    func expanded(by tiles: Int) -> Solver {
        var newMap: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: width * tiles), count: height * tiles)

        for tileY in 0 ..< tiles {
            for tileX in 0 ..< tiles {
                for y in 0 ..< width {
                    for x in 0 ..< height {
                        var value = map[y][x]
                        value += tileX + tileY

                        if value > 9 {
                            value = value % 9
                        }

                        let targetX = (tileX * width) + x
                        let targetY = (tileY * height) + y

                        newMap[targetY][targetX] = value
                    }
                }
            }
        }

        let newSolver = Solver(map: newMap, startingPoint: startingPoint, endingPoint: Point(x: newMap[0].count - 1, y: newMap.count - 1))

        print()
        print("Generated new map:")
        print(newSolver.mapDescription)
        print()

        return newSolver
    }

    var mapDescription: String {
        let rows = map.enumerated().map { (y, row) -> String in
            row.enumerated().map { (x, value) -> String in
                let point = Point(x: x, y: y)

                if point == startingPoint {
                    return "*"
                } else if point == endingPoint {
                    return "X"
                } else if path.contains(point) {
                    return "•"
                } else {
                    return String(map[y][x])
                }
            }.joined()
        }

        return rows.joined(separator: "\n")
    }

    func run() {
        frontier.removeAll()
        cameFrom.removeAll()
        costSoFar.removeAll()
        path.removeAll()

        frontier.push(startingPoint, priority: 0)

        costSoFar[startingPoint] = 0

        while !frontier.isEmpty {
            let current = frontier.pop()!

            guard current != endingPoint else { break }

            let neighborPoints = current.cardinalNeighbors.filter {
                if $0.x < 0 { return false }
                if $0.y < 0 { return false }
                if $0.x >= width { return false }
                if $0.y >= height { return false }

                return true
            }

            for neighborPoint in neighborPoints {
                let newCost = costSoFar[current]! + map[neighborPoint.y][neighborPoint.x]
                let currentCost = (costSoFar[neighborPoint] ?? .max)

                if newCost < currentCost {
                    costSoFar[neighborPoint] = newCost

                    let heuristic = abs(current.x - neighborPoint.x) + abs(current.y - neighborPoint.y)

                    let priority = newCost + heuristic;
                    frontier.push(neighborPoint, priority: priority)

                    cameFrom[neighborPoint] = current
                }
            }
        }

        path = [endingPoint]

        while path.first != startingPoint {
            let next = cameFrom[path.first!]!
            path.insert(next, at: 0)
        }
    }

    var totalRisk: Int {
        path.reduce(0) { sum, point in
            let value: Int

            if point == startingPoint {
                value = 0
            } else {
                value = map[point.y][point.x]
            }

            return sum + value
        }
    }
}

let map = data.components(separatedBy: .newlines).map { line -> [Int] in
    line.map { Int(String($0))! }
}

// MARK: - Part 1

let solver1 = Solver(map: map, startingPoint: Point(x: 0, y: 0), endingPoint: Point(x: map[0].count - 1, y: map.count - 1))
solver1.run()

print("Part 1:")
print("Path: \(solver1.path)")
print("Total Risk: \(solver1.totalRisk)")

// MARK: - Part 2

let solver2 = solver1.expanded(by: 5)
solver2.run()

print()
print("Part 2:")
print("Path: \(solver2.path)")
print("Total Risk: \(solver2.totalRisk)")
