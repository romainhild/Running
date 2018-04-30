//
//  TargetLayer.swift
//  Test2View
//
//  Created by Romain Hild on 29/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit

class TargetLayer: CALayer {
    let colorsRadius: [(CGColor, CGFloat)] = [(UIColor.yellow.cgColor,5.0/10.0),
                                              (UIColor(red: 1.0, green: 0.66, blue: 0.0, alpha: 1.0).cgColor,4.0/10.0),
                                              (UIColor(red: 1.0, green: 0.33, blue: 0.0, alpha: 1.0).cgColor,3.0/10.0),
                                              (UIColor.red.cgColor,2.0/10.0)]

    override func draw(in ctx: CGContext) {
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        for (c,r) in colorsRadius {
            ctx.setFillColor(c)
            ctx.addArc(center: center, radius: bounds.height*r, startAngle: 0, endAngle: CGFloat.pi*2.0, clockwise: false)
            ctx.fillPath()
        }
    }
}
