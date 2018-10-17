//
//  SpellingVC.swift
//  Vocabularity
//
//  Created by Admin on 04.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class SpellingVC: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var speakBtn: UIButton!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var circleBtn: UIButton!
    @IBOutlet weak var markBtn: UIButton!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var firstLblTextField: UITextField!
    @IBOutlet weak var secondLblTextField: UITextField!
    @IBOutlet weak var editBtnsView: UIView!
    
    
    
    //Variables
    var folder: Folder?
    var part: Int?
    
    var isCorrect: Bool = false
    
    var words: [Word] = []
    
    private var indexCounter: Int = 0
    private var mCardSwitcher: Bool = false
    var wordsAtTime: Int = 25
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.integer(forKey: "wordsAtTime") != 0 {
            self.wordsAtTime = defaults.integer(forKey: "wordsAtTime")
        }
        
        self.textField.delegate = self
        
        speakBtn.setImage(UIImage(named: "speaking"), for:.normal);
        speakBtn.setImage(UIImage(named: "speaking_pressed"), for:.highlighted);
        
        self.fetchCoreDataObjects(folder: folder, part: part)
        self.displayCurrentWord(index: indexCounter)
        self.setQuantity(index: indexCounter)
        
        setMarkBtnView()
        setCircleBtnView()
        setShuffleBtnView()
        
        self.textField.autocorrectionType = .no
//        buttonsStackView.bindToKeyboard()
        
        firstLblTextField.isHidden = true
        secondLblTextField.isHidden = true
        editBtnsView.isHidden = true
    }
    
    
    //Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func speakBtnPressed(_ sender: Any) {
        speak(phrase: words[indexCounter].word, language: Int(words[indexCounter].learningLang))
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
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        mCardSwitcher = false
        nextWord()
    }
    
    @IBAction func previousBtnPressed(_ sender: Any) {
        mCardSwitcher = false
        previousWord()
    }
    
    @IBAction func markBtnPressed(_ sender: Any) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let currentWord = words[indexCounter]
        currentWord.repeatSpell = !words[indexCounter].repeatSpell
        
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        setMarkBtnView()
        NotificationCenter.default.post(name: NOTIF_WORD_WAS_MARKED, object: nil)
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        
        textField.isUserInteractionEnabled = false
        
        firstLbl.isHidden = true
        secondLbl.isHidden = true
        
        firstLblTextField.isHidden = false
        secondLblTextField.isHidden = false
        
        editBtnsView.isHidden = false
        editBtn.isHidden = true
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
                    NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                
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
        
        textField.isUserInteractionEnabled = true
        
        firstLblTextField.isHidden = true
        secondLblTextField.isHidden = true
        
        displayCurrentWord(index: indexCounter)
        
        
        
        firstLbl.isHidden = false
        secondLbl.isHidden = false
        
        editBtnsView.isHidden = true
        editBtn.isHidden = false
        view.endEditing(true)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        editBtn.isHidden = false
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        words[self.indexCounter].translation = firstLblTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        words[self.indexCounter].word = secondLblTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //        textField.resignFirstResponder()  //if desired
        checkPhrase()
        return true
    }
    
    func checkPhrase() {
        let userWordUntrimmed = textField.text
        let userWord = userWordUntrimmed?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if userWord != "" {
            
            if self.isCorrect {
                
                self.nextWord()
                self.isCorrect = false
            } else {
                speak(phrase: words[indexCounter].word, language: Int(words[indexCounter].learningLang))
                
                let (userInput, mismatches1) = findMismatch(compared: userWord!, reference: words[indexCounter].word!)
                let (rightPhrase, mismatches2) = findMismatch(compared: words[indexCounter].word!, reference: userWord!)
                
            
                if mismatches1 + mismatches2 == 0 {
                    self.setCorrectAnswerTextFieldView()
                    self.secondLbl.text = ""
                    self.isCorrect = true
                } else {
                    self.setDefaultAnswerTextFieldView()
                    self.secondLbl.attributedText = rightPhrase
                }
                self.textField.attributedText =  userInput
            }
        }
    }
    
    func findMismatch(compared: String, reference: String) -> (NSAttributedString, Int) {
        let comparedArray = compared.lowercased().components(separatedBy: " ")
        let referenceArray = reference.lowercased().components(separatedBy: " ")
        var wrongWords = comparedArray.filter{ item in !(referenceArray.contains(item)) }
        
        let attribString = NSMutableAttributedString()
        var mistakesCounter = 0
        
        for word in comparedArray {
            
            var isWrong = false
            
            if wrongWords.count != 0 {
                for wrongWord in wrongWords {
                    if word == wrongWord {
                        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.red]
                        let attribWord = NSAttributedString(string: "\(word)", attributes: attributes)
                        attribString.append(attribWord)
                        attribString.append(NSAttributedString(string: " "))
                        
                        isWrong = true
                        mistakesCounter += 1
                        wrongWords.removeFirst()
                        break
                    }
                }
            }
            
            if isWrong == false {
                attribString.append(NSAttributedString(string: word))
                attribString.append(NSAttributedString(string: " "))
            }
        }
        
        return (attribString, mistakesCounter)
        
    }
    
    /*
    func findMismatch1(compared: String, reference: String) {
        let userWordUntrimmed = textField.text
        let userWord = userWordUntrimmed?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if userWord != "" {
            speak(phrase: words[indexCounter].word)
            let userWordsArray = userWord?.lowercased().components(separatedBy: " ")
            let rightWordsArray = words[indexCounter].word?.lowercased().components(separatedBy: " ")
            
            var wrongWords = userWordsArray?.filter{ item in !(rightWordsArray?.contains(item))! }
            
            let attribString = NSMutableAttributedString()
            var mistakesCounter = 0
            
            for word in userWordsArray! {
                
                var isWrong = false
                
                if wrongWords?.count != 0 {
                    for wrongWord in wrongWords! {
                        if word == wrongWord {
                            let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.red]
                            let attribWord = NSAttributedString(string: "\(word)", attributes: attributes)
                            attribString.append(attribWord)
                            attribString.append(NSAttributedString(string: " "))
                            
                            isWrong = true
                            mistakesCounter += 1
                            wrongWords?.removeFirst()
                            break
                        }
                    }
                }
                
                if isWrong == false {
                    attribString.append(NSAttributedString(string: word))
                    attribString.append(NSAttributedString(string: " "))
                }
            }
            if mistakesCounter == 0 {
                self.setCorrectAnswerTextFieldView()
            } else {
                self.textField.attributedText =  attribString
            }
        }
    }
 */
    
    func setCorrectAnswerTextFieldView() {
        self.textField.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.768627451, blue: 0.1294117647, alpha: 1)
        self.textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        self.textField.isUserInteractionEnabled = false 3EC421
    }
    
    func setDefaultAnswerTextFieldView() {
        self.textField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.textField.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    func getAttributedStrings(text: String) -> [NSAttributedString] {
        let words:[String] = text.components(separatedBy: " , ")
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.red]
        
        let attribWords = words.map({
            return NSAttributedString(string: " \($0) ", attributes: attributes)
        })
        return attribWords
    }
    
    func createLabel(string:NSAttributedString) ->UILabel {
        let label = UILabel()
        label.backgroundColor = UIColor.red
        label.attributedText = string
        label.sizeToFit()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = label.frame.height * 0.5
        return label
    }
    
    func fetchCoreDataObjects(folder: Folder?, part: Int?) {
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
            let spellingPredicate = NSPredicate(format: "repeatSpell == true")
            let languagePredicate = NSPredicate(format: "learningLang == \(defaults.integer(forKey: "currentLearningLanguage"))")
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [spellingPredicate, languagePredicate])
            fetchREquest.predicate = andPredicate
        }
        
        
        do {
            words = try managedContext.fetch(fetchREquest)
            print("Successfully fetched words")
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func shuffleWords() {
        words = self.words.shuffled()
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
        }
    }
    
    func displayCurrentWord(index: Int) {
        let translation = words[index].translation
        let word = words[index].word
        
        firstLbl.text = words[index].translation
        
        firstLblTextField.text = translation
        secondLblTextField.text = word
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
    
    
    func nextWord() {
        if defaults.bool(forKey: "looped") && self.indexCounter == (self.words.count - 1) {
            self.secondLbl.text = ""
            self.textField.text = ""
            self.indexCounter = 0
            self.setDefaultAnswerTextFieldView()
            self.displayCurrentWord(index: indexCounter)
            self.setQuantity(index: indexCounter)
            self.setMarkBtnView()
        } else {
            if self.indexCounter < (self.words.count - 1){
                self.secondLbl.text = ""
                self.textField.text = ""
                self.setDefaultAnswerTextFieldView()
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
            self.textField.text = ""
            self.setDefaultAnswerTextFieldView()
            self.indexCounter = self.words.count - 1
            self.displayCurrentWord(index: indexCounter)
            self.setQuantity(index: indexCounter)
            self.setMarkBtnView()
        } else {
            if self.indexCounter > 0 {
                self.secondLbl.text = ""
                self.textField.text = ""
                self.setDefaultAnswerTextFieldView()
                self.indexCounter -= 1
                self.displayCurrentWord(index: indexCounter)
                self.setQuantity(index: indexCounter)
                self.setMarkBtnView()
            }
        }
    }
    
    
    func setMarkBtnView() {
        if words[indexCounter].repeatSpell {
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


extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}


