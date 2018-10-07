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

class FoldersVC: UIViewController {
    
    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    
    //Variables
    var folders: [Folder] = []
    var path: [Folder] = []
    
    var decks: [Deck] = []
    
    var wordsAtTime: Int = 25
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsVC.wordsAtTimeDidChange(_:)), name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
        
        updateView()
        
        let barItem1 = UITabBarItem(title: "English", image: nil, selectedImage: nil)
        let barItem2 = UITabBarItem(title: "Russian", image: nil, selectedImage: nil)
        let tabBarList = [barItem1, barItem2]
        
        self.tabBar.setItems(tabBarList, animated: true )
        self.tabBar.selectedItem = self.tabBar.items?[1]
    }
    
    func updateView() {
        if defaults.integer(forKey: "wordsAtTime") != 0 {
            self.wordsAtTime = defaults.integer(forKey: "wordsAtTime")
        }
        
        fetchCoreDataObjects(parent: getCurrentFolder())
        tableView.reloadData()
    }
    
    func fetchCoreDataObjects(parent: Folder?) {
        self.fetch(parent: parent) { (complete) in
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
        self.fetchCoreDataObjects(parent: self.getCurrentFolder())
        self.tableView.reloadData() 
    }
    
    @IBAction func dotsBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: TO_SETTINGS, sender: nil)
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CreateFolderVC {
            vc.parentFolder = self.getCurrentFolder()
        }
        
        if let vc = segue.destination as? CreateWordVC {
            vc.parentFolder = self.getCurrentFolder()
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
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let addAction = UITableViewRowAction(style: .normal, title: "EDIT") { (rowAction, indexPath) in
            self.editFolder(atIndexPath: indexPath)
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
            self.fetchCoreDataObjects(parent: self.getCurrentFolder())
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
    }
    
    func fetch(parent: Folder?, completion: (_ complete: Bool) -> ()) {
        
        self.decks.removeAll()
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchREquest = NSFetchRequest<Folder>(entityName: "Folder")
        
        if parent == nil {
            fetchREquest.predicate = NSPredicate(format: "parent == nil")
        } else {
//            print(parent as? Any)
            fetchREquest.predicate = NSPredicate(format: "parent == %@", parent!)
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
