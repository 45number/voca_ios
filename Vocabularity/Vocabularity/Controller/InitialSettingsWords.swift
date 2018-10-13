//
//  InitialSettingsWords.swift
//  Vocabularity
//
//  Created by Admin on 13.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class InitialSettingsWords: UIViewController {

    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var counterLbl: UILabel!
    
    //Variables
    var number = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //Actions
    @IBAction func stepperPressed(_ sender: UIStepper) {
        number = Int(sender.value)
        counterLbl.text = String(number)
    }
    
//    setWordsAtTime(completion: @escaping CompletionHandler) {
//        guard let success = defaults.set(number, forKey: "wordsAtTime") else {return}
//    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        if number > 0 {
            defaults.set(number, forKey: "wordsAtTime")
            performSegue(withIdentifier: TO_MAIN_VIEW, sender: sender)
        }
    }
    
}
