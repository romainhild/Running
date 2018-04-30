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
    }

}
