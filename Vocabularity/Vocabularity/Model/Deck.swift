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
    public private(set) var marked: Bool
    
    init(title: String, info: String, marked: Bool) {
        self.title = title
        self.info = info
        self.marked = marked
    }
    
}
