//
//  BitsDecoder.swift
//  Day 16
//
//  Created by Stephen H. Gerstacker on 2021-12-16.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum PacketType: Equatable {
    case literal
    case sum
    case product
    case minimum
    case maximum
    case greaterThan
    case lessThan
    case equalTo
}

struct Packet: CustomStringConvertible, Equatable {
    let version: Int
    let type: PacketType
    let children: [Packet]
    let value: UInt64

    var description: String {
        return generateDescription()
    }

    func generateDescription(depth: Int = 0) -> String {
        let pad = String(repeating: "  ", count: depth)

        var current = "\(pad)V: \(version), "

        switch type {
        case .literal:
            current += "L: \(value)"
        case .sum:
            current += "+: {\n"
        case .product:
            current += "*: {\n"
        case .minimum:
            current += "v: {\n"
        case .maximum:
            current += "^: {\n"
        case .greaterThan:
            current += ">: {\n"
        case .lessThan:
            current += "<: {\n"
        case .equalTo:
            current += "=: {\n"
        }

        if type != .literal {
            current += children.map { $0.generateDescription(depth: depth + 1) }.joined(separator: "\n")
            current += "\n\(pad)}"
            current += " = \(evaluate())"
        }

        return current
    }

    func evaluate() -> UInt64 {
        switch type {
        case .literal:
            return value
        case .sum:
            return children.map { $0.evaluate() }.reduce(0, +)
        case .product:
            return children.map { $0.evaluate() }.reduce(1, *)
        case .minimum:
            return children.map { $0.evaluate() }.min()!
        case .maximum:
            return children.map { $0.evaluate() }.max()!
        case .greaterThan:
            precondition(children.count == 2)

            let lhs = children[0].evaluate()
            let rhs = children[1].evaluate()

            return lhs > rhs ? 1 : 0
        case .lessThan:
            precondition(children.count == 2)

            let lhs = children[0].evaluate()
            let rhs = children[1].evaluate()

            return lhs < rhs ? 1 : 0
        case .equalTo:
            precondition(children.count == 2)

            let lhs = children[0].evaluate()
            let rhs = children[1].evaluate()

            return lhs == rhs ? 1 : 0
        }
    }

    var versionSum: Int {
        let childSum = children.reduce(0) { $0 + $1.versionSum }
        return version + childSum
    }
}

class BitsDecoder {

    private var remainingInput: String = ""
    private var currentData: UInt64 = 0
    private var currentDataSize: Int = 0
    private var bitsConsumed: Int = 0

    func decode(_ value: String) -> [Packet] {
        remainingInput = value
        currentData = 0
        currentDataSize = 0
        bitsConsumed = 0

        var packets: [Packet] = []

        while !remainingInput.isEmpty && remainingInput != "0" {
            let packet = readPacket()
            packets.append(packet)

            flush()
        }

        return packets
    }

    private func flush() {
        currentData = 0
        currentDataSize = 0
    }

    private func readBits(_ count: Int) -> UInt64 {
        // Fill the buffer if needed
        while currentDataSize < count {
            readNext()
        }

        // Extract the value
        let diff = currentDataSize - count
        let value = currentData >> diff

        if diff == 0 {
            currentData = 0
        } else {
            let mask = UInt64((2 ^^ diff) - 1)
            currentData = mask & currentData
        }

        currentDataSize -= count
        bitsConsumed += count

        return value
    }

    private func readLiteralPacket(version: UInt64) -> Packet {
        var value: UInt64 = 0

        var leader: UInt64 = 0

        repeat {
            leader = readBits(1)

            let next = readBits(4)
            value = value << 4
            value = value | next
        } while (leader != 0)

        return Packet(version: Int(version), type: .literal, children: [], value: value)
    }

    private func readNext() {
        precondition(!remainingInput.isEmpty)

        let character = remainingInput.removeFirst()
        let value = UInt64(String(character), radix: 16)!

        currentData = currentData << 4
        currentData = currentData | value
        currentDataSize += 4
    }

    private func readOperatorPacket(version: UInt64, type: UInt64) -> Packet {
        let packetType: PacketType

        switch type {
        case 0:
            packetType = .sum
        case 1:
            packetType = .product
        case 2:
            packetType = .minimum
        case 3:
            packetType = .maximum
        case 5:
            packetType = .greaterThan
        case 6:
            packetType = .lessThan
        case 7:
            packetType = .equalTo
        default:
            fatalError("Unsupported packet type: \(type)")
        }

        let lengthType = readBits(1)

       var childPackets: [Packet] = []

        if lengthType == 0 {
            let subpacketLength = readBits(15)
            let startingBitsConsumed = bitsConsumed

            while (bitsConsumed - startingBitsConsumed) < subpacketLength {
                let packet = readPacket()
                childPackets.append(packet)
            }

            assert(bitsConsumed - startingBitsConsumed == subpacketLength)

        } else if lengthType == 1 {
            let totalChildPackets = readBits(11)

            while childPackets.count < totalChildPackets {
                let packet = readPacket()
                childPackets.append(packet)
            }
        } else {
            fatalError("Unhandled operator packet length")
        }

        return Packet(version: Int(version), type: packetType, children: childPackets, value: 0)
    }

    private func readPacket() -> Packet {
        let version = readBits(3)
        let type = readBits(3)

        if type == 4 {
            return readLiteralPacket(version: version)
        } else {
            return readOperatorPacket(version: version, type: type)
        }
    }
}

extension BitsDecoder {

    static func test() {
        test1()
        test2()
        test3()
        test4()
        test5()
        test6()
        test7()
        test8()
    }

    static func test1() {
        let input = "D2FE28"

        let decoder = BitsDecoder()
        let result = decoder.decode(input)

        assert(result.count == 1)

        let expected = Packet(version: 6, type: .literal, children: [], value: 2021)
        assert(result[0] == expected, "Expected \(expected), got \(result[0])")
    }

    private static func test2() {
        let input = "38006F45291200"

        let decoder = BitsDecoder()
        let result = decoder.decode(input)

        assert(result.count == 1)

        let expectedChildren = [
            Packet(version: 6, type: .literal, children: [], value: 10),
            Packet(version: 2, type: .literal, children: [], value: 20),
        ]

        let expected = Packet(version: 1, type: .lessThan, children: expectedChildren, value: 0)

        assert(result[0] == expected, "Expected \(expected), got \(result[0])")
    }

    private static func test3() {
        let input = "EE00D40C823060"

        let decoder = BitsDecoder()
        let result = decoder.decode(input)

        assert(result.count == 1)

        let expectedChildren = [
            Packet(version: 2, type: .literal, children: [], value: 1),
            Packet(version: 4, type: .literal, children: [], value: 2),
            Packet(version: 1, type: .literal, children: [], value: 3),
        ]

        let expected = Packet(version: 7, type: .maximum, children: expectedChildren, value: 0)

        assert(result[0] == expected, "Expected \(expected), got \(result[0])")
    }

    private static func test4() {
        let input = "8A004A801A8002F478"

        let decoder = BitsDecoder()
        let result = decoder.decode(input)

        assert(result.count == 1)
        assert(result[0].version == 4)

        let expectedChildren = [
            Packet(version: 6, type: .literal, children: [], value: 15)
        ]

        let expectedInnerInnerChild = Packet(version: 5, type: .minimum, children: expectedChildren, value: 0)
        let expectedInnerChild = Packet(version: 1, type: .minimum, children: [expectedInnerInnerChild], value: 0)
        let expected = Packet(version: 4, type: .minimum, children: [expectedInnerChild], value: 0)

        assert(result[0] == expected, "Expected \(expected), got \(result[0])")
        assert(result[0].versionSum == 16)
    }

    private static func test5() {
        let input = "620080001611562C8802118E34"

        let decoder = BitsDecoder()
        let result = decoder.decode(input)

        assert(result.count == 1)

        let expectedLiterals1 = [
            Packet(version: 0, type: .literal, children: [], value: 10),
            Packet(version: 5, type: .literal, children: [], value: 11),
        ]

        let expectedLiterals2 = [
            Packet(version: 0, type: .literal, children: [], value: 12),
            Packet(version: 3, type: .literal, children: [], value: 13),
        ]

        let expectedChildren = [
            Packet(version: 0, type: .sum, children: expectedLiterals1, value: 0),
            Packet(version: 1, type: .sum, children: expectedLiterals2, value: 0),
        ]

        let expected = Packet(version: 3, type: .sum, children: expectedChildren, value: 0)

        assert(result[0] == expected, "Expected \(expected), got \(result[0])")
        assert(result[0].versionSum == 12)
    }

    private static func test6() {
        let input = "C0015000016115A2E0802F182340"

        let decoder = BitsDecoder()
        let result = decoder.decode(input)

        assert(result.count == 1)

        let expectedLiterals1 = [
            Packet(version: 0, type: .literal, children: [], value: 10),
            Packet(version: 6, type: .literal, children: [], value: 11),
        ]

        let expectedLiterals2 = [
            Packet(version: 7, type: .literal, children: [], value: 12),
            Packet(version: 0, type: .literal, children: [], value: 13),
        ]

        let expectedChildren = [
            Packet(version: 0, type: .sum, children: expectedLiterals1, value: 0),
            Packet(version: 4, type: .sum, children: expectedLiterals2, value: 0),
        ]

        let expected = Packet(version: 6, type: .sum, children: expectedChildren, value: 0)

        assert(result[0] == expected, "Expected \(expected), got \(result[0])")
        assert(result[0].versionSum == 23)
    }

    private static func test7() {
        let input = "A0016C880162017C3686B18A3D4780"

        let decoder = BitsDecoder()
        let result = decoder.decode(input)

        assert(result.count == 1)

        let expectedLiterals = [
            Packet(version: 7, type: .literal, children: [], value: 6),
            Packet(version: 6, type: .literal, children: [], value: 6),
            Packet(version: 5, type: .literal, children: [], value: 12),
            Packet(version: 2, type: .literal, children: [], value: 15),
            Packet(version: 2, type: .literal, children: [], value: 15),
        ]

        let expectedInnerInner = Packet(version: 3, type: .sum, children: expectedLiterals, value: 0)
        let expectedInner = Packet(version: 1, type: .sum, children: [expectedInnerInner], value: 0)
        let expected = Packet(version: 5, type: .sum, children: [expectedInner], value: 0)

        assert(result[0] == expected, "Expected \(expected), got \(result[0])")
        assert(result[0].versionSum == 31)
    }

    private static func test8() {
        let tests = [
            (input: "C200B40A82", expected: 3),
            (input: "04005AC33890", expected: 54),
            (input: "880086C3E88112", expected: 7),
            (input: "CE00C43D881120", expected: 9),
            (input: "D8005AC2A8F0", expected: 1),
            (input: "F600BC2D8F", expected: 0),
            (input: "9C005AC2F8F0", expected: 0),
            (input: "9C0141080250320F1802104A08", expected: 1)
        ]

        for (input, expected) in tests {
            let decoder = BitsDecoder()
            let result = decoder.decode(input)

            let value = result[0].evaluate()

            assert(value == expected)
        }
    }
}
