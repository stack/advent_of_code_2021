//
//  main.swift
//  Day 25
//
//  Created by Stephen H. Gerstacker on 2021-12-26.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let data = ExampleData1

struct SeaFloor: CustomStringConvertible {
    let width: Int
    let height: Int
    
    var eastwardCucumbers: Set<Point>
    var southwardCucumbers: Set<Point>
    
    static func from(string: String) -> SeaFloor {
        var width = 0
        var height = 0
        
        var eastward: Set<Point> = []
        var southward: Set<Point> = []
        
        for (y, row) in string.components(separatedBy: .newlines).enumerated() {
            height = y + 1
            
            for (x, value) in row.enumerated() {
                if x + 1 > width { width = x + 1 }
                
                let point = Point(x: x, y: y)
                
                if value == ">" {
                    eastward.insert(point)
                } else if value == "v" {
                    southward.insert(point)
                }
            }
        }
        
        return SeaFloor(width: width, height: height, eastwardCucumbers: eastward, southwardCucumbers: southward)
    }
    
    var description: String {
        var data = [[String]](repeating: [String](repeating: ".", count: width), count: height)
        
        for point in eastwardCucumbers {
            data[point.y][point.x] = ">"
        }
        
        for point in southwardCucumbers {
            data[point.y][point.x] = "v"
        }
        
        return data.map { $0.joined() }.joined(separator: "\n")
    }
    
    @discardableResult mutating func step() -> Int {
        var moved = 0
        
        var nextEastward: Set<Point> = []
        
        for point in eastwardCucumbers {
            var nextX = point.x + 1
            
            if nextX >= width {
                nextX = 0
            }

            let neighborPoint = Point(x: nextX, y: point.y)
            
            if eastwardCucumbers.contains(neighborPoint) || southwardCucumbers.contains(neighborPoint) {
                nextEastward.insert(point)
            } else {
                nextEastward.insert(neighborPoint)
                moved += 1
            }
        }
        
        eastwardCucumbers = nextEastward
        
        var nextSouthward: Set<Point> = []
        
        for point in southwardCucumbers {
            var nextY = point.y + 1
            
            if nextY >= height {
                nextY = 0
            }
            
            let neighborPoint = Point(x: point.x, y: nextY)
            
            if eastwardCucumbers.contains(neighborPoint) || southwardCucumbers.contains(neighborPoint) {
                nextSouthward.insert(point)
            } else {
                nextSouthward.insert(neighborPoint)
                moved += 1
            }
        }
        
        southwardCucumbers = nextSouthward
        
        return moved
    }
}

@main
struct Day24 {
    
    static func main() async {
        part1()
    }
    
    static func example1() {
        var seaFloor = SeaFloor.from(string: ExampleData1)
        
        print("Example 1:")
        print("Step 0: \(seaFloor)")
        
        seaFloor.step()
        print("Step 1: \(seaFloor)")
        
        seaFloor.step()
        print("Step 2: \(seaFloor)")
    }
    
    static func example2() {
        var seaFloor = SeaFloor.from(string: ExampleData2)
        
        print("Example 2:")
        print("Step 0:\n\(seaFloor)")
        
        seaFloor.step()
        
        print()
        print("Step 1: \n\(seaFloor)")
    }
    
    static func example3() {
        var seaFloor = SeaFloor.from(string: ExampleData3)
        
        print("Example 3:")
        print("Initial state:")
        print(seaFloor)
        
        for idx in 0 ..< 4 {
            seaFloor.step()
            
            print()
            print("After \(idx + 1) steps:")
            print(seaFloor)
        }
    }
    
    static func example4() {
        var seaFloor = SeaFloor.from(string: ExampleData4)
        
        print("Example 4:")
        print("Initial state:")
        print(seaFloor)
        
        var moved = 0
        
        for idx in 0 ..< 58 {
            moved = seaFloor.step()
            
            if idx != 57 {
                assert(moved != 0)
            } else {
                assert(moved == 0)
            }
            
            print()
            print("After \(idx + 1) steps:")
            print(seaFloor)
            print("Moved: \(moved)")
        }
    }
    
    static func part1() {
        var seaFloor = SeaFloor.from(string: InputData)
        
        var step = 0
        
        while true {
            let moved = seaFloor.step()
            step += 1
            
            guard moved != 0 else { break }
        }
                    
        print("Part 1:")
        print("Step: \(step)")
    }
}

