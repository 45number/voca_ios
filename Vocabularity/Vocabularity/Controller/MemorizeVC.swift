//
//  MemorizeVC.swift
//  Vocabularity
//
//  Created by Admin on 02.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class MemorizeVC: UIViewController, UITextFieldDelegate {

    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var speakBtn: UIButton!
    @IBOutlet weak var directionBtn: UIButton!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var markBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var circleBtn: UIButton!
    
    @IBOutlet weak var firstLblTextField: UITextField!
    @IBOutlet weak var secondLblTextField: UITextField!
    @IBOutlet weak var editBtnsView: UIView!
    
    
    @IBOutlet weak var deleteBtn: RoundedButton!
    @IBOutlet weak var cancelBtn: RoundedButton!
    @IBOutlet weak var saveBtn: RoundedButton!
    
    
    @IBOutlet weak var editBtn: UIButton!
    
    
    //Variables
    var folder: Folder?
    var part: Int?
    var wordsAtTime: Int = 25
    
    
    
    
    
    var words: [Word] = []
    
    private var indexCounter: Int = 0
    private var mCardSwitcher: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if defaults.integer(forKey: "wordsAtTime") != 0 {
            self.wordsAtTime = defaults.integer(forKey: "wordsAtTime")
        }
        
        speakBtn.setImage(UIImage(named: "speaking"), for:.normal);
        speakBtn.setImage(UIImage(named: "speaking_pressed"), for:.highlighted);
        
        
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(MemorizeVC.onCardTap(_:)))
        cardView.addGestureRecognizer(cardTap)
        
//        let cancelBtnTap = UITapGestureRecognizer(target: self, action: #selector(MemorizeVC.dismissKeyboard(_:)))
//        cancelBtn.addGestureRecognizer(cancelBtnTap)
        
        self.fetchCoreDataObjects(folder: folder, part: part)
        self.displayCurrentWord(index: indexCounter)
        self.setQuantity(index: indexCounter)
        
        setMarkBtnView()
        setCircleBtnView()
        setShuffleBtnView()
        setDirectionBtnView()
        
        firstLblTextField.isHidden = true
        secondLblTextField.isHidden = true
        editBtnsView.isHidden = true
        
        cardView.setNeedsDisplay()
        
        deleteBtn.setTitle(STRING_DELETE, for: .normal)
        cancelBtn.setTitle(STRING_CANCEL, for: .normal)
        saveBtn.setTitle(STRING_SAVE, for: .normal)
        
        firstLblTextField.delegate = self
        secondLblTextField.delegate = self
//        self.hideKeyboardWhenTappedAround()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
                coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        
                    let orient = UIApplication.shared.statusBarOrientation
        
                    switch orient {
        
                    case .portrait:
        
                        print("Portrait")
        
                    case .landscapeLeft,.landscapeRight :
        
                        print("Landscape")
        
                    default:
        
                        print("Anything But Portrait")
                    }
        
                }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                    //refresh view once rotation is completed not in will transition as it returns incorrect frame size.Refresh here
                    
                    
        
                })
                super.viewWillTransition(to: size, with: coordinator)
            }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if defaults.integer(forKey: "wordsAtTime") != 0 {
            self.wordsAtTime = defaults.integer(forKey: "wordsAtTime")
        }
        
//        print(self.wordsAtTime)
//        print(defaults.integer(forKey: "wordsAtTime"))
    }
    
    @objc func dismissKeyboard(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        cancelEditing()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func speakBtnPressed(_ sender: Any) {
        speak(phrase: words[indexCounter].word, language: Int(words[indexCounter].learningLang))
    }
    
    @IBAction func previousBtnPressed(_ sender: Any) {
        mCardSwitcher = false
        previousWord()
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        mCardSwitcher = false
        nextWord()
    }
    
    @IBAction func markBtnPressed(_ sender: Any) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let currentWord = words[indexCounter]
        currentWord.repeatMem = !words[indexCounter].repeatMem
        
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        setMarkBtnView()
        NotificationCenter.default.post(name: NOTIF_WORD_WAS_MARKED, object: nil)
    }
    
    @IBAction func shuffleBtnPressed(_ sender: Any) {
        let shuffled = !defaults.bool(forKey: "shuffled")
        defaults.set(shuffled, forKey: "shuffled")
        
        if defaults.bool(forKey: "shuffled") {
            self.shuffleWords()
            self.indexCounter = 0
            self.displayCurrentWord(index: indexCounter)
            self.setQuantity(index: indexCounter)
            self.secondLbl.text = ""
        } else {
            self.fetchCoreDataObjects(folder: self.folder, part: self.part)
            self.indexCounter = 0
            self.displayCurrentWord(index: indexCounter)
            self.setQuantity(index: indexCounter)
            self.secondLbl.text = ""
        }
        
        setShuffleBtnView()
    }
    
    @IBAction func circleBtnPressed(_ sender: Any) {
        let looped = !defaults.bool(forKey: "looped")
        defaults.set(looped, forKey: "looped")
        setCircleBtnView()
    }
    
    @IBAction func directionBtnPressed(_ sender: Any) {
        let directionReversed = !defaults.bool(forKey: "directionReversed")
        defaults.set(directionReversed, forKey: "directionReversed")
        displayCurrentWord(index: indexCounter)
        if secondLbl.text != "" {
            translate(index: indexCounter)
        }
        setDirectionBtnView()
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        
        firstLbl.isHidden = true
        secondLbl.isHidden = true
        
        firstLblTextField.isHidden = false
        secondLblTextField.isHidden = false
        
        editBtnsView.isHidden = false
        editBtn.isHidden = true
        
//        let editTap = UITapGestureRecognizer(target: self, action: #selector(MemorizeVC.editTap(_:)))
//        cardView.addGestureRecognizer(editTap)
//        cardView.removeGestureRecognizer(cardView.gestureRecognizers![0])
//        cardView
//        self.hideKeyboardWhenTappedAround()
        
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Delete the card", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in }))
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
            
            guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
            
            managedContext.delete(self.words[self.indexCounter])
            
            do {
                try managedContext.save()
                print("Successfully removed word")
                if self.words.count > 1 {
                    self.words.remove(at: self.indexCounter)
                    self.indexCounter -= 1
                    self.nextWord()
                    self.setQuantity(index: self.indexCounter)
                } else {
                    
                    self.dismiss(animated: true, completion: nil)
                }
                NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
            } catch {
                debugPrint("Could not remove: \(error.localizedDescription)")
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        cancelEditing()
    }
    
    func cancelEditing() {
        
        firstLblTextField.resignFirstResponder()
        secondLblTextField.resignFirstResponder()
        
        firstLblTextField.isHidden = true
        secondLblTextField.isHidden = true
        
        displayCurrentWord(index: indexCounter)
        
        
        
        firstLbl.isHidden = false
        secondLbl.isHidden = false
        
        editBtnsView.isHidden = true
        editBtn.isHidden = false
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        editBtn.isHidden = false
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        if !defaults.bool(forKey: "directionReversed") {
            words[self.indexCounter].translation = firstLblTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            words[self.indexCounter].word = secondLblTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            words[self.indexCounter].word = firstLblTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            words[self.indexCounter].translation = secondLblTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        do {
            try managedContext.save()
            print("Successfully saved data.")
            displayCurrentWord(index: indexCounter)
            if secondLbl.text != "" {
                translate(index: self.indexCounter)
            }
            cancelEditing()
            view.endEditing(true)
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
        }
    }
    
    
    
    //Functions
    func fetchCoreDataObjects(folder: Folder!, part: Int!) {
        self.fetch(folder: folder, part: part) { (complete) in
            if complete {
                
                if defaults.bool(forKey: "shuffled") {
                    shuffleWords()
                }
                
            }
        }
    }
    
    func fetch (folder: Folder?, part: Int?, completion: (_ complete: Bool) -> ()) {

        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchREquest = NSFetchRequest<Word>(entityName: "Word")
        
        if folder != nil && part != nil {
            fetchREquest.predicate = NSPredicate(format: "folder == %@", folder!)
            fetchREquest.fetchOffset = part! * self.wordsAtTime
            fetchREquest.fetchLimit = self.wordsAtTime
        } else {
            
            let memorizePredicate = NSPredicate(format: "repeatMem == true")
            let languagePredicate = NSPredicate(format: "learningLang == \(defaults.integer(forKey: "currentLearningLanguage"))")
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [memorizePredicate, languagePredicate])
            fetchREquest.predicate = andPredicate
            
//            fetchREquest.predicate = NSPredicate(format: "repeatMem == true")
        }
        
        
        do {
            words = try managedContext.fetch(fetchREquest)
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func shuffleWords() {
        words = self.words.shuffled()
    }
    
//    func markWord(toRepeat: Bool) {
//
//    }
    
    func displayCurrentWord(index: Int) {
        
        let translation = words[index].translation
        let word = words[index].word
        
        if !defaults.bool(forKey: "directionReversed") {
            firstLbl.text = words[index].translation
            
            firstLblTextField.text = translation
            secondLblTextField.text = word
        } else {
            firstLbl.text = words[index].word
            
            firstLblTextField.text = word
            secondLblTextField.text = translation
        }
    }
    
    func translate(index: Int) {
        if !defaults.bool(forKey: "directionReversed") {
            secondLbl.text = words[index].word
        } else {
            secondLbl.text = words[index].translation
        }
    }
    
    func setQuantity(index: Int) {
        quantityLbl.text = "\(index + 1) / \(words.count)"
    }
    
    func speak(phrase: String!, language: Int!) {
        
        DispatchQueue.global(qos: .background).async {
            let utterance = AVSpeechUtterance(string: phrase)
            if language == 1 {
                utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            } else if language == 2 {
                utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
            } else if language == 3 {
                utterance.voice = AVSpeechSynthesisVoice(language: "ar-SA")
            }
            print("language is \(language)")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
            
//            DispatchQueue.main.async {
//                print("This is run on the main queue, after the previous code in outer block")
//            }
        }
    }
    
    @objc func onCardTap(_ recognizer: UITapGestureRecognizer) {
        if !mCardSwitcher {
            self.translate(index: indexCounter)
            self.speak(phrase: words[indexCounter].word, language: Int(words[indexCounter].learningLang))
            
        } else {
            self.nextWord()
        }
        mCardSwitcher = !mCardSwitcher
    }
    
//    @objc func editTap(_ recognizer: UITapGestureRecognizer) {
//        self.hideKeyboardWhenTappedAround()
//    }
    
    func nextWord() {
        if defaults.bool(forKey: "looped") && self.indexCounter == (self.words.count - 1) {
            self.secondLbl.text = ""
            self.indexCounter = 0
            self.displayCurrentWord(index: indexCounter)
            self.setQuantity(index: indexCounter)
            self.setMarkBtnView()
        } else {
            if self.indexCounter < (self.words.count - 1){
                self.secondLbl.text = ""
                self.indexCounter += 1
                self.displayCurrentWord(index: indexCounter)
                self.setQuantity(index: indexCounter)
                self.setMarkBtnView()
            }
        }
    }
    
    func previousWord() {
        if defaults.bool(forKey: "looped") && self.indexCounter == 0 {
            self.secondLbl.text = ""
            self.indexCounter = self.words.count - 1
            self.displayCurrentWord(index: indexCounter)
            self.setQuantity(index: indexCounter)
            self.setMarkBtnView()
        } else {
            if self.indexCounter > 0 {
                self.secondLbl.text = ""
                self.indexCounter -= 1
                self.displayCurrentWord(index: indexCounter)
                self.setQuantity(index: indexCounter)
                self.setMarkBtnView()
            }
        }
    }
    
    func setMarkBtnView() {
        if words[indexCounter].repeatMem {
            self.showWordAsMarked()
        } else {
            self.showWordAsUnmarked()
        }
    }
    
    func showWordAsMarked() {
        markBtn.setImage(UIImage(named: "bookmark-pressed"), for:.normal);
    }
    
    func showWordAsUnmarked() {
        markBtn.setImage(UIImage(named: "bookmark-white"), for:.normal);
    }
    
    func setDirectionBtnView() {
        if defaults.bool(forKey: "directionReversed") {
            directionBtn.setImage(UIImage(named: "exchange_pressed"), for:.normal);
//            directionBtn.setTitle("En - Ru", for: .normal)
        } else {
            directionBtn.setImage(UIImage(named: "exchange"), for:.normal);
//            directionBtn.setTitle("Ru - En", for: .normal)
        }
    }
    
    func setCircleBtnView() {
        if defaults.bool(forKey: "looped") {
            circleBtn.setImage(UIImage(named: "repeat-pressed"), for:.normal);
        } else {
            circleBtn.setImage(UIImage(named: "repeat"), for:.normal);
        }
    }
    
    func setShuffleBtnView() {
        if defaults.bool(forKey: "shuffled") {
            shuffleBtn.setImage(UIImage(named: "shuffle-pressed"), for:.normal);
        } else {
            shuffleBtn.setImage(UIImage(named: "shuffle"), for:.normal);
        }
    }
}


extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}









