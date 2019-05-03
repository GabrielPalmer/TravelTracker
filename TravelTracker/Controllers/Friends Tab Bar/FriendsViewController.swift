//
//  FriendsViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var changedUsers: [User] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        updateVisiblePins()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "You"
        } else {
            return "Friends"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return (FirebaseController.friends.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
        if indexPath.section == 0 {
            let user = FirebaseController.currentUser!
            cell.nameLabel.text = user.name
            cell.usernameLabel.text = user.username
            cell.pinsVisible.text = "Show Pins (\(user.markers.count))"
            cell.friendsSwitch.isOn = user.pinsVisible
            cell.friendsSwitch.tag = -1
            cell.friendsSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            return cell
        } else {
            let friend = FirebaseController.friends[indexPath.row]
            cell.nameLabel.text = friend.name
            cell.usernameLabel.text = friend.username
            cell.pinsVisible.text = "Show Pins (\(friend.markers.count))"
            cell.friendsSwitch.isOn = friend.pinsVisible
            cell.friendsSwitch.tag = indexPath.row
            cell.friendsSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            return cell
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        let user = sender.tag == -1 ? FirebaseController.currentUser! : FirebaseController.friends[sender.tag]
        var removedIndexes: [Int] = []
        var addedUsers: [User] = []
        if !changedUsers.isEmpty { 
            for index in 0...(changedUsers.count - 1) { // Loops the following for as many as changedUsers.count - 1
                let indexedUser = changedUsers[index] // Sets a variable indexedUser to the user for the current index of the changedUsers array
                if user.username == indexedUser.username { // If the user's username is the same as the indexedUser's username run the following
                    removedIndexes.append(index) // Removes the user for the current index of the changeUsers array
                } else { // If the user's username is not the same as the indexedUser's username run the following
                    addedUsers.append(indexedUser) // Add the user to the changedUsers array
                }
            }
        } else { // If the changedUsers array is empty run the following
            changedUsers.append(user) // Add the user to the changedUsers array
        }
        changedUsers.remove(at: removedIndexes)
        for user in addedUsers {
            changedUsers.append(user)
        }
        user.pinsVisible = !user.pinsVisible
        updateVisiblePins()
    }
    
    func updateVisiblePins() {
        var visiblePins: Int = 0
        for friend in FirebaseController.friends {
            if friend.pinsVisible == true {
                visiblePins += friend.markers.count
            }
        }
        if FirebaseController.currentUser!.pinsVisible == true {
            visiblePins += FirebaseController.currentUser!.markers.count
        }
        tabBarController?.navigationItem.title = "Visible Pins: \(visiblePins)"
    }
}
