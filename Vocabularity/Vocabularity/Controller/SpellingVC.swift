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
    
    //Outlets
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var speakBtn: UIButton!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var circleBtn: UIButton!
    @IBOutlet weak var markBtn: UIButton!
    
    
    
    
    //Variables
    let defaults = UserDefaults.standard
    var folder: Folder!
    var part: Int!
    
    var words: [Word] = []
    
    private var indexCounter: Int = 0
    private var mCardSwitcher: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self
        
        speakBtn.setImage(UIImage(named: "speaking"), for:.normal);
        speakBtn.setImage(UIImage(named: "speaking_pressed"), for:.highlighted);
        
        self.fetchCoreDataObjects(folder: folder, part: part)
        self.displayCurrentWord(index: indexCounter)
        self.setQuantity(index: indexCounter)
        
        setMarkBtnView()
        setCircleBtnView()
        setShuffleBtnView()
    }
    
    
    //Actions
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func speakBtnPressed(_ sender: Any) {
        speak(phrase: words[indexCounter].word)
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
        
    }
    
    
    //Functions
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField code
        
        //        textField.resignFirstResponder()  //if desired
        performAction()
        return true
    }
    
    func performAction() {
        //        print("return pressed")
        let userWordUntrimmed = textField.text
        let userWord = userWordUntrimmed?.trimmingCharacters(in: .whitespacesAndNewlines)
        //        print(userWordUntrimmed ?? "default")
        //        print(userWord ?? "default")
        if userWord != "" {
            speak(phrase: words[indexCounter].word)
            let userWordsArray = userWord?.lowercased().components(separatedBy: " ")
            let rightWordsArray = words[indexCounter].word?.lowercased().components(separatedBy: " ")
            
            var wrongWords = userWordsArray?.filter{ item in !(rightWordsArray?.contains(item))! }
            
//            print(wrongWords)
            
            var afterArray: [String] = []
            for word in userWordsArray! {
                
                var isWrong = false
                
                if wrongWords?.count != 0 {
                    for wrongWord in wrongWords! {
                        if word == wrongWord {
                            let string = "[[ \(word) ]]"
                            afterArray.append(string)
                            isWrong = true
                            wrongWords?.removeFirst()
                            break
                        }
                    }
                }
                
                if isWrong == false {
                    afterArray.append(word)
                }
            }
            print(afterArray)
            
            
            /*
            var indicesOfWrongWords: [[Int]] = []
            for word in wrongWords! {
                
                for (userWord1Index, userWord1) in (userWordsArray?.enumerated())! {
                    if word == userWord1 {
                        
                    }
                }
                
//                indicesOfWrongWords.append( (userWordsArray?.indexes(of: word))! )
                break
            }
            
            print(indicesOfWrongWords)
            
            var userWordsAfter: [String] = []
            for (wordIndex, word) in (userWordsArray?.enumerated())! {
                for indexes in indicesOfWrongWords {
                    for index in indexes {
                        if wordIndex == index {
                            let word1 = "ll \(word) ll"
                            userWordsAfter.append(word1)
                            
                        } else {
                            userWordsAfter.append(word)
                            
                        }
                    }
                }
            }
            print (userWordsAfter)
            */
            
            
            //            let stringText = "Test String"
            //            let stringCount = stringText.count
            //            let string: NSMutableAttributedString = NSMutableAttributedString(string: stringText)
            //
            //            string.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.red, range: NSMakeRange(0, 6))
            //            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(0, 6))
            //            self.textField.attributedText =  string
            //            textView.attributedText = attribString
            
            let attribWords = getAttributedStrings(text: "Java")
            let attribString = NSMutableAttributedString()
            attribWords.forEach{
                attribString.append(NSAttributedString(string: "  "))
                attribString.append($0)
            }
            self.textField.attributedText =  attribString
            
            
            
        }
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
    
    
    //    func matches(for regex: String, in text: String) -> [String] {
    //
    //        do {
    //            let regex = try NSRegularExpression(pattern: regex)
    //            let results = regex.matches(in: text,
    //                                        range: NSRange(text.startIndex..., in: text))
    //            return results.map {
    //                String(text[Range($0.range, in: text)!])
    //            }
    //        } catch let error {
    //            print("invalid regex: \(error.localizedDescription)")
    //            return []
    //        }
    //    }
    
    
    func fetchCoreDataObjects(folder: Folder!, part: Int!) {
        self.fetch(folder: folder, part: part) { (complete) in
            if complete {
                
                if defaults.bool(forKey: "shuffled") {
                    shuffleWords()
                }
                
            }
        }
    }
    
    func fetch (folder: Folder!, part: Int!, completion: (_ complete: Bool) -> ()) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchREquest = NSFetchRequest<Word>(entityName: "Word")
        fetchREquest.predicate = NSPredicate(format: "folder == %@", folder!)
        fetchREquest.fetchOffset = part * 5
        fetchREquest.fetchLimit = 5
        
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
    
    func speak(phrase: String!) {
        DispatchQueue.global(qos: .background).async {
            let utterance = AVSpeechUtterance(string: phrase)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        }
    }
    
    func displayCurrentWord(index: Int) {
        if !defaults.bool(forKey: "directionReversed") {
            firstLbl.text = words[index].translation
        } else {
            firstLbl.text = words[index].word
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

