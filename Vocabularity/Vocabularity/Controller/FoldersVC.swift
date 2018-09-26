//
//  ViewController.swift
//  Vocabularity
//
//  Created by Admin on 25.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class FoldersVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //Actions
    @IBAction func addBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_CREATE_FOLDER, sender: nil)
    }
    
}

