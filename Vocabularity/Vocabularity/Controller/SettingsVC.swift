//
//  SettingsVC.swift
//  Vocabularity
//
//  Created by Admin on 06.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var wordsAmountBtn: UIButton!
    @IBOutlet weak var englishSwitch: UISwitch!
    @IBOutlet weak var russianSwitch: UISwitch!
    @IBOutlet weak var arabicSwitch: UISwitch!
    
    
    
    
    //Variables
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsVC.wordsAtTimeDidChange(_:)), name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if defaults.integer(forKey: "wordsAtTime") != 0 {
            setWordsAtTimeTitle()
        }
        setSwitchViews()
    }
    
    //Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func wordsAtTimePressed(_ sender: Any) {
        createWordsAtTimeAlertView()
    }
    
    @IBAction func wordsAtTime1Pressed(_ sender: Any) {
        createWordsAtTimeAlertView()
    }
   
    
    @IBAction func englishSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: "english")
        } else {
            defaults.set(false, forKey: "english")
        }
        NotificationCenter.default.post(name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
    }
    
    @IBAction func russianSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: "russian")
        } else {
            defaults.set(false, forKey: "russian")
        }
        NotificationCenter.default.post(name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
    }
    
    @IBAction func arabicSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: "arabic")
        } else {
            defaults.set(false, forKey: "arabic")
        }
        NotificationCenter.default.post(name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
    }
    
    
    
    
    func setSwitchViews() {
        if defaults.bool(forKey: "english") { self.englishSwitch.setOn(true, animated: true) } else { self.englishSwitch.setOn(false, animated: true) }
        if defaults.bool(forKey: "russian") { self.russianSwitch.setOn(true, animated: true) } else { self.russianSwitch.setOn(false, animated: true) }
        if defaults.bool(forKey: "arabic") { self.arabicSwitch.setOn(true, animated: true) } else { self.arabicSwitch.setOn(false, animated: true) }
    }
    
    func createWordsAtTimeAlertView() {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! CustomAlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    @objc func wordsAtTimeDidChange(_ notif: Notification) {
        setWordsAtTimeTitle()
    }
    
    func setWordsAtTimeTitle() {
        wordsAmountBtn.setTitle(String(defaults.integer(forKey: "wordsAtTime")), for: UIControlState.normal)
    }
    
}



extension SettingsVC: CustomAlertViewDelegate {
    
    func okButtonTapped(selectedOption: Int) {
        
        defaults.set(selectedOption, forKey: "wordsAtTime")
        NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
        print("okButtonTapped with \(selectedOption) option selected")
//        print("TextField has value: \(textFieldValue)")
//        , textFieldValue: String
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}

