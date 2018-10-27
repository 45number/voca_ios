//
//  ViewController.swift
//  Vocabularity
//
//  Created by Admin on 25.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData
import XlsxReaderWriter

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class FoldersVC: UIViewController, UITabBarDelegate {
    
    let defaults = UserDefaults.standard
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var repeatBtn: RoundedButton!
    @IBOutlet weak var repeatBtnBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var uploadingViewWrapper: UIView!
    @IBOutlet weak var uploadingView: RoundShadowView!
    
    
    
    
    //Variables
    var folders: [Folder] = []
    var path: [Folder] = []
    
    var decks: [Deck] = []
    
    var wordsAtTime: Int = 25
    
    
    var treeArray:[Folder] = []
    
    
    var toMemWords = 0
    var toSpellWords = 0
    
//    var currentLearningLanguage: Int
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tabBar.delegate = self
        
        uploadingView.isHidden = true
        uploadingViewWrapper.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(FoldersVC.wordsAtTimeDidChange(_:)), name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FoldersVC.languagesChanged(_:)), name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FoldersVC.wordsWereMarked(_:)), name: NOTIF_WORD_WAS_MARKED, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FoldersVC.excelTutorialShowed(_:)), name: NOTIF_EXCEL_TUTORIAL_SHOWED, object: nil)
        
//        defaults.set(true, forKey: "english")wordsWereMarked
        
        getCurrentLearningLanguage()
        let learningLanguages = getLearningLanguages()
        setTabView(learningLanguages: learningLanguages)
        
        updateView()
        
//        defaults.set(false, forKey: "excelTutorialShowed")
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
        setRepeatButton()
    }
    
    func setRepeatButton() {
        let quantityMem = countRepeatedWords(mode: "repeatMem")
        let quantitySpell = countRepeatedWords(mode: "repeatSpell")
        if quantityMem != nil && quantitySpell != nil {
            
            self.toMemWords = quantityMem!
            self.toSpellWords = quantitySpell!
            
            if quantityMem != 0 || quantitySpell != 0 {
                self.repeatBtn.isHidden = false
            } else {
                self.repeatBtn.isHidden = true
            }
            
        }
    
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
            self.tabBar.selectedItem = self.tabBar.items?[currentLangPosition ]
        }
    }
    
    func hideTabBar() {
        tabBar.isHidden = true
        tableViewBottomConstraint.constant = 0
        tableView.layoutIfNeeded()
        
        repeatBtnBottomConstraint.constant = 30
        repeatBtn.layoutIfNeeded()
    }
    
    func showTabBar() {
        tabBar.isHidden = false
        tableViewBottomConstraint.constant = 50
        tableView.layoutIfNeeded()
        
        repeatBtnBottomConstraint.constant = 80
        repeatBtn.layoutIfNeeded()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        defaults.set(item.tag, forKey: "currentLearningLanguage")
        self.path.removeAll()
        updateView()
    }
    
    @objc func languagesChanged(_ notif: Notification) {
        let learningLanguages = getLearningLanguages()
        getCurrentLearningLanguage()
        updateView()
        setTabView(learningLanguages: learningLanguages)
    }
    
    @objc func wordsWereMarked(_ notif: Notification) {
        setRepeatButton()
    }
    
    @objc func excelTutorialShowed(_ notif: Notification) {
        uploadExcelControllerPresent()
    }
    
    func getLearningLanguages() -> [LearningLanguage] {
        var learningLanguages: [LearningLanguage] = []
        if defaults.bool(forKey: "english") {
            learningLanguages.append(LearningLanguage(name: NSLocalizedString("english", comment: "English"), tag: 1, image: UIImage(named: "english"), selectedImage: nil))
        }
        if defaults.bool(forKey: "russian") {
            learningLanguages.append(LearningLanguage(name: NSLocalizedString("russian", comment: "Russian"), tag: 2, image: UIImage(named: "russian"), selectedImage: nil))
        }
        if defaults.bool(forKey: "arabic") {
            learningLanguages.append(LearningLanguage(name: NSLocalizedString("arabic", comment: "Arabic"), tag: 3, image: UIImage(named: "arabic"), selectedImage: nil))
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
               
                var pathString: String = "Main"
                
                if path.count > 0 {
                    self.backBtn.isHidden = false
                    for folder in path {
                        pathString += "/" + folder.folderName!
                    }
                } else {
                    self.backBtn.isHidden = true
                }
                print(pathString)
            }
        }
    }
    
    //Actions
    @IBAction func addBtnPressed(_ sender: Any) {
        addAlert()
    }
    
    @IBAction func createBtnPressed(_ sender: Any) {
        addAlert()
    }
    
    
    func addAlert() {
        let alert = UIAlertController(title: NSLocalizedString("add", comment: "Add"), message: NSLocalizedString("whatToAdd", comment: "What to add:"), preferredStyle: UIAlertControllerStyle.alert)
        
        let addFolderTitle: String = NSLocalizedString("addFolder", comment: "Add folder")
        let addFolder = UIAlertAction(title: addFolderTitle, style: .default, handler: { action in
            self.performSegue(withIdentifier: TO_CREATE_FOLDER, sender: nil)
        })
        
        let addWords = UIAlertAction(title: NSLocalizedString("addWords", comment: "Add words"), style: .default, handler: { action in
            self.performSegue(withIdentifier: TO_CREATE_WORD, sender: nil)
        })
        
        let uploadExcel = UIAlertAction(title: NSLocalizedString("uploadExcelFile", comment: "Upload excel file"), style: .default, handler: { action in
            
            if self.defaults.bool(forKey: "excelTutorialShowed") {
                self.uploadExcelControllerPresent()
            } else {
                self.showExcelTutorial()
            }
            
        })
        
//        let opa = UIAlertAction(title: "opa", style: .default) { (action) in
//
//        }
        
        alert.addAction(addFolder)
        alert.addAction(addWords)
        alert.addAction(uploadExcel)
//        alert.addAction(opa)
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel, handler: { action in }))
        
        if path.count == 0 || folders.count > 0 {
            addFolder.isEnabled = true
            addWords.isEnabled = false
            uploadExcel.isEnabled = false
        } else if decks.count > 0 {
            addFolder.isEnabled = false
            addWords.isEnabled = true
            uploadExcel.isEnabled = true
        } else {
            addFolder.isEnabled = true
            addWords.isEnabled = true
            uploadExcel.isEnabled = true
        }
        
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadExcelControllerPresent() {
        self.uploadingView.isHidden = false
        self.uploadingViewWrapper.isHidden = false
        
        let docTypes = [
            //            "com.microsoft.excel.xls",
            "org.openxmlformats.spreadsheetml.sheet"
        ]
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
        
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func showExcelTutorial() {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "TutorialExcel") as! TutorialExcel
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.path.removeLast()
        self.fetchCoreDataObjects(learningLanguage: defaults.integer(forKey: "currentLearningLanguage"), parent: self.getCurrentFolder())
        self.tableView.reloadData() 
    }
    
    @IBAction func dotsBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: TO_SETTINGS, sender: nil)
    }
    
    @IBAction func repeatBtnPressed(_ sender: Any) {
        
        let alertController = UIAlertController(title: STRING_CHOOSE_THE_MODE, message: STRING_EXCERCISE_MODE, preferredStyle: .alert)
        
        
        let memorizeAction = UIAlertAction(title: STRING_MEMORIZE, style: .default, handler: { action in
                        let memorizeVC = MemorizeVC()
                        memorizeVC.folder = nil
                        memorizeVC.part = nil
                        memorizeVC.modalPresentationStyle = .custom
                        self.present(memorizeVC, animated: true, completion: nil)
        })
        
        let spellingAction = UIAlertAction(title: STRING_SPELLING, style: .default, handler: { action in
                        let spellingVC = SpellingVC()
                        spellingVC.folder = nil
                        spellingVC.part = nil
                        spellingVC.modalPresentationStyle = .custom
                        self.present(spellingVC, animated: true, completion: nil)
        })
        
        alertController.addAction(memorizeAction)
        alertController.addAction(spellingAction)
        
        if self.toMemWords > 0 {
            memorizeAction.isEnabled = true
        } else {
            memorizeAction.isEnabled = false
        }
        
        if self.toSpellWords > 0 {
            spellingAction.isEnabled = true
        } else {
            spellingAction.isEnabled = false
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CreateFolderVC {
            vc.parentFolder = self.getCurrentFolder()
//            vc.learningLanguage = self.currentLearningLanguage
//            defaults.set(learningLanguages[0].tag, forKey: "currentLearningLanguage")
            vc.learningLanguage = defaults.integer(forKey: "currentLearningLanguage")
            
            if sender != nil {
                vc.editingFolder = sender as? Folder
            }
            
        }
        
        if let vc = segue.destination as? CreateWordVC {
            vc.parentFolder = self.getCurrentFolder()
//            vc.learningLanguage = self.currentLearningLanguage
            vc.learningLanguage = defaults.integer(forKey: "currentLearningLanguage")
        }
        
        if let vc = segue.destination as? EditDeckVC {
            vc.folder = self.getCurrentFolder()
            vc.part = sender as? Int
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
    
    
    
//    func countDescendantFolders() {
//        buildTreeArray(folder: folders[indexPath.row])
//        navigateThroughTree(treeArray: self.treeArray)
//    }
//    
    
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
            
            self.treeArray.removeAll()
            buildTreeArray(folder: folders[indexPath.row])
            let (decksQuantitiy, wordsQuantity) = countWordsInTree(treeArray: self.treeArray)
            
//            navigateThroughTree(treeArray: self.treeArray)
            
            cell.configureCell(folder: folder, folderInfo: "\(NSLocalizedString("folders", comment: "Folders")): \(self.treeArray.count - 1) : : \(NSLocalizedString("decks", comment: "Decks")): \(decksQuantitiy) : : \(NSLocalizedString("cards", comment: "Cards")): \(wordsQuantity)")
            
//            cell.configureCell(folder: folder, folderInfo: folder.image!)
            
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
        let deleteAction = UITableViewRowAction(style: .destructive, title: STRING_DELETE_OPTION) { (rowAction, indexPath) in
            if self.folders.count > 0 {
                let alert = UIAlertController(title: STRING_DELETE_FOLDER, message: STRING_ARE_YOU_SURE, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: STRING_CANCEL, style: .default, handler: { action in }))
                alert.addAction(UIAlertAction(title: STRING_OK, style: .destructive, handler: { action in
                    
                    self.removeFolder(atIndexPath: indexPath)
                    self.updateView()
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                
                let alert = UIAlertController(title: STRING_DELETE_DECK, message: STRING_ARE_YOU_SURE, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: STRING_CANCEL, style: .default, handler: { action in }))
                alert.addAction(UIAlertAction(title: STRING_OK, style: .destructive, handler: { action in
                    self.removeDeck(atIndexPath: indexPath)
                    self.updateView()
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
//            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let addAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("edit", comment: "EDIT")) { (rowAction, indexPath) in
            if self.folders.count > 0 {
                self.editFolder(atIndexPath: indexPath)
            } else {
                self.editDeck(atIndexPath: indexPath)
            }
            
//            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        var markTitle = STRING_MARK
        if folders.count > 0 {
            let chosenFolder = folders[indexPath.row]
            if chosenFolder.marked == true { markTitle = STRING_UNMARK } else { markTitle = STRING_MARK }
        } else {
            if decks[indexPath.row].marked == true { markTitle = STRING_UNMARK } else { markTitle = STRING_MARK }
        }
        
        let markAction = UITableViewRowAction(style: .normal, title: markTitle) { (rowAction, indexPath) in
            if self.folders.count > 0 {
                self.markFolder(atIndexPath: indexPath)
            } else {
                self.decks[indexPath.row].marked = !self.decks[indexPath.row].marked
                self.markDeck(atIndexPath: indexPath)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        addAction.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.662745098, blue: 0.2666666667, alpha: 1)
        markAction.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.7215686275, blue: 0.1215686275, alpha: 1)
        
        return [deleteAction, addAction, markAction]
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
            
            let alertController = UIAlertController(title: STRING_CHOOSE_THE_MODE, message: STRING_EXCERCISE_MODE, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: STRING_MEMORIZE, style: .default, handler: { action in
                let memorizeVC = MemorizeVC()
                memorizeVC.folder = self.getCurrentFolder()
                memorizeVC.part = indexPath.row
                memorizeVC.modalPresentationStyle = .custom
                self.present(memorizeVC, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: STRING_SPELLING, style: .default, handler: { action in
                let spellingVC = SpellingVC()
                spellingVC.folder = self.getCurrentFolder()
                spellingVC.part = indexPath.row
                spellingVC.modalPresentationStyle = .custom
                self.present(spellingVC, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: STRING_CANCEL, style: .cancel, handler: nil))
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
        
        let chosenFolder = folders[indexPath.row]
        performSegue(withIdentifier: TO_CREATE_FOLDER, sender: chosenFolder)
        
        
        
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
    
    func editDeck(atIndexPath indexPath: IndexPath) {
//        let chosenFolder = folders[indexPath.row]
        performSegue(withIdentifier: TO_EDIT_DECK, sender: indexPath.row)
    }
    
    func markFolder(atIndexPath indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let chosenFolder = folders[indexPath.row]
        chosenFolder.marked = !chosenFolder.marked
        do {
            try managedContext.save()
//            print("Successfully marked")
        } catch {
            debugPrint("Could not set progress: \(error.localizedDescription)")
        }
    }
    
    func markDeck(atIndexPath indexPath: IndexPath){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchREquest = NSFetchRequest<DeckMarked>(entityName: "DeckMarked")
        let parentPredicate = NSPredicate(format: "folder == %@", getCurrentFolder()!)
        let numberPredicate = NSPredicate(format: "number == \(indexPath.row)")
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [parentPredicate, numberPredicate])
        fetchREquest.predicate = andPredicate
        
        do {
            let decksMarked = try managedContext.fetch(fetchREquest)
            if decksMarked.count == 0 {
                let deckMarked = DeckMarked(context: managedContext)
                deckMarked.number = Int32(indexPath.row)
                deckMarked.folder = getCurrentFolder()
            } else {
                for deck in decksMarked {
                    managedContext.delete(deck)
                }
            }
        } catch {
            debugPrint("Could not fetch deckMarked: \(error.localizedDescription)")
        }
        
        do {
            try managedContext.save()
//            print("Saved deckMarked")
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
        }
    }
    
    func removeFolder(atIndexPath indexPath: IndexPath) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}

        self.treeArray.removeAll()
        
        buildTreeArray(folder: folders[indexPath.row])
        navigateThroughTree(treeArray: self.treeArray)
        
        managedContext.delete(folders[indexPath.row])

        do {
            try managedContext.save()
//            print("Successfully removed folders")
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
        }
    }
    
    func removeDeck(atIndexPath indexPath: IndexPath) {
//        print("index Path: \(indexPath.row)")
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchREquest = NSFetchRequest<Word>(entityName: "Word")
        fetchREquest.predicate = NSPredicate(format: "folder == %@", getCurrentFolder()!)
        fetchREquest.fetchOffset = indexPath.row * self.wordsAtTime
        fetchREquest.fetchLimit = self.wordsAtTime
        
        do {
            let words = try managedContext.fetch(fetchREquest)
            for word in words {
                managedContext.delete(word)
            }
            try managedContext.save()
//            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
//            completion(false)
        }
    }
    
    func buildTreeArray(folder: Folder) {
        self.treeArray.append(folder)
        for child in folder.children! {
            buildTreeArray(folder: child as! Folder)
        }
    }
    
    func navigateThroughTree(treeArray: [Folder]) {
//        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        for folder in treeArray {
//            print(folder.folderName)
            if folder.image != "default.png" && folder.image != nil {
//                print(folder)
//                print("Hello [\(String(describing: folder.image))] Hello")
                ImageStore.delete(imageNamed: folder.image!)
            }
//            do {
//                try managedContext.save()
//                print("Successfully set progress")
//            } catch {
//                debugPrint("Could not set progress: \(error.localizedDescription)")
//            }
        }
    }
    
    func countWordsInTree(treeArray: [Folder]) -> (Int, Int) {
        var quantity = 0
        var decksQuantity = 0
        for folder in treeArray {
            quantity += (folder.words?.count)!
            decksQuantity += Int(ceil(Double((folder.words?.count)!)/Double(self.wordsAtTime)))
        }
        return (decksQuantity, quantity)
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
//            print("Successfully fetched data")
            
            if folders.count == 0 && parent != nil {
                let fetchWordRequest = NSFetchRequest<Word>(entityName: "Word")
                fetchWordRequest.predicate = NSPredicate(format: "folder == %@", parent!)
                let words = try managedContext.fetch(fetchWordRequest)
                if words.count > 0 {
                    
                    let markedDecks: [DeckMarked] = getMarkedDecks()!
                    
                    let decksQuantity = Int(ceil(Double(words.count)/Double(self.wordsAtTime)))
                    let modulo = words.count % self.wordsAtTime
                    print("Modulo is \(modulo)")
                    
                    for index in 1...decksQuantity {
                        let marked = isDeckMarked(index: index, markedDecks: markedDecks)
                        var info = "\(STRING_CARDS_IN_DECK): \(self.wordsAtTime)"
                        if index == decksQuantity && modulo != 0 {
                            info = "\(STRING_CARDS_IN_DECK): \(modulo)"
                        }
                        let deck = Deck(title: "\(STRING_DECK) \(index)", info: info, marked: marked)
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
    
    func countRepeatedWords(mode: String) -> Int? {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return nil}
        let fetchREquest = NSFetchRequest<DeckMarked>(entityName: "Word")
        let parentPredicate = NSPredicate(format: "learningLang == \(defaults.integer(forKey: "currentLearningLanguage"))")
        let numberPredicate = NSPredicate(format: "\(mode) == true")
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [parentPredicate, numberPredicate])
        fetchREquest.predicate = andPredicate
        do {
            let wordsQuantity = try managedContext.count(for: fetchREquest)
//            print(wordsQuantity)
            return wordsQuantity
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func getMarkedDecks() -> [DeckMarked]? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return nil}
        
        let fetchREquest = NSFetchRequest<DeckMarked>(entityName: "DeckMarked")
        fetchREquest.predicate = NSPredicate(format: "folder == %@", getCurrentFolder()!)
        
        do {
            let decksMarked = try managedContext.fetch(fetchREquest)
            return decksMarked
        } catch {
            debugPrint("Could not fetch deckMarked: \(error.localizedDescription)")
        }
        return nil
    }
    
    func isDeckMarked(index: Int, markedDecks: [DeckMarked]) -> Bool {
        for mark in markedDecks {
//            print("------------------")
//            print("mark.number: \(mark.number)")
//            print("index: \(index)")
//            print("------------------")
            if (mark.number + 1) == index {
                return true
            }
        }
        return false
    }
    
}

extension FoldersVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        
        uploadFromExcel(urls: urls) { (success) in
            
//            self.uploadingView.isHidden = true
//            self.uploadingViewWrapper.isHidden = true
            
            if success {
                self.uploadingView.isHidden = true
                self.uploadingViewWrapper.isHidden = true
            }
        }
//        guard let selectedFileURL = urls.first else {
//            return
//        }
//
////        let fileExtension = selectedFileURL.pathExtension
////        print(fileExtension)
//
//        if selectedFileURL.pathExtension != "xlsx" {
//            return
//        }
//
////        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
////        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
//
////        let documentPath: String = Bundle.main.path(forResource: "one", ofType: "xlsx")!
////        print(documentPath)
////        print(sandboxFileURL.path)
//        let filePath: String = selectedFileURL.path
////        print(filePath)
//
//
//
//        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(filePath)
//        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
//
////        let cell: BRACell? = worksheet.cell(forCellReference: "A2")
////        if cell != nil {
////            let cellVal: String? = cell?.stringValue()
////            print("--------")
////            print(cellVal)
////            //        print(string2)
////            print("--------")
////        } else {
////            print("++++++++++++++///////")
////        }
//
////        let string2: String = worksheet.cell(forCellReference: "B\(counter)").stringValue()
//
//
//        var counter = 1
//
////        let cell: BRACell? = worksheet.cell(forCellReference: "A\(counter)")
////        let cell2: BRACell? = worksheet.cell(forCellReference: "B\(counter)")
//        while worksheet.cell(forCellReference: "A\(counter)") != nil &&
//            worksheet.cell(forCellReference: "B\(counter)") != nil {
////            if cell != nil {
//                let word: String? = worksheet.c ell(forCellReference: "A\(counter)")?.stringValue()
//                let translation: String? = worksheet.cell(forCellReference: "B\(counter)")?.stringValue()
//
////                +++++++++++++++
//                let appDelegate = UIApplication.shared.delegate as? AppDelegate
//                guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
//
//                let newWord = Word(context: managedContext)
//                newWord.word = word?.trimmingCharacters(in: .whitespacesAndNewlines)
//                newWord.translation = translation?.trimmingCharacters(in: .whitespacesAndNewlines)
//                newWord.learningLang = Int32(defaults.integer(forKey: "currentLearningLanguage"))
//                newWord.repeatMem = false
//                newWord.repeatSpell = false
//                newWord.folder = self.getCurrentFolder()
//
//                do {
//                    try managedContext.save()
//                    NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
////                    print("Successfully saved data.")
//
//                } catch {
//                    debugPrint("Could not save: \(error.localizedDescription)")
//                }
////                +++++++++++++++++
//
//
////                print("--------")
////                print(word as Any)
////                print(translation as Any)
////                print("--------")
//
//
//
//                counter += 1
////            } else { print("!!!!!!!!!!") }
//        }
//
//
//
//
////        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
////            print("Already exists! Do nothing")
////        }
////        else {
////
////            do {
////                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
////
////                print("Copied file!")
////            }
////            catch {
////                print("Error: \(error)")
////            }
////        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.uploadingView.isHidden = true
        self.uploadingViewWrapper.isHidden = true
    }
    
    
    func uploadFromExcel(urls: [URL],completion: (_ finished: Bool) -> ()) {
        
        
        
        guard let selectedFileURL = urls.first else {
            return
        }
        if selectedFileURL.pathExtension != "xlsx" {
            return
        }
        let filePath: String = selectedFileURL.path
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(filePath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        var counter = 1
        while worksheet.cell(forCellReference: "A\(counter)") != nil &&
            worksheet.cell(forCellReference: "B\(counter)") != nil {
                let word: String? = worksheet.cell(forCellReference: "A\(counter)")?.stringValue()
                let translation: String? = worksheet.cell(forCellReference: "B\(counter)")?.stringValue()
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
                
                let newWord = Word(context: managedContext)
                newWord.word = word?.trimmingCharacters(in: .whitespacesAndNewlines)
                newWord.translation = translation?.trimmingCharacters(in: .whitespacesAndNewlines)
                newWord.learningLang = Int32(defaults.integer(forKey: "currentLearningLanguage"))
                newWord.repeatMem = false
                newWord.repeatSpell = false
                newWord.folder = self.getCurrentFolder()
                
                do {
                    try managedContext.save()
                    
                } catch {
                    debugPrint("Could not save: \(error.localizedDescription)")
                    completion(false)
                }
                counter += 1
        }
        NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
        completion(true)
        
    }
    
}


extension FoldersVC: CustomAlertViewDelegate {
    func okButtonTapped(selectedOption: Int) {
//        defaults.set(selectedOption, forKey: "wordsAtTime")
//        NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
        print("okButtonTapped")
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}











