//
//  FriendRequestTableViewCell.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 5/7/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        acceptButton.layer.cornerRadius = 5
        declineButton.layer.cornerRadius = 5
    }
}
