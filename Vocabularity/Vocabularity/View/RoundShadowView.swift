//
//  RoundShadowView.swift
//  Vocabularity
//
//  Created by Admin on 03.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class RoundShadowView: UIView {
    
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 10.0
//    private var fillColor: UIColor = .blue
    private var fillColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
//    override func awakeFromNib() {
//        toSetRoundedShadowed()
//    }
//
//    override func prepareForInterfaceBuilder() {
//        super.prepareForInterfaceBuilder()
//        toSetRoundedShadowed()
//    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        toSetRoundedShadowed()
    }
    
    func toSetRoundedShadowed() {
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 3
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
}
