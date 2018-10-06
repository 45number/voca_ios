//
//  SettingsVC.swift
//  Vocabularity
//
//  Created by Admin on 06.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    
    //Variables
    private let dataSource = ["Apple", "Microsoft", "Samsung", "Android", "Google"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    //Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func wordsAtTimePressed(_ sender: Any) {
//        createWordsAtTimeAlertView()
        opa()
    }
    
    func opa() {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! CustomAlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func createWordsAtTimeAlertView() {
        
        
        let alert = UIAlertController(title: "Add", message: "What to add:", preferredStyle: UIAlertControllerStyle.alert)

//        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
//
        let pickerFrame = CGRect(x: 17, y: 52, width: 270, height: 100)
        let picker = UIPickerView(frame: pickerFrame)
        
        picker.delegate = self
        picker.dataSource = self
        
        alert.view.addSubview(picker)
//
//        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
//
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

extension SettingsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        detailLabel.text = dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
}

extension SettingsVC: CustomAlertViewDelegate {
    
    func okButtonTapped() {
//        print("okButtonTapped with \(selectedOption) option selected")
//        print("TextField has value: \(textFieldValue)")
//        selectedOption: String, textFieldValue: String
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}

