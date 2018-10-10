//
//  EditDeckCell.swift
//  Vocabularity
//
//  Created by Admin on 10.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class EditDeckCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var wordTextView: UITextView!
    @IBOutlet weak var translationTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    func configureCell(word: Word, counter: Int) {
        self.counterLbl.text = String(counter)
        self.wordTextView.text = word.word
        self.translationTextView.text = word.translation
    }
    
}
