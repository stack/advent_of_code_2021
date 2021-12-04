//
//  Board.swift
//  Day 04 Visualized
//
//  Created by Stephen H. Gerstacker on 2021-12-04.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

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
