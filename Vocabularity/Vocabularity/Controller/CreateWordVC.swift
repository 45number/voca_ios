//
//  CreateWordVC.swift
//  Vocabularity
//
//  Created by Admin on 01.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData

class CreateWordVC: UIViewController, UITextFieldDelegate  {

    //Outlets
    @IBOutlet weak var wordTxtField: UITextField!
    @IBOutlet weak var translationTxtField: UITextField!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var savedLbl: UILabel!
    
    
    
    
    //Variables
    var parentFolder: Folder?
    var learningLanguage: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        wordTxtField.delegate = self
        translationTxtField.delegate = self
        
        buttonsStackView.bindToKeyboard()
        savedLbl.isHidden = true
        
        self.hideKeyboardWhenTappedAround()
        
    }

    //Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func okBtnPressed(_ sender: Any) {
        if wordTxtField.text != "" && translationTxtField.text != "" {
            self.save(learningLanguage: self.learningLanguage!, word: wordTxtField.text!, translation: translationTxtField.text!) { (success) in
                self.wordTxtField.text = ""
                self.translationTxtField.text = ""
//                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //Functions
    func save(learningLanguage: Int, word: String, translation: String, completion: (_ finished: Bool) -> ()) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let newWord = Word(context: managedContext)
        newWord.word = word.trimmingCharacters(in: .whitespacesAndNewlines)
        newWord.translation = translation.trimmingCharacters(in: .whitespacesAndNewlines)
        newWord.learningLang = Int32(learningLanguage)
        newWord.repeatMem = false
        newWord.repeatSpell = false
        newWord.folder = self.parentFolder
        
        do {
            try managedContext.save()
            NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
            print("Successfully saved data.")
            self.wordTxtField.resignFirstResponder()
            self.wordTxtField.becomeFirstResponder()
            
            self.savedLbl.isHidden = false
            self.savedLbl.alpha = 1.0
            
            UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseOut, animations: {
                self.savedLbl.alpha = 0.0
            }, completion: nil)
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
//                    self.savedLbl.alpha = 0.0
//                }, completion: nil)
////                self.savedLbl.isHidden = true
//            }
            
            
            
            completion(true)
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == wordTxtField {
            if (self.wordTxtField.text != "" && self.wordTxtField.text != nil) &&
                (self.translationTxtField.text != "" && self.translationTxtField.text != nil) {
                self.save(learningLanguage: self.learningLanguage!, word: wordTxtField.text!, translation: translationTxtField.text!) { (success) in
                    self.wordTxtField.text = ""
                    self.translationTxtField.text = ""
                }
            } else {
                self.wordTxtField.resignFirstResponder()
                self.translationTxtField.becomeFirstResponder()
            }
        } else if textField == translationTxtField {
            if (self.wordTxtField.text != "" && self.wordTxtField.text != nil) &&
                (self.translationTxtField.text != "" && self.translationTxtField.text != nil) {
                self.save(learningLanguage: self.learningLanguage!, word: wordTxtField.text!, translation: translationTxtField.text!) { (success) in
                    self.wordTxtField.text = ""
                    self.translationTxtField.text = ""
                }
            } else {
                self.translationTxtField.resignFirstResponder()
                self.wordTxtField.becomeFirstResponder()
            }
        }
        return true
    }
    
    
    
    
}
