//
//  FriendsTableViewCell.swift
//  TravelTracker
//
//  Created by Justin Herzog on 5/1/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var friendsSwitch: UISwitch!
    
    override func awakeFromNib() {
        friendsSwitch.onTintColor = #colorLiteral(red: 0.6392156863, green: 0.6784313725, blue: 0.7215686275, alpha: 1)
    }
    
}
