//
//  Misc.swift
//  Running
//
//  Created by Romain Hild on 30/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import Foundation

func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory,
                                         in: .userDomainMask)
    return paths[0]
}

func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("Running.plist")
}


func intToTime(time: Int) -> String {
    let m: Int = time/60
    let s: Int = time % 60
    var t: String = "0s"
    if m > 0 {
        if s > 0 {
            t = String(format: "%dm %ds", m, s)
        } else {
            t = String(format: "%dm", m)
        }
    } else if s > 0 {
        t = String(format: "%ds", s)
    }
    return t
}

func doubleToTime(time: Double) -> String {
    let m: Int = Int(time/60)
    let s: Double = time.truncatingRemainder(dividingBy: 60)
    var t: String = "0s"
    if m > 0 {
        if s > 0 {
            t = String(format: "%dm %.1fs", m, s)
        } else {
            t = String(format: "%dm", m)
        }
    } else if s > 0 {
        t = String(format: "%.1fs", s)
    }
    return t
}
