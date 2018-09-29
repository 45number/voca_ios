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
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    var folders: [Folder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreDataObjects()
        tableView.reloadData()
    }
    
    func fetchCoreDataObjects() {
        self.fetch { (complete) in
            if complete {
                if folders.count >= 1 {
                    tableView.isHidden = false
                } else {
                    tableView.isHidden = true
                }
            }
        }
    }
    
    //Actions
    @IBAction func addBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_CREATE_FOLDER, sender: nil)
    }
    
}

extension FoldersVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell") as? FolderCell else { return UITableViewCell() }
        
        let folder = folders[indexPath.row]
        
        cell.configureCell(folder: folder)
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
    
    func fetch(completion: (_ complete: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchREquest = NSFetchRequest<Folder>(entityName: "Folder")
        
        do {
            folders = try managedContext.fetch(fetchREquest)
            print("Successfully fetched data")
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
}
