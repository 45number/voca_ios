//
//  FolderCell.swift
//  Vocabularity
//
//  Created by Admin on 26.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class FolderCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var folderImgView: CircleImage!
    @IBOutlet weak var folderNameLbl: UILabel!
    @IBOutlet weak var folderInfoLbl: UILabel!

    @IBOutlet weak var markedBadge: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(folder: Folder, folderInfo: String) {
        self.folderNameLbl.text = folder.folderName
        self.folderInfoLbl.text = folderInfo
        
        if folder.image != "default.png" && folder.image != nil {
            let folderImg = ImageStore.retrieve(imageNamed: folder.image!)
            self.folderImgView.image = folderImg
        } else {
            self.folderImgView.image = UIImage(named: "photo")
        }
        
        if folder.marked {
            self.markedBadge.isHidden = false
        } else {
            self.markedBadge.isHidden = true
        }
        
//        if goal.goalProgress == goal.goalCompletionValue {
//            self.completionView.isHidden = false
//        } else {
//            self.completionView.isHidden = true
//        }
    }
    
    func configureCellForDeck(deck: Deck) {
        self.folderNameLbl.text = deck.title
        self.folderInfoLbl.text = deck.info
        self.folderImgView.image = UIImage(named: "pile")
        
        if deck.marked {
            self.markedBadge.isHidden = false
        } else {
            self.markedBadge.isHidden = true
        }
        
//        if folder.image != "default.png" && folder.image != nil {
//            let folderImg = ImageStore.retrieve(imageNamed: folder.image!)
//            self.folderImgView.image = folderImg
//        }
        
        //        if goal.goalProgress == goal.goalCompletionValue {
        //            self.completionView.isHidden = false
        //        } else {
        //            self.completionView.isHidden = true
        //        }
    }
    

}
