//
//  TargetLayer.swift
//  Test2View
//
//  Created by Romain Hild on 29/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit

class TargetLayer: RadiusLayer {
    
    override func draw(in ctx: CGContext) {
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        let r = bounds.height/2.0

        for speed in Speed.allValues {
            ctx.setFillColor(speed.color().cgColor)
            ctx.addArc(center: center, radius: r-size*CGFloat(speed.rawValue),
                       startAngle: 0, endAngle: CGFloat.pi*2.0, clockwise: false)
            ctx.fillPath()
        }
    }
}

class PointLayer: RadiusLayer {
    
    var level: CGFloat = 1
    var angle: CGFloat = 0

    override func draw(in ctx: CGContext) {
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        let r = bounds.height/2.0
        let delta = CGFloat.pi/12

        ctx.setFillColor(UIColor.black.cgColor)
        let alpha = angle*delta + CGFloat.pi/24
        let centerP = CGPoint(x: center.x+cos(alpha-CGFloat.pi/2)*(r-level*size/2), y: center.y+sin(alpha-CGFloat.pi/2)*(r-level*size/2))
        ctx.addArc(center: centerP, radius: size/4, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: false)
        ctx.fillPath()
    }
}
