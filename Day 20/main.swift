//
//  main.swift
//  Day 20
//
//  Created by Stephen H. Gerstacker on 2021-12-20.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

struct Algorithm {
    let data: [Int]
    
    init(stringValue: String) {
        data = stringValue.map { $0 == "#" ? 1 : 0 }
    }
    
    func apply(to source: Image) -> Image {
        var nextImage = Image(width: source.width + 2, height: source.height + 2, step: source.step == 0 ? 1 : 0)
        
        for y in 0 ..< nextImage.height {
            for x in 0 ..< nextImage.width {
                let index = source.pixelValue(x: x - 1, y: y - 1)
                let value = data[index]
                
                nextImage[x,y] = value
            }
        }
        
        return nextImage
    }
}

struct Image: CustomStringConvertible {
    var data: [[Int]]
    
    let width: Int
    let height: Int
    let step: Int
    
    init(width: Int, height: Int, step: Int) {
        self.width = width
        self.height = height
        self.step = step
        
        self.data = [[Int]](repeating: [Int](repeating: 0, count: width), count: height)
    }
    
    subscript(x: Int, y: Int) -> Int {
        get {
            return data[y][x]
        }
        
        set {
            data[y][x] = newValue
        }
    }
    
    func pixelValue(x: Int, y: Int) -> Int {
        var result = 0
        
        for yOffset in (-1...1) { // y-offset
            for xOffset in (-1...1) { // x-offset
                let localX = x + xOffset
                let localY = y + yOffset
                
                let value: Int
                
                if localX < 0 || localY < 0 {
                    value = step
                } else if localX >= width || localY >= width {
                    value = step
                } else {
                    value = data[localY][localX]
                }
                
                result = result << 1
                result += value
            }
        }
        
        return result
    }
    
    var description: String {
        return data.map {
            $0.map { $0 == 1 ? "#" : "." }.joined()
        }.joined(separator: "\n")
    }
    
    var litPixels: Int {
        return data.reduce(0) {
            $0 + $1.reduce(0, +)
        }
    }
}

var lines = data.components(separatedBy: .newlines)
let algorithmString = lines.removeFirst()
let algorithm = Algorithm(stringValue: algorithmString)

lines.removeFirst()

let width = lines[0].count
let height = lines.count
var initialImage = Image(width: width, height: height, step: 0)

for (y, line) in lines.enumerated() {
    for (x, value) in line.enumerated() {
        initialImage[x,y] = value == "#" ? 1 : 0
    }
}

print(initialImage)

// MARK: - Part 1

let step1 = algorithm.apply(to: initialImage)
print()
print(step1)

let step2 = algorithm.apply(to: step1)
print()
print(step2)

print("Lit Pixels: \(step2.litPixels)")

// MARK: - Part 2

var current = initialImage

for _ in 0 ..< 50 {
    current = algorithm.apply(to: current)
}

print()
print("Lit Pixels: \(current.litPixels)")
