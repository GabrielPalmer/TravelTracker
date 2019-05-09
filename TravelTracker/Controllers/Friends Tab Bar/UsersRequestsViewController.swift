//
//  FriendRequestsViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class UsersRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.navigationItem.title = ""
    }
    
    @objc func acceptButtonTapped(_ sender: UIButton) {
        FirebaseController.shared.acceptFriendRequest(username: FirebaseController.shared.friendRequests[sender.tag]) {
            print("accepted friend")
            //update friends view controller from tab bar
            self.tableView.reloadData()
        }
    }
    
    @objc func declineButtonTapped(_ sender: UIButton) {
        FirebaseController.shared.declineFriendRequest(username: FirebaseController.shared.friendRequests[sender.tag]) {
            print("declined friend")
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Friend Requests"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.shared.friendRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCell", for: indexPath) as! FriendRequestTableViewCell
        cell.usernameLabel.text = FirebaseController.shared.friendRequests[indexPath.row]
        cell.acceptButton.tag = indexPath.row
        cell.declineButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(acceptButtonTapped(_:)), for: .touchUpInside)
        cell.declineButton.addTarget(self, action: #selector(declineButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }

}
