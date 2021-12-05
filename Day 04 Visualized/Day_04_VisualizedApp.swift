//
//  Day_04_VisualizedApp.swift
//  Day 04 Visualized
//
//  Created by Stephen H. Gerstacker on 2021-12-04.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import SwiftUI
import Utilities

@main
struct Day_04_VisualizedApp: App {
    
    var boards: [Board]
    var draws: [Int]
    
    let blockSize: CGFloat = 15.0
    let borderWidth: CGFloat = 1.0
    let boardPadding: CGFloat = 5.0
    
    var boardColumns: Int {
        let count = Int(sqrt(Double(boards.count)))
        
        if count * count != boards.count {
            return count + 1
        } else {
            return count
        }
    }
    
    var boardRows: Int {
        Int(sqrt(Double(boards.count)))
    }
    
    var boardWidth: CGFloat {
        let cells = CGFloat(boards.first!.rows.first!.count)
        return (cells * blockSize) + ((cells - 1.0) * borderWidth)
    }
    
    var boardHeight: CGFloat {
        let cells = CGFloat(boards.first!.columns.first!.count)
        return (cells * blockSize) + ((cells - 1.0) * borderWidth)
    }
    
    var renderWidth: CGFloat {
        let cells = CGFloat(boardColumns)
        let result = (cells * boardWidth) + ((cells - 1.0) * boardPadding)
        
        if Int(result) % 2 == 1 {
            return result + 1.0
        } else {
            return result
        }
    }
    
    var renderHeight: CGFloat {
        let cells = CGFloat(boardRows)
        let result = (cells * boardHeight) + ((cells - 1.0) * boardPadding)
        
        if Int(result) % 2 == 1 {
            return result + 1.0
        } else {
            return result
        }
    }
    
    init() {
        var lines = InputData.components(separatedBy: .newlines)
        
        let drawsString = lines.removeFirst()
        draws = drawsString.split(separator: ",").map { Int($0)! }
        
        var boardStrings: [[String]] = []
        var currentBoardStrings: [String] = []

        while !lines.isEmpty {
            let line = lines.removeFirst()
            
            if line.isEmpty {
                if !currentBoardStrings.isEmpty {
                    boardStrings.append(currentBoardStrings)
                    currentBoardStrings.removeAll(keepingCapacity: true)
                }
                
                continue
            }
            
            currentBoardStrings.append(line)
        }

        if !currentBoardStrings.isEmpty {
            boardStrings.append(currentBoardStrings)
            currentBoardStrings.removeAll()
        }

        // Build the board data
        boards = boardStrings.map { boardStringSet -> Board in
            let data = boardStringSet.map { line -> [Int] in
                return line.split(separator: " ").map { Int($0)! }
            }
            
            return Board(data)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RenderableWorkView(width: Int(renderWidth), height: Int(renderHeight), frameTime: 0.05) { animator in
                var boards = self.boards
                
                let columns = boardColumns
                let rows = boardRows
                
                let width = boardWidth
                let height = boardHeight
                
                let offColor = NSColor.systemGray.cgColor
                let onColor = NSColor.systemYellow.cgColor
                let completeColor = NSColor.systemMint.cgColor
                
                let font = CTFontCreateWithName("Menlo" as CFString, CGFloat(blockSize) * 0.6, nil)
                
                for draw in draws {
                    for idx in 0 ..< boards.count {
                        if !boards[idx].isComplete {
                            boards[idx].mark(draw)
                        }
                    }
                    
                    animator.draw { context in
                        let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)
                        
                        let backgroundColor = NSColor.black.cgColor
                        context.setFillColor(backgroundColor)
                        context.fill(backgroundBounds)
                        
                        for x in (0 ..< columns) {
                            for y in (0 ..< rows) {
                                let idx = (y * rows) + x
                                let board = boards[idx]
                                
                                let boardX = CGFloat(x) * (width + boardPadding)
                                let boardY = CGFloat(y) * (width + boardPadding)
                                
                                let boardBounds = CGRect(x: boardX, y: boardY, width: width, height: height)
                                
                                for (cellY, row) in board.rows.enumerated() {
                                    for (cellX, value) in row.enumerated() {
                                        let cellMinX = boardBounds.minX + ((blockSize + borderWidth) * CGFloat(cellX))
                                        let cellMinY = boardBounds.minY + ((blockSize + borderWidth) * CGFloat(cellY))
                                        
                                        let cellBounds = CGRect(x: cellMinX, y: cellMinY, width: blockSize, height: blockSize)
                            
                                        var color: CGColor = offColor
                                        
                                        if let index = row.firstIndex(of: value) {
                                            let mark: UInt8 = 1 << UInt8(index)
                                            
                                            if board.rowMarks[cellY] & mark != 0 {
                                                let rowComplete = 2 ^^ board.columns.count - 1
                                                let columnComplete = 2 ^^ board.rows.count - 1
                                                
                                                if board.rowMarks[cellY] == rowComplete {
                                                    color = completeColor
                                                } else if board.columnMarks[cellX] == columnComplete {
                                                    color = completeColor
                                                } else {
                                                    color = onColor
                                                }
                                            }
                                        }
                                        
                                        context.setFillColor(color)
                                        context.fill(cellBounds)
                                        
                                        context.saveGState()
                                        
                                        context.textMatrix = CGAffineTransform.identity.translatedBy(x: 0, y: CGFloat(context.height)).scaledBy(x: 1, y: -1)
                                        
                                        let label = "\(value)"
                                        let attr = NSAttributedString(string: label)
                                        let range = CFRange(location: 0, length: label.count)
                                        
                                        let attributedLabel = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, label.count, attr as CFAttributedString)
                                        CFAttributedStringSetAttribute(attributedLabel, range, kCTFontAttributeName, font)
                                        
                                        let frameSetter = CTFramesetterCreateWithAttributedString(attributedLabel!)
                                        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, range, nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), nil)
                                        
                                        var textBounds = cellBounds
                                        textBounds.origin.x += (cellBounds.width - textSize.width) / 2
                                        textBounds.origin.y += (cellBounds.height - textSize.height) / 2
                                        textBounds.size.width += (cellBounds.width - textSize.width) / 2
                                        textBounds.size.height += (cellBounds.height - textSize.height) / 2
                                        
                                        let path = CGMutablePath()
                                        path.addRect(textBounds)
                                        
                                        let frame = CTFramesetterCreateFrame(frameSetter, range, path, nil)
                                        
                                        CTFrameDraw(frame, context)
                                        
                                        context.restoreGState()
                                    }
                                }
                            }
                        }
                    }
                    
                    let firstIncomplete = boards.first(where: { !$0.isComplete })
                    if firstIncomplete == nil {
                        break
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
