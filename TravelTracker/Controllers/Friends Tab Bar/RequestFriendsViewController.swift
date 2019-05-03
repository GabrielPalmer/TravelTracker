//
//  SearchViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class RequestFriendsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func cellCancelButtonTapped(_ sender: UIButton) {
        
    }
    
    //===========================================
    // MARK: - Table View Data Source
    //===========================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.sentRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sentRequestCell", for: indexPath) as! SentRequestTableViewCell
        cell.usernameLabel.text = "\(FirebaseController.sentRequests[indexPath.row]) was requested as a friend"
        cell.cancelButton.addTarget(self, action: #selector(cellCancelButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    //===========================================
    // MARK: - Search Bar Delegate
    //===========================================
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        
        guard !FirebaseController.friendUsernames.contains(searchTerm) else {
            let alertController = UIAlertController(title: "That user is already your friend", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true)
            return
        }
        
        FirebaseController.sendFriendRequest(username: searchTerm) { (success) in
            if success {
                
            } else {
                let alertController = UIAlertController(title: "Could not find anyone with that username", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true)
            }
        }
        
    }

}
