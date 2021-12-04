//
//  main.swift
//  Day 04
//
//  Created by Stephen H. Gerstacker on 2021-12-04.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

let data = InputData

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence

func ^^(radis: Int, power: Int) -> Int {
    return Int(pow(Double(radis), Double(power)))
}

struct Board: CustomStringConvertible {
    
    var rows: [[Int]]
    var columns: [[Int]]
    
    var rowMarks: [UInt8]
    var columnMarks: [UInt8]
    
    var score: Int
    
    init(_ data: [[Int]]) {
        rows = []
        columns = [[Int]](repeating: [], count: data.count)
        score = 0
        
        for row in data {
            rows.append(row)
            
            for (idx, value) in row.enumerated() {
                columns[idx].append(value)
                score += value
            }
        }
        
        rowMarks = [UInt8](repeating: 0, count: rows.count)
        columnMarks = [UInt8](repeating: 0, count: columns.count)
    }
    
    var description: String {
        return rows.enumerated().map { rowIdx, row -> String in
            return row.enumerated().map { valueIdx, value -> String in
                let markIdx = UInt8(valueIdx)
                
                let markerSpace: String
                
                if ((rowMarks[rowIdx] >> markIdx) & 0x1) == 1 {
                    markerSpace = "*"
                } else {
                    markerSpace = " "
                }
                
                let space = value < 10 ? " " : ""
                
                return "\(markerSpace)\(space)\(value)"
            }.joined(separator: " ")
        }.joined(separator: "\n")
    }
    
    var isComplete: Bool {
        let rowComplete = 2 ^^ columns.count - 1
        
        for row in rowMarks {
            if row == rowComplete { return true }
        }
        
        let columnComplete = 2 ^^ rows.count - 1
        
        for column in columnMarks {
            if column == columnComplete { return true }
        }
        
        return false
    }
    
    mutating func mark(_ value: Int) {
        var didMark = false
        
        for (rowIdx, row) in rows.enumerated() {
            if let idx = row.firstIndex(of: value) {
                let mark = UInt8(1) << idx
                rowMarks[rowIdx] |= mark
                
                didMark = true
                
                break
            }
        }
        
        if didMark {
            for (columnIdx, column) in columns.enumerated() {
                if let idx = column.firstIndex(of: value) {
                    let mark = UInt8(1) << idx
                    columnMarks[columnIdx] |= mark
                
                    break
                }
            }
        }
        
        if didMark {
            score -= value
        }
    }
}

// Get the drawn numbers
var lines = data.components(separatedBy: .newlines)

let drawsString = lines.removeFirst()
let draws = drawsString.split(separator: ",").map { Int($0)! }

// Separate the boards in to groups of strings
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
var boards = boardStrings.map { boardStringSet -> Board in
    let data = boardStringSet.map { line -> [Int] in
        return line.split(separator: " ").map { Int($0)! }
    }
    
    return Board(data)
}

// Run the picks
var winningDraws: [Int] = []
var winningBoards: [Board] = []

for draw in draws {
    print("Draw: \(draw)")
    
    for idx in 0 ..< boards.count {
        boards[idx].mark(draw)
    }
    
    for board in boards { print("\n\(board)") }
    
    print("\n---------------------------\n")
    
    let indexesToRemove = boards.enumerated().compactMap { (idx, board) -> Int? in
        board.isComplete ? idx : nil
    }
    
    for idx in indexesToRemove {
        winningDraws.append(draw)
        winningBoards.append(boards[idx])
    }
    
    for idx in indexesToRemove.reversed() {
        boards.remove(at: idx)
    }
    
    if boards.isEmpty { break }
}

let winningDraw = winningDraws.first!
let winningBoard = winningBoards.first!
let winningScore = winningBoard.score * winningDraw

print("First winning score: \(winningScore)")

let finalDraw = winningDraws.last!
let finalBoard = winningBoards.last!
let finalScore = finalBoard.score * finalDraw

print("Final score: \(finalScore)")
