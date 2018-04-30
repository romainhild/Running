//
//  ProgramsSaved.swift
//  Running
//
//  Created by Romain Hild on 30/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import Foundation

final class ProgramsSaved {
    private(set) var programs: [Program] = []
    static let shared = ProgramsSaved()
    
    private init() {}
    
    func addProgram(_ program: Program) {
        programs.append(program)
    }
    
    func removeProgram(at index: Int) {
        if index < programs.count {
            programs.remove(at: index)
        }
    }
    
    func renameProgram(at index: Int, with newName: String) {
        if index < programs.count {
            programs[index].name = newName
        }
    }
    
    func replaceProgram(at index: Int, with program: Program) {
        programs.remove(at: index)
        programs.insert(program, at: index)
    }
}
