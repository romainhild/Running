//
//  Program.swift
//  Running
//
//  Created by Romain Hild on 30/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import Foundation
import UIKit

class Program {
    typealias DictionaryType = [(Int,Speed)]
    private var program: [(Int,Speed)] = []

    var name: String = ""
    var totalTime: Int { return program.reduce(0) { $0+$1.0 } }
    var walkTime: Int { return program.filter { $0.1 == .walk }.reduce(0) { $0+$1.0 } }
    var slowTime: Int { return program.filter { $0.1 == .slow }.reduce(0) { $0+$1.0 } }
    var easyTime: Int { return program.filter { $0.1 == .easy }.reduce(0) { $0+$1.0 } }
    var hardTime: Int { return program.filter { $0.1 == .hard }.reduce(0) { $0+$1.0 } }
    var count: Int { return program.count }

    init() {}
    
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

