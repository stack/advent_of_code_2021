//
//  Day_11_VisualizedApp.swift
//  Day 11 Visualized
//
//  Created by Stephen H. Gerstacker on 2021-12-11.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import SwiftUI
import Utilities

let InputData = """
6617113584
6544218638
5457331488
1135675587
1221353216
1811124378
1387864368
4427637262
6778645486
3682146745
"""

struct Point: CustomStringConvertible, CustomDebugStringConvertible, Hashable {
    let x: Int
    let y: Int
    
    var description: String {
        "(\(x),\(y))"
    }
    
    var debugDescription: String {
        description
    }
}

@main
struct Day_11_VisualizedApp: App {
    var body: some Scene {
        WindowGroup {
            RenderableWorkView(width: 1000, height: 1000, frameTime: 0.25) { animator in
                var current = InputData
                    .components(separatedBy: .newlines)
                    .map { $0.map { Int(String($0))! } }
                var next = current
                
                var step = 0
                
                animator.draw { context in
                    render(context: context, state: current)
                }
                
                while true {
                    var toFlash: [Point] = []
                    
                    for y in 0 ..< current.count {
                        for x in 0 ..< current[0].count {
                            next[y][x] = current[y][x] + 1
                            
                            if next[y][x] > 9 {
                                toFlash.append(Point(x: x, y: y))
                            }
                        }
                    }
                    
                    var hasFlashed: Set<Point> = []
                    
                    while !toFlash.isEmpty {
                        let flashPoint = toFlash.removeFirst()
                        
                        guard !hasFlashed.contains(flashPoint) else { continue }
                        
                        hasFlashed.insert(flashPoint)
                        
                        for yOffset in -1...1 {
                            for xOffset in -1...1 {
                                guard xOffset != 0 || yOffset != 0 else { continue }
                                
                                let testPoint = Point(x: flashPoint.x + xOffset, y: flashPoint.y + yOffset)
                                
                                guard (0..<next[0].count).contains(testPoint.x) else { continue }
                                guard (0..<next.count).contains(testPoint.y) else { continue }
                                
                                next[testPoint.y][testPoint.x] += 1
                                
                                if next[testPoint.y][testPoint.x] > 9 {
                                    toFlash.append(testPoint)
                                }
                            }
                        }
                    }
                    
                    for point in hasFlashed {
                        next[point.y][point.x] = 0
                    }
                    
                    let temp = current
                    current = next
                    next = temp
                    
                    animator.draw { context in
                        render(context: context, state: current)
                    }
                    
                    if hasFlashed.count == (current.count * current[0].count) {
                        break
                    }
                    
                    step += 1
                }
            }
        }
    }
    
    private func render(context: CGContext, state: [[Int]]) {
        let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)
        let backgroundColor = CGColor(red: 58.0 / 255.0, green: 189.0 / 255.0, blue: 187.0 / 255.0, alpha: 1.0)
        
        context.setFillColor(backgroundColor)
        context.fill(backgroundBounds)
        
        let blockWidth = context.width / state[0].count
        let blockHeight = context.height / state.count
        
        let font = NSFont.systemFont(ofSize: CGFloat(blockHeight) * 0.8)
        let squid = NSString(string: "🦑")
        
        for x in 0 ..< state[0].count {
            for y in 0 ..< state.count {
                let value = state[y][x]
                let blockBounds = CGRect(x: x * blockWidth, y: y * blockHeight, width: blockWidth, height: blockHeight)
                
                let blockBackgroundColor: CGColor
                let blockAlpha: CGFloat
                
                if value == 0 {
                    blockBackgroundColor = CGColor(red: 255.0 / 255.0, green: 250.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
                    blockAlpha = 1.0
                } else {
                    blockBackgroundColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    blockAlpha = CGFloat(value) / 15.0
                }
                
                context.setFillColor(blockBackgroundColor)
                context.fill(blockBounds)
                
                context.saveGState()
    
                context.setAlpha(blockAlpha)
                
                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: true)
                squid.draw(in: blockBounds, withAttributes: [.font: font])
                NSGraphicsContext.restoreGraphicsState()
                
                context.restoreGState()
            }
        }
    }
}
