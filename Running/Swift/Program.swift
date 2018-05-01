//
//  Program.swift
//  Running
//
//  Created by Romain Hild on 30/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import Foundation
import UIKit

class Program : Codable {
    typealias DictionaryType = [(Int,Speed)]
    private var program: [(Int,Speed)] = []

    var name: String = ""
    
    var totalTime: Int { return program.reduce(0) { $0+$1.0 } }
    var walkTime: Int { return program.filter { $0.1 == .walk }.reduce(0) { $0+$1.0 } }
    var slowTime: Int { return program.filter { $0.1 == .slow }.reduce(0) { $0+$1.0 } }
    var easyTime: Int { return program.filter { $0.1 == .easy }.reduce(0) { $0+$1.0 } }
    var hardTime: Int { return program.filter { $0.1 == .hard }.reduce(0) { $0+$1.0 } }
    var count: Int { return program.count }
    
    private enum CodingKeys: String, CodingKey {
        case times
        case speeds
        case name
    }

    init() {}
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let p1 = try values.decode([Int].self, forKey: .times)
        let p2 = try values.decode([Speed].self, forKey: .speeds)
        for i in 0..<p1.count {
            program.append((p1[i],p2[i]))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        let p1 = program.map {$0.0}
        let p2 = program.map {$0.1}
        try container.encode(p1, forKey: .times)
        try container.encode(p2, forKey: .speeds)
    }

    init(name n: String, program p: [(Int,Speed)]) {
        name = n
        program = p
    }
    
    func append(_ element: (Int,Speed)) {
        program.append(element)
    }
    
    func insert(_ element: (Int,Speed), at index: Int) {
        program.insert(element, at: index)
    }
    
    @discardableResult func remove(at index: Int) -> (Int,Speed) {
        return program.remove(at: index)
    }
    
    subscript(index:Int) -> (Int,Speed) {
        get { return program[index] }
        set { program.insert(newValue, at: index) }
    }
    
}

