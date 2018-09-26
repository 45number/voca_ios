//
//  BorderButton.swift
//  app-swoosh
//
//  Created by Admin on 15.09.2018.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

class BorderButton: UIButton {
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

}
