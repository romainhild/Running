//
//  Speed.swift
//  Running
//
//  Created by Romain Hild on 30/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import Foundation
import UIKit

enum Speed: Int {
    case walk = 0
    case slow
    case easy
    case hard
    
    static let allValues = [walk, slow, easy, hard]
    
    func string() -> String {
        switch self {
        case .walk: return "Walk"
        case .slow: return "Slow"
        case .easy: return "Easy"
        case .hard: return "Hard"
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .walk: return UIColor.yellow
        case .slow: return UIColor.init(red: 1.0, green: 0.66, blue: 0, alpha: 1)
        case .easy: return UIColor.init(red: 1.0, green: 0.33, blue: 0, alpha: 1)
        case .hard: return UIColor.red
        }
    }
    
    func sound() -> String {
        switch self {
        case .walk: return "bip"
        case .slow: return "bip2"
        case .easy: return "bip3"
        case .hard: return "bip4"
        }
    }
    
    func radius() -> CGFloat {
        switch self {
        case .walk: return 5.0/10.0
        case .slow: return 4.5/10.0
        case .easy: return 4.0/10.0
        case .hard: return 3.5/10.0
        }
    }
}

