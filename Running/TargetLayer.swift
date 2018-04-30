//
//  TargetLayer.swift
//  Test2View
//
//  Created by Romain Hild on 29/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit

class RadiusLayer: CALayer {
    var size: CGFloat { return bounds.height/15 }
}

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
