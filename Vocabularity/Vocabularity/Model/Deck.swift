//
//  Deck.swift
//  Vocabularity
//
//  Created by Admin on 01.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import Foundation

struct Deck {
    
    public private(set) var title: String
    public private(set) var info: String
    
    init(title: String, info: String) {
        self.title = title
        self.info = info
    }
    
}
