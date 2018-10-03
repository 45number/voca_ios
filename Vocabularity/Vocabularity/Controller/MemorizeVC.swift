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
    
    
    //Variables
    var folder: Folder!
    var part: Int!
    
    var words: [Word] = []
    
    private var indexCounter: Int = 0
    private var mCardSwitcher: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(MemorizeVC.onCardTap(_:)))
//        tap.delegate = self // This is not required
//        cardView.addGestureRecognizer(tap)
        
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(MemorizeVC.onCardTap(_:)))
        cardView.addGestureRecognizer(cardTap)
        
        
        self.fetchCoreDataObjects(folder: folder, part: part)
//        print(self.words.count)
        self.displayCurrentWord(index: indexCounter)
        self.setQuantity(index: indexCounter)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func speakBtnPressed(_ sender: Any) {
        
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
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    @objc func onCardTap(_ recognizer: UITapGestureRecognizer) {
        if !mCardSwitcher {
            self.translate(index: indexCounter)
            self.speak(phrase: words[indexCounter].word)
            
        } else {
            if self.indexCounter < (self.words.count - 1){
                self.secondLbl.text = ""
                self.indexCounter += 1
                self.displayCurrentWord(index: indexCounter)
                self.setQuantity(index: indexCounter)
            } else {
                print("opa")
            }
        }
        mCardSwitcher = !mCardSwitcher
    }
    
}
