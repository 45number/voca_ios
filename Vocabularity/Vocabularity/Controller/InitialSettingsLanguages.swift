//
//  InitialSettingsLanguages.swift
//  Vocabularity
//
//  Created by Admin on 13.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class InitialSettingsLanguages: UIViewController {

    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var englishSwitch: UISwitch!
    @IBOutlet weak var russianSwitch: UISwitch!
    @IBOutlet weak var arabicSwitch: UISwitch!
    
    @IBOutlet weak var warningLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setSwitchViews()
        warningLbl.isHidden = true
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        if isLanguageChosen() {
            let parentVC = self.parent as! InitialSettingsVC
            parentVC.setViewControllers([parentVC.orderedViewControllers[1]], direction: .forward, animated: true, completion: nil)
            parentVC.pageControl.currentPage = 1
        } else {
            warningLbl.isHidden = false
        }
    }
    
    //Actions
    @IBAction func englishSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: "english")
            warningLbl.isHidden = true
        } else {
            defaults.set(false, forKey: "english")
        }
    }
    
    @IBAction func russianSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: "russian")
            warningLbl.isHidden = true
        } else {
            defaults.set(false, forKey: "russian")
        }
    }
    
    @IBAction func arabicSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: "arabic")
            warningLbl.isHidden = true
        } else {
            defaults.set(false, forKey: "arabic")
        }
    }
    
    
    func setSwitchViews() {
        if defaults.bool(forKey: "english") { self.englishSwitch.setOn(true, animated: true) } else { self.englishSwitch.setOn(false, animated: true) }
        if defaults.bool(forKey: "russian") { self.russianSwitch.setOn(true, animated: true) } else { self.russianSwitch.setOn(false, animated: true) }
        if defaults.bool(forKey: "arabic") { self.arabicSwitch.setOn(true, animated: true) } else { self.arabicSwitch.setOn(false, animated: true) }
    }
    
    func isLanguageChosen() -> Bool {
        if defaults.bool(forKey: "english") ||
            defaults.bool(forKey: "russian") ||
            defaults.bool(forKey: "arabic") {
            return true
        }
        return false
    }
    
}
