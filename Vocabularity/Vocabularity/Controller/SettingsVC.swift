//
//  SettingsVC.swift
//  Vocabularity
//
//  Created by Admin on 06.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData

class SettingsVC: UIViewController {

    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var wordsAmountBtn: UIButton!
    @IBOutlet weak var englishSwitch: UISwitch!
    @IBOutlet weak var russianSwitch: UISwitch!
    @IBOutlet weak var arabicSwitch: UISwitch!
    
    
    
    
    //Variables
    var treeArray:[Folder] = []
    
    
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
            defaults.set(true, forKey: LANG_ENG)
            NotificationCenter.default.post(name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
        } else {
            if defaults.bool(forKey: LANG_RU) || defaults.bool(forKey: LANG_AR) {
                self.warningDeleteLanguage(language: LANG_ENG)
            } else {
                self.englishSwitch.setOn(true, animated: true)
                self.warningCannotDeleteLanguage()
            }
        }
    }
    
    @IBAction func russianSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: LANG_RU)
            NotificationCenter.default.post(name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
        } else {
            if defaults.bool(forKey: LANG_ENG) || defaults.bool(forKey: LANG_AR) {
                self.warningDeleteLanguage(language: LANG_RU)
            } else {
                self.russianSwitch.setOn(true, animated: true)
                self.warningCannotDeleteLanguage()
            }
        }
    }
    
    @IBAction func arabicSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: LANG_AR)
            NotificationCenter.default.post(name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
        } else {
            if defaults.bool(forKey: LANG_ENG) || defaults.bool(forKey: LANG_RU) {
                self.warningDeleteLanguage(language: LANG_AR)
            } else {
                self.arabicSwitch.setOn(true, animated: true)
                self.warningCannotDeleteLanguage()
            }
        }
    }
    
    func warningDeleteLanguage(language: String!) {
        let alert = UIAlertController(title: "Are you sure!", message: "Delete this language with folders?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            if language == LANG_ENG {
                self.englishSwitch.setOn(true, animated: true)
            } else if language == LANG_RU {
                self.russianSwitch.setOn(true, animated: true)
            } else if language == LANG_AR {
                self.arabicSwitch.setOn(true, animated: true)
            } else {
                return
            }
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.deleteLanguage(language: language)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteLanguage(language: String!) {
        var langId = 0
        if language == LANG_ENG {
            langId = 1
        } else if language == LANG_RU {
            langId = 2
        } else if language == LANG_AR {
            langId = 3
        } else {
            return
        }
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchREquest = NSFetchRequest<Folder>(entityName: "Folder")
        fetchREquest.predicate = NSPredicate(format: "learningLang == \(langId)")
        do {
            let folders = try managedContext.fetch(fetchREquest)
            for folder in folders {
                if folder.image != "default.png" && folder.image != nil {
                    ImageStore.delete(imageNamed: folder.image!)
                }
                managedContext.delete(folder)
            }
            try managedContext.save()
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
        
        defaults.set(false, forKey: language)
        NotificationCenter.default.post(name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
    }
    
    
    func warningCannotDeleteLanguage() {
        let alert = UIAlertController(title: "Oops!", message: "You should learn at least one language", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
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
        clearDecksMarked()
        defaults.set(selectedOption, forKey: "wordsAtTime")
        NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
        print("okButtonTapped with \(selectedOption) option selected")
        
//        print("TextField has value: \(textFieldValue)")
//        , textFieldValue: String
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
    
    func clearDecksMarked() {
//        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
//        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "DeckMarked")
//        let request = NSBatchDeleteRequest(fetchRequest: fetch)
//        do {
//            try managedContext.execute(request)
//            print("deleted DeckMarked")
//        } catch {
//            debugPrint("Could not remove: \(error.localizedDescription)")
//        }
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchDeckRequest = NSFetchRequest<DeckMarked>(entityName: "DeckMarked")
        do {
            let decksMarked = try managedContext.fetch(fetchDeckRequest)
            for deck in decksMarked {
                do {
                    managedContext.delete(deck)
                    try managedContext.save()
                } catch {
                    debugPrint("Could not fetch: \(error.localizedDescription)")
                }
            }
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
        
    }
    
}

