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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 25))
            view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            let showPinsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            let youLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            showPinsLabel.translatesAutoresizingMaskIntoConstraints = false
            youLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(showPinsLabel)
            view.addSubview(youLabel)
            showPinsLabel.font = UIFont(name: "Futura", size: 17)
            showPinsLabel.text = "Show Pins"
            view.addConstraints([NSLayoutConstraint(item: showPinsLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: showPinsLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: showPinsLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -16)])
            youLabel.font = UIFont(name: "Futura", size: 17)
            youLabel.text = "You"
            view.addConstraints([NSLayoutConstraint(item: youLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: youLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: youLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 8)])
            return view
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 25))
            view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            let friendsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            friendsLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(friendsLabel)
            friendsLabel.font = UIFont(name: "Futura", size: 17)
            friendsLabel.text = "Friends"
            view.addConstraints([NSLayoutConstraint(item: friendsLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: friendsLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: friendsLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 8)])
            return view
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return (FirebaseController.friends.count)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
        if indexPath.section == 0 {
            let user = FirebaseController.currentUser!
            cell.nameLabel.text = user.name
            cell.usernameLabel.text = user.username
            cell.friendsSwitch.isOn = user.pinsVisible
            cell.friendsSwitch.tag = -1
            cell.friendsSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            return cell
        } else {
            let friend = FirebaseController.friends[indexPath.row]
            cell.nameLabel.text = friend.name
            cell.usernameLabel.text = friend.username
            cell.friendsSwitch.isOn = friend.pinsVisible
            cell.friendsSwitch.tag = indexPath.row
            cell.friendsSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            return cell
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        let user = sender.tag == -1 ? FirebaseController.currentUser! : FirebaseController.friends[sender.tag]
        var removedIndexes: [Int] = []
        if !changedUsers.isEmpty { 
            for index in 0...(changedUsers.count - 1) {
                let indexedUser = changedUsers[index]
                if user.username == indexedUser.username {
                    removedIndexes.append(index)
                } else {
                    changedUsers.append(user)
                }
            }
        } else {
            changedUsers.append(user)
        }
        if removedIndexes.count > 0 {
            changedUsers.remove(at: removedIndexes)
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
