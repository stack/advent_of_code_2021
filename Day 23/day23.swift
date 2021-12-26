//
//  main.swift
//  Day 23
//
//  Created by Stephen H. Gerstacker on 2021-12-23.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

@main
struct Day24 {
    
    static func main() async {
        part2()
    }
    
    static func examplePart1() {
        let initialState = parseData(value: ExampleData)
        
        print("Initial State:")
        print(initialState)
        
        let cost = initialState.solve()
        
        print()
        print("Example 1:")
        print("Cost: \(cost)")
    }
    
    static func examplePart2() {
        let initialState = parseData(value: ExampleDataFull)
        
        print("Initial State:")
        print(initialState)
        
        let cost = initialState.solve()
        
        print()
        print("Example 1:")
        print("Cost: \(cost)")
    }
    
    static func part1() {
        let initialState = parseData(value: InputData)
        
        print("Initial State:")
        print(initialState)
        
        let cost = initialState.solve()
        
        print()
        print("Part 1:")
        print("Cost: \(cost)")
    }
    
    static func part2() {
        let initialState = parseData(value: InputDataFull)
        
        print("Initial State:")
        print(initialState)
        
        let cost = initialState.solve()
        
        print()
        print("Part 1:")
        print("Cost: \(cost)")
    }
    
    private static func parseData(value: String) -> State {
        var lines = value.components(separatedBy: .newlines)
        lines.removeFirst()
        lines.removeFirst()
        lines.removeLast()
        
        let homes = lines.map { line -> [Amphipod?] in
            line.compactMap {
                switch $0 {
                case "#":
                    return nil
                case " ":
                    return nil
                case "A":
                    return Amphipod.amber
                case "B":
                    return Amphipod.bronze
                case "C":
                    return Amphipod.copper
                case "D":
                    return Amphipod.desert
                default:
                    fatalError("Invalid room config")
                }
            }
        }
        
        let rooms: [Amphipod:Room] = [
            .amber: Room(target: .amber, index: 2, content: (0 ..< homes.count).map { homes[$0][0] } ),
            .bronze: Room(target: .bronze, index: 4, content: (0 ..< homes.count).map { homes[$0][1] } ),
            .copper: Room(target: .copper, index: 6, content: (0 ..< homes.count).map { homes[$0][2] } ),
            .desert: Room(target: .desert, index: 8, content: (0 ..< homes.count).map { homes[$0][3] } ),
        ]
        
        let hallway = [Amphipod?](repeating: nil, count: 11)
        
        return State(hallway: hallway, rooms: rooms, cost: 0)
    }
}

enum Amphipod: CustomStringConvertible, Equatable, Hashable {
    case amber
    case bronze
    case copper
    case desert
    
    var description: String {
        switch self {
        case .amber:
            return "A"
        case .bronze:
            return "B"
        case .copper:
            return "C"
        case .desert:
            return "D"
        }
    }
    
    var movementCost: Int {
        switch self {
        case .amber:
            return 1
        case .bronze:
            return 10
        case .copper:
            return 100
        case .desert:
            return 1000
        }
    }
}

struct Room: Equatable, Hashable {
    let target: Amphipod
    let index: Int
    
    var content: [Amphipod?]
    
    var isAvailable: Bool {
        content.allSatisfy { $0 == target || $0 == nil }
    }
    
    var isComplete: Bool {
        content.allSatisfy { $0 == target }
    }
    
    var isInvalid: Bool {
        return !isAvailable
    }
}

struct State: CustomStringConvertible, Equatable, Hashable {
    let hallway: [Amphipod?]
    let rooms: [Amphipod:Room]
    let cost: Int
    
    
    static func ==(lhs: State, rhs: State) -> Bool {
        return lhs.hallway == rhs.hallway && lhs.rooms == rhs.rooms
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hallway)
        hasher.combine(rooms)
    }
    
    var isValid: Bool {
        var counts: [Amphipod:Int] = [:]
        
        for value in hallway {
            if let value = value {
                counts[value] = (counts[value] ?? 0) + 1
            }
        }
        
        for (_, room) in rooms {
            for value in room.content {
                if let value = value {
                    counts[value] = (counts[value] ?? 0) + 1
                }
            }
        }
        
        let roomSize = rooms.values.first!.content.count
        
        for (_, count) in counts {
            if count != roomSize {
                return false
            }
        }
        
        return true
    }
    
    var availableHallwayIndexes: [Int] {
        let allHallwayIndexes = [0, 1, 3, 5, 7, 9, 10]
        
        return allHallwayIndexes.filter { hallway[$0] == nil }
    }
    
    var description: String {
        var result = ""
        
        result += String(repeating: "#", count: hallway.count + 2)
        result += "\n"
        
        result += "#"
        result += hallway.map { $0?.description ?? "." }.joined()
        result += "#\n"
        
        for depth in 0 ..< rooms.values.first!.content.count {
            if depth == 0 {
                result += "###"
            } else {
                result += "  #"
            }
            
            for key in [Amphipod.amber, Amphipod.bronze, Amphipod.copper, Amphipod.desert] {
                let room = rooms[key]!
                
                result += room.content[depth]?.description ?? "."
                result += "#"
            }
            
            if depth == 0 {
                result += "##"
            }
            
            result += "\n"
        }
        
        result += "  "
        result += String(repeating: "#", count: (rooms.keys.count * 2) + 1)
        
        return result
    }
    
    var distance: Int {
        var distance = 0
        
        for (index, amphipod) in hallway.enumerated() {
            guard let amphipod = amphipod else { continue }

            let room = rooms[amphipod]!
            
            distance += abs(index - room.index) * amphipod.movementCost
        }
        
        for room in rooms.values {
            for value in room.content {
                guard let value = value else { continue }
                
                let targetRoom = rooms[value]!
                distance += abs(room.index - targetRoom.index) * value.movementCost
            }
        }
        
        return distance
    }
    
    var isSolved: Bool {
        rooms.values.allSatisfy { $0.isComplete }
    }
    
    func nextStates() -> [State] {
        var result: [State] = []
        
        for (index, amphipod) in movableHallwayAmphipods() {
            let room = rooms[amphipod]!
            
            guard isHallwayPathClear(hallwayIndex: index, room: room) else { continue }
            
            let depth = room.content.lastIndex(of: nil)! + 1
            let cost = (abs(index - room.index) + depth) * amphipod.movementCost
            
            var nextHallway = hallway
            nextHallway[index] = nil
            
            var nextRoom = room
            nextRoom.content[depth - 1] = amphipod
            
            var nextRooms = rooms
            nextRooms[amphipod] = nextRoom
            
            let state = State(hallway: nextHallway, rooms: nextRooms, cost: self.cost + cost)
            result.append(state)
        }
        
        for room in invalidRooms() {
            let toMoveIndex = room.content.firstIndex { $0 != nil }!
            let amphipod = room.content[toMoveIndex]!
            
            for index in availableHallwayIndexes {
                guard isHallwayPathClear(hallwayIndex: index, room: room) else { continue }
                let depth = toMoveIndex + 1
                let cost = (abs(room.index - index) + depth) * amphipod.movementCost
                
                var nextHallway = hallway
                nextHallway[index] = amphipod
                
                var nextRoom = room
                nextRoom.content[toMoveIndex] = nil
                
                var nextRooms = rooms
                nextRooms[room.target] = nextRoom
                
                let state = State(hallway: nextHallway, rooms: nextRooms, cost: self.cost + cost)
                result.append(state)
            }
        }
        
        return result
    }
    
    func solve() -> Int {
        var frontier: PriorityQueue<State> = PriorityQueue<State>()
        var cameFrom: [State:State] = [:]
        var costSoFar: [State:Int] = [:]
        
        frontier.push(self, priority: 0)
        costSoFar[self] = 0
        
        var endState: State? = nil
        
        while !frontier.isEmpty {
            let current = frontier.pop()!
            
            if current.isSolved {
                endState = current
                break
            }
            
            for nextState in current.nextStates() {
                let currentCost = (costSoFar[nextState] ?? .max)
                
                if nextState.cost < currentCost {
                    costSoFar[nextState] = nextState.cost
                    
                    let priority = nextState.cost + nextState.distance
                    frontier.push(nextState, priority: priority)
                    
                    cameFrom[nextState] = current
                }
            }
        }
        
        return endState!.cost
    }
    
    private func invalidRooms() -> [Room] {
        rooms.values.filter { $0.isInvalid }
    }
    
    private func isHallwayPathClear(hallwayIndex: Int, room: Room) -> Bool {
        let range: ClosedRange<Int>
        
        if hallwayIndex < room.index {
            range = (hallwayIndex + 1) ... room.index
        } else {
            range = room.index ... hallwayIndex - 1
        }
        
        return hallway[range].allSatisfy { $0 == nil }
    }
    
    private func movableHallwayAmphipods() -> [(index: Int, amphipod: Amphipod)] {
        hallway.enumerated().compactMap { (index, amphipod) -> (index: Int, amphipod: Amphipod)? in
            guard let amphipod = amphipod else { return nil }
            
            let room = rooms[amphipod]!
            guard room.isAvailable else { return nil }
            
            
            return (index: index, amphipod: amphipod)
        }
    }
}
