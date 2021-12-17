//
//  Day_17_VisualizedApp.swift
//  Day 17 Visualized
//
//  Created by Stephen H. Gerstacker on 2021-12-17.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Algorithms
import SwiftUI
import Utilities

enum ProjectileState: CustomStringConvertible {
    case inFlight
    case hit
    case miss

    var description: String {
        switch self {
        case .inFlight:
            return "In Flight…"
        case .hit:
            return "Hit!"
        case .miss:
            return "Miss!"
        }
    }
}

struct Projectile {

    var visited: [SIMD2<Int>]
    var velocity: SIMD2<Int>

    var targetMin: SIMD2<Int>
    var targetMax: SIMD2<Int>

    mutating func step() {
        let currentPosition = visited.last!

        let nextPosition = currentPosition &+ velocity
        visited.append(nextPosition)

        var nextVelocity = velocity

        if nextVelocity.x > 0 {
            nextVelocity.x -= 1
        } else if nextVelocity.x < 0 {
            nextVelocity.x += 1
        }
        
        nextVelocity.y -= 1

        velocity = nextVelocity
    }

    var state: ProjectileState {
        let currentPosition = visited.last!

        if isHit(point: currentPosition) {
            return .hit
        } else if isBeyond(point: currentPosition) {
            return .miss
        } else {
            return .inFlight
        }
    }
    
    var minX: Int {
        let targetMinX = min(targetMin.x, targetMax.x)
        let visitedMinX = visited.map { $0.x }.min()!
        
        return min(targetMinX, visitedMinX)
    }
    
    var minY: Int {
        let targetMinY = min(targetMin.y, targetMax.y)
        let visitedMinY = visited.map { $0.y }.min()!
        
        return min(targetMinY, visitedMinY)
    }
    
    var maxX: Int {
        let targetMaxX = max(targetMin.x, targetMax.x)
        let visitedMaxX = visited.map { $0.x }.max()!
        
        return max(targetMaxX, visitedMaxX)
    }
    
    var maxY: Int {
        let targetMaxY = max(targetMin.y, targetMax.y)
        let visitedMaxY = visited.map { $0.y }.max()!
        
        return max(targetMaxY, visitedMaxY)
    }

    private func isBeyond(point: SIMD2<Int>) -> Bool {
        let startPoint = visited.first!

        if !isBetween(p0: targetMin.x, p1: startPoint.x, p2: point.x) && !isBetween(p0: targetMax.x, p1: startPoint.x, p2: point.x) {
            return false
        }

        if !isBetween(p0: targetMin.y, p1: startPoint.y, p2: point.y) && !isBetween(p0: targetMax.y, p1: startPoint.y, p2: point.y) {
            return false
        }

        if isBetween(p0: point.x, p1: startPoint.x, p2: targetMin.x) || isBetween(p0: point.x, p1: startPoint.x, p2: targetMax.x) {
            return false
        }

        if isBetween(p0: point.y, p1: startPoint.y, p2: targetMin.y) || isBetween(p0: point.y, p1: startPoint.y, p2: targetMax.y) {
            return false
        }

        return true
    }

    private func isHit(point: SIMD2<Int>) -> Bool {
        guard isBetween(p0: point.x, p1: targetMin.x, p2: targetMax.x) else {
            return false
        }

        guard isBetween(p0: point.y, p1: targetMin.y, p2: targetMax.y) else {
            return false
        }

        return true
    }

    private func isBetween(p0: Int, p1: Int, p2: Int) -> Bool {
        let minP = min(p1, p2)
        let maxP = max(p1, p2)

        return p0 >= minP && p0 <= maxP
    }
}

@main
struct Day_17_VisualizedApp: App {
    let startX = 0
    let startY = 0
    
    let targetX1 = 179
    let targetX2 = 201
    
    let targetY1 = -63
    let targetY2 = -109
    
    var body: some Scene {
        WindowGroup {
            RenderableWorkView(width: 800, height: 800, frameTime: 0.005) { animator in
                let projectiles = generateProjectiles()
                
                let minX = projectiles.map { $0.minX }.min()!
                let minY = projectiles.map { $0.minY }.min()!
                let maxX = projectiles.map { $0.maxX }.max()!
                let maxY = projectiles.map { $0.maxY }.max()!
                
                let projectileFieldWidth = CGFloat(maxX - minX)
                let projectileFieldHeight = CGFloat(maxY - minY)
                
                for projectile in projectiles {
                    for step in 0 ..< projectile.visited.count {
                        animator.draw { context in
                            // Draw the background
                            let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)
                            let backgroundColor = CGColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                            
                            context.setFillColor(backgroundColor)
                            context.fill(backgroundBounds)
                            
                            let targetMinXPercent = CGFloat(projectile.targetMin.x) /  projectileFieldWidth
                            let targetMinYPercent = (projectileFieldHeight - CGFloat(projectile.targetMin.y) + CGFloat(minY)) / projectileFieldHeight
                            let targetMaxXPercent = CGFloat(projectile.targetMax.x) /  projectileFieldWidth
                            let targetMaxYPercent = (projectileFieldHeight - CGFloat(projectile.targetMax.y) + CGFloat(minY)) / projectileFieldHeight
                            
                            // Draw the target
                            let targetBounds = CGRect(
                                x: targetMinXPercent * CGFloat(context.width),
                                y: targetMinYPercent * CGFloat(context.height),
                                width: (targetMaxXPercent - targetMinXPercent) * CGFloat(context.width),
                                height: (targetMaxYPercent - targetMinYPercent) * CGFloat(context.height)
                            )
                            
                            // Draw the start
                            let startCenterX = 0.0 * CGFloat(context.width)
                            let startCenterY = ((projectileFieldHeight + CGFloat(minY)) / projectileFieldHeight) * CGFloat(context.height)
                            let startRadius = 5.0
                            
                            context.saveGState()
                            
                            let startCenter = CGPoint(x: startCenterX, y: startCenterY)
                            context.addArc(center: startCenter, radius: startRadius, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: true)
                            
                            let startColor = CGColor(red: 28.0 / 255.0, green: 175.0 / 255.0, blue: 154.0, alpha: 1.0)
                            context.setFillColor(startColor)
                            context.fillPath()
                            
                            context.restoreGState()
                            
                            // If this isn't the first step, draw the lines back
                            if step != 0 {
                                context.saveGState()
                                
                                if step == projectile.visited.count - 1 {
                                    let finalTargetColor = CGColor(red: 238.0 / 255.0, green: 79.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0)
                                    context.setFillColor(finalTargetColor)
                                } else {
                                    let targetColor = CGColor(red: 29.0 / 255.0, green: 41.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
                                    context.setFillColor(targetColor)
                                }
                                
                                context.fill(targetBounds)
                                
                                context.restoreGState()
                                
                                for idx in 1 ... step {
                                    context.saveGState()
                                    
                                    var visit = projectile.visited[idx - 1]
                                    
                                    var pointX = CGFloat(visit.x) / projectileFieldWidth
                                    var pointY = CGFloat(projectileFieldHeight - CGFloat(visit.y) + CGFloat(minY)) / projectileFieldHeight
                                    
                                    var point = CGPoint(
                                        x: pointX * CGFloat(context.width),
                                        y: pointY * CGFloat(context.height)
                                    )
                                    
                                    context.move(to: point)
                                    
                                    visit = projectile.visited[idx]
                                    
                                    pointX = CGFloat(visit.x) / projectileFieldWidth
                                    pointY = CGFloat(projectileFieldHeight - CGFloat(visit.y) + CGFloat(minY)) / projectileFieldHeight
                                    
                                    point = CGPoint(
                                        x: pointX * CGFloat(context.width),
                                        y: pointY * CGFloat(context.height)
                                    )
                                    
                                    context.addLine(to: point)
                                    
                                    let lineRed: CGFloat = 28.0 / 255.0
                                    let lineGreen: CGFloat = 175.0 / 255.0
                                    let lineBlue: CGFloat = 154.0 / 255.0
                                    let lineAlpha: CGFloat = CGFloat(idx) / CGFloat(step)
                                    
                                    let lineColor = CGColor(red: lineRed, green: lineGreen, blue: lineBlue, alpha: lineAlpha)
                                    context.setStrokeColor(lineColor)
                                    
                                    context.setLineWidth(2.0)
                                    context.strokePath()
                                    
                                    context.restoreGState()
                                }
                            }
                        }
                        
                        if step == projectile.visited.count - 1 {
                            for _ in 0 ..< 30 {
                                animator.repeatLastFrame()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func generateProjectiles() -> [Projectile] {
        let absoluteLimitY = [abs(targetY1), abs(targetY2)].max()!

        var yHits: [(velocity: Int, time: Int)] = []

        for velocityY in (-absoluteLimitY ... absoluteLimitY) {
            var currentPoint = startY
            var currentVelocity = velocityY
            var ticks = 0
            
            while true {
                if isBetween(p0: currentPoint, p1: targetY1, p2: targetY2) {
                    let value = (velocity: velocityY, time: ticks)
                    yHits.append(value)
                }
                
                if isBeyond(point: currentPoint, start: startY, targetMin: targetY1, targetMax: targetY2) {
                    break
                }
                
                currentPoint += currentVelocity
                currentVelocity -= 1
                ticks += 1
            }
        }
        
        let uniqueTimes = yHits.map { $0.time }.uniqued().sorted()

        var xHits: [(time: Int, velocity: Int)] = []
        let maxX = max(targetX1, targetX2)
        
        for time in uniqueTimes {
            for velocityX in 0 ... maxX {
                var currentPoint = startX
                var currentVelocity = velocityX
                
                for _ in 0 ..< time {
                    currentPoint += currentVelocity
                    
                    if currentVelocity > 0 {
                        currentVelocity -= 1
                    } else if currentVelocity < 0 {
                        currentVelocity += 1
                    }
                }
                
                if isBetween(p0: currentPoint, p1: targetX1, p2: targetX2) {
                    let value = (time: time, velocity: velocityX)
                    xHits.append(value)
                }
            }
        }
        
        let start = SIMD2<Int>(x: startX, y: startY)
        let target1 = SIMD2<Int>(x: targetX1, y: targetY1)
        let target2 = SIMD2<Int>(x: targetX2, y: targetY2)
        
        var projectiles: [Projectile] = []
        
        for yHit in yHits {
            for xHit in xHits {
                guard xHit.time == yHit.time else { continue }
                
                let velocity = SIMD2<Int>(x: xHit.velocity, y: yHit.velocity)
                var projectile = Projectile(visited: [start], velocity: velocity, targetMin: target1, targetMax: target2)
                
                while projectile.state == .inFlight {
                    projectile.step()
                }
                
                if projectile.state == .hit {
                    projectiles.append(projectile)
                }
            }
        }
        
        return projectiles
    }
    
    private func isBetween(p0: Int, p1: Int, p2: Int) -> Bool {
        let minP = min(p1, p2)
        let maxP = max(p1, p2)
        
        let result = p0 >= minP && p0 <= maxP
        return result
    }

    private func isBeyond(point: Int, start: Int, targetMin: Int, targetMax: Int) -> Bool {
        if !isBetween(p0: targetMin, p1: start, p2: point) && !isBetween(p0: targetMax, p1: start, p2: point) {
            return false
        }

        if isBetween(p0: point, p1: start, p2: targetMin) || isBetween(p0: point, p1: start, p2: targetMax) {
            return false
        }
        
        return true
    }
}
