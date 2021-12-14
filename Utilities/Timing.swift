//
//  Timing.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2021-12-14.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public func benchmark<T>(operation: () -> (T)) -> (TimeInterval, T) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = operation()
    let endTime = CFAbsoluteTimeGetCurrent()
    
    let elapsedSeconds = endTime - startTime
    
    return (elapsedSeconds, result)
}
