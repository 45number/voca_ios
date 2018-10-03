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

class MemorizeVC: UIViewController {

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
    
    
    //Variables
    var folder: Folder!
    var part: Int!
    
    var words: [Word] = []
    
    private var indexCounter: Int = 0
    private var mCardSwitcher: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        speakBtn.setImage(UIImage(named: "speaking"), for:.normal);
        speakBtn.setImage(UIImage(named: "speaking_pressed"), for:.highlighted);
        
        
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(MemorizeVC.onCardTap(_:)))
//        tap.delegate = self // This is not required
//        cardView.addGestureRecognizer(tap)
        
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(MemorizeVC.onCardTap(_:)))
        cardView.addGestureRecognizer(cardTap)
        
        
        self.fetchCoreDataObjects(folder: folder, part: part)
//        print(self.words.count)
        self.displayCurrentWord(index: indexCounter)
        self.setQuantity(index: indexCounter)
        
        setMarkBtnView()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func speakBtnPressed(_ sender: Any) {
        speak(phrase: words[indexCounter].word)
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
//        words[indexCounter].repeatMem = !words[indexCounter].repeatMem
        
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
    }
    
    @IBAction func shuffleBtnPressed(_ sender: Any) {
    }
    
    @IBAction func circleBtnPressed(_ sender: Any) {
    }
    
    @IBAction func directionBtnPressed(_ sender: Any) {
    }
    
    
    
    
    //Functions
    func fetchCoreDataObjects(folder: Folder!, part: Int!) {
        self.fetch(folder: folder, part: part) { (complete) in
            if complete {
                
                print("ok")
                
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
    
    func markWord(toRepeat: Bool) {
        
    }
    
    func displayCurrentWord(index: Int) {
        print(index)
        firstLbl.text = words[index].translation
    }
    
    func translate(index: Int) {
        secondLbl.text = words[index].word
    }
    
    func setQuantity(index: Int) {
        quantityLbl.text = "\(index + 1) / \(words.count)"
    }
    
    func speak(phrase: String!) {
        
        DispatchQueue.global(qos: .background).async {
//            print("This is run on the background queue")
            
            let utterance = AVSpeechUtterance(string: phrase)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
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
            self.speak(phrase: words[indexCounter].word)
            
        } else {
            self.nextWord()
        }
        mCardSwitcher = !mCardSwitcher
    }
    
    func nextWord() {
        if self.indexCounter < (self.words.count - 1){
            self.secondLbl.text = ""
            self.indexCounter += 1
            self.displayCurrentWord(index: indexCounter)
            self.setQuantity(index: indexCounter)
            self.setMarkBtnView()
        }
    }
    
    func previousWord() {
        if self.indexCounter > 0 {
            self.secondLbl.text = ""
            self.indexCounter -= 1
            self.displayCurrentWord(index: indexCounter)
            self.setQuantity(index: indexCounter)
            self.setMarkBtnView()
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
    
}
