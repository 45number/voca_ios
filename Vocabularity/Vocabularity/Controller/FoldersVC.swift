//
//  ViewController.swift
//  Vocabularity
//
//  Created by Admin on 25.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class FoldersVC: UIViewController, UITabBarDelegate {
    
    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    //Variables
    var folders: [Folder] = []
    var path: [Folder] = []
    
    var decks: [Deck] = []
    
    var wordsAtTime: Int = 25
    
    
    var treeArray:[Folder] = []
    
//    var currentLearningLanguage: Int
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tabBar.delegate = self
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FoldersVC.wordsAtTimeDidChange(_:)), name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FoldersVC.languagesChanged(_:)), name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
        
        
        defaults.set(true, forKey: "english")
        
        getCurrentLearningLanguage()
        let learningLanguages = getLearningLanguages()
        setTabView(learningLanguages: learningLanguages)
        
        updateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getCurrentLearningLanguage() {
        let learningLanguages = getLearningLanguages()
        if defaults.integer(forKey: "currentLearningLanguage") == 0 {
            defaults.set(learningLanguages[0].tag, forKey: "currentLearningLanguage")
        }
        let isInRange = isCurrentLangInRange(learningLanguages: learningLanguages)
        if !isInRange {
            defaults.set(learningLanguages[0].tag, forKey: "currentLearningLanguage")
        }
    }
    
    private func isCurrentLangInRange(learningLanguages: [LearningLanguage]) -> Bool {
        for lang in learningLanguages {
            if lang.tag == defaults.integer(forKey: "currentLearningLanguage") {
                return true
            }
        }
        return false
    }
    
    func updateView() {
        if defaults.integer(forKey: "wordsAtTime") != 0 {
            self.wordsAtTime = defaults.integer(forKey: "wordsAtTime")
        }
        
        fetchCoreDataObjects(learningLanguage: defaults.integer(forKey: "currentLearningLanguage"), parent: getCurrentFolder())
        tableView.reloadData()
    }
    
    func setTabView(learningLanguages: [LearningLanguage]) {
        if learningLanguages.count < 2 {
            hideTabBar()
        } else {
            showTabBar()
            var tabBarList: [UITabBarItem] = []
            
            var currentLangPosition = 0
            for (index, lang) in learningLanguages.enumerated() {
                tabBarList.append(UITabBarItem(title: lang.name, image: lang.image, tag: lang.tag))
                if lang.tag == defaults.integer(forKey: "currentLearningLanguage") {
                    currentLangPosition = index
                }
            }
            
            self.tabBar.setItems(tabBarList, animated: true)
            
            
            
//            print("first \(defaults.integer(forKey: "currentLearningLanguage") - 1)")
            self.tabBar.selectedItem = self.tabBar.items?[currentLangPosition ]
            
//            print("secont \(self.tabBar.items?[defaults.integer(forKey: "currentLearningLanguage") - 1].tag)")
        }
        
//        let barItem1 = UITabBarItem(title: "English", image: nil, selectedImage: nil)
//        let barItem2 = UITabBarItem(title: "Russian", image: nil, selectedImage: nil)
//
//        barItem1.tag = 0
//        barItem2.tag = 1
//        let tabBarList = [barItem1, barItem2]
//
//        self.tabBar.setItems(tabBarList, animated: true )
//        self.tabBar.selectedItem = self.tabBar.items?[0]
    }
    
    func hideTabBar() {
        tabBar.isHidden = true
        tableViewBottomConstraint.constant = 0
        tableView.layoutIfNeeded()
    }
    
    func showTabBar() {
        tabBar.isHidden = false
        tableViewBottomConstraint.constant = 50
        tableView.layoutIfNeeded()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        self.currentLearningLanguage = item.tag
        defaults.set(item.tag, forKey: "currentLearningLanguage")
//        var path: [Folder] = []
        self.path.removeAll()
        updateView()
        
//        if(item.tag == 1) {
//            self.currentLearningLanguage = item.tag
//        } else if(item.tag == 2) {
//            self.currentLearningLanguage = item.tag
//        } else if(item.tag == 3) {
//            self.currentLearningLanguage = item.tag
//        }
    }
    
    @objc func languagesChanged(_ notif: Notification) {
        let learningLanguages = getLearningLanguages()
        getCurrentLearningLanguage()
        updateView()
        setTabView(learningLanguages: learningLanguages)
    }
    
    func getLearningLanguages() -> [LearningLanguage] {
        var learningLanguages: [LearningLanguage] = []
        if defaults.bool(forKey: "english") {
            learningLanguages.append(LearningLanguage(name: "English", tag: 1, image: nil, selectedImage: nil))
        }
        if defaults.bool(forKey: "russian") {
            learningLanguages.append(LearningLanguage(name: "Russian", tag: 2, image: nil, selectedImage: nil))
        }
        if defaults.bool(forKey: "arabic") {
            learningLanguages.append(LearningLanguage(name: "Arabic", tag: 3, image: nil, selectedImage: nil))
        }
        return learningLanguages
    }
    
    func fetchCoreDataObjects(learningLanguage: Int, parent: Folder?) {
        self.fetch(learningLanguage: learningLanguage, parent: parent) { (complete) in
            if complete {
                if folders.count >= 1 || decks.count > 0 {
                    tableView.isHidden = false
                } else {
                    tableView.isHidden = true
                }
                
                if path.count > 0 {
                    self.backBtn.isHidden = false
                } else {
                    self.backBtn.isHidden = true
                }
                
            }
        }
    }
    
    //Actions
    @IBAction func addBtnPressed(_ sender: Any) {
        
        if path.count == 0 || folders.count > 0 {
            performSegue(withIdentifier: TO_CREATE_FOLDER, sender: nil)
        } else if decks.count > 0 {
            performSegue(withIdentifier: TO_CREATE_WORD, sender: nil)
        } else {
            
            let alert = UIAlertController(title: "Add", message: "What to add:", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Folder", style: .default, handler: { action in
                self.performSegue(withIdentifier: TO_CREATE_FOLDER, sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "Word", style: .default, handler: { action in
                self.performSegue(withIdentifier: TO_CREATE_WORD, sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
            
        }

    }
    @IBAction func backBtnPressed(_ sender: Any) {
        self.path.removeLast()
        self.fetchCoreDataObjects(learningLanguage: defaults.integer(forKey: "currentLearningLanguage"), parent: self.getCurrentFolder())
        self.tableView.reloadData() 
    }
    
    @IBAction func dotsBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: TO_SETTINGS, sender: nil)
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CreateFolderVC {
            vc.parentFolder = self.getCurrentFolder()
//            vc.learningLanguage = self.currentLearningLanguage
//            defaults.set(learningLanguages[0].tag, forKey: "currentLearningLanguage")
            vc.learningLanguage = defaults.integer(forKey: "currentLearningLanguage")
        }
        
        if let vc = segue.destination as? CreateWordVC {
            vc.parentFolder = self.getCurrentFolder()
//            vc.learningLanguage = self.currentLearningLanguage
            vc.learningLanguage = defaults.integer(forKey: "currentLearningLanguage")
        }
        
    }
    
    // Path functions
    func getCurrentFolder() -> Folder? {
        let arraySlice = self.path.suffix(1)
        let newArray = Array(arraySlice)
        var currentFolder: Folder?
        if newArray.count > 0 {
            currentFolder = newArray[0]
        } else {
            currentFolder = nil
        }
        return currentFolder
    }
    func pushToPath(folder: Folder) {
        self.path.append(folder)
    }
}

extension FoldersVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if folders.count > 0 {
            return folders.count
        } else if decks.count > 0 {
            return decks.count
        }
        
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell") as? FolderCell else { return UITableViewCell() }
        
        if folders.count > 0 {
            let folder = folders[indexPath.row]
            cell.configureCell(folder: folder)
        } else if decks.count > 0 {
            let deck = decks[indexPath.row]
            cell.configureCellForDeck(deck: deck)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            self.removeFolder(atIndexPath: indexPath)
//            self.fetchCoreDataObjects()
//            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let addAction = UITableViewRowAction(style: .normal, title: "EDIT") { (rowAction, indexPath) in
//            self.editFolder(atIndexPath: indexPath)
//            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        addAction.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.662745098, blue: 0.2666666667, alpha: 1)
        
        return [deleteAction, addAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
//        managedContext.ge
//        print(folders[indexPath.row].objectID)
//        print(indexPath.row)
//        print("hello \(indexPath.row) hello")
        
        if folders.count > 0 {
            self.pushToPath(folder: folders[indexPath.row])
            self.fetchCoreDataObjects(learningLanguage: defaults.integer(forKey: "currentLearningLanguage"), parent: self.getCurrentFolder())
            self.tableView.reloadData()
        } else if decks.count > 0 {
            
            //getting the index path of selected row
//            let indexPath = tableView.indexPathForSelectedRow
            
            //getting the current cell from the index path
//            let currentCell = tableView.cellForRow(at: indexPath)! as! FolderCell
            
            //getting the text of that cell
//            let currentItem = currentCell.folderNameLbl.text
            
            let alertController = UIAlertController(title: "Choose the mode", message: "Excercise mode ", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Memorize", style: .default, handler: { action in
                let memorizeVC = MemorizeVC()
                memorizeVC.folder = self.getCurrentFolder()
                memorizeVC.part = indexPath.row
                memorizeVC.modalPresentationStyle = .custom
                self.present(memorizeVC, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Spelling", style: .default, handler: { action in
                let spellingVC = SpellingVC()
                spellingVC.folder = self.getCurrentFolder()
                spellingVC.part = indexPath.row
                spellingVC.modalPresentationStyle = .custom
                self.present(spellingVC, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (success) in
//                self.tableView.deselectRow(at: indexPath, animated: false)
//            }))
            
            present(alertController, animated: true, completion: nil)
            self.tableView.deselectRow(at: indexPath, animated: false)
//            print("opa")
        }
        
        
//        self.currentFolder = folders[indexPath.row]
//        self.fetchCoreDataObjects(parent: self.getCurrentFolder)

    }
    
    @objc func wordsAtTimeDidChange(_ notif: Notification) {
        updateView()
    }
    
    
    
}


extension FoldersVC {
    
    func editFolder(atIndexPath indexPath: IndexPath) {
//        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
//        let chosenFolder = folders[indexPath.row]
        
//        if chosenFolder.goalProgress < chosenGoal.goalCompletionValue {
//            chosenGoal.goalProgress = chosenGoal.goalProgress + 1
//        } else {
//            return
//        }
//
//        do {
//            try managedContext.save()
//            print("Successfully set progress")
//        } catch {
//            debugPrint("Could not set progress: \(error.localizedDescription)")
//        }
    }
    
    
    
    func removeFolder(atIndexPath indexPath: IndexPath) {
//        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
//
//        managedContext.delete(goals[indexPath.row])
//
//        do {
//            try managedContext.save()
//            print("Successfully removed goal")
//        } catch {
//            debugPrint("Could not remove: \(error.localizedDescription)")
//        }
//        var treeArray:[Folder] = []
        buildTreeArray(folder: folders[indexPath.row])
        navigateThroughTree(treeArray: self.treeArray)
//        print(self.treeArray)
    }
    
    func buildTreeArray(folder: Folder) {
        self.treeArray.append(folder)
        for child in folder.children! {
            buildTreeArray(folder: child as! Folder)
        }
    }
    
    func navigateThroughTree(treeArray: [Folder]) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        for folder in treeArray {
            folder.image = "default.png"
            do {
                try managedContext.save()
                print("Successfully set progress")
            } catch {
                debugPrint("Could not set progress: \(error.localizedDescription)")
            }
        }
    }
    
    func fetch(learningLanguage: Int, parent: Folder?, completion: (_ complete: Bool) -> ()) {
        
        self.decks.removeAll()
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchREquest = NSFetchRequest<Folder>(entityName: "Folder")
        
        if parent == nil {
//            fetchREquest.predicate = NSPredicate(format: "parent == nil")
//            fetchREquest.predicate = NSPredicate(format: "learningLang == \(learningLanguage)")
            
            let parentPredicate = NSPredicate(format: "parent == nil")
            let learningLanguagePredicate = NSPredicate(format: "learningLang == \(learningLanguage)")
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [parentPredicate, learningLanguagePredicate])
            fetchREquest.predicate = andPredicate
        } else {
//            print(parent as? Any)
            fetchREquest.predicate = NSPredicate(format: "parent == %@", parent!)
//            fetchREquest.predicate = NSPredicate(format: "learningLang == \(learningLanguage)")
        }
        
        
        do {
            folders = try managedContext.fetch(fetchREquest)
            print("Successfully fetched data")
            
            if folders.count == 0 && parent != nil {
                let fetchWordRequest = NSFetchRequest<Word>(entityName: "Word")
                fetchWordRequest.predicate = NSPredicate(format: "folder == %@", parent!)
                let words = try managedContext.fetch(fetchWordRequest)
                print(words.count)
                if words.count > 0 {
//                    let decksQuantity = Int(ceil(Double(words.count/5)))
                    
                    let decksQuantity = Int(ceil(Double(words.count)/Double(self.wordsAtTime)))
                    print(decksQuantity)
                    for index in 1...decksQuantity {
                        let deck = Deck(title: "Deck \(index)", info: "\(self.wordsAtTime) words in deck")
//                        if defaults.integer(forKey: "wordsAtTime") != 0 {
//                            wordsAmountBtn.setTitle(String(defaults.integer(forKey: "wordsAtTime")), for: UIControlState.normal)
//                        }
                        self.decks.append(deck)
                    }
                }
            }
            
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
}


