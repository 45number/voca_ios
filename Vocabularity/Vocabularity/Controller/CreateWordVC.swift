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
    
    //Variables
    var parentFolder: Folder?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        wordTxtField.delegate = self
        translationTxtField.delegate = self
        
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
        if wordTxtField.text != "" && translationTxtField.text != "" {
            self.save(word: wordTxtField.text!, translation: translationTxtField.text!) { (success) in
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //Functions
    func save(word: String, translation: String, completion: (_ finished: Bool) -> ()) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
//        let nn = Word(
        let newWord = Word(context: managedContext)
        newWord.word = word
        newWord.translation = translation
        newWord.learningLang = Int32(1)
        newWord.repeatMem = false
        newWord.repeatSpell = false
//        newWord.folderName = ""
        newWord.folder = self.parentFolder
        
        do {
            try managedContext.save()
            print("Successfully saved data.")
            completion(true)
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            completion(false)
        }
    }
    
}
