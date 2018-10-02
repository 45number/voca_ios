//
//  MemorizeVC.swift
//  Vocabularity
//
//  Created by Admin on 02.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData

class MemorizeVC: UIViewController {

    //Outlets
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    
    //Variables
    var folder: Folder!
    var part: Int!
    
    var words: [Word] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        print(part)
        self.fetchCoreDataObjects(folder: folder, part: part)
        print(self.words.count)
        self.displayCurrentWord(index: 0)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        firstLbl.text = words[index].word
        secondLbl.text = words[index].translation
    }
    
}
