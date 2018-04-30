//
//  ChevronView.swift
//  Test2View
//
//  Created by Romain Hild on 29/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit

//@IBDesignable
class ChevronView: UIView {
    var view: UIView!
    let chevronLayer = ChevronLayer()

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
        layer.backgroundColor = UIColor.clear.cgColor
        self.layer.addSublayer(chevronLayer)
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
        chevronLayer.frame = self.bounds
        chevronLayer.setNeedsDisplay()
    }

}
