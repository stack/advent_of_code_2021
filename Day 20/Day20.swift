//
//  main.swift
//  Day 20
//
//  Created by Stephen H. Gerstacker on 2021-12-20.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

struct Algorithm {
    let data: [Int]
    let sillyMode: Bool
    
    init(stringValue: String) {
        data = stringValue.map { $0 == "#" ? 1 : 0 }
        
        if data.first! == 1 && data.last! == 0 {
            sillyMode = true
        } else {
            sillyMode = false
        }
    }
    
    func apply(to source: Image) -> Image {
        let nextImage = Image(width: source.width + 2, height: source.height + 2, step: source.step == 0 ? 1 : 0)
        
        for y in 0 ..< nextImage.height {
            for x in 0 ..< nextImage.width {
                let index = source.pixelValue(x: x - 1, y: y - 1, isSilly: sillyMode)
                let value = data[index]
                
                nextImage[x,y] = value
            }
        }
        
        return nextImage
    }
    
    func applyThreaded(to source: Image) async -> Image {
        let nextImage = Image(width: source.width + 2, height: source.height + 2, step: source.step == 0 ? 1 : 0)
        
        await withTaskGroup(of: Void.self, body: { taskGroup in
            for y in 0 ..< nextImage.height {
                
                taskGroup.addTask {
                    for x in 0 ..< nextImage.width {
                        let index = source.pixelValue(x: x - 1, y: y - 1, isSilly: sillyMode)
                        let value = data[index]
                        nextImage[x,y] = value
                    }
                }
            }
        })
        
        return nextImage
    }
}

class Image: CustomStringConvertible {
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
    
    func pixelValue(x: Int, y: Int, isSilly: Bool) -> Int {
        var result = 0
        
        for yOffset in (-1...1) { // y-offset
            for xOffset in (-1...1) { // x-offset
                let localX = x + xOffset
                let localY = y + yOffset
                
                let value: Int
                
                if localX < 0 || localY < 0 {
                    value = isSilly ? step : 0
                } else if localX >= width || localY >= width {
                    value = isSilly ? step : 0
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

@main
struct Day20 {
    
    static func main() async {
        let data = AdventData.InputData
        let runParts = false
        
        var lines = data.components(separatedBy: .newlines)
        let algorithmString = lines.removeFirst()
        let algorithm = Algorithm(stringValue: algorithmString)

        lines.removeFirst()

        let width = lines[0].count
        let height = lines.count
        let initialImage = Image(width: width, height: height, step: 0)

        for (y, line) in lines.enumerated() {
            for (x, value) in line.enumerated() {
                initialImage[x,y] = value == "#" ? 1 : 0
            }
        }

        var current = initialImage
        
        // MARK: - Part 1

        if runParts {
            let step1 = algorithm.apply(to: initialImage)
            print()
            print(step1)

            let step2 = algorithm.apply(to: step1)
            print()
            print(step2)

            print("Part 1:")
            print("Lit Pixels: \(step2.litPixels)")
        }
        
        // MARK: - Part 2

        if runParts {
            current = initialImage

            for _ in 0 ..< 50 {
                current = algorithm.apply(to: current)
            }

            print()
            print("Part 2:")
            print("Lit Pixels: \(current.litPixels)")

            print(current)
        }
        
        // MARK: - Timing Tests

        let expectedValue = 14052
        current = initialImage

        print("Naïve test started")

        let (naiveTiming, naiveLit) = benchmark { () -> Int in
            for _ in 0 ..< 50 {
                current = algorithm.apply(to: current)
            }
            
            return current.litPixels
        }

        assert(current.litPixels == naiveLit)

        print("Naïve time: \(naiveTiming)")

        current = initialImage

        print()
        print("Threaded test started")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0 ..< 50 {
            current = await algorithm.applyThreaded(to: current)
        }
        
        let threadedLit = current.litPixels
        
        let endTime = CFAbsoluteTimeGetCurrent()

        assert(threadedLit == expectedValue)
        
        let threadedTiming = endTime - startTime

        print("Threaded time: \(threadedTiming)")
    }
}
