//
//  EditDeckVC.swift
//  Vocabularity
//
//  Created by Admin on 10.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData
//let appDelegate = UIApplication.shared.delegate as? AppDelegate

class EditDeckVC: UIViewController {

    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionBtnsView: UIView!
    
    
    //Variables
    var folder: Folder!
    var part: Int!
    var wordsAtTime: Int = 25
    var words: [Word] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        actionBtnsView.bindToKeyboard()
        
        self.tableView.estimatedRowHeight = 69.0
        
        updateView()
    }

    
    //Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //Functions
    func updateView() {
        if defaults.integer(forKey: "wordsAtTime") != 0 {
            self.wordsAtTime = defaults.integer(forKey: "wordsAtTime")
        }
        self.fetchCoreDataObjects(folder: folder, part: part)
        tableView.reloadData()
    }
    
    func fetchCoreDataObjects(folder: Folder!, part: Int!) {
        self.fetch(folder: folder, part: part) { (complete) in } }
    
    func fetch (folder: Folder!, part: Int!, completion: (_ complete: Bool) -> ()) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchREquest = NSFetchRequest<Word>(entityName: "Word")
        fetchREquest.predicate = NSPredicate(format: "folder == %@", folder!)
        fetchREquest.fetchOffset = part * self.wordsAtTime
        fetchREquest.fetchLimit = self.wordsAtTime
        
        do {
            words = try managedContext.fetch(fetchREquest)
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    
    
}

extension EditDeckVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "editDeckCell") as? EditDeckCell else { return UITableViewCell() }
        
        let word = words[indexPath.row]
        cell.configureCell(word: word, counter: (indexPath.row + 1))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension EditDeckVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        let startHeight = textView.frame.size.height
        let calcHeight = textView.sizeThatFits(textView.frame.size).height  //iOS 8+ only
        
        if startHeight != calcHeight {
            
            UIView.setAnimationsEnabled(false) // Disable animations
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            // Might need to insert additional stuff here if scrolls
            // table in an unexpected way.  This scrolls to the bottom
            // of the table. (Though you might need something more
            // complicated if editing in the middle.)
            
            let scrollTo = self.tableView.contentSize.height - self.tableView.frame.size.height
            self.tableView.setContentOffset(CGPoint(x: 0, y: scrollTo), animated: false)
            
            UIView.setAnimationsEnabled(true)  // Re-enable animations.
        }
    }
}



