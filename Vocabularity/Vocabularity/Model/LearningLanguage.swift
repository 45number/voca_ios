//
//  LearningLanguage.swift
//  Vocabularity
//
//  Created by Admin on 07.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

struct LearningLanguage {
    
    public private(set) var name: String
    public private(set) var tag: Int
    public private(set) var image: UIImage?
    public private(set) var selectedImage: UIImage?
    
    init(name: String, tag: Int, image: UIImage?, selectedImage: UIImage?) {
        self.name = name
        self.image = image
        self.tag = tag
        self.selectedImage = selectedImage
    }
    
}
