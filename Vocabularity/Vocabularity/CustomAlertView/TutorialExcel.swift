//
//  CustomAlertView.swift
//  CustomAlertView
//
//  Created by Daniel Luque Quintana on 16/3/17.
//  Copyright © 2017 dluque. All rights reserved.
//

import UIKit

class TutorialExcel: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
//    private let dataSource = ["Apple", "Microsoft", "Samsung", "Android", "Google"]
    private var dataSource1: [Int] = []
    
    var delegate: CustomAlertViewDelegate?
    //    var selectedOption = "First"
    var selectedOption1 = 0
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateDataSource()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        if defaults.integer(forKey: "wordsAtTime") != 0 {
            //            self.selectedOption1 = defaults.integer(forKey: "wordsAtTime")
            let initialRow = defaults.integer(forKey: "wordsAtTime") - 5
            pickerView.selectRow(initialRow, inComponent: 0, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
        cancelButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
        cancelButton.addBorder(side: .Right, color: alertViewGrayColor, width: 1)
        okButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    func populateDataSource() {
        for index in 5...100 {
            self.dataSource1.append(index)
        }
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        if self.selectedOption1 != 0 {
            delegate?.okButtonTapped(selectedOption: self.selectedOption1)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension TutorialExcel: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource1.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        detailLabel.text = dataSource[row]
        self.selectedOption1 = dataSource1[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(dataSource1[row])
    }
    
}
