//
//  ChevronLayer.swift
//  Test2View
//
//  Created by Romain Hild on 29/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit

class ChevronLayer: CALayer {
    var chevronWidth: CGFloat { return bounds.width/5 }
    var chevronHeight: CGFloat { return bounds.height/10 }
    var chevronCenter: CGPoint { return CGPoint(x: bounds.width/2, y: chevronHeight/2) }

    override func draw(in ctx: CGContext) {
        let points = [CGPoint(x: chevronCenter.x-chevronWidth/2, y: chevronHeight),
                      CGPoint(x: chevronCenter.x, y: 0),
                      CGPoint(x: chevronCenter.x+chevronWidth/2, y: chevronHeight)]
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(2.0)
        ctx.addLines(between: points)
        ctx.drawPath(using: .stroke)
    }
}
