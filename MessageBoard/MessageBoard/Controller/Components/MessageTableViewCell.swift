//
//  MessageTableViewCell.swift
//  MessageBoard
//
//  Created by imac-1681 on 2023/1/17.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messagePeopleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    static let identifier = "MessageTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
