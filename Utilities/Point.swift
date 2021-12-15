//
//  Point.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2021-12-15.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public struct Point: Hashable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public var cardinalNeighbors: [Point] {
        var neighbors: [Point] = []

        neighbors.append(Point(x: x - 1, y: y))
        neighbors.append(Point(x: x + 1, y: y))
        neighbors.append(Point(x: x, y: y - 1))
        neighbors.append(Point(x: x, y: y + 1))

        return neighbors
    }
}

extension Point: CustomDebugStringConvertible {
    public var debugDescription: String {
        "(\(x),\(y))"
    }
}

extension Point: CustomStringConvertible {
    public var description: String {
        "(\(x),\(y))"
    }
}
