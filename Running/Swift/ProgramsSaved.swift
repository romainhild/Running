//
//  ProgramsSaved.swift
//  Running
//
//  Created by Romain Hild on 30/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import Foundation

final class ProgramsSaved : Codable {
    private(set) var programs: [Program] = []
    static let shared = ProgramsSaved()
    
    private init() {
        if let data = try? Data(contentsOf: dataFilePath()) {
            let decoder = PropertyListDecoder()
            do {
                programs = try decoder.decode([Program].self, from: data)
            } catch {
                print("Error decoding item array!")
            }
        }
    }
    
    func savePrograms() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(programs)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding")
        }
    }
    
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
