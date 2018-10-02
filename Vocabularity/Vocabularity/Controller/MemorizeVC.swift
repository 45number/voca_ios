//
//  MemorizeVC.swift
//  Vocabularity
//
//  Created by Admin on 02.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData

class MemorizeVC: UIViewController {

    
    //Variables
    var folder: Folder!
    var part: Int!
    
    var words: [Word] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(part)
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //Functions
    func fetchCoreDataObjects(folder: Folder!, part: Int!) {
        
    }
    
    func fetch (folder: Folder!, part: Int!, completion: (_ complete: Bool) -> ()) {
        
    }
}
