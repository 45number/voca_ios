//
//  SpellingVC.swift
//  Vocabularity
//
//  Created by Admin on 04.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class SpellingVC: UIViewController {

    //Outlets
    
   
    //Variables
    let defaults = UserDefaults.standard
    var folder: Folder!
    var part: Int!
    
    var words: [Word] = []
    
    private var indexCounter: Int = 0
    private var mCardSwitcher: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    //Actions
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
