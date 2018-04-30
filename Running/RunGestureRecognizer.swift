//
//  RunGestureRecognizer.swift
//  Test2View
//
//  Created by Romain Hild on 29/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class RunGestureRecognizer: UIGestureRecognizer {
    var angleR: CGFloat = 0.0
    var level: Int = 0
    let delta = CGFloat.pi/6.0
    var layer: ChevronLayer { return self.view!.layer.sublayers![1] as! ChevronLayer }
    var width: CGFloat { return layer.bounds.width }
    var height: CGFloat { return layer.bounds.height }
    var center: CGPoint { return CGPoint(x: width/2, y: height/2) }
    var epsilonDistance: CGFloat { return max(width/10, height/10) }
    var initialCenter: CGPoint { return layer.chevronCenter }
    var alpha: CGFloat {
        if angleR > 0 {
            return CGFloat(Int(angleR/delta))
        } else {
            return CGFloat(Int((angleR+2*CGFloat.pi)/delta))
        }
    }
    var angle: CGFloat { return CGFloat(alpha)*delta }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if touches.count == 1 && isInitialTouch(location: touches.first!.location(in: self.view)) {
            state = .began
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let newTouch = touches.first
        let newPoint = (newTouch?.location(in: self.view))!
        self.angleR = -atan2(-(newPoint.x-center.x),
                             -(newPoint.y-center.y))
        let r = distance(from: newPoint, to: center)
        if r < height*2.0/10.0 {
            self.level = 3
        } else if r < height*3.0/10.0 {
            self.level = 2
        } else if r < height*4.0/10.0 {
            self.level = 1
        } else {
            self.level = 0
        }
        self.state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .cancelled
    }
    
    override func reset() {
        self.state = .possible
    }
    
    func isInitialTouch(location: CGPoint) -> Bool {
        return distance(from: location, to: initialCenter) < epsilonDistance
    }
    
    func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return sqrt((point1.x-point2.x)*(point1.x-point2.x) + (point1.y-point2.y)*(point1.y-point2.y))
    }
}
