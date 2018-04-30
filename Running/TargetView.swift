//
//  TargetView.swift
//  Test2View
//
//  Created by Romain Hild on 29/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit

@IBDesignable
class TargetView: UIView {
    var view: UIView!
    var targetLayer = TargetLayer()
    var pointLayers: [PointLayer] = []

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        commonInit()
    }
    
    func commonInit() {
        self.layer.addSublayer(targetLayer)
        for l in stride(from: 1, to: 8, by: 2) {
            for i in 0..<24 {
                let pl = PointLayer()
                pl.level = CGFloat(l)
                pl.angle = CGFloat(i)
                pl.opacity = 0.0
                self.layer.addSublayer(pl)
                self.pointLayers.append(pl)
            }
        }
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        addSubview(view)
        self.view = view
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        targetLayer.frame = self.bounds
        targetLayer.setNeedsDisplay()
        pointLayers.forEach { $0.frame = self.bounds; $0.setNeedsDisplay() }
        
        let label12 = UILabel(frame: CGRect(x: view.bounds.width/2-9, y: targetLayer.size*CGFloat(Speed.allValues.count),
                                            width: 18, height: 15))
        label12.text = "12"
        self.addSubview(label12)
        let label3 = UILabel(frame: CGRect(x: view.bounds.width-targetLayer.size*CGFloat(Speed.allValues.count)-10, y:view.bounds.height/2-7.5,
                                           width: 10, height: 15))
        label3.text = "3"
        self.addSubview(label3)
        let label6 = UILabel(frame: CGRect(x: view.bounds.width/2-5, y: view.bounds.height-targetLayer.size*CGFloat(Speed.allValues.count)-15,
                                           width: 10, height: 15))
        label6.text = "6"
        self.addSubview(label6)
        let label9 = UILabel(frame: CGRect(x: targetLayer.size*CGFloat(Speed.allValues.count), y: view.bounds.height/2-7.5,
                                           width: 10, height: 15))
        label9.text = "9"
        self.addSubview(label9)
    }

}
