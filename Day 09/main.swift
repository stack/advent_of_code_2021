//
//  main.swift
//  Day 09
//
//  Created by Stephen H. Gerstacker on 2021-12-09.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

let heightMap = data
    .components(separatedBy: .newlines)
    .map {
        $0.map { Int(String($0))! }
    }

let columns = heightMap[0].count
let rows = heightMap.count

struct Point: CustomStringConvertible, Hashable {
    let x: Int
    let y: Int
    let value: Int

    var description: String {
        "(\(x),\(y)) = \(value)"
    }
}

// MARK: - Part 1

var lowPoints: [Point] = []

for column in 0 ..< columns {
    for row in 0 ..< rows {
        var testValues: [Int] = []

        if row > 0 {
            testValues.append(heightMap[row - 1][column])
        }

        if row < (rows - 1) {
            testValues.append(heightMap[row + 1][column])
        }

        if column > 0 {
            testValues.append(heightMap[row][column - 1])
        }

        if column < (columns - 1) {
            testValues.append(heightMap[row][column + 1])
        }

        let current = heightMap[row][column]

        var lowest = true

        for value in testValues {
            if value <= current {
                lowest = false
                break
            }
        }

        if lowest {
            lowPoints.append(Point(x: column, y: row, value: current))
        }
    }
}

print("Low Points: \(lowPoints)")

let riskLevel = lowPoints.map { $0.value + 1 }.reduce(0, +)
print("Risk Level: \(riskLevel)")

// MARK: - Part 2

class BasinFinder {

    let heightMap: [[Int]]
    let columns: Int
    let rows: Int
    let lowPoint: Point

    var basinPoints: Set<Point> = []

    init(heightMap: [[Int]], columns: Int, rows: Int, lowPoint: Point) {
        self.heightMap = heightMap
        self.lowPoint = lowPoint
        self.columns = columns
        self.rows = rows
    }

    func solve() {
        basinPoints = []

        var toVisit: [Point] = [lowPoint]

        while !toVisit.isEmpty {
            let current = toVisit.removeFirst()

            guard current.value != 9 else { continue }

            basinPoints.insert(current)

            if current.x > 0 {
                let next = Point(x: current.x - 1, y: current.y, value: heightMap[current.y][current.x - 1])

                if !basinPoints.contains(next) {
                    toVisit.append(next)
                }
            }

            if current.x < (columns - 1) {
                let next = Point(x: current.x + 1, y: current.y, value: heightMap[current.y][current.x + 1])

                if !basinPoints.contains(next) {
                    toVisit.append(next)
                }
            }

            if current.y > 0 {
                let next = Point(x: current.x, y: current.y - 1, value: heightMap[current.y - 1][current.x])

                if !basinPoints.contains(next) {
                    toVisit.append(next)
                }
            }

            if current.y < (rows - 1) {
                let next = Point(x: current.x, y: current.y + 1, value: heightMap[current.y + 1][current.x])

                if !basinPoints.contains(next) {
                    toVisit.append(next)
                }
            }
        }
    }
}

var sizes: [Int] = []

for point in lowPoints {
    let finder = BasinFinder(heightMap: heightMap, columns: columns, rows: rows, lowPoint: point)
    finder.solve()

    print("Basin: \(finder.basinPoints)")
    sizes.append(finder.basinPoints.count)
}

var sortedSizes = Array(sizes.sorted().reversed())
var total = sortedSizes[0...2].reduce(1, *)

print("Largest Sizes: \(total)")
