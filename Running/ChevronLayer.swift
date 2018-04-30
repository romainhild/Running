//
//  ChevronLayer.swift
//  Test2View
//
//  Created by Romain Hild on 29/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit

class ChevronLayer: RadiusLayer {
    var chevronCenter: CGPoint { return CGPoint(x: bounds.width/2, y: size/2) }
    
    let image = UIImage(named: "runningman.png")!

    override func draw(in ctx: CGContext) {
         UIGraphicsPushContext(ctx)
        image.draw(in: CGRect(x: chevronCenter.x-size/2, y: chevronCenter.y-size/2, width: size, height: size))
        UIGraphicsPopContext()
    }
}
