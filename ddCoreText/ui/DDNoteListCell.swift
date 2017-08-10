//
//  DDNoteListCell.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/20.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

class DDNoteListCell: UITableViewCell {
    
    var content: String = "" {
        didSet {
            contentLabel.text = content
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
