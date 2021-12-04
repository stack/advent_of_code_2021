//
//  Power.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2021-12-04.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence

public func ^^(radis: Int, power: Int) -> Int {
    return Int(pow(Double(radis), Double(power)))
}
