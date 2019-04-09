//
//  User.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 4/7/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class User {
    let name: String
    let username: String
    let password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
}