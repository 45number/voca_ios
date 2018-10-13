//
//  InitialSettingsLanguages.swift
//  Vocabularity
//
//  Created by Admin on 13.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class InitialSettingsLanguages: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
        
//        // get parent view controller
//        let parentVC = self.parent as! InitialSettingsVC
//
//        // change page of PageViewController
//        parentVC.setViewControllers([parentVC.pages[1]], direction: .forward, animated: true, completion: nil)
    }
    

}
