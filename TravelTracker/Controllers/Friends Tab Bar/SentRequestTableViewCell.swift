//
//  RequestFriendTableViewCell.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 5/3/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class SentRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cancelButton.layer.cornerRadius = 5
    }

}
