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
    let delta = CGFloat.pi/12.0
    var layer: ChevronLayer { return self.view!.layer.sublayers![1] as! ChevronLayer }
    var width: CGFloat { return layer.bounds.width }
    var height: CGFloat { return layer.bounds.height }
    var center: CGPoint { return CGPoint(x: width/2, y: height/2) }
    var epsilonDistance: CGFloat { return max(width/10, height/10) }
    var chevronCenter: CGPoint { return layer.chevronCenter }
    var initialAngle: CGFloat = 0.0
    var alpha: Int {
        let angleP: CGFloat
        if angleR >= 0 {
            angleP = angleR
        } else {
            angleP = angleR+2*CGFloat.pi
        }
        let a = Int(angleP/delta)
        if a < 7 {
            return a
        } else if a < 22 {
            return a + a%2
        } else {
            return 24
        }
    }
    var angle: CGFloat {
        return CGFloat(alpha)*delta
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let touch = touches.first!.location(in: self.view)
        if touches.count == 1 && isInitialTouch(location: touch) {
            initialAngle = angle(of: touch)
            state = .began
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let newTouch = touches.first
        let newPoint = (newTouch?.location(in: self.view))!
        let oldAlpha = self.alpha
        self.angleR = angle(of: newPoint)-initialAngle
        if (oldAlpha != self.alpha) && ((oldAlpha > self.alpha+2) || (oldAlpha < self.alpha-2)) {
            print("invalid alpha: \(self.alpha) old: \(oldAlpha)")
            state = .failed
        } else {
            let r = distance(from: newPoint, to: center)
            if r < height*Speed.hard.radius() {
                self.level = 3
            } else if r < height*Speed.easy.radius() {
                self.level = 2
            } else if r < height*Speed.slow.radius() {
                self.level = 1
            } else {
                self.level = 0
            }
            self.state = .changed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if alpha == 0 {
            self.state = .failed
        } else {
            self.state = .ended
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .cancelled
    }
    
    override func reset() {
        self.angleR = 0.0
        self.level = 0
        self.state = .possible
    }
    
    func isInitialTouch(location: CGPoint) -> Bool {
        return distance(from: location, to: chevronCenter) < epsilonDistance
    }
    
    func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return sqrt((point1.x-point2.x)*(point1.x-point2.x) + (point1.y-point2.y)*(point1.y-point2.y))
    }
    
    func angle(of point: CGPoint) -> CGFloat {
        return -atan2(-(point.x-center.x),-(point.y-center.y))
    }
}
