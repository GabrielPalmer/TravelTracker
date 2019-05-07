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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //set up tab bar delegate and animation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.navigationItem.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        
        loadingIndicator.isHidden = true
        loadingIndicator.color = UIColor.black
    }
    
    @objc func cellCancelButtonTapped(_ sender: UIButton) {
        let username = FirebaseController.sentRequests[sender.tag]
        
        searchBar.isUserInteractionEnabled = false
        tableView.isUserInteractionEnabled = false
        loadingIndicator.isHidden = false
        
        FirebaseController.cancelFriendRequest(username: username) { (success) in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                } else {
                    let alertController = UIAlertController(title: "Failed to remove friend request", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true)
                }
                
                self.searchBar.isUserInteractionEnabled = true
                self.tableView.isUserInteractionEnabled = true
                self.loadingIndicator.isHidden = true
            }
        }
    }
    
    //===========================================
    // MARK: - Table View Data Source
    //===========================================
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sent Requests"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.sentRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sentRequestCell", for: indexPath) as! SentRequestTableViewCell
        cell.usernameLabel.text = "\(FirebaseController.sentRequests[indexPath.row]) was requested as a friend"
        cell.cancelButton.addTarget(self, action: #selector(cellCancelButtonTapped(_:)), for: .touchUpInside)
        cell.cancelButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //===========================================
    // MARK: - Search Bar Delegate
    //===========================================
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print("search bar button was clicked")
        
        searchBar.isUserInteractionEnabled = false
        tableView.isUserInteractionEnabled = false
        loadingIndicator.isHidden = false
        
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        
        guard !FirebaseController.friendUsernames.contains(searchTerm) else {
            let alertController = UIAlertController(title: "That user is already your friend", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true)
            return
        }
        
        FirebaseController.sendFriendRequest(username: searchTerm) { (success) in
            
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                    self.searchBar.text = ""
                } else {
                    let alertController = UIAlertController(title: "Could not find anyone with that username", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true)
                }
                
                self.searchBar.isUserInteractionEnabled = true
                self.tableView.isUserInteractionEnabled = true
                self.loadingIndicator.isHidden = true
            }
        }
        
    }
    
    

}
