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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 25))
        view.backgroundColor = #colorLiteral(red: 0.6392156863, green: 0.6784313725, blue: 0.7215686275, alpha: 1)
        let friendsRequestLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        friendsRequestLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(friendsRequestLabel)
        friendsRequestLabel.font = UIFont(name: "Futura", size: 17)
        friendsRequestLabel.text = "Friends Requests"
        friendsRequestLabel.textColor = #colorLiteral(red: 0.2509803922, green: 0.3098039216, blue: 0.1411764706, alpha: 1)
        view.addConstraints([NSLayoutConstraint(item: friendsRequestLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: friendsRequestLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: friendsRequestLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 8)])
        return view
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
