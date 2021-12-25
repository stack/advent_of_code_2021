//
//  main.swift
//  Day 24
//
//  Created by Stephen H. Gerstacker on 2021-12-24.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Algorithms
import Foundation
import SwiftUI

struct ALU {
    
    let aList = [1, 1, 1, 1, 1, 26, 26, 1, 26, 1, 26, 26, 26, 26]
    let bList = [14, 13, 12, 14, 13, -7, -13, 10, -7, 11, -9, -2, -9, -14]
    let cList = [12, 6, 4, 5, 0, 4, 15, 14, 6, 14, 8, 5, 14, 4]
    
    var w: Int = 0
    var x: Int = 0
    var y: Int = 0
    var z: Int = 0
    
    var input: [Int] = []
    var equations: [(index1: Int, index2: Int, amount: Int)] = []
    
    func solve(input: [Int]) -> String {
        var output = input
        var stack: [(index: Int, amount: Int)] = []
        
        for index in 0 ..< 14 {
            let div = aList[index]
            let check = bList[index]
            let add = cList[index]
            
            if div == 1 {
                stack.append((index: index, amount: add))
            } else if div == 26 {
                let (jIndex, jAmount) = stack.removeLast()
                
                output[index] = output[jIndex] + jAmount + check
                
                if output[index] > 9 {
                    output[jIndex] -= output[index] - 9
                    output[index] = 9
                }
                
                if output[index] < 1 {
                    output[jIndex] += 1 - output[index]
                    output[index] = 1
                }
            } else {
                fatalError("Div was not 1 or 26")
            }
        }
        
        return output.map { String($0) }.joined()
    }
}

@main
struct Day24 {
    
    static func main() async {
        part1()
        part2()
    }
    
    private static func part1() {
        print("Part 1:")
        
        let alu = ALU()
        let highest = alu.solve(input: [Int](repeating: 9, count: 14))
        
        print("Highest: \(highest)")
    }
    
    private static func part2() {
        print("Part 2:")
        
        let alu = ALU()
        let lowest = alu.solve(input: [Int](repeating: 1, count: 14))
        
        print("Lowest: \(lowest)")
    }
}
