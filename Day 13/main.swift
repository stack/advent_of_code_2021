//
//  main.swift
//  Day 13
//
//  Created by Stephen H. Gerstacker on 2021-12-13.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

enum Fold {
    case horizontal(Int)
    case vertical(Int)
}

struct Paper {

    let width: Int
    let height: Int

    let dots: [[Bool]]

    init(width: Int, height: Int, dots: [[Bool]]) {
        self.width = width
        self.height = height
        self.dots = dots
    }

    init<T: Sequence>(width: Int, height: Int, dotPairs: T) where T.Iterator.Element == (Int, Int) {
        var convertedDots = [[Bool]](repeating: [Bool](repeating: false, count: width), count: height)

        for dot in dotPairs {
            convertedDots[dot.1][dot.0] = true
        }

        self.init(width: width, height: height, dots: convertedDots)
    }

    var totalDots: Int {
        var sum = 0

        for row in dots {
            for value in row {
                sum += value ? 1 : 0
            }
        }

        return sum
    }

    func folded(by fold: Fold) -> Paper {
        switch fold {
        case .horizontal(let line):
            return foldedHorizontally(on: line)
        case .vertical(let line):
            return foldedVertically(on: line)
        }
    }

    /// Fold the paper up along the y-axis
    private func foldedHorizontally(on yAxis: Int) -> Paper {
        // Calculate the new dimensions of the paper
        let topHeight = yAxis
        let bottomHeight = (height - yAxis) - 1

        let nextHeight = max(topHeight, bottomHeight)
        let nextWidth = width

        var nextDots = [[Bool]](repeating: [Bool](repeating: false, count: nextWidth), count: nextHeight)

        // Copy the values from the top
        for srcY in 0 ..< topHeight {
            for srcX in 0 ..< width {
                let destX = srcX
                let destY = srcY

                nextDots[destY][destX] = dots[srcY][srcX]
            }
        }

        // Merge the values from the bottom
        for srcY in (yAxis + 1) ..< height {
            for srcX in 0 ..< width {
                let destX = srcX
                let destY = nextHeight - (srcY - yAxis)

                nextDots[destY][destX] = nextDots[destY][destX] || dots[srcY][srcX]
            }
        }

        let nextPaper = Paper(width: nextWidth, height: nextHeight, dots: nextDots)

        return nextPaper
    }

    /// Fold the paper left along the x-axis
    private func foldedVertically(on xAxis: Int) -> Paper {
        // Calculate the new dimensions of the paper
        let leftWidth = xAxis
        let rightWidth = width - xAxis - 1

        let nextWidth = max(leftWidth, rightWidth)
        let nextHeight = height

        var nextDots = [[Bool]](repeating: [Bool](repeating: false, count: nextWidth), count: nextHeight)

        // Copy the values from the left side
        for srcY in 0 ..< height {
            for srcX in 0 ..< xAxis {
                let destX = srcX
                let destY = srcY

                nextDots[destY][destX] = dots[srcY][srcX]
            }
        }

        // Merge the values from the right
        for srcY in 0 ..< height {
            for srcX in (xAxis + 1) ..< width {
                let destX = nextWidth - (srcX - xAxis)
                let destY = srcY

                nextDots[destY][destX] = nextDots[destY][destX] || dots[srcY][srcX]
            }
        }

        let nextPaper = Paper(width: nextWidth, height: nextHeight, dots: nextDots)

        return nextPaper
    }

    func printPaper(with fold: Fold? = nil) {
        var output = ""

        for (y, line) in dots.enumerated() {
            if !output.isEmpty { output += "\n" }

            output += line.enumerated().map { (x, value) -> String in
                if case .horizontal(let axis) = fold, y == axis {
                    return "-"
                } else if case .vertical(let axis) = fold, x == axis {
                    return "|"
                } else {
                    return value ? "#" : "."
                }
            }.joined()
        }

        print(output)
    }
}

var xs: [Int] = []
var ys: [Int] = []
var folds: [Fold] = []

var inFolds = false

for line in data.components(separatedBy: .newlines) {
    if !inFolds && line.isEmpty {
        inFolds = true
        continue
    }

    if inFolds {
        let parts = line.split(separator: "=")
        precondition(parts.count == 2)

        let axis = parts[0].last!
        let amount = Int(parts[1])!

        switch axis {
        case "x":
            folds.append(.vertical(amount))
        case "y":
            folds.append(.horizontal(amount))
        default:
            fatalError("Unhandled axis: \(axis)")
        }
    } else {
        let parts = line.split(separator: ",")
        precondition(parts.count == 2)

        let x = Int(parts[0])!
        let y = Int(parts[1])!

        xs.append(x)
        ys.append(y)
    }
}

let width = xs.max()!
let height = ys.max()!

var paper = Paper(width: width + 1, height: height + 1, dotPairs: zip(xs, ys))

print("Original Paper:")
print()
paper.printPaper()

for (idx, fold) in folds.enumerated() {
    print()
    print("Fold \(idx + 1):")
    print()

    paper.printPaper(with: fold)

    paper = paper.folded(by: fold)

    print()
    paper.printPaper()
    print("= Total Dots: \(paper.totalDots)")
}
