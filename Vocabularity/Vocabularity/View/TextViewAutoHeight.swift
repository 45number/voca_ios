//
//  TextViewAutoHeight.swift
//  Vocabularity
//
//  Created by Admin on 10.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class TextViewAutoHeight: UITextView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isScrollEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(updateHeight), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    @objc func updateHeight() {
        // trigger your animation here
        
        
         var newFrame = frame
         
         let fixedWidth = frame.size.width
         let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
         
         newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
         self.frame = newFrame
         
        
        // suggest searching stackoverflow for "uiview animatewithduration" for frame-based animation
        // or "animate change in intrinisic size" to learn about a more elgant solution :)
    }

}
