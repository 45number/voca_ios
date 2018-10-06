//
//  SettingsVC.swift
//  Vocabularity
//
//  Created by Admin on 06.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    //Outlets
    @IBOutlet weak var wordsAmountBtn: UIButton!
    
    
    let defaults = UserDefaults.standard
    
    //Variables
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if defaults.integer(forKey: "wordsAtTime") != 0 {
            wordsAmountBtn.setTitle(String(defaults.integer(forKey: "wordsAtTime")), for: UIControlState.normal)
        }
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
    
    
    func createWordsAtTimeAlertView() {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! CustomAlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
}



extension SettingsVC: CustomAlertViewDelegate {
    
    func okButtonTapped(selectedOption: Int) {
        
        defaults.set(selectedOption, forKey: "wordsAtTime")
        print("okButtonTapped with \(selectedOption) option selected")
//        print("TextField has value: \(textFieldValue)")
//        , textFieldValue: String
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}

