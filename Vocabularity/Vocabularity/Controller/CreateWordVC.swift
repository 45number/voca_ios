//
//  CreateWordVC.swift
//  Vocabularity
//
//  Created by Admin on 01.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class CreateWordVC: UIViewController {

    //Outlets
    @IBOutlet weak var wordTxtField: UITextField!
    @IBOutlet weak var translationTxtField: UITextField!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    //Variables
    var parentFolder: Folder?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsStackView.bindToKeyboard()
    }

    //Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func okBtnPressed(_ sender: Any) {
        
    }
    
    
}
