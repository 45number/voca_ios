//
//  EditDeckCell.swift
//  Vocabularity
//
//  Created by Admin on 10.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

protocol DeckCellDelegate {
    func cellDataChanged(cell: EditDeckCell)
}


class EditDeckCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var wordTextView: UITextView!
    @IBOutlet weak var translationTextView: UITextView!
    
    //Variables
    var delegate: DeckCellDelegate?

//    var word: Word
//
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wordTextView.delegate = self
        
        translationTextView.delegate = self
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

extension EditDeckCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
//        let startHeight = textView.frame.size.height
//        let calcHeight = textView.sizeThatFits(textView.frame.size).height
        
        delegate?.cellDataChanged(cell: self)
        
//        if startHeight != calcHeight {
//            NotificationCenter.default.post(name: NOTIF_TEXT_VIEW_DID_CHANGE, object: nil)
//        }
        
        
    }
}
